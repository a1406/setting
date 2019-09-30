;; lua mode 要在新版emacs（27）上运行，需要如下修改
(setq rx-parent nil)
(defun lua--rx-symbol (form)
  ;; form is a list (symbol XXX ...)
  ;; Skip initial 'symbol
  (setq form (cdr form))
  ;; If there's only one element, take it from the list, otherwise wrap the
  ;; whole list into `(or XXX ...)' form.
  (setq form (if (eq 1 (length form))
                 (car form)
               (append '(or) form)))
  ;; (rx-form `(seq symbol-start ,form symbol-end) rx-parent))
  (rx-to-string `(seq symbol-start ,form symbol-end) rx-parent))    
