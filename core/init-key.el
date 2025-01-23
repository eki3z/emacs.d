;;; init-key.el --- keybinding for all  -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>
;; Created: 2021-11-01 00:06:28

;;; Commentary:

;; SEE https://github.com/magit/transient/wiki
;; SEE https://stackoverflow.com/a/1052296/13194984
;; SEE http://xahlee.info/emacs/emacs/emacs_key_notation_return_vs_RET.html
;; SEE http://xahlee.info/emacs/emacs/keystroke_rep.html
;; SEE https://www.masteringemacs.org/article/mastering-key-bindings-emacs

;;; Code:

(defun my/keyboard-quit ()
  "A general `keyboard-quit'.
The generic `keyboard-quit' does not do the expected thing when
the minibuffer is open.  Whereas we want it to close the
minibuffer, even without explicitly focusing it.

The DWIM behaviour of this command is as follows:

- When the region is active, disable it.
- When a minibuffer is open, but not focused, close the minibuffer.
- When the Completions buffer is selected, close it.
- In every other case use the regular `keyboard-quit'."
  (interactive)
  (cond
   ((region-active-p)
    (keyboard-quit))
   ((derived-mode-p 'completion-list-mode)
    (delete-completion-window))
   ((> (minibuffer-depth) 0)
    (abort-recursive-edit))
   (t
    (keyboard-quit))))

(dolist (pair '(("C-g" . my/keyboard-quit)
                ("M-j" . scroll-other-window)
                ("M-k" . scroll-other-window-down)
                ("M-o" . toggle-one-window)
                ;; vscode style
                ("s-r" . consult-git-grep)
                ("s-p" . my/dir-find-file)
                ("s-/" . newcomment-toggle)))
  (keymap-global-set (car pair) (cdr pair)))

(defvar-keymap my/toggle-map
  :doc "Keymap for toggle commands."
  "o" #'toggle-one-window
  "p" #'toggle-profiler
  "e" #'toggle-debug-on-error
  "t" #'toggle-debug-on-quit
  "F" #'toggle-frame-fullscreen
  "C" #'toggle-truncate-lines
  "W" #'toggle-word-wrap
  "m" #'markdown-toggle-markup-hiding)
(keymap-set mode-specific-map "t" my/toggle-map)

(defvar-keymap my/ide-map
  :doc "Keymap for ide-like commands."
  "r" #'my/run
  "R" #'quickrun-shell
  "f" #'my/format
  ;; test
  "c" #'testrun-nearest
  "n" #'testrun-namespace
  "b" #'testrun-file
  "a" #'testrun-all
  "l" #'testrun-last
  ;; doc
  "h" #'devdocs-at-point
  "H" #'helpful-at-point
  ;; git
  "v" #'vc-msg-show
  "j" #'browse-at-remote
  "J" #'git-link)
(keymap-set mode-specific-map "i" my/ide-map)

(defvar-keymap my/jump-map
  :doc "Keymap for jump commands"
  "f" #'flymake-goto-next-error
  "F" #'flymake-goto-prev-error
  "t" #'hl-todo-next
  "T" #'hl-todo-previous
  "b" #'binky-next-in-buffer
  "B" #'binky-previous-in-buffer
  "d" #'diff-hl-next-hunk
  "D" #'diff-hl-previous-hunk)
(keymap-set mode-specific-map "j" my/jump-map)

;; HACK resolve conflicts with diff-hl-command-help
(with-eval-after-load 'diff-hl
  (map-keymap (lambda (_key cmd) (put cmd 'repeat-map 'my/jump-map))
              my/jump-map))

(defvar-keymap ctl-x-7-map
  :doc "Keymap for `transpose-frame' commands"
  :repeat t
  "t" #'transpose-frame
  "i" #'flip-frame
  "o" #'flop-frame
  "r" #'rotate-frame
  "c" #'rotate-frame-clockwise
  "a" #'rotate-frame-anticlockwise)
(keymap-set ctl-x-map "7" ctl-x-7-map)

(defvar-keymap my/edit-map
  :doc "Keymap for structure edit commands."
  ;; isolate
  "a" #'isolate-quick-add
  "d" #'isolate-quick-delete
  "c" #'isolate-quick-change
  "A" #'isolate-long-add
  "D" #'isolate-long-delete
  "C" #'isolate-long-change)
(keymap-set mode-specific-map "e" my/edit-map)

;; (with-eval-after-load 'transient

;; (transient-define-prefix my/transient-buffer ()
;;   "Invoke commands about buffer"
;;   [["Info"
;;     ("N" "Base name" buffer-base-name)
;;     ("A" "Absolute path" file-absolute-path)
;;     ;; ("R" "relative path")
;;     ]
;;    ["Edit"
;;     ("r" "Revert buffer" revert-this-buffer)
;;     ("b" "Rename buffer" rename-buffer)
;;     ("f" "Rename file" rename-this-file)
;;     ("B" "Rename both" rename-both)
;;     ("d" "Delete both" delete-both)
;;     ]
;;    ["Content"
;;     ;; ("u" "change utf")
;;     ("u" "Dos2unix" dos2unix)
;;     ("U" "Unix2dos" unix2dos)]
;;    ])

;; )

(provide 'init-key)
;;; init-key.el ends here
