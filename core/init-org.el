;;; init-org.el --- summary -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang
;; Created: 2021-07-31 17:39:06

;;; Commentary:

;;; Code:

(leaf org
  :init
  (setq org-edit-src-content-indentation 0)
  :defer-config
  (keymap-global-set "C-c l" 'org-store-link)
  (keymap-global-set "C-c a" 'org-agenda)
  (keymap-global-set "C-c c" 'org-capture))

(leaf org-roam
  :init
  (setq org-roam-directory "~/writing/org-roam/"))

(provide 'init-org)
;;; init-org.el ends here
