;;; init-passed.el --- passwd config -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>
;; Created: 2022-12-22 16:49:36

;;; Commentary:

;;; Code:

;; ------------------------- password -----------------------------

(leaf epg-config
  :init
  ;; to read passphrase from minibuffer
  (setq epg-pinentry-mode 'loopback))

;; (leaf pass
;;   :init
;;   (setq pass-show-keybindings nil))

(leaf auth-source
  :commands auth-source-user-and-password)

(leaf authinfo-color-mode
  :mode ("authinfo.gpg\\'" . authinfo-color-mode)
  :init (advice-add 'authinfo-mode :override #'authinfo-color-mode))

(provide 'init-passwd)
;;; init-passwd.el ends here
