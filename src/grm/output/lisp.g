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
 * LispOutput.cpp, LispOutput.hpp, LispOutputTokenTypes.hpp, LispOutputTokenTypes.txt
 * 
 * @author Gabor Bakos (baga@users.sourceforge.net)
 */

//TODO create the proper output in case of not supported trigonometric functions too.
class LispOutput extends TreeParser;
options {
	importVocab=Intuitive;
	ASTLabelType = "RefFcAST";
	defaultErrorHandler=false;
}

{
protected:
	std::string declares;
	bool useBVar;

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
	 #(PLUS a=expr b=expr {s="(+ "+a+" "+b+")";})
	|#(MINUS a=expr b=expr {s="(- "+a+" "+b+")";})
	|#(NEG a=expr {s="(- 0 "+a+")";})
	|#(MULT a=expr b=expr {s="(* "+a+" "+b+")";})
	|#(DIV a=expr b=expr {s="(/ "+a+" "+b+")";})
	|#(MATRIXPRODUCT a=expr b=expr {s="(prod "+a+" "+b+")";})
	|#(MATRIXEXPONENTIATION a=expr b=expr {s="(exp "+a+" "+b+")";})
	|#(MOD a=expr b=expr {s="(mod "+a+" "+b+")";})
	|#(MODP a=expr b=expr c=expr {s="(= (mod "+a+" "+c+") (mod "+b+" "+c+")";})
	|#(EQUIV a=expr b=expr {throw std::exception();})
	|#(FACTOROF a=expr b=expr {s="(= 0 (mod "+b+" "+a+"))";})
	|#(CIRCUM a=expr b=expr {s="(expt "+a+" "+b+")";})
	|#(FACTORIAL a=expr {throw std::exception();})
	|#(DFACTORIAL a=expr {throw std::exception();})
	|#(UNDERSCORE a=expr b=expr {throw std::exception();})
	|#(PM a=expr b=expr {throw std::exception();})
	|#(MP a=expr b=expr {throw std::exception();})
	|#(DERIVE a=expr b=expr {throw std::exception();})
	|#(NTHDERIVE a=expr b=expr {useBVar=true;} c=expr {throw std::exception();})
	|#(DEFINTEGRAL a=expr b=expr c=expr d=expr {throw std::exception();})
	|#(INDEFINTEGRAL a=expr b=expr {throw std::exception();})
	|#(SUM a=expr b=expr c=expr d=expr {throw std::exception();} )
	|#(PROD a=expr b=expr c=expr d=expr {throw std::exception();})
	|#(EQUAL a=expr b=expr {s="(= "+a+" "+b+")";})
	|#(NEQ a=expr b=expr {s="(/= "+a+" "+b+")";})
	|#(LESS a=expr b=expr {s="(< "+a+" "+b+")";})
	|#(LEQ a=expr b=expr {s="(<= "+a+" "+b+")";})
	|#(GREATER a=expr b=expr {s="(> "+a+" "+b+")";})
	|#(GEQ a=expr b=expr {s="(>= "+a+" "+b+")";})
	|#(SETSUBSET a=expr b=expr {throw std::exception();})
	|#(SETSUBSETEQ a=expr b=expr {throw std::exception();})
	|#(SETIN a=expr b=expr {throw std::exception();} )
	|#(SET (a=expr (b=expr)?)? {throw std::exception();} )
	|#(SETMINUS a=expr b=expr {throw std::exception();})
	|#(SETMULT a=expr b=expr {throw std::exception();})
	|#(SETUNION a=expr b=expr {throw std::exception();})
	|#(SETINTERSECT a=expr b=expr {throw std::exception();})
	|#(ASSIGN a=expr b=expr {s="(setf "+a+" "+b+")";})
	|#(NOT a=expr {s="(lognot "+a+")";})
	|#(AND a=expr b=expr {s="(and "+a+" "+b+")";})
	|#(OR a=expr b=expr {s="(or "+a+" "+b+")";})
	|#(IMPLY a=expr b=expr {s="(or (lognot "+a+" "+b+"))";})
	|#(IFF a=expr b=expr {s="(and (or (not "+a+" "+b+")) (or (not "+b+" "+a+")))";})
	|#(FORALL {useBVar=true;} a=expr {useBVar=false;} b=expr { throw std::exception();})
	|#(EXISTS {useBVar=true;} a=expr {useBVar=false;} b=expr {throw std::exception();})
	|#(LIM a=expr b=expr c=expr (d=expr)? {throw std::exception();})
	|#(LIMSUP a=expr (b=expr)? {throw std::exception();})
	|#(LIMINF a=expr (b=expr)? {throw std::exception();})
	|#(SUP a=expr (b=expr)? {throw std::exception();})
	|#(INF a=expr (b=expr)? {throw std::exception();})
	|#(MAX a=expr (b=expr)? {s="(min "+a+")";})
	|#(MIN a=expr (b=expr)? {s="(max "+a+")";})
	|#(ARGMAX a=expr b=expr {throw std::exception();})
	|#(ARGMIN a=expr b=expr {throw std::exception();})
	| LEFT {s=std::string(""); throw std::exception();}
	| RIGHT {s=std::string(""); throw std::exception();}
	| REAL {s=std::string(""); throw std::exception();}
	| COMPLEX {throw std::exception();}
	| v:VARIABLE {s=""+v->getText()+"";}
	| n:NUMBER {s=""+n->getText()+"";}
	| p:PARAMETER {s=""+p->getText()+"";}
	| DOTS {throw std::exception();}
	| FC_TRUE {s="t";}
	| FC_FALSE {s=std::string("nil");}
	| PI {s=std::string("pi");}
	| UNKNOWN {throw std::exception();}
	| NONE {s=std::string("");}
	| INFTY {s=std::string("inf"); throw std::exception();}
	| E {s=std::string("(exp 1)");}
	| I {s=std::string("#C(0 1)");}
	| NATURALNUMBERS {s=std::string("natural"); throw std::exception();}
	| PRIMES {s=std::string("prime"); throw std::exception();}
	| INTEGERS {s=std::string("integer"); throw std::exception();}
	| RATIONALS {s=std::string("rational"); throw std::exception();}
	| REALS {s=std::string("real"); throw std::exception();}
	| COMPLEXES {s=std::string("complex"); throw std::exception();}
	|#(ENUMERATION (a=expr {s+=" "+a; s+="";})* )
	|#(PAIR a=expr b=expr {throw std::exception();})
	|#(LBRACKET a=expr {s="#("+a+")";})
	|#(FUNCTION a=expr b=expr {if (a.substr(0, 4)=="log " && a.length()>4) s="(log "+b+" "+a.substr(4)+")"; else if (a.substr(0, 5)=="expt " && a.length()>5) s="(expt "+b+" (/ 1 "+a.substr(5)+"))"; else s="("+a+" "+b+")";})
	|#(type:TYPEDEF a=expr
	  {
	    std::string t=#type->getText();
//	    std::string typeName=getTypeName(t);
//	    declares+="("+typeName+" "+a+")";
	    throw std::exception();})
	|#(decl:DECLARE a=expr b=expr {
