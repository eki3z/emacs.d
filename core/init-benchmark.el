;;; init-benchmark.el --- benchmark lib -*- lexical-binding: t no-byte-compile: t -*-

;; Author: Eki Zhang <liuyinz95@gmail.com>
;; Created: 2022-12-08 20:06:27

;;; Commentary:

;;; Code:

(require 'cl-lib)

;; TODO display use ctable tabulist ?
(cl-defmacro bench-multi (&key (times 1) forms ensure-equal raw)
  "Return Org table as a list with benchmark results for FORMS.
Runs FORMS with `benchmark-run-compiled' for TIMES iterations.

When ENSURE-EQUAL is non-nil, the results of FORMS are compared,
and an error is raised if they aren't `equal'.  If the results are
sequences, the difference between them is shown with
`seq-difference'.

When RAW is non-nil, the raw results from
`benchmark-run-compiled' are returned instead of an Org table
list.

If the first element of a form is a string, it's used as the
form's description in the bench-multi-results; otherwise, forms
are numbered from 0.

Before each form is run, `garbage-collect' is called."
  ;; MAYBE: Since `bench-multi-lexical' byte-compiles the file, I'm not sure if
  ;; `benchmark-run-compiled' is necessary over `benchmark-run', or if it matters.
  (declare (indent defun))
  (let*((keys (gensym "keys"))
        (result-times (gensym "result-times"))
        (header '(("Form" "x fastest" "Total runtime" "# of GCs" "Total GC runtime")
                  hline))
        ;; Copy forms so that a subsequent call of the macro will get the original forms.
        (forms (cl-copy-list forms))
        (descriptions (cl-loop for form in forms
                               for i from 0
                               collect (if (stringp (car form))
                                           (prog1 (car form)
                                             (setf (nth i forms) (cadr (nth i forms))))
                                         i))))
    `(unwind-protect
         (progn
           (defvar bench-multi-results nil)
           (let* ((bench-multi-results (make-hash-table))
                  (,result-times (sort (list ,@(cl-loop for form in forms
                                                        for i from 0
                                                        for description = (nth i descriptions)
                                                        collect `(progn
                                                                   (garbage-collect)
                                                                   (cons ,description
                                                                         (benchmark-run-compiled ,times
                                                                           ,(if ensure-equal
                                                                                `(puthash ,description ,form bench-multi-results)
                                                                              form))))))
                                       (lambda (a b)
                                         (< (cl-second a) (cl-second b))))))
             ,(when ensure-equal
                `(cl-loop with ,keys = (hash-table-keys bench-multi-results)
                          for i from 0 to (- (length ,keys) 2)
                          unless (equal (gethash (nth i ,keys) bench-multi-results)
                                        (gethash (nth (1+ i) ,keys) bench-multi-results))
                          do (if (sequencep (gethash (car (hash-table-keys bench-multi-results)) bench-multi-results))
                                 (let* ((k1) (k2)
                                        ;; If the difference in one order is nil, try in other order.
                                        (difference (or (setq k1 (nth i ,keys)
                                                              k2 (nth (1+ i) ,keys)
                                                              difference (seq-difference (gethash k1 bench-multi-results)
                                                                                         (gethash k2 bench-multi-results)))
                                                        (setq k1 (nth (1+ i) ,keys)
                                                              k2 (nth i ,keys)
                                                              difference (seq-difference (gethash k1 bench-multi-results)
                                                                                         (gethash k2 bench-multi-results))))))
                                   (user-error "Forms' bench-multi-results not equal: difference (%s - %s): %S"
                                               k1 k2 difference))
                               ;; Not a sequence
                               (user-error "Forms' bench-multi-results not equal: %s:%S %s:%S"
                                           (nth i ,keys) (nth (1+ i) ,keys)
                                           (gethash (nth i ,keys) bench-multi-results)
                                           (gethash (nth (1+ i) ,keys) bench-multi-results)))))
             ;; Add factors to times and return table
             (if ,raw
                 ,result-times
               (append ',header
                       (bench-multi-process-results ,result-times)))))
       (unintern 'bench-multi-results nil))))

(defun bench-multi-process-results (results)
  "Return sorted RESULTS with factors added."
  (setq results (sort results (-on #'< #'cl-second)))
  (cl-loop with length = (length results)
           for i from 0 below length
           for description = (car (nth i results))
           for factor = (pcase i
                          (0 "fastest")
                          (_ (format "%.2f" (/ (cl-second (nth i results))
                                               (cl-second (nth 0 results))))))
           collect (append (list description factor)
                           (list (format "%.6f" (cl-second (nth i results)))
                                 (cl-third (nth i results))
                                 (if (> (cl-fourth (nth i results)) 0)
                                     (format "%.6f" (cl-fourth (nth i results)))
                                   0)))))

(provide 'init-benchmark)
;;; init-benchmark.el ends here
