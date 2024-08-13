(defun c:ExportTextToCSV ()
  ;; Prompt user to save the CSV file
  (setq filename (getfiled "Save text data as" "" "csv" 1))
  (if filename
    (progn
      ;; Open file for writing
      (setq file (open filename "w"))
      ;; Get all TEXT and MTEXT entities in the drawing
      (setq ss (ssget "X" '((0 . "TEXT,MTEXT"))))
      ;; Check if any text entities are found
      (if ss
        (progn
          (setq i 0)
          ;; Loop through all selected entities
          (while (< i (sslength ss))
            (setq ent (ssname ss i))
            (setq entData (entget ent))
            ;; Initialize variables
            (setq text "")
            (setq x nil)
            (setq y nil)
            ;; Check entity type and extract text and coordinates
            (cond
              ;; For TEXT entities
              ((= (cdr (assoc 0 entData)) "TEXT")
                (setq text (cdr (assoc 1 entData)))
                (setq x (cdr (assoc 10 entData)))
                (setq y (cdr (assoc 20 entData))))
              ;; For MTEXT entities
              ((= (cdr (assoc 0 entData)) "MTEXT")
                (setq text (cdr (assoc 1 entData)))
                (setq insPt (cdr (assoc 10 entData)))
                (if insPt
                  (progn
                    (setq x (car insPt))
                    (setq y (cadr insPt)))))
            )
            ;; Ensure x and y are not nil before writing to file
            (if (and x y text)
              (write-line (strcat (rtos x 2 2) "," (rtos y 2 2) "," text) file))
            (setq i (1+ i))
          )
          ;; Close the file
          (close file)
          (princ "Text data exported successfully.")
        )
        (princ "No text entities found.")
      )
    )
    (princ "Operation cancelled.")
  )
  (princ)
)

(defun c:ImportTranslatedTextFromCSV ()
  ;; Prompt user to select the CSV file with translated texts
  (setq filename (getfiled "Select the translated text file" "" "csv" 4))
  (if filename
    (progn
      ;; Open the CSV file for reading
      (setq file (open filename "r"))
      ;; Read each line from the file
      (while (setq line (read-line file))
        ;; Trim any whitespace from the line
        (setq line (vl-string-trim " \t\n\r" line))
        ;; Find the positions of the first two commas
        (setq comma1 (vl-string-search "," line))
        (setq comma2 (vl-string-search "," line (1+ comma1)))
        ;; Check if both commas are found
        (if (and comma1 comma2)
          (progn
            ;; Extract X, Y, and Translated Text
            (setq xStr (substr line 1 comma1))
            (setq yStr (substr line (1+ comma1) (- comma2 comma1)))
            (setq translatedText (substr line (1+ comma2)))
            ;; Convert X and Y strings to numbers
            (setq x (atof xStr))
            (setq y (atof yStr))
            ;; Ensure X and Y are valid numbers
            (if (and (numberp x) (numberp y))
              (progn
                ;; Find the text entity at the given location
                (setq pt (list x y 0.0))
                (setq ss (ssget "C" pt (list (list 0 "TEXT,MTEXT"))))
                ;; If a text entity is found, update its text content
                (if (ssname ss 0)
                  (progn
                    (setq ent (ssname ss 0))
                    (setq entData (entget ent))
                    ;; Check if the entity is TEXT or MTEXT
                    (cond
                      ((= (cdr (assoc 0 entData)) "TEXT")
                        (entmod (subst (cons 1 translatedText) (assoc 1 entData) entData))
                      )
                      ((= (cdr (assoc 0 entData)) "MTEXT")
                        (entmod (subst (cons 1 translatedText) (assoc 1 entData) entData))
                      )
                    )
                  )
                )
              )
              (princ (strcat "\nInvalid coordinates: " line))
            )
          )
          (princ (strcat "\nInvalid line format: " line))
        )
      )
      ;; Close the file
      (close file)
      (princ "Translated texts imported successfully.")
    )
    (princ "Operation cancelled.")
  )
  (princ)
)



