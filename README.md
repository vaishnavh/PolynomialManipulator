PolynomialManipulator
=====================

The following LISP code defines functions that can be used to 
- construct
- recognize
- factorize
- arithmetically manipulate
- decompose
- partial-split
polynomials of rational coefficients, with a single variable/none.

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
The input is either of the form ((variable-symbol) COEFF (list-of-coefficients-by-order-of-power))
or ((variable-symbol) PAIR (list of (degree coeff) pairs))

Recognization functions :
	- constant-p
	- variable-p
	- sum-p
	- power-p
	- simple-p
	
The following function enable polynomial manipulation: 
	

