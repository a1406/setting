(require 'evil)
(setq evil-default-state 'emacs)
(setq evil-insert-state-modes '())
(setq evil-motion-state-modes '())
(setq evil-want-abbrev-expand-on-insert-exit nil)
(setq evil-want-integration nil)
(setq evil-want-keybinding nil)
(setq evil-want-minibuffer nil)
(defun evil-generate-mode-line-tag (&optional state)
  "Generate the evil mode-line tag for STATE."
  (let ((tag (evil-state-property state :tag t)))
    ;; prepare mode-line: add tooltip
    (if (stringp tag)
        (propertize tag		    
                    'help-echo (evil-state-property state :name)
                    'mouse-face 'mode-line-highlight 'face '(:foreground "red"))
      tag)))

(global-set-key "\M-;" 'evil-mode)
;;;;;;;;;;;;;;;;;;;;;;;;NORMAL-MODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-key evil-emacs-state-map "  " (lambda() (interactive)(insert-char #x20)))
(define-key evil-emacs-state-map " p" 'point-to-register)
(define-key evil-emacs-state-map " j" 'jump-to-register)
(define-key evil-emacs-state-map " x" 'counsel-M-x)
(define-key evil-emacs-state-map " b" 'ivy-switch-buffer)
(define-key evil-emacs-state-map " s" 'swiper)
(define-key evil-emacs-state-map " t" (lambda() (interactive)(counsel-ag (thing-at-point 'symbol) cscope-initial-directory (format "-E %s/%s" cscope-initial-directory cscope-index-file) nil)))
(define-key evil-emacs-state-map "t" (lambda() (interactive)(counsel-ag (thing-at-point 'symbol) cscope-initial-directory (format "-E %s/%s" cscope-initial-directory cscope-index-file) nil)))

;;rtags
(define-key evil-emacs-state-map " rp" 'rtags-location-stack-back)
(define-key evil-emacs-state-map " rn" 'rtags-location-stack-forward)
(define-key evil-emacs-state-map " rq" 'rtags-find-symbol)
(define-key evil-emacs-state-map " ri" 'rtags-symbol-info)
(define-key evil-emacs-state-map " rc" 'rtags-ivy-rc)
(define-key evil-emacs-state-map " rk" 'irony-server-kill)
;;ivy
(define-key evil-emacs-state-map " ir" 'ivy-resume)
(define-key evil-emacs-state-map " ii" 'counsel-imenu)
;;etags
(define-key evil-emacs-state-map " es" 'my-etags-find-tag)
(define-key evil-emacs-state-map " ep" 'pop-tag-mark)
;;file
(define-key evil-emacs-state-map " ff" 'counsel-find-file)
(define-key evil-emacs-state-map " fa" (lambda() (interactive)(switch-to-buffer "*scratch*")))
(define-key evil-emacs-state-map " fm" (lambda() (interactive)(switch-to-buffer "*Messages*")))
(define-key evil-emacs-state-map " fc" (lambda() (interactive)(find-file "~/.emacs.conf/emacs.conf")))
(define-key evil-emacs-state-map " fk" (lambda() (interactive)(find-file "~/.emacs.conf/my-evil.lisp")))
(define-key evil-emacs-state-map " fo" (lambda() (interactive)(find-file "~/.emacs.conf/other.lisp")))
(define-key evil-emacs-state-map " fp" (lambda() (interactive)(find-file "~/.emacs.conf/package.conf")))
(define-key evil-emacs-state-map " fs" (lambda() (interactive)(my-enter-shell)(delete-other-windows)))
(define-key evil-emacs-state-map " fy" 'spacemacs/show-and-copy-buffer-filename)
(define-key evil-emacs-state-map " fr" 'refresh-file)
(define-key evil-emacs-state-map " fe" 'spacemacs/sudo-edit)
;;cscope
(define-key evil-emacs-state-map " cg" 'cscope-find-global-definition)
(define-key evil-emacs-state-map " ct" 'cscope-find-this-text-string)
(define-key evil-emacs-state-map " cs" 'cscope-find-this-symbol)
(define-key evil-emacs-state-map " cf" 'my-key/ivy-cscope-file)
(define-key evil-emacs-state-map " ce" 'cscope-find-egrep-pattern)
(define-key evil-emacs-state-map " ci" 'cscope-set-initial-directory)
(define-key evil-emacs-state-map " cc" 'cscope-find-functions-calling-this-function)
(define-key evil-emacs-state-map " cp" 'cscope-pop-mark)

;; my-jump
(define-key evil-emacs-state-map " of" 'point-stack-forward)
(define-key evil-emacs-state-map " ol" 'point-stack-last)
(define-key evil-emacs-state-map " ob" 'point-stack-backward)
(define-key evil-emacs-state-map " on" 'point-stack-forward)
(define-key evil-emacs-state-map " op" 'point-stack-backward)
(define-key evil-emacs-state-map " oc" 'point-stack-clear)
(define-key evil-emacs-state-map " os" 'point-stack-push)
(define-key evil-emacs-state-map " od" 'point-stack-delete) 


(define-key evil-emacs-state-map "c" 'comment-or-uncomment-region)
(define-key evil-emacs-state-map "n" 'next-line)
(define-key evil-emacs-state-map "p" 'previous-line)
;;(define-key evil-emacs-state-map "i" ')
(define-key evil-emacs-state-map "f" 'forward-char)
(define-key evil-emacs-state-map "b" 'backward-char)
(define-key evil-emacs-state-map "F" 'forward-word)
(define-key evil-emacs-state-map "B" 'backward-word)
(define-key evil-emacs-state-map "v" 'scroll-up-command)
(define-key evil-emacs-state-map "V" 'scroll-down-command)
(define-key evil-emacs-state-map "w" 'kill-ring-save)
(define-key evil-emacs-state-map "\M-w" 'kill-region)
(define-key evil-emacs-state-map "g" 'goto-line)
(define-key evil-emacs-state-map "s" 'save-buffer)
(define-key evil-emacs-state-map "d" 'delete-char)
(define-key evil-emacs-state-map "k" 'kill-line)
(define-key evil-emacs-state-map "o" 'other-window)
(define-key evil-emacs-state-map "x" 'save-buffers-kill-terminal)
(define-key evil-emacs-state-map "u" 'undo)
(define-key evil-emacs-state-map "r" 'undo-tree-redo)
(define-key evil-emacs-state-map "y" 'yank)
(define-key evil-emacs-state-map "m" 'set-mark-command)
(define-key evil-emacs-state-map "a" 'beginning-of-line)
(define-key evil-emacs-state-map "e" 'move-end-of-line)
(define-key evil-emacs-state-map "," 'beginning-of-buffer)
(define-key evil-emacs-state-map "." 'end-of-buffer)
(define-key evil-emacs-state-map "l" 'recenter-top-bottom)
(define-key evil-emacs-state-map "j" 'avy-goto-word-1)
(define-key evil-emacs-state-map "(" (lambda() (interactive)
					(insert-char #x28)
					(yank)
					(insert-char #x29)))


;;(define-key evil-emacs-state-map (kbd "<RET>") 'newline)
;;(define-key evil-emacs-state-map (kbd "<DEL>") 'delete-backward-char)

(define-key evil-emacs-state-map "i" 'evil-mode)
(define-key evil-emacs-state-map "I" 'evil-mode)
(define-key evil-emacs-state-map "q" 'evil-mode)

;;(define-key evil-emacs-state-map "" ')
