#!/bin/bash

DOT_DIRECTORY="$HOME/dotfiles"
SPECIFY_FILES=(Brewfile)

cd `dirname $0`

for f in .??* ${SPECIFY_FILES[@]}
do
    [[ $f = ".git" ]] && continue
    [[ $f = ".gitignore" ]] && continue
    [[ $f = ".DS_Store" ]] && continue
    ln -snfv $DOT_DIRECTORY/$f $HOME/$f
done

mkdir -p $HOME/.emacs.d
ln -snfv $DOT_DIRECTORY/.emacs/init.el $HOME/.emacs.d/init.el
