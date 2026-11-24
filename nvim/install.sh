#!/usr/bin/env bash
# Bootstrap this nvim config on a new machine.
#
# Usage:
#   git clone <your-dotfiles-repo> ~/.config/nvim
#   ~/.config/nvim/install.sh
#
# What it does:
#   1. Sanity-checks that nvim, git and curl are available
#   2. Installs lazy.nvim plugins headlessly (:Lazy! sync)
#   3. Tree-sitter parsers and the tree-sitter CLI install themselves
#      automatically on first launch (see lua/plugins/nvim-treesitter.lua);
#      this script triggers that headlessly so even the first interactive
#      start is clean.
set -euo pipefail

echo "==> Checking prerequisites"
missing=0
for cmd in nvim git curl; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "    MISSING: $cmd"
        missing=1
    else
        echo "    found:   $cmd ($(command -v "$cmd"))"
    fi
done

if [ "$missing" -ne 0 ]; then
    cat <<'EOF'

Install the missing tools first. This config needs nvim >= 0.12, which
distro apt repos usually don't ship yet, so use one of:
  Any Linux     : download the tarball/appimage from
                  https://github.com/neovim/neovim/releases
                  (e.g. nvim-linux-arm64.tar.gz -> /opt or ~/.local)
  bob           : version manager, `bob install stable && bob use stable`
  macOS         : brew install neovim
  Ubuntu/Debian : apt is fine for git/curl; nvim from apt is likely too old
EOF
    exit 1
fi

echo "==> Syncing plugins (lazy.nvim)"
nvim --headless '+Lazy! sync' '+qall!' || true

echo "==> Installing tree-sitter CLI + parsers (first-launch bootstrap)"
# The config auto-downloads the tree-sitter CLI and kicks off parser
# installs asynchronously; give it time to finish, then verify.
nvim --headless \
    '+lua vim.defer_fn(function() vim.cmd("qall!") end, 120000)' \
    '+lua if vim.fn.exepath("tree-sitter") ~= "" then vim.cmd("qall!") end' || true

echo
echo "Done. If any parsers were still compiling, just open nvim once more —"
echo "installation continues automatically."
