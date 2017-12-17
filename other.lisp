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
