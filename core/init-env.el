;;; init-env.el --- Environment setup -*- lexical-binding: t no-byte-compile: t -*-

;; Author: liuyinz <liuyinz95@gmail.com>
;; Created: 2023-11-07 15:37:39

;;; Commentary:

;;; Code:

;; write command to add envrc for node
;; for npm/pnpm project
;; create or add path
;; allow envrc
;; (defun my/env-add-path ()
;;   (interactive)
;;
;;   )

(leaf envrc
  :mode ("\\.env\\(rc\\)?\\'" . envrc-file-mode)
  ;; :hook (after-init-hook . envrc-global-mode)
  )

(leaf mise
  :init
  (setq mini-echo-mise-show-always nil)
  :hook (after-init-hook . global-mise-mode))

;; TODO switch envrc/mise accroding to project
;; (defun my/switch-envrc-mise ()
;;   (interactive)
;;   )
(provide 'init-env)
;;; init-env.el ends here
