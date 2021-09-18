;;; init-vcs.el --- version control system -*- lexical-binding: t no-byte-compile: t -*-
;;; Commentary:
;;; Code:

(leaf git-modes
  :require t
  :mode (;; NOTE https://github.com/magit/git-modes/discussions/142
         ("\\.\\(gitconfig\\|gitmodules\\)\\'" . gitconfig-mode)
         ("\\.\\(git\\|rg\\|docker\\)ignore\\'" . gitignore-mode)
         ("\\.gitattributes\\'" . gitattributes-mode)))

(leaf magit
  :doc "deps: with-editor forge git-modes ghub"
  :commands (magit-status
             magit-submodule
             magit-dispatch
             magit-file-dispatch
             magit-log
             magit-log-all-branches
             magit-commit-create
             magit-merge-abort)
  :init
  (setq magit-no-confirm t
        magit-save-repository-buffers 'dontask
        magit-auto-revert-immediately t
        magit-submodule-remove-trash-gitdirs t
        ;; SEE https://magit.vc/manual/magit/Diff-Options.html
        ;; magit-diff-refine-hunk nil
        magit-diff-paint-whitespace-lines 'all)

  :defer-config
  (prependq! magit-section-initial-visibility-alist '((untracked . hide)))

  ;; HACK ignore submodules in magit-status when there is too many submodules.
  (defvar magit-status-submodule-max 10
    "Maximum number of submodules that will be not ignored in `magit-status'.")
  (defun ad/ignore-submodules-more-than-max (orig-fn &rest args)
    (let ((default-directory (magit-toplevel)))
      (if (< magit-status-submodule-max (length (magit-list-module-paths)))
          ;; SEE https://emacs.stackexchange.com/a/57594/35676
          (cl-letf (((get 'magit-status-mode 'magit-diff-default-arguments)
                     (cl-pushnew
                      "--ignore-submodules=all"
                      (get 'magit-status-mode 'magit-diff-default-arguments))))
            (apply orig-fn args))
        (apply orig-fn args))))
  (advice-add 'magit-diff--get-value :around #'ad/ignore-submodules-more-than-max)
  )

(leaf gist
  :doc "deps: gh"
  :commands gist-list
  :config
  (setq gist-ask-for-description t)
  (setq gist-list-format '((id "Id" 7 nil identity)
                           (created "Created" 15 nil "%y-%m-%d %R")
                           (visibility "Visibility" 10 nil
                                       (lambda (public)
                                         (or (and public "public")
                                             "private")))
                           (description "Description" 0 nil identity)))

  (setq gh-profile-alist `(("github"
                            :username ,(car (github-info))
                            :password nil
                            :token   ,(cdr (github-info))
                            :url "https://api.github.com"
                            :remote-regexp
                            ,(gh-profile-remote-regexp "github.com"))))
  )

(leaf gitignore-templates
  :commands gitignore-templates-insert gitignore-templates-new-file
  :init (setq gitignore-templates-api 'github))

;; Open github/gitlab/bitbucket page
(leaf browse-at-remote :commands browse-at-remote)

(leaf vc-msg
  :commands vc-msg-show
  :init
  (setq vc-msg-show-at-line-beginning-p nil
        vc-msg-newbie-friendly-msg "")
  )

(leaf conventional-changelog
  :commands conventional-changelog)

(provide 'init-vcs)
;;; init-vcs.el ends here
