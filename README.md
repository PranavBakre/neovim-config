# Neovim configuration

A macOS-oriented [LazyVim](https://www.lazyvim.org/) configuration for [Neovide](https://neovide.dev/), with familiar editor shortcuts and language-server shutdown for inactive windows.

## Features

- File explorer with single-click opening, file tabs, project search, and mouse support.
- TypeScript 7.0.2 native language server, installed separately from project dependencies.
- Type information after hovering for 500 ms; definition, implementation, and reference navigation.
- Multiple persistent shells in one bottom terminal dock, excluded from file tabs.
- Language servers stop after five minutes unfocused and restart on return. Buffers and unsaved edits stay open.
- Folder launches set the project directory for search and terminals.

This remains a modal editor: press `i` to type and `Esc` to return to Normal mode. It does not hibernate entire windows to disk; terminals and development servers continue running when language servers stop.

## Install on macOS

Requires Git, Node.js/npm, and Neovim 0.12+. Neovide is needed for the Command-key shortcuts.

```bash
brew install neovim node ripgrep fd lazygit tree-sitter-cli
brew install --cask neovide-app font-jetbrains-mono-nerd-font
```

Back up an existing `~/.config/nvim` before cloning. If you use another Neovim setup, also preserve its data, state, and cache before replacing it.

```bash
git clone https://github.com/PranavBakre/neovim-config.git ~/.config/nvim
bash ~/.config/nvim/scripts/install-typescript.sh
neovide --chdir /absolute/path/to/project /absolute/path/to/project
```

Allow plugin and syntax-parser installation to finish on first launch. Use `:Lazy restore` to restore plugin versions recorded in `lazy-lock.json`; `:Mason` manages additional language servers. The TypeScript installer uses Neovim's data directory, including custom XDG/NVIM_APPNAME settings.

## Controls

| Action | Shortcut |
|---|---|
| Find file | Cmd+P |
| Search project | Cmd+Shift+F |
| Command palette | Cmd+Shift+P |
| Toggle explorer | Cmd+B |
| Save / close file | Cmd+S / Cmd+W |
| Definition | Cmd+click or F12 |
| Implementation | Cmd+F12 |
| References | Shift+F12 |
| Type information | Mouse hover or Cmd+K |
| Toggle terminal dock | Ctrl+backtick |
| New terminal | Cmd+Shift+backtick |
| Select terminal | Cmd+Shift+J |

See [START-HERE.md](START-HERE.md) for the full guide and command alternatives.

## Configuration

- `lua/config/options.lua`: mouse, font, launch directory, idle timeout.
- `lua/config/keymaps.lua`: editor and terminal shortcuts.
- `lua/local_config/idle_lsp.lua`: idle language-server lifecycle.
- `lua/local_config/terminal_dock.lua`: terminal selection and dock behavior.
- `lua/plugins/workspace.lua`: native TypeScript server, explorer, file-tab filtering.
- `lua/plugins/hover.lua`: mouse-hover type information.

Run `:LspSleep` to stop servers immediately, `:LspWake` to restart them, and `:LspSleepStatus` to inspect their state. Change `vim.g.idle_lsp_timeout_ms` to adjust the five-minute timeout.

## TypeScript compatibility

Using this configuration does not upgrade a project's compiler dependency. TypeScript 7 can report different diagnostics from older project compilers, and some framework language-service plugins are not supported.

TypeScript 7 removed `baseUrl`. Projects that used `"baseUrl": "."` for root-relative imports need equivalent `paths` entries (for example `"*": ["./*"]`), preserving any existing aliases. Review this migration in each project; the installer does not change project files.

Neovide currently uses a fixed mouse pointer rather than changing its shape over clickable items.

## Attribution

Based on [LazyVim/starter](https://github.com/LazyVim/starter). The original Apache-2.0 license is preserved in [LICENSE](LICENSE). Editor behavior, terminal management, native TypeScript setup, and documentation have been customized.
