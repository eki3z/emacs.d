;;; init-lsp-langs.el --- setting for lsp langs -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>
;; Created: 2024-09-25 14:37:44

;;; Commentary:

;;; Code:

;; js

(leaf lsp-bash
  :init
  (setq lsp-bash-highlight-parsing-errors t))

(leaf lsp-pyright :require t)
(leaf lsp-ruff
  :init
  (setq lsp-ruff-log-level "info"))

(leaf lsp-javascript
  :init
  (setq lsp-clients-typescript-prefer-use-project-ts-server t))

;; (defun my/emmet-ls-setup ()
;;   "Setup for emmet-ls"
;;   (setq-local corfu-auto-delay 0.8
;;               corfu-preselect-first t
;;               corfu-doc-delay 0.1)
;;   (setq-local lsp-completion-show-detail nil))
;; (add-hook 'lsp-emmet-ls-after-open-hook #'my/emmet-ls-setup)


;; ;; REQUIRE deps : ccls
;; (leaf ccls
;;   :hook ((c-mode-hook c++-mode-hook) . (lambda ()
;;                                          (require 'ccls)
;;                                          (lsp-deferred))))



(provide 'init-lsp-langs)
;;; init-lsp-langs.el ends here
