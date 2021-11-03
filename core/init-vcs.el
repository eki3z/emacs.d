;;; init-vcs.el --- version control system -*- lexical-binding: t no-byte-compile: t -*-
;;; Commentary:
;;; Code:

(leaf forge
  :after magit
  :init
  (setq  forge-topic-list-limit '(100 . -10)))

(leaf git-modes
  :mode ("\\.\\(rg\\|docker\\)ignore\\'" . gitignore-mode))

(leaf gist
  :defer-config
  (setq gist-ask-for-description t)
  (setq gist-list-format
        '((id "Id" 7 nil identity)
          (created "Created" 15 nil "%y-%m-%d %R")
          (visibility "Visibility" 10 nil
                      (lambda (public)
                        (or (and public "public")
                            "private")))
          (description "Description" 0 nil identity)))

  (let ((info (auth-source-user-and-password "api.github.com" "liuyinz^gist")))
    (setq gh-profile-alist
          `(("github"
             :username "liuyinz"
             :password nil
             :token   ,(cadr info)
             :url "https://api.github.com"
             :remote-regexp
             ,(gh-profile-remote-regexp "github.com")))))
  )


(leaf vc-msg
  :init
  (setq vc-msg-show-at-line-beginning-p nil
        vc-msg-newbie-friendly-msg ""))

(leaf blamer
  :hook (after-init-hook . global-blamer-mode)
  :init
  (setq blamer-idle-time 0.3
        blamer-min-offset 70)
  )

(leaf git-commit-insert-issue
  :hook (git-commit-mode-hook . git-commit-insert-issue-mode))

(leaf gitignore-templates
  :init
  (setq gitignore-templates-api 'github)

  ;; Integrate with `magit-gitignore'
  (with-eval-after-load 'magit-gitignore
    (require 'gitignore-templates nil t)
    (transient-append-suffix 'magit-gitignore '(0)
      ["Template"
       ("n" "new file" gitignore-templates-new-file)
       ("i" "select pattern" gitignore-templates-insert)])))

(leaf conventional-changelog
  :init
  (setq conventional-changelog-tmp-dir
        (expand-file-name "var/conventional-changelog" my/dir-cache))

  ;; Integrate to `magit-tag'
  (with-eval-after-load 'magit-tag
    (transient-append-suffix 'magit-tag
      '(1 0 -1)
      '("c" "changelog" conventional-changelog-menu))))

(leaf magit
  :init
  (setq magit-no-confirm t
        magit-save-repository-buffers 'dontask
        magit-auto-revert-immediately t
        magit-submodule-remove-trash-gitdirs t
        ;; SEE https://magit.vc/manual/magit/Diff-Options.html
        ;; magit-diff-refine-hunk nil
        magit-diff-paint-whitespace-lines 'all
        magit-fetch-modules-jobs 7)

  :defer-config
  (prependq! magit-section-initial-visibility-alist '((untracked . hide)))

  ;; ------------------------- submodul -----------------------------

  ;; HACK ignore submodules in magit-status when there is too many submodules.
  (defvar magit-status-submodule-max 20
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

  ;; disable `magit-insert-modules-overview'
  (setq magit-module-sections-hook
        '(magit-insert-modules-unpulled-from-upstream
          magit-insert-modules-unpulled-from-pushremote
          magit-insert-modules-unpushed-to-upstream
          magit-insert-modules-unpushed-to-pushremote))
  ;; add module in `magit-status'
  (magit-add-section-hook 'magit-status-sections-hook
                          'magit-insert-modules
                          'magit-insert-untracked-files)
  )

(provide 'init-vcs)
;;; init-vcs.el ends here
