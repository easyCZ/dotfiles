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
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

if [[ -d "/home/gitpod/.dotfiles" ]]; then
    # In gitpod, dotfiles are stored in this directory
    pushd "/home/gitpod/.dotfiles"
        mv .zshrc ~/.zshrc
    popd
fi

export SHELL=zsh
