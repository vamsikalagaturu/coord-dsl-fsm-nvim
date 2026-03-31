local M = {}

---@class FsmNvimConfig
---@field enable_lsp boolean Enable the FSM language server (default: true)
---@field enable_treesitter boolean Register the FSM parser with nvim-treesitter (default: true)
---@field python string|nil Path to a python executable that has pygls installed (auto-detected if nil)
---@field grammar_path string|nil Path to a coord-dsl repo (local fork or clone). Uses bundled submodule if nil.
---@field lspconfig table|nil Extra options forwarded to lspconfig.fsm_ls.setup() when using nvim-lspconfig

M.config = {
  enable_lsp = true,
  enable_treesitter = true,
  python = nil,
  grammar_path = nil,
  lspconfig = {},
}

---Setup the fsm-nvim plugin.
---@param opts FsmNvimConfig|nil
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  vim.filetype.add({ extension = { fsm = "fsm" } })

  if M.config.enable_treesitter then
    require("fsm-nvim.treesitter").setup()
  end

  if M.config.enable_lsp then
    require("fsm-nvim.lsp").setup(M.config)
  end
end

return M
