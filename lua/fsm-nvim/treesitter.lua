local M = {}

-- Return the plugin root directory (two levels up from this file)
local function plugin_root()
  return vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h:h")
end

function M.setup()
  -- Register with nvim-treesitter if present
  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if ok then
    local root = plugin_root()
    local configs = type(parsers.get_parser_configs) == "function"
      and parsers.get_parser_configs()
      or parsers
    configs.fsm = {
      install_info = {
        url = root,
        files = { "src/parser.c" },
        generate_requires_npm = false,
        requires_generate_from_grammar = false,
      },
      filetype = "fsm",
      maintainers = {},
    }
    return
  end

  -- Fallback: register the parser directly via vim.treesitter if compiled .so
  -- is already on the runtimepath (e.g. the user installed it manually).
  -- Nothing extra needed; Neovim auto-loads parsers from parser/ directories.
end

return M
