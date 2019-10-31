;; (load "~/.emacs.conf/global-tags.el")

(setq my-use-gtags-default nil)

(defun my-gtags-set-default ()
  "show current point in stack."
  (interactive)
  (if (and (boundp 'ggtags-mode) ggtags-mode)
      (progn
	(ggtags-mode 0)
	)
    (progn
      (ggtags-mode 1)      
      )
    )
  (message "xref backends = %s" xref-backend-functions)
  )
;; (defun my-gtags-set-default ()
;;   "show current point in stack."
;;   (interactive)
;;   (if my-use-gtags-default
;;       (progn
;; 	(setq my-use-gtags-default nil)
;; 	(setq xref-backend-functions (delete 'global-tags-xref-backend xref-backend-functions))	
;; 	)
;;     (progn
;;       (setq my-use-gtags-default t)
;;       (add-to-list 'xref-backend-functions 'global-tags-xref-backend)
;;       )
;;     )
;;   (message "xref backends = %s" xref-backend-functions)
;;   )

(defun gtags-point-stack-show ()
  "show current point in stack."
  (interactive)
(let* ((cur 0)
       (tmp)
       (buffer)
	 (line)       
	 (t_str ""))
  (if (or (null counsel-gtags--context)
	  (null counsel-gtags--context-position))
      (message "Stack is empty.")
  
  (while (< cur (length counsel-gtags--context))
    (setq tmp (nth cur counsel-gtags--context))
    (setq buffer (plist-get tmp :buffer))
    (setq line (plist-get tmp :line))    
    (if (buffer-live-p buffer)
    (save-excursion
    (with-current-buffer buffer
      (goto-char (point-min))
      (forward-line (1- line))      
      (if (eq cur counsel-gtags--context-position)
	  (setq t_str (concat t_str (format "*%s: [%s:%s]%s\n" cur (buffer-name) (line-number-at-pos)
		    (buffer-substring-no-properties (line-beginning-position) (line-end-position) ))))
	(setq t_str (concat t_str (format " %s: [%s:%s]%s\n" cur (buffer-name) (line-number-at-pos)
		    (buffer-substring-no-properties (line-beginning-position) (line-end-position) )))))
      ))
    ;;else
      (if (eq cur counsel-gtags--context-position)    
	  (setq t_str (concat t_str (format "*%s: deleted\n" cur)))
	  (setq t_str (concat t_str (format " %s: deleted\n" cur))))	
      );;if
    (setq cur (+ cur 1))    
    );;while
  (if point-cur
      (setq t_str (concat t_str (format "%s/%s" counsel-gtags--context-position (length counsel-gtags--context)))))
  (message "%s" t_str)
)))

(defun gtags-point-stack-clear ()
  "clear point from stack."
  (interactive)
  (setq counsel-gtags--context nil)
  (setq counsel-gtags--context-position 0))

(defun gtags-point-stack-first ()
  "forward first point from stack."
  (interactive)
  (if (or (null counsel-gtags--context)
	  (null counsel-gtags--context-position))
      (message "Stack is empty.")
    (setq counsel-gtags--context-position 0)
    (counsel-gtags--goto counsel-gtags--context-position)
  (message "point-stack. %s/%s" counsel-gtags--context-position (length counsel-gtags--context))
))
(defun gtags-point-stack-last ()
  "forward last point from stack."
  (interactive)
  (if (or (null counsel-gtags--context)
	  (null counsel-gtags--context-position))
      (message "Stack is empty.")
    (setq counsel-gtags--context-position (- (length counsel-gtags--context) 1))
    (counsel-gtags--goto counsel-gtags--context-position)
  (message "point-stack. %s/%s" counsel-gtags--context-position (length counsel-gtags--context))
  ))
(defun gtags-adust-point-cur ()
  ""
  (if (>= counsel-gtags--context-position (length counsel-gtags--context))
      (setq counsel-gtags--context-position 0))
)
(defun gtags-point-stack-current ()
  "forward current point from stack."
  (interactive)
  (if (or (null counsel-gtags--context)
	  (null counsel-gtags--context-position))
      (message "Stack is empty.")
    (gtags-adust-point-cur)
    
    (counsel-gtags--goto counsel-gtags--context-position)
  (message "point-stack. %s/%s" counsel-gtags--context-position (length counsel-gtags--context))
))

(defun gtags-point-stack-backward ()
  "forward point from stack."
  (interactive)
  (let (tmp)
  (if (or (null counsel-gtags--context)
	  (null counsel-gtags--context-position))
      (message "Stack is empty.")
    (if (eq (length counsel-gtags--context) 1)
	(progn
	  (counsel-gtags--goto 0)
	  (message "point-stack. %s/%s" counsel-gtags--context-position (length counsel-gtags--context))
	  )
	  
      (if (eq 0 counsel-gtags--context-position)
	  (message "Stack at top")
	(setq counsel-gtags--context-position (- counsel-gtags--context-position 1))
	(counsel-gtags--goto counsel-gtags--context-position)
	(message "point-stack. %s/%s" counsel-gtags--context-position (length counsel-gtags--context))
	)))))

(defun gtags-point-stack-forward ()
  "backward point from stack."
  (interactive)
  (let (tmp)
  (if (or (null counsel-gtags--context)
	  (null counsel-gtags--context-position))
      (message "Stack is empty.")

    (if (eq (length counsel-gtags--context) 1)
	(progn
	  (counsel-gtags--goto 0)
	  (message "point-stack. %s/%s" counsel-gtags--context-position (length counsel-gtags--context))
	  )
    
    (if (<= (length counsel-gtags--context) (+ 1 counsel-gtags--context-position))    
	(message "Stack at bottom")
      (setq counsel-gtags--context-position (+ counsel-gtags--context-position 1))
      (counsel-gtags--goto counsel-gtags--context-position)
      (message "point-stack. %s/%s" counsel-gtags--context-position (length counsel-gtags--context))
  )))))

(defun gtags-point-stack-delete ()
  "delete current point from stack."
  (interactive)
  (let ((l))
  (if (or (null counsel-gtags--context)
	  (null counsel-gtags--context-position))
      (message "Stack is empty.")
    (setq l (length counsel-gtags--context))
    (if (<= l 1)
	(gtags-point-stack-clear)
      (setq counsel-gtags--context (my-nth-remove counsel-gtags--context-position counsel-gtags--context))))
      (message "point-stack. %s/%s" counsel-gtags--context-position (length counsel-gtags--context))  
  ))
