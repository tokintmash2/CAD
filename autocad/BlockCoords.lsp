;Export block coordinates, even in AutoCAD LT
;(C)2024 ARKANCE CZ, www.cadforum.cz
;V1.1 - added dynamic blocks, optional scale and rotation angle (uncomment second line '***', comment the first)

(if (not _BCdelimiter)
 (setq _BCdelimiter (cond ((vl-registry-read "HKEY_CURRENT_USER\\Control Panel\\International" "sList")) (","))) ; take Sys delimiter
)

(defun C:BlockCoords ( / e edata bname ebname ss ssl i f fn pt obj att atts cnt rot scl)
  (defun rtd (a) (/ (* a 180.0) pi))

  (vl-load-com)
  (while (not e)
   (and
    (setq e (car (entsel "\nSelect sample block to export: ")))
    (setq edata (entget e))
    (if (/= (cdr (assoc 0 edata)) "INSERT")(progn (princ " this is not a block! ")(setq e nil)))
   )
  )
  (setq bname (cdr (assoc 2 edata))
		ebname (vla-get-Effectivename (setq obj (vlax-ename->vla-object e)))
		atts ""
  )
  (princ (strcat bname (if (= (ascii bname) 42) (strcat " (" ebname ")") ""))) ; "*" ?
  (princ "\nSelect blocks to export coordinates <all>")
  (setq ss (ssget (list (cons 0 "INSERT")(cons 2 (strcat bname ",`*U*"))))  i 0  cnt 0)
  (if (not ss)(setq ss (ssget "_X" (list (cons 0 "INSERT")(cons 2 (strcat bname ",`*U*")))))) ; All?
  (if (and ss (> (setq ssl (sslength ss)) 0))(progn
   (princ (strcat "\nExporting " (itoa ssl) " block references..."))
   (setq f (open (setq fn (strcat (getvar "WORKINGFOLDER") "\\" (getvar "DWGNAME") ".csv")) "w"))
   (if f (progn
    (foreach att (vlax-invoke obj 'GetAttributes)(setq atts (strcat atts _BCdelimiter "\"" (vlax-get att 'TagString) "\"")))
    (princ (strcat "X" _BCdelimiter "Y" _BCdelimiter "Z"  _BCdelimiter "Scale" _BCdelimiter "Angle" atts) f) ; CSV Header - full
;    (princ (strcat "X" _BCdelimiter "Y" _BCdelimiter "Z" atts) f) ; CSV Header - no scale/rot
    (while (< i ssl) ; all selected
      (setq e (ssname ss i)
			edata (entget e)
			pt (cdr (assoc 10 edata))
			scl (cdr (assoc 41 edata))
			rot (cdr (assoc 50 edata))
			obj (vlax-ename->vla-object e)
			atts ""
      )
      (if (= (strcase ebname) (strcase (vla-get-effectivename obj)))(progn
       (foreach att (vlax-invoke obj 'GetAttributes) ; all atts
        (setq atts (strcat atts _BCdelimiter "\"" (vlax-get att 'TextString) "\""))
       )
       (princ (strcat "\n" (rtos (car pt) 2 6) _BCdelimiter (rtos (cadr pt) 2 6) _BCdelimiter (rtos (caddr pt) 2 6)
                      _BCdelimiter (rtos scl 2 6) _BCdelimiter (rtos (rtd rot) 2 6) ; comment this if no scale/rot
                      atts) f)
       (setq cnt (1+ cnt))
      ));if
      (setq i (1+ i))
    );while
    (close f)
    (princ (strcat "\n" (itoa cnt) " coordinates of " ebname " exported to " fn))
   );else
    (princ "\nCSV file cannot be created!")
   );if f
  ));if ss
 (princ)
)

(princ "\nLoaded. Type BLOCKCOORDS to export block coordinates.")
(princ)