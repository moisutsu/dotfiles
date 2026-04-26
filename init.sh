#!/usr/bin/env bash

set -eu

DOT_DIRECTORY="${DOT_DIRECTORY:-$HOME/dotfiles}"
REPOSITORY="${REPOSITORY:-https://github.com/moisutsu/dotfiles}"

if [ -d "$DOT_DIRECTORY/.git" ]; then
    git -C "$DOT_DIRECTORY" pull --ff-only
else
    git clone "$REPOSITORY" "$DOT_DIRECTORY"
fi

if command -v brew > /dev/null 2>&1; then
    brew bundle install --file "$DOT_DIRECTORY/Brewfile" --no-upgrade
else
    echo "brew is not installed. Please install brew, or install chezmoi, sheldon, and mise manually." >&2
fi

command -v chezmoi > /dev/null 2>&1 && chezmoi apply --source "$DOT_DIRECTORY"
command -v sheldon > /dev/null 2>&1 && sheldon lock
command -v mise > /dev/null 2>&1 && mise install

exec zsh -l
