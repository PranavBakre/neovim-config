# Your Neovim setup

Launch a project in a separate window:

    neovide /absolute/path/to/project

Mouse: click to position the cursor, drag to select, scroll, and drag split borders.
Pause the mouse over a symbol for 500 ms to see its type and documentation.
Cmd+K shows type information at the editing cursor (Normal or Insert mode).

Single-click files in the explorer to open them. Click file names in the top bar to switch.

## Mac shortcuts (Neovide)

- Cmd+S: save
- Cmd+P: find file
- Cmd+Shift+P: command palette
- Cmd+Shift+F: search project
- Cmd+B: toggle file explorer
- Cmd+W: close file (prompts for unsaved edits)
- Cmd+backtick / Ctrl+backtick: bottom project terminal (also toggles from terminal input)
- Cmd+click / F12: go to definition
- Cmd+Option+click / Cmd+F12: go to implementation
- Shift+F12: find references
- Cmd+T: go to workspace symbol
- Ctrl+O: go back after navigation
- Cmd+C / X / V: copy selection / cut selection / paste
- Cmd+A: select all
- Cmd+Z / Cmd+Shift+Z: undo / redo

Neovim is still modal: press i to type; Escape returns to Normal mode.
Press Space and wait in Normal mode to see available commands.
Use :qa to close the window; it protects unsaved changes.

## Multiple terminals

Terminals share the bottom dock and do not appear in the file-tab bar.

- Cmd+Shift+backtick or :ProjectTerminalNew: create another shell
- Cmd+Shift+J or :ProjectTerminals: select a shell
- :ProjectTerminalNext: cycle shells
- Ctrl+backtick: hide/show the selected shell

Switching or hiding terminals keeps their commands running.

## Memory saving

Five minutes after a window loses focus, its enabled language servers shut down.
Refocusing restarts them. Open files and unsaved changes remain in Neovim memory.
This releases language-server memory; it does not hibernate the whole editor to disk.
Terminals, dev servers, and other subprocesses are unaffected.

- :LspSleep — stop servers immediately
- :LspWake — restart servers
- :LspSleepStatus — inspect sleeping and active state
- Timeout: vim.g.idle_lsp_timeout_ms in lua/config/options.lua (milliseconds)

TypeScript uses the native TypeScript 7.0.2 server (Neovim server name: tsc).
The editor-only package is pinned in ~/.local/share/nvim/typescript-native.
Project dependencies are unchanged. vtsls and the tsgo alias are disabled to avoid duplicate servers.
Idle shutdown uses Neovim's built-in LSP lifecycle API rather than the older lsp-timeout plugin.

## Maintenance

:Lazy updates editor plugins; :Mason manages language servers and tools.
Configuration lives in ~/.config/nvim. lazy-lock.json records installed plugin versions.
