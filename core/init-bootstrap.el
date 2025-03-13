;;; init-bootstrap.el --- Bootstrap modules -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>

;;; Commentary:

;;; Code:

(defun benchmark-show-init-time ()
  "Show startup time."
  (message "init completed in %.2fms"
           (* 1000.0 (float-time (time-subtract after-init-time before-init-time)))))
(add-hook 'after-init-hook #'benchmark-show-init-time)

;; --------------------------- borg -------------------------------

(add-to-list 'load-path (expand-file-name "lib/borg" user-emacs-directory))

(setq borg-rewrite-urls-alist
      '(("git@github.com:" . "https://github.com/")
        ("git@gitlab.com:" . "https://gitlab.com/")))
(require 'borg)
(borg-initialize)

;; --------------------------- leaf -------------------------------
;; NOTE
;; `:defer-config' in `leaf' == `:config' in `use-package'
;; `:config' needed to use with `:require'

(setq leaf-enable-imenu-support nil)
(require 'leaf)

;; -------------------------- compile ------------------------------

;; native-comp
(when (featurep 'native-compile)
  ;; if t, auto compile elc to eln
  (setq native-comp-deferred-compilation nil)
  (leaf comp
    :init
    (setq native-comp-speed 2
          native-comp-async-report-warnings-errors nil)))

;; ----------------------- optimization ---------------------------

;; BUG error happens
(leaf benchmark-init
  :require t
  :hook (after-init-hook . benchmark-init/deactivate)
  :init
  (with-eval-after-load 'benchmark-init-modes
    (keymap-set benchmark-init/tree-mode-map
                "t" #'benchmark-init/show-durations-tabulated)
    (keymap-set benchmark-init/tabulated-mode-map
                "t" #'benchmark-init/show-durations-tree))
  (add-hook 'benchmark-init/tabulated-mode-hook #'hl-line-mode))

(leaf gcmh
  :require t
  :init
  (setq gcmh-idle-delay 5
        gcmh-high-cons-threshold #x1000000) ; 16MB
  :config
  (gcmh-mode 1))

(leaf no-littering
  :require t
  :init
  (setq no-littering-etc-directory (expand-file-name "etc/" my/dir-cache)
        no-littering-var-directory (expand-file-name "var/" my/dir-cache))
  :config
  ;; ;; save auto-save file if needed
  ;; (setq auto-save-file-name-transforms
  ;;       `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))

  ;; DISCUSSION https://github.com/emacscollective/no-littering/discussions/164
  (when (fboundp 'lisp-data-mode)
    (prependq! auto-mode-alist
               `((,(concat (regexp-quote no-littering-etc-directory) ".*\\.el\\'")
                  . lisp-data-mode)
                 (,(concat (regexp-quote no-littering-var-directory) ".*\\.el\\'")
                  . lisp-data-mode))))

  ;; exclude these in recentf
  (with-eval-after-load 'recentf
    (appendq! recentf-exclude
              `(,no-littering-var-directory ,no-littering-etc-directory))))

(leaf llama
  :require t
  :config
  (global-llama-fontify-mode))

;; (defun my/load-default-lib ()
;;   (run-with-timer 3 nil
;;                   (lambda()
;;                     (require 'dash nil t)
;;                     (require 'llama nil t)
;;                     (require 's nil t)
;;                     (require 'f nil t))))
;;
;; (add-hook 'after-init-hook #'my/load-default-lib)

(provide 'init-bootstrap)
;;; init-bootstrap.el ends here
