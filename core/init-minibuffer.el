;;; init-minibuffer.el --- minibuffer sets -*- lexical-binding: t no-byte-compile: t -*-
;;; Commentary:
;;; Code:

;; SEE https://github.com/purcell/emacs.d/blob/master/lisp/init-minibuffer.el

(leaf vertico
  :hook (after-init-hook . vertico-mode)
  :init
  (setq vertico-cycle t
        vertico-count 20
        resize-mini-windows t)
  :bind
  ("C-c C-r" . vertico-repeat)
  (:vertico-map
   ("RET" . vertico-directory-enter)
   ("DEL" . vertico-directory-delete-char))

  :defer-config

  (leaf vertico-multiform
    :require t
    :config
    (add-to-list 'vertico-multiform-categories
                 '(jinx grid (vertico-grid-annotate . 20)))
    (vertico-multiform-mode 1))

  ;; SEE https://github.com/minad/vertico/wiki#prefix-current-candidate-with-arrow
  (defun ad/vertico-customize-candidate (orig cand prefix suffix index _start)
    (concat (if (= vertico--index index)
                (propertize "> " 'face 'font-lock-warning-face)
              "  ")
            (funcall orig cand prefix suffix index _start)))
  (advice-add 'vertico--format-candidate :around #'ad/vertico-customize-candidate)

  ;; SEE https://github.com/minad/vertico/wiki#left-truncate-recentf-filename-candidates-eg-for-consult-buffer
  (defun my/vertico-truncate-candidates (args)
    (if-let* ((arg (car args))
              (type (get-text-property 0 'multi-category arg))
              ((eq (car-safe type) 'file))
              (w (max 30 (- (window-width) 38)))
              (l (length arg))
              ((> l w)))
        (setcar args (concat ".." (truncate-string-to-width arg l (- l w)))))
    args)
  (advice-add #'vertico--format-candidate :filter-args #'my/vertico-truncate-candidates)
  )

(leaf marginalia
  :hook (vertico-mode-hook . marginalia-mode)
  :defer-config
  (setq marginalia-align 'right
        marginalia-align-offset -1)
  (appendq! marginalia-prompt-categories
            '(("\\<directory\\|directories\\>" . file)))
  )

;; SEE https://github.com/minad/consult/wiki#minads-orderless-configuration
(leaf orderless
  :after vertico
  :require t
  :defer-config
  (setq completion-styles '(orderless basic))
  (setq orderless-component-separator #'orderless-escapable-split-on-space)
  (setq completion-category-defaults nil)

  (orderless-define-completion-style
      my/orderless-mix
    (orderless-matching-styles '(orderless-initialism
                                 orderless-literal
                                 orderless-regexp)))
  (setq completion-category-overrides
        '((file     (styles partial-completion))
          (command  (styles my/orderless-mix))
          (variable (styles my/orderless-mix))
          (symbol   (styles my/orderless-mix))))

  (with-eval-after-load 'consult
    (defun consult--orderless-regexp-compiler (input type &rest _config)
      (let ((input (orderless-pattern-compiler input)))
        (cons
         (mapcar (lambda (r) (consult--convert-regexp r type)) input)
         (lambda (str) (orderless--highlight input t str)))))
    (setq consult--regexp-compiler #'consult--orderless-regexp-compiler))

  (with-eval-after-load 'pinyinlib
    (defun ad/orderless-regexp-pinyin (args)
      "Patch `orderless-regexp' with pinyin surpport"
      (setf (car args) (pinyinlib-build-regexp-string (car args)))
      args)
    (advice-add 'orderless-regexp :filter-args #'ad/orderless-regexp-pinyin))
  )

(provide 'init-minibuffer)
;;; init-minibuffer.el ends here
