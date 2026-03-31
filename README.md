# fsm-nvim

Neovim plugin for the [coord-dsl](https://github.com/vamsikalagaturu/coord-dsl) TextX FSM DSL (`.fsm` files).

Provides:
- Syntax highlighting via tree-sitter (with vim regex fallback)
- LSP diagnostics, hover docs via a bundled Python language server

## Requirements

- Neovim >= 0.10 (0.11+ recommended for native `vim.lsp.config`)
- Python 3.7+ with `pygls >= 2.0` and `textX >= 4.1` in the active environment
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) (optional, for tree-sitter highlighting)

Install Python dependencies:
```sh
pip install pygls textX
```

## Installation

### lazy.nvim / LazyVim

```lua
{
  "vamsikalagaturu/coord-dsl-fsm-nvim",
  ft = "fsm",
  config = function()
    require("fsm-nvim").setup()
  end,
}
```

To point at a specific Python executable:
```lua
require("fsm-nvim").setup({
  python = "/path/to/.venv/bin/python3",
})
```

### Tree-sitter parser

After installing the plugin, run `:TSInstall fsm` once to compile the parser.

## Configuration

```lua
require("fsm-nvim").setup({
  -- python executable that has pygls + textX installed (auto-detected if nil)
  python = nil,

  -- register FSM parser with nvim-treesitter (default: true)
  enable_treesitter = true,

  -- start the FSM language server (default: true)
  enable_lsp = true,

  -- extra opts forwarded to lspconfig.fsm_ls.setup() on Neovim < 0.11
  lspconfig = {},
})
```

## LSP features

| Feature | Status |
|---------|--------|
| Diagnostics (syntax errors) | yes |
| Hover documentation | yes (keywords) |
| Go-to-definition | planned |
| Completion | planned |

## Syntax highlighting groups

The tree-sitter highlights map to standard Neovim capture names:

| Construct | Capture |
|-----------|---------|
| Section keywords (`NAME`, `STATES`, ...) | `@keyword` |
| Clause keywords (`FROM`, `TO`, `WHEN`, `DO`, `FIRES`) | `@keyword` |
| `ns` | `@keyword.import` |
| State names | `@type` |
| Event names | `@variable` |
| Transition / reaction names | `@function` |
| `@references` | `@variable.member` |
| Namespace identifiers | `@module` |
| Strings | `@string` |
| Comments | `@comment` |

## License

MIT
