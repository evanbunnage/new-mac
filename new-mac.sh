#!/bin/zsh

STATUS='\033[1;33m'  # Bold Yellow
GREEN='\033[0;32m'   # Green
NC='\033[0m'         # No Color

HOME_DIR="/Users/$USER"
PLIST_DIR="/Users/$USER/Library/Preferences"

HOMEBREW_PACKAGES=(
    wget
    neovim
    lazygit
    gh
    font-meslo-lg-nerd-font
    colima
    scroll-reverser
    stats
    fzf
    fd
    ripgrep
    watch
    jq
)

main() {
    
    # Exit on any error
    set -e

    setup_directories || exit 1
    configure_macos_defaults || exit 1
    install_homebrew || exit 1
    install_homebrew_packages || exit 1
    install_node || exit 1
    install_rust || exit 1
    install_zig || exit 1
    install_oh_my_zsh || exit 1
    setup_python || exit 1
    setup_api_keys || exit 1
    setup_git || exit 1
    clone_repos || exit 1
    setup_config_files || exit 1
    setup_launch_scripts || exit 1
    
    echo -e "${GREEN}Setup complete, restart your 💻${NC}"
}

setup_directories() {
    echo -e "${STATUS}Setting up directories...${NC}"
    mkdir -p "$HOME_DIR/projects"
}

configure_macos_defaults() {
    echo -e "${STATUS}Configuring macOS default settings...${NC}"
    
    # Change default keyboard settings beyond what is available in the settings UI
    # https://apple.stackexchange.com/questions/10467/how-to-increase-keyboard-key-repeat-rate-on-os-x
    defaults write -g InitialKeyRepeat -int 10  # normal minimum is 15 (225 ms)
    defaults write -g KeyRepeat -int 1          # normal minimum is 2 (30 ms)
    
    # Change some window behaviors for Aerospace
    defaults write -g NSWindowShouldDragOnGesture -bool true
    defaults write com.apple.dock expose-group-apps -bool true && killall Dock
    defaults write com.apple.spaces spans-displays -bool true && killall SystemUIServer
}

install_homebrew() {
    echo -e "${STATUS}Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
}

install_homebrew_packages() {
    echo -e "${STATUS}Installing Homebrew packages...${NC}"
    
    brew install "${HOMEBREW_PACKAGES[@]}"
    
    # Install casks
    brew install --cask nikitabobko/tap/aerospace
    brew install --cask betterdisplay
    brew install --cask ghostty
}

install_node() {
    echo -e "${STATUS}Installing Node.js via nvm...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    source ~/.zshrc
    nvm install node
}

install_rust() {
    echo -e "${STATUS}Installing Rust...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

install_zig() {
    echo -e "${STATUS}Installing the latest Zig from master...${NC}"
    sudo mkdir -p /usr/local/zig/
    
    # Get latest zig master metadata
    json=$(curl -s https://ziglang.org/download/index.json)
    tarball=$(echo "$json" | grep -o 'https://ziglang.org/builds/zig-macos-aarch64-[^"]*')
    
    # Download and install
    curl -L "$tarball" -o zig.tar.xz
    
    sudo rm -rf /usr/local/zig/*
    sudo tar xf zig.tar.xz -C /usr/local/zig --strip-components=1
    rm zig.tar.xz
    chmod +x /usr/local/zig/zig
}

install_oh_my_zsh() {
    echo -e "${STATUS}Installing Oh My Zsh...${NC}"
    # Force reinstall by removing existing installation
    rm -rf "$HOME_DIR/.oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    return 0
}

setup_python() {
    echo -e "${STATUS}Setting up Python environment with uv...${NC}"
    # Download some python versions
    if command -v uv &> /dev/null; then
        uv self update
    else
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
    uv python install 3.11 3.12 3.13
}

setup_git() {
    echo -e "${STATUS}Setting up Git configuration...${NC}"
    # Set up git
    read "git_email?Enter the email to use for the global git config: "
    git config --global user.name "Evan Bunnage"
    git config --global user.email "$git_email"
    git config --global color.ui true

    if ! gh auth status 2>/dev/null; then
        echo -e "${STATUS}GitHub not authenticated, starting login process...${NC}"
        gh auth login
    else
        # Extract and display the account name using grep and awk for more reliable parsing
        account_name=$(gh auth status | grep "Logged in to github.com" | awk -F'account ' '{print $2}' | awk '{print $1}')
        echo -e "${STATUS}Already logged into GitHub as ${account_name}${NC}"
    fi
}

setup_api_keys() {
    # Add API keys file to environment if it doesn't exist
    if [[ -f "$HOME_DIR/.api_keys" ]]; then
        echo -e "${STATUS}Found existing ~/.api_keys file${NC}"
        return 0
    fi
    
    echo -e "${STATUS}Setting up API keys file...${NC}"
    touch "$HOME_DIR/.api_keys"
    chmod 600 "$HOME_DIR/.api_keys"
}

clone_repos() {
    echo -e "${STATUS}Cloning essential repositories...${NC}"

    if [ -d "$HOME_DIR/.config/nvim" ]; then
        mv "$HOME_DIR/.config/nvim" "$HOME_DIR/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
    fi

    if ! gh repo clone evanbunnage/nvim "$HOME_DIR/.config/nvim/"; then
        echo -e "${STATUS}The repo at .config/nvim already exists, not overwriting...${NC}"
    fi

    if ! gh repo clone evanbunnage/new-mac "$HOME_DIR/projects/new-mac/"; then
        echo -e "${STATUS}The repo at /projects/new-mac already exists, not overwriting...${NC}"
    fi

    if ! gh repo clone evanbunnage/notes "$HOME_DIR/projects/notes/"; then
        echo -e "${STATUS}The repo at /projects/notes already exists, not overwriting...${NC}"
    fi

}

setup_config_files() {
    echo -e "${STATUS}Linking config files...${NC}"

    # Create symlink for dotfiles at ~/
    rm -f "$HOME_DIR/.aerospace.toml" # Aerospace auto-generates this on install
    ln -s "$HOME_DIR/projects/new-mac/dotfiles/.aerospace.toml" "$HOME_DIR/.aerospace.toml"

    rm -f "$HOME_DIR/.zshrc"
    ln -s "$HOME_DIR/projects/new-mac/dotfiles/.zshrc" "$HOME_DIR/.zshrc" 

    # Link super basic plist files
    rm -f "$PLIST_DIR/eu.exelban.Stats.plist"
    ln -s "$HOME_DIR/projects/new-mac/plists/eu.exelban.Stats.plist" "$PLIST_DIR/eu.exelban.Stats.plist"
}

setup_launch_scripts() {
    echo -e "${STATUS}Setting up custom LaunchAgents...${NC}"
    # Make launch scripts executable
    find "$HOME_DIR/projects/new-mac/plists/LaunchAgents" \
        -name "*.sh" \
        -type f \
        -exec chmod +x {} \;

    # Link launch agent plists to Library/LaunchAgents
    find "$HOME_DIR/projects/new-mac/plists/LaunchAgents" \
        -name "*.plist" \
        -type f \
        -exec ln -s {} "$HOME_DIR/Library/LaunchAgents/" \;

    # Load all launch agent plists
    find "$HOME_DIR/projects/new-mac/plists/LaunchAgents" \
        -name "*.plist" \
        -type f \
        -exec launchctl load {} \;
}
# Run the script
main
