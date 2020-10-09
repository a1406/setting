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

