;;; init-window.el --- window setting -*- lexical-binding: t no-byte-compile: t -*-
;;; Commentary:
;;; Code:

;; SEE https://github.com/cyrus-and/zoom
(leaf zoom
  :init (setq zoom-size '(0.618 . 0.618)))

(leaf shackle
  :hook (after-init-hook . shackle-mode)
  :init
  (setq shackle-default-rule nil)
  (setq shackle-rules
        ;; SEE https://github.com/seagle0128/.emacs.d/blob/320ae719a1acb84c047e94bb6ee3f33e426f7b47/lisp/init-window.el#L204
        '(
          ;; builtin
          (("*Warnings*" "*Messages*") :size 0.3 :align 'below)
          (("*shell*" "*eshell*" "*ielm*") :popup t :size 0.3 :align 'below)
          ("\\*[Wo]*Man.*\\*" :regexp t :popup t :select t :size 0.5 :align 'below)

          ;; third-party
          ;; ("*evil-marks*" :align 'below :size 0.4)

          ("*vterm*" :align 'below :size 0.4)
          ;; ("*quickrun*" :select t :size 0.4 :align 'below)
          ("*Python*" :select t :size 0.4 :align 'below)
          ("*nodejs*" :select t :size 0.4 :align 'below)

          ;; BUG other,no-select
          ;; ("elisp-demos.org" :select nil :other t)

          ("*format-all-errors*" :size 0.3 :align 'below)
          (helpful-mode :other t :select nil)
          (" *Flycheck checkers*" :select t :size 0.3 :align 'below)
          ((flycheck-error-list-mode flymake-diagnostics-buffer-mode)
           :select t :size 0.25 :align 'below)

          ("*rg*" :select t)
          ("\\`\\*edit-indirect .+\\*\\'" :regexp t :popup t :select t :size 0.4 :align 'below)

          ;; ("*Emacs Log*" :size 0.3 :align 'right)
          )))

(add-to-list 'display-buffer-alist
             '("^\\*quickrun"
               (display-buffer-reuse-window
	            display-buffer-in-side-window)
               (reusable-frames . visible)
               (side            . bottom)
               (window-height   . 0.3)))

(add-to-list 'display-buffer-alist
             '("^\\*Emacs Log*"
               (display-buffer-reuse-window
	            display-buffer-in-side-window)
               (reusable-frames . visible)
               (side            . right)
               (window-width    . 0.25)))

;; ------------------------- commands -----------------------------

(defvar toggle-one-window-window-configuration nil
  "The window configuration use for `toggle-one-window'.")

(defun toggle-one-window ()
  "Toggle between window layout and one window."
  (interactive)
  (if (equal (length (cl-remove-if #'window-dedicated-p (window-list))) 1)
      (if toggle-one-window-window-configuration
          (progn
            (set-window-configuration toggle-one-window-window-configuration)
            (setq toggle-one-window-window-configuration nil))
        (message "No other windows exist."))
    (setq toggle-one-window-window-configuration (current-window-configuration))
    (delete-other-windows)))

(provide 'init-window)
;;; init-window.el ends here
