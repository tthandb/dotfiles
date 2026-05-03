#!/usr/bin/env bash
# Install plugins for vim/vimrc into ~/.vim/pack/plugins/start/
# and symlink ~/.vimrc to this repo's vimrc.
# Idempotent: existing plugins are git-pulled, missing ones cloned.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VIMRC_SRC="$SCRIPT_DIR/.vimrc"
VIMRC_DST="$HOME/.vimrc"

PACK_DIR="${HOME}/.vim/pack/plugins/start"
mkdir -p "$PACK_DIR"

# symlink ~/.vimrc -> this repo's vimrc
if [ -L "$VIMRC_DST" ] && [ "$(readlink "$VIMRC_DST")" = "$VIMRC_SRC" ]; then
  echo "vimrc   already linked"
else
  if [ -e "$VIMRC_DST" ] || [ -L "$VIMRC_DST" ]; then
    backup="$VIMRC_DST.backup.$(date +%Y%m%d%H%M%S)"
    echo "vimrc   backing up existing $VIMRC_DST -> $backup"
    mv "$VIMRC_DST" "$backup"
  fi
  echo "vimrc   linking $VIMRC_DST -> $VIMRC_SRC"
  ln -s "$VIMRC_SRC" "$VIMRC_DST"
fi

PLUGINS=(
  "tokyonight-vim https://github.com/ghifarit53/tokyonight-vim"
  "vim-airline https://github.com/vim-airline/vim-airline"
  "vim-airline-themes https://github.com/vim-airline/vim-airline-themes"
  "fzf https://github.com/junegunn/fzf"
  "fzf.vim https://github.com/junegunn/fzf.vim"
  "nerdtree https://github.com/preservim/nerdtree"
  "vim-fugitive https://github.com/tpope/vim-fugitive"
  "vim-gitgutter https://github.com/airblade/vim-gitgutter"
  "vim-surround https://github.com/tpope/vim-surround"
  "vim-repeat https://github.com/tpope/vim-repeat"
  "vim-commentary https://github.com/tpope/vim-commentary"
  "auto-pairs https://github.com/jiangmiao/auto-pairs"
  "vim-sneak https://github.com/justinmk/vim-sneak"
  "vim-highlightedyank https://github.com/machakann/vim-highlightedyank"
)

cloned=0
updated=0
for entry in "${PLUGINS[@]}"; do
  name="${entry%% *}"
  url="${entry#* }"
  dst="$PACK_DIR/$name"
  if [ -d "$dst/.git" ]; then
    echo "update  $name"
    git -C "$dst" pull --ff-only --quiet
    updated=$((updated + 1))
  else
    echo "clone   $name"
    git clone --depth=1 --quiet "$url" "$dst"
    cloned=$((cloned + 1))
  fi
done

# fzf binary
if ! command -v fzf >/dev/null 2>&1; then
  echo "install fzf binary..."
  case "$(uname -s)" in
    Darwin)
      if command -v brew >/dev/null 2>&1; then
        brew install fzf
      else
        "$PACK_DIR/fzf/install" --bin --no-update-rc
      fi
      ;;
    Linux)
      "$PACK_DIR/fzf/install" --bin --no-update-rc
      ;;
    *)
      echo "warn: install fzf manually: https://github.com/junegunn/fzf"
      ;;
  esac
fi

# ripgrep + fd (used by :Files / :Rg)
# NOTE: a shell function named `rg` may exist (e.g. from Claude Code) — vim spawns
# commands non-interactively, so we need the real binary on PATH.
for bin in rg fd; do
  if [ ! -x "/opt/homebrew/bin/$bin" ] && [ ! -x "/usr/local/bin/$bin" ] && \
     ! /usr/bin/env -i PATH=/usr/bin:/bin command -v "$bin" >/dev/null 2>&1; then
    echo "install $bin binary..."
    case "$(uname -s)" in
      Darwin)
        command -v brew >/dev/null 2>&1 && brew install "${bin/rg/ripgrep}" \
          || echo "warn: install brew, then 'brew install ripgrep fd'"
        ;;
      Linux)
        echo "warn: install $bin via your package manager (apt/dnf/pacman)"
        ;;
    esac
  fi
done

# generate helptags for all installed plugins
vim -u NONE -c 'helptags ALL' -c quit 2>/dev/null || true

echo "done. cloned=$cloned updated=$updated"
