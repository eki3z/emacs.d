;;; init-color.el --- Setup color -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>
;; Created: 2022-12-12 06:59:38

;;; Commentary:

;;; Code:

;; TODO write transient menu for color operation
;; (leaf kurecolor
;;   :init
;;   (defun my/kurecolor-variant (hex)
;;     (interactive)
;;     (let ((lst (number-sequence 0.1 1.0 0.1)))
;;       (with-current-buffer (get-buffer-create "*kurecolor-variant")
;;         (colorful-mode 1)
;;         (goto-char (point-max))
;;         (insert (format "\n\n %s   %s\nsat: %0.2f %s\nbri: %0.2f %s"
;;                         hex
;;                         (mapconcat (apply-partially #'format "%0.2f") lst "    ")
;;                         (kurecolor-hex-get-saturation hex)
;;                         (mapconcat (apply-partially #'kurecolor-hex-set-saturation hex) lst " ")
;;                         (kurecolor-hex-get-brightness hex)
;;                         (mapconcat (apply-partially #'kurecolor-hex-set-brightness hex) lst " ")
;;                         ))
;;         (display-buffer (current-buffer))))))

(leaf ct)

(provide 'init-color)
;;; init-color.el ends here
