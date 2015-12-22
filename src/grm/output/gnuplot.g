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
 * GnuplotOutput.cpp, GnuplotOutput.hpp, GnuplotOutputTokenTypes.hpp, GnuplotOutputTokenTypes.txt
 * @author Gabor Bakos (baga@users.sourceforge.net)
 * @version $Id: gnuplot.g,v 1.15 2012/01/16 07:47:05 kovzol Exp $
 */

class GnuplotOutput extends TreeParser;
options {
	importVocab=Intuitive;
	ASTLabelType = "RefFcAST";
	defaultErrorHandler=false;
}

{
    private:
	bool forceFloatDiv;
    public:
	void setForceFloatDivision(bool newValue)
	{
	    forceFloatDiv = newValue;
	}
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
	|#(DIV a=expr b=expr {s="("+a+(forceFloatDiv?"*1.0":"")+"/"+b+")";})
	|#(MATRIXPRODUCT a=expr b=expr {/*s="("+a+"*"+b+")";*/ throw std::exception();})
	|#(MOD a=expr b=expr {s="("+a+"%"+b+")";})
	|#(MODP a=expr b=expr c=expr {s="("+a+"%"+c+"=="+b+"%"+c+")";})
	|#(EQUIV a=expr b=expr {throw std::exception();})
	|#(FACTOROF a=expr b=expr {s="("+b+"%"+a+"==0)";})
	|#(CIRCUM a=expr b=expr {s="("+a+"**"+(b[0]=='('?"(1.0*"+b.substr(1,b.length()-1):b)+")";})
	|#(FACTORIAL a=expr {s="("+a+")!";})
	|#(DFACTORIAL a=expr {throw std::exception(); s=""+a+"";})
	|#(UNDERSCORE a=expr b=expr {s=""+a+"["+b+"]";})
	|#(PM a=expr b=expr {throw std::exception();})
	|#(MP a=expr b=expr {throw std::exception();})
	|#(DERIVE a=expr b=expr{throw std::exception();})
	|#(DEFINTEGRAL a=expr b=expr c=expr d=expr {throw std::exception();})
	|#(INDEFINTEGRAL a=expr b=expr {throw std::exception();})
	|#(SUM a=expr b=expr c=expr d=expr {throw std::exception();})
	|#(PROD a=expr b=expr c=expr d=expr {throw std::exception();})
	|#(EQUAL a=expr b=expr {s="("+a+"=="+b+")";})
	|#(NEQ a=expr b=expr {s="("+a+"!="+b+")";})
	|#(LESS a=expr b=expr {s="("+a+"<"+b+")";})
	|#(LEQ a=expr b=expr {s="("+a+"<="+b+")";})
	|#(GREATER a=expr b=expr {s="("+a+">"+b+")";})
	|#(GEQ a=expr b=expr {s="("+a+">="+b+")";})
	|#(SETSUBSET a=expr b=expr {throw std::exception();})
	|#(SETSUBSETEQ a=expr b=expr {throw std::exception();})
	|#(SETIN a=expr b=expr {throw std::exception();})
	|#(SET {} (a=expr {} (b=expr {})?)? {throw std::exception();})
	|#(SETMINUS a=expr b=expr {throw std::exception();})
	|#(SETMULT a=expr b=expr {throw std::exception();})
	|#(SETUNION a=expr b=expr {throw std::exception();})
	|#(SETINTERSECT a=expr b=expr {throw std::exception();})
	|#(ASSIGN a=expr b=expr {throw std::exception();})
	|#(NOT a=expr {s="!"+a+"";})
	|#(AND a=expr b=expr {s=""+a+"&&"+b+"";})
	|#(OR a=expr b=expr {s=""+a+"||"+b+"";})
	|#(IMPLY a=expr b=expr {s="(!("+a+")||"+b+")";})
	|#(IFF a=expr b=expr {s="((!("+a+")||"+b+")&&(!("+b+")||"+a+"))";})
	|#(FORALL a=expr b=expr {throw std::exception();})
	|#(EXISTS a=expr b=expr {throw std::exception();})
	|#(LIM a=expr b=expr c=expr (d=expr)? {throw std::exception();})
	|#(LIMSUP a=expr (b=expr)? {throw std::exception();})
	|#(LIMINF a=expr (b=expr)? {throw std::exception();})
	|#(SUP a=expr (b=expr)? {throw std::exception();})
	|#(INF a=expr (b=expr)? {throw std::exception();})
	|#(MAX a=expr (b=expr)? {throw std::exception();})
	|#(MIN a=expr (b=expr)? {throw std::exception();})
	|#(ARGMAX a=expr b=expr {throw std::exception();})
	|#(ARGMIN a=expr b=expr {throw std::exception();})
	| LEFT {throw std::exception();}
	| RIGHT {throw std::exception();}
	| REAL {throw std::exception();}
	| COMPLEX {throw std::exception();}
	| v:VARIABLE {s=""+v->getText()+"";}
	| n:NUMBER {s=""+n->getText()+"";}
	| p:PARAMETER {s=""+p->getText()+"";}
	| DOTS {throw std::exception();}
	| FC_TRUE {s="1";}
	| FC_FALSE {s=std::string("0");}
	| PI {s=std::string("pi");}
	| UNKNOWN {throw std::exception();}
	| NONE {s=std::string("");}
	| INFTY {s=std::string("1e300");}
	| E {s=std::string("exp(1)");}
	| I {s=std::string("{0,1}");}
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
	|(#(FUNCTION #(LOG expr) expr))=>(#(FUNCTION #(LOG a=expr) b=expr {s="(log("+b+")/log("+a+"))";}))
	|(#(FUNCTION #(ROOT expr) expr))=>(#(FUNCTION #(ROOT a=expr) b=expr {s=""+b+"**(1.0/"+a+")";}))
	|#(FUNCTION a=expr b=expr {s="("+a+""+b+"))";})
	//Functions
	| SIZEOF {s=""; throw std::exception();}
	| ABS {s="abs(";}
	| SGN {s="sgn(";}
	| SIN {s="sin(";}
	| COS {s="cos(";}
	| TAN {s="tan(";}
	| SEC {s="1e0/cos(";}
	| COSEC {s="1e0/sin(";}
	| COT {s="1e0/tan(";}
	| SINH {s="sinh(";}
	| COSH {s="cosh(";}
	| TANH {s="tanh(";}
	| SECH {s="1e0/cosh(";}
	| COSECH {s="1e0/sinh(";}
	| COTH {s="1e0/tanh(";}
	| ARCSIN {s="asin(";}
	| ARCCOS {s="acos(";}
	| ARCTAN {s="atan(";}
	| ARCSEC {s="acos(1e0/";}
	| ARCCOSEC {s="asin(1e0/";}
	| ARCCOT {s="pi/2-atan(";}
	| ARCSINH {s="asinh(";}
	| ARCCOSH {s="acosh(";}
	| ARCTANH {s="atanh(";}
	| ARCSECH {s="acosh(1e0/";}
	| ARCCOSECH {s="asinh(1e0/";}
	| ARCCOTH {s="atanh(1e0/";}
	| ERF {s="erf(";}
	| IM {s="imag(";}
	| RE {s="real(";}
	| ARG {s="arg(";}
	| GCD {throw std::exception();}
	| LCM {throw std::exception();}
	| CONJUGATE {throw std::exception();}
	| TRANSPONATE {throw std::exception();}
	| COMPLEMENTER {throw std::exception();}
	| EXP {s="exp(";}
	| #(LOG {s="log(";} (a=expr {s="1e0/log("+a+")*log(";})? )
	| SQRT {s="sqrt(";}
	| #(ROOT a=expr {s="exp(1.0/("+a+")*";})
	| CEIL {s="ceil(";}
	| FLOOR {s="floor(";}
        ;
