#!/bin/zsh

# Change default keyboard settings beyond what is available in the settings UI
# https://apple.stackexchange.com/questions/10467/how-to-increase-keyboard-key-repeat-rate-on-os-x
defaults write -g InitialKeyRepeat -int 12 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -int 1         # normal minimum is 2 (30 ms)

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
if ! grep -q "eval \"\$(/opt/homebrew/bin/brew shellenv)\"" ~/.zshrc; then
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.zshrc
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install homebrew packages
brew install \
  wget \
  neovim \
  lazygit \
  gh \
  font-meslo-lg-nerd-font \
  colima

# Install casks
brew install --cask nikitabobko/tap/aerospace

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

# Get neovim config
gh repo clone evanbunnage/nvim /Users/evan/.config/nvim/
