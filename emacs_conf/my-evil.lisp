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
;; (define-key evil-emacs-state-map " p" 'point-to-register)
;; (define-key evil-emacs-state-map " j" 'jump-to-register)
(define-key evil-emacs-state-map " b" 'counsel-ibuffer)
(define-key evil-emacs-state-map " s" 'swiper)
(define-key evil-emacs-state-map " n" 'er/expand-region)
(define-key evil-emacs-state-map " u" 'backward-up-list)
(define-key evil-emacs-state-map " d" 'forward-sexp)
(define-key evil-emacs-state-map " tt" 'my-counsel-rag)
(define-key evil-emacs-state-map " ts" 'my-counsel-rag-sp)
(define-key evil-emacs-state-map " tp" 'my-counsel-proto)
(define-key evil-emacs-state-map "t" 'my-counsel-rag)
(define-key evil-emacs-state-map " a" 'aweshell-dedicated-toggle)
(define-key evil-emacs-state-map " y" 'ivy-yasnippet)
(define-key evil-emacs-state-map " \t" (lambda() (interactive)
					 (if (region-active-p)
					     (clang-format-region (region-beginning) (region-end)))))

;;
(define-key evil-emacs-state-map " vp" 'previous-buffer)
(define-key evil-emacs-state-map " vn" 'next-buffer)
;; auto-yasnippet
(define-key evil-emacs-state-map " vac" 'aya-create)
(define-key evil-emacs-state-map " vae" 'aya-expand)
(define-key evil-emacs-state-map " vah" 'aya-expand-from-history)
(define-key evil-emacs-state-map " vap" 'aya-persist-snippet)

;;gtags
(define-key evil-emacs-state-map " gu" 'my-gtags-set-default)
(define-key evil-emacs-state-map " go" 'my-gtags-show-use)
;; (define-key evil-emacs-state-map " gs" 'counsel-gtags-find-symbol)
;; (define-key evil-emacs-state-map " g," 'counsel-gtags-find-reference)
;; (define-key evil-emacs-state-map " g." 'counsel-gtags-find-definition)
;; (define-key evil-emacs-state-map " gw" 'counsel-gtags-dwim)
;; (define-key evil-emacs-state-map " gi" 'counsel-gtags-find-file)

;; (define-key evil-emacs-state-map " gp" 'gtags-point-stack-backward)
;; (define-key evil-emacs-state-map " gn" 'gtags-point-stack-forward)
;; (define-key evil-emacs-state-map " ga" 'gtags-point-stack-first)
;; (define-key evil-emacs-state-map " ge" 'gtags-point-stack-last)
;; (define-key evil-emacs-state-map " gl" 'gtags-point-stack-current)
;; (define-key evil-emacs-state-map " gd" 'gtags-point-stack-delete)
;; (define-key evil-emacs-state-map " gc" 'gtags-point-stack-clear)
;; (define-key evil-emacs-state-map " go" 'gtags-point-stack-show)

;;lsp
(define-key evil-emacs-state-map " lo" 'my-xref-show)
(define-key evil-emacs-state-map " lp" 'my-xref-pre)
(define-key evil-emacs-state-map " ln" 'my-xref-next)
(define-key evil-emacs-state-map " ll" 'my-xref-cur)
(define-key evil-emacs-state-map " l," 'my-xref-first)
(define-key evil-emacs-state-map " l." 'my-xref-last)
(define-key evil-emacs-state-map " lc" 'my-xref-clear)
(define-key evil-emacs-state-map " la" 'xref-find-apropos)
(define-key evil-emacs-state-map " ls" (lambda() (interactive)(lsp-ivy-global-workspace-symbol 1)))
;;(define-key evil-emacs-state-map " lr" 'rtags-find-references)
(define-key evil-emacs-state-map " li" 'lsp-describe-thing-at-point)
;;(define-key evil-emacs-state-map " lc" 'rtags-ivy-rc)
(define-key evil-emacs-state-map " lk" 'lsp-restart-workspace)
(define-key evil-emacs-state-map " ld" 'lsp-ui-peek-find-definitions)
(define-key evil-emacs-state-map " lr" 'lsp-ui-peek-find-references)
(define-key evil-emacs-state-map " lg" (lambda() (interactive)
					 (if (eq major-mode 'go-mode)
					     (call-interactively  'godef-jump)
					   (message "not in go mode")
					 )))

;;hs-minor-mode
(define-key evil-emacs-state-map " hm" 'hs-minor-mode)
(define-key evil-emacs-state-map " hhb" 'hs-show-block)
(define-key evil-emacs-state-map " hs" 'hs-show-all)
(define-key evil-emacs-state-map " ht" 'hs-toggle-hiding)
(define-key evil-emacs-state-map " ha" 'hs-hide-all)
(define-key evil-emacs-state-map " hb" (lambda() (interactive)
					  (xref-push-marker-stack)
					  (call-interactively 'hs-hide-block)
					  ))

;; ;;rtags
;; (define-key evil-emacs-state-map " rp" 'rtags-location-stack-back)
;; (define-key evil-emacs-state-map " rn" 'rtags-location-stack-forward)
;; (define-key evil-emacs-state-map " rs" 'rtags-find-symbol)
;; (define-key evil-emacs-state-map " rr" 'rtags-find-references)
;; (define-key evil-emacs-state-map " ri" 'rtags-symbol-info)
;; (define-key evil-emacs-state-map " rc" 'rtags-ivy-rc)
;; (define-key evil-emacs-state-map " rk" 'irony-server-kill)

;;narrowing
(define-key evil-emacs-state-map " rn" 'narrow-to-region)
(define-key evil-emacs-state-map " rw" 'widen)
(define-key evil-emacs-state-map " rd" 'narrow-to-defun)

;;ivy
(define-key evil-emacs-state-map " ir" 'ivy-resume)
(define-key evil-emacs-state-map " ii" 'counsel-imenu)
;;etags
;; (define-key evil-emacs-state-map " es" 'my-etags-find-tag)
;; (define-key evil-emacs-state-map " ep" 'pop-tag-mark)
;;file
(define-key evil-emacs-state-map " ff" 'counsel-find-file)
(define-key evil-emacs-state-map " fa" (lambda() (interactive)(switch-to-buffer "*scratch*")))
(define-key evil-emacs-state-map " fm" (lambda() (interactive)(switch-to-buffer "*Messages*")))
;;(define-key evil-emacs-state-map " fc" (lambda() (interactive)(find-file "~/.emacs.conf/emacs.conf")))
(define-key evil-emacs-state-map " fk" (lambda() (interactive)(find-file "~/.emacs.conf/my-evil.lisp")))
(define-key evil-emacs-state-map " fo" (lambda() (interactive)(find-file "~/.emacs.conf/other.lisp")))
(define-key evil-emacs-state-map " fp" (lambda() (interactive)(find-file "~/.emacs.conf/package.conf")))
(define-key evil-emacs-state-map " fs" (lambda() (interactive)(my-enter-shell)(delete-other-windows)))
(define-key evil-emacs-state-map " fv" (lambda() (interactive)(call-interactively #'vterm)(delete-other-windows)))
(define-key evil-emacs-state-map " fy" 'spacemacs/show-and-copy-buffer-filename)
(define-key evil-emacs-state-map " fr" 'refresh-file)

(define-key evil-emacs-state-map " fc" (lambda() (interactive)
  (if (string-match "chinese" (format "%s" buffer-file-coding-system))
      (let ((coding-system-for-read (merge-coding-systems 'utf-8 buffer-file-coding-system)))
        (revert-buffer nil t))
    (let ((coding-system-for-read (merge-coding-systems 'gb18030 buffer-file-coding-system)))
      (revert-buffer nil t))
    )))
					 
(define-key evil-emacs-state-map " fe" 'spacemacs/sudo-edit)
(define-key evil-emacs-state-map " fw" 'kill-current-buffer)
(define-key evil-emacs-state-map " flf" 'flycheck-first-error)
(define-key evil-emacs-state-map " flp" 'flycheck-previous-error)
(define-key evil-emacs-state-map " fln" 'flycheck-next-error)
(define-key evil-emacs-state-map " flb" 'flycheck-buffer)
(define-key evil-emacs-state-map " flc" 'flycheck-clear)
(define-key evil-emacs-state-map " flm" 'flycheck-mode)
(define-key evil-emacs-state-map " fll" 'flycheck-list-errors)
;;cscope
;; (define-key evil-emacs-state-map " cg" 'cscope-find-global-definition)
;; (define-key evil-emacs-state-map " ct" 'cscope-find-this-text-string)
;; (define-key evil-emacs-state-map " cs" 'cscope-find-this-symbol)
(define-key evil-emacs-state-map " cf" 'my-key/ivy-cscope-file)
(define-key evil-emacs-state-map " co" 'my-find-cscope-other-file)
;; (define-key evil-emacs-state-map " ce" 'cscope-find-egrep-pattern)
;; (define-key evil-emacs-state-map " ci" 'cscope-set-initial-directory)
;; (define-key evil-emacs-state-map " cc" 'cscope-find-functions-calling-this-function)
;; (define-key evil-emacs-state-map " cp" 'cscope-pop-mark)
(define-key evil-emacs-state-map " c." 'company-tabnine)
;; company
(defun my-set-company-backend (backend)
  (setq company-backends (delete backend company-backends))
  (push backend company-backends)
  (message "company backends: %s" company-backends)
  )
(define-key evil-emacs-state-map " cc" (lambda() (interactive)(my-set-company-backend 'company-capf)))
(define-key evil-emacs-state-map " ct" (lambda() (interactive)(my-set-company-backend 'company-tabnine)))
(define-key evil-emacs-state-map " cg" (lambda() (interactive)(my-set-company-backend 'company-gtags)))
(define-key evil-emacs-state-map " cy" 'counsel-yank-pop)
(define-key evil-emacs-state-map " cb" (lambda() (interactive)(erase-buffer)))

;; my-jump
(define-key evil-emacs-state-map " oo" 'point-stack-show)
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
(define-key evil-emacs-state-map "f" (lambda() (interactive)
				       (if (and (eq major-mode 'vterm-mode) (eq (point) (vterm--get-cursor-point)))
					   (vterm-send-C-f)
					 (call-interactively #'forward-char))))

(define-key evil-emacs-state-map "b" (lambda() (interactive)
				       (if (and (eq major-mode 'vterm-mode) (eq (point) (vterm--get-cursor-point)))
					   (vterm-send-C-b)
					 (call-interactively #'backward-char))))

(define-key evil-emacs-state-map "F" (lambda() (interactive)
				       (if (and (eq major-mode 'vterm-mode) (eq (point) (vterm--get-cursor-point)))
					   (vterm-send-M-f)
					 (call-interactively #'forward-word))))

(define-key evil-emacs-state-map "B" (lambda() (interactive)
				       (if (and (eq major-mode 'vterm-mode) (eq (point) (vterm--get-cursor-point)))
					   (vterm-send-M-b)
					 (call-interactively #'backward-word))))


(define-key evil-emacs-state-map "v" 'scroll-up-command)
(define-key evil-emacs-state-map "V" 'scroll-down-command)
(define-key evil-emacs-state-map "w" 'kill-ring-save)
(define-key evil-emacs-state-map "\M-w" 'kill-region)
(define-key evil-emacs-state-map "z" 'repeat)
(define-key evil-emacs-state-map "g" 'goto-line)
(define-key evil-emacs-state-map "s" (lambda() (interactive)
				       (if (eq major-mode 'vterm-mode)
					   (insert-char 115)					   
					 (if (eq major-mode 'eshell-mode)
					     (insert-char 115)
					   (save-buffer)))))

(define-key evil-emacs-state-map "d" (lambda() (interactive)
				       (if (eq major-mode 'vterm-mode)
					   (vterm-send-C-d)
					 (if (region-active-p)
					     (call-interactively #'kill-region)
					   (call-interactively #'delete-char)))))
(define-key evil-emacs-state-map "k" (lambda() (interactive)
				       (if (and (eq major-mode 'vterm-mode) (eq (point) (vterm--get-cursor-point)))
					   (vterm-send-C-k)
					 (call-interactively #'kill-line))))


(define-key evil-emacs-state-map "oo" 'other-window)
(define-key evil-emacs-state-map "or" 'redraw-display)
(define-key evil-emacs-state-map "of" 'delete-other-windows)
(define-key evil-emacs-state-map "o1" 'delete-other-windows)
(define-key evil-emacs-state-map "o2" 'split-window-below)
(define-key evil-emacs-state-map "o3" 'split-window-right)
(define-key evil-emacs-state-map "o0" 'delete-window)

(define-key evil-emacs-state-map "om"
  (lambda() (interactive)
    (magit-status)
    (evil-mode -1)))
(define-key evil-emacs-state-map "x" 'counsel-M-x)
(define-key evil-emacs-state-map "u" (lambda() (interactive)
				       (if (eq major-mode 'vterm-mode)
					   (vterm-undo)
					 (call-interactively #'undo-fu-only-undo))))

(define-key evil-emacs-state-map "m" 'set-mark-command)
(define-key evil-emacs-state-map "r" 'undo-fu-only-redo)
(define-key evil-emacs-state-map "y" 'yank)
(define-key evil-emacs-state-map "a" (lambda() (interactive)
				       (if (and (eq major-mode 'vterm-mode) (eq (point) (vterm--get-cursor-point)))
					   (vterm-send-C-a)
				       (if (functionp 'eshell-bol)
					   (eshell-bol)
				       (beginning-of-line)))))
(define-key evil-emacs-state-map "e" (lambda() (interactive)
				       (if (and (eq major-mode 'vterm-mode) (eq (point) (vterm--get-cursor-point)))
					   (vterm-send-C-e)
					 (call-interactively #'move-end-of-line))))

(define-key evil-emacs-state-map "," 'beginning-of-buffer)
(define-key evil-emacs-state-map "." (lambda() (interactive)
				       (if (eq major-mode 'vterm-mode)
					   (vterm-reset-cursor-point)
					 (call-interactively #'end-of-buffer))))

(define-key evil-emacs-state-map "l" 'recenter-top-bottom)
(define-key evil-emacs-state-map "j" 'avy-goto-word-1)
(define-key evil-emacs-state-map " j" 'avy-goto-char-timer)
;; (define-key evil-emacs-state-map "(" (lambda() (interactive)
;; 					(insert-char #x28)
;; 					(yank)
;; 					(insert-char #x29)))


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
(define-key evil-emacs-state-map (kbd "h <RET>") (lambda() (interactive)(insert-char 10)))

;; evil match it
(global-evil-matchit-mode 1)
(define-key evil-emacs-state-map " m" 'evilmi-jump-items)

(define-key evil-emacs-state-map " hhx" 'save-buffers-kill-terminal)
(define-key evil-emacs-state-map " hhp" 'previous-buffer)
(define-key evil-emacs-state-map " hhn" 'next-buffer)

(define-key evil-emacs-state-map " lf" 'my-cousel-lua-function)
(define-key evil-emacs-state-map " hhf" 'my-cousel-lua-function)
