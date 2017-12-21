(custom-set-variables
  '(initial-frame-alist (quote ((fullscreen . fullscreen)))))
;; '(initial-frame-alist (quote ((fullscreen . maximized)))))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Source Code Pro" :foundry "adobe" :slant normal :weight normal :height 143 :width normal)))))

(load "~/.emacs.conf")
(load "~/.emacs_key.conf")
(if (file-exists-p "~/.other.lisp")
    (load "~/.other.lisp")
  )

