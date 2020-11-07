#!/bin/bash

if command -v brew 1>/dev/null 2>&1; then
    if [ ! "$(uname)" = 'Darwin' ]; then
        if [ -e $HOME/.linuxbrew/bin/brew ];then
            eval $($HOME/.linuxbrew/bin/brew shellenv)
        else
            eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
        fi
    fi
fi

if command -v zsh 1>/dev/null 2>&1; then
    export SHELL="`which zsh`"
    exec $SHELL -l
fi
