# dotfiles

`chezmoi`を使ったmacOSとLinux用のdotfiles

## 初回セットアップ

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/moisutsu/dotfiles/main/bootstrap.sh)"
```

`bootstrap.sh` は次の処理を行います。

- `~/dotfiles` がなければcloneし、あれば `git pull --ff-only` で更新する
- Homebrewがある環境では、`Brewfile` の最低限のCLIを入れる
- Homebrewがなければ、Homebrewまたは `chezmoi` / `sheldon` / `mise` のインストール案内を表示する
- `chezmoi` があれば `chezmoi apply --source "$HOME/dotfiles"` で設定を反映する
- `sheldon` があればZsh pluginをlock/installする
- `mise` があれば管理対象ツールをinstallする
- 最後に `zsh -l` を起動する

## 既存マシンの更新

通常は次のコマンドを再実行すればよいです。何回実行しても同じ状態に収束する構成にしています。

```bash
cd ~/dotfiles
bash ~/dotfiles/bootstrap.sh
```

設定ファイルだけを反映したい場合はchezmoiを直接使います。

```bash
chezmoi diff
chezmoi apply
```

## 構成

- `bootstrap.sh`: 新規セットアップと既存マシン更新用のbootstrap script
- `Brewfile`: Homebrewが使える環境で入れる、dotfilesが直接使う最低限のCLI一覧
- `.chezmoiroot`: chezmoiのsource rootを `home/` にする設定
- `home/`: ホームディレクトリへ展開されるchezmoi管理ファイル
- `home/dot_config/mise/config.toml`: miseで管理する言語・CLIバージョン
- `home/dot_config/sheldon/plugins.toml`: Zsh plugin管理

## マシン固有設定

マシン固有の設定はこのリポジトリでは管理しません。各マシンの `~/.zshrc.local` に置きます。

`~/.zshrc.local` は `~/.zshrc` から読み込まれます。

リポジトリ管理のファイルにマシン固有設定を直接書かない方針です。

## Homebrew

`Brewfile` はMacアプリや作業用途の全パッケージ一覧ではありません。dotfilesが直接前提にしている最低限のCLIだけを管理します。

Homebrewが使える環境では、次のコマンドで不足分を入れます。

```bash
brew bundle install --file "$HOME/dotfiles/Brewfile" --no-upgrade
```

## mise

言語ランタイムや一部CLIのバージョン管理にはmiseを使います。設定は `home/dot_config/mise/config.toml` にあります。

```bash
mise install
mise ls --current
```

## Sheldon

Zsh plugin管理にはSheldonを使います。設定は `home/dot_config/sheldon/plugins.toml` にあります。

```bash
sheldon lock
sheldon source
```

`.zshrc` はSheldonが存在する場合だけ `sheldon source` を読み込みます。Sheldonがない環境でもshell自体は起動できます。

## chezmoi運用

ホームディレクトリへ反映されるファイルは `home/` 配下に置きます。

例:

- `home/dot_zshrc` -> `~/.zshrc`
- `home/dot_gitconfig.tmpl` -> `~/.gitconfig`
- `home/dot_config/mise/config.toml` -> `~/.config/mise/config.toml`

`home/dot_config/chezmoi/chezmoi.toml` で `sourceDir = "~/dotfiles"` を設定しているため、初回適用後は通常 `--source` を付けずにchezmoiを使えます。

変更前に差分を見るには:

```bash
chezmoi diff
```

反映するには:

```bash
chezmoi apply
```

管理対象ファイルを編集するには:

```bash
chezmoi edit ~/.zshrc
chezmoi apply
```

ホームディレクトリ側の管理対象ファイルに加わった変更をdotfilesへ取り込むには:

```bash
chezmoi diff ~/.zshrc
chezmoi re-add ~/.zshrc
```
