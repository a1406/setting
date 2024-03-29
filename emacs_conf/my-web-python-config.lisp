(load "~/.emacs.conf/flycheck-luacheck.el")
(load "~/.emacs.conf/my-markdown-config.lisp")
(autoload 'lua-mode "lua-mode" "Lua editing mode." t)
(add-to-list 'auto-mode-alist '("\\.lua$" . lua-mode))
(add-to-list 'interpreter-mode-alist '("lua" . lua-mode))
(add-to-list 'auto-mode-alist '("\\.shader$" . shader-mode))
(add-to-list 'auto-mode-alist '("\\.cginc$" . shader-mode))

(setq lua-indent-level 4)
(defun my-lua-setup ()
  (flycheck-luacheck-setup)
  ;; (flycheck-select-checker 'luacheck)
  (flycheck-mode 1)
  (setq indent-tabs-mode nil)
  (setq tab-width 4)
  (company-mode)
  (if (functionp 'display-line-numbers-mode)
	  (display-line-numbers-mode)
	(linum-mode 1))
  (local-set-key  "\C-c\C-c"  'comment-or-uncomment-region)
 (if my-use-lsp (progn
		   (load "~/.emacs.conf/my-lua-lsp.lisp")
		   ))
 (flycheck-select-checker 'luacheck)
 (my/org-mode/load-prettify-symbols)
  )
(add-hook 'lua-mode-hook 'my-lua-setup)

(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
;; (add-to-list 'auto-mode-alist '("\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.php?\\'" . web-mode))
(defun my-web-setup ()
  (setq indent-tabs-mode t)
  (if (functionp 'display-line-numbers-mode)
	  (display-line-numbers-mode)
	(linum-mode 1))
  (local-set-key  "\C-c\C-c"  'comment-or-uncomment-region)
  )
(add-hook 'web-mode-hook 'my-web-setup)
(add-hook 'js-mode-hook 'my-web-setup)

(require 'python)
;; 需要编译Microsoft.Python.LanguageServer
;; https://vxlabs.com/2018/11/19/configuring-emacs-lsp-mode-and-microsofts-visual-studio-code-python-language-server/
;; cd python-language-server/src/LanguageServer/Impl
;; dotnet build -c Release
;;(setq lsp-python-ms-executable (executable-find "python-language-server"))
(setq lsp-python-ms-executable "/home/jack/tmp2/python-language-server/output/bin/Release/Microsoft.Python.LanguageServer")
(setq python-indent-guess-indent-offset-verbose nil)
(setq python-shell-completion-native-enable nil)
(setq python-shell-virtualenv-path (format "%s/pyenv" (getenv "HOME")))
(setq python-shell-interpreter "ipython")
(setq python-shell-interpreter-args "--simple-prompt -i")
(defun python-util-clone-local-variables (from-buffer &optional regexp)
  "Clone local variables from FROM-BUFFER.
Optional argument REGEXP selects variables to clone and defaults
to \"^python-\"."
  (mapc
   (lambda (pair)
     (when (listp pair)
     (and (symbolp (car pair))
          (string-match (or regexp "^python-")
                        (symbol-name (car pair)))
          (set (make-local-variable (car pair))
               (cdr pair)))))
   (buffer-local-variables from-buffer)))
;;(if (>= (string-to-number (substring (with-temp-buffer
;;					   (call-process "ipython" nil t nil "--version")
;;					   (buffer-string)) 0 1)) 5)
;;    (setq python-shell-interpreter-args "--simple-prompt -i")
;;  )

;;(require 'company-anaconda)
;;(require 'anaconda-mode)
(if my_use-anaconda
(progn
  (add-hook 'python-mode-hook 'anaconda-mode)
  (add-hook 'python-mode-hook 'anaconda-eldoc-mode)
  (add-to-list 'company-backends 'company-anaconda)))

;;ein
(setq ein:completion-backend 'ein:use-company-backend)
(add-hook 'ein:notebook-mode-hook
	  (lambda ()
	    (setq indent-tabs-mode nil)
	    (company-mode)
	    (define-key evil-emacs-state-local-map "s" 'ein:notebook-save-notebook-command)
	    (define-key evil-emacs-state-local-map " c" 'ein:worksheet-execute-cell)
	    (define-key evil-emacs-state-local-map " l" 'ein:worksheet-clear-output)
	    (define-key evil-emacs-state-local-map " e" 'ein:worksheet-toggle-output)
	    (define-key evil-emacs-state-local-map " h" 'ein:pytools-request-tooltip-or-help)
	    (define-key evil-emacs-state-local-map " r" 'ein:notebook-rename-command)
	    ))

;;(defun my-python-mode-common-hook ()
;;  (define-key python-mode-map (kbd "TAB") 'tab-indent-or-complete)
;;  (message "my python mode hook")
;;  )
;;(add-hook 'inferior-python-mode-hook 'my-python-mode-common-hook)

;;(setq elpy-rpc-python-command "/usr/bin/python")
;;(elpy-enable)
;;(setq elpy-modules (delete 'elpy-module-highlight-indentation elpy-modules))
;;(elpy-use-ipython)

;;(global-set-key (kbd "ESC <right>") 'ahs-forward)
;;(global-set-key (kbd "ESC <left>") 'ahs-backward)

;;js
;;(add-hook 'js-mode-hook
;;          '(lambda ()
;;             (company-mode 1)
;;             (tern-mode 1)
;;             (setq company-tooltip-align-annotations t)
;;             (add-to-list 'company-backends 'company-tern)))

;; (add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
;; (add-to-list 'auto-mode-alist '("\\.jsx?\\'" . js2-jsx-mode))
(add-hook 'js-mode-hook 'js2-minor-mode)


;;(add-to-list 'auto-mode-alist '("\\.[jt]s\\'" . web-mode))
(define-key web-mode-map "\M-;" nil)



(defun my-shader-setup ()
  (setq indent-tabs-mode nil)
  (setq tab-width 4)
  (company-mode)
  (if (functionp 'display-line-numbers-mode)
	  (display-line-numbers-mode)
	(linum-mode 1))
  )
(add-hook 'shader-mode-hook 'my-shader-setup)
