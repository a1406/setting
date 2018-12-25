(require 'gdb-mi)
(defun game-gdb ()
  (interactive)
  (let* (
	 (init_dir (file-name-as-directory (my-cscope-guess-root-directory)))
	 (pid_path (format "%sgame_srv/pid.txt" init_dir))
	 (srv_pid
    (with-temp-buffer
      (insert-file-contents pid_path)
      (buffer-string)))
	 ;;	 (cmd1 (gud-val 'command-name 'gdb))
	 (cmd1 gud-gud-gdb-command-name)
	 (cmd2 (format "%s %sgame_srv/game_srv -p %s" cmd1 init_dir srv_pid))
	 )
;;    (message "cmd2 %s"  cmd2)
;;    (setq gud-gdb-history (list cmd2))
    (gud-gdb cmd2)
    )
  )

(defun conn-gdb ()
  (interactive)
  (let* (
	 (init_dir (file-name-as-directory (my-cscope-guess-root-directory)))
	 (pid_path (format "%sconn_srv/pid.txt" init_dir))
	 (srv_pid
    (with-temp-buffer
      (insert-file-contents pid_path)
      (buffer-string)))
	 ;;	 (cmd1 (gud-val 'command-name 'gdb))
	 (cmd1 gud-gud-gdb-command-name)
	 (cmd2 (format "%s %sconn_srv/conn_srv -p %s" cmd1 init_dir srv_pid))
	 )
;;    (message "cmd2 %s"  cmd2)
;;    (setq gud-gdb-history (list cmd2))
    (gud-gdb cmd2)
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

(defun my_show-current-dir ()
  (interactive)
  (message (kill-new default-directory))
  )

;;为了在ivy-read那里设置个sort
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


(if my_use-rtags
(defun my-rtags-find-file (tagname)
  (let ((offset)
          (line)
          (column)
	(prefer-exact rtags-find-file-prefer-exact-match))
      (with-current-buffer (rtags-get-buffer)
        (rtags-call-rc "-P" tagname
                       (when rtags-find-file-absolute "-K")
                       (when rtags-find-file-case-insensitive "-I")
                       (when prefer-exact "-A"))
        (and (= (point-min) (point-max))
             (string-match "[^/]\\.\\.[^/]" tagname)
             (rtags-call-rc "-P"
                            (replace-regexp-in-string "\\([^/]\\)\\.\\.\\([^/]\\)" "\\1.\\2" tagname)
                            (when rtags-find-file-absolute "-K")
                            (when rtags-find-file-case-insensitive "-I")
                            (when prefer-exact "-A")))

        (cond (offset (rtags-append (format ",%d" offset)))
              ((and line column) (rtags-append (format ":%d:%d" line column)))
              ((and line) (rtags-append (format ":%d" line)))
              (t nil))
        ;; (message (format "Got lines and shit %d\n[%s]" (count-lines (point-min) (point-max)) (buffer-string)))
        (goto-char (point-min))
        (cond ((= (point-min) (point-max)) t)
              ((= (count-lines (point-min) (point-max)) 1) (rtags-goto-location (buffer-substring-no-properties (point-at-bol) (point-at-eol))))
              (t (rtags-switch-to-buffer rtags-buffer-name t)
                 (shrink-window-if-larger-than-buffer)
                 (rtags-mode))))))
(defun my-rtags-find-file (tagname)
  (interactive)
  (if (file-exists-p tagname)
      (find-file tagname)
      )
  )
)


(defun my-rtags-open-other-file ()
  (interactive)
  (let* ((filename (replace-regexp-in-string ".*/" "" (buffer-file-name)))
	 (ch-name))
    (if (string-match "^.*\.h$" filename)
	(setq ch-name (replace-regexp-in-string "\.h" "\.cpp" filename))
      (setq ch-name (replace-regexp-in-string "\.cpp" "\.h" filename)))
    (message "open file %s" ch-name)
    (my-rtags-find-file ch-name)
    (if (and (window-parent nil) my_use-rtags)
      (progn (delete-window)
	     (ivy-rtags-read)
	     ))
    ))


(if my_use-rtags
(defun my_rtags-set-current-project ()
  "Set active project.
Uses `completing-read' to ask for the project."
  (interactive)
  (let ((projects nil)
        (project nil)
        (current "")
	(command)
	)
    (with-temp-buffer
      (rtags-call-rc :path t "-w")
      (goto-char (point-min))
      (while (not (eobp))
        (let ((line (buffer-substring-no-properties (point-at-bol) (point-at-eol))))
          (cond ((string-match "^\\([^ ]+\\)[^<]*<=$" line)
                 (let ((name (match-string-no-properties 1 line)))
                   (push name projects)
                   (setq current name)))
                ((string-match "^\\([^ ]+\\)[^<]*$" line)
                 (push (match-string-no-properties 1 line) projects))
                (t)))
        (forward-line)))
    (setq project (completing-read
                   (format "RTags select project (current is %s): " current)
                   projects))
    (when project
      (with-temp-buffer
      (setq command (format "-w %s" project))
      (rtags-call-rc :path t command))
      (message "change rtags project to %s" project)
      )
    ))
(defun my_rtags-set-current-project ()
    (interactive)
  )
)


(defun org-insert-src-block (src-code-type)
    "Insert a `SRC-CODE-TYPE' type source code block in org-mode."
    (interactive
     (let ((src-code-types
            '("C" "emacs-lisp" "python" "sh" "java" "js" "clojure" "C++" "css"
              "calc" "asymptote" "dot" "gnuplot" "ledger" "lilypond" "mscgen"
              "octave" "oz" "plantuml" "R" "sass" "screen" "sql" "awk" "ditaa"
              "haskell" "latex" "lisp" "matlab" "ocaml" "org" "perl" "ruby"
              "scheme" "sqlite")))
       (list (ido-completing-read "Source code type: " src-code-types))))
    (progn
      (newline-and-indent)
      (insert (format "#+BEGIN_SRC %s\n" src-code-type))
      (newline-and-indent)
      (insert "#+END_SRC\n")
      (previous-line 2)
      (org-edit-src-code)))


(if (not (functionp 'process-kill-without-query))
(defun process-kill-without-query (process &optional _flag)
  "Say no query needed if PROCESS is running when Emacs is exited.
Optional second argument if non-nil says to require a query.
Value is t if a query was formerly required."
  (declare (obsolete
            "use `process-query-on-exit-flag' or `set-process-query-on-exit-flag'."
            "22.1"))
  (let ((old (process-query-on-exit-flag process)))
    (set-process-query-on-exit-flag process nil)
    old)))

(require 'counsel)
;;优先使用设置的tags file name
(defun counsel-etags-locate-tags-file ()
  "Find tags file: Search in parent directory or use `tags-file-name'."
  (let ((dir))
    (if (and tags-file-name (file-exists-p tags-file-name))
	tags-file-name
      (progn 
	(setq dir (locate-dominating-file default-directory "TAGS"))
	(concat dir "TAGS")))))
	      
;;去掉^M, 否则不能修改
(defun counsel-grep-like-occur (cmd-template)
  (unless (eq major-mode 'ivy-occur-grep-mode)
    (ivy-occur-grep-mode)
    (setq default-directory (ivy-state-directory ivy-last)))
  (setq ivy-text
        (and (string-match "\"\\(.*\\)\"" (buffer-name))
             (match-string 1 (buffer-name))))
  (let* ((cmd (format cmd-template
                      (shell-quote-argument
                       (counsel-unquote-regex-parens
                        (ivy--regex ivy-text)))))
         (cands (split-string (shell-command-to-string cmd) "\n" t)))
    ;; Need precise number of header lines for `wgrep' to work.
    (insert (format "-*- mode:grep; default-directory: %S -*-\n\n\n"
                    default-directory))
    (insert (format "%d candidates:\n" (length cands)))
    (ivy--occur-insert-lines
     (mapcar
      (lambda (cand)
	(setq cand (replace-regexp-in-string "" "" cand))	
	(concat "./" cand))
      cands))))


(defun my-choose-num (beg end)
  (interactive "r")
  (message "beg = %s, end = %s, choose = %s" beg end (- end beg)))

(defvar xref--cur-pos 0)
(defun my-xref-pre ()
  (interactive)
  (let ((ring xref--marker-ring)
	(cur-len (ring-length xref--marker-ring)))
    (when (ring-empty-p ring)
      (user-error "Marker stack is empty"))
    (setq xref--cur-pos (- xref--cur-pos 1))
    (if (< xref--cur-pos 0)
	(setq xref--cur-pos 0))
    (if (>= xref--cur-pos cur-len)
	(setq xref--cur-pos (- cur-len 1)))
    
    (let ((marker (ring-ref ring xref--cur-pos)))
      (switch-to-buffer (or (marker-buffer marker)
                            (user-error "The marked buffer has been deleted")))
      (goto-char (marker-position marker)))
    (message "xref %s/%s" xref--cur-pos cur-len)    
  ))

(defun my-xref-next ()
  (interactive)
  (let ((ring xref--marker-ring)
	(cur-len (ring-length xref--marker-ring)))
    (when (ring-empty-p ring)
      (user-error "Marker stack is empty"))
    (setq xref--cur-pos (+ xref--cur-pos 1))
    (if (< xref--cur-pos 0)
	(setq xref--cur-pos 0))
    (if (>= xref--cur-pos cur-len)
	(setq xref--cur-pos (- cur-len 1)))
    
    (let ((marker (ring-ref ring xref--cur-pos)))
      (switch-to-buffer (or (marker-buffer marker)
                            (user-error "The marked buffer has been deleted")))
      (goto-char (marker-position marker)))
    (message "xref %s/%s" xref--cur-pos cur-len)
  ))

(defun my-xref-cur ()
  (interactive)
  (let ((ring xref--marker-ring)
	(cur-len (ring-length xref--marker-ring)))
    (when (ring-empty-p ring)
      (user-error "Marker stack is empty"))
    (if (< xref--cur-pos 0)
	(setq xref--cur-pos 0))
    (if (>= xref--cur-pos cur-len)
	(setq xref--cur-pos (- cur-len 1)))
    
    (let ((marker (ring-ref ring xref--cur-pos)))
      (switch-to-buffer (or (marker-buffer marker)
                            (user-error "The marked buffer has been deleted")))
      (goto-char (marker-position marker)))
    (message "xref %s/%s" xref--cur-pos cur-len)    
  ))

(defun my-xref-first ()
  (interactive)
  (let ((ring xref--marker-ring)
	(cur-len (ring-length xref--marker-ring)))
    (when (ring-empty-p ring)
      (user-error "Marker stack is empty"))
    (setq xref--cur-pos 0)
    (if (< xref--cur-pos 0)
	(setq xref--cur-pos 0))
    (if (>= xref--cur-pos cur-len)
	(setq xref--cur-pos (- cur-len 1)))
    
    (let ((marker (ring-ref ring xref--cur-pos)))
      (switch-to-buffer (or (marker-buffer marker)
                            (user-error "The marked buffer has been deleted")))
      (goto-char (marker-position marker)))
    (message "xref %s/%s" xref--cur-pos cur-len)    
  ))

