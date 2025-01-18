;;; init-ui.el --- ui settings -*- lexical-binding: t no-byte-compile: t -*-

;;; Commentary:

;;; Code:

(leaf repeat
  :hook (after-init-hook . repeat-mode)
  :init
  (setq repeat-exit-key (kbd "C-g")))

(leaf repeat-help
  :hook (repeat-mode-hook . repeat-help-mode)
  :init
  (setq repeat-help-popup-type 'which-key))

;; FIXME shining when move up/down in rg-mode result when display is enabled
(leaf mini-echo
  :hook (after-init-hook . mini-echo-mode)
  :init
  (setq mode-line-position-column-line-format '("%l:%c,%p"))
  (setq mini-echo-right-padding 2)
  (setq mini-echo-mise-show-always nil)
  (setq mini-echo-persistent-rule
        '(:long ("meow" "shrink-path" "vcs" "buffer-position"
                 "buffer-size" "flymake" "mise" "envrc")
          :short ("meow" "buffer-name" "buffer-position" "flymake")))

  (setq mini-echo-persistent-function #'my/mini-echo-persistent-detect)
  (defun my/mini-echo-persistent-detect ()
    (with-current-buffer (current-buffer)
      (pcase major-mode
        ((guard (bound-and-true-p atomic-chrome-edit-mode))
         '(:both ("meow" "atomic-chrome" "buffer-name" "buffer-position" "flymake")))
        ((guard (or (memq major-mode '(git-commit-elisp-text-mode git-rebase-mode))
                    (string-match-p "\\`magit-.*-mode\\'" (symbol-name major-mode))))
         '(:both ("meow" "major-mode" "project")))
        ((guard (and (fboundp 'popper-display-control-p)
                     (popper-display-control-p (current-buffer))))
         '(:both ("meow" "popper")))
        ('profiler-report-mode '(:both ("meow" "major-mode" "profiler-report")))
        ('rg-mode '(:both ("meow" "major-mode")))
        ('diff-mode '(:both ("meow" "major-mode")))
        ('ibuffer-mode '(:both ("meow" "major-mode")))
        ('dired-mode '(:both ("meow" "major-mode" "dired")))
        ('helpful-mode '(:both ("meow" "major-mode" "helpful")))
        ('treesit--explorer-tree-mode '(:both ("meow" "major-mode" "treesit-explorer")))
        ('xwidget-webkit-mode '(:both ("meow" "major-mode" "xwidget")))
        (_ nil))))
  )

;; (leaf breadcrumb
;;   :hook (after-init-hook . breadcrumb-mode))

;; TODO matrix screensaver
(leaf insecure-lock
  :bind
  ("s-q" . insecure-lock-enter)
  :init
  (setq insecure-lock-require-password nil)
  (setq insecure-lock-mode-hook '(insecure-lock-redact-with-minibuf insecure-lock-posframe))
  (defun insecure-lock-redact-with-minibuf ()
    "`insecure-lock' module that redacts buffers.
No changes in mode-line."
    (unless (require 'redacted nil t) (user-error "Package `redacted' not available"))
    (let ((arg (if insecure-lock-mode 1 -1)))
      (dolist (frame (frame-list))
        ;; NOTE call redacted-mode also in minibuf
        (dolist (window (window-list frame t))
          (with-current-buffer (window-buffer window)
            (redacted-mode arg)))))))

(leaf page-break-lines
  :hook (after-init-hook . global-page-break-lines-mode)
  :init
  (setq page-break-lines-max-width fill-column))

(provide 'init-ui)
;;; init-ui.el ends here
