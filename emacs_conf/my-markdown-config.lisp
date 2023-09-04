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
