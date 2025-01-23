;;; init-icon.el --- summary -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>
;; Created: 2024-06-10 15:30:36

;;; Commentary:

;;; Code:

;; REQUIRE brew install font-symbols-only-nerd-font
(leaf nerd-icons
  :init
  (setq nerd-icons-font-family "Symbols Nerd Font Mono"))

(leaf nerd-icons-completion
  :hook (after-init-hook . nerd-icons-completion-mode)
  :init
  (setq nerd-icons-completion-icon-size 0.8)
  :defer-config
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(leaf nerd-icons-ibuffer
  :hook (ibuffer-mode-hook . nerd-icons-ibuffer-mode)
  :init
  (setq nerd-icons-ibuffer-icon-size 0.8)
  (setq nerd-icons-ibuffer-formats
        '((mark " " (icon 2 2)
                " " (name 20 20 :left :elide)
                " " modified read-only locked
                " " (size-h 7 -1 :right)
                " " (mode+ 16 16 :left :elide)
                " " filename-and-process+)
          (mark " " name))))

(leaf nerd-icons-corfu
  :require t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

;; TODO magit
(provide 'init-icon)
;;; init-icon.el ends here

