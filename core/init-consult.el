;;; init-consult.el --- Consult setup -*- lexical-binding: t no-byte-compile: t -*-

;; Author: liuyinz <liuyinz95@gmail.com>
;; Created: 2022-06-12 20:29:21

;;; Commentary:

;;; Code:

(leaf consult
  :after vertico
  :bind
  ;;ctl-x-map
  ("C-x b"   . consult-buffer)
  ("C-x 4 b" . consult-buffer-other-window)
  ("C-x C-d" . consult-dir)
  ("C-x M-:" . consult-complex-command)
  ("C-x r b" . consult-bookmark)
  ;;goto-map
  ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
  ("M-g M-g" . consult-goto-line)
  ("M-g i" . consult-imenu)
  ("M-g I" . consult-imenu-multi)
  ("M-g t" . consult-todo)
  ("M-g e" . consult-compile-error)
  ;;search-map
  ("M-s d" . consult-find)   ;; Alternative: consult-fd
  ("M-s r" . consult-ripgrep)
  ("M-s l" . consult-line)
  ("M-s L" . consult-line-multi)
  ("M-s k" . consult-keep-lines)
  ("M-s e" . consult-isearch-history)
  ("M-s u" . consult-focus-lines)
  (:isearch-mode-map
   ("M-e"   . consult-isearch-history)
   ("M-s e" . consult-isearch-history) ;; orig. isearch-edit-string
   ("M-s l" . consult-line) ;; needed by consult-line to detect isearch
   ("M-s L" . consult-line-multi) ;; needed by consult-line to detect isearch
   )
  ("M-y" . consult-yank-pop)
  ;;mode-specific-map
  ("C-c M-x" . consult-mode-command)

  :init
  (setq consult-async-min-input 1)
  (setq consult-async-split-style 'semicolon)
  (setq consult-line-start-from-top t)

  :defer-config
  (setq-default completion-in-region-function #'consult-completion-in-region)

  ;; Optionally configure the narrowing key.
  (setq consult-narrow-key "<")

  ;; -------------------------- Source ------------------------------

  ;; NOTE
  ;; 1. hidden: add regexp in `consult-buffer-filter' or filter with :predicate
  ;;    in `consult--source-buffer'
  ;; 2. extract: set :filter nil and :predicate in consult--source-*

  (appendq! consult-buffer-filter '("\\`\\*.*\\*\\'"
                                    "\\`.*\\.el\\.gz\\'"
                                    "\\`magit[:-].*\\'"
                                    "\\`COMMIT_EDITMSG\\'"
                                    "\\`.+~.+~\\'"
                                    "\\`\\*vterm\\*.*\\'"))

  ;; enable hidden buffer preview
  (consult-customize consult--source-hidden-buffer :state #'consult--buffer-state)

  ;; filter `consult--source-buffer'
  (consult-customize
   consult--source-buffer
   :items
   (lambda ()
     (consult--buffer-query
      :sort 'visibility
      :as #'buffer-name
      :predicate
      (lambda (buffer)
        (let ((mode (buffer-local-value 'major-mode buffer)))
          (not (eq mode 'dired-mode)))))))

  ;; Dired-source
  (defvar consult--source-dired
    `(:name     "Dired"
      :narrow   ?d
      :hidden   t
      :category buffer
      :face     dired-header
      :state    ,#'consult--buffer-state
      :items
      ,(lambda ()
         (consult--buffer-query
          :mode 'dired-mode
          :filter nil
          :sort 'visibility
          :as #'buffer-name)))
    "Dired buffer candidate source for `consult-buffer'.")
  (add-to-list 'consult-buffer-sources 'consult--source-dired)

  ;; atomic-chrome buffers
  (defvar consult--source-atomic
    `(:name     "Atomic"
      :narrow   ?a
      :hidden   t
      :category buffer
      :face     dired-warning
      :state    ,#'consult--buffer-state
      :items
      ,(lambda ()
         (consult--buffer-query
          :sort 'visibility
          :as #'buffer-name
          :filter nil
          :predicate
          (lambda (buffer)
            (with-current-buffer buffer
              (bound-and-true-p atomic-chrome-edit-mode))))))
    "Atomic buffer candidate source for `consult-buffer'.")
  (add-to-list 'consult-buffer-sources 'consult--source-atomic)

  ;; xwidget buffers
  (defvar consult--source-xwidget
    `(:name     "Xwidget"
      :narrow   ?x
      :hidden   t
      :category buffer
      :face     dired-warning
      :state    ,#'consult--buffer-state
      :items
      ,(lambda ()
         (consult--buffer-query
          :mode 'xwidget-webkit-mode
          :sort 'visibility
          :as #'buffer-name
          :filter nil)))
    "Xwidget buffer candidate source for `consult-buffer'.")
  (add-to-list 'consult-buffer-sources 'consult--source-xwidget)

  ;; Blob-source
  (defvar consult--source-blob
    `(:name     "Blob"
      :narrow   ?g
      :hidden   t
      :category buffer
      :face     transient-pink
      :state    ,#'consult--buffer-state
      :items
      ,(lambda ()
         (consult--buffer-query
          :sort 'visibility
          :as #'buffer-name
          :filter nil
          :predicate
          (lambda (buffer)
            (string-match-p "\\`.+~.+~\\'" (buffer-name buffer))))))
    "Blob buffer candidate source for `consult-buffer'.")
  (add-to-list 'consult-buffer-sources 'consult--source-blob)

  ;; Org-source
  (autoload 'org-buffer-list "org")
  (defvar consult--source-org
    `(:name     "Org"
      :narrow   ?o
      :hidden   t
      :category buffer
      :face     org-headline-todo
      :state    ,#'consult--buffer-state
      :items
      ,(lambda ()
         (consult--buffer-query
          :mode 'org-mode
          :filter nil
          :sort 'visibility
          :as #'buffer-name)))
    "Org buffer candidate source for `consult-buffer'.")
  (add-to-list 'consult-buffer-sources 'consult--source-org)

  ;; ------------------------- Preview ------------------------------

  (setq consult-preview-allowed-hooks '(global-font-lock-mode-check-buffers))

  ;; disable preview
  (consult-customize
   consult-recent-file consult-bookmark consult--source-recent-file
   consult--source-project-recent-file consult--source-bookmark
   consult-ripgrep consult-git-grep consult-grep
   :preview-key nil)

  ;; -------------------------- Extra -------------------------------

  (require 'consult-xref)
  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  (require 'consult-register)
  ;; Optionally configure the register formatting.
  (setq register-preview-delay 0
        register-preview-function #'consult-register-format)

  ;; Integrate with `leaf'
  (require 'consult-imenu)
  (setq consult-imenu-config
        '((emacs-lisp-mode
           :toplevel "Functions"
           :types ((?f "Functions"   font-lock-function-name-face)
                   (?y "Types"       font-lock-type-face)
                   (?v "Variables"   font-lock-variable-name-face)
                   (?c "Commands"    font-lock-constant-face)
                   (?u "Customs"     font-lock-string-face)
                   (?a "Faces"       font-lock-type-face)
                   (?l "Leafs"       font-lock-keyword-face)
                   (?m "Macros"      font-lock-function-name-face)
                   (?k "Keys"        font-lock-variable-name-face)
                   (?t "Transients"  font-lock-type-face)))
          (js-mode
           :types ((?c "Classes"    font-lock-type-face)
                   (?f "Functions"  font-lock-function-name-face)
                   (?s "Constants"  font-lock-constant-face)
                   (?m "Methods"    font-lock-string-face)
                   (?p "Properties" font-lock-builtin-face)
                   (?v "Variables"  font-lock-variable-name-face)
                   (?e "Fields"     font-lock-warning-face)))
          (js-ts-mode
           :types ((?c "Class"      font-lock-type-face)
                   (?f "Function"   font-lock-function-name-face)
                   ;; (?s "Constants"  font-lock-constant-face)
                   ;; (?m "Methods"    font-lock-string-face)
                   ;; (?p "Properties" font-lock-builtin-face)
                   ;; (?v "Variables"  font-lock-variable-name-face)
                   ;; (?e "Fields"     font-lock-warning-face)
                   ))
          (python-mode
           :types ((?c "Classes"    font-lock-type-face)
                   (?f "Functions"  font-lock-function-name-face)
                   (?v "Variables"  font-lock-variable-name-face)))
          (sh-mode
           :types ((?f "Functions"  font-lock-function-name-face)
                   (?v "Variables"  font-lock-variable-name-face)))))

  (leaf consult-dir
    :init
    (setq consult-dir-default-command #'consult-dir-dired)
    :defer-config
    (defvar consult-dir--source-zlua
      `(:name     "Zlua Dir"
        :narrow   ?z
        :category file
        :face     consult-file
        :history  file-name-history
        :enabled  ,(lambda () (getenv "ZLUA_SCRIPT"))
        :items
        ,(lambda ()
           (nreverse (mapcar
                      (lambda (p) (abbreviate-file-name (file-name-as-directory p)))
                      ;; REQUIRE export `ZLUA_SCRIPT' in parent-shell
                      (split-string (shell-command-to-string
                                     "lua $ZLUA_SCRIPT -l | perl -lane 'print $F[1]'")
                                    "\n" t)))))
      "Zlua directory source for `consult-dir'.")
    (add-to-list 'consult-dir-sources 'consult-dir--source-zlua t))

  )

(provide 'init-consult)
;;; init-consult.el ends here
