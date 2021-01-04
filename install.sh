#!/bin/bash

export HOMEBREW_NO_ENV_FILTERING=1

sudo -k

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

if [ ! "$(uname)" = 'Darwin' ]; then
    if [ -e $HOME/.linuxbrew/bin/brew ];then
        eval $($HOME/.linuxbrew/bin/brew shellenv)
    else
        eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
    fi
fi

brew bundle

if [ ! `which zsh` ]; then
    brew install zsh
fi

# /etc/shellsに `which zsh` の出力を追加する必要あり
# if [ $SHELL != "`which zsh`" ]; then
#     chsh -s `which zsh`
# fi

# anyenv
anyenv install --init

# zinit
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"
