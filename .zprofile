#
# Executes commands at login pre-zshrc.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

#
# Browser
#

if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

#
# Editors
#

export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'

#
# Language
#

if [[ -z "$LANG" ]]; then
  export LANG='ja_JP.UTF-8'
fi

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Set the list of directories that cd searches.
# cdpath=(
#   $cdpath
# )

# Set the list of directories that Zsh searches for programs.
path=(
  /usr/local/{bin,sbin}
  $path
)

#
# Less
#

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
if (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi

# emacs keybind on zsh
bindkey -e

# anyenv
type anyenv > /dev/null 2>&1 && eval "$(anyenv init - --no-rehash)"

# Homebrew
if [ -e $HOME/.linuxbrew/bin/brew ]; then
    eval $($HOME/.linuxbrew/bin/brew shellenv)
elif [ -e /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
elif [ -e /opt/homebrew/bin/brew ]; then
    eval $(/opt/homebrew/bin/brew shellenv)
fi

# gh completion
type gh > /dev/null 2>&1 && eval "$(gh completion --shell zsh)"

# direnv
type direnv > /dev/null 2>&1 && eval "$(direnv hook zsh)"

# pyenv
type pyenv > /dev/null 2>&1 && eval "$(pyenv init --path)"

#
# Paths
#

export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.poetry/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/go/bin
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

if [ "$(uname)" = 'Darwin' ]; then
  PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
fi
