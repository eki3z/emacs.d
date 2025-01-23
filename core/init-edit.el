;;; init-edit.el --- edit setting -*- lexical-binding: t no-byte-compile: t -*-
;;; Commentary:
;;; Code:

;; --------------------------- Edit -------------------------------

(leaf atomic-chrome
  :hook (after-init-hook . atomic-chrome-start-server)
  :init
  (setq atomic-chrome-create-file-strategy `(,(list (concat my/dir-cache "atomic"))))
  (setq atomic-chrome-buffer-open-style 'full)
  (setq atomic-chrome-auto-remove-file t)
  (setq atomic-chrome-make-file-save-initial-contents t)
  (setq atomic-chrome-url-major-mode-alist
        '(("ramdajs\\.com"           . js-ts-mode)
          ("codesandbox\\.io"        . js-ts-mode)
          ("w3schools\\.com"         . js-ts-mode)
          ("jsfiddle\\.net"          . js-ts-mode)
          ("github\\.com"            . gfm-mode)
          ("gitlab\\.com"            . gfm-mode)
          ("reddit\\.com"            . gfm-mode)
          ("emacs-china\\.org"       . gfm-mode)
          ("stackexchange\\.com"     . gfm-mode)
          ("stackoverflow\\.com"     . gfm-mode)
          ("leetcode\\.com"          . typescript-ts-mode)
          ("typescriptlang\\.org"    . typescript-ts-mode)
          ("react\\.docschina\\.org" . js-jsx-mode)
          ("react\\.dev"             . js-jsx-mode)
          ("play\\.d2lang\\.com"     . d2-ts-mode)))

  :defer-config
  ;; HACK change major mode if website extension is wrong
  (defun atomic-edit-setup ()
    (let ((infos (atomic-chrome-get-info (current-buffer))))
      (when (and buffer-file-name
                 (string= (nth 2 infos) ".js")
                 (string-match-p "react\\.docschina\\.org" (nth 0 infos))
                 (not (eq major-mode 'js-jsx-mode)))
        (js-jsx-mode))))
  (add-hook 'atomic-chrome-edit-mode-hook #'atomic-edit-setup)
  )

(leaf hungry-delete
  :hook (after-init-hook . global-hungry-delete-mode)
  :defer-config (setq-default hungry-delete-chars-to-skip " \t\f\v"))

(leaf pangu-spacing
  :hook ((prog-mode-hook text-mode-hook) . pangu-spacing-mode)
  :init
  (setq pangu-spacing-real-insert-separtor t)
  :defer-config
  (push 'dired-mode pangu-spacing-inhibit-mode-alist))

;; (leaf super-save
;;   :hook (after-init-hook . super-save-mode)
;;   :init
;;   (setq super-save-auto-save-when-idle t
;;         super-save-all-buffers t
;;         super-save-idle-duration 10
;;         super-save-silent t))

(leaf coercion
  :bind-keymap
  ("C-c c" . coercion-command-map))

;; SEE https://www.python.org/dev/peps/pep-0350/#mnemonics
(leaf hl-todo
  :hook (after-init-hook . global-hl-todo-mode)
  :init
  (setq hl-todo-wrap-movement t))

(leaf consult-todo
  :init
  (setq consult-todo-cache-threshold 2)
  (setq consult-todo-narrow
        '((?t . "TODO")
          (?f . "FIXME")
          (?h . "HACK")
          (?k . "WORKAROUND")
          (?r . "REQUIRE")
          (?s . "SEE")
          (?p . "PR")
          (?i . "ISSUE")
          (?c . "DISCUSSION")
          (?n . "NOTE")
          (?x . "XXX")
          (?b . "BUG")
          (?w . "WONTFIX")
          (?d . "DEPRECATED"))))

(leaf edit-indirect
  :commands edit-indirect-buffer-indirect-p
  :init
  (defun my/edit-indirect ()
    "Edit indirectly according to `major-mode'"
    (interactive)
    (pcase major-mode
      ('snippet-mode (yas-edit-elisp-indirect))
      ((or 'markdown-mode 'gfm-mode) (markdown-edit-code-block)))))

(leaf wgrep
  :init
  (setq wgrep-change-readonly-file t)
  (setq wgrep-auto-save-buffer t))

(leaf rg
  :hook (rg-mode-hook . rg-mode-setup)
  :bind
  ("C-c s" . rg-menu)
  (:rg-mode-map
   ("<"    . compilation-first-error)
   (">"    . compilation-last-error)
   ("n"    . compilation-next-error)
   ("p"    . compilation-previous-error)
   ("\C-o" . compilation-display-error)
   ("\C-n" . next-error-no-select)
   ("\C-p" . previous-error-no-select)
   ("M-n"  . rg-next-file)
   ("M-p"  . rg-prev-file)
   ("w"    . rg-forward-history)
   ("b"    . rg-back-history)
   ("R"    . rg-replace)
   ("?"    . rg-menu))

  :init
  (setq rg-ignore-case 'smart
        rg-command-line-flags '("-z" "--pcre2"))

  (defun rg-mode-setup ()
    (goto-address-mode -1))

  :defer-config

  (defun rg-replace (new-str)
    "Replace matched result in rg-mode buffer."
    ;; SEE https://emacs.stackexchange.com/a/72155
    (interactive (list (minibuffer-with-setup-hook
                           (lambda () (set-mark (minibuffer-prompt-end)))
                         (read-string "Rg replace matched string with: "
                                      (pcase-let ((`(,begin . ,length)
                                                   (car rg-match-positions)))
                                        (buffer-substring-no-properties
                                         begin (+ length (marker-position begin))))))))
    (let* ((stop-pos (point))
           (keep-asking t)
           (replace-stop nil)
           (prompt (format "Replace match string with %s: (y,n,q,Q,!,.) ?" new-str))
           (start (or (cl-position-if
                       (lambda(x) (>= x (point)))
                       (mapcar (lambda(x) (+ (marker-position (car x)) (cdr x)))
                               rg-match-positions))
                      (length rg-match-positions)))
           (replaces (nconc (cl-subseq rg-match-positions start)
                            (cl-subseq rg-match-positions 0 start))))
      (wgrep-change-to-wgrep-mode)
      (unwind-protect
          (catch 'quit
            (catch 'stop
              (dolist (cur-match replaces)
                (goto-char (setq stop-pos (car cur-match)))
                (let ((replace-p (not keep-asking)))
                  (when keep-asking
                    (catch 'pass
                      (while-let ((key (single-key-description (read-key prompt) t)))
                        (when (member key '("Q" "q"))
                          (wgrep-abort-changes)
                          (rg-recompile)
                          (throw 'quit nil))
                        (when (member key '("C-g" "ESC" "." "!" "y"
                                            "Y" "SPC" "n" "N" "DEL"))
                          (setq keep-asking (not (string= key "!")))
                          (setq replace-p (member key '("." "!" "y" "Y" "SPC")))
                          (setq replace-stop (member key '("C-g" "ESC" ".")))
                          (throw 'pass nil)))))
                  (when replace-p
                    (let ((begin (marker-position (car cur-match))))
                      (delete-region begin (+ begin (cdr cur-match)))
                      (insert new-str)))
                  (when replace-stop (throw 'stop nil)))))
            (wgrep-finish-edit))
        (goto-char stop-pos))))
  (rg-menu-transient-insert "Rerun" "R" "Replace" #'rg-replace))

;; NOTE command-key [super] couldn't identifiled in emacs -nw
(leaf simpleclip
  :hook (after-init-hook . simpleclip-mode)
  :init
  (setq simpleclip-less-feedback t
        simpleclip-unmark-on-copy t)

  ;; HACK support vterm-mode
  (advice-add 'simpleclip-paste :override #'av/simpleclip-paste)
  (defun av/simpleclip-paste ()
    "Paste the contents of the system clipboard at the point."
    (interactive)
    (let ((str-val (simpleclip-get-contents)))
      (unless str-val
        (error "No content to paste"))
      (cond
       ((eq major-mode 'vterm-mode)
        (let ((inhibit-read-only t))
          (vterm-goto-char (point))
          (cl-letf (((symbol-function 'insert-for-yank) #'vterm-insert))
            (insert-for-yank str-val))))
       (buffer-read-only
        (error "Buffer is read-only"))
       ((derived-mode-p 'term-mode)
        (term-send-raw-string str-val))
       (t
        (when (use-region-p)
          (delete-region (region-beginning) (region-end)))
        (push-mark (point) t)
        (insert-for-yank str-val)))
      (when (and (not (minibufferp))
                 (not simpleclip-less-feedback)
                 (simpleclip-called-interactively-p 'interactive))
        (message "pasted from clipboard"))))
  )

(leaf copy-as-format
  :require t
  :bind
  ("s-C" . simpleclip-copy-as-format)
  :init
  (defun simpleclip-copy-as-format ()
    "Copy the current line or active region and add it to the system clipboard as
GitHub/Slack/JIRA/HipChat/... formatted code.  Format defaults to
`copy-as-format-default'.  The buffer will not be modified.
With a prefix argument prompt for the format."
    (interactive)
    (let* ((text (copy-as-format--extract-text))
           (format (if current-prefix-arg
                       (completing-read "Format: "
                                        (mapcar 'car copy-as-format-format-alist)
                                        nil t "" nil copy-as-format-default)
                     copy-as-format-default))
           (func (cadr (assoc format copy-as-format-format-alist))))
      (when (eq (length text) 0)
        (error "No text selected"))
      (when (not (fboundp func))
        (error "Missing or invalid format function for `%s'" format))
      (simpleclip-set-contents (funcall func text (use-region-p)))
      (setq deactivate-mark t))))

;; TODO write alignment command based-on this library
(leaf delim-col)

(provide 'init-edit)
;;; init-edit.el ends here
