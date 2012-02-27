#|
  This file is a part of marching-cubes project.
  Copyright (c) 2012 Masayuki Takagi (kamonama@gmail.com)
|#

(in-package :marching-cubes-example.blob2)


;; blob

(defun blob (x0 y0 z0 strength radius)
  (lambda (x y z)
    (let ((distance (sqrt (+ (* (- x x0) (- x x0))
                             (* (- y y0) (- y y0))
                             (* (- z z0) (- z z0))))))
      (if (<= distance radius)
          (* strength (expt (- 1 (expt (/ distance radius) 2)) 2))
          0))))

(let ((blob1 (blob 0 0 0 4 4))
      (blob2 (blob 6 0 0 4 4))
      (blob3 (blob 3 5 0 4 4))
      (blob4 (blob -6 0 0 4 4))
      (blob5 (blob -3.5 -5 0 4 4)))
  (defun blob-value (x y z)
    (+ (funcall blob1 x y z)
       (funcall blob2 x y z)
       (funcall blob3 x y z)
       (funcall blob4 x y z)
       (funcall blob5 x y z)))
  (defun blob-normal (x y z)
    (normalize-vec3 (make-vec3 (- (blob-value (+ x 0.00001) y z)
                                  (blob-value (- x 0.00001) y z))
                               (- (blob-value x (+ y 0.00001) z)
                                  (blob-value x (- y 0.00001) z))
                               (- (blob-value x y (+ z 0.00001))
                                  (blob-value x y (- z 0.00001)))))))


;; output functions

(defun lines (xs)
  (format nil "~{~a~^~%~}~%" xs))

(defun output (triangles)
  (with-open-file (out "blob2.pov"
                       :direction :output
                       :if-exists :supersede)
    (output-head out)
    (output-smooth-triangles triangles out))
  "ok")

(defun head ()
  (lines '("#include \"colors.inc\""
           "camera {"
           "  location <0, 0, -20>"
           "  look_at <0, 0, 0>"
           "}"
           "light_source { <0, 0, -20> color White }")))

(defun output-head (out)
  (princ (head) out))

(defun output-smooth-triangles (triangles out)
  (princ (lines (append '("union {")
                        (mapcar #'smooth-triangle-pov triangles)
                        '("pigment { color White }")
                        '("}")))
         out))

(defun smooth-triangle-pov (tri)
  (format nil "smooth_triangle { ~A, ~A, ~A, ~A, ~A, ~A }"
          (vec3-pov (smooth-triangle-vertex tri 0))
          (vec3-pov (smooth-triangle-normal tri 0))
          (vec3-pov (smooth-triangle-vertex tri 1))
          (vec3-pov (smooth-triangle-normal tri 1))
          (vec3-pov (smooth-triangle-vertex tri 2))
          (vec3-pov (smooth-triangle-normal tri 2))))

(defun vec3-pov (x)
  (format nil "<~A, ~A, ~A>" (vec3-x x) (vec3-y x) (vec3-z x)))


;; main

(defun main ()
  (output (marching-cubes-smooth #'blob-value
                                 #'blob-normal
                                 (make-vec3 -10 -10 -10)
                                 (make-vec3 10 10 10)
                                 0.25 1)))
