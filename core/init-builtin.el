;;; init-builtin.el --- setting for builtin package  -*- lexical-binding: t no-byte-compile: t -*-

;;; Commentary:
;;; Code:

;; ------------------------- Startup ------------------------------

(setq inhibit-startup-screen t
      inhibit-startup-echo-area-message (user-login-name)
      initial-scratch-message nil
      inhibit-default-init t
      auto-save-list-file-prefix nil)

;; don't load site-start.el
(setq site-run-file nil)
(setq user-full-name "Eki Zhang")
(setq user-mail-address "liuyinz95@gmail.com")

(advice-add #'display-startup-echo-area-message :override #'ignore)

(leaf server
  :hook (after-init-hook . server-or-daemon-setup)
  :init
  (setq server-client-instructions nil)
  (defun server-or-daemon-setup ()
    "Start server if not running."
    (require 'server)
    (unless (or (daemonp) (server-running-p))
      (server-start))))

;; --------------------------- Tui --------------------------------

(leaf which-key
  :hook (after-init-hook . which-key-mode)
  :init
  (setq which-key-show-prefix 'top
        which-key-popup-type 'minibuffer
        which-key-preserve-window-configuration t
        which-key-max-description-length 45
        which-key-dont-use-unicode t
        which-key-idle-delay 0.6
        which-key-idle-secondary-delay 0.2))

(leaf frame
  :init
  (setq blink-cursor-blinks 0)

  ;; HACK menu-bar-mode would called forced before gui-frame in Macos
  (add-hook 'after-make-graphic-frame-hook (lambda () (menu-bar-mode -1)))

  ;; set vertical split bar to "│"
  ;; SEE https://www.reddit.com/r/emacs/comments/5tm9zy/vertical_split_bar/ddnw72f?utm_source=share&utm_medium=web2x&context=3
  (set-display-table-slot standard-display-table 'vertical-border (make-glyph-code ?│))
  ;; use space for wrap line
  ;; SEE https://www.emacswiki.org/emacs/LineWrap
  (set-display-table-slot standard-display-table 'wrap ?\ )
  (set-display-table-slot standard-display-table 'truncation ?\ )

  ;; SEE https://apple.stackexchange.com/a/36947
  (defun ad/enable-tui-fullscreen (fn)
    "Toggle fullscreen with TUI support."
    (if (and (not (display-graphic-p))
             (eq system-type 'darwin))
        (call-process "osascript"
                      nil t nil
                      (expand-file-name "kitty-toggle.scpt" my/dir-ext))
      (funcall fn)))
  (advice-add 'toggle-frame-fullscreen :around #'ad/enable-tui-fullscreen))

(leaf mouse
  :init
  (setq mouse-yank-at-point t))

(leaf xt-mouse
  :init
  (defun my/mouse-setup ()
    "enable mouse and keybindings in eamcs -nw"
    (xterm-mouse-mode)
    (keymap-global-set "<mouse-4>" (lambda ()
                                     (interactive)
                                     (scroll-down 1)))
    (keymap-global-set "<mouse-5>" (lambda ()
                                     (interactive)
                                     (scroll-up 1))))
  (add-hook 'after-make-console-frame-hook #'my/mouse-setup))

(leaf mwheel
  :defer-config
  (setq mouse-wheel-scroll-amount '(1 ((shift) . 1))
        mouse-wheel-progressive-speed nil))

(leaf pixel-scroll
  :hook (after-init-hook . pixel-scroll-precision-mode))

;; ------------------------ Apperance -----------------------------
(leaf paragraphs
  :init
  (setq sentence-end-double-space nil))

(leaf display-line-numbers
  :hook (after-init-hook . global-display-line-numbers-mode)
  :init
  (setq display-line-numbers-grow-only t)

  ;; HACK only display line numbers in selected modes
  (advice-add 'display-line-numbers--turn-on
              :override #'av/display-line-numbers--turn-on)
  (defun av/display-line-numbers--turn-on ()
    (unless (or (minibufferp)
                (memq major-mode '(vterm-mode dired-mode dirvish-directory-view-mode
                                              eshell-mode term-mode))
                (derived-mode-p '(special-mode)))
      (display-line-numbers-mode))))

(leaf hl-line
  :hook
  ((prog-mode-hook text-mode-hook ibuffer-mode-hook rg-mode-hook) . hl-line-mode)
  :init
  (setq hl-line-sticky-flag nil)
  (setq global-hl-line-sticky-flag nil)

  ;; HACK show/hide hl-line-mode according to region is active or not
  (defvar-local hl-line-recover-p nil)
  (add-hook 'post-command-hook #'my/toggle-hl-line-with-selection)
  (defun my/toggle-hl-line-with-selection ()
    "Show or hide hl-line according to whether region is active or not."
    (when (boundp hl-line-mode)
      (when (or
             ;; compatiable with region selection
             (and mark-active hl-line-mode)
             (and (not mark-active)
                  (not hl-line-mode)
                  hl-line-recover-p)
             ;; ;; TODO compatiable with combobulate refactor
             ;; ISSUE https://github.com/mickeynp/combobulate/issues/106
             ;; (and combobulate-refactor--active-sessions hl-line-mode)
             ;; (and (not combobulate-refactor--active-sessions)
             ;;      (not hl-line-mode)
             ;;      hl-line-recover-p)
             )
        (hl-line-mode 'toggle)
        (setq-local hl-line-recover-p (not hl-line-recover-p)))))
  )

;; TODO multiple desktop settings,see
;; https://www.emacswiki.org/emacs/DesktopMultipleSaveFiles
;; https://stackoverflow.com/a/849180/13194984
(leaf desktop
  ;; :hook (after-init-hook . desktop-save-mode)
  :init
  (setq desktop-auto-save-timeout 600
        desktop-restore-frames nil)
  (setq desktop-globals-to-save
        '((comint-input-ring        . 50)
          (compile-history          . 30)
          desktop-missing-file-warning
          (dired-regexp-history     . 20)
          (extended-command-history . 30)
          (face-name-history        . 20)
          (file-name-history        . 100)
          (grep-find-history        . 30)
          (grep-history             . 30)
          (magit-revision-history   . 50)
          (minibuffer-history       . 50)
          (org-clock-history        . 50)
          (org-refile-history       . 50)
          (org-tags-history         . 50)
          (query-replace-history    . 60)
          (read-expression-history  . 60)
          (regexp-history           . 60)
          (regexp-search-ring       . 20)
          register-alist
          (search-ring              . 20)
          (shell-command-history    . 50)
          tags-file-name
          tags-table-list))

  :defer-config
  (defun ad/desktop-time-restore (orig &rest args)
    "Count the restore time in total."
    (message "Desktop: %.2fms restored in TOTAL" (time-count! (apply orig args))))
  (advice-add 'desktop-read :around 'ad/desktop-time-restore)

  (defun ad/desktop-time-buffer-create (orig ver filename &rest args)
    "Count the buffer restored time."
    (message "Desktop: %.2fms to restore %s"
             (time-count! (apply orig ver filename args))
             (when filename
               (abbreviate-file-name filename))))
  (advice-add 'desktop-create-buffer :around 'ad/desktop-time-buffer-create))

(leaf simple
  :init
  (setq next-error-highlight t
        next-error-highlight-no-select t
        next-error-message-highlight t
        kill-whole-line t
        read-extended-command-predicate #'command-completion-default-include-p)
  (setq-default indent-tabs-mode nil)
  ;; SEE https://emacs-china.org/t/emacs29-blinking-cursor/23683
  (setq copy-region-blink-delay 0))

(leaf uniquify
  :init
  (setq uniquify-buffer-name-style 'forward
        uniquify-separator "/"))

;; (leaf display-fill-column-indicator
;;   :hook (after-init-hook . global-display-fill-column-indicator-mode)
;;   :init
;;   ;; use white space character
;;   (setq-default display-fill-column-indicator-character ?\u0020))

;; -------------------------- Buffer ------------------------------

(leaf files
  :init
  (setq auto-mode-case-fold nil
        enable-local-variables :all
        save-silently t
        ;; large-file-warning-threshold nil
        confirm-kill-processes nil
        find-file-suppress-same-file-warnings t
        find-file-visit-truename t)

  ;; ISSUE https://github.com/emacsorphanage/osx-trash/issues/5#issuecomment-882759527
  (setq delete-by-moving-to-trash t)
  (when sys/macp
    (setq trash-directory "~/.Trash"))

  ;; SEE https://emacsredux.com/blog/2022/06/12/auto-create-missing-directories/
  (defun my/auto-create-missing-dirs ()
    (let ((target-dir (file-name-directory buffer-file-name)))
      (unless (file-exists-p target-dir)
        (make-directory target-dir t))))
  (add-to-list 'find-file-not-found-functions #'my/auto-create-missing-dirs)

  (setq make-backup-files nil
        create-lockfiles nil)

  ;; auto-save
  (setq auto-save-default nil
        auto-save-visited-interval 10)
  (setq auto-save-visited-predicate
        (lambda () (and (buffer-modified-p) (not buffer-read-only))))
  (add-hook 'after-init-hook #'auto-save-visited-mode))

(leaf saveplace
  :hook (after-init-hook . save-place-mode)
  :init (setq save-place-limit nil))

(leaf recentf
  :hook (after-init-hook . recentf-mode)
  :init
  (setq recentf-max-saved-items nil
        recentf-auto-cleanup 15
        recentf-exclude
        '("\\.?cache" "-autoloads\\.el\\'" ".cask" "url" "COMMIT_EDITMSG\\'"
          "\\.\\(?:gz\\|gif\\|svg\\|png\\|jpe?g\\|bmp\\|xpm\\)$"
          "\\.?ido\\.last$" "\\.revive$" "/G?TAGS$" "/.elfeed/" "/.Trash/"
          "^/tmp/" "^/private/tmp/" "^/var/folders/.+$" "/share/emacs/.+$" "\\.git/.+$"
          "bookmarks"))

  (defun recentf-prune ()
    "Delete all recentf records which match selected DIRS."
    (interactive)
    (let* ((vertico-sort-function nil)
           (parent-dirs (let (counts)
                          (dolist (path recentf-list)
                            (cl-incf (alist-get
                                      (abbreviate-file-name
                                       (file-name-parent-directory path))
                                      counts 0 nil 'equal)))
                          (mapcar #'car (seq-sort-by #'cdr #'> counts)))))
      (when-let* ((to-prune (completing-read-multiple
                             (format-prompt "Prune recent directories" nil) parent-dirs)))
        (setq recentf-list
              (seq-remove (lambda (file)
                            (seq-some (lambda (pre)
                                        (string-prefix-p pre file))
                                      to-prune))
                          recentf-list)))))

  :defer-config
  ;; auto-cleanup in save/load
  (advice-add 'recentf-save-list :before #'recentf-cleanup)
  (advice-add 'recentf-load-list :after #'recentf-cleanup)

  ;; silent message
  (mapc (lambda (cmd)
          (advice-add cmd :around #'ad/silent-message))
        '(recentf-load-list
          recentf-save-list
          recentf-cleanup)))

(leaf savehist
  :hook (after-init-hook . savehist-mode)
  :init
  (setq savehist-autosave-interval 300
        savehist-additional-variables
        '(mark-ring
          global-mark-ring
          search-ring
          regexp-search-ring
          extended-command-history)))

(leaf minibuffer
  :init
  (setq enable-recursive-minibuffers t)
  (setq completion-category-defaults nil
        completion-category-overrides '((file (styles . (partial-completion)))))

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode))

;; --------------------------- Edit -------------------------------

(leaf subword
  :hook ((prog-mode-hook . subword-mode)
         (minibuffer-setup-hook . subword-mode)))

(leaf delsel
  :hook (after-init-hook . delete-selection-mode))

(leaf whitespace
  :init
  (setq whitespace-style '(face empty trailing))
  (face-spec-set 'whitespace-empty
                 '((((background light))
                    :background "#FF6C6B")
                   (t
                    :background "#FF6C6B"))))

(leaf newcomment
  :init (setq comment-empty-lines t)
  :bind ([remap comment-dwim] . #'newcomment-toggle)
  :defer-config
  (defun newcomment-toggle (n)
    "Toggle the comments."
    (interactive "*p")
    (if (or (use-region-p)
            (save-excursion
              (beginning-of-line)
              (looking-at "\\s-*$")))
        (call-interactively 'comment-dwim)
      (let ((range
             (list (line-beginning-position)
                   (goto-char (line-end-position n)))))
        (comment-or-uncomment-region
         (apply #'min range)
         (apply #'max range))))))

(leaf indent-aux
  :hook (after-init-hook . kill-ring-deindent-mode))

(leaf copyright
  :init (setq copyright-year-ranges t))

(leaf jit-lock
  :init
  (setq jit-lock-defer-time 0
        jit-lock-stealth-time 16))

(leaf face-remap
  :init
  (defun my/text-scale-reset ()
    "Reset the font size of default face to origin value."
    (interactive)
    (text-scale-increase 0)))

(leaf isearch
  :init
  (setq isearch-lazy-count t))

(leaf crm
  :init
  ;; Add prompt indicator to `completing-read-multiple'.
  (defun ad/crm-indicator (args)
    "Set indicater ARGS for multiple read."
    (cons (concat "[*] " (car args)) (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'ad/crm-indicator)

  ;; TODO bind to C-t to select all filtered items at once
  (defun crm-complete-all ()))

;; Don't ask me when kill process buffer
(setq kill-buffer-query-functions
      (remq 'process-kill-buffer-query-function
            kill-buffer-query-functions))

(if (get-buffer "*scratch*")
    (setq default-directory "~/"))

(leaf autorevert
  :hook (after-init-hook . global-auto-revert-mode)
  :init
  (setq auto-revert-interval 3
        auto-revert-use-notify t
        auto-revert-verbose nil))

;; --------------------------- Jump -------------------------------

(leaf xref
  :init
  (setq xref-history-storage 'xref-window-local-history
        xref-search-program 'ripgrep))

(leaf compile
  :defer-config
  (defun compilation-first-error ()
    "Move point to the first error in the compilation buffer."
    (interactive)
    (compilation-next-error 1 nil (point-min)))

  (defun compilation-last-error ()
    "Move point to the last error in the compilation buffer."
    (interactive)
    (compilation-next-error (- 1) nil (point-max)))

  (defun ad/compilation-previous-file (n)
    "Move point at first error when jumping to previous files."
    (interactive "p")
    (compilation-next-file (- n))
    (condition-case nil
        (progn
          (compilation-next-file (- 1))
          (compilation-next-file 1))
      (error
       (compilation-first-error))))
  (advice-add 'compilation-previous-file :override #'ad/compilation-previous-file)

  )

(leaf executable
  :init
  (setq executable-prefix-env t))

;; --------------------------- Tool -------------------------------

(leaf eldoc
  :init
  (setq eldoc-idle-delay 0.3))

(leaf transient
  :require t
  :bind
  (:transient-map
   ("ESC" . transient-quit-one)
   ("<escape>" . transient-quit-one))
  :init
  (setq transient-highlight-mismatched-keys nil
        transient-detect-key-conflicts t)
  (setq transient-show-during-minibuffer-read nil
        transient-hide-during-minibuffer-read t))

(leaf xwidget
  :commands xwidget-webkit-current-session
  :hook (xwidget-webkit-mode-hook . xwidget-setup)
  :init
  (defun xwidget-setup ()
    "docstring"
    (goto-address-mode -1)
    (setq-local header-line-format nil)))

(leaf copyright
  :init
  (setq copyright-year-ranges t
        copyright-query nil)
  ;; TODO write a command to update all liuyinz packages
  )

;; -------------------------- Encode ------------------------------

(define-coding-system-alias 'UTF-8 'utf-8)
(when (fboundp 'set-charset-priority)
  (set-charset-priority 'unicode))
(prefer-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)

;; ------------------------- C source -----------------------------

(setq y-or-n-p-use-read-key t)

(setq source-directory "~/Library/Caches/Homebrew/emacs-head@31--git")

(setq use-short-answers t
      use-file-dialog nil
      use-dialog-box nil
      echo-keystrokes 0.02
      ad-redefinition-action 'accept
      inhibit-compacting-font-caches t
      window-resize-pixelwise t
      frame-resize-pixelwise t
      ring-bell-function 'ignore
      history-length 1000
      history-delete-duplicates t
      word-wrap-by-category t)

(setq-default tab-width 4
              fill-column 85
              fringes-outside-margins t
              fringe-indicator-alist nil
              left-margin-width 1
              right-margin-width 1
              line-spacing 0.15
              default-directory "~")

;; improve performance of long line
;; SEE https://emacs-china.org/t/topic/25811/7
(setq-default bidi-display-reordering nil)
(setq bidi-inhibit-bpa t
      long-line-threshold 1000
      large-hscroll-threshold 1000
      syntax-wholeline-max 1000)

;; SEE https://emacs.stackexchange.com/a/2555/35676;9u
(setq-default major-mode
              (lambda () (if buffer-file-name
                             (fundamental-mode)
                           (let ((buffer-file-name (buffer-name)))
                             (set-auto-mode)))))

;; Increase how much is read from processes in a single chunk (default is 4kb)
(setq read-process-output-max #x10000)  ; 64kb

;; Don't ping things that look like domain names.
(setq ffap-machine-p-known 'reject)


;; ---------------------- disabled command -------------------------

;; disable all commands
;; (setq disabled-command-functions nil)

(defvar disabled-command-list '(set-goal-column help-fns-edit-variable))
(mapatoms (lambda (sym)
            (when (and (commandp sym)
                       (get sym 'disabled)
                       (not (member sym disabled-command-list)))
              (put sym 'disabled nil))))

;; -------------------- library protection ------------------------

(defun lisp-directory-read-only ()
  "Set all built-in library read-only."
  (when (file-in-directory-p buffer-file-name lisp-directory)
    (read-only-mode)))

(add-hook #'find-file-hook #'lisp-directory-read-only)

(provide 'init-builtin)
;;; init-builtin.el ends here
