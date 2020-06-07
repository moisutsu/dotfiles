#!/bin/bash

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

eval $($HOME/.linuxbrew/bin/brew shellenv)

brew bundle
