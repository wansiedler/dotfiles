#!/usr/bin/env bash
# Symlink dotfiles into $HOME. Idempotent. Backs up existing real files.
# Usage: ~/.dotfiles/bootstrap.sh [--quiet]
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QUIET="${1:-}"
log() { [ "$QUIET" = "--quiet" ] || echo "$@"; }

BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

link() {
  local src="$DOTFILES/$1" dst="$HOME/$1"
  [ -e "$src" ] || return 0
  mkdir -p "$(dirname "$dst")"
  # already correct symlink → skip
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then return 0; fi
  # existing real file/dir → back up
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$BACKUP/$(dirname "$1")"
    mv "$dst" "$BACKUP/$1"
    log "backup: $dst -> $BACKUP/$1"
  fi
  ln -s "$src" "$dst"
  log "link:   $dst -> $src"
}

# files to link (relative to $HOME)
link .gitconfig
link .zshenv
link .zshrc
link .claude/CLAUDE.md
link .claude/settings.json
link .claude/hooks/block-git-write.sh

chmod +x "$DOTFILES/.claude/hooks/block-git-write.sh" 2>/dev/null || true
log "done. backups (if any): $BACKUP"
