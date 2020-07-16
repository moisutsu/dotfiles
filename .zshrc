# .aliasesを読み込み
[ -f $HOME/.aliases ] && source $HOME/.aliases

# 自作シェススクリプトの読み込み
[ -f $HOME/.functions ] && source $HOME/.functions

# fpath
fpath+=~/.zfunc

# zsh 補間
autoload -U compinit
compinit

# .zshrc.local 環境依存の設定を記述
[ -f $HOME/.zshrc.local ] && source $HOME/.zshrc.local

eval "$(starship init zsh)"
