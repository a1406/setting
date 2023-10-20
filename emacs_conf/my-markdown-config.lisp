;; https://stackoverflow.com/questions/36183071/how-can-i-preview-markdown-in-emacs-in-real-time/36189456?noredirect=1#comment104784050_36189456
;; M-x httpd-start
;; M-x impatient-mode
;; M-x imp-set-user-filter RET markdown-html RET
(defun markdown-html_v1 (buffer)
  (princ (with-current-buffer buffer
	   (format "<!DOCTYPE html><html><title>Impatient Markdown</title><xmp theme=\"united\" style=\"display:none;\"> %s  </xmp><script src=\"http://ndossougbe.github.io/strapdown/dist/strapdown.js\"></script></html>" (buffer-substring-no-properties (point-min) (point-max))))
	 (current-buffer)))

(setq httpd-host "0.0.0.0")

(defun my-markdown-preview ()
  "Preview markdown."
  (interactive)
  (unless (process-status "httpd")
    (httpd-start))
  (impatient-mode)
  (imp-set-user-filter 'markdown-html_v1)
  ;;  (imp-visit-buffer)
  )

;;;;;;;;;;;;;;;;;;
(setq grip-github-user "a1406@163.com")
(setq grip-github-password (base64-decode-string (base64-decode-string "WjJod1gyYzRXV2hwU2pOVVRrUndkbmxxVGtZMFpVcE9hbmhqVG10aFYwNDJNREJLV0cxMVV3PT0=")))

(setq grip-preview-host "0.0.0.0")
(defun grip--address ()
  "Return grip preview url."
  (format "%s:%d" grip-preview-host grip--port))

(defun my-grip-start-process (orig-fun &rest args)
  "Render and preview with grip."
  (unless (processp grip--process)
    (unless (executable-find grip-binary-path)
      (grip-mode -1)                    ; Force to disable
      (user-error "The `grip' is not available in PATH environment"))

    ;; Generat random port
    (while (< grip--port 6419)
      (setq grip--port (random 65535)))

    ;; Start a new grip process
    (when grip--preview-file
      (setq grip--process
            (start-process (format "grip-%d" grip--port)
                           (format " *grip-%d*" grip--port)
                           grip-binary-path
                           (format "--api-url=%s" grip-github-api-url)
                           (format "--user=%s" grip-github-user)
                           (format "--pass=%s" grip-github-password)
                           (format "--title=%s - Grip" (buffer-name))
                           grip--preview-file
			   (grip--address)))
;;                           (number-to-string grip--port)))

      (message "Preview `%s' on %s" buffer-file-name (grip--preview-url))
      (sleep-for grip-sleep-time) ; Ensure the server has started
;;      (grip--browse-url (grip--preview-url))
      )))

(advice-add 'grip-start-process :around #'my-grip-start-process)


;; (add-hook 'markdown-mode-hook #'grip-mode)
;; (add-hook 'org-mode-hook #'grip-mode)

