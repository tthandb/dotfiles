#!/usr/bin/env bash
set -euo pipefail

resolve() {
  local t="$1" l
  while [ -L "$t" ]; do
    l="$(readlink "$t")"
    case "$l" in
      /*) t="$l" ;;
      *)  t="$(dirname "$t")/$l" ;;
    esac
  done
  [ -e "$t" ] || return 1
  printf '%s/%s\n' "$(cd -P "$(dirname "$t")" && pwd -P)" "$(basename "$t")"
}

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
VIMRC_SRC="$SCRIPT_DIR/.vimrc"
VIMRC_DST="$HOME/.vimrc"
PACK_DIR="$HOME/.vim/pack/plugins/start"
UNDO_DIR="$HOME/.vim/undo"

if [ -t 1 ]; then
  B=$'\033[1m'; G=$'\033[32m'; Y=$'\033[33m'; R=$'\033[31m'; N=$'\033[0m'
else
  B=''; G=''; Y=''; R=''; N=''
fi
info() { printf '%s\n' "$*"; }
ok()   { printf '%s+%s %s\n' "$G" "$N" "$*"; }
warn() { printf '%s!%s %s\n' "$Y" "$N" "$*"; }
die()  { printf '%sx%s %s\n' "$R" "$N" "$*" >&2; exit 1; }

command -v git >/dev/null 2>&1 || die "git is required"
[ -f "$VIMRC_SRC" ] || die "cannot find $VIMRC_SRC"

printf '\n%s== environment ==%s\n' "$B" "$N"

if command -v vim >/dev/null 2>&1; then
  VIM_BIN="$(command -v vim)"
  VIM_VER="$(vim --version | head -1 | sed 's/^VIM - Vi IMproved //;s/ .*//')"
  info "vim        $VIM_VER  ($VIM_BIN)"
  case "$VIM_VER" in
    9.*) ;;
    8.2|8.2.*) warn "vim 8.2: 'wildoptions=fuzzy' unavailable" ;;
    *)   warn "vim < 8.2: upgrade recommended" ;;
  esac
else
  die "vim not found"
fi

if vim --version | grep -q '+clipboard'; then
  ok "+clipboard"
elif command -v pbcopy >/dev/null 2>&1; then
  warn "-clipboard: falling back to pbcopy/pbpaste"
else
  warn "-clipboard and no pbcopy"
fi

if command -v ctags >/dev/null 2>&1; then
  if ctags --version 2>/dev/null | grep -qi 'universal\|exuberant'; then
    ok "ctags"
  else
    warn "ctags: BSD build, C/Pascal/Lisp only"
  fi
else
  warn "no ctags: use [I and <leader>*"
fi

vim --version | grep -q '+terminal' && ok "+terminal" || warn "-terminal"

printf '\n%s== vimrc ==%s\n' "$B" "$N"
if [ -L "$VIMRC_DST" ] && [ "$(resolve "$VIMRC_DST" 2>/dev/null)" = "$VIMRC_SRC" ]; then
  ok "already linked"
else
  if [ -L "$VIMRC_DST" ]; then
    info "replacing stale symlink $VIMRC_DST"
    rm -f "$VIMRC_DST"
  elif [ -e "$VIMRC_DST" ]; then
    backup="$VIMRC_DST.backup.$(date +%Y%m%d%H%M%S)"
    n=1
    while [ -e "$backup" ]; do
      backup="$VIMRC_DST.backup.$(date +%Y%m%d%H%M%S).$n"
      n=$((n + 1))
    done
    info "backing up $VIMRC_DST -> $backup"
    mv "$VIMRC_DST" "$backup"
  fi
  ln -s "$VIMRC_SRC" "$VIMRC_DST"
  ok "linked $VIMRC_DST -> $VIMRC_SRC"
fi

mkdir -p "$PACK_DIR"
mkdir -p "$UNDO_DIR" && chmod 700 "$UNDO_DIR"

PLUGINS=(
  "vim-repeat      https://github.com/tpope/vim-repeat"
  "vim-surround    https://github.com/tpope/vim-surround"
  "vim-commentary  https://github.com/tpope/vim-commentary"
  "vim-fugitive    https://github.com/tpope/vim-fugitive"
)

OPTIONAL=(
  "targets.vim         https://github.com/wellle/targets.vim"
  "vim-abolish         https://github.com/tpope/vim-abolish"
  "vim-gitgutter       https://github.com/airblade/vim-gitgutter"
  "vim-sneak           https://github.com/justinmk/vim-sneak"
  "vim-highlightedyank https://github.com/machakann/vim-highlightedyank"
  "vim-eunuch          https://github.com/tpope/vim-eunuch"
  "vim-dispatch        https://github.com/tpope/vim-dispatch"
)

if [ "${VIM_OPTIONAL:-0}" = "1" ]; then
  PLUGINS+=("${OPTIONAL[@]}")
fi

printf '\n%s== plugins ==%s\n' "$B" "$N"
cloned=0; updated=0; failed=0
declare -a WANTED=()

for entry in "${PLUGINS[@]}"; do
  read -r name url <<<"$entry"
  [ -n "$name" ] || continue
  WANTED+=("$name")
  dst="$PACK_DIR/$name"

  if [ -d "$dst/.git" ]; then
    if git -C "$dst" pull --ff-only --quiet 2>/dev/null; then
      updated=$((updated + 1))
    else
      warn "pull failed: $name"
      failed=$((failed + 1))
    fi
  else
    if git clone --depth=1 --quiet "$url" "$dst" 2>/dev/null; then
      ok "cloned $name"
      cloned=$((cloned + 1))
    else
      warn "clone failed: $name"
      failed=$((failed + 1))
    fi
  fi
done

if [ "${VIM_NO_PRUNE:-0}" != "1" ]; then
  pruned=0
  for dir in "$PACK_DIR"/*/; do
    [ -d "$dir" ] || continue
    name="$(basename "$dir")"
    keep=0
    for w in "${WANTED[@]}"; do [ "$w" = "$name" ] && keep=1 && break; done
    if [ "$keep" -eq 0 ] && [ "${VIM_OPTIONAL:-0}" != "1" ]; then
      for o in "${OPTIONAL[@]}"; do
        read -r oname _ <<<"$o"
        [ "$oname" = "$name" ] && keep=1 && break
      done
    fi
    if [ "$keep" -eq 0 ]; then
      info "pruning $name"
      rm -rf "$dir"
      pruned=$((pruned + 1))
    fi
  done
  [ "$pruned" -gt 0 ] && ok "pruned $pruned"
fi

for dir in "$PACK_DIR"/*/doc; do
  [ -d "$dir" ] || continue
  vim -u NONE -es -c "helptags $dir" -c quit >/dev/null 2>&1 || true
done

printf '\n%s== done ==%s  cloned=%s updated=%s failed=%s\n\n' \
  "$B" "$N" "$cloned" "$updated" "$failed"
