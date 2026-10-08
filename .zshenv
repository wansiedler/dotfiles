# ~/.zshenv — read by every zsh (login, interactive, scripts). Env only.

# Editor / locale
export EDITOR="${EDITOR:-vim}"
export LANG="${LANG:-en_US.UTF-8}"

# Git identity also in env (belt + suspenders; ~/.gitconfig is primary).
export GIT_AUTHOR_NAME="wansiedler"
export GIT_AUTHOR_EMAIL="apwansiedler@gmail.com"
export GIT_COMMITTER_NAME="wansiedler"
export GIT_COMMITTER_EMAIL="apwansiedler@gmail.com"

# Dotfiles location
export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

# builds go through the capped "ci" buildx builder (runner-host/harden-ci-slice.sh)
export BUILDX_BUILDER=ci
