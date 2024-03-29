(require 'gdb-mi)
;; (setq gdb-mi-decode-strings 'utf-8)
(setq gdb-mi-decode-strings t)

(defun my-get-utf ()
  (interactive)
  (beginning-of-buffer)
  (replace-regexp "\\\\\\u\\(....\\)" "&#x\\1;")
  )

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


;;为了eshell里面排序，比如tail -f game_srv/logs/game_srv.0
;;(setq ivy-sort-functions-alist '((read-file-name-internal . ivy-sort-file-function-default) (internal-complete-buffer . ivy-sort-file-function-default) (ivy-completion-in-region . ivy-sort-file-function-default) (counsel-git-grep-function) (Man-goto-section) (org-refile) (t . ivy-string<) (ivy-completion-in-region . ivy-sort-file-function-default)))
(setf (cdr (assoc 'ivy-completion-in-region ivy-sort-functions-alist)) 'ivy-sort-file-function-default)

;; 通过在c++mode里面添加了ivy-done到ivy-sort-functions-alist结局
;; (setq ivy-completing-sort t)
;; (setq ivy-completing-in-region-sort nil)
;;为了在ivy-read那里去掉sort, lsp 选择project的时候排序很讨厌
;; (defun ivy-completing-read1 (prompt collection
;;                             &optional predicate require-match initial-input
;;                               history def inherit-input-method)
;;   "Read a string in the minibuffer, with completion.

;; This interface conforms to `completing-read' and can be used for
;; `completing-read-function'.

;; PROMPT is a string that normally ends in a colon and a space.
;; COLLECTION is either a list of strings, an alist, an obarray, or a hash table.
;; PREDICATE limits completion to a subset of COLLECTION.
;; REQUIRE-MATCH is a boolean value.  See `completing-read'.
;; INITIAL-INPUT is a string inserted into the minibuffer initially.
;; HISTORY is a list of previously selected inputs.
;; DEF is the default value.
;; INHERIT-INPUT-METHOD is currently ignored."
;;   (let ((handler
;;          (and (< ivy-completing-read-ignore-handlers-depth (minibuffer-depth))
;;               (assq this-command ivy-completing-read-handlers-alist))))
;;     (if handler
;;         (let ((completion-in-region-function #'completion--in-region)
;;               (ivy-completing-read-ignore-handlers-depth (1+ (minibuffer-depth))))
;;           (funcall (cdr handler)
;;                    prompt collection
;;                    predicate require-match
;;                    initial-input history
;;                    def inherit-input-method))
;;       ;; See the doc of `completing-read'.
;;       (when (consp history)
;;         (when (numberp (cdr history))
;;           (setq initial-input (nth (1- (cdr history))
;;                                    (symbol-value (car history)))))
;;         (setq history (car history)))
;;       (when (consp def)
;;         (setq def (car def)))
;;       (let ((str (ivy-read
;;                   prompt collection
;;                   :predicate predicate
;;                   :require-match (and collection require-match)
;;                   :initial-input (cond ((consp initial-input)
;;                                         (car initial-input))
;;                                        ((and (stringp initial-input)
;;                                              (not (eq collection #'read-file-name-internal))
;;                                              (string-match-p "\\+" initial-input))
;;                                         (replace-regexp-in-string
;;                                          "\\+" "\\\\+" initial-input))
;;                                        (t
;;                                         initial-input))
;;                   :preselect def
;;                   :def def
;;                   :history history
;;                   :keymap nil
;;                   :sort ivy-completing-sort
;;                   :dynamic-collection ivy-completing-read-dynamic-collection
;;                   :caller (if (and collection (symbolp collection))
;;                               collection
;;                             this-command))))
;;         (if (string= str "")
;;             ;; For `completing-read' compat, return the first element of
;;             ;; DEFAULT, if it is a list; "", if DEFAULT is nil; or DEFAULT.
;;             (or def "")
;;           str)))))

;; ;;为了在ivy-read那里设置个sort, eshell那里排序
;; (defun ivy-completion-in-region1 (start end collection &optional predicate)
;;   "An Ivy function suitable for `completion-in-region-function'.
;; The function completes the text between START and END using COLLECTION.
;; PREDICATE (a function called with no arguments) says when to exit.
;; See `completion-in-region' for further information."
;;   (let* ((enable-recursive-minibuffers t)
;;          (str (buffer-substring-no-properties start end))
;;          (completion-ignore-case case-fold-search)
;;          (comps
;;           (completion-all-completions str collection predicate (- end start)))
;;          (ivy--prompts-list (if (window-minibuffer-p)
;;                                 ivy--prompts-list
;;                               '(ivy-completion-in-region (lambda nil)))))
;;     (cond ((null comps)
;;            (message "No matches"))
;;           ((progn
;;              (nconc comps nil)
;;              (and (null (cdr comps))
;;                   (string= str (car comps))))
;;            (message "Sole match"))
;;           (t
;;            (let* ((len (ivy-completion-common-length (car comps)))
;;                   (str-len (length str))
;;                   (initial (cond ((= len 0)
;;                                   "")
;;                                  ((> len str-len)
;;                                   (setq len str-len)
;;                                   str)
;;                                  (t
;;                                   (substring str (- len))))))
;;              (unless (ivy--filter initial comps)
;;                (setq initial nil))
;;              (delete-region (- end len) end)
;;              (setq ivy-completion-beg (- end len))
;;              (setq ivy-completion-end ivy-completion-beg)
;;              (if (null (cdr comps))
;;                  (progn
;;                    (unless (minibuffer-window-active-p (selected-window))
;;                      (setf (ivy-state-window ivy-last) (selected-window)))
;;                    (ivy-completion-in-region-action
;;                     (substring-no-properties
;;                      (car comps))))
;;                (let* ((w (1+ (floor (log (length comps) 10))))
;;                       (ivy-count-format (if (string= ivy-count-format "")
;;                                             ivy-count-format
;;                                           (format "%%-%dd " w)))
;;                       (prompt (format "(%s): " str)))
;;                  (and
;;                   (ivy-read (if (string= ivy-count-format "")
;;                                 prompt
;;                               (replace-regexp-in-string "%" "%%" prompt))
;;                             ;; remove 'completions-first-difference face
;;                             (mapcar #'substring-no-properties comps)
;;                             :predicate predicate
;;                             :initial-input initial
;; 			    :sort ivy-completing-in-region-sort
;;                             :action #'ivy-completion-in-region-action
;;                             :unwind (lambda ()
;;                                       (unless (eq ivy-exit 'done)
;;                                         (goto-char ivy-completion-beg)
;;                                         (insert initial)))
;;                             :caller 'ivy-completion-in-region)
;;                   t))))))))


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
;; (defun counsel-etags-locate-tags-file ()
;;   "Find tags file: Search in parent directory or use `tags-file-name'."
;;   (let ((dir))
;;     (if (and tags-file-name (file-exists-p tags-file-name))
;; 	tags-file-name
;;       (progn 
;; 	(setq dir (locate-dominating-file default-directory "TAGS"))
;; 	(concat dir "TAGS")))))
	      
;;去掉^M, 否则不能修改
;; (defun counsel-grep-like-occur (cmd-template)
;;   (unless (eq major-mode 'ivy-occur-grep-mode)
;;     (ivy-occur-grep-mode)
;;     (setq default-directory (ivy-state-directory ivy-last)))
;;   (setq ivy-text
;;         (and (string-match "\"\\(.*\\)\"" (buffer-name))
;;              (match-string 1 (buffer-name))))
;;   (let* ((cmd (format cmd-template
;;                       (shell-quote-argument
;;                        (counsel-unquote-regex-parens
;;                         (ivy--regex ivy-text)))))
;;          (cands (split-string (shell-command-to-string cmd) "\n" t)))
;;     ;; Need precise number of header lines for `wgrep' to work.
;;     (insert (format "-*- mode:grep; default-directory: %S -*-\n\n\n"
;;                     default-directory))
;;     (insert (format "%d candidates:\n" (length cands)))
;;     (ivy--occur-insert-lines
;;      (mapcar
;;       (lambda (cand)
;; 	(setq cand (replace-regexp-in-string "" "" cand))	
;; 	(concat "./" cand)
;; 	(counsel--normalize-grep-match cand)
;; 	)
;;       cands))))
;; (defun counsel-grep-like-occur (cmd-template)
;;   ;; (message "cmd-template = %s" cmd-template)
;;   (if my_use-rg
;;       (progn
;; 	(setq rgfile (format "%s/rg.files"  (my-cscope-guess-root-directory)))
;; 	(if (f-exists-p rgfile)
;; 	    (setq process-environment (setenv-internal process-environment "RIPGREP_CONFIG_PATH" rgfile t)))))
  
;;   (unless (eq major-mode 'ivy-occur-grep-mode)
;;     (ivy-occur-grep-mode)
;;     (setq default-directory (ivy-state-directory ivy-last)))
;;   (setq ivy-text
;;         (and (string-match "\"\\(.*\\)\"" (buffer-name))
;;              (match-string 1 (buffer-name))))
;;   (let* ((command-args (counsel--split-command-args ivy-text))
;;          (regex (counsel--grep-regex (cdr command-args)))
;;          (switches (concat (car command-args)
;;                            (counsel--ag-extra-switches regex)))
;;          (cmd (format cmd-template
;;                       (concat
;;                        switches
;;                        (shell-quote-argument regex))))
;;          (cands (split-string (shell-command-to-string cmd)
;;                               counsel-async-split-string-re
;;                               t)))
;;     ;; Need precise number of header lines for `wgrep' to work.
;;     (insert (format "-*- mode:grep; default-directory: %S -*-\n\n\n"
;;                     default-directory))
;;     (insert (format "%d candidates:\n" (length cands)))
;;     (ivy--occur-insert-lines
;;      (mapcar
;;       (lambda (cand)
;; 	(setq cand (replace-regexp-in-string "" "" cand))	
;; 	(concat "./" cand)
;; 	(counsel--normalize-grep-match cand)
;; 	)
;;       cands))))
;; ;; (mapcar #'counsel--normalize-grep-match cands))))

;; (defun counsel-grep-like-occur (cmd-template)
;;   ;; (message "cmd-template = %s" cmd-template)
;;   (if my_use-rg
;;       (progn
;; 	(setq rgfile (format "%s/rg.files"  (my-cscope-guess-root-directory)))
;; 	(if (f-exists-p rgfile)
;; 	    (setq process-environment (setenv-internal process-environment "RIPGREP_CONFIG_PATH" rgfile t)))))
;;   (unless (eq major-mode 'ivy-occur-grep-mode)
;;     (ivy-occur-grep-mode)
;;     (setq default-directory (ivy-state-directory ivy-last)))
;;   (setq ivy-text
;;         (and (string-match "\"\\(.*\\)\"" (buffer-name))
;;              (match-string 1 (buffer-name))))
;;   (let* ((cmd
;;           (if (functionp cmd-template)
;;               (funcall cmd-template ivy-text)
;;             (let* ((command-args (counsel--split-command-args ivy-text))
;;                    (regex (counsel--grep-regex (cdr command-args)))
;;                    (switches (concat (car command-args)
;;                                      (counsel--ag-extra-switches regex))))
;;               (format cmd-template
;;                       (concat
;;                        switches
;;                        (shell-quote-argument regex))))))
;;          (cands (counsel--split-string (shell-command-to-string cmd))))
;;     ;; (swiper--occur-insert-lines (mapcar #'counsel--normalize-grep-match cands))))
;;     (swiper--occur-insert-lines
;;      (mapcar
;;       (lambda (cand)
;; 	(setq cand (replace-regexp-in-string "" "" cand))	
;; 	(concat "./" cand)
;; 	(counsel--normalize-grep-match cand)
;; 	)
;;       cands))))
(defun my-choose-num (beg end)
  (interactive "r")
  (message "beg = %s, end = %s, choose = %s" beg end (- end beg)))

(defun my-find-cscope-other-file ()
  ""
  (interactive)
  (let* ((cs-f (concat (my-cscope-guess-root-directory) "/cscope.files"))
	 (cs-line (read-lines cs-f))
	 (cs-f (concat (my-cscope-guess-root-directory) "/cscope2.files"))
	 (cs-len (length cs-line))
	 (foo-name)
	 (fname (file-name-nondirectory (buffer-file-name)))
	 (base1)
	 (base2)
	 )

    (if (file-exists-p cs-f)
	(progn
	 (setq cs-line2 (read-lines cs-f))
	 (setq cs-line (append cs-line cs-line2))
	 (setq cs-len (length cs-line))
	 )
	)
    
    (string-match "[0-9a-zA-Z_]+" fname)
    (setq base1
	  (match-string 0 fname))

    (catch 'out
    (dolist (foo cs-line)
      (setq foo-name (file-name-nondirectory foo))
      (if (string-equal foo-name fname)
	  nil
	(string-match "[0-9a-zA-Z_]+" foo-name)
	(setq base2
	  (match-string 0 foo-name))
	(if (string-equal base1 base2)
	    (progn
	      ;; (message "find file %s" foo)
	      (find-file (concat (my-cscope-guess-root-directory) foo))
	      (throw 'out nil)))
      )))  
    ))

(defun my-cscope-guess-root-directory ()
  "Display the name of the directory containing the cscope database."
  (interactive)
  (let (info directory)
    (setq info (cscope-find-info nil))
    (if (= (length info) 1)
	  (setq directory (car (car info)))
"")))


(defun my-cscope-include-directory (&optional dir)
  ""
  (interactive)
  (let* ((root)
	 (all-file)
	(result '("."))
	)
    (if dir
	(setq root dir)
      (setq root  (my-cscope-guess-root-directory)))

    (setq all-file (file-name-all-completions "" root))
    
    (dolist (file all-file)
      (unless ;;(member file '("./" "../"))
	  (or (string-match "^\\..*" file)
	      (string-match "CMake.*" file))
	(when (directory-name-p file)
	  (let ((t1 (format "%s/%s" root file))
		(t2))
	    (add-to-list 'result (format "%s" t1))
	  (unless (file-symlink-p t1)
	      (setq t2 (my-cscope-include-directory t1))
;;	       (setq result (nconc result tmp-result))
	    ) ;;unless
	  ));;when
	);;unless
      );;dolist
    result
    ))

;; (defun ttt()
;;   ""
;;   (interactive)
;;   (let ((tmp))
;;     (setq tmp (my-cscope-include-directory))
;;     (message "ttt result = [%s]" tmp)
;;     ))


;; (defun my-counsel-rag (&optional initial-input initial-directory extra-rg-args rg-prompt)
;;   "Grep for a string in the current directory using rg.
;; INITIAL-INPUT can be given as the initial minibuffer input.
;; INITIAL-DIRECTORY, if non-nil, is used as the root directory for search.
;; EXTRA-RG-ARGS string, if non-nil, is appended to `counsel-rg-base-command'.
;; RG-PROMPT, if non-nil, is passed as `ivy-read' prompt argument."
;;   (interactive)
;;   (if my_use-rg
;;       (progn
;; 	(setenv "RIPGREP_CONFIG_PATH" (format "%s/rg.files"  (my-cscope-guess-root-directory)))
;; 	(counsel-rg (thing-at-point 'symbol) (my-cscope-guess-root-directory))
;; 	)
;;     (counsel-ag (thing-at-point 'symbol) (my-cscope-guess-root-directory) (format "-E %s/%s" (my-cscope-guess-root-directory) cscope-index-file) nil)))

(if my_use-rg
    (setq counsel-grep-base-command
	  "rg -i -L -M 120 --no-heading --line-number --color never %s %s")
    (setq counsel-grep-base-command
	  "ag -i -f --noheading --numbers --nocolor %s %s"))

(setq counsel-rg-base-command
      "rg -M 240 -L --with-filename --no-ignore --no-heading --line-number --color never %s || echo \"ignore rg error\"")

(setq my-counsel-rag-sp nil)
(defun my-counsel-rag-sp (&optional initial-input initial-directory extra-rg-args rg-prompt)
  "Grep for a string in the current directory using rg.
INITIAL-INPUT can be given as the initial minibuffer input.
INITIAL-DIRECTORY, if non-nil, is used as the root directory for search.
EXTRA-RG-ARGS string, if non-nil, is appended to `counsel-rg-base-command'.
RG-PROMPT, if non-nil, is passed as `ivy-read' prompt argument."
  (interactive)
  (setq my-counsel-rag-sp t)  
  (if my_use-rg
      (counsel-rg (thing-at-point 'symbol) (my-cscope-guess-root-directory) "-i")
      (counsel-ag (thing-at-point 'symbol) (my-cscope-guess-root-directory) (format "-f -E %s/%s" (my-cscope-guess-root-directory) cscope-index-file) nil))
  (setq my-counsel-rag-sp nil)  
  )

(defun my-counsel-rag (&optional initial-input initial-directory extra-rg-args rg-prompt)
  "Grep for a string in the current directory using rg.
INITIAL-INPUT can be given as the initial minibuffer input.
INITIAL-DIRECTORY, if non-nil, is used as the root directory for search.
EXTRA-RG-ARGS string, if non-nil, is appended to `counsel-rg-base-command'.
RG-PROMPT, if non-nil, is passed as `ivy-read' prompt argument."
  (interactive)
  (setq my-counsel-rag-sp nil)  
  (if my_use-rg
	(counsel-rg (thing-at-point 'symbol) (my-cscope-guess-root-directory) "-i")
    (counsel-ag (thing-at-point 'symbol) (my-cscope-guess-root-directory) (format "-f -E %s/%s" (my-cscope-guess-root-directory) cscope-index-file) nil)))

(defun my-counsel-proto (&optional initial-input initial-directory extra-rg-args rg-prompt)
  "Grep for a string in the current directory using rg.
INITIAL-INPUT can be given as the initial minibuffer input.
INITIAL-DIRECTORY, if non-nil, is used as the root directory for search.
EXTRA-RG-ARGS string, if non-nil, is appended to `counsel-rg-base-command'.
RG-PROMPT, if non-nil, is passed as `ivy-read' prompt argument."
  (interactive)
  (setq my-counsel-rag-sp nil)  
  (counsel-ag (thing-at-point 'symbol) (my-cscope-guess-root-directory) "--proto" nil)  
  )

;; (if my_use-rg
;; (defun counsel-ag-function (string)
;;   "Grep in the current directory for STRING."
;;   (let* ((command-args (counsel--split-command-args string))
;;          (search-term (cdr command-args))
;; 	 (rgfile (format "%s/rg.files"  (my-cscope-guess-root-directory)))
;; 	 (cmd)
;; 	 )
;;     (or
;;      (let ((ivy-text search-term))
;;        (ivy-more-chars))
;;      (let* ((default-directory (ivy-state-directory ivy-last))
;;             (regex (counsel--grep-regex search-term))
;;             (switches (concat (car command-args)
;;                               (counsel--ag-extra-switches regex)
;;                               (if (ivy--case-fold-p string)
;;                                   " -i "
;;                                   " -s "))))
;;        (setq cmd (counsel--format-ag-command
;;                                 switches
;;                                 (shell-quote-argument regex)))
;;        (if my-counsel-rag-sp
;; 	   (setq cmd (format "%s | grep -i '\\(\\.h:[0-9]\\|::%s\\|Omitted long matching line\\)'" cmd string)))
;;        (if (f-exists-p rgfile)
;; 	   (setq process-environment (setenv-internal process-environment "RIPGREP_CONFIG_PATH" rgfile t)))
;;        (counsel--async-command cmd)
;;        nil))))    
;; )

;; 添加了thing-at-point symbol, 来设置预设的输入
;;
(defun xref-find-apropos (pattern)
  "Find all meaningful symbols that match PATTERN.
The argument has the same meaning as in `apropos'."
  (interactive (list (read-string
                      "Search for pattern (word list or regexp): "
                      (thing-at-point 'symbol) 'xref--read-pattern-history)))

;;  (message "bak backend = %s" xref-backend-functions)
  (let ((bak-xref-backend (append xref-backend-functions)))
    (setq xref-backend-functions (delete 'global-tags-xref-backend xref-backend-functions))
    (if my-use-gtags-default
	(add-to-list 'xref-backend-functions 'global-tags-xref-backend)	
	)

;;  (message "bak backend = %s, xref backend = %s" bak-xref-backend xref-backend-functions)    

  (require 'apropos)
  (let* ((newpat
          (if (and (version< emacs-version "28.0.50")
                   (memq (xref-find-backend) '(elisp etags)))
              ;; Handle backends in older Emacs.
              (xref-apropos-regexp pattern)
            ;; Delegate pattern handling to the backend fully.
            ;; The old way didn't work for "external" backends.
            pattern)))
    (xref--find-xrefs pattern 'apropos newpat nil))
  (setq xref-backend-functions (append bak-xref-backend))
  ))
(setq grep-program 'rg)

(define-key esc-map "%" (lambda() (interactive)
			  (xref-push-marker-stack)
			  (call-interactively 'query-replace)
			  ))


(require 'format-all)
(defun my-pretty-lua ()
  (interactive)
  (let ((output "11")
	(output2 "22")
	)
    (setq output2 (format-all--buffer-easy "lua" (expand-file-name "~/.emacs.conf/pretty.lua")))
    (erase-buffer)
    (insert (car output2))
    ))

(defun my-pretty-utf ()
  (interactive)
  (let ((command "python -c \"print(\\\"")
	(content (buffer-string))
	(cmd-tail "\\\")\"")
	)
    (erase-buffer)
    (setq content (replace-regexp-in-string "\\\\" "\\\\\\\\" content))
  (setq content (replace-regexp-in-string "\n" "\\\\n" content))
  (setq content (replace-regexp-in-string "\"" "\\\\\\\\\\\\\"" content))
    (setq command (format "%s%s%s" command content cmd-tail))
    (call-process-shell-command command nil t t )
    ))

(defun my-reload-symbol-file ()
  (interactive)
  (let* ((file-name (buffer-file-name))
	 (flist (split-string file-name "/"))
	 (t_path "")
	 (t_path2 nil)
	 (t_pos (point))
	 (t_car "")	 
	 )
    (while flist
      (setq t_car (car flist))
      (if (equal "" t_car)
	  nil
	;; (message "t_car = %s" t_car)
	(setq t_path (format "%s/%s" t_path t_car))
	(setq t_path2 (file-symlink-p t_path))

	(if t_path2
	    (message "symbol path %s to %s" t_path t_path2))
	(if t_path2
	    (setq t_path t_path2))
	)
      ;; (message "file path: %s" t_path)
      (setq flist (cdr flist))
      )
    (kill-current-buffer)      
    (find-file t_path)
    (goto-char t_pos)
    ;; (message "t_path = %s" t_path)
    ))

(defun my-magit-mode-bury-buffer (orig-fun &rest args)
  ;; (message "display-buffer called with args %S" args)
  (let ((res (apply orig-fun args)))
    ;; (message "display-buffer returned %S" res)
    (evil-mode 1)
    res))

(advice-add 'magit-mode-bury-buffer :around #'my-magit-mode-bury-buffer)


;; eshell中ivy补全路径后会添加一个空格，暂时用个旧版ivy的函数换一下
(defun ivy-completion-in-region-action (str)
  "Insert STR, erasing the previous one.
The previous string is between `ivy-completion-beg' and `ivy-completion-end'."
  (when (consp str)
    (setq str (cdr str)))
  (when (stringp str)
    (let ((fake-cursors (and (require 'multiple-cursors-core nil t)
                             (mc/all-fake-cursors)))
          (pt (point))
          (beg ivy-completion-beg)
          (end ivy-completion-end))
      (when beg
        (delete-region beg end))
      (setq ivy-completion-beg (point))
      (insert (substring-no-properties str))
      (completion--done str 'exact)
      (setq ivy-completion-end (point))
      (save-excursion
        (dolist (cursor fake-cursors)
          (goto-char (overlay-start cursor))
          (delete-region (+ (point) (- beg pt))
                         (+ (point) (- end pt)))
          (insert (substring-no-properties str))
          ;; manually move the fake cursor
          (move-overlay cursor (point) (1+ (point)))
          (set-marker (overlay-get cursor 'point) (point))
          (set-marker (overlay-get cursor 'mark) (point)))))))

(defun my/org-mode/load-prettify-symbols ()
  (interactive)
  (setq prettify-symbols-alist
	'(
	  ;; ("lambda" . "λ")
	  ;; ("|>" . "▷")
	  ;; ("<|" . "◁")
	  ;; ("->>" . "↠")
	  ;; ("->" . "→")
	  ;; ("<-" . "←")
	  ;; ("=>" . "⇒")
	  ("<=" . "≤")
	  ("!=" . "≠")
	  ("~=" . "≠")		  
	  (">=" . "≥"))
	)
  ;(prettify-symbols-mode 1)
  )

(load "~/.emacs.conf/my-xref-backpoint.lisp")

