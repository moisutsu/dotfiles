#!/bin/bash

if [ ! "$(uname)" = 'Darwin' ]; then
    if [ -e $HOME/.linuxbrew/bin/brew ];then
        eval $($HOME/.linuxbrew/bin/brew shellenv)
    else
        eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
    fi
fi

export SHELL="`which zsh`"

exec $SHELL -l
