;;; init-dired.el --- dired setting -*- lexical-binding: t no-byte-compile: t -*-
;;; Commentary:
;;; Code:

(leaf dired
  :hook (dired-mode-hook . dired-mode-setup)
  :bind
  (:dired-mode-map
   ("C-c C-p" . wdired-change-to-wdired-mode)
   ;; ("C-c C-z f" . browse-url-of-file)
   ("{" . dired-omit-mode)
   ("}" . dired-hide-details-mode)
   ;; unbind key s to set as prefix
   ("s" . nil))
  :init
  (setq dired-free-space nil
        dired-kill-when-opening-new-dired-buffer t
        dired-recursive-deletes 'always
        dired-recursive-copies 'always)
  (setq dired-dwim-target t)
  (setq dired-movement-style 'cycle)

  (setq dired-no-confirm t
        dired-clean-up-buffers-too t
        dired-clean-confirm-killing-deleted-buffers nil)

  (setq delete-by-moving-to-trash t)

  ;; SEE http://www.nextpoint.se/?p=808
  (defun dired-mark-empty-directories (&optional arg)
    "Mark empty directories.
A prefix argument means to unmark them instead."
    (interactive "P")
    (let ((dired-marker-char (if arg ?\s dired-marker-char)))
      (dired-mark-if
       (when-let* ((dir (dired-get-filename t t)))
         (directory-is-empty-p dir))
       "empty directory")))

  (defun dired-mode-setup ()
    "Dired mode setup."
    (dired-omit-mode)
    (dired-hide-details-mode)
    (diredfl-mode))

  :defer-config
  ;; Use GNU ls as `gls' from `coreutils' if available.
  (when (executable-find "gls")
    (setq dired-use-ls-dired t)
    (setq insert-directory-program "gls")
    ;; do not include any sort options
    (setq dired-listing-switches "-alh --group-directories-first"))

  ;; SEE https://stackoverflow.com/a/38594423 try to define function use defalias
  ;; more sort command
  (defmacro define-dired--sort (sort-by)
    "Define sorting command in dired with SORT-BY and REVERSER."
    (let* ((func-name (intern (concat "dired-sort-by-" sort-by)))
           (func-name-r (intern (concat "dired-sort-by-" sort-by "-reverse")))
           (docstring sort-by)
           (docstring-r (concat sort-by " reversely"))
           (switch (concat (pcase sort-by
                             ("name" "")
                             ((or "size" "version" "extension" "width")
                              (concat "--sort=" sort-by))
                             ((or "mtime" "atime" "ctime" "birth")
                              (concat "--sort=time --time=" sort-by)))))
           (switch-r (concat switch " --reverse"))
           (key (substring sort-by 0 1))
           (key-r (upcase key)))
      `(progn
         (defun ,func-name ()
           ,(concat (format "Sorting files in dired by %s." docstring))
           (declare (modes dired-mode))
           (interactive)
           (dired-sort-other ,(concat dired-listing-switches " " switch)))
         (keymap-set dired-mode-map ,(concat "s " key) #',func-name)
         (defun ,func-name-r ()
           ,(concat (format "Sorting files in dired by %s." docstring-r))
           (declare (modes dired-mode))
           (interactive)
           (dired-sort-other ,(concat dired-listing-switches " " switch-r)))
         (keymap-set dired-mode-map ,(concat "s " key-r) #',func-name-r))))

  (dolist (sort-by '("name" "size" "version" "extension" "width"
                     "mtime" "atime" "ctime" "birth"))
    (eval `(define-dired--sort ,sort-by)))

  )

(leaf dired-aux
  :bind
  (:dired-mode-map
   ("E" . dired-create-empty-file))
  :init
  (setq dired-create-destination-dirs 'always
        dired-create-destination-dirs-on-trailing-dirsep t
        dired-compress-directory-default-suffix t
        dired-vc-rename-file t
        dired-backup-overwrite t
        dired-do-revert-buffer t
        dired-isearch-filenames t)

  (defun my/create-empty-file-multi ()
    "Create multi empty files under directory."
    (interactive)
    (let ((split-string-default-separators ","))
      (if-let* ((files
                 (or (dired-get-marked-files)
                     (->> (read-string "Input new files names(',' as seperator): ")
                          (split-string)
                          (-map #'string-trim)
                          (-remove #'string-empty-p)))))
          (--each files
            (let* ((expanded (expand-file-name it)))
              (if (file-exists-p expanded)
                  (error "Cannot create file %s: file exists" expanded))
              (make-empty-file file 'parents)))
        (message "No files confirmed, operaton cancel.")))))

(leaf dired-x
  :defer-config
  (setq dired-omit-files (concat dired-omit-files "\\|^\\..*$")))

(leaf diredfl
  :defer-config
  (set-face-attribute 'diredfl-dir-name nil :bold t))

(leaf dirvish
  :hook (after-init-hook . dirvish-override-dired-mode)
  :bind
  ("C-x d" . dirvish)
  (:dired-mode-map
   ("["   . dirvish-layout-switch)
   ("]"   . dirvish-layout-toggle)
   ("TAB" . dirvish-toggle-subtree-anywhere))
  :init
  (setq dirvish-attributes
        '(subtree-state nerd-icons collapse file-size)
        dirvish-use-mode-line nil
        dirvish-use-header-line nil
        dirvish-preview-dispatchers nil)

  (defun dirvish-toggle-subtree-anywhere ()
    "Toggle current directory subtree or parent directory."
    (interactive)
    (let ((dir-p (file-directory-p (dired-get-filename))))
      (if (and (not dir-p)
               (equal 0 (dirvish-subtree--depth)))
          (dired-up-directory)
        (and (not dir-p) (dirvish-subtree-up))
        (dirvish-subtree-toggle))))

  ;; TODO fix dired-goto-file if subtree is on.

  :defer-config

  ;; setup layout
  (setq dirvish-default-layout '(0 0 0.75))
  (setq dirvish-layout-recipes
        `((1 0.11 0.55)
          ;; HACK hide preview window as small as possible to imitate full-screen dired
          (0 0 0.02)
          ,dirvish-default-layout))

  (leaf dirvish-subtree
    :init
    (setq dirvish-subtree-listing-switches "-A"
          dirvish-subtree-always-show-state t
          dirvish-subtree-prefix " "))

  (leaf dirvish-icons
    :init
    (setq dirvish-nerd-icons-height 0.8)))

(provide 'init-dired)
;;; init-dired.el ends here
