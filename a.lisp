;; -----------------------------------------------------------------------------------
;; A Simple Polynomial consists of a-0 x^0 + ... a_n x^n = ('simple x (a_0 a_1 a_2 ... a_n))
;; A Complex Polynomial consists of Simple Polynomial, sum, products and powers 
;; C is reserved as a generic constant
;;
;;------------------------------------------------------------------------------------


;;
;; Constructors for polynomials - assumes clean input - check with recognizer
;;

;;COMPLEX
(defun make-constant (num)
  num)

(defun make-variable (sym)
 sym)

(defun make-sum (poly1 poly2)
  (list '+ poly1 poly2))

(defun make-product (poly1 poly2)
  (list '* poly1 poly2))

(defun make-power (poly num)
  (list '^ poly num))



;;SIMPLE - acccepts any form of input : either complexl or (var 'coeff list-of_coeffs) or (var 'pairs (deg coeff)) -- may or may not be distinct
(defun make-simple-polynomial(poly)
  (cond
    ((polynomial-p poly)  (simplify poly))
    ((eq (second poly) 'COEFF) (list 'SIMPLE (first poly) (third poly)))
    ((eq (second poly) 'PAIR) (list 'SIMPLE (first poly) (convert-coeff (third poly))))
  )
)


;Given coeff pairs, converts it into a list
;ASSUMES VALID INPUT 
(defun convert-coeff (coeff)
  (if (= 1 (length coeff)) 
      (let* ((pair (car coeff))  (power (degree pair)))
        ( if (exponent-p power) (append (make-list power :initial-element 0) (list (coefficient pair)))
            NIL
        ))     
      (sum-coefficients (convert_coeff (list (car coeff))) (convert_coeff (cdr coeff))))
)



(defun degree (pair)
  (first pair))

(defun coefficient (pair)
  (second pair))

(defun sum-coefficients (coeff1  coeff2)
  (if (null coeff1) coeff2
    (if (null coeff2) coeff1
      (cons (sum-coefficients-auxiliary (car coeff1) (car coeff2)) (sum-coefficients (cdr coeff1) (cdr coeff2)))) 
      ))

(defun sum-coefficients-auxiliary (symb1 symb2)
  (if (and (numberp symb1) (numberp symb2)) (+ symb1 symb2)
    (if (or (eq symb1 'C) (eq symb2 'C)) 'C 0)
  )
)



;;
;; Recognizers for complex polynomials
;;

(defun constant-p (poly)
 ; (or (numberp poly)) (eq 'C poly) (and (simple-p poly) (= 0 (polynomial-degree poly))))
  (or (numberp poly) (eq 'C poly)) )


(defun variable-p (poly)
 (symbolp poly))

(defun sum-p (poly)
  (let ((poly1 (sum-arg1 poly)) (poly2 (sum-arg2 poly))) 
     (and (listp poly) (= 3 (length poly)) (eq (operator poly) '+) (polynomial-p poly1) (polynomial-p poly2) (compatible poly1 poly2))))

(defun product-p (poly)
  (let ((poly1 (product-arg1 poly)) (poly2 (product-arg2 poly))) 
     (and (listp poly) (= 3 (length poly)) (eq (operator poly) '*) (polynomial-p poly1) (polynomial-p poly2) (compatible poly1 poly2))))

(defun power-p (poly)
  (and (listp poly) (= 3 (length poly))  (eq (operator poly) '^) (polynomial-p (power-base poly)) (exponent-p (power-exponent poly))))

;ASSUMES that third element is a list of real numbers
(defun simple-p (poly)
; (and (listp poly) (= 3 (length poly)) (eq (first poly) 'SIMPLE) (symbolp (second poly)) (listp (third poly))))
  (or (constant-p poly) (and (listp poly) (= 3 (length poly)) (eq (first poly) 'SIMPLE) (symbolp (second poly)) (listp (third poly)))))

(defun polynomial-p (poly)
  (if (null (variable-symbol poly)) NIL 
    (or (constant-p poly) (variable-p poly) (simple-p poly)  (sum-p poly) (product-p poly) (power-p poly))))

(defun exponent-p (power)
  (and (integerp power) (<= 0 power)))

;;
;; Selectors for polynomials
;;


;; Simple ones
(defun constant-numeric (const)
  (cond 
    ((numberp const) const)
    ;((and (constant-p const) (simple-p const)) (car (coefficient-list const)))
  )
)


;Return NIL if no valid variable symbol is found
(defun variable-symbol (poly)
  (cond
    ((constant-p poly) poly) ;TODO : Check correctness
    ((variable-p poly) poly)
    ((simple-p poly) (second poly))
    ((sum-p poly) (let (
        (var1 (variable-symbol (sum-arg1 poly)))
        (var2 (variable-symbol (sum-arg2 poly)))
      )
      (cond
        ((constant-p var1) (variable-symbol var2))
        ((constant-p var2) (variable-symbol var1))
        ((eq var1 var2) var1)
        ((T) NIL)
      )
    ))
     ((product-p poly) (let (
        (var1 (variable-symbol (product-arg1 poly)))
        (var2 (variable-symbol (product-arg2 poly)))
      )
      (cond 
        ((constant-p var1) (variable-symbol var2))
        ((constant-p var2) (variable-symbol var1))
        ((eq var1 var2) var1)
        ((T) NIL)
      ) 
 
    ))
    ((power-p poly) (variable-symbol (power-base poly)))
  )
)

(defun operator (poly)
  (first poly)
)

(defun sum-arg1 (sum)
  (second sum))

(defun sum-arg2 (sum)
  (third sum))

(defun product-arg1 (prod)
  (second prod))

(defun product-arg2 (prod)
  (third prod))

(defun power-base (pow)
  (second pow))

(defun power-exponent (poly)
  (third poly))

(defun coefficient-list (poly)
  (cond
    ((constant-p poly) (list poly))
    ((simple-p poly) (third poly))
  )
)


;;Degree of a polynomial
(defun polynomial-degree (poly)
  (cond
    ((simple-p poly) (length (coefficient-list poly)))
    ((polynomial-p poly) (polynomial-degree (simplify poly)))
))

;;Whether variables of both poly match
(defun compatible (poly1 poly2)
    (let 
      (
        (var1 (variable-symbol poly1))
        (var2 (variable-symbol poly2))
      )
     (if (or (null var1) (null var2)) NIL
     ;  If one of them is inherently not a valid polynomial, incompatible
        (if (or (constant-p poly1) (constant-p poly2) ) T (eq var1 var2)) ) 
        ;If one of them is a constant, compatible
        ; else look at what variables they contain
    ))

;;Converting to simplified form
(defun simplify (poly)
 (cond
  ((simple-p poly) poly)
  ((constant-p poly) poly) ;(make-simple-polynomial (list () 'COEFF (constant-numeric poly))))
  ((variable-p poly) (make-simple-polynomial (list (variable-symbol poly) 'COEFF '(0 1))))
  ((product-p poly) (simple-product (product-arg1 poly) (product-arg2 poly))) 
  ((sum-p poly) (simple-sum (sum-arg1 poly) (sum-arg2 poly)))
  ((power-p poly) 
      (if (= 0 (power-exponent poly)) 1 
        (if (= 1 (power-exponent poly)) (simplify (power-base poly));
          (simple-product (power-base poly) (make-power (power-base poly) (- (power-exponent poly) 1)))
      )
 ))
))


(defun integrate (poly)
  (cond
    ((simple-p poly) (cons 'C (integrate-auxiliary (coefficient-list poly) 1)))
    ((polynomial-p poly) (integrate (simplify poly)))
  )
)

(defun integrate-auxiliary (poly pow)
  (if (null poly) NIL
    (cons (/ (car poly) pow) (integrate-auxiliary (cdr poly) (+ 1 pow)))
  )
)


(defun simple-sum (poly1 poly2)
;TODO : Extend to many arguments
  (let ( (sp1 (simplify poly1)) (sp2 (simplify poly2))) 
  (cond
    
      ((and (constant-p poly1) (constant-p poly2)) (+ poly1 poly2))
      ((constant-p poly1) (list 'SIMPLE (variable-symbol sp2) (sum-coefficients (coefficient-list sp1) (coefficient-list sp2))))
      ((compatible poly1 poly2) (list 'SIMPLE (variable-symbol sp1) (sum-coefficients (coefficient-list sp1) (coefficient-list sp2))))
  ))
)


(defun simple-product (poly1 poly2)
;TODO : Extend to many arguments
 (let ( (sp1 (simplify poly1)) (sp2 (simplify poly2)))
   (cond
      ((and (constant-p poly1) (constant-p poly2)) (* poly1 poly2))
      ((constant-p poly1) (list 'SIMPLE (variable-symbol sp2) (product-coefficients (coefficient-list sp1) (coefficient-list sp2))))
      ((compatible poly1 poly2) (list 'SIMPLE (variable-symbol sp1) (product-coefficients (coefficient-list sp1) (coefficient-list sp2))))   )
   ; (if (compatible sp1 sp2) (list 'SIMPLE  (variable-symbol sp1) (product-coefficients (coefficient-list sp1) (coefficient-list sp2)))
   ;   NIL)
  )
)

(defun product-coefficients (poly1 poly2)
;TODO : Rename variables here properly; Extend to many arguments
  (if (or (null poly1) (null poly2)) NIL 
    (sum-coefficients (product-coefficients-auxiliary (car poly1) poly2) (right-shift (product-coefficients (cdr poly1) poly2)))
  )
)



(defun product-coefficients-auxiliary (symb1 poly2)
;TODO : Rename variables properly
  (let ( (prod (lambda (x y) (if (or (eq 'C x) (eq 'C y)) 'C (* x y))))) 
           
      (mapcar #'(lambda (x) (funcall prod x symb1)) poly2)
))

(defun right-shift (coeff)
  (cons 0 coeff)
)


(defun simple-subtract (poly1 poly2)
  (simple-sum poly1 (simple-product (replace-coefficients poly2 '(-1) )) poly2))


;Expect simple polynomial as input
(defun simple-purge (poly)
  (let ( (coeff (coefficient-list poly)))
  (if (simple-p poly) (if (equal (list 0) (last coeff)) (simple-purge (replace-coefficients poly (butlast coeff)) )  poly)
  NIL))
)


(defun replace-coefficients (poly new-list)
 (if (simple-p poly) (make-simple-polynomial (list (variable-symbol poly) 'COEFF new-list)))
)
