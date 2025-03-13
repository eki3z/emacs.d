;;; init-treesit.el --- setup for treesit -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>
;; Created: 2024-10-18 05:39:38

;;; Commentary:

;;; Code:

;; ------------------------ Tree-sitter ----------------------------

(leaf treesit
  :init
  ;; debug
  ;; (setq treesit--font-lock-verbose t)

  ;; Use the full theming potential of treesit
  (setq treesit-font-lock-level 4)
  (setq treesit-extra-load-path
        (list (expand-file-name "var/tree-sitter/" my/dir-cache)))

  ;; command to build modules
  (defun treesit-build-modules ()
    "Build all treesit grammars."
    (interactive)
    (let ((default-directory (expand-file-name "tree-sitter-module/" my/dir-lib)))
      (shell-command (concat "INSTALL_DIR=" (car treesit-extra-load-path)
                             " EXTENSION_TAGS=1"
                             " EXTENSION_WIKI_LINK=1"
                             " JOBS=$(nproc) ./batch.sh&")))))

(provide 'init-treesit)
;;; init-treesit.el ends here
