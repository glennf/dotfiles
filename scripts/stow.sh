#!/usr/bin/env bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
STOW_DIR="${DOTFILES_DIR}/stow"
BACKUP_DIR="$HOME/.dotfiles-backup"

echo -e "${GREEN}=== GNU Stow Dotfiles Installer ===${NC}"
echo "Dotfiles directory: ${DOTFILES_DIR}"
echo "Stow directory: ${STOW_DIR}"
echo ""

if ! command -v stow &> /dev/null; then
    echo -e "${YELLOW}GNU Stow not found. Installing via Homebrew...${NC}"
    if ! command -v brew &> /dev/null; then
        echo -e "${RED}Error: Homebrew not installed. Please install Homebrew first.${NC}"
        exit 1
    fi
    brew install stow
    echo -e "${GREEN}GNU Stow installed successfully.${NC}"
else
    echo -e "${GREEN}GNU Stow is already installed.${NC}"
fi

echo ""

echo -e "${YELLOW}Creating backup directory: ${BACKUP_DIR}${NC}"
mkdir -p "${BACKUP_DIR}"

PACKAGES=("zsh" "p10k" "git" "zprofile")
DOTFILES=(
    ".zshrc:zsh"
    ".p10k.zsh:p10k"
    ".gitconfig:git"
    ".zprofile:zprofile"
)

echo -e "${YELLOW}Backing up existing dotfiles...${NC}"
for entry in "${DOTFILES[@]}"; do
    IFS=':' read -r file package <<< "$entry"
    
    if [ -f "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
        echo "  Backing up $file (regular file)"
        mv "$HOME/$file" "${BACKUP_DIR}/$file.$(date +%Y%m%d-%H%M%S)"
    elif [ -L "$HOME/$file" ]; then
        echo "  Skipping $file (already a symlink)"
    else
        echo "  Skipping $file (does not exist)"
    fi
done

echo ""
echo -e "${GREEN}Running GNU Stow...${NC}"

cd "${DOTFILES_DIR}"

for package in "${PACKAGES[@]}"; do
    if [ -d "${STOW_DIR}/${package}" ]; then
        echo "  Stowing ${package}..."
        stow -v -d "${STOW_DIR}" -t "$HOME" "${package}"
    else
        echo -e "${YELLOW}  Warning: Package ${package} not found in ${STOW_DIR}${NC}"
    fi
done

echo ""
echo -e "${GREEN}=== Dotfiles stowed successfully! ===${NC}"
echo -e "Backups are located in: ${BACKUP_DIR}"
echo ""
echo "Symlinks created:"
for entry in "${DOTFILES[@]}"; do
    IFS=':' read -r file package <<< "$entry"
    if [ -L "$HOME/$file" ]; then
        target=$(readlink "$HOME/$file")
        echo "  $HOME/$file -> $target"
    fi
done
