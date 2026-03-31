# fsm-nvim

Neovim plugin for the [coord-dsl](https://github.com/secorolab/coord-dsl) TextX FSM DSL (`.fsm` files).

Provides:
- Syntax highlighting via tree-sitter (with vim regex fallback)
- LSP diagnostics and hover docs via a bundled Python language server

## Requirements

- Neovim >= 0.10 (0.11+ recommended for native `vim.lsp.config`)
- Python 3.10+
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) (optional, for tree-sitter highlighting)

Python dependencies (`pygls`, `textX`) are installed automatically into a plugin-local virtualenv on first use.

## Installation

### lazy.nvim / LazyVim

```lua
{
  "vamsikalagaturu/coord-dsl-fsm-nvim",
  ft = "fsm",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("fsm-nvim").setup()
  end,
}
```

Run `:TSInstall fsm` once to compile the tree-sitter parser.

## Configuration

```lua
require("fsm-nvim").setup({
  -- python executable with pygls + textX (auto-detected if nil)
  python = nil,

  -- path to a coord-dsl repo root (local fork or clone)
  -- uses the bundled submodule (secorolab/coord-dsl) if nil
  grammar_path = nil,

  -- register FSM parser with nvim-treesitter (default: true)
  enable_treesitter = true,

  -- start the FSM language server (default: true)
  enable_lsp = true,
})
```

### Using a local or forked coord-dsl

```lua
require("fsm-nvim").setup({
  grammar_path = "/path/to/your/coord-dsl",
})
```

The plugin expects `<grammar_path>/src/coord_dsl/metamodels/fsm.tx` to exist.

## Syntax highlighting

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

MIT — see [LICENSE](LICENSE)
