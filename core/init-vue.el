;;; init-vue.el --- Setup vue configs -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>
;; Created: 2023-10-05 21:46:58

;;; Commentary:

;;; Code:

;; Setup major mode
(add-to-list 'auto-mode-alist '("\\.vue\\'" . web-vue-mode))
(define-derived-mode web-vue-mode web-mode "wVue"
  "Major mode for editing VUE files."
  ;; NOTE do not fontification
  (setq-local web-mode-enable-html-entities-fontification t)
  (setq-local web-mode-enable-element-content-fontification nil)
  (setq-local web-mode-enable-element-tag-fontification nil)
  )

;; Setup lsp
(with-eval-after-load 'lsp-bridge
  (add-to-list 'lsp-bridge-default-mode-hooks 'web-vue-mode-hook))

;; Setup tsdk path in volar.json
(defun tsdk-path-detect ()
  (let ((bin-path (string-trim (shell-command-to-string "command -v tsc"))))
    (string-replace "bin/tsc" "lib/node_modules/typescript/lib" bin-path)))

(provide 'init-vue)
;;; init-vue.el ends here

