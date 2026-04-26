#!/usr/bin/env bash

set -eu

DOT_DIRECTORY="${DOT_DIRECTORY:-$HOME/dotfiles}"
REPOSITORY="${REPOSITORY:-https://github.com/moisutsu/dotfiles}"

if [ -d "$DOT_DIRECTORY/.git" ]; then
    git -C "$DOT_DIRECTORY" pull --ff-only
else
    git clone "$REPOSITORY" "$DOT_DIRECTORY"
fi

if ! command -v chezmoi > /dev/null 2>&1; then
    if command -v brew > /dev/null 2>&1; then
        brew install chezmoi
    else
        mkdir -p "$HOME/.local/bin"
        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
        PATH="$HOME/.local/bin:$PATH"
    fi
fi

chezmoi apply --source "$DOT_DIRECTORY"

if command -v brew > /dev/null 2>&1 && [ -f "$DOT_DIRECTORY/Brewfile" ]; then
    brew bundle install --file "$DOT_DIRECTORY/Brewfile" --no-upgrade
fi

if command -v sheldon > /dev/null 2>&1; then
    sheldon lock
fi

if command -v mise > /dev/null 2>&1; then
    mise install
fi

exec zsh -l
