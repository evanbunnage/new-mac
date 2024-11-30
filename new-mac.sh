#!/bin/zsh

mkdir -p /Users/evan/projects

# Change default keyboard settings beyond what is available in the settings UI
# https://apple.stackexchange.com/questions/10467/how-to-increase-keyboard-key-repeat-rate-on-os-x
defaults write -g InitialKeyRepeat -int 10 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -int 1         # normal minimum is 2 (30 ms)

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
if ! grep -q "eval \"\$(/opt/homebrew/bin/brew shellenv)\"" ~/.zshrc; then
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.zshrc
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install homebrew packages
HOMEBREW_PACKAGES=(
  wget
  neovim
  lazygit
  gh
  font-meslo-lg-nerd-font
  colima
  scroll-reverser
  stats
)

# First uninstall every other homebrew package. This ensures that old packages are removed
# when I re-run this script periodically
brew list | grep -v "$(printf '%s\|' "${HOMEBREW_PACKAGES[@]}" | sed 's/|$//')" | xargs brew uninstall --force

brew install "${HOMEBREW_PACKAGES[@]}"

# Install casks
brew install --cask nikitabobko/tap/aerospace
brew install --cask betterdisplay

# Install nvm and node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.zshrc
nvm install node 

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Setup Zig
sudo mkdir -p /usr/local/zig/

# Add Zig to path if not already there
if ! grep -q "export PATH=\$PATH:/usr/local/zig/" ~/.zshrc; then
  echo 'export PATH=$PATH:/usr/local/zig/' >>~/.zshrc
fi

# Get latest zig master metadata
json=$(curl -s https://ziglang.org/download/index.json)
tarball=$(echo "$json" | grep -o 'https://ziglang.org/builds/zig-macos-aarch64-[^"]*')
shasum=$(echo "$json" | grep -A1 '"aarch64-macos"' | grep shasum | cut -d'"' -f4)

# Download and verify
curl -L "$tarball" -o zig.tar.xz
echo "$shasum zig.tar.xz" | shasum -a 256 -c

# Install
sudo rm -rf /usr/local/zig/*
sudo tar xf zig.tar.xz -C /usr/local/zig --strip-components=1
rm zig.tar.xz
chmod +x /usr/local/zig/zig

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended

# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Download some python versions
uv python install 3.11 3.12 3.13

touch ~/.api_keys
chmod 600 ~/.api_keys
# Add API keys to environment on shell startup
if ! grep -q "source  ~/.api_keys" ~/.zshrc; then
  echo 'source  ~/.api_keys' >>~/.zshrc
fi

# Set up git
git config --global user.name "Evan Bunnage"
git config --global user.email "ebunnage@gmail.com"
git config --global color.ui true

gh auth login

# Get configs and dotfiles
gh repo clone evanbunnage/nvim /Users/evan/.config/nvim/
gh repo clone evanbunnag/new-mac /Users/evan/projects/new-mac/

# Create symlink for areospace config at root
rm -f /Users/evan/.aerospace.toml
ln -s projects/new-mac/dotfiles/.aerospace.toml /Users/evan/.aerospace.toml

# Change some window behaviors for Aerospace
defaults write -g NSWindowShouldDragOnGesture -bool true
defaults write com.apple.dock expose-group-apps -bool true && killall Dock
defaults write com.apple.spaces spans-displays -bool true && killall SystemUIServer


