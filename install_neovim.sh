#!/bin/bash

# Written by Archimatix

set -e

YELLOW='\033[1;33m'
NOCOLOR='\033[0m'

log() {
    echo -e "${YELLOW}[INFO] $1${NOCOLOR}"
}

error_exit() {
    echo -e "${YELLOW}[ERROR] $1${NOCOLOR}" >&2
    exit 1
}

install_dependencies() {
    if [ -x "$(command -v apt-get)" ]; then
        log "Detected Debian-based system. Installing dependencies..."
        sudo apt update || error_exit "Failed to update package list"
        sudo apt install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen || error_exit "Failed to install dependencies"
    elif [ -x "$(command -v dnf)" ]; then
        log "Detected Fedora system. Installing dependencies..."
        sudo dnf install -y ninja-build gettext libtool autoconf automake cmake gcc gcc-c++ make pkgconfig unzip curl doxygen || error_exit "Failed to install dependencies"
    elif [ -x "$(command -v brew)" ]; then
        log "Detected macOS system with Homebrew. Installing dependencies..."
        brew install ninja libtool automake cmake pkg-config gettext curl || error_exit "Failed to install dependencies"
        brew link --force gettext || error_exit "Failed to link gettext"
    else
        error_exit "Unsupported OS. Please install dependencies manually."
    fi
}

install_node_npm() {
    log "Installing Node.js and npm..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - || error_exit "Failed to setup Node.js repository"
    sudo apt-get install -y nodejs || error_exit "Failed to install Node.js"
}

install_prettier() {
    log "Installing Prettier globally..."
    sudo npm install -g prettier || error_exit "Failed to install Prettier"
}

build_neovim() {
    if command -v nvim &> /dev/null; then
        log "Neovim is already installed. Skipping cloning and building."
    else
        log "Cloning Neovim repository..."
        git clone https://github.com/neovim/neovim.git || error_exit "Failed to clone Neovim repository"
        cd neovim || error_exit "Failed to enter Neovim directory"

        log "Building Neovim..."
        make CMAKE_BUILD_TYPE=Release || error_exit "Failed to build Neovim"

        log "Installing Neovim..."
        sudo make install || error_exit "Failed to install Neovim"
    fi
}

copy_config_files() {
    local config_dir="$HOME/.config/nvim"
    log "Copying Neovim configuration files to $config_dir"
    
    mkdir -p "$config_dir" || error_exit "Failed to create configuration directory"

    cp -r ./config_files/* "$config_dir" || error_exit "Failed to copy configuration files"
}

main() {
    log "Starting Neovim installation script"
    install_dependencies
    install_node_npm
    install_prettier
    build_neovim
    copy_config_files
    log "Neovim installation complete. Verify installation by running: nvim --version"
}

main "$@"

