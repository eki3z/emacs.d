;;; init-outline.el --- Setup outline -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>
;; Created: 2022-12-12 06:58:06

;;; Commentary:

;;; Code:

;; (leaf outline
;;   :hook (prog-mode-hook . outline-minor-mode)
;;   :init
;;   (set-display-table-slot
;;    standard-display-table
;;    'selective-display
;;    (let ((face-offset (* (face-id 'shadow) (lsh 1 22))))
;;      (vconcat (mapcar (lambda (c) (+ face-offset c)) "...")))))

(leaf hideshow
  :hook (prog-mode-hook . hs-mode-setup)
  :init
  (setq hs-isearch-open t
        hs-hide-comments-when-hiding-all t)

  ;; display more information
  (defun display-code-line-counts (ov)
    (when (eq 'code (overlay-get ov 'hs))
      (overlay-put ov 'display
                   (propertize
                    (format "...%d"
                            (- (count-lines (overlay-start ov) (overlay-end ov)) 1))
                    'face 'shadow))))
  (setq hs-set-up-overlay #'display-code-line-counts)

  (defun hs-mode-setup ()
    "hs-minor-mode setup."
    (unless (memq major-mode '(vue-ts-mode moonbit-mode))
      (hs-minor-mode 1)))
  )

(leaf bicycle
  :bind
  (:outline-minor-mode-map
   :package outline
   ([C-tab] . bicycle-cycle)
   ([S-tab] . bicycle-cycle-global)))

(provide 'init-outline)
;;; init-outline.el ends here
