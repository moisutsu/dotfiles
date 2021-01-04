#!/bin/bash

if !(command -v zsh 1>/dev/null 2>&1); then
    sudo -k
    export HOMEBREW_NO_ENV_FILTERING=1
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

# zinit
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"
