;;; init-citre.el --- setup for citre -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>
;; Created: 2022-10-02 13:25:59

;;; Commentary:

;;; Code:

(leaf citre
  :init
  (require 'citre-config)
  (setq citre-completion-case-sensitive nil
        citre-default-create-tags-file-location 'global-cache
        citre-use-project-root-when-creating-tags t
        citre-prompt-language-for-ctags-command t))

(provide 'init-citre)
;;; init-citre.el ends here
