#!/usr/bin/env bash

#
# bootstrap.sh - Main orchestrator for dotfiles setup
# Coordinates brew.sh → macos.sh → apps.sh → stow.sh in correct order
#

set -e

#==============================================================================
# Color Definitions
#==============================================================================

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

#==============================================================================
# Configuration Variables
#==============================================================================

# Determine dotfiles directory (script location)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
readonly DOTFILES_DIR="$SCRIPT_DIR"
readonly SCRIPTS_DIR="${DOTFILES_DIR}/scripts"

# Script flags (default: run all)
RUN_BREW=true
RUN_MACOS=true
RUN_APPS=true
RUN_STOW=true
WORK_MODE=false
DRY_RUN=false

#==============================================================================
# Helper Functions
#==============================================================================

print_header() {
  echo -e "\n${BLUE}==>${NC} ${1}"
}

print_success() {
  echo -e "${GREEN}✓${NC} ${1}"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} ${1}"
}

print_error() {
  echo -e "${RED}✗${NC} ${1}" >&2
}

show_help() {
  cat << EOF
Usage: ./bootstrap.sh [OPTIONS]

Main orchestrator script for macOS dotfiles setup.
Runs scripts in order: brew.sh → macos.sh → apps.sh → stow.sh

OPTIONS:
  --no-brew       Skip Homebrew installation (brew.sh)
  --no-macos      Skip macOS defaults configuration (macos.sh)
  --no-apps       Skip application installations (apps.sh)
  --no-stow       Skip GNU Stow dotfile linking (stow.sh)
  --work          Install corporate apps from Brewfile.work
  --dry-run       Show what would be executed without running
  --help          Show this help message

EXAMPLES:
  ./bootstrap.sh                    # Full setup (personal)
  ./bootstrap.sh --work             # Full setup (with corporate apps)
  ./bootstrap.sh --no-macos         # Skip macOS defaults
  ./bootstrap.sh --dry-run          # Preview without executing
  ./bootstrap.sh --no-brew --work   # Skip Homebrew, include work apps

SCRIPT EXECUTION ORDER:
  1. brew.sh      - Install Homebrew + packages
  2. macos.sh     - Configure macOS defaults
  3. apps.sh      - Install oh-my-zsh, mise, zoxide
  4. stow.sh      - Symlink dotfiles to home directory

EOF
}

verify_not_root() {
  if [ "$EUID" -eq 0 ] || [ "$UID" -eq 0 ]; then
    print_error "Do not run this script as root or with sudo"
    print_error "The scripts will request sudo when needed"
    exit 1
  fi
}

verify_scripts_exist() {
  local missing=false
  
  if [ "$RUN_BREW" = true ] && [ ! -f "${SCRIPTS_DIR}/brew.sh" ]; then
    print_error "Missing: scripts/brew.sh"
    missing=true
  fi
  
  if [ "$RUN_MACOS" = true ] && [ ! -f "${SCRIPTS_DIR}/macos.sh" ]; then
    print_error "Missing: scripts/macos.sh"
    missing=true
  fi
  
  if [ "$RUN_APPS" = true ] && [ ! -f "${SCRIPTS_DIR}/apps.sh" ]; then
    print_error "Missing: scripts/apps.sh"
    missing=true
  fi
  
  if [ "$RUN_STOW" = true ] && [ ! -f "${SCRIPTS_DIR}/stow.sh" ]; then
    print_error "Missing: scripts/stow.sh"
    missing=true
  fi
  
  if [ "$missing" = true ]; then
    print_error "Cannot proceed with missing scripts"
    exit 1
  fi
}

run_script() {
  local script="$1"
  local args="${2:-}"
  
  if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}[DRY RUN]${NC} Would execute: ${script} ${args}"
    return 0
  fi
  
  if ! bash "${script}" "${args}"; then
    print_error "Script failed: ${script}"
    print_error "Fix the error and re-run bootstrap.sh"
    exit 1
  fi
}

#==============================================================================
# Argument Parsing
#==============================================================================

while [[ $# -gt 0 ]]; do
  case $1 in
    --no-brew)
      RUN_BREW=false
      shift
      ;;
    --no-macos)
      RUN_MACOS=false
      shift
      ;;
    --no-apps)
      RUN_APPS=false
      shift
      ;;
    --no-stow)
      RUN_STOW=false
      shift
      ;;
    --work)
      WORK_MODE=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --help)
      show_help
      exit 0
      ;;
    *)
      print_error "Unknown option: $1"
      echo "Run './bootstrap.sh --help' for usage"
      exit 1
      ;;
  esac
done

#==============================================================================
# Main Execution
#==============================================================================

main() {
  print_header "macOS Dotfiles Setup"
  echo "Dotfiles directory: ${DOTFILES_DIR}"
  
  if [ "$DRY_RUN" = true ]; then
    print_warning "DRY RUN MODE - No changes will be made"
  fi
  
  # Pre-flight checks
  verify_not_root
  verify_scripts_exist
  
  # Step 1: Homebrew Installation
  if [ "$RUN_BREW" = true ]; then
    print_header "Step 1/4: Homebrew Installation"
    if [ "$WORK_MODE" = true ]; then
      run_script "${SCRIPTS_DIR}/brew.sh" "--work"
    else
      run_script "${SCRIPTS_DIR}/brew.sh"
    fi
    print_success "Homebrew setup complete"
  else
    print_warning "Skipping Homebrew installation (--no-brew)"
  fi
  
  # Step 2: macOS Defaults
  if [ "$RUN_MACOS" = true ]; then
    print_header "Step 2/4: macOS Defaults Configuration"
    run_script "${SCRIPTS_DIR}/macos.sh"
    print_success "macOS defaults configured"
  else
    print_warning "Skipping macOS defaults (--no-macos)"
  fi
  
  # Step 3: Application Installation
  if [ "$RUN_APPS" = true ]; then
    print_header "Step 3/4: Application Installation"
    run_script "${SCRIPTS_DIR}/apps.sh"
    print_success "Applications installed"
  else
    print_warning "Skipping application installation (--no-apps)"
  fi
  
  # Step 4: GNU Stow Dotfiles
  if [ "$RUN_STOW" = true ]; then
    print_header "Step 4/4: Dotfile Symlinking"
    run_script "${SCRIPTS_DIR}/stow.sh"
    print_success "Dotfiles symlinked"
  else
    print_warning "Skipping GNU Stow (--no-stow)"
  fi
  
  # Completion
  if [ "$DRY_RUN" = true ]; then
    echo ""
    print_success "Dry run complete - no changes made"
    echo "Remove --dry-run flag to execute for real"
  else
    echo ""
    print_success "🎉 Bootstrap complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your Mac to apply all settings"
    echo "  2. Source your shell: source ~/.zshrc"
    echo "  3. Configure 1Password, VSCode, and other apps"
    echo ""
    print_warning "Some macOS settings require a logout/restart to take effect"
  fi
}

main "$@"
