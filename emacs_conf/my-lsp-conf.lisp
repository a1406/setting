(require 'lsp)
(require 'lsp-clients)
(require 'ivy-xref)
(require 'projectile)

;;(setq cquery-executable "/usr/local/bin/cquery")
;;(setq ccls-executable "/usr/local/bin/ccls")
(setq lsp-prefer-flymake nil)
(push "cscope.files" projectile-project-root-files)

(require 'flycheck-clangcheck)
(setq flycheck-clangcheck-analyze t)

(dolist (hook '(c-mode-hook c++-mode-hook))
  (add-hook hook
            #'(lambda ()
                ;;              (require 'cquery)
                (require 'ccls)
                (lsp)
		(flycheck-select-checker 'c/c++-clangcheck)
;;		(flymake-mode-off)
		)))


(dolist (hook '(typescript-mode-hook js-mode-hook js2-mode-hook rjsx-mode-hook))
  (add-hook hook
            #'(lambda ()
                (lsp))))

(dolist (hook '(python-mode-hook))
  (add-hook hook
            #'(lambda ()
                (lsp)
;;		(flymake-mode-off)
		)))

(push 'company-lsp company-backends)
(setq xref-show-xrefs-function #'ivy-xref-show-xrefs)
(setq xref-prompt-for-identifier '(not xref-find-references xref-find-definitions xref-find-definitions-other-window xref-find-definitions-other-frame))
;;(add-hook 'lsp-mode-hook 'lsp-ui-mode)
;;(global-set-key (kbd "M-.") (function rtags-find-symbol-at-point))
(global-set-key (kbd "M-,") (function xref-find-references))

(setq lsp-auto-guess-root nil)
