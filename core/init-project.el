;;; init-project.el --- Setup project -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>
;; Created: 2022-12-12 07:19:27

;;; Commentary:

;;; Code:

(leaf project
  :require t
  :init
  (setq project-vc-merge-submodules nil)
  (defun my/dir-find-file ()
    "Command to find file in selected directory for `consult-dir'."
    (interactive)
    (call-interactively
     (if (string-prefix-p (file-truename (project-root (project-current t)))
                          (file-truename default-directory))
         #'project-find-file
       #'find-file))))

(leaf consult-project-extra)

(provide 'init-project)
;;; init-project.el ends here
