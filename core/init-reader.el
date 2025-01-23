;;; init-reader.el --- summary -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>
;; Created: 2023-07-05 02:54:33

;;; Commentary:

;;; Code:

(leaf elfeed
  :init
  (setq url-queue-timeout 30)
  (setq elfeed-initial-tags '(unread))
  (setq elfeed-search-filter "@6-months-ago")
  ;; (setq elfeed-show-entry-switch #'switch-to-buffer
  ;;       elfeed-show-entry-delete #'elfeed-kill-buffer)
  (setq elfeed-curl-extra-arguments '("--proxy" "socks5://127.0.0.1:7890"
                                      "--retry" "3"
                                      "--insecure"))
  (setq elfeed-feeds
        '(("https://sachachua.com/blog/feed" sacha emacs)
          ("https://planet.emacslife.com/atom.xml" emacs)
          ("http://www.masteringemacs.org/feed/" emacs)
          ("http://pragmaticemacs.com/feed/" emacs)
          ("https://oremacs.com/atom.xml" emacs)
          ("http://xahlee.info/emacs/emacs/blog.xml" emacs xah)
          ("https://pinecast.com/feed/emacscast" emacs)
          ("https://emacstil.com/feed.xml" emacs)
          ("https://emacstalk.codeberg.page/podcast/index.xml" emacs)
          ("https://manateelazycat.github.io/feed.xml" lazycat emacs)
          ("https://news.ycombinator.com/rss" hacker news)))

  ;; SEE https://emacs-china.org/t/elfeed-nerd-icons/26125
  (setq  elfeed-search-print-entry-function #'elfeed-search-print-entry--my)
  (defun elfeed-search-print-entry--my (entry)
    "Print ENTRY to the buffer."
    (let* ((date (elfeed-search-format-date (elfeed-entry-date entry)))
           (date-width (car (cdr elfeed-search-date-format)))
           (title (concat (or (elfeed-meta entry :title)
                              (elfeed-entry-title entry) "")
                          ;; NOTE: insert " " for overlay to swallow
                          " "))
           (title-faces (elfeed-search--faces (elfeed-entry-tags entry)))
           (feed (elfeed-entry-feed entry))
           (feed-title (when feed (or (elfeed-meta feed :title)
                                      (elfeed-feed-title feed))))
           (tags (mapcar #'symbol-name (elfeed-entry-tags entry)))
           (tags-str (mapconcat (lambda (s)
                                  (propertize s 'face 'elfeed-search-tag-face))
                                tags ","))
           (title-width (- (frame-width)
                           ;; (window-width (get-buffer-window (elfeed-search-buffer) t))
                           date-width elfeed-search-trailing-width))
           (title-column (elfeed-format-column
                          title (elfeed-clamp
                                 elfeed-search-title-min-width
                                 title-width
                                 elfeed-search-title-max-width) :left))
           ;; Title/Feed ALIGNMENT
           (align-to-feed-pixel (+ date-width
                                   (max elfeed-search-title-min-width
                                        (min title-width
                                             elfeed-search-title-max-width)))))
      (insert (propertize date 'face 'elfeed-search-date-face) " ")
      (insert (propertize title-column 'face title-faces 'kbd-help title))
      (put-text-property (1- (point)) (point) 'display
                         `(space :align-to ,align-to-feed-pixel))
      (when feed-title
        (insert " " (propertize feed-title 'face 'elfeed-search-feed-face) " "))
      (when tags (insert "(" tags-str ")"))))

  :defer-config

  (leaf elfeed-webkit
    :require t
    :init
    (advice-add 'elfeed-show-mode :after #'elfeed-webkit-toggle)
    :bind
    (:elfeed-show-mode-map
     ("%" . elfeed-webkit-toggle)))

  (defun eli/elfeed-overview ()
    "Get an overview of all feeds."
    (interactive)
    (with-current-buffer (elfeed-search-buffer)
      (elfeed-save-excursion
        (let* ((inhibit-read-only t)
               (standard-output (current-buffer)))
          (erase-buffer)
          (eli/elfeed-overview--update-list)
          (dolist (entry elfeed-search-entries)
            (funcall elfeed-search-print-entry-function entry)
            (insert "\n"))
          (setf elfeed-search-last-update (float-time))))
      (when (zerop (buffer-size))
        ;; If nothing changed, force a header line update
        (force-mode-line-update))
      (run-hooks 'elfeed-search-update-hook)))

  (defun eli/elfeed-overview--update-list ()
    "Update `elfeed-search-filter' list."
    (let* ((head (list nil))
           (tail head)
           (count 0))
      (dolist (feed elfeed-feeds)
        (let* ((lexical-binding t)
               (filter (elfeed-search-parse-filter
                        (concat "=" (or (car-safe feed)
                                        feed))))
               (func (byte-compile (elfeed-search-compile-filter filter))))
          (with-elfeed-db-visit (entry feed)
            (when (funcall func entry feed count)
              (setf (cdr tail) (list entry)
                    tail (cdr tail)
                    count (1+ count))
              (elfeed-db-return)))))
      (let ((entries (cdr head))
            (elfeed-search-sort-function
             (lambda (a b)
               (let ((a-date (elfeed-entry-date a))
                     (b-date (elfeed-entry-date b)))
                 (> a-date b-date)))))
        (setf entries (sort entries elfeed-search-sort-function))
        (setf elfeed-search-entries
              entries))))
  (push elfeed-db-directory recentf-exclude))

(provide 'init-reader)
;;; init-reader.el ends here
