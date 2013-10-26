PolynomialManipulator
=====================

The `polynomial.lisp` LISP code defines functions that can be used to 
- construct
- recognize
- factorize
- arithmetically manipulate
- integrate
- decompose
- partial-split
polynomials of rational coefficients, with a single variable/none.
NOTE: A simple polynomial is a representation where we have decomposed the whol polynomial after applying all + and * operations to a_n x^n + ... a_0  form.

Construction functions :
	- make-constant
	- make-variable
	- make-sum
	- make-diff
	- make-diff
	- make-product
	- make-power
	- make-simple-polynomial

The user can use make-simple-polynomial to create a polynomial 'object'.
The input is either of the form `((variable-symbol) COEFF (list-of-coefficients-by-order-of-power))`
or `((variable-symbol) PAIR (list of (degree coeff) pairs))`
Polynmial inputs can be given as `(op poly1 poly2)` where op is either *, - or + in prefix notation. `(^ poly cons)` is also a valid input signifying poly to the power of cons.
Polynomials with different variable symbols can be used. The function `compatible` checks whether two polynomials given have the same variables used, if any.
For example, `(simple-sum '(SIMPLE X (1/2 2)) '(SIMPLE Y (3 2)))` returns `NIL` because the the polynomials are incompatible.
Recognization functions :
- constant-p
- variable-p
- sum-p
- power-p
- simple-p
	
The following function enable polynomial manipulation: 
- simple-sum
- simple-subtract
- simple-product
- divide

`divide` returns a quotient, remainder pair.

Note that, any basic function like sum, product can be done on polynomials with rational coefficients.

`polynomial-gcd` returns the greatest common divisor of two polynomials using the euclidean algorithm.
`extended-euclid` returns a list of three values : (gcd, A, B) such that A*poly1 + B*poly2 = gcd.
`polynomial-factorize` returns a list of factors, which are basically polynomials. Factorization results in extraction of all linear factors of any rational polynomial, some quadratic factors and one more polynomial of a higher degree.
The implementation is a naive search over a finite set of candidate factors.

`(split-frac num den)` returns list of (num den) pairs : basically a sum of num/den for all these pairs would give the original input polynomial. This would have attempted to do a partial fraction split.

As an example,

`> (split-frac 1 '(* (+ X 1) (^ X 2)))`
`((1 (SIMPLE X (1 1))) ((SIMPLE X (1 -1)) (SIMPLE X (0 0 1))))`
Implying that (1/((x+1)*(x^2))) can be split into two fractions: 1/(x+1) & (-x+1)/(x^2)

Here's a bigger example that the reader can verify :
`(split-frac 1 '(* (^ (+ X 1) 2) (^ X 3)))`
`(((SIMPLE X (-4/9 -1/3)) (SIMPLE X (1/9 2/9 1/9))) ((SIMPLE X (1/9 -2/9 1/3)) (SIMPLE X (0 0 0 1/9))))`


`(split-frac 'X '(* (^ (+ X 1) 2) (^ X 3)))`
`((-3 1) ((SIMPLE X (1/3 2/9)) (SIMPLE X (1/9 2/9 1/9))) (3 1) ((SIMPLE X (0 1/9 -2/9)) (SIMPLE X (0 0 0 1/9))))`


	

