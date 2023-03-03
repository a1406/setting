(add-to-list 'load-path "~/gitroot/lsp-bridge/")

(add-hook 'emacs-startup-hook
          (lambda ()
            (require 'yasnippet)
            (yas-global-mode 1)

            (require 'lsp-bridge)
            (global-lsp-bridge-mode)

            (unless (display-graphic-p)
              (with-eval-after-load 'acm
                (require 'acm-terminal)))))
