local M = {}

local function plugin_root()
  return vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h:h")
end

-- Find a Python executable that has pygls available.
local function find_python(hint)
  local candidates = {}
  if hint then
    table.insert(candidates, hint)
  end
  -- Prefer a venv python in common project-root locations
  local cwd = vim.fn.getcwd()
  for _, rel in ipairs({ ".venv/bin/python3", "venv/bin/python3" }) do
    table.insert(candidates, cwd .. "/" .. rel)
  end
  table.insert(candidates, "python3")
  table.insert(candidates, "python")

  for _, cmd in ipairs(candidates) do
    if vim.fn.executable(cmd) == 1 then
      -- Quick check: can we import pygls?
      local result = vim.fn.system({ cmd, "-c", "import pygls.lsp.server" })
      if vim.v.shell_error == 0 then
        return cmd
      end
    end
  end
  return nil
end

function M.setup(opts)
  opts = opts or {}
  local root = plugin_root()
  local server_script = root .. "/server/fsm_lsp.py"

  if vim.fn.filereadable(server_script) == 0 then
    vim.notify("fsm-nvim: server script not found: " .. server_script, vim.log.levels.ERROR)
    return
  end

  local python = find_python(opts.python)
  if not python then
    vim.notify(
      "fsm-nvim: python with pygls not found. "
        .. "Install pygls: pip install pygls\n"
        .. "Or set opts.python to the path of a python executable that has pygls.",
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

  -- Neovim >= 0.11: use vim.lsp.config / vim.lsp.enable
  if vim.lsp.config then
    vim.lsp.config("fsm_ls", server_opts)
    vim.lsp.enable("fsm_ls")
    return
  end

  -- Fallback: nvim-lspconfig
  local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
  if lspconfig_ok then
    local configs = require("lspconfig.configs")
    if not configs.fsm_ls then
      configs.fsm_ls = {
        default_config = vim.tbl_extend("force", server_opts, {
          name = "fsm_ls",
          docs = {
            description = "Language server for the TextX FSM DSL (.fsm files)",
          },
        }),
      }
    end
    lspconfig.fsm_ls.setup(opts.lspconfig or {})
    return
  end

  vim.notify(
    "fsm-nvim: Neovim >= 0.11 or nvim-lspconfig is required for LSP support.",
    vim.log.levels.WARN
  )
end

return M
