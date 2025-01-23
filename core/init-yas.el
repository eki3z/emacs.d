;;; init-yas.el --- Setup for yasnippet -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>
;; Created: 2022-07-09 08:08:36

;;; Commentary:

;;; Code:

(leaf yasnippet
  :hook (after-init-hook . yas-global-mode)
  :bind
  (:yas-keymap
   ([tab] . yas-next-field)
   ("TAB" . yas-next-field))
  :init
  (setq yas-minor-mode-map nil)
  (setq yas-alias-to-yas/prefix-p nil)
  (setq yas-indent-line 'auto)
  (setq yas-new-snippet-default "\
# -*- mode: snippet -*-
# name: ${1:name}
# contributor : ${2:`user-full-name`<`user-mail-address`>}
# key: ${3:key}
# --
$0`(yas-escape-text yas-selected-text)`")

  ;; silent message in start.
  (advice-add #'yas-reload-all :around #'ad/silent-message)

  :defer-config

  ;; enable commit snippets
  (add-hook 'git-commit-mode-hook
            (lambda () (yas-activate-extra-mode 'git-commit-mode)))

  (leaf yasnippet-collection
    :require t
    :config
    (yasnippet-collection-initialize))
  )

(provide 'init-yas)
;;; init-yas.el ends here
