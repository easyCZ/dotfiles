#!/bin/bash
set -ex

echo "Setting up dotfiles"


if [[ -z "$ZSH_VERSION" ]]; then
    echo "Installing zsh"
    sudo apt install zsh
fi

if [[ ! -d "~/.oh-my-zsh" ]]; then
    echo "Installing Oh My Zsh"
    
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install spaceship
# https://github.com/spaceship-prompt/spaceship-prompt
ZSH_CUSTOM="/home/gitpod/.oh-my-zsh/custom"
git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"


# install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git /home/gitpod/.fzf
/home/gitpod/.fzf/install --all --update-rc

if [[ -d "/home/gitpod/.dotfiles" ]]; then
    # In gitpod, dotfiles are stored in this directory
    pushd "/home/gitpod/.dotfiles"
        mv .zshrc ~/.zshrc
    popd
fi

export SHELL=zsh

CREDENTIALS_FILE="/usr/local/secrets/ATUIN_CREDENTIALS"

# Check if credentials file exists
if [ -f "$CREDENTIALS_FILE" ]; then
    # Install atuin if not already installed
    if ! command -v atuin &> /dev/null; then
        echo "Installing Atuin..."
        curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
        source "$HOME/.atuin/bin/env"
        echo 'eval "$(atuin init zsh)"' >> ~/.zshrc
    fi
    
    # Read and parse JSON credentials
    USERNAME=$(jq -r '.user' "$CREDENTIALS_FILE")
    PASSWORD=$(jq -r '.password' "$CREDENTIALS_FILE")
    KEY=$(jq -r '.key' "$CREDENTIALS_FILE")
    
    # Check if all credentials were parsed successfully
    if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ] || [ -z "$KEY" ]; then
        echo "Error: Failed to parse credentials from JSON file"
        exit 1
    fi
    
    # Perform Atuin login
    atuin login -u "$USERNAME" -p "$PASSWORD" -k "$KEY" 
fi

