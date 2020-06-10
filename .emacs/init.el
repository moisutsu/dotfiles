;; 日本語化
(set-language-environment 'Japanese)

;; 文字コードをUTF-8
(set-language-environment  'utf-8)
(prefer-coding-system 'utf-8)

;; Ctrl-hで削除
(define-key key-translation-map (kbd "C-h") (kbd "<DEL>"))

;; バックアップファイルを作成しない
(setq auto-save-default nil)
(setq make-backup-files nil)

;; シンボリックリンク先のファイルを自動で開く
(setq vc-follow-symlinks t)

;; スタートアップメッセージを表示させない
(setq inhibit-startup-message t)

;; 列数を表示する
(column-number-mode t)

;; 行数を表示する
(require 'linum)
(global-linum-mode t)
(setq linum-format "%3d ")
(line-number-mode t)

;; 対応する括弧を光らせる
(show-paren-mode 1)

;; スクロールは１行ごとに
(setq scroll-conservatively 1)

;; "yes or no" の選択を "y or n" にする
(fset 'yes-or-no-p 'y-or-n-p)

;; 括弧を自動で補完する
(electric-pair-mode 1)

;; tabにスペース４つを利用
(setq-default tab-width 4 indent-tabs-mode nil)

;; メニューバーの非表示
(menu-bar-mode -1)
