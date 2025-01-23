;;; init-embark.el --- embark setup -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>
;; Created: 2022-06-12 20:33:40

;;; Commentary:

;;; Code:

(leaf embark
  :after vertico
  :init
  (setq embark-prompter 'embark-keymap-prompter
        embark-mixed-indicator-delay 0.6)

  (setq embark-indicators
        '(embark-mixed-which-key-indicator
          embark-highlight-indicator
          embark-isearch-highlight-indicator))

  ;; HACK use delayed which-key to display embark
  (defun embark-mixed-which-key-indicator ()
    "Mixed indicator showing keymap and targets.
The indicator shows the `embark-minimal-indicator' by default.
After `embark-mixed-indicator-delay' seconds, the
`embark-which-key-indicator' is shown."
    (let* ((windicator (embark-which-key-indicator))
           (mindicator (embark-minimal-indicator))
           windicator-active
           wtimer)
      (lambda (&optional keymap targets prefix)
        (when wtimer
          (cancel-timer wtimer)
          (setq wtimer nil))
        (if (not keymap)
            (progn
              (funcall windicator)
              (when mindicator (funcall mindicator)))
          (when mindicator
            (funcall mindicator keymap targets prefix))
          (if windicator-active
              (funcall windicator keymap targets prefix)
            (setq wtimer
                  (run-at-time
                   embark-mixed-indicator-delay nil
                   (lambda ()
                     (setq windicator-active t)
                     (funcall windicator keymap targets prefix)))))))))

  (defun embark-which-key-indicator ()
    "An embark indicator that displays keymaps using which-key.
The which-key help message will show the type and value of the
current target followed by an ellipsis if there are further
targets."
    (lambda (&optional keymap targets prefix)
      (if (null keymap)
          (which-key--hide-popup-ignore-command)
        (which-key--show-keymap
         (if (eq (plist-get (car targets) :type) 'embark-become)
             "Become"
           (format "Act on %s '%s'%s"
                   (plist-get (car targets) :type)
                   (embark--truncate-target (plist-get (car targets) :target))
                   (if (cdr targets) "…" "")))
         (if prefix
             (pcase (lookup-key keymap prefix 'accept-default)
               ((and (pred keymapp) km) km)
               (_ (key-binding prefix 'accept-default)))
           keymap)
         nil nil t (lambda (binding)
                     (not (string-suffix-p "-argument" (cdr binding))))))))

  :bind
  ("M-l" . embark-act)
  (:embark-general-map
   ("C-c C-a" . marginalia-cycle))
  (:vertico-map
   ("C-l" . embark-act)
   ("C-c C-o" . embark-export)
   ("C-c C-a" . marginalia-cycle))
  (:embark-expression-map
   ("M" . pp-macroexpand-all-expression))
  (:embark-library-map
   ("o" . find-library-other-window))
  (:embark-identifier-map
   ("d" . lsp-bridge-find-def-other-window))

  :defer-config

  ;; HACK Open source code of `symbol' in other window
  (dolist (cmd '(embark-find-definition))
    (advice-add cmd :before #'open-in-other-window))

  )

(leaf embark-consult
  :after embark consult)

(provide 'init-embark)
;;; init-embark.el ends here
