;;; init-treesit.el --- setup for treesit -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>
;; Created: 2024-10-18 05:39:38

;;; Commentary:

;;; Code:

;; ------------------------ Tree-sitter ----------------------------

(leaf treesit
  :init
  ;; Use the full theming potential of treesit
  (setq treesit-font-lock-level 4)

  ;; ;; tweak the new funcall face
  ;; (custom-theme-set-faces
  ;;  ;; for current theme
  ;;  (or (car custom-enabled-themes) 'user)
  ;;
  ;;  ;; funcall face
  ;;  `(font-lock-function-call-face
  ;;    ((t :inherit font-lock-function-name-face
  ;;        :foreground "hot pink"
  ;;        :background "black"))))

  (setq treesit-extra-load-path
        (list (expand-file-name "var/tree-sitter/" my/dir-cache)))

  ;; command to build modules
  (defun treesit-build-modules ()
    "Build all treesit grammars."
    (interactive)
    (let ((default-directory (expand-file-name "tree-sitter-module/" my/dir-lib)))
      (shell-command (concat "INSTALL_DIR=" (car treesit-extra-load-path)
                             " JOBS=$(nproc) ./batch.sh&"))))
  )

;; (leaf treesit-auto
;;   :hook (after-init-hook . global-treesit-auto-mode)
;;   :init
;;   (setq treesit-auto-install nil)
;;   (setq treesit-auto-langs
;;         '(bash c c-sharp clojure cmake commonlisp cpp css dart dockerfile elixir
;;                go gomod heex java javascript json julia kotlin lua make
;;                python ruby rust scala sql toml tsx typescript typst vue yaml
;;                ;; BUG
;;                markdown
;;                ;; third-party
;;                jq mermaid zig moonbit
;;                ;; swift doesn't have parser.c
;;                ;; SEE https://github.com/alex-pinkus/tree-sitter-swift?tab=readme-ov-file#where-is-your-parserc
;;                ))
;;
;;   ;; (defun treesit-binary-update ()
;;   ;;   "Update precompiled dylib in treesitter-langs."
;;   ;;   (interactive)
;;   ;;   (call-process "bash" nil nil nil
;;   ;;                 (expand-file-name "treesit-binary-update.sh" my/dir-ext)))
;;
;;   (defun treesit-auto-install-missing (&optional all)
;;     "Install missing grammar in `treesit-auto-langs'.
;; If optional arg ALL if non-nil, reinstall all grammars."
;;     (interactive "P")
;;     (if-let* ((to-install
;;                (or (and all treesit-auto-langs)
;;                    (seq-uniq (cl-remove-if (lambda (lang) (treesit-ready-p lang t))
;;                                            treesit-auto-langs))))
;;               (treesit-language-source-alist (treesit-auto--build-treesit-source-alist)))
;;         (progn
;;           (if all
;;               (message "Reinstall all tree-siiter grammars in treesit-auto-langs.")
;;             (message "The following tree-sitter grammars are/were missing: %s"
;;                      (mapconcat 'symbol-name to-install ", ")))
;;           (mapc 'treesit-install-language-grammar to-install)
;;           (treesit-auto-add-to-auto-mode-alist))
;;       (message "All grammars are installed already.")))
;;   :defer-config
;;   (prependq! treesit-auto-recipe-list
;;              `(,(make-treesit-auto-recipe
;;                  :lang 'jq
;;                  :ts-mode 'jq-ts-mode
;;                  :remap 'jq-mode
;;                  :url "https://github.com/nverno/tree-sitter-jq"
;;                  :ext "\\.jq\\'")
;;                ,(make-treesit-auto-recipe
;;                  :lang 'zig
;;                  :ts-mode 'zig-ts-mode
;;                  :remap 'zig-mode
;;                  :url "https://github.com/maxxnino/tree-sitter-zig"
;;                  :ext "\\.zig\\'")
;;                ;; ,(make-treesit-auto-recipe
;;                ;;   :lang 'swift
;;                ;;   :ts-mode 'swift-ts-mode
;;                ;;   :remap 'swift-mode
;;                ;;   :url "https://github.com/alex-pinkus/tree-sitter-swift"
;;                ;;   :ext "\\.swift\\'")
;;                ,(make-treesit-auto-recipe
;;                  :lang 'mermaid
;;                  :ts-mode 'mermaid-ts-mode
;;                  :remap 'mermaid-mode
;;                  :url "https://github.com/monaqa/tree-sitter-mermaid"
;;                  :ext "\\.\\(mmd\\|mermaid\\)")
;;                ;; ,(make-treesit-auto-recipe
;;                ;;   :lang 'moonbit
;;                ;;   :ts-mode 'moonbit-mode
;;                ;;   :remap 'moonbit-mode
;;                ;;   :url "https://github.com/moonbitlang/tree-sitter-moonbit"
;;                ;;   :ext "\\.mbt\\'")
;;                ))
;;
;;   (treesit-auto-add-to-auto-mode-alist))


(provide 'init-treesit)
;;; init-treesit.el ends here
