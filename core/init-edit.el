;;; init-edit.el --- edit setting -*- lexical-binding: t no-byte-compile: t -*-
;;; Commentary:
;;; Code:

(require 'init-const)

;;; --------------------------- Edit -------------------------------

(use-package hungry-delete
  :hook (after-init-hook . global-hungry-delete-mode)
  :config (setq-default hungry-delete-chars-to-skip " \t\f\v"))

;; SEE https://www.python.org/dev/peps/pep-0350/#mnemonics
(use-package hl-todo
  :hook (after-init-hook . global-hl-todo-mode)
  :config (prependq! hl-todo-include-modes '(conf-mode))
  :init
  (setq hl-todo-wrap-movement t)
  (setq hl-todo-keyword-faces
        '(;; Informal tasks/features that are pending completion
          ("TODO"       . "#afd8af")
          ;; Problematic or ugly code needing refactoring or cleanup
          ("FIXME"      . "#cc9393")
          ;;Temporary code to force inflexible functionality
          ("HACK"       . "#d0bf8f")
          ;; Portability for specific OS, Python version,etc
          ("WORKAROUND" . "#7cb8bb")
          ;; Remove since version X.x.x
          ("DEPRECATED" . "#7cb8bb")
          ;; Satisfactions of specific, formal requirements.
          ("REQUIRE"    . "#7cb8bb")
          ;; Pointers to other code, web link, etc
          ("SEE"        . "#99d0f6")
          ;; Code shared on Github
          ("ISSUE"      . "#dc8cc3")
          ("PR"         . "#dc8cc3")
          ;; Reviewer thinks needs more discussion
          ("NOTE"       . "#dc8cc3")
          ;; Problems
          ("XXX+"       . "#cc9393")
          ("BUG"        . "#ff665c")
          ("WONTFIX"    . "#8c5353")
          )))

(use-package edit-indirect
  :commands edit-indirect-buffer-indirect-p
  :init
  (setq edit-indirect-mode-map nil)

  (defun my/edit-indirect ()
    "Edit indirectly according to `major-mode'"
    (interactive)
    (pcase major-mode
      ('snippet-mode (yas-edit-elisp-indirect))
      ((or 'markdown-mode 'gfm-mode) (markdown-edit-code-block))
      (_ nil)))
  )

(use-package wgrep
  :init
  (setq wgrep-change-readonly-file t)
  (setq wgrep-auto-save-buffer t))

(use-package rg
  ;; HACK jump to first error once search finished.
  :hook (rg-mode-hook . (lambda ()
                          (run-with-idle-timer 0.1 nil #'compilation-first-error)))
  :init
  (setq rg-ignore-case 'smart
        rg-command-line-flags '("-z" "--pcre2"))
  :config
  ;; Integration with evil-ex-substitute
  (defun rg-replace ()
    "Replace in Rg-mode."
    (interactive)
    (wgrep-change-to-wgrep-mode)
    (unwind-protect
        (evil-ex (concat "%s/" (rg-search-pattern rg-cur-search)))
      (wgrep-finish-edit)))
  (rg-menu-transient-insert "Rerun" "R" "Replace" #'rg-replace)
  )

;; FIXME s-v is ok,s-c is disable in emacs -nw still, use EVIL copy instead.
(use-package xclip
  :hook (after-make-console-frame-hook . xclip-mode))

(use-package cliphist
  :init
  (setq cliphist-cc-kill-ring t)
  (with-eval-after-load 'xclip
    (setq cliphist-select-item-callback
          (lambda (num str)
            (xclip-set-selection 'clipboard str))))
  )

;;; --------------------------- Undo -------------------------------

(use-package undohist
  :hook (after-init-hook . undohist-initialize)
  :init (setq undohist-ignored-files '("\\.git/COMMIT_EDITMSG$")))

(use-package vundo
  :hook (after-init-hook . vundo-ascii-mode)
  :init (setq vundo--window-max-height 5))

;;; --------------------------- Jump -------------------------------

(use-package avy
  :hook (after-init-hook . avy-setup-default)
  :config
  (setq avy-all-windows t
        avy-all-windows-alt t
        avy-background t
        avy-style 'at-full
        avy-keys '(?a ?s ?d ?f ?h ?j ?k ?l ?q ?u ?w ?i ?e ?o))
  (setq avy-orders-alist
        '((avy-goto-char . avy-order-closest)
          (avy-goto-word-0 . avy-order-closest)
          (avy-goto-paren . avy-order-closest)))

  ;; SEE https://github.com/abo-abo/avy/wiki/custom-commands#jumping-to-an-open-paren
  ;; https://stackoverflow.com/a/50063226/13194984
  (defun avy-goto-paren ()
    "Avy jump to paren."
    (interactive)
    (let ((avy-command this-command))
      (avy-jump "[][(){}]")))

  ;; Pinyin support
  (use-package ace-pinyin
    :init (setq ace-pinyin-simplified-chinese-only-p nil)
    :config (ace-pinyin-global-mode +1))
  )

;; Disable modes below when enter `vlf-mode'
(use-package vlf
  :commands vlf-mode
  :init
  (setq large-file-warning-threshold (* 1024 1024))
  (setq vlf-save-in-place t
        vlf-batch-size (* 1 1024 1024))

  ;; toggle modes according to vlf-mode
  (defvar vlf-toggle-modes '((flycheck-mode . nil)
                             (auto-revert-mode . nil)
                             (diff-hl-mode . nil)))
  (add-hook 'vlf-mode-hook (lambda ()
                             (mode-hook-toggle
                              vlf-mode
                              vlf-toggle-modes)))
  :config
  (use-package vlf-setup
    :init (setq vlf-application 'ask))
  )

(provide 'init-edit)
;;; init-edit.el ends here
