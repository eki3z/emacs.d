;;; init-define.el --- Definition by user -*- lexical-binding: t no-byte-compile: t -*-
;;; Commentary:
;;; Code:


;;; Variables

(defconst my/dir-core
  (expand-file-name "core/" user-emacs-directory)
  "User dir for Emacs configs.")

(defconst my/dir-ext
  (expand-file-name "ext/" user-emacs-directory)
  "User dir for external tools.")

(defconst my/dir-lib
  (expand-file-name "lib/" user-emacs-directory)
  "User dir for submodules.")

(defconst my/dir-cache
  (expand-file-name ".cache/" user-emacs-directory)
  "User dir for recentf,places and so on.")

(defconst my/dir-debug
  (expand-file-name "debug/" my/dir-cache)
  "User dir for minimal debugging config.")

(defconst my/file-debug
  (expand-file-name "debug-default.el" my/dir-debug)
  "Default file for debug.")

(defconst user-home-page
  "https://github.com/eki3z"
  "The Github Page of mine.")

(defconst emacs-preload-features (reverse features)
  "Emacs preload features by default.")

(defconst sys/win32p
  (eq system-type 'windows-nt)
  "Are we running on a WinTel system?")

(defconst sys/linuxp
  (eq system-type 'gnu/linux)
  "Are we running on a GNU/Linux system?")

(defconst sys/macp
  (eq system-type 'darwin)
  "Are we running on a Mac system?")

(defconst sys/mac-x-p
  (and (display-graphic-p) sys/macp)
  "Are we running under X on a Mac system?")

(defconst sys/mac-ns-p
  (eq window-system 'ns)
  "Are we running on a GNUstep or Macintosh Cocoa display?")

(defconst sys/mac-cocoa-p
  (featurep 'cocoa)
  "Are we running with Cocoa on a Mac system?")

(defconst sys/mac-port-p
  (eq window-system 'mac)
  "Are we running a macport build on a Mac system?")

(defconst sys/linux-x-p
  (and (display-graphic-p) sys/linuxp)
  "Are we running under X on a GNU/Linux system?")

(defconst sys/cygwinp
  (eq system-type 'cygwin)
  "Are we running on a Cygwin system?")

(defconst sys/rootp
  (string-equal "root" (getenv "USER"))
  "Are you using ROOT user?")

(defconst emacs/>=30p
  (>= emacs-major-version 30)
  "Emacs is 30 or above.")

(defconst emacs/>=29.1p
  (or emacs/>=30p
      (and (= emacs-major-version 29)
           (>= emacs-minor-version 1)))
  "Emacs is 29.1 or above.")


;;; Macors

(defmacro message! (arg)
  "Echo `ARG' info."
  `(message (concat "[" (symbol-name ',arg) "] >> TYPE: %s , VALUE: %s ")
            (type-of (symbol-value ',arg)) ,arg))

(defmacro time-count! (&rest body)
  "Measure the time (ms) it takes evaluating BODY."
  `(let ((time (current-time)))
     ,@body
     (* 1000.0 (float-time (time-since time)))))

(defmacro appendq! (sym &rest lists)
  "Append LISTS to SYM in place."
  `(setq ,sym (append ,sym ,@lists)))

(defmacro prependq! (sym &rest lists)
  "Prepend LISTS to SYM in place."
  `(setq ,sym (append ,@lists ,sym)))

(defmacro alist-set! (sym alist)
  "For each element of ALIST, add or replace it in SYM.
Add the element to SYM when there is no match whose `car' equals element's
`car'.  Replace the element in SYM when there is match."
  `(mapc (lambda (x) (setf (alist-get (car x) ,sym) (cdr x))) ,alist))

(defmacro run-general! (fn-r fn)
  "Expand as one command to rule all.
FN-R : region function, FN: default function"
  `(if (use-region-p)
       (funcall ',fn-r (region-beginning) (region-end))
     (funcall ',fn)))

(defmacro defun-mixed! (func-name thing-type prompt body)
  ""
  `(defun ,func-name ()
     (interactive)
     (let* ((sym-here (thing-at-point ',thing-type t))
            (default-val
             (if sym-here
                 (format
                  (propertize "(default %s)" 'face 'font-lock-doc-face)
                  (propertize sym-here 'face 'font-lock-variable-name-face))
               ""))
            (query (if (use-region-p)
                       (buffer-substring-no-properties
                        (region-beginning)
                        (region-end))
                     (read-string
                      (format "%s %s: " ,prompt default-val)
                      nil nil sym-here))))
       ,body)))


;;; Functions

(defvar minor-fallback-alist
  '((read-only-mode . buffer-read-only)
    (save-place-local-mode . save-place-mode)))

(defun minor-mode-p (mode)
  "Return t if MODE is a minor mode."
  (and (functionp mode)
       (progn
         (when (autoloadp (symbol-function mode))
           (load (cdr (find-function-library mode)) nil t))
         (memq (or (alist-get mode minor-fallback-alist) mode) minor-mode-list))))

(defun feature-preload-p (feature)
  "Return non-nil if FEATURE is pre-loaded by default."
  (and emacs-preload-features
       (memq feature emacs-preload-features)))

(defun my/major-mode-list ()
  "Return major mode list."
  (mapcar #'symbol-name
          (seq-filter #'commandp
                      (seq-uniq (map-values auto-mode-alist)))))

(defun adjust-font-family-buffer-local (font-family)
  "Set FONT-FAMILY in current buffer only."
  (interactive (list (completing-read "font family:" (font-family-list))))
  (setq buffer-face-mode-face `(:family ,font-family))
  (buffer-face-mode))

;; TODO write buffer-info-dispatch to show, copy and change buffer status
;; Dos2Unix/Unix2Dos
(defun dos2unix ()
  "Convert the current buffer to UNIX file format."
  (interactive)
  (set-buffer-file-coding-system 'undecided-unix nil))

(defun unix2dos ()
  "Convert the current buffer to DOS file format."
  (interactive)
  (set-buffer-file-coding-system 'undecided-dos nil))

(defun delete-carrage-returns ()
  "Delete `^M' characters in the buffer.
Same as `replace-string C-q C-m RET RET'."
  (interactive)
  (save-excursion
    (goto-char 0)
    (while (search-forward "\r" nil :noerror)
      (replace-match ""))))


;; File and buffer

(defun my/temp-file (suffix)
  "Switch to temp file with SUFFIX."
  (interactive
   (list (read-string "Select file kind : ")))
  (let ((file-name (expand-file-name (concat "Temp/temp." suffix) my/dir-cache)))
    (with-current-buffer (find-file file-name)
      (delete-region (point-min) (point-max)))))

(defun revert-this-buffer ()
  "Revert the current buffer."
  (interactive)
  (unless (minibuffer-window-active-p (selected-window))
    (revert-buffer t t)
    (message "Reverted this buffer")))

(defun delete-both ()
  "Delete the current file, and kill the buffer."
  (interactive)
  (unless (buffer-file-name)
    (error "No file is currently being edited"))
  (when (yes-or-no-p (format "Really delete '%s'?"
                             (file-name-nondirectory buffer-file-name)))
    (delete-file (buffer-file-name))
    (kill-this-buffer)))

(defun rename-both (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (unless filename
      (error "Buffer '%s' is not visiting a file!" name))
    (progn
      (when (file-exists-p filename)
        (rename-file filename new-name 1))
      (set-visited-file-name new-name)
      (rename-buffer new-name))))

(defun rename-this-file (new-name)
  "Renames current file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((filename (buffer-file-name)))
    (unless filename
      (error "Buffer '%s' is not visiting a file!" name))
    (when (file-exists-p filename)
      (rename-file filename new-name 1))))

(defun file-absolute-path ()
  "Return visited file absolute-path."
  (interactive)
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (unless filename
      (error "Buffer '%s' is not visiting a file!" name))
    (message "File Path: '%s' " filename)
    (kill-new filename)))

(defun buffer-base-name ()
  "Return buffer name."
  (interactive)
  (let ((name (buffer-name)))
    (message "Buffer name: '%s' " name)
    (kill-new name)))

(defun browse-this-file ()
  "Open the current file as a URL using `browse-url'."
  (interactive)
  (let ((file-name (buffer-file-name)))
    (if (and (fboundp 'tramp-tramp-file-p)
             (tramp-tramp-file-p file-name))
        (error "Cannot open tramp file")
      (browse-url (concat "file://" file-name)))))

(defun copy-file-name ()
  "Copy the current buffer file name to the clipboard."
  (interactive)
  (if-let* ((filename (if (equal major-mode 'dired-mode)
                         default-directory
                       (buffer-file-name))))
      (progn
        (kill-new filename)
        (message "Copied '%s'" filename))
    (message "WARNING: Current buffer is not attached to a file!")))

(defun reload-init-file ()
  "Reload Emacs configurations."
  (interactive)
  (load user-init-file))

(defun save-buffer-as-utf8 (coding-system)
  "Revert a buffer with `CODING-SYSTEM' and save as UTF-8."
  (interactive "zCoding system for visited file (default nil):")
  (revert-buffer-with-coding-system coding-system)
  (set-buffer-file-coding-system 'utf-8)
  (save-buffer))

(defun save-buffer-gbk-as-utf8 ()
  "Revert a buffer with GBK and save as UTF-8."
  (interactive)
  (save-buffer-as-utf8 'gbk))

(defun save-and-kill ()
  "Save and kill current buffer."
  (interactive)
  (let ((kill-buffer-query-functions nil))
    (save-buffer)
    (kill-buffer nil)))

(defun kill-buffer-silently ()
  "Kill current buffer silently."
  (interactive)
  (let ((kill-buffer-query-functions nil))
    (kill-buffer nil)))

(defun ad/silent-message (original &rest args)
  "Silent function `ORIGINAL' message."
  (let ((inhibit-message t)
        (message-log-max nil))
    (apply original args)))

(defun indent-whole-buffer ()
  "Indent whole buffer."
  (interactive)
  (let ((begin (point-min))
        (end (point-max)))
    (indent-region begin end nil)
    (whitespace-cleanup-region begin end)))

(defun indent-dir-files (dir ext)
  "Formatting files with EXT in DIR."
  (interactive (list (read-directory-name "Directory: ")
                     (read-string "File extension: " ".")))
  (let ((bufs (buffer-list))
        (cur (current-buffer)))
    (dolist (file (directory-files-recursively dir ext))
      (find-file file)
      (indent-region (point-min) (point-max))
      (save-buffer)
      (unless (member (get-file-buffer file) bufs)
        (kill-buffer nil)))
    (switch-to-buffer cur)))

(defun toggle-profiler ()
  "Start,stop or report in one command."
  (interactive)
  (if (not (or (profiler-cpu-running-p) (profiler-memory-running-p)))
      (profiler-start 'cpu+mem)
    (profiler-stop)
    (profiler-report)))

(defun cjk-font-setting (font scale)
  "Set cjk `FONT' with `SCALE'."
  (dolist (charset '(kana han symbol cjk-misc bopomofo))
    (set-fontset-font (frame-parameter nil 'font)
                      charset (font-spec :family font))
    (setq face-font-rescale-alist '((font . scale)))))

(defun open-in-other-window (&rest _)
  "Open in other window."
  (switch-to-buffer-other-window (current-buffer)))

(defun tty-frame-list ()
  "Return a list of all tty frames, except the daemon <frame F1>."
  (seq-filter (lambda (f) (frame-parameter f 'tty))
              (frame-list)))

(defun gui-frame-list ()
  "Return a list of all non-child gui frames."
  (seq-filter (lambda (f)
                (and (frame-parameter f 'display)
                     (null (frame-parameter f 'parent-frame))))
              (frame-list)))

(defun shell-command-exit-code-and-output (program &rest args)
  "Run PROGRAM with ARGS and return the exit code and output in a cons."
  (with-temp-buffer
    (cons (apply 'call-process program nil (current-buffer) nil args)
          (buffer-string))))

;; SEE https://www.emacswiki.org/emacs/AsciiTable
(defun ascii-table ()
  "Display basic ASCII table (0 thru 128)."
  (interactive)
  (switch-to-buffer "*ASCII*")
  (erase-buffer)
  (setq buffer-read-only nil)
  (local-set-key "q" 'bury-buffer)
  (save-excursion
    (let ((i -1))
      (insert "ASCII characters 0 to 127.\n\n")
      (insert (apply #'concat (make-list 4 " Char  Oct  Dec  Hex |")) "\n")
      (while (< i 31)
        (insert (format (apply
                         #'concat
                         (make-list 4 (mapconcat
                                       (lambda (pair)
                                         (propertize (car pair) 'face (cdr pair)))
                                       '((" %4s" . font-lock-keyword-face)
                                         (" %4o" . font-lock-comment-face)
                                         (" %4d" . font-lock-variable-name-face)
                                         (" %4x |" . default)))))
                        (single-key-description (setq i (+ 1  i))) i i i
                        (single-key-description (setq i (+ 32 i))) i i i
                        (single-key-description (setq i (+ 32 i))) i i i
                        (single-key-description (setq i (+ 32 i))) i i i)
                "\n")
        (setq i (- i 96))))))


;;; Debug
;;; TODO miniconfig package

(defun my/debug-begin-p ()
  "Return t if mininal debug begin."
  (and (file-exists-p my/file-debug)
       (> (nth 7 (file-attributes my/file-debug)) 0)))

(defun my/debug-begin ()
  "Begin debug with existed config or new one."
  (interactive)
  (my/debug-end)
  (let* ((new my/file-debug)
         (dir (expand-file-name "backup/" my/dir-debug))
         ;; (dir (make-directory (expand-file-name "backup/" my/dir-debug) t))
         (select (and (file-exists-p dir)
                      (not (directory-empty-p dir))
                      (yes-or-no-p "Select existed config? ")))
         (old (and select (condition-case nil
                              (read-file-name "Debug config: " dir "")
                            (quit "")))))
    (if (length> old 0)
        (copy-file old new 'overwrite)
      (make-empty-file new))
    (display-buffer (find-file-noselect new))))

(defun my/debug-add ()
  "Copy selected config to `my/file-debug'."
  (interactive)
  (let* ((f my/file-debug)
         (buf (or (get-file-buffer f)
                  (find-file-noselect f)))
         (pos (save-excursion
                (if (use-region-p)
                    (cons (region-beginning) (region-end))
                  (condition-case _err
                      (while (not (looking-at "(leaf "))
                        (backward-up-list 1))
                    (error nil))
                  (cons (line-beginning-position) (scan-sexps (point) 1)))))
         (str (buffer-substring-no-properties (car pos) (cdr pos))))
    (with-current-buffer buf
      (goto-char (point-max))
      (insert (format "\n%s\n" str))
      (indent-region (point-min) (point-max))
      (emacs-lisp-mode)
      (save-buffer)
      (display-buffer buf))))

(defun my/debug-end ()
  "Exit debug process."
  (interactive)
  (let* ((buf (get-file-buffer my/file-debug))
         (win (get-buffer-window buf)))
    (ignore-errors
      (and buf win (delete-window win))
      (and buf (kill-buffer buf))
      (delete-file my/file-debug))))

(defun my/debug-backup ()
  "Backup minimal config file."
  (interactive)
  (if (my/debug-begin-p)
      (let* ((default-directory (expand-file-name "backup/" my/dir-debug))
             (old my/file-debug)
             (new (condition-case nil
                      (read-from-minibuffer
                       (format "Backup %s to debug-*.el: "
                               (file-name-nondirectory old)))
                    (quit ""))))
        (if (string-empty-p new)
            (message "File name is illegal.")
          (make-directory default-directory t)
          (copy-file old (concat "debug-" new ".el") 1)))
    (message "Debug hasn't begined yet.")))


;;; Hooks

;; SEE https://www.reddit.com/r/emacs/comments/lelbr5/how_to_start_emacsclient_such_that_it_respects_my/gmhbyv7?utm_source=share&utm_medium=web2x&context=3
;; https://github.com/purcell/emacs.d/blob/adf337dfa8c324983e5dc01ed055a34c3cc4a964/lisp/init-frame-hooks.el

;; (defvar after-load-theme-hook nil
;;   "Hook run after a color theme is loaded using `load-theme'.")
;; (defun run-after-load-theme-hook (&rest _)
;;   "Run `after-load-theme-hook'."
;;   (run-hooks 'after-load-theme-hook))
;; (advice-add #'load-theme :after #'run-after-load-theme-hook)

(defun av/update-frame-title-foreground (theme &rest _)
  "Advice for update frame tile foreground when load THEME."
  (when (featurep 'ns)
    (modify-all-frames-parameters
     (list (cons 'ns-appearance
                 ;; FIXME failed on doom-*-themes
                 (or (plist-get (get theme 'theme-properties) :background-mode) 'dark))))))
(advice-add #'load-theme :after #'av/update-frame-title-foreground)

(defvar after-make-console-frame-hook '()
  "Hooks to run after creating a new TTY frame.")

(defvar after-make-graphic-frame-hook '()
  "Hooks to run after creating a new graphic frame.")

(defun my/frame-setup ()
  "Setup for frame related hooks."
  (run-hooks (if (display-graphic-p)
                 'after-make-graphic-frame-hook
               'after-make-console-frame-hook)))
(add-hook 'server-after-make-frame-hook #'my/frame-setup)

(defun my/frame-no-server-setup (frame)
  "Run configured hooks in response to the newly-created FRAME.
Selectively runs either `after-make-console-frame-hooks' or
`after-make-graphic-frame-hooks'"
  (unless (daemonp)
    (with-selected-frame frame
      (my/frame-setup))))
(add-hook 'after-make-frame-functions 'my/frame-no-server-setup)

(defconst my/initial-frame (selected-frame)
  "The frame (if any) active during Emacs initialization.")
(add-hook 'after-init-hook
          (lambda () (when my/initial-frame
                       (my/frame-no-server-setup my/initial-frame))))

(provide 'init-define)
;;; init-define.el ends here
