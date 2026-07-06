#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUN_STOW=false

usage() {
  cat <<EOF
Usage: ${0##*/} [--stow]

Installs the macOS/Homebrew dependencies used by the zsh stow package.

Options:
  --stow    Run stow for the zsh and starship packages after installing deps.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --stow) RUN_STOW=true ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
done

log() {
  printf '\n==> %s\n' "$*"
}

have() {
  command -v "$1" >/dev/null 2>&1
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This installer is written for macOS/Homebrew." >&2
  exit 1
fi

if ! have brew; then
  log "Installing Homebrew"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

brew_formulae=(
  atuin
  bat
  btop
  deno
  eza
  git
  go
  jira-cli
  jj
  krew
  kubernetes-cli
  neovim
  nvm
  odin
  pnpm
  ripgrep
  sheldon
  starship
  stow
  zoxide
  zsh
)

brew_casks=(
  font-iosevka-term-nerd-font
)

log "Installing Homebrew formulae"
brew install "${brew_formulae[@]}"

log "Installing Homebrew casks"
brew install --cask "${brew_casks[@]}"

mkdir -p "$HOME/.nvm" "$HOME/.config" "$HOME/.local/bin"

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  log "Installing Oh My Zsh"
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
else
  log "Oh My Zsh already exists"
fi

if ! have cargo; then
  log "Installing Rust toolchain with rustup"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

if [[ "$RUN_STOW" == true ]]; then
  log "Stowing zsh and starship packages"
  stow -d "$DOTFILES_DIR" -t "$HOME" zsh starship

  if have sheldon; then
    log "Preparing Sheldon plugins"
    sheldon lock --update
  fi
fi

cat <<EOF

Done.

Next steps:
  1. If you did not pass --stow, run:
     stow -d "$DOTFILES_DIR" -t "$HOME" zsh starship
  2. Start a new zsh login shell.
  3. Configure Jira with 'jira init' and add your Jira token to Keychain if you use jira-new.
EOF
