header {
#include <string>
#include <h/fcAST.h>
using namespace std;
}

options {
        language=Cpp;
}

/**
 * This file creates a string from an Intuitive type AST (less errors, if it is after content transformations).
 * Generation depends on the following files:
 * IntuitiveTokenTypes.txt
 * Compilation depends on the following files:
 * h/fcAST.h
 * From this file the following files will be created:
 * JavaOutput.cpp, JavaOutput.hpp, JavaOutputTokenTypes.hpp, JavaOutputTokenTypes.txt
 * @author Gabor Bakos (baga@users.sourceforge.net)
 */

class JavaOutput extends TreeParser;
options {
	importVocab=Intuitive;
	ASTLabelType = "RefFcAST";
	defaultErrorHandler=false;
}

inp returns [string s] {string a;}:
	(a=expr {s=a;})
	|
	;

expr returns [string s]
	{
		string a,b,c,d;
	}
	:
	 #(PLUS a=expr b=expr {s="Math.plus("+a+","+b+")";})
	|#(MINUS a=expr b=expr {s="Math.minus("+a+","+b+")";})
	|#(NEG a=expr {s="Math.neg("+a+")";})
	|#(MULT a=expr b=expr {s="Math.mult("+a+","+b+")";})
	|#(DIV a=expr b=expr {s="Math.div("+a+","+b+")";})
	|#(MATRIXPRODUCT a=expr b=expr {s="Math.prod("+a+","+b+")";})
	|#(MOD a=expr b=expr {s="("+a+"%"+b+")";})
	|#(MODP a=expr b=expr c=expr {s="("+a+"%"+c+"=="+b+"%"+c+")";})
	|#(EQUIV a=expr b=expr {throw std::exception();})
	|#(FACTOROF a=expr b=expr {s="("+b+"%"+a+"==0)";})
	|#(CIRCUM a=expr b=expr {s="Math.pow("+a+","+b+")";})
	|#(FACTORIAL a=expr {s="Math.factorial("+a+")";})
	|#(DFACTORIAL a=expr {s="Math.dfactorial("+a+")";})
	|#(UNDERSCORE a=expr b=expr {s=""+a+"["+b+"]";})
	|#(PM a=expr b=expr {throw std::exception();})
	|#(MP a=expr b=expr {throw std::exception();})
	|#(DERIVE a=expr b=expr {throw std::exception();})
	|#(DEFINTEGRAL a=expr b=expr {throw std::exception();})
	|#(INDEFINTEGRAL a=expr b=expr {throw std::exception();})
	|#(SUM a=expr b=expr c=expr d=expr {throw std::exception();})
	|#(PROD a=expr b=expr c=expr d=expr {throw std::exception();})
	|#(EQUAL a=expr b=expr {s=""+a+".equals("+b+")";})
	|#(NEQ a=expr b=expr {s="(!("+a+".equals("+b+")))";})
	|#(LESS a=expr b=expr {s=""+a+".less("+b+")";})
	|#(LEQ a=expr b=expr {s=""+a+".leq("+b+")";})
	|#(NOTLESS a=expr b=expr {s="(!("+a+".less("+b+")))";})
	|#(NOTLEQ a=expr b=expr {s="(!("+a+".leq("+b+")))";})
	|#(GREATER a=expr b=expr {s=""+a+".greater("+b+")";})
	|#(GEQ a=expr b=expr {s=""+a+".geq("+b+")";})
	|#(NOTGREATER a=expr b=expr {s="(!("+a+".greater("+b+")))";})
	|#(NOTGEQ a=expr b=expr {s="(!("+a+".geq("+b+")))";})
	|#(SETSUBSET a=expr b=expr {throw std::exception();})
	|#(SETSUBSETEQ a=expr b=expr {throw std::exception();})
	|#(SETNOTSUBSETEQ a=expr b=expr {throw std::exception();})
	|#(SETSUPSET a=expr b=expr {throw std::exception();})
	|#(SETSUPSETEQ a=expr b=expr {throw std::exception();})
	|#(SETNOTSUPSETEQ a=expr b=expr {throw std::exception();})
	|#(SETIN a=expr b=expr {throw std::exception();})
	|#(SETNI a=expr b=expr {throw std::exception();})
	|#(SET a=expr b=expr {throw std::exception();})
	|#(SETMINUS a=expr b=expr {throw std::exception();})
	|#(SETMULT a=expr b=expr {throw std::exception();})
	|#(SETUNION a=expr b=expr {throw std::exception();})
	|#(SETINTERSECT a=expr b=expr {throw std::exception();})
	|#(ASSIGN a=expr b=expr {s=""+a+"="+b+"";})
	|#(NOT a=expr {s="!("+a+")";})
	|#(AND a=expr b=expr {s="("+a+"&&"+b+")";})
	|#(OR a=expr b=expr {s="("+a+"&&"+b+")";})
	|#(IMPLY a=expr b=expr {s="(!("+a+")||"+b+")";})
	|#(IFF a=expr b=expr {s="((!("+a+")||"+b+") && ("+a+"|| !("+b+")))";})
	|#(FORALL a=expr b=expr {throw std::exception();})
	|#(EXISTS a=expr b=expr {throw std::exception();})
	|#(LIM a=expr b=expr c=expr (d=expr)? {throw std::exception();})
	|#(LIMSUP a=expr (b=expr)? {throw std::exception();})
	|#(LIMINF a=expr (b=expr)? {throw std::exception();})
	|#(SUP a=expr (b=expr)? {throw std::exception();})
	|#(INF a=expr (b=expr)? {throw std::exception();})
	|#(MAX a=expr (b=expr)? {throw std::exception();})
	|#(MIN a=expr (b=expr)? {throw std::exception();})
	|#(ARGMAX a=expr (b=expr)? {throw std::exception();})
	|#(ARGMIN a=expr (b=expr)? {throw std::exception();})
	| LEFT {throw std::exception();}
	| RIGHT {throw std::exception();}
	| REAL {throw std::exception();}
	| COMPLEX {throw std::exception();}
	| v:VARIABLE {s=v->getText();}
	| n:NUMBER {s=n->getText();}
	| p:PARAMETER {s=p->getText();}
	| DOTS {throw std::exception();}
	| FC_TRUE {s=std::string("true");}
	| FC_FALSE {s=std::string("false");}
	| PI {s=std::string("Math.PI");}
	| UNKNOWN {throw std::exception();}
	| NONE {throw std::exception();}
	| INFTY {s=std::string("1e300");}
	| E {s=std::string("Math.E");}
	| I {s=std::string("new Complex(0, 1)");}
	| NATURALNUMBERS {throw std::exception();}
	| PRIMES {throw std::exception();}
	| INTEGERS {throw std::exception();}
	| RATIONALS {throw std::exception();}
	| REALS {throw std::exception();}
	| COMPLEXES {throw std::exception();}
	|#(ENUMERATION {s=std::string("???");} (a=expr {s+=a; s+=",";})*  {throw std::exception();})
	|#(PAIR a=expr b=expr {throw std::exception();})
	|#(LBRACKET a=expr {s="::["+a+"]::"; throw std::exception();})
	|#(VECTOR a=expr {s="::["+a+"]::"; throw std::exception();})
	|#(MATRIX a=expr {s="::["+a+"]::"; throw std::exception();})
	|#(MATRIXROW a=expr {s="::["+a+"]::"; throw std::exception();})
	|#(FUNCTION a=expr b=expr {if (a.find('(')==std::string::npos) s=""+a+"("+b+")"; else s=""+a+""+b+"))";})
	//Functions
	|#(ABS {s="(Math.abs(";})
	//Functions
	| SIZEOF {s="(sizeof("; throw std::exception();}
	| SGN {s="(Math.sgn(";}
	| SIN {s="(Math.sin(";}
	| COS {s="(Math.cos(";}
	| TAN {s="(Math.tan(";}
	| SEC {s="(1e0/Math.cos(";}
	| COSEC {s="(1e0/Math.sin(";}
	| COT {s="(1e0/Math.tan(";}
	| SINH {s="(Math.sinh(";}
	| COSH {s="(Math.cosh(";}
	| TANH {s="(Math.tanh(";}
	| SECH {s="(1e0/Math.cosh(";}
	| COSECH {s="(1e0/Math.sinh(";}
	| COTH {s="(1e0/Math.tanh(";}
	| ARCSIN {s="(Math.arcsin(";}
	| ARCCOS {s="(Math.arccos(";}
	| ARCTAN {s="(Math.arctan(";}
	| ARCSEC {s="(Math.arccos(1e0/";}
	| ARCCOSEC {s="(Math.arsin(1e0/";}
	| ARCCOT {s="(Math.arctan(1e0/";}
	| ARCSINH {s="(Math.arcsinh(";}
	| ARCCOSH {s="(Math.arccosh(";}
	| ARCTANH {s="(Math.arctanh(";}
	| ARCSECH {s="(Math.arccosh(1e0/";}
	| ARCCOSECH {s="(Math.arcsinh(1e0/";}
	| ARCCOTH {s="(Math.arctanh(1e0/";}
	| ERF {throw std::exception();}
	| IM {s="(Math.imag(";}
	| RE {s="(Math.real(";}
	| GCD {s="Math.gcd(";} //Don't work because it would use an enumeration as the argument.
	| LCM {s="Math.lcm(";} //Don't work because it would use an enumeration as the argument.
	| ARG {s="(Math.arg(";}
	| CONJUGATE {s="(Math.conj(";}
	| TRANSPONATE {s="(Math.transponate("; throw std::exception();}
	| COMPLEMENTER {s="(Math.complementer("; throw std::exception();}
	| EXP {s="(Math.exp(";}
	| #(LOG {s="(Math.log(";} (a=expr {s="((1e0/Math.log("+a+"))*Math.log(";})?)
	| SQRT {s="(Math.sqrt(";}
	| #(ROOT a=expr {s="Math.exp((1e0/"+a+")*log(";})
	| CEIL {s="(Math.ceil(";}
	| FLOOR {s="(Math.floor(";}
        ;

