#!/usr/bin/env bash

set -e

# brew.sh - Idempotent Homebrew installation and bundle management
#
# Usage:
#   ./brew.sh           # Install Homebrew (if missing) and run brew bundle
#   ./brew.sh --work    # Also install corporate apps from Brewfile.work
#   ./brew.sh --help    # Show this help message

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Determine the dotfiles directory (script is in dotfiles/scripts/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Parse arguments
INSTALL_WORK=false
SHOW_HELP=false

for arg in "$@"; do
  case $arg in
    --work)
      INSTALL_WORK=true
      shift
      ;;
    --help|-h)
      SHOW_HELP=true
      shift
      ;;
    *)
      echo -e "${RED}Unknown argument: $arg${NC}"
      SHOW_HELP=true
      shift
      ;;
  esac
done

# Show help if requested
if [ "$SHOW_HELP" = true ]; then
  cat << EOF
${BLUE}brew.sh${NC} - Idempotent Homebrew installation and bundle management

${YELLOW}USAGE:${NC}
  ./brew.sh           Install Homebrew (if missing) and run brew bundle
  ./brew.sh --work    Also install corporate apps from Brewfile.work
  ./brew.sh --help    Show this help message

${YELLOW}DESCRIPTION:${NC}
  This script detects your Mac architecture (Apple Silicon vs Intel),
  installs Homebrew if it's not already installed, and runs 'brew bundle'
  to install packages from your Brewfile.

  The script is idempotent - safe to run multiple times without breaking.

${YELLOW}OPTIONS:${NC}
  --work    Also install corporate applications from Brewfile.work
  --help    Display this help message

${YELLOW}EXAMPLES:${NC}
  ./brew.sh              # Personal setup only
  ./brew.sh --work       # Personal + corporate setup
EOF
  exit 0
fi

echo -e "${BLUE}=== Homebrew Installation Script ===${NC}"

# Detect architecture
ARCH="$(uname -m)"
echo -e "${YELLOW}Detected architecture:${NC} $ARCH"

# Determine expected Homebrew installation path based on architecture
if [ "$ARCH" = "arm64" ]; then
  EXPECTED_BREW_PATH="/opt/homebrew/bin/brew"
elif [ "$ARCH" = "x86_64" ]; then
  EXPECTED_BREW_PATH="/usr/local/bin/brew"
else
  echo -e "${RED}Unknown architecture: $ARCH${NC}"
  exit 1
fi

# Check if Homebrew is already installed
if command -v brew &> /dev/null; then
  BREW_PATH="$(which brew)"
  echo -e "${GREEN}✓ Homebrew already installed:${NC} $BREW_PATH"
else
  echo -e "${YELLOW}Homebrew not found. Installing...${NC}"
  
  # Install Homebrew using official installer
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Add Homebrew to PATH for this session
  if [ -x "$EXPECTED_BREW_PATH" ]; then
    eval "$($EXPECTED_BREW_PATH shellenv)"
    echo -e "${GREEN}✓ Homebrew installed successfully${NC}"
  else
    echo -e "${RED}✗ Homebrew installation failed${NC}"
    exit 1
  fi
fi

# Verify Homebrew is accessible
if ! command -v brew &> /dev/null; then
  echo -e "${RED}✗ Homebrew is not in PATH after installation${NC}"
  echo -e "${YELLOW}You may need to add Homebrew to your shell profile:${NC}"
  echo -e "  eval \"\$($EXPECTED_BREW_PATH shellenv)\""
  exit 1
fi

# Update Homebrew
echo -e "${YELLOW}Updating Homebrew...${NC}"
brew update

# Install packages from Brewfile
BREWFILE_PATH="${DOTFILES_DIR}/Brewfile"
if [ -f "$BREWFILE_PATH" ]; then
  echo -e "${YELLOW}Installing packages from Brewfile...${NC}"
  brew bundle --file="$BREWFILE_PATH" --no-lock
  echo -e "${GREEN}✓ Brewfile installation complete${NC}"
else
  echo -e "${RED}✗ Brewfile not found at:${NC} $BREWFILE_PATH"
  exit 1
fi

# Install corporate apps if --work flag is set
if [ "$INSTALL_WORK" = true ]; then
  BREWFILE_WORK_PATH="${DOTFILES_DIR}/Brewfile.work"
  if [ -f "$BREWFILE_WORK_PATH" ]; then
    echo -e "${YELLOW}Installing corporate apps from Brewfile.work...${NC}"
    brew bundle --file="$BREWFILE_WORK_PATH" --no-lock
    echo -e "${GREEN}✓ Brewfile.work installation complete${NC}"
  else
    echo -e "${RED}✗ Brewfile.work not found at:${NC} $BREWFILE_WORK_PATH"
    exit 1
  fi
fi

# Cleanup
echo -e "${YELLOW}Cleaning up...${NC}"
brew cleanup

echo -e "${GREEN}=== Homebrew setup complete! ===${NC}"
