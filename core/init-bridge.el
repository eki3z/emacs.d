;;; init-bridge.el --- Setup for lsp-bridge -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>
;; Created: 2022-07-09 08:07:53

;;; Commentary:

;;; Code:

(leaf lsp-bridge
  :hook (after-init-hook . global-lsp-bridge-mode)
  :bind
  ("M-d" . lsp-bridge-doc-toggle)
  :init
  ;; Setup language
  ;; REQUIRE pthon3 -m pip install epc orjson sexpdata six paramiko ruff-lsp packaging
  (setq lsp-bridge-python-command "python3")
  (setq lsp-bridge-python-multi-lsp-server "basedpyright_ruff")
  (setq lsp-bridge-lua-lsp-server "sumneko")
  (setq lsp-bridge-c-lsp-server "clangd")

  (setq lsp-bridge-enable-inlay-hint t)
  (setq lsp-bridge-enable-completion-in-string t)
  ;; (setq lsp-bridge-completion-in-string-file-types '("vue" "dart"))

  ;; (setq lsp-bridge-completion-popup-predicates nil)
  ;; ;; Debug
  ;; (setq lsp-bridge-enable-log t)
  ;; (setq lsp-bridge-enable-debug t)

  (defun lsp-bridge-doc-toggle ()
    (interactive)
    (if (acm-frame-visible-p lsp-bridge-popup-documentation-frame)
        (acm-hide)
      (lsp-bridge-popup-documentation)))

  :defer-config
  (my/load-features 'init-bridge-detect)

  ;; Setup server
  (setq lsp-bridge-user-langserver-dir
        (expand-file-name "lsp-bridge/single" my/dir-ext))
  (setq lsp-bridge-user-multiserver-dir
        (expand-file-name "lsp-bridge/multi" my/dir-ext))

  (setq lsp-bridge-enable-diagnostics t
        lsp-bridge-disable-backup nil)

  (appendq! lsp-bridge-default-mode-hooks
            '(snippet-mode-hook
              git-commit-mode-hook
              mhtml-mode-hook
              html-mode-hook
              lua-ts-mode-hook
              astro-ts-mode-hook
              js-json-mode-hook
              moonbit-mode-hook))

  ;; FIXME can not detect frame switch between gui and tui, leads to crash.
  (leaf acm
    :bind
    (:acm-mode-map
     ("C-j" . nil)
     ("C-k" . nil)
     ;; ("C-;" . acm-switch-templates)
     )
    :init
    (setq acm-enable-quick-access nil
          acm-enable-tabnine nil
          acm-enable-doc nil)
    (setq acm-candidate-match-function 'orderless-flex)
    ;; yasnippet
    (setq acm-completion-backend-merge-order
          '("template-first-part-candidates"
            "template-second-part-candidates"
            "mode-first-part-candidates"
            "mode-second-part-candidates"))
    (setq acm-backend-yas-candidates-number 3
          acm-backend-yas-match-by-trigger-keyword t
          acm-backend-yas-show-trigger-keyword " [%s]")

    :defer-config

    ;; (require 'acm-backend-lsp-workspace-symbol)
    ;; (setq acm-enable-lsp-workspace-symbol t)

    ;; enable acm cycle style
    (defun ad/acm-select-prev ()
      (interactive)
      (acm-menu-update
       (cond ((> acm-menu-index 0)
              (setq-local acm-menu-index (1- acm-menu-index)))
             ((> acm-menu-offset 0)
              (setq-local acm-menu-offset (1- acm-menu-offset)))
             (t (call-interactively #'acm-select-last)))))
    (advice-add 'acm-select-prev :override #'ad/acm-select-prev)

    (defun ad/acm-select-next ()
      (interactive)
      (acm-menu-update
       (cond ((< acm-menu-index (1- (length acm-menu-candidates)))
              (setq-local acm-menu-index (1+ acm-menu-index)))
             ((< (+ acm-menu-offset acm-menu-index) (1- (length acm-candidates)))
              (setq-local acm-menu-offset (1+ acm-menu-offset)))
             (t (call-interactively #'acm-select-first)))))
    (advice-add 'acm-select-next :override #'ad/acm-select-next)

    ;; ;; TODO write a acm-switch-template
    ;; (defun acm-switch-templates ()
    ;;   "docstring"
    ;;   (interactive))

    ;; FIXME wrapper of `lsp-bridge-toggle-sdcv-helper'
    (defun acm-sdcv-toggle ()
      "docstring"
      (interactive)
      (let ((inhibit-message t))
        (lsp-bridge-toggle-sdcv-helper)
        (acm-update)
        (acm-menu-update)))

    (defun ad/acm-doc-toggle ()
      (interactive)
      (if (acm-frame-visible-p acm-doc-frame)
          (progn
            (acm-doc-hide)
            (setq acm-enable-doc nil))
        (setq acm-enable-doc t)
        (acm-doc-try-show)))
    (advice-add 'acm-doc-toggle :override #'ad/acm-doc-toggle))
  )

(provide 'init-bridge)
;;; init-bridge.el ends here
