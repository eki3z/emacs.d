;;; init-meow.el --- modal editing -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>
;; Created: 2022-02-01 15:30:22

;;; Commentary:

;;; Code:

;;; TODO write things with treesit api
(leaf meow
  :hook (vterm-mode-hook . meow-mode)
  :require t
  :init

  ;; HACK to keep consistent with old behaviors
  (setq meow-keypad-leader-dispatch "C-c")

  (defun meow-setup ()
    (meow-normal-define-key
     ;; argument
     '("-" . negative-argument)
     '("q" . meow-quit)

     ;; jump
     '("h" . meow-left)
     '("j" . meow-next)
     '("k" . meow-prev)
     '("l" . meow-right)
     '("b" . meow-back-word)
     '("B" . meow-back-symbol)
     '("e" . meow-next-word)
     '("E" . meow-next-symbol)
     '("f" . meow-find)
     '("t" . meow-till)
     '("z" . meow-goto-line)

     ;; edit
     '("i" . meow-insert)
     '("I" . meow-open-above)
     '("a" . meow-append)
     '("A" . meow-open-below)
     '("c" . meow-change)
     '("C" . meow-change-save)
     '("d" . meow-delete)
     '("D" . meow-backward-delete)
     '("u" . meow-undo)
     '("U" . meow-redo)
     ;; '("U" . meow-undo-in-selection)

     ;; kill-region (cut)
     '("x" . meow-kill)
     '("X" . meow-kill-append)
     ;; kill-ring-save (copy)
     '("y" . meow-save)
     '("Y" . meow-save-append)
     ;; yank (paste)
     '("p" . meow-yank)
     '("P" . meow-yank-pop)
     ;; replace
     '("r" . meow-replace)
     '("R" . meow-replace-save)

     ;; selection
     '("0" . meow-expand-0)
     '("9" . meow-expand-9)
     '("8" . meow-expand-8)
     '("7" . meow-expand-7)
     '("6" . meow-expand-6)
     '("5" . meow-expand-5)
     '("4" . meow-expand-4)
     '("3" . meow-expand-3)
     '("2" . meow-expand-2)
     '("1" . meow-expand-1)
     '(";" . meow-reverse)

     '("H" . meow-left-expand)
     '("J" . meow-next-expand)
     '("K" . meow-prev-expand)
     '("L" . meow-right-expand)
     '("v" . meow-line)
     '("V" . meow-line-expand)
     '("o" . meow-block)
     '("O" . meow-to-block)
     '("T" . meow-join)

     '("g" . meow-cancel-selection)
     '("s" . meow-pop-selection)

     ;; grab
     '("G" . meow-grab)
     '("F" . meow-sync-grab)
     '("S" . meow-swap-grab)
     '("Q" . meow-pop-grab)

     ;; search
     '("n" . meow-search)
     '("N" . meow-visit)
     '("w" . meow-mark-word)
     '("W" . meow-mark-symbol)

     ;; macro
     '("M" . meow-start-kmacro)
     '("m" . meow-end-or-call-kmacro)
     '("Z" . meow-kmacro-lines)

     ;; thing
     '("," . meow-inner-of-thing)
     '("." . meow-bounds-of-thing)
     '("<" . meow-beginning-of-thing)
     '(">" . meow-end-of-thing)

     ;; self-defined
     '("/" . isearch-forward-regexp)
     '("<escape>" . ignore)
     '("'" . binky-binky)
     '("\"" . my/winconf-switch))

    (meow-motion-overwrite-define-key
     '("C-o" . meow-temp-normal)
     '("<escape>" . ignore)
     '("'" . binky-binky)
     '("\"" . my/winconf-switch))

    (meow-leader-define-key
     ;; SPC j/k will run the original command in MOTION state.
     '("j" . "H-j")
     '("k" . "H-k")
     ;; Use SPC (0-9) for digit arguments.
     '("1" . meow-digit-argument)
     '("2" . meow-digit-argument)
     '("3" . meow-digit-argument)
     '("4" . meow-digit-argument)
     '("5" . meow-digit-argument)
     '("6" . meow-digit-argument)
     '("7" . meow-digit-argument)
     '("8" . meow-digit-argument)
     '("9" . meow-digit-argument)
     '("0" . meow-digit-argument)
     '("/" . meow-keypad-describe-key)
     '("?" . meow-cheatsheet)))

  (defvar-local meow--temp-state-before nil)
  (defun my/meow-temp-motion (&optional arg)
    "Switch between meow-motion-mode and meow-normal-mode automatically."
    (interactive "p")
    (when (region-active-p)
      (meow--cancel-selection))
    (if (< arg 0)
        (progn
          (meow--switch-state meow--temp-state-before)
          (setq-local meow--temp-state-before nil))
      (setq-local meow--temp-state-before (meow--current-state))
      (meow--switch-state 'motion)))

  ;; wrapper of meow-redo
  (defvar meow--kbd-undo-redo "C-?"
    "KBD macro for command `undo-redo'.")
  (defun meow-redo ()
    "Cancel current selection then redo."
    (interactive)
    (when (region-active-p)
      (meow--cancel-selection))
    (meow--execute-kbd-macro meow--kbd-undo-redo))

  :defer-config

  (meow-define-keys 'insert
    '("C-j" . meow-open-below)
    '("C-k" . meow-open-above))

  (prependq! meow-mode-state-list
             '((diff-mode . motion)
               (inferior-emacs-lisp-mode . insert)
               (inferior-python-mode . insert)
               (nodejs-repl-mode . insert)
               (quickrun--mode . motion)
               (vterm-mode . insert)
               (term-mode . motion)
               (eshell-mode . insert)
               (lsp-bridge-ref-mode . motion)
               (treesit--explorer-tree-mode . normal)))

  (setq meow-expand-hint-remove-delay 3.0)

  (setq meow-replace-state-name-list
        '((normal . "<N>")
          (motion . "<M>")
          (keypad . "<K>")
          (insert . "<I>")
          (beacon . "<B>")))

  ;; customize thing

  (setq meow-display-thing-help t)
  (setq meow-char-thing-table
        '((?r . round)
          (?s . square)
          (?c . curly)
          (?a . angle)
          (?g . string)
          (?e . symbol)
          (?d . defun)
          (?l . line)
          (?p . paragraph)
          (?b . buffer)
          (?t . tag)
          (?u . url)
          (?w . window)
          (?m . email)))

  (meow-thing-register 'url 'url 'url)
  (meow-thing-register 'email 'email 'email)
  (meow-thing-register 'angle
                       '(pair ("<") (">"))
                       '(pair ("<") (">")))

  ;;; thing for tag
  ;; TODO write for js-jsx-mode and tsx-ts-mode
  ;; (defun jtsx-jsx-element-pos ()
  ;;   "Retun list fo positions of pair tag of current element in `jtsx'."
  ;;   (when-let* (((jtsx-jsx-context-p))
  ;;               (node (jtsx-enclosing-jsx-element-at-point t))
  ;;               (open (treesit-node-child-by-field-name node "open_tag"))
  ;;               (close (treesit-node-child-by-field-name node "close_tag")))
  ;;     (list (treesit-node-start open)
  ;;           (treesit-node-end open)
  ;;           (treesit-node-start close)
  ;;           (treesit-node-end close))))

  (defun web-mode-element-pos ()
    "Retun list fo positions of pair tag of current element in `web-mode'."
    (when-let* ((ele-begin (web-mode-element-beginning-position))
                (ele-end (web-mode-element-end-position)))
      (list ele-begin
            (1+ (web-mode-tag-end-position ele-begin))
            (web-mode-tag-beginning-position ele-end)
            (1+ ele-end))))

  (defun meow--inner-of-tag ()
    (-let [(_ beg end _)
           (pcase major-mode
             ;; ((or 'jtsx-jsx-mode 'jtsx-tsx-mode)
             ;;  (jtsx-jsx-element-pos))
             ('web-mode (web-mode-element-pos))
             (_ nil))]
      (and beg end (cons beg end))))

  (defun meow--bounds-of-tag ()
    (-let [(beg _ _ end)
           (pcase major-mode
             ;; ((or 'jtsx-jsx-mode 'jtsx-tsx-mode)
             ;;  (jtsx-jsx-element-pos))
             ('web-mode (web-mode-element-pos))
             (_ nil))]
      (and beg end (cons beg end))))

  (meow-thing-register 'tag #'meow--inner-of-tag #'meow--bounds-of-tag)

  (meow-setup)
  (meow-global-mode 1)

  (with-eval-after-load 'consult
    (setq meow-goto-line-function #'consult-goto-line))

  ;; HACK disable colorful-mode in meow-grab
  (with-eval-after-load 'colorful-mode
    (defun av/colorful-toggle-on-meow-grab ()
      (when (bound-and-true-p colorful-mode)
        (when (secondary-selection-exist-p)
          (save-excursion
            (font-lock-fontify-region (overlay-start mouse-secondary-overlay)
                                      (overlay-end mouse-secondary-overlay))))
        (when (region-active-p)
          (dolist (ov (overlays-in (region-beginning) (region-end)))
            (when (overlay-get ov 'colorful--overlay)
              (colorful--delete-overlay ov))))))
    (advice-add 'meow-grab :before #'av/colorful-toggle-on-meow-grab)))

;; REQUIRE brew tap laishulu/macism
(leaf sis
  :init
  (defun my/meow-reset-sis (&rest _)
    "Reset english input when not in meow-insert-state."
    (unless meow-insert-mode
      (sis-set-english)))

  ;; Reset when switchshi to non-insert meow-state
  (add-hook 'meow-insert-exit-hook #'sis-set-english)
  ;; Reset when refocus in frame
  (add-function :after after-focus-change-function #'my/meow-reset-sis)
  ;; Reset when change window
  (add-hook 'window-selection-change-functions #'my/meow-reset-sis))

(provide 'init-meow)
;;; init-meow.el ends here
