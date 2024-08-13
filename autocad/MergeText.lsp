;; (defun c:MergeTextObjects ()
;;   (prompt "\nSelect text objects to merge (press Enter to finish): ")
;;   (setq textObjects '())
;;   (setq textObj nil)
;;   ;; Collect all selected text objects
;;   (while (setq textObj (car (entsel "\nSelect text: ")))
;;     (setq textObjects (cons textObj textObjects))
;;   )
  
;;   ;; Check if any text objects were selected
;;   (if (null textObjects)
;;     (progn
;;       (prompt "\nNo text objects selected.")
;;       (princ)
;;     )
;;     (progn
;;       (setq mergedText "")
;;       ;; Loop through all selected text objects and concatenate their text
;;       (foreach obj textObjects
;;         (setq objText (cdr (assoc 1 (entget obj))))
;;         (setq mergedText (strcat mergedText " " objText))
;;         ;; Optionally delete the original text objects
;;         (entdel obj)
;;       )
;;       ;; Create a new text object with the merged text
;;       (setq pt (getpoint "\nSpecify insertion point for merged text: "))
;;       (entmake
;;         (list
;;           (cons 0 "TEXT")
;;           (cons 10 pt)
;;           (cons 40 0.2) ;; Set text height
;;           (cons 1 mergedText)
;;         )
;;       )
;;       (prompt "\nText objects merged successfully.")
;;       (princ)
;;     )
;;   )
;; )

;; (princ "\nType 'MergeTextObjects' to run the script.\n")

(defun c:MergeTextObjects ()
  (prompt "\nSelect text objects to merge (press Enter to finish): ")
  (setq textObjects '())
  (setq textObj nil)
  ;; Collect all selected text objects
  (while (setq textObj (car (entsel "\nSelect text: ")))
    (setq textObjects (cons textObj textObjects))
  )
  
  ;; Check if any text objects were selected
  (if (null textObjects)
    (progn
      (prompt "\nNo text objects selected.")
      (princ)
    )
    (progn
      (setq mergedText "")
      ;; Loop through all selected text objects and concatenate their text
      (foreach obj textObjects
        (setq objText (cdr (assoc 1 (entget obj))))
        (setq mergedText (strcat mergedText " " objText))
        ;; Optionally delete the original text objects
        (entdel obj)
      )
      ;; Create a new text object with the merged text
      (setq pt (getpoint "\nSpecify insertion point for merged text: "))
      (if (not pt)
        (prompt "\nNo insertion point specified.")
        (progn
          (entmake
            (list
              (cons 0 "TEXT")
              (cons 10 pt)
              (cons 40 2.5) ;; Set text height
              (cons 1 mergedText)
              (cons 7 "Standard") ;; Text style
              (cons 8 "0") ;; Layer
              (cons 72 1) ;; Alignment (centered)
              (cons 11 pt)
              (cons 50 0.0) ;; Rotation angle
            )
          )
          (prompt "\nText objects merged successfully.")
        )
      )
    )
  )
  (princ)
)

(princ "\nType 'MergeTextObjects' to run the script.\n")

