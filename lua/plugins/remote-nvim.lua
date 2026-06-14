local TREE_SITTER_VERSION = "0.24.0"
local TREE_SITTER_ARCHIVE = "tree-sitter-linux-x64.gz"

local PROXY_ENV_NAMES = {
  "http_proxy",
  "https_proxy",
  "all_proxy",
  "HTTP_PROXY",
  "HTTPS_PROXY",
  "ALL_PROXY",
  "no_proxy",
  "NO_PROXY",
}

local function executable(name)
  local path = vim.fn.exepath(name)
  if path ~= "" then
    return path
  end

  for _, prefix in ipairs({ "/usr/bin", "/bin", "/usr/local/bin", "/opt/homebrew/bin" }) do
    local candidate = ("%s/%s"):format(prefix, name)
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end

  return name
end

local function tree_sitter_archive_path()
  local cache_dir = vim.fn.stdpath("cache") .. "/remote-nvim.nvim"
  vim.fn.mkdir(cache_dir, "p")
  return ("%s/%s"):format(cache_dir, TREE_SITTER_ARCHIVE)
end

local function ensure_local_tree_sitter_archive()
  local archive_path = tree_sitter_archive_path()
  if (vim.uv or vim.loop).fs_stat(archive_path) then
    return archive_path
  end

  local url = ("https://github.com/tree-sitter/tree-sitter/releases/download/v%s/%s"):format(
    TREE_SITTER_VERSION,
    TREE_SITTER_ARCHIVE
  )
  local downloader
  if vim.fn.executable(executable("curl")) == 1 then
    downloader = { executable("curl"), "-L", "-o", archive_path, url }
  elseif vim.fn.executable(executable("wget")) == 1 then
    downloader = { executable("wget"), "-O", archive_path, url }
  end

  if not downloader then
    error("curl or wget is required locally to download tree-sitter " .. TREE_SITTER_VERSION)
  end

  local output = vim.fn.system(downloader)
  if vim.v.shell_error ~= 0 then
    vim.fn.delete(archive_path)
    error(("Failed to download tree-sitter %s:\n%s"):format(TREE_SITTER_VERSION, output))
  end

  return archive_path
end

local function stdout_contains(provider, text)
  return table.concat(provider.executor:job_stdout(), "\n"):find(text, 1, true) ~= nil
end

local function remote_proxy_prefix()
  local assignments = {}
  for _, name in ipairs(PROXY_ENV_NAMES) do
    local value = vim.env[name]
    if value and value ~= "" then
      table.insert(assignments, ("%s=%s"):format(name, vim.fn.shellescape(value)))
    end
  end

  if #assignments == 0 then
    return nil
  end

  return "export " .. table.concat(assignments, " ") .. "; "
end

local function patch_remote_proxy_env(SSHExecutor)
  if SSHExecutor._remote_nvim_proxy_env then
    return
  end

  -- remote-nvim 通过非交互 SSH/bash 执行远端命令，不会读取容器里的
  -- .zshrc。把本地 Neovim 进程里的代理变量显式带过去，供 curl/wget 使用。
  local ssh_build_run_command = SSHExecutor._build_run_command
  function SSHExecutor:_build_run_command(command, job_opts)
    local prefix = remote_proxy_prefix()
    if prefix then
      command = prefix .. command
    end
    return ssh_build_run_command(self, command, job_opts)
  end

  SSHExecutor._remote_nvim_proxy_env = true
end

local function force_compressed_uploads(SSHExecutor)
  if SSHExecutor._remote_nvim_force_tar_upload then
    return
  end

  -- 有些 devcontainer 镜像没有 scp。强制走 tar | ssh tar 上传，
  -- 这样复制脚本、配置和缓存文件都不依赖远端 scp。
  local ssh_upload = SSHExecutor.upload
  function SSHExecutor:upload(localSrcPath, remoteDestPath, job_opts)
    job_opts = job_opts or {}
    job_opts.compression = vim.tbl_deep_extend("force", job_opts.compression or {}, {
      enabled = true,
      additional_opts = {},
    })
    return ssh_upload(self, localSrcPath, remoteDestPath, job_opts)
  end

  SSHExecutor._remote_nvim_force_tar_upload = true
end

local function patch_devpod_provider(DevpodProvider, Provider, remote_nvim)
  -- 只停止远端 nvim server，不自动 stop DevPod workspace，避免每次断开 UI
  -- 都把开发容器停掉。
  function DevpodProvider:stop_neovim()
    Provider.stop_neovim(self)
    self._devpod_workspace_active = false
  end

  function DevpodProvider:_stop_devpod_workspace()
    self._devpod_workspace_active = false
  end

  -- DevPod 在 PTY 模式下可能先输出控制字符再输出 JSON。只截取 JSON
  -- 对象边界，避免 provider list 的解码被前缀噪声打断。
  function DevpodProvider:_handle_provider_setup()
    if not self._devpod_provider then
      return
    end

    self.local_provider:run_command(
      ("%s provider list --output json"):format(remote_nvim.config.devpod.binary),
      ("Checking if the %s provider is present"):format(self._devpod_provider)
    )

    local raw = table.concat(self.local_provider.executor:job_stdout(), "\n")
    local json_start = raw:find("{", 1, true)
    local json_end = raw:match(".*()}")
    local json = json_start and json_end and raw:sub(json_start, json_end) or "{}"
    local ok, provider_list_output = pcall(vim.json.decode, json)
    provider_list_output = ok and provider_list_output or {}

    if not vim.tbl_contains(vim.tbl_keys(provider_list_output), self._devpod_provider) then
      self.local_provider:run_command(
        ("%s provider add %s"):format(remote_nvim.config.devpod.binary, self._devpod_provider),
        ("Adding %s provider to DevPod"):format(self._devpod_provider)
      )
    end
  end
