(require 'lsp)
(require 'lsp-clients)
(require 'ivy-xref)
(require 'projectile)

;;(setq cquery-executable "/usr/local/bin/cquery")
;;(setq ccls-executable "/usr/local/bin/ccls")
(setq lsp-prefer-flymake nil)
(push "cscope.files" projectile-project-root-files)

(require 'flycheck-clangcheck)
(setq flycheck-clangcheck-analyze t)

(dolist (hook '(c-mode-hook c++-mode-hook))
  (add-hook hook
            #'(lambda ()
		;;		(message "cur major mode = %s" major-mode)
		(if (eq major-mode 'php-mode)
		    nil
                  ;;              (require 'cquery)
                  (require 'ccls)

		  ;;eglot config
		  ;; (eglot-ensure)
		  ;; (company-mode)
		  ;; (setq-local company-backends (add-to-list 'company-backends 'company-capf))

		  ;;lsp config
		  (setq-local ivy-completing-sort nil)
		  (setq-local ivy-sort-functions-alist (append (list (list 'ivy-done)) ivy-sort-functions-alist))
                (lsp)
		(flycheck-select-checker 'c/c++-clangcheck)
		(flymake-mode-off)
		(setq-local company-backends (add-to-list 'company-backends 'company-c-headers t))		
		(setq-local company-backends (add-to-list 'company-backends 'company-files t))
		;;头文件关闭flycheck，总是报错
		(if (string-match "\\.h$" buffer-file-name)
		    (flycheck-mode-off))
		))))

(dolist (hook '(typescript-mode-hook js-mode-hook js2-mode-hook rjsx-mode-hook))
  (add-hook hook
            #'(lambda ()
		(if (boundp 'js-mode-map)
		    (progn
		      (define-key js-mode-map [(meta ?,)] #'xref-find-references)		
		      (define-key js-mode-map [(meta ?.)] #'xref-find-definitions)))
		(setq-local ivy-completing-sort nil)
                (lsp))))

(dolist (hook '(python-mode-hook))
  (add-hook hook
            #'(lambda ()
		(setq-local ivy-completing-sort nil)		
                (lsp)
;;		(flymake-mode-off)
		)))

;; (push 'company-lsp company-backends)
(setq xref-show-xrefs-function #'ivy-xref-show-xrefs)
(setq xref-prompt-for-identifier '(not xref-find-references xref-find-definitions xref-find-definitions-other-window xref-find-definitions-other-frame))
;;(add-hook 'lsp-mode-hook 'lsp-ui-mode)
;;(global-set-key (kbd "M-.") (function rtags-find-symbol-at-point))
(global-set-key (kbd "M-,") (function xref-find-references))

(setq lsp-auto-guess-root nil)

;; 使用projectile来代替project选择项目目录
(defun projectile-project-find-function (dir)
  (let* ((root (projectile-project-root dir)))
    (and root (cons 'transient root))))

(with-eval-after-load 'project
  (add-to-list 'project-find-functions 'projectile-project-find-function))


(defun flycheck-mode-on ()
  "Turn Flymake mode on."
  (flycheck-mode 1))

;;;###autoload
(defun flycheck-mode-off ()
  "Turn Flymake mode off."
  (flycheck-mode 0))


;;避免太多的无用信息
(defun lsp--imenu-create-index ()
  "Create imenu index from document symbols."
  (let ((symbols (lsp--get-document-symbols)))
    ;; (if (lsp--imenu-hierarchical-p symbols)
    ;;     (lsp--imenu-create-hierarchical-index symbols)
      (mapcar (lambda (nested-alist)
                (cons (car nested-alist)
                      (mapcar #'lsp--symbol-to-imenu-elem (cdr nested-alist))))
              (seq-group-by #'lsp--get-symbol-type (lsp--imenu-filter-symbols symbols)))))
;; )
