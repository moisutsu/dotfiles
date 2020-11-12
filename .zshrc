# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# .aliasesを読み込み
[ -f $HOME/.aliases ] && source $HOME/.aliases

# 自作シェススクリプトの読み込み
[ -f $HOME/.functions ] && source $HOME/.functions

# history
# メモリに保存される履歴の件数
export HISTSIZE=1000
# 履歴ファイルに保存される履歴の件数
export SAVEHIST=100000
# 重複を記録しない
setopt hist_ignore_dups
# 開始と終了を記録
setopt EXTENDED_HISTORY
# historyを共有
setopt share_history
# ヒストリに追加されるコマンド行が古いものと同じなら古いものを削除
setopt hist_ignore_all_dups
# スペースで始まるコマンド行はヒストリリストから削除
setopt hist_ignore_space
# ヒストリを呼び出してから実行する間に一旦編集可能
setopt hist_verify
# 余分な空白は詰めて記録
setopt hist_reduce_blanks
# 古いコマンドと同じものは無視
setopt hist_save_no_dups
# historyコマンドは履歴に登録しない
setopt hist_no_store
# 補完時にヒストリを自動的に展開
setopt hist_expand
# 履歴をインクリメンタルに追加
setopt inc_append_history

# fpath
fpath+=~/.zfunc

# zsh 補間
autoload -U compinit
compinit

# .zshrc.local 環境依存の設定を記述
[ -f $HOME/.zshrc.local ] && source $HOME/.zshrc.local

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/jun/.anyenv/envs/pyenv/versions/anaconda3-2020.07/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/jun/.anyenv/envs/pyenv/versions/anaconda3-2020.07/etc/profile.d/conda.sh" ]; then
        . "/Users/jun/.anyenv/envs/pyenv/versions/anaconda3-2020.07/etc/profile.d/conda.sh"
    else
        export PATH="/Users/jun/.anyenv/envs/pyenv/versions/anaconda3-2020.07/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

