(if (not (package-installed-p 'xref '(1 5 1)))
    (message "xref version too low, reinstall it")
    )

(defvar xref--cur-pos 0)

(defun my-goto-xref-curpos ()
  (let* ((back_ring (car xref--history))
	 (forward_ring (cdr xref--history))
	 (back-len (length back_ring))
	 (forward-len (length forward_ring)) 
	 (cur-len (+ back-len forward-len))
	 (target)
	 )
    (when (= 0 cur-len)
      (user-error "Marker stack is empty"))
    (if (< xref--cur-pos 0)
	(setq xref--cur-pos 0))
    (if (>= xref--cur-pos cur-len)
	(setq xref--cur-pos (- cur-len 1)))

    (if (< xref--cur-pos forward-len)
	(setq target (nth (- (- forward-len xref--cur-pos) 1) forward_ring))
	(setq target (nth (- xref--cur-pos forward-len) back_ring))      
	)
      (switch-to-buffer (or (marker-buffer target)
                            (user-error "The marked buffer has been deleted")))
      (goto-char (marker-position target))
    
    ;; (let ((marker (ring-ref ring xref--cur-pos)))
    ;;   (switch-to-buffer (or (marker-buffer marker)
    ;;                         (user-error "The marked buffer has been deleted")))
    ;;   (goto-char (marker-position marker)))
    (message "xref %s/%s" xref--cur-pos cur-len)    
  ))
(defun my-xref-cur ()
  (interactive)
  (my-goto-xref-curpos)
  )

(defun my-xref-first ()
  (interactive)
  (setq xref--cur-pos 0)
  (my-goto-xref-curpos)  
  )
(defun my-xref-last ()
  (interactive)
  (let* ((back_ring (car xref--history))
	 (forward_ring (cdr xref--history))
	 (back-len (length back_ring))
	 (forward-len (length forward_ring)) 
	 (cur-len (+ back-len forward-len))
	 )
    (setq xref--cur-pos (- cur-len 1)))
    (my-goto-xref-curpos)
    )

(defun my-show-marker-info (cur tmp)
  (let ((t_str ""))
    (if (buffer-live-p (marker-buffer tmp))
    (save-excursion
    (with-current-buffer (marker-buffer tmp)
      (goto-char (marker-position tmp))
      (if (eq cur xref--cur-pos)
	  (setq t_str (concat t_str (format "*%s: [%s:%s]%s\n" cur (buffer-name) (line-number-at-pos)
		    (buffer-substring-no-properties (line-beginning-position) (line-end-position) ))))
	(setq t_str (concat t_str (format " %s: [%s:%s]%s\n" cur (buffer-name) (line-number-at-pos)
		    (buffer-substring-no-properties (line-beginning-position) (line-end-position) )))))
      ))
    ;;else
      (if (eq cur xref--cur-pos)    
	  (setq t_str (concat t_str (format "*%s: deleted\n" cur)))
	  (setq t_str (concat t_str (format " %s: deleted\n" cur))))	
      );;if
    t_str
  ))


(defun my-xref-show ()
  "show current point in stack."
  (interactive)
  (let* ((back_ring (car xref--history))
	 (forward_ring (cdr xref--history))
	 (back-len (length back_ring))
	 (forward-len (length forward_ring)) 
	 (cur-len (+ back-len forward-len))
	 (tmp)
	 (t_str "")
	 (cur 0)
	 (cur2 0)	 
	 )
    (when (= 0 cur-len)
      (user-error "Marker stack is empty"))
    
    (setq cur (- forward-len 1))
    (while (>= cur 0)
	(setq tmp (nth cur forward_ring))
	(setq t_str (concat t_str (my-show-marker-info cur2 tmp)))
	(setq cur (- cur 1))
	(setq cur2 (+ cur2 1))
	)
    (setq cur 0)    
    (while (< cur back-len)
	(setq tmp (nth cur back_ring))
	(setq t_str (concat t_str (my-show-marker-info cur2 tmp)))
	(setq cur (+ cur 1))
	(setq cur2 (+ cur2 1))
	)
    
  (setq t_str (concat t_str (format "%s/%s" xref--cur-pos cur-len)))  
  (message "%s" t_str)
    ))

(defun my-xref-next ()
  (interactive)
  (let* ((back_ring (car xref--history))
	 (forward_ring (cdr xref--history))
	 (back-len (length back_ring))
	 (forward-len (length forward_ring)) 
	 (cur-len (+ back-len forward-len))
	 )
    (setq xref--cur-pos (+ xref--cur-pos 1))
    (if (< xref--cur-pos 0)
	(setq xref--cur-pos 0))
    (if (>= xref--cur-pos cur-len)
	(setq xref--cur-pos (- cur-len 1)))
    (my-goto-xref-curpos)    
  ))

(defun my-xref-pre ()
  (interactive)
    (setq xref--cur-pos (- xref--cur-pos 1))
    (if (< xref--cur-pos 0)
	(setq xref--cur-pos 0))
    (my-goto-xref-curpos)        
  )
(defun my-xref-clear ()
  ""
  (interactive)
  (xref-clear-marker-stack)
    )
