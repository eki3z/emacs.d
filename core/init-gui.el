;;; init-gui.el --- summary -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>
;; Created: 2022-04-15 13:51:24

;;; Commentary:

;;; Code:

;; (leaf exec-path-from-shell
;;   :hook (after-make-graphic-frame-hook . exec-path-from-shell-initialize))

;; REQUIRE pip3 install my-cookies
;; (leaf leetcode
;;   :init
;;   (setq leetcode-prefer-language "javascript"
;;         leetcode-prefer-sql "mysql"
;;         leetcode-save-solutions t
;;         leetcode-directory "~/Documents/repo/leetcode"))

;; REQUIRE npm install -g @mermaid-js/mermaid-cli
(leaf mermaid-mode)

(leaf org-mordern)

(provide 'init-gui)
;;; init-gui.el ends here
