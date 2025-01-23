;;; init-flymake.el --- Config for lint -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>
;; Created: 2023-08-01 17:01:50

;;; Commentary:

;;; Code:

(leaf flymake
  :hook ((prog-mode-hook
          markdown-mode-hook
          yaml-ts-mode-hook
          web-vue-mode-hook) . flymake-mode)
  :init
  (setq flymake-indicator-type nil
        flymake-margin-indicator-position nil
        flymake-fringe-indicator-position nil
        flymake-no-changes-timeout 20))

(leaf flymake-collection
  :hook (after-init-hook . flymake-collection-hook-setup)
  :init
  ;; REQUIRE
  ;; pip install ruff-lsp yamllint
  ;; brew install shellcheck tidy-html5 jq
  ;; gem install mdl
  ;; luarocks install luacheck
  ;; npm install -g less
  (setq flymake-collection-hook-config
        '(((python-ts-mode python-mode) .
           (flymake-collection-ruff
            (python-flymake :disable t)))
          ((sh-mode bash-ts-mode) .
           (flymake-collection-shellcheck
            (sh-shellcheck-flymake :disabled t)))
          ((yaml-mode yaml-ts-mode) .
           flymake-collection-yamllint)
          ;; REQUIRE brew install tidy-html5
          ((web-mode html-ts-mode mhtml-mode html-mode) .
           (flymake-collection-html-tidy))
          ;; ((js-mode js-ts-mode typescript-mode typescript-ts-mode web-vue-mode
          ;;           typescript-tsx-mode) .
          ;; (flymake-collection-eslint))
          ((json-mode json-ts-mode) flymake-collection-jq)
          ((markdown-mode gfm-mode) flymake-collection-markdownlint)
          (c-ts-mode flymake-collection-clang)
          ((lua-mode lua-ts-mode) flymake-collection-luacheck)
          ((ruby-mode ruby-ts-mode) . (flymake-collection-rubocop))
          (sql-mode flymake-collection-sql-lint)
          (nxml-mode flymake-collection-xmllint)
          (less-mode flymake-collection-less))))

(leaf flymake-collection-clang
  :defer-config
  (appendq! flymake-collection-clang-args '("-Wno-gnu")))

(leaf flymake-relint
  :hook ((emacs-lisp-mode-hook lisp-interaction-mode-hook) . flymake-relint-setup))

(leaf flymake-bridge
  :hook (lsp-bridge-mode-hook . flymake-bridge-setup))

(provide 'init-flymake)
;;; init-flymake.el ends here
