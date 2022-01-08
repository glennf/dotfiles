#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

# Setup Finder Commands
# Show Library Folder in Finder
chflags nohidden ~/Library

# Show Hidden Files in Finder
defaults write com.apple.finder AppleShowAllFiles YES

# Show Path Bar in Finder
defaults write com.apple.finder ShowPathbar -bool true

# Show Status Bar in Finder
defaults write com.apple.finder ShowStatusBar -bool true

# Check for Homebrew, and then install it
if test ! "$(which brew)"; then
    echo "Installing homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    echo "Homebrew installed successfully"
else
    echo "Homebrew already installed!"
fi

# Make brew run in shell
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/t928390/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install XCode Command Line Tools
echo 'Checking to see if XCode Command Line Tools are installed...'
brew config

# Updating Homebrew.
echo "Updating Homebrew..."
brew update

# Upgrade any already-installed formulae.
echo "Upgrading Homebrew..."
brew upgrade

# Install iTerm2
echo "Installing iTerm2..."
brew install iterm2

# Update the Terminal
# Install oh-my-zsh
echo "Installing oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
echo "Need to logout now to start the new SHELL..."
logout

# Install Git
echo "Installing Git..."
brew install git

# Install Powerline fonts
echo "Installing Powerline fonts..."
git clone https://github.com/powerline/fonts.git
cd fonts || exit
sh -c ./install.sh



# Install sdkman
curl -s "https://get.sdkman.io" | bash

sdk install java 8.0.312-zulu
sdk install java 11.0.13-zulu
sdk install sbt
sdk install scala 
# Install some CTF tools; see https://github.com/ctfs/write-ups.
#brew install nmap

# Development tools
#brew install dotnet-sdk
#brew install mono
brew install git
#brew install balenaetcher

# Install other useful binaries.
brew install speedtest_cli

# Core casks
brew install --appdir="/Applications" alfred

# Development tool casks
brew install --appdir="/Applications" visual-studio-code

# Misc casks
brew install --appdir="/Applications" google-chrome
brew install --appdir="/Applications" slack
brew install --appdir="/Applications" 1password
# Docker doesn't seem to install Docker Desktop
# brew cask install --appdir="/Applications" docker
brew install jetbrains-toolbox
brew install webex
brwe install citrix-workspace
#brew install --appdir="/Applications" caffeine

softwareupdate --install-rosetta --agree-to-license

# Remove outdated versions from the cellar.
echo "Running brew cleanup..."
brew cleanup
echo "You're done!"
