# dotfiles

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/moisutsu/dotfiles/main/init.sh)"
```

## 必要なコマンド

- zsh
- curl
- git

## 適用

```bash
source "$HOME/dotfiles/init.sh"
```

設定ファイルだけを反映する場合:

```bash
chezmoi apply --source "$HOME/dotfiles"
```

chezmoiで管理するホームディレクトリ向けのファイルは `home/` 配下に置きます。

## Homebrew

Homebrewが使える環境では、dotfilesが直接使う最低限のCLIだけをBrewfileで管理します。

```bash
brew bundle install --file "$HOME/dotfiles/Brewfile" --no-upgrade
```
