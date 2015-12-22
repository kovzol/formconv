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
 * MathematicaOutput.cpp, MathematicaOutput.hpp, MathematicaOutputTokenTypes.hpp, MathematicaOutputTokenTypes.txt
 * @author Gabor Bakos (baga@users.sourceforge.net)
 */

class MathematicaOutput extends TreeParser;
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
	|#(MATRIXPRODUCT a=expr b=expr {s="("+a+" . "+b+")";})
	|#(MOD a=expr b=expr {s="Mod["+a+","+b+"]";})
	|#(MODP a=expr b=expr c=expr {s="(Mod["+a+","+c+"]==Mod["+b+","+c+"])";})
	|#(EQUIV a=expr b=expr {throw std::exception();})
	|#(FACTOROF a=expr b=expr {s="(Mod["+b+","+a+"]==0)";})
	|#(CIRCUM a=expr b=expr {s="("+a+"^"+b+")";})
	|#(FACTORIAL a=expr {s="Factorial["+a+"]";})
	|#(DFACTORIAL a=expr {s="Factorial2["+a+"]";})
	|#(UNDERSCORE a=expr b=expr {s=""+a+"{"+b+"}";})
	|#(PM a=expr b=expr {throw std::exception();})
	|#(MP a=expr b=expr {throw std::exception();})
	|#(DERIVE a=expr b=expr{s="Dt["+a+", "+b+"]";})//TODO: Not really good...
	|#(DEFINTEGRAL a=expr b=expr c=expr d=expr {s="Integrate["+a+",{"+b+"."+c+""+d+"}]";})
	|#(INDEFINTEGRAL a=expr b=expr {s="Integrate["+a+", "+b+"]";})
	|#(SUM a=expr b=expr c=expr d=expr {s="Sum["+d+",{"+a+","+b+","+c+"}]";})
	|#(PROD a=expr b=expr c=expr d=expr {s="Product["+d+",{"+a+","+b+","+c+"}]";})
	|#(EQUAL a=expr b=expr {s="("+a+"=="+b+")";})
	|#(NEQ a=expr b=expr {s="("+a+"!="+b+")";})
	|#(LESS a=expr b=expr {s="("+a+"<"+b+")";})
	|#(LEQ a=expr b=expr {s="("+a+"<="+b+")";})
	|#(GREATER a=expr b=expr {s="("+a+">"+b+")";})
	|#(GEQ a=expr b=expr {s="("+a+">="+b+")";})
	|#(SETSUBSET a=expr b=expr {s="Subset["+a+","+b+"]";})//TODO: One of them is wrong...
	|#(SETSUBSETEQ a=expr b=expr {s="Subset["+a+""+b+"]";})//TODO: One of them is wrong...
	|#(SETIN a=expr b=expr {s="Element["+a+","+b+"]";})
	|#(SET {} (a=expr {} (b=expr {})?)? {throw std::exception();})
	|#(SETMINUS a=expr b=expr {s="Complement["+a+","+b+"]";})
	|#(SETMULT a=expr b=expr {s="("+a+"*"+b+")"; throw std::exception();})
	|#(SETUNION a=expr b=expr {s="Union["+a+","+b+"]";})
	|#(SETINTERSECT a=expr b=expr {s="Intersection["+a+","+b+"]";})
	|#(ASSIGN a=expr b=expr {s=""+a+"="+b+"";})
	|#(NOT a=expr {s="Not["+a+"]";})
	|#(AND a=expr b=expr {s="And["+a+","+b+"]";})
	|#(OR a=expr b=expr {s="Or["+a+","+b+"]";})
	|#(IMPLY a=expr b=expr {s="Implies["+a+","+b+"]";})
	|#(IFF a=expr b=expr {s="And[Implies["+a+","+b+"],Implies["+b+","+a+"]]";})
	|#(FORALL a=expr b=expr {s="ForAll["+a+","+b+"]";})//Not really good...
	|#(EXISTS a=expr b=expr {s="Exists["+a+","+b+"]";})
	|#(LIM a=expr b=expr c=expr (d=expr)? {s="Limit["+c+", "+a+"->"+b+d+"]";})
	|#(LIMSUP a=expr (b=expr)? {throw std::exception();})
	|#(LIMINF a=expr (b=expr)? {throw std::exception();})
	|#(SUP a=expr (b=expr)? {throw std::exception();})
	|#(INF a=expr (b=expr)? {throw std::exception();})
	|#(MAX a=expr (b=expr)? {throw std::exception();})
	|#(MIN a=expr (b=expr)? {throw std::exception();})
	|#(ARGMAX a=expr b=expr {throw std::exception();})
	|#(ARGMIN a=expr b=expr {throw std::exception();})
	| LEFT {s=std::string(", Direction->1");}
	| RIGHT {s=std::string(", Direction->-1");}
	| REAL {throw std::exception();}
	| COMPLEX {throw std::exception();}
	| v:VARIABLE {s=""+v->getText()+"";}
	| n:NUMBER {s=""+n->getText()+"";}
	| p:PARAMETER {s=""+p->getText()+"";}
	| DOTS {throw std::exception();}
	| FC_TRUE {s="True";}
	| FC_FALSE {s=std::string("False");}
	| PI {s=std::string("Pi");}
	| UNKNOWN {throw std::exception();}
	| NONE {s=std::string("");}
	| INFTY {s=std::string("Infinity");}
	| E {s=std::string("E");}
	| I {s=std::string("I");}
	| NATURALNUMBERS {throw std::exception();}
	| PRIMES {throw std::exception();}
	| INTEGERS {throw std::exception();}
	| RATIONALS {throw std::exception();}
	| REALS {throw std::exception();}
	| COMPLEXES {throw std::exception();}
	|#(ENUMERATION {s=std::string("");} (a=expr {if (s!="") s+=", "; s+=a;})* )
	|#(PAIR a=expr b=expr {throw std::exception();})
	|#(LBRACKET a=expr {s="{"+a+"}";})
	|#(VECTOR a=expr {s="{"+a+"}";})
	|#(MATRIX a=expr {s="{"+a+"}";})
	|#(MATRIXROW a=expr {s="{"+a+"}";})
	|(#(FUNCTION #(LOG expr) expr))=>(#(FUNCTION #(LOG a=expr) b=expr {s="Log["+a+","+b+"]";}))
	|(#(FUNCTION #(ROOT expr) expr))=>(#(FUNCTION #(ROOT a=expr) b=expr {s=""+b+"^(1.0/"+a+")";}))
	|#(FUNCTION a=expr b=expr {s=""+a+""+b+"]";})
	//Functions
	| SIZEOF {s=""; throw std::exception();}
	| ABS {s="Abs[";}
	| SGN {s="Sgn[";}
	| SIN {s="Sin[";}
	| COS {s="Cos[";}
	| TAN {s="Tan[";}
	| SEC {s="Sec[";}
	| COSEC {s="Csc[";}
	| COT {s="Cot[";}
	| SINH {s="Sinh[";}
	| COSH {s="Cosh[";}
	| TANH {s="Tanh[";}
	| SECH {s="Sech[";}
	| COSECH {s="Csch[";}
	| COTH {s="Coth[";}
	| ARCSIN {s="ArcSin[";}
	| ARCCOS {s="ArcCos[";}
	| ARCTAN {s="ArcTan[";}
	| ARCSEC {s="ArcSec[";}
	| ARCCOSEC {s="ArcCsc[";}
	| ARCCOT {s="ArcCot[";}
	| ARCSINH {s="ArcSinh[";}
	| ARCCOSH {s="ArcCosh[";}
	| ARCTANH {s="ArcTanh[";}
	| ARCSECH {s="ArcSech[";}
	| ARCCOSECH {s="ArcCsch[";}
	| ARCCOTH {s="ArcCoth[";}
	| ERF {s="Erf[";}
	| IM {s="Im[";}
	| RE {s="Re[";}
	| ARG {s="Arg[";}
	| GCD {s="GCD[";}
	| LCM {s="LCM[";}
	| CONJUGATE {s="Conjugate[";}
	| TRANSPONATE {s="Transpose[";}
	| COMPLEMENTER {s="Complement[";}
	| EXP {s="Exp[";}
	| LOG {s="Log[";}
	| SQRT {s="Sqrt[";}
	| CEIL {s="Ceiling[";}
	| FLOOR {s="Floor[";}
        ;
