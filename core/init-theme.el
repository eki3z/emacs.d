;;; init-theme.el --- config for theme -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>
;; Created: 2024-10-10 01:31:00

;;; Commentary:

;;; Code:

(leaf hl-todo
  :init
  (setq hl-todo-keyword-faces
        '(("TODO"       . "#73daca")
          ("HACK"       . "#bb9af7")
          ("FIXME"      . "#ff9e64")
          ("WORKAROUND" . "#ff9e64")
          ("SEE"        . "#7aa2f7")
          ("REQUIRE"    . "#7aa2f7")
          ("NOTE"       . "#7aa2f7")
          ("PR"         . "#e0af68")
          ("ISSUE"      . "#e0af68")
          ("DISCUSSION" . "#e0af68")
          ("BUG"        . "#f7768e")
          ("XXX"        . "#f7768e")
          ("WONTFIX"    . "#565f89")
          ("DEPRECATED" . "#565f89"))))

(leaf doom-themes
  :require t
  :config
  (load-theme 'doom-tokyo-night t)
  :init
  (advice-add 'load-theme :after #'av/doom-theme-customize)
  (defun av/doom-theme-customize (&rest _)
    (pcase (car custom-enabled-themes)
      ('doom-tokyo-night
       (custom-set-faces
        `(font-lock-operator-face ((t (:foreground ,(doom-color 'teal)))))
        `(font-lock-delimiter-face ((t (:foreground ,(doom-color 'base3)))))
        `(font-lock-number-face ((t (:foreground ,(doom-color 'orange)))))
        `(font-lock-type-face ((t (:foreground ,(doom-color 'yellow) :bold t))))
        `(font-lock-property-name-face ((t (:foreground ,(doom-color 'dark-blue)))))
        `(font-lock-variable-name-face ((t (:foreground ,(doom-color 'dark-cyan)))))
        `(font-lock-escape-face ((t (:foreground ,(doom-color 'magenta)
                                     :bold t))))
        ;; `(font-lock-punctuation-face ((t (:foreground ,(doom-color 'red)))))
        ;; `(font-lock-misc-punctuation-face ((t (:foreground ,(doom-color 'red)))))
        `(font-lock-regexp-face ((t (:foreground ,(doom-lighten (doom-color 'green) 0.8)))))
        `(secondary-selection ((t (:background ,(doom-darken (doom-color 'violet) 0.7)))))
        `(hl-line ((t (:background ,(doom-darken (doom-color 'blue) 0.75)))))
        `(line-number ((t (:italic nil))))
        `(line-number-current-line ((t (:italic nil))))
        ;;consult
        '(consult-file         ((t (:inherit font-lock-doc-face))))
        '(consult-imenu-prefix ((t (:inherit font-lock-doc-face :slant italic))))
        ;; vertico
        `(vertico-current ((t (:background ,(doom-darken (doom-color 'blue) 0.7) :extend t))))
        ;;diff-hl
        `(diff-hl-change ((t (:background unspecified
                              :inverse-video nil
                              :italic nil))))
        `(diff-hl-insert ((t (:background unspecified
                              :inverse-video nil
                              :italic nil))))
        `(diff-hl-delete ((t (:background unspecified
                              :inverse-video nil
                              :italic nil))))
        ;; transient
        `(transient-key-exit ((t (:foreground ,(doom-color 'yellow)))))
        `(transient-key-stay ((t (:foreground ,(doom-color 'green)))))
        `(transient-key-return ((t (:foreground ,(doom-color 'violet)))))
        ;; mini-echo
        `(mini-echo-red ((t (:foreground ,(doom-color 'red)))))
        `(mini-echo-green ((t (:foreground ,(doom-color 'green)))))
        `(mini-echo-yellow ((t (:foreground ,(doom-color 'yellow)))))
        `(mini-echo-blue ((t (:foreground ,(doom-color 'blue)))))
        `(mini-echo-magenta ((t (:foreground ,(doom-color 'magenta)))))
        `(mini-echo-cyan ((t (:foreground ,(doom-color 'cyan)))))
        `(mini-echo-gray ((t (:foreground ,(doom-color 'dark-blue)))))
        ;; meow
        `(meow-normal-indicator   ((t (:foreground ,(doom-color 'blue) :bold t))))
        `(meow-insert-indicator   ((t (:foreground ,(doom-color 'green) :bold t))))
        `(meow-motion-indicator   ((t (:foreground ,(doom-color 'red) :bold t))))
        `(meow-keypad-indicator   ((t (:foreground ,(doom-color 'magenta) :bold t))))
        `(meow-beacon-indicator   ((t (:foreground ,(doom-color 'yellow) :bold t))))
        `(meow-search-indicator   ((t (:foreground ,(doom-color 'cyan) :bold t))))
        `(meow-beacon-fake-cursor ((t (:foreground ,(doom-color 'bg)
                                       :background ,(doom-blend 'yellow 'bg 0.7)
                                       :bold t))))
        `(meow-position-highlight-number-1 ((t (:inherit orderless-match-face-1))))
        `(meow-position-highlight-number-2 ((t (:inherit orderless-match-face-2))))
        `(meow-position-highlight-number-3 ((t (:inherit orderless-match-face-3))))
        ;; dirvish
        '(dirvish-hl-line ((t (:inherit hl-line))))
        ;; mini-echo
        `(window-divider ((t (:foreground ,(doom-color 'base0)))))
        ;; magit
        `(magit-blame-dimmed ((t (:foreground ,(doom-color 'bg)))))
        `(magit-blame-margin ((t (:foreground ,(doom-blend 'blue 'fg 0.6)
                                  :background ,(doom-blend 'blue 'bg 0.1)
                                  :bold t))))
        ;; ;;org
        ;; `(org-block            ((t (:background ,(doom-darken (doom-color 'base3) 0.15)))))
        ;; `(org-block-begin-line ((t (:background ,(doom-darken (doom-color 'base3) 0.15)
        ;;                             :foreground ,(doom-color 'fg-alt)))))
        ;; `(org-block-end-line   ((t (:background ,(doom-darken 'base3 0.15)
        ;;                             :foreground ,(doom-color 'fg-alt)))))
        ;; combobulate
        '(combobulate-refactor-highlight-face ((t (:background unspecified))))
        `(combobulate-refactor-label-face ((t (:foreground ,(doom-color 'bg)
                                               :background ,(doom-blend 'cyan 'bg 0.7)
                                               :bold t))))
        `(combobulate-active-indicator-face ((t (:foreground ,(doom-blend 'cyan 'bg 0.7)
                                                 :bold t))))
        ;; web-mode
        `(web-mode-html-tag-bracket-face ((t (:foreground ,(doom-color 'dark-blue)))))
        `(web-mode-html-entity-face ((t (:italic nil :foreground ,(doom-color 'teal)))))
        `(web-mode-current-element-highlight-face
          ((t (:weight bold :background ,(doom-blend 'cyan 'bg 0.15)))))
        `(web-mode-current-column-highlight-face  ((t (:background ,(doom-color 'base4)
                                                       :foreground unspecified))))
        ;; orderless
        `(orderless-match-face-0 ((t (:underline t))))
        `(orderless-match-face-1 ((t (:underline t))))
        `(orderless-match-face-2 ((t (:underline t))))
        `(orderless-match-face-3 ((t (:underline t))))
        ;;rg.el
        `(rg-match-face ((t (:inherit orderless-match-face-2))))
        `(rg-info-face        ((t (:foreground ,(doom-color 'red)))))
        `(rg-filename-face    ((t (:foreground ,(doom-color 'blue) :underline t))))
        `(rg-line-number-face ((t (:foreground ,(doom-color 'yellow)))))
        `(rg-file-tag-face ((t (:foreground ,(doom-color 'magenta)))))
        ;; wgrep
        `(wgrep-face ((t (:foreground ,(doom-color 'yellow)
                          :background unspecified
                          :bold nil))))
        `(wgrep-delete-face ((t (:foreground ,(doom-color 'red)
                                 :background unspecified
                                 :strike-through t))))
        `(rainbow-delimiters-depth-1-face ((t (:foreground ,(doom-color 'blue)))))
        `(rainbow-delimiters-depth-2-face ((t (:foreground ,(doom-color 'yellow)))))
        `(rainbow-delimiters-depth-3-face ((t (:foreground ,(doom-color 'magenta)))))
        `(rainbow-delimiters-depth-4-face ((t (:foreground ,(doom-color 'teal)))))
        `(rainbow-delimiters-depth-5-face ((t (:foreground ,(doom-color 'red)))))
        `(which-key-note-face ((t (:foreground ,(doom-color 'yellow)))))
        ))))
  )

(provide 'init-theme)
;;; init-theme.el ends here
