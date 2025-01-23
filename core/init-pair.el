;;; init-pair.el --- Setup pair editing -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>
;; Created: 2022-12-22 17:28:22

;;; Commentary:

;;; Code:

;; disable show-paren-mode by default
(leaf paren
  :hook (after-init-hook . (lambda () (show-paren-mode -1)))
  :init
  (setq show-paren-style 'parenthesis
        show-paren-delay 0
        show-paren-context-when-offscreen 'overlay))

(leaf elec-pair
  :hook (after-init-hook . electric-pair-mode))

(leaf elec-pair-extra
  :hook (after-init-hook . elec-pair-extra-setup)
  :init
  (setq elec-pair-extra-rules
        '(;; enable <> auto pair for generics<T> in typescript, disable pair
          ;; when following a space
          ;; (typescript-ts-mode
          ;;  :pair ((?\< . ?\>))
          ;;  :inhibit ((?\< . " <")))
          ;; disable pair <> in HTML+JS submode in mhtml-mode
          (mhtml-mode
           :pair nil
           :inhibit ((?\< . (lambda (c)
                              (and (eq major-mode 'js-mode)
                                   (= c ?<)))))))))

(leaf isolate
  :require t
  :defer-config
  (add-hook 'isolate-add-mode-hook #'my/meow-motion-temporary))

(provide 'init-pair)
;;; init-pair.el ends here
