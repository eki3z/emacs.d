;;; init-font.el --- font setup -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>
;; Created: 2024-02-09 05:28:51

;;; Commentary:

;;; Code:

(defvar my/default-font "LXGW WenKai Mono Light 17")
(defvar my/chinese-font-family "LXGW WenKai Mono")

;; setup default frame
(add-to-list 'default-frame-alist `(font . ,my/default-font))

;; ;; setup chinese patch
;; (defun my/patch-chinese-charset ()
;;   "Patch chinese character with lxgw font."
;;   `(dolist (charset '(kana han symbol cjk-misc bopomofo))
;;     (set-fontset-font
;;      ;; "fontset-startup"
;;      (frame-parameter nil 'font)
;;      charset
;;      (font-spec :family ,my/chinese-font-family))))
;; (add-hook 'after-make-graphic-frame-hook #'my/patch-chinese-charset)

(provide 'init-font)
;;; init-font.el ends here
