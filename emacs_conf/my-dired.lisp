;; -*- lexical-binding: t -*-
(require 'dired)

(setq dired-listing-switches
      (if (memq system-type '(windows-nt darwin))
          "-alh"
        "-laGh1v --group-directories-first"))
(setq dired-recursive-copies 'always)
(setq dired-recursive-deletes 'always)
(setq dired-dwim-target t)

;;* advice
(defadvice dired-advertised-find-file (around ora-dired-subst-directory activate)
  "Replace current buffer if file is a directory."
  (interactive)
  (let* ((orig (current-buffer))
         (filename (dired-get-filename t t))
         (bye-p (file-directory-p filename)))
    ad-do-it
    (when (and bye-p (not (string-match "[/\\\\]\\.$" filename)))
      (kill-buffer orig))))

(defadvice dired-delete-entry (before ora-force-clean-up-buffers (file) activate)
  (let ((buffer (get-file-buffer file)))
    (when buffer
      (kill-buffer buffer))))

(defun ora-dired-sort ()
  "Sort dired listings with directories first."
  (when (file-remote-p default-directory)
    (save-excursion
      (let (buffer-read-only)
        ;; beyond dir. header
        (forward-line 2)
        (sort-regexp-fields t "^.*$" "[ ]*." (point) (point-max)))
      (set-buffer-modified-p nil))))

(defadvice dired-readin (after dired-after-updating-hook first () activate)
  "Sort dired listings with directories first before adding marks."
  (ora-dired-sort))


;;* rest
(defun ora-dired-show-octal-permissions ()
  "Show current item premissons, e.g. for later use in chmod."
  (interactive)
  (let ((r (counsel--command "stat" "-c" "%a %n" (car (dired-get-marked-files)))))
    (message (car (split-string r " ")))))

(defun ora-dired-get-size ()
  (interactive)
  (let* ((cmd (concat "du -sch "
                      (mapconcat (lambda (x) (shell-quote-argument (file-name-nondirectory x)))
                                 (dired-get-marked-files) " ")))
         (res (shell-command-to-string cmd)))
    (if (string-match "\\(^[ 0-9.,]+[A-Za-z]+\\).*total$" res)
        (message (match-string 1 res))
      (error "unexpected output %s" res))))

(defun ora-ediff-files ()
  (interactive)
  (let ((files (dired-get-marked-files))
        (wnd (current-window-configuration)))
    (if (<= (length files) 2)
        (let ((file1 (car files))
              (file2 (if (cdr files)
                         (cadr files)
                       (read-file-name
                        "file: "
                        (dired-dwim-target-directory)))))
          (if (file-newer-than-file-p file1 file2)
              (ediff-files file2 file1)
            (ediff-files file1 file2))
          (add-hook 'ediff-after-quit-hook-internal
                    (lambda ()
                      (setq ediff-after-quit-hook-internal nil)
                      (set-window-configuration wnd))))
      (error "no more than 2 files should be marked"))))

(defun ora-dired-other-window ()
  (interactive)
  (if (string= (buffer-name) "*Find*")
      (find-file-other-window
       (file-name-directory (dired-get-file-for-visit)))
    (save-selected-window
      (dired-find-file-other-window))))

(defun ora-dired-up-directory ()
  (interactive)
  (let ((this-directory default-directory)
        (buffer (current-buffer)))
    (dired-up-directory)
    (unless (cl-find-if
             (lambda (w)
               (with-selected-window w
                 (and (eq major-mode 'dired-mode)
                      (equal default-directory this-directory))))
             (delete (selected-window) (window-list)))
      (kill-buffer buffer))))

;;* bind and hook
(define-key dired-mode-map "e" 'ora-ediff-files)
(define-key dired-mode-map "h" 'dired-do-shell-command)
(define-key dired-mode-map (kbd "C-j") 'dired-find-file)
(define-key dired-mode-map (kbd "%^") 'dired-flag-garbage-files)
(define-key dired-mode-map (kbd "z") 'ora-dired-get-size)
(define-key dired-mode-map "a" 'ora-dired-up-directory)
(define-key dired-mode-map "O" 'ora-dired-other-window)
(define-key dired-mode-map "P" 'ora-dired-show-octal-permissions)
(define-key dired-mode-map "I" 'dired-kill-subdir)
