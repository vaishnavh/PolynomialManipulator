;; -----------------------------------------------------------------------------------
;; A Simple Polynomial consists of a_0 x^0 + ... a_n x^n = ('simple x (a_0 a_1 a_2 ... a_n))
;; A Complex Polynomial consists of Simple Polynomial, sum, products and powers 
;;
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

;;SIMPLE - acccepts any form of input : either complexl or (var 'coeff list_of_coeffs) or (var 'pairs (deg coeff)) -- may or may not be distinct
(defun make-simple-polynomial(poly)
  (cond
    ((polynomial-p poly)  (simplify poly))
    ((eq (second poly) 'COEFF) (list 'SIMPLE (first poly) (third poly)))
    ((eq (second poly) 'PAIRS) (list 'SIMPLE (first poly) (convert_coeff (third poly))))
  )
)

;Given coeff pairs, converts it into a list
;Assumes valid input
(defun convert_coeff (coeff)
  (if (= 1 (length coeff)) 
      (let ((pair (car coeff)))
          (append (make-list (degree pair) :initial-element 0) (list (coefficient pair)))
        )
      (sum_coefficients (convert_coeff (list (car coeff))) (convert_coeff (cdr coeff)))
  )
)

(defun degree (pair)
  (first pair))

(defun coefficient (pair)
  (second pair))

(defun sum_coefficients (coeff1  coeff2)
  (if (null coeff1) coeff2
    (if (null coeff2) coeff1
      (cons (+ (car coeff1) (car coeff2)) (sum_coefficients (cdr coeff1) (cdr coeff2)))
    )
  )
)
;;
;; Recognizers for complex polynomials
;;

(defun constant-p (poly)
  (numberp poly))

(defun variable-p (poly)
 (symbolp poly))

(defun sum-p (poly)
  (let ((poly1 (sum-arg1 poly)) (poly2 (sum-arg2 poly))) 
     (and (listp poly) (eq (operator poly) '+) (polynomial-p poly1) (polynomial-p poly2) (compatible poly1 poly2)) 
  )
)

(defun product-p (poly)
  (let ((poly1 (product-arg1 poly)) (poly2 (product-arg2 poly))) 
     (and (listp poly) (eq (operator poly) '*) (polynomial-p poly1) (polynomial-p poly2) (compatible poly1 poly2)) 
  )
)

(defun power-p (poly)
  (and (listp poly) (eq (operator poly) '^) (polynomial-p (power-base poly)) (exponent-p (power-exponent poly))) 
  )

(defun polynomial-p (poly)
  (if (null (variable-symbol poly)) NIL 
  (or (constant-p poly) (variable-p poly) (sum-p poly) (product-p poly) (power-p poly)) 
  )
)
(defun exponent-p (power)
  (and (numberp power) (<= 0 power))
)

;;
;; Selectors for polynomials
;;


;; Simple ones
(defun constant-numeric (const)
  const)


;Return NIL if no valid variable symbol is found
(defun variable-symbol (poly)
  (cond
    ((constant-p poly) poly)
    ((variable-p poly) poly)
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
    ((exponent-p poly) (variable-symbol (power-base poly)))
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

(defun power-exponent (pow)
  (third pow))


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
1
)
