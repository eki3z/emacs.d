;;; init-markdown.el --- setting for markdown -*- lexical-binding: t no-byte-compile: t -*-

;;; Commentary:

;; SEE https://github.com/seagle0128/.emacs.d/blob/master/lisp/init-markdown.el

;;; Code:

(leaf md
  :mode ("\\.md\\'" . md-ts-mode)
  :hook (md-ts-mode-hook . md-toc-mode)
  :init
  (setq md-ts-mode-fontify-fenced-blocks-natively t))

;; REQUIRE pip install grip colorama
(leaf grip-mode
  :commands grip-start-preview
  :defer-config
  ;; BUG lose md code block background
  (setq grip-preview-use-webkit t))

(leaf xwidget
  :commands xwidget-webkit-current-session)

(provide 'init-markdown)

;;; init-markdown.el ends here
