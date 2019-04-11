(defvar point-stack nil)
(defvar point-cur nil)

(defun my-nth-remove (nth seq)
  (let ((n -1))
    (remove-if
     #'(lambda (p1)
	 ;;     (message "p1 = %s, n = %s" p1 n)
	 (setq n (+ n 1))
	 (if (eq n nth)
	     t
	   nil))
     seq))
  )

(defun point-stack-show ()
  "show current point in stack."
  (interactive)
(let* ((cur 0)
	 (tmp)
	 (t_str ""))
  (while (< cur (length point-stack))
    (setq tmp (nth cur point-stack))
    (if (buffer-live-p (car tmp))
    (save-excursion
    (with-current-buffer (car tmp)
      (goto-char (cadr tmp))
      (if (eq cur point-cur)
	  (setq t_str (concat t_str (format "*%s: %s\n" cur
		    (buffer-substring-no-properties (line-beginning-position) (line-end-position) ))))
	(setq t_str (concat t_str (format " %s: %s\n" cur
		    (buffer-substring-no-properties (line-beginning-position) (line-end-position) )))))
      ))
    ;;else
      (if (eq cur point-cur)    
	  (setq t_str (concat t_str (format "*%s: deleted\n" cur)))
	  (setq t_str (concat t_str (format " %s: deleted\n" cur))))	
      );;if
    (setq cur (+ cur 1))    
    );;while
  (if point-cur
      (setq t_str (concat t_str (format "%s/%s" point-cur (length point-stack)))))
  (message "%s" t_str)
))

(defun point-stack-push ()
  "Push current point in stack."
  (interactive)
  (message "Location marked. %s" (+ 1 (length point-stack)))
  (setq point-cur 0)
  (setq point-stack (cons (list (current-buffer) (point)) point-stack)))

(defun point-stack-pop ()
  "Pop point from stack."
  (interactive)
  (if (null point-stack)
      (message "Stack is empty.")
    (switch-to-buffer (caar point-stack))
    (goto-char (cadar point-stack))
    (setq point-cur 0)    
    (setq point-stack (cdr point-stack))))

(defun point-stack-clear ()
  "clear point from stack."
  (interactive)
  (setq point-cur nil)
  (setq point-stack nil))

(defun point-stack-first ()
  "forward first point from stack."
  (interactive)
  (if (or (null point-stack)
	  (null point-cur))
      (message "Stack is empty.")
    (setq point-cur 0)    
    (switch-to-buffer (caar point-stack))
    (goto-char (cadar point-stack))
  (message "point-stack. %s/%s" point-cur (length point-stack))
))
(defun point-stack-last ()
  "forward last point from stack."
  (interactive)
  (let (tmp)    
  (if (or (null point-stack)
	  (null point-cur))
      (message "Stack is empty.")
	(setq point-cur (- (length point-stack) 1))
	(setq tmp (nth point-cur point-stack))
	(switch-to-buffer (car tmp))
	(goto-char (cadr tmp))
	(message "point-stack. %s/%s" point-cur (length point-stack)))
  ))
(defun adust-point-cur ()
  ""
  (if (>= point-cur (length point-stack))
      (setq point-cur 0))
)
(defun point-stack-current ()
  "forward current point from stack."
  (interactive)
  (let (tmp)  
  (if (or (null point-stack)
	  (null point-cur))
      (message "Stack is empty.")
    (adust-point-cur)

    (setq tmp (nth point-cur point-stack))
    (switch-to-buffer (car tmp))
    (goto-char (cadr tmp))
    (message "point-stack. %s/%s" point-cur (length point-stack)))
))

(defun point-stack-backward ()
  "forward point from stack."
  (interactive)
  (let (tmp)
  (if (or (null point-stack)
	  (null point-cur))
      (message "Stack is empty.")
    (if (eq (length point-stack) 1)
	(progn
	  (setq tmp (nth 0 point-stack))
	  (switch-to-buffer (car tmp))
	  (goto-char (cadr tmp))
	  (message "point-stack. %s/%s" point-cur (length point-stack))	  
	  )
	  
      (if (eq 0 point-cur)
	  (message "Stack at top")
	(setq point-cur (- point-cur 1))
	(setq tmp (nth point-cur point-stack))
	(switch-to-buffer (car tmp))
	(goto-char (cadr tmp))
	(message "point-stack. %s/%s" point-cur (length point-stack))
	)))))

(defun point-stack-forward ()
  "backward point from stack."
  (interactive)
  (let (tmp)
  (if (or (null point-stack)
	  (null point-cur))
      (message "Stack is empty.")
    (if (eq (length point-stack) 1)
	(progn
	  (setq tmp (nth 0 point-stack))
	  (switch-to-buffer (car tmp))
	  (goto-char (cadr tmp))
	  (message "point-stack. %s/%s" point-cur (length point-stack))
	  )
    
    (if (<= (length point-stack) (+ 1 point-cur))    
	(message "Stack at bottom")
      (setq point-cur (+ point-cur 1))
      (setq tmp (nth point-cur point-stack))
      (switch-to-buffer (car tmp))
      (goto-char (cadr tmp))
	  (message "point-stack. %s/%s" point-cur (length point-stack))	  
  )))))

(defun point-stack-delete ()
  "delete current point from stack."
  (interactive)
  (let ((l))
  (if (or (null point-stack)
	  (null point-cur))
      (message "Stack is empty.")
    (setq l (length point-stack))
    (if (<= l 1)
	(point-stack-clear)
    (setq point-stack (my-nth-remove point-cur point-stack))))
  (message "point-stack. %s/%s" point-cur (length point-stack))  
  ))
