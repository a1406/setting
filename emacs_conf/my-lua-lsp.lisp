(setq-local lsp-enable-imenu nil)
(setq-local lsp-log-io nil) ; if set to true can cause a performance hit
(setq-local lsp-print-performance t)
(setq-local lsp-auto-guess-root t) ; auto detect workspace and start lang server

;; lua
;; https://emacs-lsp.github.io/lsp-mode/page/lsp-lua-language-server/
(setq lsp-clients-lua-language-server-install-dir (f-join (getenv "HOME") "gitroot/lua-language-server"); Default: ~/.emacs.d/.cache/lsp/lua-language-server/
        lsp-clients-lua-language-server-bin (f-join lsp-clients-lua-language-server-install-dir "bin/Linux/lua-language-server")
        lsp-clients-lua-language-server-main-location (f-join lsp-clients-lua-language-server-install-dir "main.lua")
        lsp-lua-workspace-max-preload 2048 ; Default: 300, Max preloaded files
        lsp-lua-workspace-preload-file-size 1024; Default: 100, Skip files larger than this value (KB) when preloading.
        )
(require 'lsp-diagnostics)
(add-to-list 'lsp-diagnostics-disabled-modes 'lua-mode)



