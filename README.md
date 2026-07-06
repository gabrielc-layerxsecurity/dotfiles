# Dotfiles

This repo is organized for GNU Stow. Each top-level directory is a stow
package whose contents are linked relative to `$HOME`.

## Bootstrap

On a new macOS machine:

```sh
./scripts/bootstrap-macos.sh --stow
```

The script installs Homebrew if needed, runs `brew bundle` against
`Brewfile`, installs non-Brew user tools, and optionally stows all config
packages:

- `aerospace`
- `nvim`
- `starship`
- `wezterm`
- `zsh`

Current package inventory covered by the repo:

- Homebrew: 191 installed formulae total on this machine, represented by the
  requested formulae, taps, casks, Go package, Krew plugin, and npm package in
  `Brewfile`.
- Casks: `aerospace`, `codex`, `dbeaver-community`, `localsend`, `maccy`,
  `mitmproxy`, `wezterm@nightly`, plus `font-iosevka-term-nerd-font` for the
  prompt and terminal icons.
- Cargo tools: `cargo-about`, `cargo-deny`, `cargo-nextest`, and `uv`.
- Krew plugins: `neat`. Krew itself is installed with Homebrew.
- Go tools: `github.com/google/pprof`.

Machine-local state that is intentionally not managed:

- shell history, completion dumps, and sessions
- credentials and app login state
- `.nvm` Node versions
- `.cargo`, `.deno`, `.krew`, and package-manager caches
- local source checkouts such as `~/dev/Odin`
- the local Servo checkout that provided the Cargo `crown` binary

If Homebrew reports that `/opt/homebrew/Cellar` or
`~/Library/Caches/Homebrew` is not writable, fix ownership before running the
bootstrap:

```sh
sudo chown -R "$USER" /opt/homebrew/Cellar "$HOME/Library/Caches/Homebrew"
```

## Zsh

The live zsh setup maps to these managed files:

- `zsh/.zshrc`
- `zsh/.zshenv`
- `zsh/.zprofile`
- `zsh/.config/sheldon/plugins.toml`
- `starship/.config/starship.toml`

Do not stow generated or machine-local zsh state:

- `.oh-my-zsh`
- `.nvm`
- `.cargo`
- `.deno`
- `.krew`
- `.zcompdump*`
- `.zsh_history`
- `.zsh_sessions`

If the target machine already has real files at `~/.zshrc`, `~/.zshenv`,
`~/.zprofile`, or `~/.config/sheldon/plugins.toml`, move those aside before
running stow.

To stow only the shell packages manually:

```sh
stow -d "$PWD" -t "$HOME" zsh starship
```
