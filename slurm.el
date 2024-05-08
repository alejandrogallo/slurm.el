;;; slurm

(defun slurm-squeue (&optional all)
  (interactive "P")
  (shell-command (concat
                  "squeue" " "
                  (if all "" "--me"))))


(defun slurm-sbatch (&optional title)
  (interactive (list (read-string "Title: " nil 'slurm-title)))
  (shell-command (format "sbatch %s %s"
                         (if title (format "-J %S" title) "")
                         (buffer-file-name (current-buffer)))))

(defun slurm-scancel (job)
  (interactive (list
                (completing-read "Job: "
                                 (mapcar #'string-trim
                                         (butlast
                                          (cdr
                                           (string-split
                                            (shell-command-to-string
                                             "squeue --me") "\n")))))))
  (let ((id (car (string-split job " "))))
    (shell-command-to-string (format "scancel %s" id))))

(defun slurm-sqos ()
  (interactive)
  (shell-command "sqos"))


(defun slurm-list-associations (userid)
  (interactive (list (string-trim (shell-command-to-string "id -u"))))
  (let ((associations (string-split (shell-command-to-string "sacctmgr -p list Association") "\n")))
    (let ((my-assoc (cl-remove-if-not (lambda (ac) (string-match-p userid ac)) associations)))
      (with-current-buffer (get-buffer-create "*slurm-assocs*")
        (erase-buffer)
        (org-mode)
        (insert "Cluster|Account|User|Partition|Share|Priority|GrpJobs|GrpTRES|GrpSubmit|GrpWall|GrpTRESMins|MaxJobs|MaxTRES|MaxTRESPerNode|MaxSubmit|MaxWall|MaxTRESMins|QOS|Def QOS|GrpTRESRunMins|\n")
        (dolist (assoc (mapcar #'string-trim my-assoc))
          (insert assoc)
          (insert "\n"))
        (replace-regexp "|" "\t" nil (point-min) (point-max))
        (org-table-convert-region (point-min) (point-max))
        (beginning-of-buffer)
        (next-line)
        (insert "|-\n")
        (org-table-align))
      (switch-to-buffer "*slurm-assocs*"))))

(defun slurm-partition-sinfo (partition)
  (interactive (list (thing-at-point 'symbol)))
  (shell-command (format "sinfo -p %s" partition)))

(defun slurm-node-information ()
  (interactive)
  (shell-command "scontrol show node"))

(provide 'slurm)
