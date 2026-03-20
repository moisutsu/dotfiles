#
# Defines environment variables.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'

if [[ -z "$LANG" ]]; then
  export LANG='ja_JP.UTF-8'
fi

typeset -gU cdpath fpath mailpath path

path=(
  "$HOME/.cargo/bin"
  "${ASDF_DATA_DIR:-$HOME/.asdf}/bin"
  "${ASDF_DATA_DIR:-$HOME/.asdf}/shims"
  /usr/local/bin
  /usr/local/sbin
  $path
  "$HOME/.local/bin"
  "$HOME/go/bin"
)

case "$(uname -s)" in
  Linux*)
    export GIT_CONFIG_GLOBAL="$HOME/.gitconfig.linux"
    if [[ -d "$HOME/.linuxbrew/bin" ]]; then
      path=("$HOME/.linuxbrew/bin" "$HOME/.linuxbrew/sbin" $path)
    elif [[ -d /home/linuxbrew/.linuxbrew/bin ]]; then
      path=(/home/linuxbrew/.linuxbrew/bin /home/linuxbrew/.linuxbrew/sbin $path)
    fi
    ;;
  Darwin*)
    export GIT_CONFIG_GLOBAL="$HOME/.gitconfig.macos"
    if [[ -d /opt/homebrew/bin ]]; then
      path=(/opt/homebrew/bin /opt/homebrew/sbin $path)
    fi
    if [[ -d /opt/homebrew/opt/coreutils/libexec/gnubin ]]; then
      path=(/opt/homebrew/opt/coreutils/libexec/gnubin $path)
    elif [[ -d /usr/local/opt/coreutils/libexec/gnubin ]]; then
      path=(/usr/local/opt/coreutils/libexec/gnubin $path)
    fi
    ;;
esac

export LESS='-F -g -i -M -R -S -w -X -z-4'

if (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi
