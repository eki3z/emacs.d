;;; init-elisp.el --- Emacs lisp settings -*- lexical-binding: t no-byte-compile: t -*-
;;; Commentary:
;;; Code:

(leaf ielm
  :bind
  (:inferior-emacs-lisp-mode-map
   ("C-l" . comint-clear-buffer))
  :init
  (setq ielm-noisy nil))


(leaf elisp-mode
  :hook (emacs-lisp-mode-hook . elisp-mode-setup)
  :init
  ;; define imenu regexp for elisp-mode
  (defun elisp-imenu-regexp-generate (item)
    "docstring"
    (list (nth 0 item)
          (concat "^\\s-*(" (regexp-opt (nth 1 item) t)
                  "\\s-+\\(" (rx lisp-mode-symbol)
                  (or (nth 2 item) "\\)")
                  ) 2))

  (setq my/elisp-iemnu-generic-expression
        (mapcar #'elisp-imenu-regexp-generate
                '(("Leafs" ("leaf"))
                  ("Customs" ("defcustom"))
                  ("Faces" ("defface"))
                  ("Commands" ("defun" "cl-defun" "transient-define-suffix")
                   "\\)\\(.*\n\\)+?\\s-*(interactive.*")
                  ("Macros" ("defmacro" "cl-defmacro" "cl-define-compiler-macro"))
                  ("Transients" ("transient-define-prefix" "transient-define-suffix"
                                 "transient-define-infix" "transient-define-argument"))
                  ("Functions"
                   ("defun" "cl-defun" "defun*" "defsubst" "cl-defsubst"
                    "define-inline" "define-advice" "defadvice" "define-skeleton"
                    "define-compilation-mode" "define-minor-mode"
                    "define-global-minor-mode" "define-globalized-minor-mode"
                    "define-derived-mode" "define-generic-mode" "defsetf"
                    "define-setf-expander" "define-method-combination"
                    "defgeneric" "cl-defgeneric" "defmethod" "cl-defmethod"
                    "ert-deftest"))
                  ("Variables" ("defvar" "defconst" "defconstant"
                                "defvar-local" "defvaralias"
                                "defparameter" "define-symbol-macro"))
                  ("Types" ("defgroup" "deftheme" "define-widget" "define-error"
                            "deftype" "cl-deftype" "cl-defstruct" "defstruct"
                            "defclass" "define-condition" "defpackage")))))

  (defun elisp-mode-setup ()
    (setq-local imenu-generic-expression my/elisp-iemnu-generic-expression)))

(leaf simple
  :init
  (setq eval-expression-print-length nil
        eval-expression-print-level nil))

(leaf pp
  :init
  (setq pp-default-function 'pp-28)

  (defun pp-macroexpand-all-expression (expression)
    "Macroexpand EXPRESSION all level and pretty-print its value."
    (interactive
     (list (read--expression "Macroexpand: ")))
    (pp-display-expression (macroexpand-all expression) "*Pp Macroexpand Output*"
                           pp-use-max-width)))

(leaf macroexpand
  :init
  (setq macrostep-expand-in-separate-buffer t
        macrostep-expand-compiler-macros nil))

;; SEE https://github.com/manateelazycat/lsp-bridge/commit/d25a63a1e7cca38fc931bb6ddb52acf590912685
(leaf electric
  :hook (after-init-hook . electric-indent-mode))

;; (leaf aggressive-indent
;;   :hook (emacs-lisp-mode-hook . aggressive-indent-mode))

;; SEE https://emacs-china.org/t/2-3-4/11875/5
(leaf lisp-keyword-indent
  :hook (after-init-hook . lisp-keyword-indent-mode)
  :init (setq lisp-indent-function 'lisp-indent-function))

;; add extra font-lock for elisp
(leaf elispfl
  :after elisp-mode
  :config
  (elispfl-mode)
  (elispfl-ielm-mode))

(leaf eros :hook (after-init-hook . eros-mode))

(leaf elisp-demos
  :commands elisp-demos-find-demo
  :init
  (advice-add 'helpful-update :after #'elisp-demos-advice-helpful-update))

(leaf helpful
  :init
  (setq helpful-switch-buffer-function #'display-buffer
        helpful-max-buffers nil)

  :bind
  ([remap describe-key]      . helpful-key)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-command]  . helpful-command)
  ([remap describe-function] . helpful-callable)
  ([remap describe-symbol]   . helpful-symbol))

;; (leaf dash
;;   :hook (after-init-hook . global-dash-fontify-mode)
;;   :init
;;   (with-eval-after-load 'info-look
;;     (dash-register-info-lookup)))

(leaf info-colors
  :hook (Info-selection-hook . info-colors-fontify-node))

(leaf macrostep
  :init
  (setq macrostep-expand-in-separate-buffer t))

(leaf psearch)

(provide 'init-elisp)
;;; init-elisp.el ends here
