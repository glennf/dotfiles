#!/usr/bin/env bash
set -e

# apps.sh - Install oh-my-zsh, powerlevel10k, mise, and configure zoxide
# Idempotent: Safe to run multiple times

echo "=== Installing shell tools and utilities ==="

# Install oh-my-zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  echo "✓ oh-my-zsh installed"
else
  echo "✓ oh-my-zsh already installed"
fi

# Install powerlevel10k theme if not already installed
P10K_DIR="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  echo "Installing powerlevel10k theme..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
  echo "✓ powerlevel10k installed"
else
  echo "✓ powerlevel10k already installed"
fi

# Install mise if not already installed
if ! command -v mise &> /dev/null; then
  echo "Installing mise..."
  if command -v brew &> /dev/null; then
    brew install mise
  else
    # Fallback to official installer
    curl https://mise.run | sh
    echo 'eval "$(~/.local/bin/mise activate bash)"' >> "$HOME/.bashrc"
    echo 'eval "$(~/.local/bin/mise activate zsh)"' >> "$HOME/.zshrc"
  fi
  echo "✓ mise installed"
else
  echo "✓ mise already installed ($(mise --version))"
fi

# Install zoxide if not already installed
if ! command -v zoxide &> /dev/null; then
  echo "Installing zoxide..."
  if command -v brew &> /dev/null; then
    brew install zoxide
  else
    echo "Warning: Homebrew not found. Install zoxide manually: https://github.com/ajeetdsouza/zoxide#installation"
  fi
  echo "✓ zoxide installed"
else
  echo "✓ zoxide already installed ($(zoxide --version))"
fi

# Check for fabric-bootstrap.inc (optional dependency)
FABRIC_BOOTSTRAP="$HOME/.config/fabric/fabric-bootstrap.inc"
if [ -f "$FABRIC_BOOTSTRAP" ]; then
  echo "✓ fabric-bootstrap.inc found at $FABRIC_BOOTSTRAP"
else
  echo "ℹ fabric-bootstrap.inc not found (optional dependency)"
fi

echo ""
echo "=== Installation complete ==="
echo "Next steps:"
echo "  1. Stow your dotfiles: cd ~/projects/dotfiles && stow -t ~ stow/*"
echo "  2. Restart your shell or run: exec zsh"
echo "  3. Configure powerlevel10k: p10k configure"
