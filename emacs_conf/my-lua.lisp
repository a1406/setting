;; ;; lua mode 要在新版emacs（27）上运行，需要如下修改
;; (setq rx-parent nil)
;; (defun lua--rx-symbol (form)
;;   ;; form is a list (symbol XXX ...)
;;   ;; Skip initial 'symbol
;;   (setq form (cdr form))
;;   ;; If there's only one element, take it from the list, otherwise wrap the
;;   ;; whole list into `(or XXX ...)' form.
;;   (setq form (if (eq 1 (length form))
;;                  (car form)
;;                (append '(or) form)))
;;   ;; (rx-form `(seq symbol-start ,form symbol-end) rx-parent))
;;   (rx-to-string `(seq symbol-start ,form symbol-end) rx-parent))    

(defun my-after-cousel-rag ()
  (let* ((cmd (format "%s" this-command)))
    (if (string-equal "minibuffer-keyboard-quit" cmd)
	(progn
      (message "my-after-counsel-rag22, cmd = %s, last = %s, real last = %s" cmd last-command real-last-command)
    (setq counsel-ag-function-hook nil)))
  ))


(add-hook 'post-command-hook #'my-after-cousel-rag)


(defun my-lua-function-hook-func (regex)
  (setq regex (format "function.*%s|%s.*function" regex regex))
)

(setq counsel-ag-function-hook nil)
(defun counsel-ag-function (string)
  "Grep in the current directory for STRING."
  (let* ((command-args (counsel--split-command-args string))
         (search-term (cdr command-args)))
    (or
     (let ((ivy-text search-term))
       (ivy-more-chars))
     (let* ((default-directory (ivy-state-directory ivy-last))
            (regex (counsel--grep-regex search-term))
            (switches (concat (if (ivy--case-fold-p string)
                                  " -i "
                                " -s ")
                              (counsel--ag-extra-switches regex)
                              (car command-args))))

       (if (functionp counsel-ag-function-hook)
	   (setq regex (funcall counsel-ag-function-hook regex))) 
       (counsel--async-command (counsel--format-ag-command
                                switches
                                (funcall (if (listp counsel-ag-command) #'identity
                                           #'shell-quote-argument)
                                         regex)))
       nil))))


(define-key evil-emacs-state-map " hhf" (lambda() (interactive)
					  (setq counsel-ag-function-hook 'my-lua-function-hook-func)
					  (my-counsel-rag)
					  (setq counsel-ag-function-hook nil)
					  ))

