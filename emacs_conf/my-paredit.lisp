;; (require 'smartparens-config)
;;  (add-hook 'prog-mode-hook 'turn-on-smartparens-mode)
;;  (add-hook 'markdown-mode-hook 'turn-on-smartparens-mode)
;;  (setq sp-autoinsert-pair t)


(eval-after-load 'paredit
  '(progn
     (define-key paredit-mode-map (kbd "M-;")  nil)
     (define-key paredit-mode-map (kbd "{")  'paredit-open-curly)
     (define-key paredit-mode-map (kbd "}")  nil)
     (define-key paredit-mode-map (kbd "]")  nil)
     (define-key paredit-mode-map (kbd ")")  nil)     
))


