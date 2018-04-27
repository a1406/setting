(require 'counsel)
(defun my-counsel-ag (&optional initial-input initial-directory extra-ag-args ag-prompt)
  "Grep for a string in the current directory using ag.
INITIAL-INPUT can be given as the initial minibuffer input.
INITIAL-DIRECTORY, if non-nil, is used as the root directory for search.
EXTRA-AG-ARGS string, if non-nil, is appended to `counsel-ag-base-command'.
AG-PROMPT, if non-nil, is passed as `ivy-read' prompt argument."
  (interactive)
  (setq counsel-ag-command counsel-ag-base-command)
  (counsel-require-program (car (split-string counsel-ag-command)))
  (when current-prefix-arg
    (setq initial-directory
          (or initial-directory
              (read-directory-name (concat
                                    (car (split-string counsel-ag-command))
                                    " in directory: "))))
    (setq extra-ag-args
          (or extra-ag-args
              (read-from-minibuffer (format
                                     "%s args: "
                                     (car (split-string counsel-ag-command)))))))
  (when (null extra-ag-args)
    (setq extra-ag-args ""))
  (let* ((args-end (string-match " -- " extra-ag-args))
         (file (if args-end
                   (substring-no-properties extra-ag-args (+ args-end 3))
                 ""))
         (extra-ag-args (if args-end
                            (substring-no-properties extra-ag-args 0 args-end)
                          extra-ag-args)))
    (setq counsel-ag-command (format "cat %s/%s | xargs %s" cscope-initial-directory cscope-index-file counsel-ag-command))
    (setq counsel-ag-command (format counsel-ag-command
                                      (concat extra-ag-args
                                              " -- "
                                              "%s"
                                              file))))
;;  (message "cmd = %s" counsel-ag-command)
  (ivy-set-prompt 'counsel-ag counsel-prompt-function)
  (let ((default-directory (or initial-directory
                               (locate-dominating-file default-directory ".git")
                               default-directory)))
    (ivy-read (or ag-prompt (car (split-string counsel-ag-command)))
              #'counsel-ag-function
              :initial-input initial-input
              :dynamic-collection t
              :keymap counsel-ag-map
              :history 'counsel-git-grep-history
              :action #'counsel-git-grep-action
              :unwind (lambda ()
                        (counsel-delete-process)
                        (swiper--cleanup))
              :caller 'counsel-ag)))

