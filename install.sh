#!/usr/bin/env bash

# Get dotfiles dir (this script can be ran from anywhere)
export DOTFILES_DIR
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# First update dotfiles via git
[ -d "$DOTFILES_DIR/.git" ] && git --work-tree="$DOTFILES_DIR" --git-dir="$DOTFILES_DIR/.git" pull origin main

# Helper functions
source $DOTFILES_DIR/etc/helpers.sh
probe_capabilities

# If a specific installer is specified, or if a list
# of specific installers is given, run only those;
# otherwise, just install everything
echo "--------- INSTALLING EVERYTHING ---------"
# Run all the installers
install_package cmake
install_package base-devel
install_package python
install_package python-flake8-black
install_package nodejs
install_package jdk-openjdk
install_package jre-openjdk
install_package stow
install_package rofi
install_package zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
chsh -s /usr/bin/zsh
yay -S noto-fonts-emoji-apple
clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# TODO: fix jdk installation
# TODO: install zsh and zsh config
# TODO: add tmux themes dir to repo

stow --dotfiles cwm bash git tmux vim xinitrc xprofile
rm -rf ~/.vim
cp -r ./vim/vim ~/.vim #this is bad since it doesn't symlink the file

tmux source ~/.tmux.conf
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# download & install plugins
vim -E +PlugInstall +qall
python3 ~/.vim/plugged/YouCompleteMe/install.py

# build custom spellcheck dictionary
vim -E +"mkspell ~/.dotfiles/vim/spell/en.utf-8.add" +qall
source ./fonts/install

cp ranger/dot-config/ranger/rc.conf ~/.config/ranger/rc.conf

cp alacritty/dot-config/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml

report_errors

