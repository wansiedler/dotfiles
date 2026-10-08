# dotfiles

Single source of truth for shell + Claude Code + git, on every SSH host.
Why: macOS web "Instructions for Claude" and `ssh SendEnv GIT_*` do NOT reach
remote Claude Code CLI / tool processes. Files on the host do.

## Contents
- `.gitconfig`      — git identity (wansiedler), settings, aliases, gh credential helper
- `.zshenv/.zshrc`  — zsh env + interactive (prompt, history, throttled auto-pull)
- `.claude/CLAUDE.md`      — global Claude instructions (caveman, no-commit, identity)
- `.claude/settings.json`  — hooks (blocks git commit/push, gh pr create)
- `.claude/hooks/block-git-write.sh` — the enforcement hook

## New host
```sh
git clone git@github.com:wansiedler/dotfiles.git ~/.dotfiles
~/.dotfiles/bootstrap.sh        # symlinks into $HOME, backs up existing
gh auth login                   # per-host GitHub auth (no PAT in repo)
```

## Auto-update
`.zshrc` pulls + re-bootstraps once / 24h. Manual: `git -C ~/.dotfiles pull && ~/.dotfiles/bootstrap.sh`.

## Secrets
Never in this repo. PAT via `gh auth` or untracked `~/.netrc` (chmod 600).
