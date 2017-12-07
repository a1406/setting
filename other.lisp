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
