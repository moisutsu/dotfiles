# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# .aliasesを読み込み
if [ -f $HOME/.aliases ]; then
  . $HOME/.aliases
fi

# 自作シェススクリプトの読み込み
if [ -f $HOME/.functions ]; then
  . $HOME/.functions
fi

# fpath
fpath+=~/.zfunc

# zsh 補間
autoload -U compinit
compinit
