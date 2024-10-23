(defvar stscript-mode-hook nil)

(defvar stscript-mode-map
  (let ((map (make-keymap)))
    (define-key map "\C-j" 'newline-and-indent)
    map)
  "Keymap for STscript major mode")

;; Regular expressions for syntax highlighting
(defconst stscript-font-lock-keywords
  (list
   ;; Commands starting with /
   '("/[[:alnum:]_-]+" . font-lock-function-name-face)

   ;; Variables {{var::name}}
   '("{{\\(var\\|getvar\\|setvar\\|addvar\\|incvar\\|decvar\\|getglobalvar\\|setglobalvar\\|addglobalvar\\|incglobalvar\\|decglobalvar\\|item\\|index\\)::[^}]+}}" . font-lock-variable-name-face)

   ;; Macros {{name}}
   '("{{[^:][^}]*}}" . font-lock-constant-face)

   ;; Named arguments key=value
   '("\\([[:alnum:]_-]+\\)=" . font-lock-type-face)

   ;; Comments
   '("//.*" . font-lock-comment-face)
   '("/\\*.*?\\*/" . font-lock-comment-face)

   ;; Closures
   '("{:.*?:}" . font-lock-string-face)

   ;; Pipes
   '("\\(|\\||\\)" . font-lock-keyword-face)
   )
  "Highlighting expressions for STscript mode")

(defun stscript-indent-line ()
  "Indent current line as STscript code"
  (interactive)
  (beginning-of-line)
  (if (bobp)
      (indent-line-to 0)
    (let ((not-indented t) cur-indent)
      (if (looking-at "^[ \t]*:}")
          (progn
            (save-excursion
              (forward-line -1)
              (setq cur-indent (- (current-indentation) 2)))
            (if (< cur-indent 0)
                (setq cur-indent 0)))
        (save-excursion
          (while not-indented
            (forward-line -1)
            (if (looking-at "^[ \t]*{:")
                (progn
                  (setq cur-indent (+ (current-indentation) 2))
                  (setq not-indented nil))
              (if (looking-at "^[ \t]*:}")
                  (progn
                    (setq cur-indent (current-indentation))
                    (setq not-indented nil))
                (if (bobp)
                    (setq not-indented nil)))))))
      (if cur-indent
          (indent-line-to cur-indent)
        (indent-line-to 0)))))

(defvar stscript-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?_ "w" st)
    (modify-syntax-entry ?/ ". 124b" st)
    (modify-syntax-entry ?* ". 23" st)
    (modify-syntax-entry ?\n "> b" st)
    st)
  "Syntax table for stscript-mode")

;;;###autoload
(define-derived-mode stscript-mode fundamental-mode "STscript"
  "Major mode for editing STscript files"
  :syntax-table stscript-mode-syntax-table

  (set (make-local-variable 'font-lock-defaults) '(stscript-font-lock-keywords))
  (set (make-local-variable 'indent-line-function) 'stscript-indent-line)

  (set (make-local-variable 'comment-start) "// ")
  (set (make-local-variable 'comment-end) "")

  (modify-syntax-entry ?{ "(}" stscript-mode-syntax-table)
  (modify-syntax-entry ?} "){" stscript-mode-syntax-table))

(provide 'stscript-mode)
