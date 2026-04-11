local M = {}

local function plugin_root()
  return vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h:h")
end

-- Run build.sh to create the plugin-local venv if it does not exist yet.
local function ensure_venv(root, on_done)
  local venv_py = root .. "/.venv/bin/python3"
  if vim.fn.executable(venv_py) == 1 then
    on_done(true)
    return
  end

  local build_sh = root .. "/build.sh"
  if vim.fn.filereadable(build_sh) == 0 then
    on_done(false)
    return
  end

  vim.notify("fsm-nvim: installing server dependencies...", vim.log.levels.INFO)
  vim.fn.jobstart({ "sh", build_sh }, {
    cwd = root,
    on_exit = function(_, code)
      if code == 0 then
        vim.notify("fsm-nvim: server ready.", vim.log.levels.INFO)
        on_done(true)
      else
        vim.notify("fsm-nvim: build.sh failed (exit " .. code .. ")", vim.log.levels.ERROR)
        on_done(false)
      end
    end,
  })
end

local function find_python(root, hint)
  local candidates = {}
  if hint then
    table.insert(candidates, hint)
  end
  table.insert(candidates, root .. "/.venv/bin/python3")
  table.insert(candidates, "python3")
  table.insert(candidates, "python")

  for _, cmd in ipairs(candidates) do
    if vim.fn.executable(cmd) == 1 then
      local result = vim.fn.system({ cmd, "-c", "import pygls.lsp.server" })
      if vim.v.shell_error == 0 then
        return cmd
      end
    end
  end
  return nil
end

local function register_server(root, opts)
  local server_script = root .. "/server/fsm_lsp.py"
  if vim.fn.filereadable(server_script) == 0 then
    vim.notify("fsm-nvim: server script not found: " .. server_script, vim.log.levels.ERROR)
    return
  end

  local python = find_python(root, opts.python)
  if not python then
    vim.notify(
      "fsm-nvim: no python with pygls found; LSP unavailable.",
      vim.log.levels.WARN
    )
    return
  end

  local cmd = { python, server_script }

  local server_opts = {
    cmd = cmd,
    filetypes = { "fsm" },
    root_markers = { ".git" },
    settings = {},
  }

  if vim.lsp.config then
    vim.lsp.config("fsm_ls", server_opts)
    vim.lsp.enable("fsm_ls")
    return
  end

  local ok, lspconfig = pcall(require, "lspconfig")
  if ok then
    local configs = require("lspconfig.configs")
    if not configs.fsm_ls then
      configs.fsm_ls = {
        default_config = vim.tbl_extend("force", server_opts, {
          name = "fsm_ls",
          docs = { description = "Language server for the TextX FSM DSL (.fsm files)" },
        }),
      }
    end
    lspconfig.fsm_ls.setup(opts.lspconfig or {})
    return
  end

  vim.notify("fsm-nvim: Neovim >= 0.11 or nvim-lspconfig is required for LSP.", vim.log.levels.WARN)
end

function M.setup(opts)
  opts = opts or {}
  local root = plugin_root()
  ensure_venv(root, function(ok)
    if ok then
      register_server(root, opts)
    end
  end)
end

return M
