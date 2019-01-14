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
(define-key evil-emacs-state-map " x" 'save-buffers-kill-terminal)
(define-key evil-emacs-state-map " b" 'ivy-switch-buffer)
(define-key evil-emacs-state-map " s" 'swiper)
(define-key evil-emacs-state-map " n" 'er/expand-region)
(define-key evil-emacs-state-map " t" 'my-counsel-rag)
(define-key evil-emacs-state-map "t" 'my-counsel-rag)

;;lsp
(define-key evil-emacs-state-map " lp" 'my-xref-pre)
(define-key evil-emacs-state-map " ln" 'my-xref-next)
(define-key evil-emacs-state-map " ll" 'my-xref-cur)
(define-key evil-emacs-state-map " lf" 'my-xref-first)
(define-key evil-emacs-state-map " ls" 'xref-find-apropos)
;;(define-key evil-emacs-state-map " lr" 'rtags-find-references)
(define-key evil-emacs-state-map " li" 'lsp-describe-thing-at-point)
;;(define-key evil-emacs-state-map " lc" 'rtags-ivy-rc)
(define-key evil-emacs-state-map " lk" 'lsp-restart-workspace)

;;rtags
(define-key evil-emacs-state-map " rp" 'rtags-location-stack-back)
(define-key evil-emacs-state-map " rn" 'rtags-location-stack-forward)
(define-key evil-emacs-state-map " rs" 'rtags-find-symbol)
(define-key evil-emacs-state-map " rr" 'rtags-find-references)
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
(define-key evil-emacs-state-map " fw" 'kill-current-buffer)
(define-key evil-emacs-state-map " flf" 'flycheck-first-error)
(define-key evil-emacs-state-map " flp" 'flycheck-previous-error)
(define-key evil-emacs-state-map " fln" 'flycheck-next-error)
;;cscope
(define-key evil-emacs-state-map " cg" 'cscope-find-global-definition)
(define-key evil-emacs-state-map " ct" 'cscope-find-this-text-string)
(define-key evil-emacs-state-map " cs" 'cscope-find-this-symbol)
(define-key evil-emacs-state-map " cf" 'my-key/ivy-cscope-file)
(define-key evil-emacs-state-map " co" 'my-find-cscope-other-file)
(define-key evil-emacs-state-map " ce" 'cscope-find-egrep-pattern)
(define-key evil-emacs-state-map " ci" 'cscope-set-initial-directory)
(define-key evil-emacs-state-map " cc" 'cscope-find-functions-calling-this-function)
(define-key evil-emacs-state-map " cp" 'cscope-pop-mark)

;; my-jump
(define-key evil-emacs-state-map " of" 'point-stack-forward)
(define-key evil-emacs-state-map " ol" 'point-stack-current)
(define-key evil-emacs-state-map " o," 'point-stack-first)
(define-key evil-emacs-state-map " o." 'point-stack-last)
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
(define-key evil-emacs-state-map "z" 'repeat)
(define-key evil-emacs-state-map "g" 'goto-line)
(define-key evil-emacs-state-map "s" 'save-buffer)
(define-key evil-emacs-state-map "d" (lambda() (interactive)
				       (if (region-active-p)
					   (call-interactively #'kill-region)
					 (call-interactively #'delete-char))))
(define-key evil-emacs-state-map "k" 'kill-line)
(define-key evil-emacs-state-map "oo" 'other-window)
(define-key evil-emacs-state-map "of" 'delete-other-windows)
(define-key evil-emacs-state-map "x" 'counsel-M-x)
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
;;(define-key evil-emacs-state-map "q" 'evil-mode)

;;(define-key evil-emacs-state-map "" ')


;;使用ha  hb  hA  hB插入单个字符
(let ((ii 97)
      (ch)
      )
  (while (< ii (+ 97 26))
    (setq ch (format "(define-key evil-emacs-state-map \"h%s\" (lambda() (interactive)(insert-char %s)))"
		     (char-to-string ii) ii))
    (with-temp-buffer    (insert ch)    (eval-buffer))
    (setq ii (+ ii 1))
    )
  (setq ii 65)
  (while (< ii (+ 65 26))
    (setq ch (format "(define-key evil-emacs-state-map \"h%s\" (lambda() (interactive)(insert-char %s)))"
		     (char-to-string ii) ii))
    (with-temp-buffer    (insert ch)    (eval-buffer))
    (setq ii (+ ii 1))
    )

  (setq ii 44)
    (setq ch (format "(define-key evil-emacs-state-map \"h%s\" (lambda() (interactive)(insert-char %s)))"
		     (char-to-string ii) ii))
    (with-temp-buffer    (insert ch)    (eval-buffer))

  (setq ii 46)
    (setq ch (format "(define-key evil-emacs-state-map \"h%s\" (lambda() (interactive)(insert-char %s)))"
		     (char-to-string ii) ii))
    (with-temp-buffer    (insert ch)    (eval-buffer))
  )
