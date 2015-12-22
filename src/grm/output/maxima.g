header {
#include <string>
#include <exception>
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
 * MaximaOutput.cpp, MaximaOutput.hpp, MaximaOutputTokenTypes.hpp, MaximaOutputTokenTypes.txt
 * @author Gabor Bakos (baga@users.sourceforge.net)
 */

class MaximaOutput extends TreeParser;
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
	 #(PLUS a=expr b=expr {s="("+a+"+"+b+")";})
	|#(MINUS a=expr b=expr {s="("+a+"-"+b+")";})
	|#(NEG a=expr {s="(-("+a+"))";})
	|#(MULT a=expr b=expr {s="("+a+"*"+b+")";})
	|#(DIV a=expr b=expr {s="("+a+"/"+b+")";})
	|#(MATRIXPRODUCT a=expr b=expr {s="("+a+"."+b+")";})
	|#(MATRIXEXPONENTIATION a=expr b=expr {s="("+a+"^^"+b+")";})
	|#(MOD a=expr b=expr {s="mod("+a+","+b+")";})
	|#(MODP a=expr b=expr c=expr {s="equals(mod("+a+","+c+"), mod("+b+","+c+"))";})
	|#(EQUIV a=expr b=expr {throw std::exception();})
	|#(FACTOROF a=expr b=expr {s="equals(mod("+b+","+a+"), 0)";})
	|#(CIRCUM a=expr b=expr {s="("+a+"^"+b+")";})
	|#(FACTORIAL a=expr {s=""+a+"!";})
	|#(DFACTORIAL a=expr {s=""+a+"!!";})
	|#(UNDERSCORE a=expr b=expr {s=""+a+"{"+b+"}";})
	|#(PM a=expr b=expr {throw std::exception();})
	|#(MP a=expr b=expr {throw std::exception();})
	|#(DERIVE a=expr b=expr{s="diff("+a+", "+b+")";})
	|#(DEFINTEGRAL a=expr b=expr c=expr d=expr {s="defint("+a+", "+b+", "+c+", "+d+")";})
	|#(INDEFINTEGRAL a=expr b=expr {s="integrate("+a+", "+b+")";})
	|#(SUM a=expr b=expr c=expr d=expr {s="sum("+d+","+a+","+b+","+c+")";})
	|#(PROD a=expr b=expr c=expr d=expr {s="product("+d+","+a+","+b+","+c+")";})
	|#(EQUAL a=expr b=expr {s=""+a+"="+b;})
	|#(NEQ a=expr b=expr {s="notequal("+a+", "+b+")";})
	|#(LESS a=expr b=expr {s="("+a+"<"+b+")";})
	|#(LEQ a=expr b=expr {s="("+a+"<="+b+")";})
	|#(GREATER a=expr b=expr {s="("+a+">"+b+")";})
	|#(GEQ a=expr b=expr {s="("+a+">="+b+")";})
	|#(SETSUBSET a=expr b=expr {s="subsetp("+a+","+b+")";})//TODO: One of them is wrong...
	|#(SETSUBSETEQ a=expr b=expr {s="subsetp["+a+""+b+"]";})//TODO: One of them is wrong...
	|#(SETIN a=expr b=expr {throw std::exception();})
	|#(SET {} (a=expr {} (b=expr {})?)? {throw std::exception();})
	|#(SETMINUS a=expr b=expr {s="setdifference("+a+","+b+")";})
	|#(SETMULT a=expr b=expr {s="("+a+"*"+b+")"; throw std::exception();})
	|#(SETUNION a=expr b=expr {s="union("+a+","+b+")";})
	|#(SETINTERSECT a=expr b=expr {s="intersect("+a+","+b+")";})
	|#(ASSIGN a=expr b=expr {s=""+a+"="+b+"";})
	|#(NOT a=expr {s="(not "+a+")";})
	|#(AND a=expr b=expr {s="("+a+" and "+b+")";})
	|#(OR a=expr b=expr {s="("+a+" or "+b+")";})
	|#(IMPLY a=expr b=expr {s="(not ("+a+") or "+b+")";})
	|#(IFF a=expr b=expr {s="((not ("+a+") or "+b+") and (not ("+b+") or "+a+"))";})
	|#(FORALL a=expr b=expr {throw std::exception();})
	|#(EXISTS a=expr b=expr {throw std::exception();})
	|#(LIM a=expr b=expr c=expr (d=expr)? {s="limit("+c+", "+a+", "+b+d+")";})
	|#(LIMSUP a=expr (b=expr)? {throw std::exception();})
	|#(LIMINF a=expr (b=expr)? {throw std::exception();})
	|#(SUP a=expr (b=expr)? {throw std::exception();})
	|#(INF a=expr (b=expr)? {throw std::exception();})
	|#(MAX a=expr (b=expr)? {throw std::exception();})
	|#(MIN a=expr (b=expr)? {throw std::exception();})
	|#(ARGMAX a=expr b=expr {throw std::exception();})
	|#(ARGMIN a=expr b=expr {throw std::exception();})
	| LEFT {s=std::string(", plus");}
	| RIGHT {s=std::string(", minus");}
	| REAL {throw std::exception();}
	| COMPLEX {throw std::exception();}
	| v:VARIABLE {s=""+v->getText()+"";}
	| n:NUMBER {s=""+n->getText()+"";}
	| p:PARAMETER {s=""+p->getText()+"";}
	| DOTS {throw std::exception();}
	| FC_TRUE {s="true";}
	| FC_FALSE {s=std::string("false");}
	| PI {s=std::string("%pi");}
	| UNKNOWN {throw std::exception();}
	| NONE {s=std::string("");}
	| INFTY {s=std::string("inf");}
	| E {s=std::string("%e");}
	| I {s=std::string("%i");}
	| NATURALNUMBERS {throw std::exception();}
	| PRIMES {throw std::exception();}
	| INTEGERS {throw std::exception();}
	| RATIONALS {throw std::exception();}
	| REALS {throw std::exception();}
	| COMPLEXES {throw std::exception();}
//	|#(ENUMERATION {s=std::string("");} (a=expr {s+=a; s+=", ";})* {if (s!="") s.erase(s.length()-2);})
        |#(ENUMERATION {s=std::string("");} (a=expr {if (s!="") s+=", "; s+=a;})* )
	|#(PAIR a=expr b=expr {throw std::exception();})
	|#(LBRACKET a=expr {s="{"+a+"}";})//I think this is unnecessary...
	|#(VECTOR a=expr {s="["+a+"]";})
	|#(MATRIX a=expr {s="matrix("+a+")";})
	|#(MATRIXROW a=expr {s="["+a+"]";})
	|(#(FUNCTION #(LOG expr) expr))=>(#(FUNCTION #(LOG a=expr) b=expr {s="log("+b+")/log("+a+")";}))
	|(#(FUNCTION #(ROOT expr) expr))=>(#(FUNCTION #(ROOT a=expr) b=expr {s=""+b+"^(1.0/"+a+")";}))
	|#(FUNCTION a=expr b=expr {s=""+a+"("+b+")";})
	//Functions
	| SIZEOF {s=""; throw std::exception();}
	| ABS {s="abs";}
	| SGN {s="signum";}
	| SIN {s="sin";}
	| COS {s="cos";}
	| TAN {s="tan";}
	| SEC {s="sec";}
	| COSEC {s="csc";}
	| COT {s="cot";}
	| SINH {s="sinh";}
	| COSH {s="cosh";}
	| TANH {s="tanh";}
	| SECH {s="sech";}
	| COSECH {s="csch";}
	| COTH {s="coth";}
	| ARCSIN {s="asin";}
	| ARCCOS {s="acos";}
	| ARCTAN {s="atan";}
	| ARCSEC {s="asec";}
	| ARCCOSEC {s="acsc";}
	| ARCCOT {s="acot";}
	| ARCSINH {s="asinh";}
	| ARCCOSH {s="acosh";}
	| ARCTANH {s="atanh";}
	| ARCSECH {s="asech";}
	| ARCCOSECH {s="acsch";}
	| ARCCOTH {s="acoth";}
	| ERF {s="erf";}
	| IM {s="imagpart";}
	| RE {s="realpart";}
	| ARG {s="arg";}
	| GCD {s="gcd";}
	| LCM {s="lcm";}
	| CONJUGATE {s="conjugate";}
	| TRANSPONATE {s="transpose";}
	| COMPLEMENTER {s="complement";}
	| EXP {s="exp";}
	| LOG {s="log";}
	| SQRT {s="sqrt";}
	| CEIL {s="ceiling";}
	| FLOOR {s="floor";}
        ;
