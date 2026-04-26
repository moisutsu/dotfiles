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
    echo "brew is not installed. Please install brew." >&2
fi

if command -v chezmoi > /dev/null 2>&1; then
    chezmoi apply --source "$DOT_DIRECTORY"
else
    echo "chezmoi is not installed. Please install chezmoi." >&2
fi

if command -v sheldon > /dev/null 2>&1; then
    sheldon lock
else
    echo "sheldon is not installed. Please install sheldon." >&2
fi

if command -v mise > /dev/null 2>&1; then
    mise install
else
    echo "mise is not installed. Please install mise." >&2
fi

exec zsh -l
