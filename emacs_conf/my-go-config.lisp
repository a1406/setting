
;; Customizations for all modes in CC Mode.
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

  (define-key go-mode-map (kbd "TAB") 'tab-indent-or-complete)
  (define-key go-mode-map "\C-c\C-c"  'comment-or-uncomment-region)
  ;; (define-key go-mode-map (kbd "M-.") 'godef-jump)  
  (lsp)
  (flycheck-select-checker 'lsp-ui)
  (flymake-mode-off)
  )

(add-hook 'go-mode-hook 'my-go-mode-common-hook)

