;; Here's a sample .emacs file that might help you along the way.  Just
;; copy this region and paste it into your .emacs file.  You may want to
;; change some of the actual values.

(defconst my-c-style
  '((c-tab-always-indent        . t)
	(c-comment-only-line-offset . 4)
	(c-hanging-braces-alist     . ((substatement-open after)
				   (brace-list-open)))
	(c-hanging-colons-alist     . ((member-init-intro before)
				   (inher-intro)
				   (case-label after)
				   (label after)
				   (access-label after)))
	(c-cleanup-list             . (scope-operator
				   empty-defun-braces
				   defun-close-semi))
	(c-offsets-alist            . ((arglist-close . c-lineup-arglist)
				   (substatement-open . 0)
				   (label . nil)
				   (arglist-cont-nonempty  . 4)
				   (case-label        . 4)
				   (block-open        . 0)
				   (knr-argdecl-intro . -)))
	(c-echo-syntactic-information-p . t)
	)
  "My C Programming Style")

;; offset customizations not in my-c-style
(setq c-offsets-alist '((member-init-intro . ++)))

;; Customizations for all modes in CC Mode.
(defun my-c-mode-common-hook ()
  ;; add my personal style and set it for the current buffer
  (hs-minor-mode t)
  (flycheck-mode t)
  ;; (enable-paredit-mode)
  (c-add-style "PERSONAL" my-c-style t)
  ;; other customizations
  (setq tab-width 4)
  ;; this will make sure spaces are used instead of tabs
  ;;  (setq indent-tabs-mode nil)
  ;; we like auto-newline and hungry-delete
  ;;(c-toggle-auto-hungry-state nil)
  ;; key bindings for all supported languages.  We can put these in
  ;; c-mode-base-map because c-mode-map, c++-mode-map, objc-mode-map,
  ;; java-mode-map, idl-mode-map, and pike-mode-map inherit from it.
  (local-set-key "\C-m" 'c-context-line-break)
  (local-set-key "\C-c\C-h" 'hs-hide-block)
  (local-set-key "\C-c\C-j" 'hs-show-block)
  (local-set-key "\C-c\C-k" 'hs-show-all)
;;  (local-set-key "\C-c\C-s" 'shell)
  (local-set-key "\C-c." (function rtags-find-symbol))
;;  (define-key c-mode-base-map "}"      (lambda() (interactive)(insert-char #x7D)))

  ;;  (local-set-key (kbd ",")
  ;;					#'(lambda ()
  ;;					   (interactive)
  ;;                    (insert ", ")))

;;  (if (> (point-max) 100000)
;;      (linum-mode 0)
  ;;      (linum-mode 1))
  (if (functionp 'display-line-numbers-mode)
	  (display-line-numbers-mode)
	(linum-mode 1))
  (c-set-offset 'statement-case-intro 4)
  (c-set-offset 'substatement-label 4)

  (define-key c-mode-map (kbd "TAB") 'tab-indent-or-complete)
  (define-key c++-mode-map (kbd "TAB") 'tab-indent-or-complete)

;;	 (define-key c++-mode-map (kbd "RET")
;;	 #'(lambda () (interactive)
;;		 (c-context-line-break)
;;		 (clang-format-region (line-beginning-position) (line-end-position))
;;		 ))
;;	 (define-key c-mode-map (kbd "RET")
;;	 #'(lambda () (interactive)
;;		 (c-context-line-break)
;;		 (clang-format-region (line-beginning-position) (line-end-position))
;;		 ))
  )

(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)
(add-hook 'cpp-mode-common-hook 'my-c-mode-common-hook)
(define-key c-mode-base-map "\C-c\C-c"  'comment-or-uncomment-region)

(if my_use-irony
	(progn
	  (add-hook 'c++-mode-hook 'irony-mode)
	  (add-hook 'c-mode-hook 'irony-mode)
	  (add-hook 'objc-mode-hook 'irony-mode)
	  (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
	  (require 'flycheck-irony)
	  (flycheck-irony-setup)
;;      (add-hook 'flycheck-mode-hook #'flycheck-irony-setup)
	  (add-hook 'irony-mode-hook #'irony-eldoc)
	  )
  (progn
	(add-hook 'c++-mode-hook 'company-mode)
	(add-hook 'c-mode-hook 'company-mode)
	))


;; clang格式化代码
(setq clang-format-executable "clang-format")
