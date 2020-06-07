#!/bin/bash

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

eval $($HOME/.linuxbrew/bin/brew shellenv)

brew bundle

if [ ! which zsh ]; then
    brew install zsh
fi

chsh -s `which zsh`

# Poetry
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python

# cargo
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# prezto
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