//	    std::string typeName=getTypeName(#decl->getText());
//	    declares="("+typeName+a+" "+b+")";
	    throw std::exception();})
	|#(LAMBDACONSTRUCT a=expr b=expr {s="(lambda"+a+" "+b+")"; throw std::exception();})
	//Functions
	| SIZEOF {s="card"; throw std::exception();}
	| ABS {s="abs ";}
	| SGN {s="sgn ";}
	| SIN {s="sin ";}
	| COS {s="cos ";}
	| TAN {s="tan ";}
	| SEC {s="sec "; throw std::exception();}
	| COSEC {s="csc"; throw std::exception();}
	| COT {s="cot"; throw std::exception();}
	| SINH {s="sinh";}
	| COSH {s="cosh";}
	| TANH {s="tanh";}
	| SECH {s="sech"; throw std::exception();}
	| COSECH {s="csch"; throw std::exception();}
	| COTH {s="coth"; throw std::exception();}
	| ARCSIN {s="asin";}
	| ARCCOS {s="acos";}
	| ARCTAN {s="atan";}
	| ARCSEC {s="asec";}
	| ARCCOSEC {s="acsc";}
	| ARCCOT {s="acot";}
	| ARCSINH {s="asinh";}
	| ARCCOSH {s="acosh";}
	| ARCTANH {s="atanh";}
	| ARCSECH {s="asech"; throw std::exception();}
	| ARCCOSECH {s="acsch"; throw std::exception();}
	| ARCCOTH {s="acoth"; throw std::exception();}
	| ERF {throw std::exception();}
	| IM {s="imagpart";}
	| RE {s="realpart";}
	| ARG {s="phase";}
	| GCD {s="gcd";}
	| LCM {s="lcm";}
	| CONJUGATE {s="conjugate";}
	| TRANSPONATE {s="transpose"; throw std::exception();}
	| COMPLEMENTER {s="complementer("; throw std::exception();}
	| EXP {s="exp ";}
	| #(LOG {s="log ";} (a=expr {s="log "+a+"";})?)
	| SQRT {s="sqrt ";}
	| #(ROOT a=expr {s="expt "+a+"";})
	| CEIL {s="ceiling ";}
	| FLOOR {s="floor ";}
        ;
