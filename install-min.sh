#!/bin/bash

export HOMEBREW_NO_ENV_FILTERING=1

if !(command -v zsh 1>/dev/null 2>&1); then
    sudo -k
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    if [ ! "$(uname)" = 'Darwin' ]; then
        if [ -e $HOME/.linuxbrew/bin/brew ];then
            eval $($HOME/.linuxbrew/bin/brew shellenv)
        else
            eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
        fi
    fi
    brew install zsh
fi

# prezto
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
