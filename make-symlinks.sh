#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
OLDDIR="$HOME/dotfiles_old"
FILES=(.zshrc .gitconfig .p10k.zsh .ideavimrc .tmux.conf .config)

if [ -t 1 ]; then
  G=$'\033[32m'; Y=$'\033[33m'; N=$'\033[0m'
else
  G=''; Y=''; N=''
fi
ok()   { printf '%s+%s %s\n' "$G" "$N" "$*"; }
warn() { printf '%s!%s %s\n' "$Y" "$N" "$*"; }

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

mkdir -p "$OLDDIR"

for file in "${FILES[@]}"; do
  src="$DIR/$file"
  dst="$HOME/$file"

  if [ ! -e "$src" ]; then
    warn "skip $file (not in repo)"
    continue
  fi

  if [ -L "$dst" ] && [ "$(resolve "$dst" 2>/dev/null)" = "$src" ]; then
    ok "$file already linked"
    continue
  fi

  if [ -L "$dst" ]; then
    rm -f "$dst"
  elif [ -e "$dst" ]; then
    backup="$OLDDIR/$file"
    n=1
    while [ -e "$backup" ]; do
      backup="$OLDDIR/$file.$n"
      n=$((n + 1))
    done
    mv "$dst" "$backup"
    warn "$file backed up to ${backup#"$HOME"/}"
  fi

  ln -s "$src" "$dst"
  ok "$file linked"
done

printf '\nNext: bash %s/.config/vim/install.sh\n' "${DIR#"$HOME"/}"
