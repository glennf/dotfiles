# macOS Dotfiles & Setup System

A comprehensive, modular, and idempotent system to bootstrap a brand new Mac into a fully configured development environment. This setup uses **Homebrew** for package management, **GNU Stow** for dotfile symlinking, and **zsh** with **Powerlevel10k** for a modern terminal experience.

## 🚀 Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/dotfiles.git ~/projects/dotfiles
   cd ~/projects/dotfiles
   ```

2. **Run the bootstrap script:**
   ```bash
   ./bootstrap.sh
   ```

3. **Restart your Mac** to ensure all system defaults (like keyboard repeat rates) take effect.

---

## 📋 Prerequisites

Before running the setup, ensure you have the following:

- **Xcode Command Line Tools**: Run `xcode-select --install` in your terminal.
- **Git**: Often installed with Xcode CLI tools, but required to clone this repo.
- **Apple ID**: Ensure you are signed into the Mac App Store (required if you plan to use `mas` for App Store apps).
- **Admin Rights**: The script will prompt for your password when installing Homebrew or changing system settings.

---

## 📦 What Gets Installed

### 1. Homebrew Packages ([Brewfile](./Brewfile))
- **Essentials**: `git`, `zsh`, `powerlevel10k`, `tmux`, `neovim`, `gh` (GitHub CLI).
- **Languages & Runtimes**: Python (3.11/3.12), Go, Node.js (via `fnm` and `nvm`), `uv`.
- **Infrastructure**: Docker (via Colima), Supabase CLI, Railway CLI, Fly.io CLI.
- **Utilities**: `ffmpeg`, `imagemagick`, `watchman`, `nmap`, `zoxide`.
- **GUI Apps**: iTerm2, VSCode, Cursor, Google Chrome, Arc, Zen, Slack, Discord, 1Password, Obsidian, and more.
- **Fonts**: Monaspace and Monaspice Nerd Font.
- **VSCode Extensions**: A curated list of extensions for Python, dbt, Docker, and GitHub Copilot.

### 2. Shell Environment
- **Oh My Zsh**: Managed configuration framework for zsh.
- **Powerlevel10k**: A highly customizable and fast zsh theme.
- **Mise**: Polyglot tool version manager (successor to asdf).
- **Zoxide**: A smarter `cd` command.

### 3. macOS System Defaults
Optimizes macOS for development, including:
- Disabling boot sound and auto-correct.
- Enabling key repeat (no press-and-hold).
- Showing all file extensions and hidden files in Finder.
- Configuring Dock (size, autohide, speed).
- Setting up screenshot locations and formats.

---

## 🛠 Usage

The `bootstrap.sh` script is the main orchestrator. It runs the modular scripts in `scripts/` in the correct order.

### Command Line Flags

| Flag | Description |
| :--- | :--- |
| `--work` | Include corporate apps (Zoom, etc.) from `Brewfile.work` |
| `--no-brew` | Skip Homebrew installation and package bundling |
| `--no-macos` | Skip configuring macOS system defaults |
| `--no-apps` | Skip installation of Oh My Zsh, mise, and zoxide |
| `--no-stow` | Skip symlinking dotfiles with GNU Stow |
| `--dry-run` | Preview what would happen without making changes |
| `--help` | Show usage information and examples |

### Examples

```bash
# Full personal setup
./bootstrap.sh

# Setup for a work machine (includes corporate apps)
./bootstrap.sh --work

# Only link dotfiles (skipping all installations)
./bootstrap.sh --no-brew --no-macos --no-apps

# Preview changes before executing
./bootstrap.sh --dry-run
```

---

## 📂 Directory Structure

```text
dotfiles/
├── bootstrap.sh       # Main entry point and orchestrator
├── Brewfile           # Main Homebrew dependency list (Personal)
├── Brewfile.work      # Corporate-specific Homebrew apps
├── Brewfile.mas       # Mac App Store apps (via mas CLI)
├── scripts/           # Modular setup scripts
│   ├── brew.sh        # Homebrew installer and bundler
│   ├── macos.sh       # macOS system defaults configuration
│   ├── apps.sh        # Shell tools (OMZ, mise, zoxide)
│   └── stow.sh        # GNU Stow symlinking logic
└── stow/              # Dotfile packages (organized by app)
    ├── git/           # .gitconfig
    ├── p10k/          # .p10k.zsh
    ├── zprofile/      # .zprofile
    └── zsh/           # .zshrc
```

---

## 🔧 Customization

### Adding Homebrew Packages
1. Open `Brewfile`.
2. Add your package: `brew "package_name"` for CLI or `cask "app_name"` for GUI.
3. Run `./bootstrap.sh` to install.

### Modifying macOS Defaults
All system settings are located in [scripts/macos.sh](./scripts/macos.sh). You can comment out or add new `defaults write` commands there.

### Adding New Dotfiles (Stow Guide)
If you want to manage a new config file (e.g., `.tmux.conf`):

1. Create a new directory in `stow/`: `mkdir -p stow/tmux`
2. Move your config file there: `mv ~/.tmux.conf stow/tmux/`
3. Add "tmux" to the `PACKAGES` array in [scripts/stow.sh](./scripts/stow.sh).
4. Run `./bootstrap.sh --no-brew --no-macos --no-apps` to link it.

---

## ❓ Troubleshooting

**Permission Denied**
- Do **not** run the scripts with `sudo`. The scripts will prompt for your password specifically when root privileges are required.

**Stow Conflicts**
- If a file already exists in your home directory, `stow` might fail. [scripts/stow.sh](./scripts/stow.sh) attempts to back up existing files to `~/.dotfiles-backup`, but if conflicts persist, manually move the offending file out of the way.

**Homebrew PATH**
- If `brew` is not found after installation, the script attempts to add it to your path. You may need to restart your terminal or run `eval "$(/opt/homebrew/bin/brew shellenv)"`.

**Settings Not Applying**
- Some macOS defaults require a logout or restart to take effect. If something doesn't look right, try a reboot.

---

## 🤝 Contributing
Feel free to fork this repo and customize it for your own workflow. If you find a bug in the modular scripts, PRs are welcome!
