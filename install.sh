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

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
python3 ~/.vim/plugged/YouCompleteMe/install.py

# download & install plugins
vim -E +PlugInstall +qall

# build custom spellcheck dictionary
vim -E +"mkspell ~/.dotfiles/vim/spell/en.utf-8.add" +qall
source ./fonts/install

stow --dotfiles cwm bash git polybar ranger\
	tmux vim xinitrc xprofile

cp polybar/launch.sh ~/launch.sh

report_errors

