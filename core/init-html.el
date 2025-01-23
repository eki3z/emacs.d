;;; init-mhtml.el --- config for mhtml -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>
;; Created: 2024-02-28 23:42:41

;;; Commentary:

;;; Code:

(leaf sgml)

;;; tag-follow-mode
;; TODO tag highlight, rename, selection

(defun rst--inside-tag-p ()
  (save-excursion
    (not (null (sgml-get-context)))))

;;;###autoload
(defun rename-sgml-tag ()
  (interactive)
  (if (not (rst--inside-tag-p))
      (error "Place point inside tag to rename."))
  (let ((context (car (last (sgml-get-context)))))
    (if (looking-at "</")
        (setq context (car (last (sgml-get-context)))))
    (goto-char (aref context 2))
    (let* ((tag-name (aref context 4))
           (num-chars (length tag-name))
           (master-start (1+ (point)))
           (mirror-end (save-excursion
                         (sgml-skip-tag-forward 1)
                         (1- (point)))))
      (forward-char 1)
      (set-mark (+ (point) num-chars))
      (mm/create-master master-start (+ master-start num-chars))
      (mm/add-mirror (- mirror-end num-chars) mirror-end))))

(defun my/sgml-get-tag ()
  "docstring"
  (save-excursion
    (when-let* ((context (car (last (sgml-get-context))))
               (type (aref 1 context))
               ())
      ))

  )

(provide 'init-html)
;;; init-mhtml.el ends here
