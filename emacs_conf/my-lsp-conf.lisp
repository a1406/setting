(require 'lsp)
;;(require 'lsp-clients)
(require 'lsp-ui)
(require 'ivy-xref)
(require 'projectile)

;;(setq cquery-executable "/usr/local/bin/cquery")
;;(setq ccls-executable "/usr/local/bin/ccls")
(setq lsp-prefer-flymake nil)
(push "cscope.files" projectile-project-root-files)

;; 打开文件得时候卡
;; (require 'flycheck-clangcheck)
;; (setq flycheck-clangcheck-analyze t)

(setq lsp-ui-doc-enable nil)
(setq lsp-ui-peek-enable nil)
(setq lsp-ui-sideline-enable nil)

(setq lsp-file-watch-threshold 10000)
(setq lsp-enable-file-watchers nil)
;; use `evil-matchit' instead
(setq lsp-enable-folding nil)
;; handle yasnippet by myself
(setq lsp-enable-snippet nil)
;; turn off for better performance
(setq lsp-enable-symbol-highlighting nil)
;; use ffip instead
(setq lsp-enable-links nil)
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024)) ;; 1mb
(setq lsp-prefer-capf t)
(setq lsp-idle-delay 0.500)

;;(require 'ccls)
;; (setq ccls-sem-highlight-method 'font-lock)
;; alternatively, (setq ccls-sem-highlight-method 'overlay)

;; For rainbow semantic highlighting
;;(ccls-use-default-rainbow-sem-highlight)
;;(face-spec-set 'ccls-sem-member-face
;;              '((t :slant "normal"))
;;               'face-defface-spec)
;;容易和expand-region颜色冲突，看不清楚
(setq lsp-enable-symbol-highlighting nil)

(setq my-use-lsp t)

(add-hook 'lsp-after-initialize-hook
	  #'(lambda ()
	      (if my-use-gtags-default
		  (add-to-list 'xref-backend-functions 'global-tags-xref-backend)	
		  )
	      (lsp-register-custom-settings
	       '(("gopls.completeUnimported" t t)
		 ("gopls.staticcheck" t t)))
	      ))

(dolist (hook '(c-mode-hook c++-mode-hook))
  (add-hook hook
            #'(lambda ()
		;;		(message "cur major mode = %s" major-mode)
		(if (eq major-mode 'php-mode)
		    nil
                  ;;              (require 'cquery)
		  ;;eglot config
		  ;; (eglot-ensure)
		  ;; (company-mode)
		  ;; (setq-local company-backends (add-to-list 'company-backends 'company-capf))
		    (require 'ccls)
		  ;;lsp config
		  (setq-local ivy-completing-sort nil)
		  (setq-local ivy-sort-functions-alist (append (list (list 'ivy-done)) ivy-sort-functions-alist))
		  (if my-use-lsp
                      (lsp))
		  (if my-use-gtags-default
		      (add-to-list 'xref-backend-functions 'global-tags-xref-backend)	
		      )
		  (if my-use-lsp		  
		      (flycheck-select-checker 'lsp-ui)
		      )
		(flymake-mode-off)
		(setq-local company-backends (add-to-list 'company-backends 'company-c-headers t))
		(setq-local company-backends (add-to-list 'company-backends 'company-files t))

		(setq-local company-c-headers-path-user (my-cscope-include-directory))

		;; (setq ccls-sem-highlight-method 'font-lock)
		;; ;; alternatively, (setq ccls-sem-highlight-method 'overlay)

		;; ;; For rainbow semantic highlighting
		;; (ccls-use-default-rainbow-sem-highlight)
		;; (face-spec-set 'ccls-sem-member-face
		;;              '((t :slant "normal"))
		;;               'face-defface-spec)

		;;头文件关闭flycheck，总是报错
		;; (if (string-match "\\.h" buffer-file-name)
		;;     (flycheck-mode-off))
		))))

(dolist (hook '(typescript-mode-hook js-mode-hook js2-mode-hook rjsx-mode-hook))
  (add-hook hook
            #'(lambda ()
		(if (boundp 'js-mode-map)
		    (progn
		      (define-key js-mode-map [(meta ?,)] #'xref-find-references)		
		      (define-key js-mode-map [(meta ?.)] #'xref-find-definitions)))
		(setq-local ivy-completing-sort nil)
		(if my-use-lsp		  
                    (lsp))
		)))

(require 'lsp-python-ms)
(setq lsp-python-ms-auto-install-server t)
(dolist (hook '(python-mode-hook))
  (add-hook hook
            #'(lambda ()
		;; (add-to-list 'lsp-disabled-clients 'pyls)
		;; (add-to-list 'lsp-enabled-clients 'mspyls)
		(setq-local ivy-completing-sort nil)
		(if my-use-lsp		  
                    (lsp))
;;		(flymake-mode-off)
		)))


;; (add-hook 'prog-mode-hook
;; 	  #'(lambda ()
;; 	      (message "prog mode hook jack")
;; 	      (setq company-backends (delete 'company-tabnine company-backends))
;; 	      (push 'company-tabnine company-backends)
;; 	      ))

;; (push 'company-lsp company-backends)
;; (setq xref-show-xrefs-function #'ivy-xref-show-xrefs)
;; (if (< emacs-major-version 27)
(setq xref-show-xrefs-function #'ivy-xref-show-xrefs)
(setq xref-show-definitions-function #'ivy-xref-show-defs)

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
;; (defun lsp--imenu-hierarchical-p (symbols)
;;   "Determine whether any element in SYMBOLS has children."
;;   nil
;;   )


;;避免flychecker弹出checker相关信息
(defun flycheck-verify-checker (checker)
  )

;; (add-hook 'lsp-after-initialize-hook (lambda ()
;; 	  (lsp-defun lsp-ivy--format-symbol-match
;; 	      ((&SymbolInformation :name :kind :container-name? :location (&Location :uri))
;; 	       project-root)
;; 	    "Convert the match returned by `lsp-mode` into a candidate string."
;; 	    (let* ((type (if (>= kind (length lsp-ivy-symbol-kind-to-face))
;; 			     nil
;; 			     (elt lsp-ivy-symbol-kind-to-face kind)))
;; 		   (typestr (if lsp-ivy-show-symbol-kind
;; 				(propertize (format "[%s] " (car type)) 'face (cdr type))
;; 				""))
		   
;; 		   (pathstr (if lsp-ivy-show-symbol-filename
;; 				(propertize (format " · %s" (file-relative-name (lsp--uri-to-path uri) project-root))
;; 					    'face font-lock-comment-face) "")))
;; 	      (concat typestr (if (or (null container-name?) (string-empty-p container-name?))
;; 				  (format "%s" name)
;; 				  (format "%s.%s" container-name? name)) pathstr))))
;; 	  )
