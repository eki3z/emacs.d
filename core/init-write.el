;;; init-write.el --- Writing setup -*- lexical-binding: t no-byte-compile: t -*-

;; Author: liuyinz <liuyinz95@gmail.com>
;; Created: 2022-12-23 07:39:21

;;; Commentary:

;;; Code:

(leaf focus)

(leaf olivetti
  :init
  (setq olivetti-body-width nil
        olivetti-style t))

;; TODO customize easy-hugo-buffer, refactor easy-hugo, tag filter
(leaf easy-hugo
  :init
  (setq easy-hugo-basedir  "~/Code/blog/"
        easy-hugo-postdir "content/posts/"
        easy-hugo-url  "https://liuyinz.github.io/"
        easy-hugo-preview-url "http://localhost:1313/"
        easy-hugo-server-flags "-D"
        easy-hugo-no-help t)
  :defer-config
  (easy-hugo-enable-menu))

(leaf denote
  :init
  (setq denote-file-type 'markdown-yaml)
  (setq denote-known-keywords '("emacs" "javascript" "typescript"
                                "react" "vue" "coding" "web"))
  (setq denote-file-name-letter-casing '((title . verbatim) (t . downcase)))
  :defer-config
  (leaf denote-silo-extras
    :init
    (setq denote-silo-extras-directories `(,denote-directory))))

(leaf denote-rename-buffer
  :hook (after-init-hook . denote-rename-buffer-mode)
  :init
  ;; show denote buffer in title.ext style
  (defun denote-rename-buffer-with-ext (&optional buffer)
    "Rename current buffer or optional BUFFER with denote title and extension."
    (require 'denote)
    (when-let* ((file (buffer-file-name (or buffer (current-buffer))))
                ((denote-file-has-identifier-p file))
                (ext (denote-get-file-extension file))
                ((string-match denote-title-regexp file))
                (new-name (concat (match-string 1 file) ext)))
      (rename-buffer new-name :unique)))
  (setq denote-rename-buffer-function #'denote-rename-buffer-with-ext))

(leaf denote-menu)
(transient-define-prefix denote-dispatch ()
  "denote commands"
  ["Create"
   ("cc" "Default" denote)
   ("cr" "With region" denote-region)
   ("ct" "With template" denote-template)
   ("cn" "With subdirectory" denote-subdirectory)
   ("cy" "With type" denote-type)
   ("cd" "With date" denote-date)
   ("cs" "With signature" denote-signature)]
  ["Update"
   ("ur" "Rename file" denote-rename-file)
   ("uf" "Rename file with front matter" denote-rename-file-using-front-matter)
   ("uk" "Add keyword" denote-keywords-add)
   ("ud" "Remove keyword" denote-keywords-remove)
   ("ua" "Add front matter" denote-add-front-matter)
   ("uc" "Change type and front matter" denote-change-file-type-and-front-matter)]
  ["Link"
   ("lc" "Create link" denote-link)
   ("la" "Add links" denote-add-links)
   ("lf" "Find link" denote-find-link)
   ("lb" "Backlinks" denote-backlinks)
   ("ls" "Find backlink" denote-find-backlink)]
  ["Silo"
   ("sc" "Create" denote-silo-extras-create-note)
   ("so" "Open or create" denote-silo-extras-open-or-create)
   ("sr" "Run command" denote-silo-extras-select-silo-then-command)]
  ["Menu"
   ("ml" "List notes" denote-menu-list-notes)
   ("mf" "Filter notes" denote-menu-filter)
   ("mk" "Filter notes by keyword" denote-menu-filter-by-keyword)
   ("mK" "Exclude notes by keyword" denote-menu-filter-out-keyword)
   ("mc" "Clear filters" denote-menu-clear-filters)
   ("me" "Export to dired" denote-menu-export-to-dired)]
  )

(provide 'init-write)
;;; init-write.el ends here
