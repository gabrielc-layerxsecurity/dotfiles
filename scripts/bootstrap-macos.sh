#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BREWFILE="$DOTFILES_DIR/Brewfile"
RUN_STOW=false
SKIP_BREW=false
SKIP_EXTRA_TOOLS=false
STOW_PACKAGES=(aerospace nvim starship wezterm zsh)

usage() {
  cat <<EOF
Usage: ${0##*/} [--stow] [--skip-brew] [--skip-extra-tools]

Bootstraps this macOS workstation from the dotfiles repo.

Options:
  --stow              Stow all dotfile packages after installing dependencies.
  --skip-brew         Skip Homebrew and Brewfile installation.
  --skip-extra-tools  Skip Rust/Cargo, Krew, uv, Go, and Oh My Zsh extras.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --stow) RUN_STOW=true ;;
    --skip-brew) SKIP_BREW=true ;;
    --skip-extra-tools) SKIP_EXTRA_TOOLS=true ;;
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

warn() {
  printf 'warning: %s\n' "$*" >&2
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This installer is written for macOS/Homebrew." >&2
  exit 1
fi

setup_homebrew() {
  if ! have brew; then
    log "Installing Homebrew"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  local cellar cache
  cellar="$(brew --cellar)"
  cache="${HOMEBREW_CACHE:-$HOME/Library/Caches/Homebrew}"

  if [[ -d "$cellar" && ! -w "$cellar" ]]; then
    warn "$cellar is not writable. Fix with: sudo chown -R \"$USER\" \"$cellar\""
  fi
  if [[ -d "$cache" && ! -w "$cache" ]]; then
    warn "$cache is not writable. Fix with: sudo chown -R \"$USER\" \"$cache\""
  fi

  log "Installing Homebrew packages from Brewfile"
  brew bundle --file "$BREWFILE"
}

install_oh_my_zsh() {
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    log "Installing Oh My Zsh"
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
  else
    log "Oh My Zsh already exists"
  fi
}

install_rust() {
  if ! have cargo; then
    log "Installing Rust toolchain with rustup"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # shellcheck source=/dev/null
    [[ -r "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
  fi

  local cargo_tools=(
    cargo-about
    cargo-deny
    cargo-nextest
    uv
  )

  local tool
  for tool in "${cargo_tools[@]}"; do
    log "Ensuring Cargo tool: $tool"
    cargo install "$tool"
  done
}

install_krew_plugins() {
  if ! kubectl krew version >/dev/null 2>&1; then
    warn "kubectl krew is not available; skipping Krew plugins"
    return
  fi

  if ! kubectl krew list | grep -qx "neat"; then
    log "Installing Krew plugin: neat"
    kubectl krew install neat
  fi
}

install_go_tools() {
  if have go && ! have pprof; then
    log "Installing Go tool: github.com/google/pprof"
    go install github.com/google/pprof@latest
  fi
}

install_extra_tools() {
  mkdir -p "$HOME/.nvm" "$HOME/.config" "$HOME/.local/bin"
  export PATH="$HOME/.cargo/bin:$HOME/go/bin:$HOME/.local/bin:${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

  install_oh_my_zsh
  install_rust
  install_krew_plugins
  install_go_tools

  if have sheldon; then
    log "Preparing Sheldon plugins"
    sheldon lock --update
  fi
}

if [[ "$SKIP_BREW" == false ]]; then
  setup_homebrew
fi

if [[ "$SKIP_EXTRA_TOOLS" == false ]]; then
  install_extra_tools
fi

if [[ "$RUN_STOW" == true ]]; then
  log "Stowing dotfile packages"
  stow -d "$DOTFILES_DIR" -t "$HOME" "${STOW_PACKAGES[@]}"
fi

cat <<EOF

Done.

Next steps:
  1. If you did not pass --stow, run:
     stow -d "$DOTFILES_DIR" -t "$HOME" ${STOW_PACKAGES[*]}
  2. Start a new zsh login shell.
  3. Configure app/account state that is not safe to put in dotfiles:
     - jira init, plus your Jira token in Keychain if you use jira-new
     - cloud/kube/docker credentials
     - local source checkouts such as ~/dev/Odin and Servo's crown tool
EOF
