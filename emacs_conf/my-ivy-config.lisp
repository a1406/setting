;;(add-hook 'ivy-sort-functions-alist '(ivy-completion-in-region . ivy-sort-file-function-default))
(require 'ivy)
(setq ivy-sort-functions-alist (append ivy-sort-functions-alist '((ivy-completion-in-region . ivy-sort-file-function-default))))

(add-hook 'ivy-occur-grep-mode-hook (lambda ()
				      (if (functionp 'display-line-numbers-mode)
					  (display-line-numbers-mode)
					(linum-mode 1)
					)))

(add-hook 'protobuf-mode-hook (lambda ()
				(add-to-list 'swiper-font-lock-exclude 'protobuf-mode)
				))

(define-key ivy-occur-grep-mode-map "a" nil)					
(define-key ivy-occur-grep-mode-map "n" nil)
(define-key ivy-occur-grep-mode-map "p" nil)
(define-key ivy-occur-grep-mode-map "j" nil)
(define-key ivy-occur-grep-mode-map (kbd "SPC") nil)
(define-key ivy-occur-grep-mode-map "o" nil)
(define-key ivy-occur-grep-mode-map "d" 'ivy-occur-delete-candidate)
(define-key ivy-occur-grep-mode-map "g" nil)
(define-key ivy-occur-grep-mode-map "v" nil)
(define-key ivy-occur-grep-mode-map "s" 'ivy-wgrep-change-to-wgrep-mode)

;;ivy设置
(require 'ivy)
(setq counsel-yank-pop-truncate-radius 0)
(setq ivy-use-virtual-buffers nil)
(setq ivy-count-format "(%d/%d) ")
(global-set-key (kbd "C-s") 'swiper)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "C-x b") 'ivy-switch-buffer)
(global-set-key (kbd "M-r") 'ivy-resume)
(global-set-key "\M-mt" #'(lambda () (interactive)
				(counsel-ag (thing-at-point 'symbol) (my-cscope-guess-root-directory) "--cpp" nil)))

(define-key ivy-minibuffer-map "\M-mp" 'ivy-avy)
(define-key ivy-minibuffer-map "\M-u"  'ivy-occur)
(define-key ivy-minibuffer-map "\M-n"  'next-line)
(define-key ivy-minibuffer-map "\M-j"  'ivy-alt-done)
(define-key ivy-minibuffer-map [remap describe-mode] 'describe-mode)
(define-key ivy-minibuffer-map "\M-p"  'previous-line)
(define-key ivy-minibuffer-map "\M-h"  #'(lambda () (interactive)
					   (if truncate-lines
					   (setq truncate-lines nil)
					   (setq truncate-lines t)
					   )))

(setq ivy-display-functions-alist nil)
;;(setq counsel-ag-base-command "cat ag.list 2>/dev/null | xargs ag  --nogroup --nocolor %s")
(setq dumb-jump-selector 'ivy)
;; mini buffer截断换行(truncate)的时候，在终端下显示的问题
;;(setq resize-mini-windows nil)
(setq resize-mini-windows 'grow-only)

(ivy-mode 1)

(define-key ivy-minibuffer-map (kbd "M-o") 'hydra-ivy/body)
(defhydra hydra-ivy (:hint nil
                     :color pink)
  "
^ ^ ^ ^ ^ ^ | ^Call^      ^ ^  | ^Cancel^ | ^Options^ | Action _w_/_s_/_a_: %-14s(ivy-action-name)
^-^-^-^-^-^-+-^-^---------^-^--+-^-^------+-^-^-------+-^^^^^^^^^^^^^^^^^^^^^^^^^^^^^---------------------------
^ ^ _a_ ^ ^ | _f_ollow occ_u_r | _i_nsert | _c_: calling %-5s(if ivy-calling \"on\" \"off\") _C_ase-fold: %-10`ivy-case-fold-search
_p_ ^+^ _n_ | _d_one      ^ ^  | _o_ops   | _m_: matcher %-5s(ivy--matcher-desc)^^^^^^^^^^^^ _t_runcate: %-11`truncate-lines
^ ^ _e_ ^ ^ | _g_o        ^ ^  | ^ ^      | _<_/_>_: shrink/grow^^^^^^^^^^^^^^^^^^^^^^^^^^^^ _D_efinition of this menu
"
  ;; arrows
  ("a" ivy-beginning-of-buffer)
  ("n" ivy-next-line)
  ("p" ivy-previous-line)
  ("e" ivy-end-of-buffer)
  ;; actions
  ("o" keyboard-escape-quit :exit t)
  ("C-g" keyboard-escape-quit :exit t)
  ("i" nil)
  ("C-o" nil)
  ("f" ivy-alt-done :exit nil)
  ("C-j" ivy-alt-done :exit nil)
  ("d" ivy-done :exit t)
  ("g" ivy-call)
  ("C-m" ivy-done :exit t)
  ("c" ivy-toggle-calling)
  ("m" ivy-rotate-preferred-builders)
  (">" ivy-minibuffer-grow)
  ("<" ivy-minibuffer-shrink)
  ("w" ivy-prev-action)
  ("s" ivy-next-action)
  ("a" ivy-read-action)
  ("t" (setq truncate-lines (not truncate-lines)))
  ("C" ivy-toggle-case-fold)
  ("u" ivy-occur :exit t)
  ("D" (ivy-exit-with-action
        (lambda (_) (find-function 'hydra-ivy/body)))
       :exit t))
