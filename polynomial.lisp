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

(defun make-diff (poly1 poly2)
  (list '- poly1 poly2))

(defun make-product (poly1 poly2)
  (list '* poly1 poly2))

(defun make-power (poly num)
  (list '^ poly num))



;;SIMPLE - acccepts any form of input : either complexl or (var 'coeff list-of_coeffs) or (var 'pairs (deg coeff)) -- may or may not be distinct
;;Creates a polynomial
(defun make-simple-polynomial(poly)
  (cond
    ((polynomial-p poly)  (simplify poly))
    ((equal (second poly) 'COEFF) (list 'SIMPLE (first poly) (third poly)))
    ((equal (second poly) 'PAIR) (list 'SIMPLE (first poly) (convert-coeff (third poly))))
  )
)


;Given coeff pairs, converts it into a list (0 1) (2 3) to (1 0 3)
;ASSUMES VALID INPUT 
(defun convert-coeff (coeff)
  (if (= 1 (length coeff)) 
      (let* ((pair (car coeff))  (power (degree pair)))
        ( if (exponent-p power) (append (make-list power :initial-element 0) (list (coefficient pair)))
            NIL
        ))     
      (sum-coefficients (convert-coeff (list (car coeff))) (convert-coeff (cdr coeff))))
)



;Extract from a pair of coefficient-degree
(defun degree (pair)
  (first pair))

(defun coefficient (pair)
  (second pair))


;To sum two coefficient lists
(defun sum-coefficients (coeff1  coeff2)
  (if (null coeff1) coeff2
    (if (null coeff2) coeff1
      (cons (sum-coefficients-auxiliary (car coeff1) (car coeff2)) (sum-coefficients (cdr coeff1) (cdr coeff2)))) 
      ))


;Take care of integration constant
(defun sum-coefficients-auxiliary (symb1 symb2)
  (if (and (numberp symb1) (numberp symb2)) (+ symb1 symb2)
    (if (or (equal symb1 'C) (equal symb2 'C)) 'C 0)
  )
)



;;
;; Recognizers for complex polynomials
;;
(defun constant-auxiliary (poly)
;Filters only those without any - or + as constants
  (or (numberp poly) (equal 'C poly))
)
(defun constant-p (poly)
 ; (or (numberp poly)) (equal 'C poly) (and (simple-p poly) (equal 0 (polynomial-degree poly))))
 ; (or (constant-auxiliary poly)) (numberp (simplify poly)));(and (not (simple-p poly)) (numberp (simplify poly))))
 (constant-auxiliary poly)) ;TODO : Remember to remove the unneceesary call

(defun variable-p (poly)
 (symbolp poly))

(defun sum-p (poly)
  (let ((poly1 (sum-arg1 poly)) (poly2 (sum-arg2 poly))) 
     (and (listp poly) (= 3 (length poly)) (equal (operator poly) '+) (polynomial-p poly1) (polynomial-p poly2) (compatible poly1 poly2))))


(defun diff-p (poly)
  (let ((poly1 (sum-arg1 poly)) (poly2 (sum-arg2 poly))) 
     (and (listp poly) (= 3 (length poly)) (equal (operator poly) '-) (polynomial-p poly1) (polynomial-p poly2) (compatible poly1 poly2))))

(defun product-p (poly)
  (let ((poly1 (product-arg1 poly)) (poly2 (product-arg2 poly))) 
     (and (listp poly) (= 3 (length poly)) (equal (operator poly) '*) (polynomial-p poly1) (polynomial-p poly2) (compatible poly1 poly2))))

(defun power-p (poly)
  (and (listp poly) (= 3 (length poly))  (equal (operator poly) '^) (polynomial-p (power-base poly)) (exponent-p (power-exponent poly))))

;ASSUMES that third element is a list of real numbers
(defun simple-p (poly)
; (and (listp poly) (= 3 (length poly)) (equal (first poly) 'SIMPLE) (symbolp (second poly)) (listp (third poly))))
  (or (constant-auxiliary poly) (and (listp poly) (= 3 (length poly)) (equal (first poly) 'SIMPLE) ; ?Required(symbolp (second poly))
    (listp (third poly)))))

(defun polynomial-p (poly)
  (if (null (variable-symbol poly)) NIL 
    (or (constant-p poly) (variable-p poly) (simple-p poly)  (sum-p poly) (diff-p poly) (product-p poly) (power-p poly))))

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
;To find the variable contained by the polynomial
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
        ((equal var1 var2) var1)
        ((T) NIL)
      )
    ))
    ((diff-p poly) (let (
        (var1 (variable-symbol (diff-arg1 poly)))
        (var2 (variable-symbol (diff-arg2 poly)))
      )
      (cond
        ((constant-p var1) (variable-symbol var2))
        ((constant-p var2) (variable-symbol var1))
        ((equal var1 var2) var1)
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
        ((equal var1 var2) var1)
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

(defun diff-arg1 (diff)
  (second diff))

(defun diff-arg2 (diff)
  (third diff))

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
    ((simple-p poly) (- (length (coefficient-list poly)) 1))
    ((polynomial-p poly) (polynomial-degree (simplify poly)))
))

;;Whether variables of both poly match
(defun compatible (poly1 poly2)
    (let* 
      (
        (sp1 (simplify poly1))
        (sp2 (simplify poly2))
        (var1 (variable-symbol sp1))
        (var2 (variable-symbol sp2))
      )
     (if (or (null var1) (null var2)) NIL
     ;  If one of them is inherently not a valid polynomial, incompatible
        (if (or (constant-p sp1) (constant-p sp2) ) T (equal var1 var2)) ) 
        ;If one of them is a constant, compatible
        ; else look at what variables they contain
    ))

;;Converting to simplified form
(defun simplify (poly)
 (cond
  ((simple-p poly) (simple-purge poly))
  ((constant-auxiliary poly)  poly) ;(make-simple-polynomial (list () 'COEFF (constant-numeric poly))))
  ((variable-p poly) (make-simple-polynomial (list (variable-symbol poly) 'COEFF '(0 1))))
  ((product-p poly) (simple-product (product-arg1 poly) (product-arg2 poly))) 
  ((sum-p poly) (simple-sum (sum-arg1 poly) (sum-arg2 poly)))
  ((diff-p poly) (simple-subtract (diff-arg1 poly) (diff-arg2 poly)))
  ((power-p poly) 
      (if (equal 0 (power-exponent poly)) 1 
        (if (= 1 (power-exponent poly)) (simplify (power-base poly));
          (simple-product (power-base poly) (make-power (power-base poly) (- (power-exponent poly) 1)))
      )
 ))
))


;Integrate a polynomial

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

;Add two polynials
(defun simple-sum (poly1 poly2)
;TODO : Extend to many arguments
  (let* ( (sp1 (simplify poly1)) (sp2 (simplify poly2)) (c1 (coefficient-list sp1)) (c2 (coefficient-list sp2)) (csum (sum-coefficients c1 c2))) 
  (if (>= 1 (length  csum)) (car csum)  
    (cond 
        ((and (constant-p poly1) (constant-p poly2)) (+ poly1 poly2))
        ((constant-p poly1) (simple-purge (list 'SIMPLE (variable-symbol sp2) csum)))
        ((compatible poly1 poly2) (simple-purge (list 'SIMPLE (variable-symbol sp1) csum)))))
))



;Multiply two polynomials
(defun simple-product (poly1 poly2)
;TODO : Extend to many arguments
 (let ( (sp1 (simplify poly1)) (sp2 (simplify poly2)))
   (cond
      ((and (constant-p sp1) (constant-p poly2)) (* poly1 poly2))
      ((constant-p sp1) (simple-purge (list 'SIMPLE (variable-symbol sp2) (product-coefficients (coefficient-list sp1) (coefficient-list sp2)))))
      ((compatible sp1 sp2) (simple-purge (list 'SIMPLE (variable-symbol sp1) (product-coefficients (coefficient-list sp1) (coefficient-list sp2))))))
   ; (if (compatible sp1 sp2) (list 'SIMPLE  (variable-symbol sp1) (product-coefficients (coefficient-list sp1) (coefficient-list sp2)))
   ;   NIL)
  )
)



;Multiply two coefficient lists
(defun product-coefficients (poly1 poly2)
;TODO : Rename variables here properly; Extend to many arguments
  (if (or (null poly1) (null poly2)) NIL 
    (sum-coefficients (product-coefficients-auxiliary (car poly1) poly2) (right-shift (product-coefficients (cdr poly1) poly2)))
  )
)

(defun product-coefficients-auxiliary (symb1 poly2)
;TODO : Rename variables properly
  (let ( (prod (lambda (x y) (if (or (equal 'C x) (equal 'C y)) 'C (* x y))))) 
           
      (mapcar #'(lambda (x) (funcall prod x symb1)) poly2)
))

(defun right-shift (coeff)
  (cons 0 coeff)
)



;Subtract two polynomials
(defun simple-subtract (poly1 poly2)
  (simple-sum poly1 (simple-product -1 poly2)))


;Expect simple polynomial as input; Purges : adds up like terms
;NOTE: ASSUMPTION MADE
(defun simple-purge (poly)
  (let ( (coeff (coefficient-list poly)))
  (cond
    ((equal (list 0) coeff) 0)
    ((simple-p poly) (if (equal (list 0) (last coeff)) (simple-purge (replace-coefficients poly (butlast coeff)) )  
                            (if (= 1 (length coeff)) (car coeff) poly)))
                           ;poly))
                      
    ((T) NIL)
  )
  )
)


;Given a polynomial ,replaces its coeeficient list
(defun replace-coefficients (poly new-list)
  (cond
    ((constant-p poly) (if (= 1 (length new-list)) (car new-list) NIL))
    ((simple-p poly) (if (simple-p poly) (make-simple-polynomial (list (variable-symbol poly) 'COEFF new-list))))
  ) 
)

;ASSUMES SIMPLE POLYNOMIAL
;Returns the coefficient of the highest degree
(defun highest-coefficient (poly)
  (first (last (coefficient-list poly))))

;Divide polynomials and return (qoutient  reminder)
(defun divide (poly1 poly2)
  (if (compatible poly1 poly2)
  (let* ((sp1 (simplify poly1)) (sp2 (simplify poly2))(deg1 (polynomial-degree sp1) ) (deg2 (polynomial-degree sp2)))
      (if (and (constant-p poly1) (constant-p poly2)) (list (/ poly1 poly2) 0); ?Required(let* ( (r (mod poly1 poly2)) (q (/ (- poly1 r) poly2))) (list q r))
        (if (< deg1 deg2) (list 0 sp1)
        (let* ( 
            (t1 (highest-coefficient sp1)) 
            (t2 (highest-coefficient sp2)) 
            (var (variable-symbol sp1)) 
            (q (/ t1 t2))
            (f (make-simple-polynomial (list var 'PAIR (list (list (- deg1 deg2) q)))))
            (to-remove (simple-product f sp2))
            (subresult (divide (simple-subtract sp1 to-remove) sp2))
            ) 
            (list ;(make-simple-polynomial (list var 'COEFF (append (coefficient-list (first subresult)) (list q))))
             (simple-sum f (first subresult))
             (second subresult))
        )))
  ) 
  NIL
  )
)

;Some auxiliary division functions : give the output of division here
(defun quotient (answer)
  (first answer))

(defun remainder (answer)
  (second answer))


;Remainder zero
(defun divisible (answer)
  (equal 0 (remainder answer))
) 
 

;----------------------------------FUNCTIONS FOR FACTORIZATION OF POLYNOMIALS------------------------
;Assumes integer polynomials
(defun get-linear-factors (poly)
  (let* ((sp (simplify poly)) (deg (polynomial-degree sp)))
  (cond 
  ( (> 1 deg) (list sp NIL))
  ( (= 1 deg) (list 1 (list sp)))
  (T  (let* (
          (sp (simplify poly))
          (coeff (coefficient-list sp))
          (const (car coeff)) 
          (high (highest-coefficient sp)) 
          ;(rat (/ const high))
          ;(a_0 (abs (numerator rat)))
          ;(a_n (abs (denominator rat)))
          (a_0 const)
          (a_n high)
          ) 
          (linear-factorize-loop sp a_0 a_n 0 1)   
  ))))
)

(defun get-quadratic-factors (poly)
 (let* ((sp (simplify poly)) (deg (polynomial-degree sp)))
  (cond 
  ( (> 2 deg) (list sp NIL))
  ( (= 2 deg) (list 1 (list sp)))
  (T  (let* (
          (sp (simplify poly))
          (coeff (coefficient-list sp))
          (const (car coeff)) 
          (high (highest-coefficient sp)) 
          (rat (/ const high))
         ; (a_0 (abs (numerator rat)))
         ; (a_n (abs (denominator rat)))
          (a_0 const)
          (a_n high)
          
          ) 
          (quadratic-factorize-outerloop sp a_0 a_n 0 1)   
  ))))
)

;ASSUMPTION spl is simple polynomial
(defun linear-factorize-loop (spl a_0 a_n b_0 b_1)      
  ;Function definition
      (cond
          ((> b_1 a_n) (list spl NIL));(if (> b_0 a_n)) (list spl NIL) (factorize-loop spl a_0 a_n (+ 1 b_0) 1)))
          ((> b_0 a_0) (linear-factorize-loop spl a_0 a_n 0 (+ 1 b_1) ))
          (T (let* (
                      (fac1  (make-simple-polynomial (list (variable-symbol spl) 'PAIR (list (list 0 b_0) (list 1 b_1))) ))
                      (fac2  (make-simple-polynomial (list (variable-symbol spl) 'PAIR (list (list 0 (- 0 b_0)) (list 1 b_1))) ))
                      (div1 (divide spl fac1))
                      (div2 (if (divisible div1) (divide (quotient div1) fac2) (divide spl fac2)))
                      (sp1 (cond 
                              ((and (divisible div1) (divisible div2)) (quotient div2)) 
                                ((divisible div1) (quotient div1))
                                ((divisible div2) (quotient div2))
                                (T spl))
                      )
                      (result  (if (and (not (divisible div1)) (not (divisible div2)))  (linear-factorize-loop sp1 a_0 a_n (+ b_0 1) b_1) (get-linear-factors sp1)))
                      (res1 (if (divisible div1) (list fac1) NIL))
                      (res2 (if (divisible div2) (append res1 (list fac2)) res1))
                    )
                    (list (first result) (append res2 (second result)))
                    
          
                ))
        )      
)



;ASSUMPTION spl is simple polynomial
(defun quadratic-factorize-outerloop (spl a_0 a_n b_0 b_1) 
          
  ;Function definition
      (cond
          ((> b_1 a_n) (list spl NIL))
          ((> b_0 a_0) (quadratic-factorize-outerloop spl a_0 a_n 0 (+ 1 b_1)))
          (T ( let* 
              ( (result (quadratic-factorize-innerloop spl a_0 a_n b_0 b_1 0))
                (result2 (quadratic-factorize-outerloop (first result) a_0 a_n (+ 1 b_0) b_1))          
              )
               (list (first result2) (append (second result) (second result2)))
          )
        )      
    )
)

;Assumption spl is simple polynomial : an auxliary function to loop over
(defun quadratic-factorize-innerloop (spl a_0 a_n b_0 b_1 c)
    ( let* ( (BSQ (* c c))   (fourAC (* 4 (* b_0 b_1)))  )
      (cond
        ((> 2 (polynomial-degree spl)) (list spl))
        ((= 2 (polynomial-degree spl)) (list 1 (list spl)))
        ((>= BSQ fourAC) (list spl))
        (T 
              (let* (
                      (fac1  (make-simple-polynomial (list (variable-symbol spl) 'PAIR (list (list 0 b_0) (list 1 c) (list 2 b_1))) ))
                      (fac2  (make-simple-polynomial (list (variable-symbol spl) 'PAIR (list (list 0 b_0) (list 1 (- 0 c)) (list 2 b_1))) ))
                      (fac3  (make-simple-polynomial (list (variable-symbol spl) 'PAIR (list (list 0 (- 0 b_0)) (list 1 c) (list 2 b_1))) ))
                      (fac4  (make-simple-polynomial (list (variable-symbol spl) 'PAIR (list (list 0 (- 0 b_0)) (list 1 (- 0 c)) (list 2 b_1))) ))
                      (div1 (divide spl fac1))
                      (sp1 (if (divisible div1) (quotient div1) spl))
                      (div2 (divide sp1 fac2))
                      (sp2 (if (divisible div2) (quotient (divide sp1 fac2)) sp1 ))
                      (div3 (divide sp2 fac3))
                      (sp3 (if (divisible div3) (quotient (divide sp2 fac3)) sp2))
                      (div4 (divide sp3 fac4))
                      (sp4 (if (divisible div4) (quotient (divide sp3 fac4)) sp3))
                      ;sp4 is the remaining polynomial after all 4 divisions
                      (result (quadratic-factorize-innerloop sp4 a_0 a_n b_0 b_1 (+ 1 c)))
                      (res1 (if (divisible div1) (list fac1) NIL))
                      (res2 (if (divisible div2) (append (list fac2) res1) res1))
                      (res3 (if (divisible div3) (append (list fac3) res2) res2))
                      (res4 (if (divisible div4) (append (list fac4) res3) res3))
                     )

                    (list (first result) (append res4 (second result)))
              )
             ) 
           
        
      )
    ) 
)


;-------------------------------------------------------------------------------
;Returns the gcd of two polynomials
(defun polynomial-gcd (poly1 poly2)
  (let* (
          (sp1 (simplify poly1))
          (sp2 (simplify poly2))
          (deg1 (polynomial-degree sp1))
          (deg2 (polynomial-degree sp2))
          (A (if (< deg1 deg2) sp2 sp1))
          (B (if (>= deg1 deg2) sp2 sp1))
          (D (divide A B))
          (Q (quotient D))
          (R (remainder D))
  )
  (if (equal 0 R) (polynomial-reduce B) (polynomial-gcd B R))

  ))


;ASSUMES poly1 has greater than or equal degree
;Given poly1 and poly2 returns (gcd A B) such that Apoly1 + Bpoly2 = gcd
;An aliter function for polynomial-gcd
(defun extended-euclid (poly1 poly2)
 (let* (
          (sp1 (simplify poly1))
          (sp2 (simplify poly2))
          (deg1 (polynomial-degree sp1))
          (deg2 (polynomial-degree sp2))
          (A (if (< deg1 deg2) sp2 sp1))
          (B (if (>= deg1 deg2) sp2 sp1))
  ;        (D (divide A B))
  ;        (Q (quotient D))
  ;        (R (remainder D))
  )
  (if (equal 0 B) (list A 1 0) 
      (let* (
             (D (divide A B))
             (Q (quotient D))
             (R (remainder D))
             (res (extended-euclid B R)))

        (list (first res) (third res)   (simple-subtract (second res) (simple-product Q (third res))) ) 
      )
      
      )

  ) 
)

;Assumes simple polynomial : Given a polynomial with integer coefficients, extracts the  constant factor
(defun polynomial-reduce (poly)
  (replace-coefficients poly (mapcar (lambda (x) (/ x (gcd-list (coefficient-list poly))))  (coefficient-list poly)))
)



;Gets gcd of a list of numbers
(defun gcd-list (x)
  (if (= 1 (length x)) 
    (car x)
    (gcd (car x) (gcd-list (cdr x)))
  )
)

;Can be any polynomial : can have rational coeffs
;Returns quadratic, linear factors
(defun polynomial-factorize (poly)
  (let* (
        (coeff (coefficient-list poly))
        (mult (den-lcm-list coeff))
        (polym (simple-product poly mult))
        (polyr (polynomial-reduce polym))
        (reduced-value (gcd-list (coefficient-list polym)))
        (lin-fac (get-linear-factors polyr))
        (remainder-poly (first lin-fac))
        (linear-factors (second lin-fac))
        (quad-fac (get-quadratic-factors remainder-poly))
      ) 
      (append (list (/ reduced-value mult)) (list (car quad-fac)) linear-factors (second quad-fac))
  )
)


;Given numerator and denominator, decomposes : returns a list of pairs of nums and dens
(defun split-frac (cnum cden)
 (let* ( (num (simplify cnum))
         (den (simplify cden))
        (num-deg (polynomial-degree num))
        (den-deg (polynomial-degree den))
        
        )
 
  (if (>= num-deg den-deg)
      (let* (
              (div (divide num den))
      )
        (if (equal 0 (remainder div)) (list (list (quotient div) 1))   (append (list (list (quotient div) 1))  (split-frac (remainder div) den)) )
       
      )
    (let* (
          (lr (get-linear-factors den))
          (qr (get-quadratic-factors (first lr)))
          (qr-enum (count-list (second qr)))
          (lr-enum (count-list (second lr)))
          (factor-list (append (list (list 1 (first qr)))  qr-enum lr-enum)) 
          (fl (remove-constant factor-list))
          (cop (get-coprime-fac fl))
      )
      
        (if (null cop)
            (list (list num den))
              (let* (
                    (P (simplify (list '^ (second (first cop)) (first (first cop)))))
                    (Q (simplify (list '^ (second (second cop)) (first (second cop)))))
                    (ext-euc (extended-euclid P Q))
                    (D (first ext-euc))
                    (A (second ext-euc))
                    (B (third ext-euc)) 
              )
              (append (split-frac (simple-product A num) (simple-product Q D))  (split-frac (simple-product B num) (simple-product D P)))
              )
        )
    )
   )
 )
 
)


;-----------------------FUNCTIONS HANDLING list of pairs of <power, polynomial>-------------------
;Given a  list of pairs of <power - polynomial>, removes those with polynomial of degree equal 0; assume power>0
(defun remove-constant (factor-list)
  (if (null factor-list) NIL 
  (let ((f (first factor-list)))
      (if (equal 0 (polynomial-degree (second f))) (remove-constant (cdr factor-list))   (append (list f) (remove-constant (cdr factor-list))))
  ))
)



;Given a list of <power - polynomial>, returns a list of two such entities, whose polynomials are coprime; If none found, returns nil
(defun get-coprime-fac (factor-list)
 (if (>= 1 (length factor-list))
  NIL
  (let* (
            (a (first factor-list))
            (b (second factor-list))
            (gcd-ab (polynomial-gcd (second a) (second b)))
        )
        (if (< 0 (polynomial-degree gcd-ab))  
              (let* (
                        (gcd-ac (get-coprime-fac (append (list a) (cdr (cdr factor-list))))) ;list with second element removed
                    )
                (if (null gcd-ac)  (get-coprime-fac (cdr factor-list))  gcd-ac)
              )  
              (list a b) ;coprime
        )
  )
 )

)
;------------------------------------------------------------

;Given a list of rational numbers returns a number which when multiplied to it, converts all numbers to integers
(defun den-lcm-list (x)
  (if (= 1 (length x))
    (denominator (car x) )
    (lcm (denominator (car x)) (den-lcm-list (cdr x)))
  )
)

;assumes simply poly : what is the zero of this linear poly?
(defun zero-linear (lin)
(let* (
      (coeff (coefficient-list lin))
  )
  (/ (- 0 (first coeff)) (second coeff))
)
)

;;-------------------FUNCTIONS HANDLING list of factors <poly, poly . . . > --------------------------;;
;Given a list of factors, returns a  list of pairs of <count, polynomial> where count = number of occurences
(defun count-list (factor-list)
  (if (null factor-list) NIL (let ((fac (car factor-list)))   (append (list (list (count-fac fac factor-list) fac))   (count-list (remove-fac fac factor-list))) ))
)

;Removes a specific factor from the list
(defun remove-fac (fac factor-list)
  (if (null factor-list) NIL 
      (if (equal fac (car factor-list)) (remove-fac fac (cdr factor-list)) (append (list (car factor-list)) (remove-fac fac (cdr factor-list))))
  )

)


;Given a factor, finds number of occurences in the list
(defun count-fac (fac factor-list)
  (if (null factor-list) 0 
      (if (equal fac (car factor-list)) (+ 1 (count-fac fac (cdr factor-list))) (count-fac fac (cdr factor-list)))
  )
)
