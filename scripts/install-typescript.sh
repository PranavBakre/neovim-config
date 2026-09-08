#!/usr/bin/env bash
set -euo pipefail

command -v nvim >/dev/null || { echo 'Install Neovim first.' >&2; exit 1; }
command -v npm >/dev/null || { echo 'Install Node.js and npm first.' >&2; exit 1; }

nvim_data_dir="$(nvim --clean --headless '+lua io.write(vim.fn.stdpath("data"))' +qa)"
npm install --prefix "$nvim_data_dir/typescript-native" --save-exact typescript@7.0.2
"$nvim_data_dir/typescript-native/node_modules/.bin/tsc" --version
