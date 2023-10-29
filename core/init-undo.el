;;; init-undo.el --- Setup undo -*- lexical-binding: t no-byte-compile: t -*-

;; Author: liuyinz <liuyinz95@gmail.com>
;; Created: 2022-12-12 06:52:58

;;; Commentary:

;;; Code:

(leaf undo-fu-session
  :hook (after-init-hook . undo-fu-session-global-mode)
  :init
  (setq undo-fu-session-incompatible-files
        '("/COMMIT_EDITMSG\\'" "/git-rebase-todo\\'")))

(leaf vundo
  :hook (vundo-mode-hook . vundo-mode-setup)
  :init
  (setq vundo-window-max-height 5)
  (defun vundo-mode-setup ()
    (and hl-line-mode (hl-line-mode 'toggle))
    (binky-margin-local-mode -1))
  :bind
  ("C-c u" . vundo)
  (:vundo-mode-map
   :package vundo
   ("l" . vundo-forward)
   ("h" . vundo-backward)
   ("j" . vundo-next)
   ("k" . vundo-previous)))

;; (leaf undo-hl
;;   :hook ((text-mode-hook prog-mode-hook) . undo-hl-mode)
;;   :defer-config
;;   (appendq! undo-hl-undo-commands '(meow-undo meow-redo))
;;   (setq undo-hl-flash-duration 0.15))

(leaf simple
  :init
  (setq undo-no-redo t)

  ;; BUG https://lists.gnu.org/archive/html/bug-gnu-emacs/2022-12/msg01661.html
  ;; jump after inserted text after undo-redo
  (psearch-patch primitive-undo
    (psearch-forward '`(goto-char . ,rest)
                     t (lambda (_ bounds)
                         (when (= psearch-count-current 5)
                           (delete-region (car bounds) (cdr bounds)))
                         t)
                     5))

  )

(provide 'init-undo)
;;; init-undo.el ends here
