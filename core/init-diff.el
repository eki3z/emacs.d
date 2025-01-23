;;; init-diff.el --- summary -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>
;; Created: 2024-05-23 16:57:52

;;; Commentary:

;;; Code:

(leaf diff-mode
  :init
  ;; disable smerge-refine with set `diff-refine' to nil
  (setq diff-refine 'navigation))

;; ;; A comprehensive visual interface to diff & patch
;; (leaf ediff
;;   :hook (;; show org ediffs unfolded
;;          ;; (ediff-prepare-buffer . outline-show-all)
;;          ;; restore window layout when done
;;          (ediff-quit-hook . winner-undo))
;;   :init
;;   (setq ediff-window-setup-function 'ediff-setup-windows-plain)
;;   (setq ediff-split-window-function 'split-window-horizontally)
;;   (setq ediff-merge-split-window-function 'split-window-horizontally))

;; adaptive-fill-regexp "[ t]+|[ t]*([0-9]+.|*+)[ t]*"
;; adaptive-fill-first-line-regexp "^* *$"
;; sentence-end "\\([。！？]\\|……\\|[.?!][]\"')}]*\\($\\|[ \t]\\)\\)[ \t\n]*"
;; sentence-end-double-space nil)

(leaf smerge-mode
  :hook (smerge-mode-hook . my/smerge-setup)
  :bind
  (:smerge-basic-map
   ;; move
   ("n" . smerge-vc-next-conflict)
   ("f" . smerge-first)
   ("l" . smerge-last)
   ("x" . smerge-next-file)
   ;; choose
   ("a" . smerge-keep-all)
   ("m" . smerge-keep-upper)
   ("b" . smerge-keep-base)
   ("o" . smerge-keep-lower)
   ("c" . smerge-keep-current)
   ;; diff
   ("SPC" . smerge-conflict-preview-or-scroll)
   ("<"   . smerge-diff-base-upper)
   (">"   . smerge-diff-base-lower)
   ("="   . smerge-diff-upper-lower)
   ("e"   . smerge-ediff)
   ("R"   . smerge-refine)
   ;; edit
   ("s"   . smerge-swap)
   ("C"   . smerge-combine-with-next)
   ("r"   . smerge-resolve)
   ("C-r" . smerge-resolve-all)
   ("u"   . undo)
   ("U"   . undo-redo))
  :init
  (setq smerge-change-buffer-confirm nil
        ;; smerge-command-prefix ""
        smerge-refine-ignore-whitespace nil)

  (defun my/smerge-setup ()
    ;; (my/transient-smerge)
    ;; make sure call `smerge-first' after disable `save-place-local-mode'
    ;; see `add-hook' doc about order
    (smerge-first))

  (defun smerge-first ()
    "Jump to first conflict in the buffer."
    (interactive)
    (goto-char (point-min))
    (unless (looking-at smerge-begin-re)
      (smerge-next)))

  (defun smerge-last ()
    "Jump to first conflict in the buffer."
    (interactive)
    (goto-char (point-max))
    (smerge-prev))

  (defun smerge-conflict-preview-or-scroll ()
    "Preview or scorll conflict region."
    (interactive)
    (smerge-match-conflict)
    (let* ((rev (match-beginning 0))
           (buf (get-buffer "*smerge-preview*"))
           win)
      (unless (and buf (equal rev (buffer-local-value 'orig-rev buf)))
        (copy-to-buffer "*smerge-preview*" (match-beginning 0) (match-end 0))
        ;; SEE https://emacs.stackexchange.com/a/32817
        ;; (with-current-buffer "*smerge-preview*"
        ;;   (set (make-local-variable 'orig-rev) rev))
        (setf (buffer-local-value 'orig-rev buf) rev))
      (if (setq win (get-buffer-window buf))
          (with-selected-window win
            (condition-case nil
                (scroll-up)
              (error
               (goto-char (point-min)))))
        (display-buffer buf nil))))

  (defun smerge-next-file ()
    "Jump to next conflicted file."
    (interactive)
    (vc-find-conflicted-file)
    (smerge-first)
    (smerge-refine 2)))

(provide 'init-diff)
;;; init-diff.el ends here
