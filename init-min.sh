#!/bin/bash

git clone https://github.com/moisutsu/dotfiles "$HOME/dotfiles"

bash $HOME/dotfiles/link.sh

bash $HOME/dotfiles/install-min.sh

# .bashrcにより zsh を起動
bash
