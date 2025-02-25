;;; init-highlight.el --- highlight setting -*- lexical-binding: t no-byte-compile: t -*-
;;; Commentary:
;;; Code:

(leaf colorful-mode
  :hook
  (after-init-hook . global-colorful-mode)
  (colorful-mode-hook . colorful-mode-setup)
  :init
  (setopt css-fontify-colors nil)
  (setopt colorful-use-prefix t
          colorful-only-strings t
          ;; black medium square
          colorful-prefix-string "\u25FC"
          colorful-allow-mouse-clicks nil)
  (setopt colorful-extra-color-keyword-functions
        '((emacs-lisp-mode . colorful-add-color-names)
          ((mhtml-mode html-ts-mode css-mode css-ts-mode) .
           (colorful-add-hsl-colors colorful-add-color-names))
          (latex-mode . colorful-add-latex-colors)
          colorful-add-hex-colors colorful-add-rgb-colors))

  ;; TODO support tailwindcss
  (defun colorful-add-tailwind-colors ())

  (defun colorful-mode-setup ()
    "colorful-mode setup."
    (when (memq major-mode '(css-mode css-ts-mode sass-mode scss-mode))
      (setq-local colorful-only-strings nil)))

  )

(leaf rainbow-delimiters
  :hook (prog-mode-hook . rainbow-delimiters-mode)
  :init
  (setq rainbow-delimiters-max-face-count 5))

;; FIXME only show overlays on selected-window
;; window-selection-change-functions
(leaf highlight-parentheses
  :hook
  ((prog-mode-hook helpful-mode-hook) . highlight-parentheses-mode)
  (minibuffer-setup-hook . highlight-parentheses-minibuffer-setup)
  :init
  (setq highlight-parentheses-delay 0.05
        highlight-parentheses-highlight-adjacent t
        highlight-parentheses-colors nil
        highlight-parentheses-attributes '((:inverse-video t :weight bold))))

;; Syntax highlighting of known Elisp symbols
(leaf highlight-defined
  :init (setq highlight-defined-face-use-itself t))

;; BUG conflict with meow in cursor shape
(leaf diff-hl
  :hook (after-init-hook . global-diff-hl-mode)
  :init
  (setq diff-hl-draw-borders nil
        diff-hl-ask-before-revert-hunk nil
        diff-hl-show-staged-changes nil
        diff-hl-side 'left)

  :defer-config

  (leaf diff-hl-margin
    :hook (global-diff-hl-mode-hook . diff-hl-margin-mode)
    :init
    ;; SEE https://symbl.cc/en/unicode/blocks/block-elements/
    ;; (char-to-string ?\x258d) => "▍" , ?\x2588 - 258f
    ;; if font is designed for chinese,then use ?\x258f, or use ?\x258d instead.
    (setq diff-hl-margin-symbols-alist
          '((insert  . "\x258f")
            (delete  . "\x258f")
            (change  . "\x258f")
            (unknown . "\x258f")
            (ignored . "\x258f"))))

  (leaf diff-hl-dired
    :hook (dired-mode-hook . diff-hl-dired-mode-unless-remote))

  (leaf diff-hl-flydiff
    :hook (diff-hl-mode-hook . diff-hl-flydiff-mode))

  ;; Integration with magit
  (with-eval-after-load 'magit
    (add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
    (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)))

;; SEE https://github.com/jdtsmith/indent-bars.git
;; (leaf indent-bars
;;   :hook (prog-mode-hook . indent-bars-mode)
;;   :init
;;   (setq
;;    indent-bars-pattern "."
;;    indent-bars-width-frac 0.5
;;    indent-bars-pad-frac 0.25
;;    indent-bars-color-by-depth nil
;;    indent-bars-highlight-current-depth '(:face default :blend 0.4)))

(provide 'init-highlight)
;;; init-highlight.el ends here
