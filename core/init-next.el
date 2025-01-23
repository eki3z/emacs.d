;;; init-next.el --- for next package dev -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>
;; Created: 2024-06-03 04:24:24

;;; Commentary:

;;; Code:

(add-to-list 'display-buffer-alist
             '("^\\*\\(quickrun\\|Python\\|nodejs\\|ielm\\)\\*$"
               (display-buffer-reuse-window
	            display-buffer-in-side-window)
               (reusable-frames . visible)
               (side            . bottom)
               (window-height   . 0.4)))

(add-to-list 'display-buffer-alist
             '("^\\*vterm\\*\\(<.*>\\)?$"
               (display-buffer-reuse-window
	            display-buffer-in-side-window)
               (reusable-frames . visible)
               (side            . bottom)
               (window-height   . 0.4)))

(defvar next-enabled-modes
  '(vterm-mode quickrun--mode nodejs-repl-mode
               inferior-emacs-lisp-mode
               inferior-python-mode))

(defun next--get-buffers ()
  "Return a list of vterm buffers."
  (--filter (memq (buffer-local-value 'major-mode it)
                  next-enabled-modes)
            (buffer-list)))

(defun next--get-windows ()
  "Return a list of windows display vterm buffers."
  (--filter (memq (buffer-local-value 'major-mode (window-buffer it))
                  next-enabled-modes)
            (window-list nil 'no-minibuf)))

(defun next-toggle ()
  "Toggle to show or hide vterm window."
  (interactive)
  (let* ((bufs (next--get-buffers))
         (win (car (next--get-windows))))
    (cond
     ((not bufs) (vterm-new))
     ((not win) (switch-to-buffer-other-window (car bufs)))
     (t (delete-window win)))))

(defun next-cycle (&optional backward)
  "Cycle the vterm buffer.
If BACKWARD is non-nil, cycle vterms buffers reversely"
  (interactive "P")
  (let* ((bufs (next--get-buffers))
         (win (car (next--get-windows))))
    (cond
     ((not bufs) (vterm-new))
     ((not win) (switch-to-buffer-other-window (car bufs)))
     (t (save-selected-window
          (let* ((order-bufs (-sort #'string-lessp (-map #'buffer-name bufs)))
                 (new-buf
                  (-> (if backward #'1- #'1+)
                      (funcall (-elem-index (buffer-name (window-buffer win)) order-bufs))
                      (mod (length order-bufs))
                      (nth order-bufs))))
            (select-window win)
            (switch-to-buffer new-buf)
            (message "Switch to %S" new-buf)))))))

(defun next-kill ()
  "Kill the vterm buffer which is displayed in frame."
  (interactive)
  (let* ((win (car (next--get-windows)))
         (buf-to-kill (window-buffer win)))
    (if (not win)
        (message "No ide buffer displaying to be killed.")
      (next-cycle 'backward)
      (kill-buffer buf-to-kill))))

;; TODO
;; 1. add comamnd to switch bottom and right
;; 2. split window commadn

(dolist (pair '(("s-t" . next-toggle)
                ("s-u" . vterm-new)
                ("s-i" . next-cycle)
                ("s-d" . next-kill)))
  (keymap-global-set (car pair) (cdr pair)))

(provide 'init-next)
;;; init-next.el ends here
