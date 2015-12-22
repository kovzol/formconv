header {
#include <string>
#include <iostream>
#include <cstdlib>
#include <antlr/ASTFactory.hpp>
#include <h/fccomplexAST.h>
using namespace std;
}

options {
        language=Cpp;
}

/**
 * This file creates an AST. The input must be in complexcompute AST format. The output has precomputed nodes.
 * Generation depends on the following files:
 * IntuitiveTokenTypes.txt
 * Compilation depends on the following files:
 * h/fccomplexAST.h
 * From this file the following files will be created:
 * ComplexComputeBoost.cpp, ComplexComputeBoost.hpp, ComplexComputeBoostTokenTypes.hpp, ComplexComputeBoostTokenTypes.txt
 * @author Gabor Bakos (baga@users.sourceforge.net)
 */

class ComplexComputeBoost extends TreeParser;
options {
	importVocab=Intuitive;
	buildAST=true;
	ASTLabelType="RefFcComplexAST"; //TODO take it a bit more templateish...
	defaultErrorHandler=false;
}

{
	RefFcComplexAST dup(const RefFcComplexAST v) const
	{
		return RefFcComplexAST(getASTFactory()->dup((antlr::RefAST)v));
	}
}

inp	:	(expr)
	|
	;

expr	: 
	 !#(PLUS plus0:expr plus1:expr {if (#plus0->getType()==NUMBER && #plus1->getType()==NUMBER) {#expr=#(#[NUMBER]); #expr->value=#plus0->value+#plus1->value;} else #expr=#(#PLUS, #plus0, #plus1);})
	| #(MINUS minus0:expr minus1:expr)
	| #(NEG neg0:expr)
	| #(MULT mult0:expr mult1:expr)
	| #(DIV div0:expr div1:expr)
	| #(MATRIXPRODUCT expr expr {throw std::exception();})
	| #(MOD expr expr {throw std::exception();})
	| #(MODP expr expr expr {throw std::exception();})
	| #(EQUIV expr expr {throw std::exception();})
	| #(FACTOROF expr expr {throw std::exception();})
	| #(CIRCUM pow0:expr pow1:expr)
	| #(FACTORIAL expr {throw std::exception();})
	| #(DFACTORIAL expr {throw std::exception();})
	| #(UNDERSCORE expr expr {throw std::exception();})
	| #(PM expr expr {throw std::exception();})
	| #(MP expr expr {throw std::exception();})
	| #(DERIVE expr expr {throw std::exception();})
	| #(NTHDERIVE expr expr expr {throw std::exception();})
	| #(NTHDERIVEX expr expr {throw std::exception();})
	| #(FUNCINVERSE expr {throw std::exception();})
//	| #(FUNCMULT expr expr)
//	| #(FUNCPLUS expr exrp)
	| #(DEFINTEGRAL expr expr expr expr {throw std::exception();})
	| #(INDEFINTEGRAL expr expr {throw std::exception();})
	| #(SUM expr expr expr expr {throw std::exception();})//??
	| #(PROD expr expr expr expr {throw std::exception();})//??
	| #(EQUAL expr expr {throw std::exception();})
	| #(NEQ expr expr {throw std::exception();})
	| #(LESS expr expr {throw std::exception();})
	| #(LEQ expr expr {throw std::exception();})
	| #(NOTLESS expr expr {throw std::exception();})
	| #(LESSNOTEQ expr expr {throw std::exception();})
	| #(NOTLEQ expr expr {throw std::exception();})
	| #(GREATER expr expr {throw std::exception();})
	| #(GEQ expr expr {throw std::exception();})
	| #(NOTGREATER expr expr {throw std::exception();})
	| #(GREATERNOTEQ expr expr {throw std::exception();})
	| #(NOTGEQ expr expr {throw std::exception();})
//	| #(SETPOW expr expr)
//	| #(SETGENERATED expr)
	| #(SETSUBSET expr expr {throw std::exception();})
	| #(SETSUBSETEQ expr expr {throw std::exception();})
