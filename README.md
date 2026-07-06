# Dotfiles

This repo is organized for GNU Stow. Each top-level directory is a stow
package whose contents are linked relative to `$HOME`.

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

On a new macOS machine:

```sh
./scripts/install-zsh-deps.sh --stow
```

If the target machine already has real files at `~/.zshrc`, `~/.zshenv`,
`~/.zprofile`, or `~/.config/sheldon/plugins.toml`, move those aside before
running stow.

To stow manually:

```sh
stow -d "$PWD" -t "$HOME" zsh starship
```
