(defun my-go-mode-common-hook ()
  ;; add my personal style and set it for the current buffer
  (hs-minor-mode t)
  (flycheck-mode t)
  ;; other customizations
  (setq tab-width 4)
  (local-set-key "\C-c\C-h" 'hs-hide-block)
  (local-set-key "\C-c\C-j" 'hs-show-block)
  (local-set-key "\C-c\C-k" 'hs-show-all)
  (if (functionp 'display-line-numbers-mode)
	  (display-line-numbers-mode)
	(linum-mode 1))

  ;; (define-key go-mode-map (kbd "TAB") 'tab-indent-or-complete)
  (define-key go-mode-map "\C-c\C-c"  'comment-or-uncomment-region)
  ;; (define-key go-mode-map (kbd "M-.") 'godef-jump)  
  (lsp)
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t)
  (lsp-register-custom-settings
   '(("gopls.completeUnimported" t t)
     ("gopls.staticcheck" t t)))
  (if my-use-gtags-default
      (add-to-list 'xref-backend-functions 'global-tags-xref-backend)	
      )
  (flymake-mode-off)
  (flycheck-select-checker 'go-gofmt)
  )

(add-hook 'go-mode-hook 'my-go-mode-common-hook)

;; buffer-file-name 为空会报错
(defun my-go-plain_gopath (orig-fun &rest args)
  ;; (message "display-buffer called with args %S" args)
  (if buffer-file-name  
  (let ((res (apply orig-fun args)))
    res)))
(advice-add 'go-plain-gopath :around #'my-go-plain_gopath)

;; 没有src可以通过cscope.files来设置
(defun my-go-guess-gopath (orig-fun &rest args)
  (let ((res (apply orig-fun args)))
    (if res
	res
      (my-cscope-guess-root-directory)
      )))
(advice-add 'go-guess-gopath :around #'my-go-guess-gopath)
