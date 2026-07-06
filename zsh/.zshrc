typeset -U path PATH

path_prepend() {
  local dir
  for dir in "$@"; do
    [[ -d "$dir" ]] && path=("$dir" "${path[@]}")
  done
  return 0
}

path_prepend \
  "$HOME/dev/Odin" \
  "${KREW_ROOT:-$HOME/.krew}/bin" \
  "$HOME/go/bin" \
  "$HOME/.local/bin" \
  "$HOME/.deno/bin"

export EDITOR="nvim"
export ZSH="$HOME/.oh-my-zsh"
export NVM_DIR="$HOME/.nvm"

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  plugins=(git)
  source "$ZSH/oh-my-zsh.sh"
fi

if command -v brew >/dev/null 2>&1; then
  nvm_prefix="$(brew --prefix nvm 2>/dev/null)"
  if [[ -n "$nvm_prefix" ]]; then
    [[ -s "$nvm_prefix/nvm.sh" ]] && . "$nvm_prefix/nvm.sh"
    [[ -s "$nvm_prefix/etc/bash_completion.d/nvm" ]] && . "$nvm_prefix/etc/bash_completion.d/nvm"
  fi
  unset nvm_prefix
fi

if command -v sheldon >/dev/null 2>&1; then
  eval "$(sheldon source)"
fi

if ! (( $+functions[compdef] )); then
  autoload -Uz compinit
  compinit
fi

if command -v jj >/dev/null 2>&1; then
  source <(jj util completion zsh)
fi

command -v nvim >/dev/null 2>&1 && alias vim='nvim'
alias siz='source ~/.zshrc'
alias viz='vim ~/.zshrc'
command -v eza >/dev/null 2>&1 && alias ls='eza --icons'
command -v eza >/dev/null 2>&1 && alias ll='eza -l --icons --git'
command -v bat >/dev/null 2>&1 && alias cat='bat'
command -v rg >/dev/null 2>&1 && alias grep='rg'
command -v pnpm >/dev/null 2>&1 && alias npm='pnpm'

alias 'jj b'='jj bookmark'
alias 'jj b l'='jj bookmark list'
alias 'jj b c'='jj bookmark create'
alias 'jj b t'='jj bookmark track'
alias 'jj n'='jj new'

alias 'gsm'='git switch main'
alias 'gp'='git pull'
alias 'gpp'='git push'
alias 'gca'='git commit --amend'
alias 'grm'='git rebase -i origin/main'

if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh)"
fi

# eval "$(zoxide init zsh)"

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

export PNPM_HOME="${PNPM_HOME:-$HOME/Library/pnpm}"
path_prepend "$PNPM_HOME"
