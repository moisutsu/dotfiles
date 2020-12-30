#!/bin/bash

DOT_DIRECTORY="$HOME/dotfiles"
SPECIFY_FILES=(Brewfile)
BACKUP_DIRECTORY="$HOME/.backup/dotfiles"

cd `dirname $0`

mkdir -p $BACKUP_DIRECTORY

for f in .??* ${SPECIFY_FILES[@]}
do
    [[ $f = ".git" ]] && continue
    [[ $f = ".gitignore" ]] && continue
    [[ $f = ".DS_Store" ]] && continue
    if [ -e $HOME/$f ] && [ ! -L $HOME/$f ]; then
        mv $HOME/$f $BACKUP_DIRECTORY
    fi
    ln -snfv $DOT_DIRECTORY/$f $HOME/$f
done

rmdir -p $BACKUP_DIRECTORY 2>/dev/null

# emacs config
mkdir -p $HOME/.emacs.d
ln -snfv $DOT_DIRECTORY/emacs/init.el $HOME/.emacs.d/init.el
