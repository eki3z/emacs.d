;;; init-format.el --- format config -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>
;; Created: 2023-08-01 17:07:24

;;; Commentary:

;;; Code:

;; -------------------------- Format ------------------------------

;; (leaf editorconfig
;;   :hook (after-init-hook . editorconfig-mode))

(leaf apheleia
  :hook ((typescript-ts-mode-hook js-ts-mode-hook)
         . apheleia-mode)
  :init
  (setq apheleia-hide-log-buffers t)
  (defun my/format ()
    "Formatting current buffer."
    (interactive)
    (if buffer-read-only
        (message "%s is read-only." (buffer-name))
      (cl-case major-mode
        ((gitconfig-mode emacs-lisp-mode lisp-interaction-mode)
         (run-general! indent-region indent-whole-buffer))
        (t (call-interactively #'apheleia-format-buffer)))))

  ;; do not format if functions return non-nil
  (setq apheleia-skip-functions
        '(yas-current-field active-minibuffer-window))

  :defer-config
  (alist-set! apheleia-formatters
              '((shfmt . ("shfmt" "-i" "2" "-bn" "-ci"))
                (stylua . ("stylua" "--search-parent-directories" "-"))
                (d2fmt . ("d2" "fmt" filepath))))
  (alist-set! apheleia-mode-alist
              '((python-mode . (ruff isort))
                (python-ts-mode . (ruff isort))
                ((sh-mode bash-ts-mode) . shfmt)
                (d2-ts-mode . d2fmt)
                (markdown-mode . prettier-markdown)
                (gfm-mode . prettier-markdown)
                (ruby-ts-mode . rubocop)
                (nxml-mode . prettier-html)
                (js-jsx-mode . prettier-javascript)
                (tsx-ts-mode . prettier-typescript))))

(provide 'init-format)
;;; init-format.el ends here
