# Draft: Mac Setup Scripts Cleanup & Creation

## Requirements (confirmed)

- **Audit current system**: YES - capture all Homebrew, npm global, pip/pipx packages
- **Dotfile deployment**: GNU Stow
- **Script organization**: Modular scripts (brew.sh, macos.sh, dotfiles.sh, etc.) with main bootstrap.sh
- **Idempotency**: YES - safe to run multiple times
- **Capture missing dotfiles**: YES - .p10k.zsh, .gitconfig, .zprofile
- **macOS defaults**: YES - comprehensive (Finder, Dock, Trackpad, Keyboard, etc.)
- **App Store apps**: YES - use mas-cli to track and install

## Critical Decisions (from Metis Review)

- **Repo structure**: FLATTEN - move contents from dotfiles/dotfiles/ up to dotfiles/, preserve git history
- **Package curation**: CURATED with categories (essentials, development, productivity, optional)
- **Work apps**: SEPARATE Brewfile.work for corporate apps (Citrix, Webex, Zoom, etc.)
- **File conflicts**: BACKUP existing files to ~/.dotfiles-backup/ before symlinking
- **P10k theme**: AUTO-INSTALL - bootstrap clones p10k into oh-my-zsh custom themes
- **Version managers**: MISE ONLY - replace sdkman with mise for all languages (Java, Node, Python, Ruby)

## Current Repo State

### Files Present
- `/Users/glenn/projects/dotfiles/dotfiles/setup.sh` - existing setup script (needs refactoring)
- `/Users/glenn/projects/dotfiles/dotfiles/.zshrc` - shell config
- `/Users/glenn/projects/dotfiles/dotfiles/readme.md` - brief notes

### Files Missing (to capture)
- `~/.p10k.zsh` - powerlevel10k prompt config (referenced in .zshrc)
- `~/.gitconfig` - git configuration
- `~/.zprofile` - shell profile (brew shellenv likely here)
- No Brewfile (need to generate)
- No npm package list
- No pipx/pip list

## Technical Decisions

- Use GNU Stow for symlinking (run from dotfiles/stow directory)
- Modular script structure:
  ```
  dotfiles/
  ├── bootstrap.sh          # Main entry point
  ├── scripts/
  │   ├── brew.sh           # Homebrew + packages
  │   ├── macos.sh          # macOS defaults
  │   ├── apps.sh           # App-specific setup (oh-my-zsh, sdkman, etc.)
  │   └── stow.sh           # Symlink deployment
  ├── Brewfile              # Homebrew manifest
  ├── Brewfile.mas          # Mac App Store apps (or combined)
  ├── stow/                 # Stow packages
  │   ├── zsh/
  │   │   └── .zshrc
  │   ├── git/
  │   │   └── .gitconfig
  │   ├── p10k/
  │   │   └── .p10k.zsh
  │   └── ...
  └── README.md             # Updated documentation
  ```

## Open Questions

None - all major decisions captured.

## Scope Boundaries

### INCLUDE
- Audit current system packages (brew, npm -g, pipx, pip, mas)
- Generate Brewfile from current system
- Capture missing dotfiles (.p10k.zsh, .gitconfig, .zprofile)
- Reorganize repo structure for GNU Stow
- Create modular, idempotent setup scripts
- Add comprehensive macOS defaults
- Document the setup process

### EXCLUDE
- Capturing application-specific configs (VSCode settings, JetBrains, etc.) - can be added later
- Secrets/credentials - should never be in repo
- Project-specific configs

## Next Steps

1. Consult Metis for gap analysis
2. Generate work plan to `.sisyphus/plans/mac-setup-scripts.md`
