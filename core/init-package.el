;;; init-package.el --- Setup for emacs package development -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>
;; Created: 2023-11-23 05:06:29

;;; Commentary:

;;; Code:

(leaf package-lint-flymake
  :hook (emacs-lisp-mode-hook . elisp-package-setup)
  :init
  (defvar elisp-flymake-fill-column-excluded
    `(;; package summary
      "^;;; \\([^ ]*\\)\\.el ---[ \t]*\\(.*?\\)[ \t]*\\(-\\*-.*-\\*-[ \t]*\\)?$"
      ;; package require
      "^;;[ \t]+Package-Requires:"
      ;; url in comments or strings
      ,(concat "^"
               "[[:blank:]]*"
               "\\(?:;+\\|\"\\)?"
               "[[:blank:]]*"
               "[a-zA-Z][a-zA-Z0-9\-+.]*://"
               "[][;,/?:@&=+$_.!~*'()#%[:alnum:]-]+"
               "[[:blank:]]*\"?[[:blank:]]*"
               "[[:blank:]]*)*[[:blank:]]*"
               "$")))

  (defun elisp-flymake-fill-column (report-fn &rest _args)
    "A flymake backend to check buffer has no line exceeding `fill-column' in length."
    (save-excursion
      (let ((collected nil)
            (regexp (mapconcat (lambda (x) (concat "\\(?:" x "\\)"))
                               elisp-flymake-fill-column-excluded
                               "\\|")))
        (goto-char (point-min))
        (while (not (eobp))
          (let ((text (buffer-substring-no-properties
                       (line-beginning-position)
                       (line-end-position))))
            (when (and (> (length text) fill-column)
                       (not (string-match-p regexp text)))
              (push (flymake-make-diagnostic
                     (current-buffer)
                     (line-beginning-position)
                     (line-end-position)
                     :note
                     (format "Line length %s exceeded default value (%s)"
                             (current-column)
                             fill-column))
                    collected)))
          (forward-line 1)
          (end-of-line))
        (funcall report-fn (reverse collected)))))

  (defun elisp-package-setup ()
    "Setup flymake backends for elisp package file."
    (when-let* ((filepath (buffer-file-name))
                ((string-prefix-p my/dir-lib filepath))
                ((package-lint-looks-like-a-package-p)))
      (package-lint-flymake-setup)
      ;; (setq-local fill-column 92)
      ;; (add-hook 'flymake-diagnostic-functions #'elisp-flymake-fill-column nil t)
      )))

;; ;; TODO imitate markdown-toc to write a function to convert and update
;; ;; commnetary section to README.md
;; (leaf el2readme

;; )

(leaf license-templates)

(provide 'init-package)
;;; init-package.el ends here
