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

(defun point-stack-push ()
  "Push current point in stack."
  (interactive)
  (message "Location marked.")
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

(defun point-stack-last ()
  "forward last point from stack."
  (interactive)
  (if (or (null point-stack)
	  (null point-cur))
      (message "Stack is empty.")
    (switch-to-buffer (caar point-stack))
    (goto-char (cadar point-stack))
    (setq point-cur 0)    
))

(defun point-stack-forward ()
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
	  (goto-char (cadr tmp)))
	  
      (if (eq 0 point-cur)
	  (message "Stack at top")
	(setq point-cur (- point-cur 1))
	(setq tmp (nth point-cur point-stack))
	(switch-to-buffer (car tmp))
	(goto-char (cadr tmp))
	)))))

(defun point-stack-backward ()
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
	  (goto-char (cadr tmp)))
    
    (if (<= (length point-stack) (+ 1 point-cur))    
	(message "Stack at bottom")
      (setq point-cur (+ point-cur 1))
      (setq tmp (nth point-cur point-stack))
      (switch-to-buffer (car tmp))
      (goto-char (cadr tmp))
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

      (setq point-stack (my-nth-remove point-cur point-stack))))))
