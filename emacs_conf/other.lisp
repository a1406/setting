(require 'gdb-mi)
(defun gamesrv-gdb ()
  (interactive)
  (let* ((srv_pid
    (with-temp-buffer
      (insert-file-contents "game_srv/pid.txt")
      (buffer-string)))
	 (cmd1 (gud-val 'command-name 'gdb))
	 (cmd2 (format "%s game_srv/game_srv -p %s" cmd1 srv_pid))
	 )
;;    (setq gud-gdb-history (list cmd2))
    (gdb cmd2)
    )
  )


(defun remove_last (path)
  (let* ((len (- (length path) 1))
	 (last (nth len path))
	 )
    (remove last path)
  ))


(defun my_make_path (path)
  (let ((ret ""))
    (loop for i in path do
      (setq ret (format "%s/%s" ret i))
      )
    ret
    ))


(defun my_find-cscope-files ()
  (let* ((sp_path (split-string (expand-file-name default-directory) "/"))
	 (path "")
	 )
    (loop
     (setq path (my_make_path sp_path))
;;     (message "%s: %s" sp_path path)
     (if (eq path "")
	 (return nil))
      (if (file-exists-p (format "%s/cscope.files" path))
	  (return path))
      (setq sp_path (remove_last sp_path))
     )
  ))

(defun my_reset_id (start end)
  (interactive "r")
  (let* ((str (substring (buffer-string) (- start 1) (- end 1)))
	 (cmd (format "echo \"%s\" | awk -f reset_id.awk" str))
	 (result "")
	 )
    (setq result (shell-command-to-string cmd))
    (kill-region start end)
    (insert result)
    (kill-line)
    )
  )

(defun ivy-completion-in-region (start end collection &optional predicate)
  "An Ivy function suitable for `completion-in-region-function'.
The function completes the text between START and END using COLLECTION.
PREDICATE (a function called with no arguments) says when to exit.
See `completion-in-region' for further information."
  (let* ((enable-recursive-minibuffers t)
         (str (buffer-substring-no-properties start end))
         (completion-ignore-case case-fold-search)
         (comps
          (completion-all-completions str collection predicate (- end start)))
         (ivy--prompts-list (if (window-minibuffer-p)
                                ivy--prompts-list
                              '(ivy-completion-in-region (lambda nil)))))
    (cond ((null comps)
           (message "No matches"))
          ((progn
             (nconc comps nil)
             (and (null (cdr comps))
                  (string= str (car comps))))
           (message "Sole match"))
          (t
           (let* ((len (ivy-completion-common-length (car comps)))
                  (str-len (length str))
                  (initial (cond ((= len 0)
                                  "")
                                 ((> len str-len)
                                  (setq len str-len)
                                  str)
                                 (t
                                  (substring str (- len))))))
             (unless (ivy--filter initial comps)
               (setq initial nil))
             (delete-region (- end len) end)
             (setq ivy-completion-beg (- end len))
             (setq ivy-completion-end ivy-completion-beg)
             (if (null (cdr comps))
                 (progn
                   (unless (minibuffer-window-active-p (selected-window))
                     (setf (ivy-state-window ivy-last) (selected-window)))
                   (ivy-completion-in-region-action
                    (substring-no-properties
                     (car comps))))
               (let* ((w (1+ (floor (log (length comps) 10))))
                      (ivy-count-format (if (string= ivy-count-format "")
                                            ivy-count-format
                                          (format "%%-%dd " w)))
                      (prompt (format "(%s): " str)))
                 (and
                  (ivy-read (if (string= ivy-count-format "")
                                prompt
                              (replace-regexp-in-string "%" "%%" prompt))
                            ;; remove 'completions-first-difference face
                            (mapcar #'substring-no-properties comps)
                            :predicate predicate
                            :initial-input initial
			    :sort t
                            :action #'ivy-completion-in-region-action
                            :unwind (lambda ()
                                      (unless (eq ivy-exit 'done)
                                        (goto-char ivy-completion-beg)
                                        (insert initial)))
                            :caller 'ivy-completion-in-region)
                  t))))))))

