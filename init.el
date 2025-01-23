;;; init.el --- init startup  -*- lexical-binding: t no-byte-compile: t -*-
;;; Commentary:
;;; Code:


;;; Debug
;; (setq debug-on-error t)
;; (debug-on-entry 'load-file)


;;; Warning

;; add user config dir to load-path
(add-to-list 'load-path (expand-file-name "core/" user-emacs-directory))

(require 'init-define)

;; ensure dir exists
(dolist (dir `(,my/dir-cache
               ,my/dir-lib
               ,my/dir-ext
               ,my/dir-debug))
  (make-directory dir t))

(unless emacs/>=29.1p
  (error "Please upgrade your emacs-version above 29 !"))

;; surpress warning
(setq byte-compile-warnings '(not docstrings free-vars obsolete))
(dolist (func '(define-minor-mode))
  (advice-add func :around #'ad/silent-message))

;; load custom.el if exists.
(setq custom-file (expand-file-name "etc/custom.el" my/dir-cache))
(when (file-exists-p custom-file)
  (load custom-file nil :no-message))

;; load private info if exists
(setq private-file (expand-file-name "etc/private.el" my/dir-cache))
(when (file-exists-p private-file)
  (load private-file nil :no-message))

(defun temp-log (msg)
  (with-current-buffer (get-buffer-create " *temp-log*")
    (unless (derived-mode-p 'special-mode)
      (special-mode))
    (goto-char (point-max))
    (let ((inhibit-read-only t))
      (insert msg)
      (newline 2))))

(defun my/load-features (&rest features)
  "Loading FEATURES and print log if error happens."
  (dolist (f features)
    (condition-case err
        (require f)
      (t (temp-log (format "%s\n%-10s: %s\n%-10s: %s"
                           (propertize "[init-require-feature]" 'face 'error)
                           "feature" (symbol-name f)
                           "error" (error-message-string err)))))))


;;; Loading

(with-temp-message ""
  (my/load-features 'init-bootstrap)
  (if (my/debug-begin-p)
      (my/load-features 'init-debug)
    (my/load-features
     ;;; normal loading
     'init-builtin
     ;;; ui
     'init-gui
     'init-icon
     'init-font
     'init-duplexer
     'init-meow
     'init-minibuffer
     'init-dired
     'init-combobulate
     'init-consult
     'init-embark
     'init-outline
     ;; 'init-citre
     'init-yas
     'init-bridge
     ;; 'init-corfu
     ;; 'init-lsp
     'init-ui
     'init-theme
     'init-highlight
     'init-window
     'init-ibuffer
     'init-undo
     'init-edit
     'init-jump
     'init-pair
     'init-diff
     'init-spell
     'init-tool
     'init-passwd
     'init-package
     'init-benchmark
     'init-color
     ;;; engineering
     'init-ide
     'init-flymake
     'init-format
     'init-vcs
     'init-reader
     'init-project
     ;; 'init-projectile
     ;;; langs
     'init-treesit
     'init-lang
     'init-elisp
     'init-web
     'init-vue
     ;; 'init-go
     'init-write
     'init-markdown
     'init-org
     ;; 'init-denote
     'init-key
     'init-env
     )))

;;; init.el ends here
