#!/bin/bash

# zshfiles
ln -sf $HOME/dotfiles/zshfiles/zshrc $HOME/.zshrc
ln -sf $HOME/dotfiles/zshfiles/zlogin $HOME/.zlogin
ln -sf $HOME/dotfiles/zshfiles/zlogout $HOME/.zlogout
ln -sf $HOME/dotfiles/zshfiles/zpreztorc $HOME/.zpreztorc
ln -sf $HOME/dotfiles/zshfiles/zshenv $HOME/.zshenv
ln -sf $HOME/dotfiles/zshfiles/zprofile $HOME/.zprofile

# gitfiles
ln -sf $HOME/dotfiles/gitfiles/commit_template $HOME/.commit_template
ln -sf $HOME/dotfiles/gitfiles/gitconfig $HOME/.gitconfig
ln -sf $HOME/dotfiles/gitfiles/gitignore_global $HOME/.gitignore_global

# shellscripts
ln -sf $HOME/dotfiles/shellscripts/aliases $HOME/.aliases
ln -sf $HOME/dotfiles/shellscripts/functions $HOME/.functions
