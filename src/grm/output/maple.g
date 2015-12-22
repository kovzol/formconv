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
 * MapleOutput.cpp, MapleOutput.hpp, MapleOutputTokenTypes.hpp, MaplesOutputTokenTypes.txt
 * @author Gabor Bakos (baga@users.sourceforge.net)
 */

class MapleOutput extends TreeParser;
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
	|#(MATRIXPRODUCT a=expr b=expr {s="multiply("+a+", "+b+")";})
	|#(MOD a=expr b=expr {s="("+a+" mod "+b+")";})
	|#(MODP a=expr b=expr c=expr {s="("+a+" mod "+c+"="+b+" mod "+c+")";})
	|#(EQUIV a=expr b=expr {throw std::exception();})
	|#(FACTOROF a=expr b=expr {s="("+b+" mod "+a+"=0)";})
	|#(CIRCUM a=expr b=expr {s="("+a+"^"+b+")";})
	|#(FACTORIAL a=expr {s="("+a+")!";})
	|#(DFACTORIAL a=expr {throw std::exception();})
	|#(UNDERSCORE a=expr b=expr {s=""+a+"["+b+"]";})
	|#(PM a=expr b=expr {throw std::exception();})
	|#(MP a=expr b=expr {throw std::exception();})
	|#(DERIVE a=expr b=expr{s="diff("+a+", "+b+")";})
	|#(DEFINTEGRAL a=expr b=expr c=expr d=expr {s="int("+a+", "+b+"="+c+".."+d+")";})
	|#(INDEFINTEGRAL a=expr b=expr {s="int("+a+", "+b+")";})
	|#(SUM a=expr b=expr c=expr d=expr {s="sum('"+d+"', '"+a+"'= "+b+".."+c+")";})
	|#(PROD a=expr b=expr c=expr d=expr {s="prod('"+d+"', '"+a+"'="+b+".."+c+")";})
	|#(EQUAL a=expr b=expr {s="("+a+"="+b+")";})
	|#(NEQ a=expr b=expr {s="("+a+"<>"+b+")";})
	|#(LESS a=expr b=expr {s="("+a+"<"+b+")";})
	|#(LEQ a=expr b=expr {s="("+a+"<="+b+")";})
	|#(GREATER a=expr b=expr {s="("+a+">"+b+")";})
	|#(GEQ a=expr b=expr {s="("+a+">="+b+")";})
	|#(SETSUBSET a=expr b=expr {throw std::exception();})
	|#(SETSUBSETEQ a=expr b=expr {throw std::exception();})
	|#(SETIN a=expr b=expr {s="member("+a+","+b+")";})
	|#(SET {} (a=expr {} (b=expr {})?)? {throw std::exception();})
	|#(SETMINUS a=expr b=expr {s="("+a+" minus "+b+")";})
	|#(SETMULT a=expr b=expr {s="("+a+"*"+b+")"; throw std::exception();})
	|#(SETUNION a=expr b=expr {s="("+a+" union "+b+")";})
	|#(SETINTERSECT a=expr b=expr {s="("+a+" intersect "+b+")";})
	|#(ASSIGN a=expr b=expr {s=""+a+"="+b+"";})
	|#(NOT a=expr {s="(not "+a+")";})
	|#(AND a=expr b=expr {s="("+a+" and "+b+")";})
	|#(OR a=expr b=expr {s="("+a+" or "+b+")";})
	|#(IMPLY a=expr b=expr {s="((not "+a+") or "+b+")";})
	|#(IFF a=expr b=expr {s="(((not "+a+") or "+b+") or ((not "+b+") or "+a+"))";})
	|#(FORALL a=expr b=expr {throw std::exception();})
	|#(EXISTS a=expr b=expr {throw std::exception();})
	|#(LIM a=expr b=expr c=expr (d=expr)? {s="limit("+c+", "+a+"="+b+d+")";})
	|#(LIMSUP a=expr (b=expr)? {throw std::exception();})
	|#(LIMINF a=expr (b=expr)? {throw std::exception();})
	|#(SUP a=expr (b=expr)? {throw std::exception();})
	|#(INF a=expr (b=expr)? {throw std::exception();})
	|#(MAX a=expr (b=expr)? {throw std::exception();})
	|#(MIN a=expr (b=expr)? {throw std::exception();})
	|#(ARGMAX a=expr b=expr {throw std::exception();})
	|#(ARGMIN a=expr b=expr {throw std::exception();})
	| LEFT {s=std::string(", left");}
	| RIGHT {s=std::string(", right");}
	| REAL {s=std::string(", real");}
	| COMPLEX {s=std::string(", complex");}
	| v:VARIABLE {s=""+v->getText()+"";}
	| n:NUMBER {s=""+n->getText()+"";}
	| p:PARAMETER {s=""+p->getText()+"";}
	| DOTS {throw std::exception();}
	| FC_TRUE {s="true";}
	| FC_FALSE {s=std::string("false");}
	| PI {s=std::string("Pi");}
	| UNKNOWN {throw std::exception();}
	| NONE {s=std::string("");}
	| INFTY {s=std::string("infinity");}
	| E {s=std::string("exp(1)");}
	| I {s=std::string("I");}
	| NATURALNUMBERS {throw std::exception();}
	| PRIMES {throw std::exception();}
	| INTEGERS {throw std::exception();}
	| RATIONALS {throw std::exception();}
	| REALS {throw std::exception();}
	| COMPLEXES {throw std::exception();}
	|#(ENUMERATION {s=std::string("");} (a=expr {if (s!="") s+=", "; s+=a;})* )
	|#(PAIR a=expr b=expr {throw std::exception();})
	|#(LBRACKET a=expr {s="["+a+"]";})
	|#(VECTOR a=expr {s="["+a+"]";})
	|#(MATRIX a=expr {s="["+a+"]";})
	|#(MATRIXROW a=expr {s="["+a+"]";})
	|(#(FUNCTION #(LOG expr) expr))=>(#(FUNCTION #(LOG a=expr) b=expr {if (a!="") s="log["+a+"]("+b+")";}))
	|(#(FUNCTION #(ROOT expr) expr))=>(#(FUNCTION #(ROOT a=expr) b=expr {s=""+b+"^(1.0/"+a+")";}))
	|#(FUNCTION a=expr b=expr {s=""+a+"("+b+")";})
	//Functions
	| SIZEOF {s=""; throw std::exception();}
	| ABS {s="abs";}
	| SGN {s="sgn";}
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
	| ARCSIN {s="arcsin";}
	| ARCCOS {s="arccos";}
	| ARCTAN {s="arctan";}
	| ARCSEC {s="arcsec";}
	| ARCCOSEC {s="arccsc";}
	| ARCCOT {s="arccot";}
	| ARCSINH {s="arcsinh";}
	| ARCCOSH {s="arccosh";}
	| ARCTANH {s="arctanh";}
	| ARCSECH {s="arcsech";}
	| ARCCOSECH {s="arccsch";}
	| ARCCOTH {s="arccoth";}
	| ERF {s="erf";}
	| IM {s="Im";}
	| RE {s="Re";}
	| ARG {s="polar";}
	| GCD {s="gcd";}
	| LCM {s="lcm";}
	| CONJUGATE {s="conjugate";}
	| TRANSPONATE {s="transpose";}
	| COMPLEMENTER {throw std::exception();}
	| EXP {s="exp";}
	| #(LOG (a=expr)? {s="log";})
	| SQRT {s="sqrt";}
//	| #(ROOT a=expr {s="root["+a+"]";})
	| CEIL {s="ceil";}
	| FLOOR {s="floor";}
        ;