end

local function patch_tree_sitter_for_ubuntu_2204(Provider)
  if Provider._remote_nvim_tree_sitter_ubuntu2204 then
    return
  end

  local setup_remote = Provider._setup_remote
  function Provider:_setup_remote()
    setup_remote(self)

    -- Ubuntu 22.04 仓库里的 tree-sitter 偏旧，部分插件会因为版本不够而失败。
    -- 只在远端确认为 Ubuntu 22.04 时上传固定版本的官方二进制。
    local detect_ubuntu_2204_cmd = table.concat({
      [[if [ -r /etc/os-release ]; then . /etc/os-release; fi]],
      [[if [ "${ID:-}" = "ubuntu" ] && [ "${VERSION_ID:-}" = "22.04" ]; then echo ubuntu-22.04; fi]],
    }, "; ")
    self:run_command(detect_ubuntu_2204_cmd, "Checking remote OS for tree-sitter")
    if not stdout_contains(self, "ubuntu-22.04") then
      return
    end

    local check_tree_sitter_cmd = table.concat({
      [[if command -v tree-sitter >/dev/null 2>&1]],
      ([[&& [ "$(tree-sitter --version 2>/dev/null | awk '{print $NF}')" = "%s" ]; then]]):format(
        TREE_SITTER_VERSION
      ),
      [[echo tree-sitter-ok;]],
      [[fi]],
    }, " ")
    self:run_command(check_tree_sitter_cmd, "Checking tree-sitter version")
    if stdout_contains(self, "tree-sitter-ok") then
      return
    end

    self:upload(
      ensure_local_tree_sitter_archive(),
      "/tmp",
      ("Uploading tree-sitter v%s to remote"):format(TREE_SITTER_VERSION)
    )

    local install_tree_sitter_binary_cmd = table.concat({
      [[if [ "$(id -u)" -eq 0 ]; then]],
      [[mv tree-sitter-linux-x64 /usr/local/bin/tree-sitter;]],
      [[elif command -v sudo >/dev/null 2>&1; then]],
      [[sudo mv tree-sitter-linux-x64 /usr/local/bin/ee-sitter;]],
      [[else mkdir -p "$HOME/.local/bin";]],
      [[mv tree-sitter-linux-x64 "$HOME/.local/bin/tree-sitter";]],
      [[fi]],
    }, " ")
    local print_tree_sitter_version_cmd = table.concat({
      [[if command -v tree-sitter >/dev/null 2>&1; then]],
      [[tree-sitter --version;]],
      [[else "$HOME/.local/bin/tree-sitter" --version;]],
      [[fi]],
    }, " ")
    self:run_command(
      table.concat({
        "set -eu",
        "cd /tmp",
        "rm -f tree-sitter-linux-x64",
        "gunzip -f tree-sitter-linux-x64.gz",
        "chmod +x tree-sitter-linux-x64",
        install_tree_sitter_binary_cmd,
        print_tree_sitter_version_cmd,
      }, " && "),
      ("Installing tree-sitter v%s on Ubuntu 22.04"):format(TREE_SITTER_VERSION)
    )
  end

  Provider._remote_nvim_tree_sitter_ubuntu2204 = true
end

return {
  "amitds1997/remote-nvim.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    local remote_nvim = require("remote-nvim")

    remote_nvim.setup({
      devpod = {
        binary = executable("devpod"),
        docker_binary = executable("docker"),
      },
      ssh_config = {
        ssh_binary = executable("ssh"),
        scp_binary = executable("scp"),
      },
      client_callback = function(port, _)
        local server = ("localhost:%s"):format(port)
        local neovide = executable("neovide.exe")
        if vim.fn.executable(neovide) ~= 1 then
          vim.notify("neovide.exe not found in PATH", vim.log.levels.ERROR)
          return
        end

        local job = vim.fn.jobstart({ neovide, "--wsl", "--frame", "none", "--server", server }, {
          cwd = (vim.uv or vim.loop).cwd(),
          detach = true,
        })
        if job <= 0 then
          vim.notify("Failed to launch remote Neovim UI with neovide.exe", vim.log.levels.ERROR)
        end
      end,
    })

    local SSHExecutor = require("remote-nvim.providers.ssh.ssh_executor")
    patch_remote_proxy_env(SSHExecutor)
    force_compressed_uploads(SSHExecutor)

    local DevpodProvider = require("remote-nvim.providers.devpod.devpod_provider")
    local Provider = require("remote-nvim.providers.provider")
    patch_devpod_provider(DevpodProvider, Provider, remote_nvim)
    patch_tree_sitter_for_ubuntu_2204(Provider)
  end,
}
