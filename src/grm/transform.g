header {
#include <string>
#include <map>
#include <exception>
#include <iostream>
#include <h/fcAST.h>
//using namespace std;
}

options {
        language=Cpp;
}

/**
 * This file performs some transformations on an Intuitive type AST.
 * Generation depends on the following files:
 * IntuitiveTokenTypes.txt
 * Compilation depends on the following files:
 * h/fcAST.h
 * From this file the following files will be created:
 * Transform.cpp, Transform.hpp, TransformTokenTypes.hpp, TransformTokenTypes.txt
 * @author Gabor Bakos (baga@users.sourceforge.net)
 */

class Transform extends TreeParser;
options {
	importVocab=Intuitive;
	ASTLabelType="RefFcAST";
	buildAST=true;
	defaultErrorHandler=false;
}

{
	private:
		std::map<std::string, std::string> changes;

	public:
		///Clears the map of changes.
		void clearChangesDictionary()
		{
			changes.clear();
		}

		/**
		 * Add a new pair to the map
		 * @param what What to change
		 * @param toWhat Will change it to this
		 */
		void addChange(const std::string &what, const std::string &toWhat)
		{
			changes[what]=toWhat;
		}
}

inp:
	(expr)
	|
	;

expr
	{
		std::string a,b,c,d;
	}
	:
	 #(PLUS expr expr)
	|#(MINUS expr expr)
	|#(NEG expr)
	|#(MULT expr expr)
	|#(INVISIBLETIMES expr expr)
	|#(DIV expr expr)
	|#(MOD expr expr )
	|#(MODP expr expr (expr)?)
	|#(EQUIV expr expr)
	|#(MATRIXPRODUCT expr expr)
	|#(MATRIXEXPONENTIATION expr expr)
	|#(FACTOROF expr expr)
	|#(CIRCUM expr expr)
	|#(FACTORIAL expr)
	|#(DFACTORIAL expr)
	|#(UNDERSCORE expr expr)
	|#(PM expr expr)
	|#(MP expr expr)
	|#(DERIVE expr expr)
	|#(DERIVET expr expr)
	|#(DERIVEX expr expr)
	|#(NTHDERIVE expr expr expr)
	|#(NTHDERIVEX expr expr)
	|#(FUNCINVERSE expr)
	|#(DEFINTEGRAL expr expr expr expr)
	|#(INDEFINTEGRAL expr expr)
	|#(SUM expr expr expr expr)
	|#(PROD expr expr expr expr)
	|#(EQUAL expr expr)
	|#(NEQ expr expr)
	|#(LESS expr expr)
	|#(LEQ expr expr)
	|#(NOTLESS expr expr)
	|#(LESSNOTEQ expr expr)
	|#(NOTLEQ expr expr)
	|#(GREATER expr expr)
	|#(GEQ expr expr)
	|#(NOTGREATER expr expr)
	|#(GREATERNOTEQ expr expr)
	|#(NOTGEQ expr expr)
	|#(SETSUBSET expr expr)
	|#(SETSUBSETEQ expr expr)
	|#(SETSUBSETNEQ expr expr)
	|#(SETNOTSUBSETEQ expr expr)
	|#(SETSUPSET expr expr)
	|#(SETSUPSETEQ expr expr)
	|#(SETSUPSETNEQ expr expr)
	|#(SETNOTSUPSETEQ expr expr)
	|#(SETIN expr expr)
	|#(SETNI expr expr)
	|#(SET expr (expr)?)
	|#(SETMINUS expr expr)
	|#(SETMULT expr expr)
	|#(SETUNION expr expr)
	|#(SETINTERSECT expr expr)
	|#(ASSIGN expr expr)
	|#(NOT expr)
	|#(AND expr expr)
	|#(OR expr expr)
	|#(IMPLY expr expr)
	|#(RIMPLY expr expr)
	|#(IFF expr expr)
	|#(FORALL expr expr)
	|#(EXISTS expr expr)
	|#(LIM expr expr expr (expr)?)
	|#(LIMSUP expr (expr)?)
	|#(LIMINF expr (expr)?)
	|#(SUP expr (expr)?)
	|#(INF expr (expr)?)
	|#(MAX expr (expr)?)
	|#(MIN expr (expr)?)
	|#(ARGMAX expr expr)
	|#(ARGMIN expr expr)
	| LEFT
	| RIGHT
	| REAL
	| COMPLEX
	| v:VARIABLE {if (changes.find(#v->getText())!=changes.end()) #v->setText(changes[#v->getText()]);}
	| n:NUMBER
	| p:PARAMETER {if (changes.find(#p->getText())!=changes.end()) #p->setText(changes[#p->getText()]);}
	| DOTS
	| FC_TRUE
	| FC_FALSE
	| ALPHA
	| BETA
	| GAMMA
	| GAMMAG
	| DELTA
	| DELTAG
	| EPSILON
	| ZETA
	| ETA
	| THETA
	| THETAG
	| IOTA
	| KAPPA
	| LAMBDA
	| LAMBDAG
	| MU
	| NU
	| XI
	| XIG
	| OMICRON
	| PI
	| PIG
	| RHO
	| SIGMA
	| SIGMAG
	| TAU
	| UPSILON
	| UPSILONG
	| PHI
	| PHIG
	| CHI
	| PSI
	| PSIG
	| OMEGA
	| OMEGAG
	| UNKNOWN
	| NONE
	| INFTY
	| E
	| I
	| NATURALNUMBERS
	| PRIMES
	| INTEGERS
	| RATIONALS
	| REALS
	| COMPLEXES
	|#(ENUMERATION (expr)*)
	|#(VECTOR (expr)*)
	|#(MATRIX (expr)*)
	|#(MATRIXROW (expr)*)
	|#(PAIR expr expr)
	|#(LPAREN expr)
	|#(LBRACKET expr)
	|#(GCD (expr (expr)?)?)
	|#(LCM (expr (expr)?)?)
	|#(FUNCTION expr expr)
	|#(TYPEDEF expr)
	|#(DECLARE expr (expr)?)
	|#(LAMBDACONSTRUCT expr expr)
	//Functions
	| #(SIZEOF (expr)?)
	| #(ABS (expr)?)
	| SGN
	| SIN
	| COS
	| TAN
	| SEC
	| COSEC
	| COT
	| SINH
	| COSH
	| TANH
	| SECH
	| COSECH
	| COTH
	| ARCSIN
	| ARCCOS
	| ARCTAN
	| ARCSEC
	| ARCCOSEC
	| ARCCOT
	| ARCSINH
	| ARCCOSH
	| ARCTANH
	| ARCSECH
	| ARCCOSECH
	| ARCCOTH
	| ERF
	| IM
	| RE
	| ARG
	| #(CONJUGATE (expr)?)
	| #(TRANSPONATE (expr)?)
	| #(COMPLEMENTER (expr)?)
	| #(EXP (expr)?)
	| #(LN (expr)?)
	| #(LOG (expr (expr)?)?)
	| #(LG (expr)?)
	| #(SQRT (expr)?)
	| #(ROOT expr (expr)?)
	| #(CEIL (expr)?)
	| #(FLOOR (expr)?)
	;