//	| #(SETSUBSETNEQ expr expr)
//	|#(SETNOTSUBSETEQ expr expr)
	| #(SETSUPSET expr expr {throw std::exception();})
	| #(SETSUPSETEQ expr expr {throw std::exception();})
	| #(SETSUPSETNEQ expr expr {throw std::exception();})
	| #(SETNOTSUPSETEQ expr expr {throw std::exception();})
	| #(SETIN expr expr {throw std::exception();})
//	| #(SETNI expr expr)
	| #(SET expr (expr)? {throw std::exception();})
	| #(SETMINUS expr expr {throw std::exception();})
	| #(SETMULT expr expr {throw std::exception();})
	| #(SETUNION expr expr {throw std::exception();})
	| #(SETINTERSECT expr expr {throw std::exception();})
	| #(ASSIGN expr expr {throw std::exception();})
	| #(NOT expr {throw std::exception();})
	| #(AND expr expr {throw std::exception();})
	| #(OR expr expr {throw std::exception();})
//	| #(NAND expr expr)
//	| #(NOR expr expr)
	| #(IMPLY expr expr {throw std::exception();})
//	| #(RIMPLY expr expr)
//	| #(IFF expr expr)
	| #(FORALL expr expr {throw std::exception();})
	| #(EXISTS expr expr {throw std::exception();})
	| #(LIM expr expr expr (expr)? {throw std::exception();})
	| #(LIMSUP expr (expr)? {throw std::exception();})
	| #(LIMINF expr (expr)? {throw std::exception();})
	| #(SUP expr (expr)? {throw std::exception();})
	| #(INF expr (expr)? {throw std::exception();})
	| #(MAX expr (expr)? {throw std::exception();})
	| #(MIN expr (expr)? {throw std::exception();})
	| #(ARGMAX expr (expr)? {throw std::exception();})
	| #(ARGMIN expr (expr)? {throw std::exception();})
	| LEFT {throw std::exception();}
	| RIGHT {throw std::exception();}
	| REAL {throw std::exception();}
	| COMPLEX {throw std::exception();}
	| VARIABLE {if (#VARIABLE->getText()=="z") #VARIABLE->setType(PARAMETER);}
	| NUMBER {#NUMBER->value=std::complex<double>(atof((#NUMBER->getText()).c_str()), 0.0);}
	| PARAMETER {#PARAMETER->setType(VARIABLE);}
	| DOTS {throw std::exception();}
	| FC_TRUE {throw std::exception();}
	| FC_FALSE {throw std::exception();}
/*	|!ALPHA {#expr=#[PARAMETER, "alpha"];}
	|!BETA {#expr=#[PARAMETER, "beta"];}
	|!GAMMA {#expr=#[PARAMETER, "gamma"];}
	|!GAMMAG {#expr=#[PARAMETER, "Gamma"];}
	|!DELTA {#expr=#[PARAMETER, "delta"];}
	|!DELTAG {#expr=#[PARAMETER, "Delta"];}
	|!EPSILON {#expr=#[PARAMETER, "epsilon"];}
	|!ZETA {#expr=#[PARAMETER, "zeta"];}
	|!ETA {#expr=#[PARAMETER, "eta"];}
	|!THETA {#expr=#[PARAMETER, "theta"];}
	|!THETAG {#expr=#[PARAMETER, "Theta"];}
	|!IOTA {#expr=#[PARAMETER, "iota"];}
	|!KAPPA {#expr=#[PARAMETER, "kappa"];}
	|!LAMBDA {#expr=#[PARAMETER, "lambda"];}
	|!LAMBDAG {#expr=#[PARAMETER, "Lambda"];}
	|!MU {#expr=#[PARAMETER, "mu"];}
	|!NU {#expr=#[PARAMETER, "nu"];}
	|!XI {#expr=#[PARAMETER, "xi"];}
	|!XIG {#expr=#[PARAMETER, "Xi"];}
	|!OMICRON {#expr=#[PARAMETER, "omicron"];}
	| PI {$setType(NUMBER); #PI->value=std::complex(M_PI, 0.0);}
	|!PIG {#expr=#[PARAMETER, "Pi"];}
	|!RHO {#expr=#[PARAMETER, "rho"];}
	|!SIGMA {#expr=#[PARAMETER, "sigma"];}
	|!SIGMAG {#expr=#[PARAMETER, "Sigma"];}
	|!TAU {#expr=#[PARAMETER, "tau"];}
	|!UPSILON {#expr=#[PARAMETER, "upsilon"];}
	|!UPSILONG {#expr=#[PARAMETER, "Upsilon"];}
	|!PHI {#expr=#[PARAMETER, "phi"];}
	|!PHIG {#expr=#[PARAMETER, "Phi"];}
	|!CHI {#expr=#[PARAMETER, "chi"];}
	|!PSI {#expr=#[PARAMETER, "psi"];}
	|!PSIG {#expr=#[PARAMETER, "Psi"];}
	|!OMEGA {#expr=#[PARAMETER, "omega"];}
	|!OMEGAG {#expr=#[PARAMETER, "Omega"];}*/
	| UNKNOWN {throw std::exception();}
	| NONE {throw std::exception();}
	| INFTY {#INFTY->setType(NUMBER); #INFTY->value=std::complex<double>(4e300,0);}
	| E {#E->setType(NUMBER); #E->value=std::exp(1.0);}
	| I {#I->setType(NUMBER); #I->value=std::complex<double>(0, 1.0);}
	| NATURALNUMBERS {throw std::exception();}
	| PRIMES {throw std::exception();}
	| INTEGERS {throw std::exception();}
	| RATIONALS {throw std::exception();}
	| REALS {throw std::exception();}
	| COMPLEXES {throw std::exception();}
	| #(ENUMERATION (expr)* {throw std::exception();})
	| #(PAIR expr expr {throw std::exception();})
	|!#(LPAREN lparen:expr {#expr=#lparen;})
	| #(LBRACKET expr {throw std::exception();})//??
	| #(VECTOR expr {throw std::exception();})//??
	| #(MATRIX expr {throw std::exception();})//??
	| #(MATRIXROW expr {throw std::exception();})//??
	| #(GCD (expr (expr)?)? {throw std::exception();})
	| #(LCM (expr (expr)?)? {throw std::exception();})
	|!(#(FUNCTION #(LOG NUMBER) expr))=>#(FUNCTION #(LOG logn:NUMBER) log0:expr {#expr=#[NUMBER, "generated"]; #expr->value=log(atof(#logn->getText().c_str())); #expr=#(#[DIV, "/"], #(#LOG, #log0), #expr);})
	|!(#(FUNCTION #(LOG expr) expr))=>#(FUNCTION #(LOG logn0:expr) log1:expr {#expr=#(#[DIV, "/"], #(#LOG, #log1), #(dup(#LOG), #logn0));})
	|!(#(FUNCTION #(ROOT expr) expr))=>#(FUNCTION #(ROOT rootnth:expr) rootarg:expr {#expr=#[NUMBER, "1"]; #expr->value=1.0; #expr=#(#[CIRCUM, "pow"], #rootarg, #(#[DIV, "/"], #expr, #rootnth));})
	|!#(FUNCTION f0:expr f1:expr {#expr=#(#f0, #f1);})
	| #(TYPEDEF expr {throw std::exception();})
	| #(DECLARE expr expr {throw std::exception();})
	| #(LAMBDACONSTRUCT expr expr {throw std::exception();})
	| SIZEOF {throw std::exception();}
	| ABS
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
	| ARCSIN {throw std::exception();} //??
	| ARCCOS {throw std::exception();} //??
	| ARCTAN {throw std::exception();} //??
	| ARCSEC {throw std::exception();} //??
	| ARCCOSEC {throw std::exception();} //??
	| ARCCOT {throw std::exception();} //??
	| ARCSINH {throw std::exception();} //??
	| ARCCOSH {throw std::exception();} //??
	| ARCTANH {throw std::exception();} //??
	| ARCSECH {throw std::exception();} //??
	| ARCCOSECH {throw std::exception();} //??
	| ARCCOTH {throw std::exception();} //??
	| ERF {throw std::exception();}
	| IM
	| RE
	| ARG
	| CONJUGATE
	| TRANSPONATE {throw std::exception();}
	| COMPLEMENTER {throw std::exception();}
	| EXP
	| LN {#LN->setType(LOG);}
	| LOG
	| SQRT
//	| #(ROOT expr)
	| CEIL {throw std::exception();}
	| FLOOR {throw std::exception();}
        ;

