# ~/.zshrc — interactive zsh.

# --- self-update dotfiles (throttled: once / 24h) ---
_dot_autopull() {
	local d="${DOTFILES:-$HOME/.dotfiles}" stamp
	[ -d "$d/.git" ] || return
	stamp="$d/.git/.last_autopull"
	if [ -z "$(find "$stamp" -mtime -1 2>/dev/null)" ]; then
		( git -C "$d" pull --quiet --ff-only 2>/dev/null && "$d/bootstrap.sh" --quiet ) &!
		touch "$stamp"
	fi
}
_dot_autopull

# --- prompt / basics ---
setopt PROMPT_SUBST
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
PROMPT='%F{cyan}%n@%m%f %F{yellow}%~%f%F{green}${vcs_info_msg_0_}%f
→ '

# history
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_DUPS

# completion
autoload -Uz compinit && compinit -u

# ansible tab completion (argcomplete)
if command -v register-python-argcomplete &>/dev/null; then
	autoload -Uz bashcompinit && bashcompinit
	eval "$(register-python-argcomplete ansible)"
	eval "$(register-python-argcomplete ansible-playbook)"
	eval "$(register-python-argcomplete ansible-galaxy)"
	eval "$(register-python-argcomplete ansible-vault)"
	eval "$(register-python-argcomplete ansible-doc)"
fi

. "$HOME/.local/bin/env"



export PATH="$HOME/go/bin:$PATH"

[ -f "$HOME/runner-host/runner-aliases.sh" ] && . "$HOME/runner-host/runner-aliases.sh"
