;;; init-duplexer.el --- duplexer setup -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>
;; Created: 2022-12-18 20:49:08

;;; Commentary:

;;; Code:

(leaf duplexer
  :hook (after-init-hook . duplexer-mode)
  :defer-config
  (setq duplexer-quiet t)
  (setq duplexer-groups
        '(;; built-in
          (no-hl-line . ((hl-line-mode -1) (global-hl-line-mode -1)))
          (read-only  . ((read-only-mode 1)))
          (no-cursor  . ((blink-cursor-mode -1)))
          ;; third-party
          (no-margin  . ((diff-hl-margin-local-mode -1) (binky-margin-local-mode -1)))
          (no-paren   . ((highlight-parentheses-mode -1)))
          (temp-motion . ((my/meow-temp-motion 1)))))

  (setq duplexer-alist
        '((olivetti-mode . (no-margin no-hl-line (focus-mode 1)))
          (redacted-mode . (no-margin no-hl-line no-paren no-cursor read-only))
          (smerge-mode   . (no-margin no-paren (save-place-local-mode -1)))))

  (appendq! duplexer-fallback-alist '((my/meow-temp-motion . meow--temp-state-before))))

(provide 'init-duplexer)
;;; init-duplexer.el ends here
