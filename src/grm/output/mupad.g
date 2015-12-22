header {
#include <string>
#include <exception>
#include <h/fcAST.h>
#include <h/misc.h>
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
 * MupadOutput.cpp, MupadOutput.hpp, MupadOutputTokenTypes.hpp, MupadOutputTokenTypes.txt
 * @author Gabor Bakos (baga@users.sourceforge.net)
 */

class MupadOutput extends TreeParser;
options {
	importVocab=Intuitive;
	ASTLabelType = "RefFcAST";
	defaultErrorHandler=false;
}

{
	/**
	 * If true, it writes all (possibly unnecessary) parentheses. If true, it writes just at
	 * generated positions (and in function calls), where there is an LPAREN node.
	 */
	bool writeParen;

public:
	void setWriteParen(bool writeAllParentheses)
	{
		writeParen = writeAllParentheses;
	}

	static Precedence mupadTokenPrecedence(const int t)
	{
		Precedence ret=NOTINPREC;
		switch (t)
		{
			case PLUS:
			case MINUS:
			case NEG:
			case SETUNION:
			case SETINTERSECT:
			case SETMINUS:
			case PM:
			case MP:
			case SUM:
				ret=ADDITION;
				break;
			case MULT:
			case DIV:
			case FUNCMULT:
			case SETMULT:
			case PROD:
				ret=MULTIPLY;
				break;
			case CIRCUM:
				ret=POWER;
				break;
			case LPAREN:
			case LBRACKET:
			case ABS:
				ret=PAREN;
				break;
			case EQUAL:
			case NEQ:
			case LESS:
			case LEQ:
			case NOTLESS:
			case NLEQ:
			case GREATER:
			case GEQ:
			case NOTGREATER:
			case NGEQ:
			case SETSUBSET:
			case SETSUBSETEQ:
			case SETSUBSETNEQ:
			case SETNOTSUBSETEQ:
			case SETSUPSET:
			case SETSUPSETEQ:
			case SETSUPSETNEQ:
			case SETNOTSUPSETEQ:
			case SETIN:
			case SETNI:
			case SETNOTIN:
			case SETNOTNI:
				ret=RELATION;
				break;
			case OR:
				ret=DISJUNCTION;
				break;
			case AND:
				ret=CONJUNCTION;
				break;
			case IMPLY:
			case RIMPLY:
				ret=CONCLUSION;
				break;

		}
		return ret;
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
	 #(PLUS a=expr b=expr {s=writeParen ? "("+a+"+"+b+")" : a+"+"+b;})
	|#(MINUS a=expr b=expr {s=writeParen ? "("+a+"-"+b+")" : a+"-"+b;})
	|#(NEG a=expr {s=writeParen ? "(-("+a+"))" : "-"+a;})
	|#(MULT a=expr b=expr {s=writeParen ? "("+a+"*"+b+")" : a+"*"+b;})
	|#(DIV a=expr b=expr {s=writeParen ? "("+a+"/"+b+")" : a+"/"+b;})
	|#(MATRIXPRODUCT a=expr b=expr {s=writeParen ? "("+a+"*"+b+")" : a+"*"+b;})
	|#(MOD a=expr b=expr {s=writeParen ? "("+a+" mod "+b+")" : a+" mod "+b;})
	|#(MODP a=expr b=expr c=expr {s=writeParen ? "(("+a+" mod "+c+") = ("+b+" mod "+c+"))" : a+" mod "+c+" = "+b+" mod "+c;})
	|#(EQUIV a=expr b=expr {throw std::exception();})
	|#(FACTOROF a=expr b=expr {s=writeParen ? "(("+b+" mod "+a+") = 0)" : b+" mod "+a+" = 0";})
	|#(CIRCUM a=expr b=expr {s=writeParen ? "("+a+"^"+b+")" : a+"^"+b;})
	|#(FACTORIAL a=expr {s=writeParen ? "("+a+")!" : a+"!";})
	|#(DFACTORIAL a=expr {s=writeParen ? "("+a+")!!" : a+"!!";})
	|#(UNDERSCORE a=expr b=expr {s=""+a+"["+b+"]";})
	|#(PM a=expr (b=expr {s=writeParen ? "("+a+" Symbol::plusmn "+b+")" : a+" Symbol::plusmn "+b; return s;})? {s=writeParen ? " Symbol::plusmn("+a+")" : " Symbol::plusmn "+a;})
	|#(MP a=expr (b=expr {s="-("+a+" Symbol::plusmn "+b+")"; return s;})? {s=" -Symbol::plusmn "+(writeParen ? "("+a+")" : a);})
	|#(DERIVE a=expr b=expr{s="diff("+a+", "+b+")";})
	|#(NTHDERIVE a=expr b=expr c=expr{s="diff("+a+", "+c+" $ "+b+")";})
	|#(NTHDERIVEX a=expr b=expr{s="diff("+a+", x $ "+b+")";})
	|#(DEFINTEGRAL a=expr b=expr c=expr d=expr {s="int("+a+", "+b+"="+c+".."+d+")";})
	|#(INDEFINTEGRAL a=expr b=expr {s="int("+a+", "+b+")";})
	|#(SUM a=expr b=expr c=expr d=expr {s="sum("+d+", "+a+"="+b+".."+c+")";})
	|#(PROD a=expr b=expr c=expr d=expr {s="product("+d+", "+a+"="+b+".."+c+")";})
	|#(EQUAL a=expr b=expr {s=writeParen ? "("+a+" = "+b+")" : a+" = "+b;})
	|#(NEQ a=expr b=expr {s=writeParen ? "("+a+" <> "+b+")" : a+" <> "+b;})
	|#(LESS a=expr b=expr {s=writeParen ? "("+a+"<"+b+")" : a+"<"+b;})
	|#(LEQ a=expr b=expr {s=writeParen ? "("+a+"<="+b+")" : a+"<="+b;})
	|#(GREATER a=expr b=expr {s=writeParen ? "("+a+">"+b+")" : a+">"+b;})
	|#(GEQ a=expr b=expr {s=writeParen ? "("+a+">="+b+")" : a+">="+b;})
	|#(SETSUBSET a=expr b=expr {s=writeParen ? "(("+a+" subset "+b+") and ("+a+"<>"+b+"))" : "("+a+" subset "+b+" and "+a+"<>"+b+")";})
	|#(SETSUBSETEQ a=expr b=expr {s=writeParen ? "("+a+" subset "+b+")" : a+" subset "+b;})
	|#(SETIN a=expr b=expr {s=writeParen ? "("+a+" in "+b+")" : a+" in "+b;})
	|#(SET {} (a=expr {} (b=expr {})?)? {throw std::exception();})
	|#(SETMINUS a=expr b=expr {s=writeParen ? "("+a+" minus "+b+")" : a+" minus "+b;})
	|#(SETMULT a=expr b=expr {throw std::exception();})
	|#(SETUNION a=expr b=expr {s=writeParen ? "("+a+" union "+b+")" : a+" union "+b;})
	|#(SETINTERSECT a=expr b=expr {s=writeParen ? "("+a+" intersect "+b+")" : a+" intersect "+b;})
	|#(ASSIGN a=expr b=expr {s=""+a+"="+b+"";})
	|#(NOT a=expr {s=writeParen ? "(not "+a+")" : "not "+a;})
	|#(AND a=expr b=expr {s=writeParen ? "("+a+" and "+b+")" : a+" and "+b;})
	|#(OR a=expr b=expr {s=writeParen ? "("+a+" or "+b+")" : a+" or "+b;})
	|#(IMPLY a=expr b=expr {s=writeParen ? "("+a+"==> "+b+")" : a+"==> "+b;})
	|#(IFF a=expr b=expr {s=writeParen ? "("+a+"<=>"+b+")" : a+"<=>"+b;})
	|#(FORALL a=expr b=expr {throw std::exception();})
	|#(EXISTS a=expr b=expr {throw std::exception();})
	|#(LIM a=expr b=expr c=expr (d=expr)? {s="limit("+c+", "+a+"="+b+d+")";})
	|#(LIMSUP a=expr (b=expr)? {throw std::exception();})
	|#(LIMINF a=expr (b=expr)? {throw std::exception();})
	|#(SUP a=expr (b=expr)? {throw std::exception();})
	|#(INF a=expr (b=expr)? {throw std::exception();})
	|#(MAX a=expr (b=expr)? {s="max("+a+")";})
	|#(MIN a=expr (b=expr)? {s="min("+a+")";})
	|#(ARGMAX a=expr b=expr {throw std::exception();})
	|#(ARGMIN a=expr b=expr {throw std::exception();})
	| LEFT {s=std::string(", left");}
	| RIGHT {s=std::string(", right");}
	| REAL {s=std::string(", real");}
	| COMPLEX {throw std::exception();}
	| v:VARIABLE {s=""+v->getText()+"";}
	| n:NUMBER {s=""+n->getText()+"";}
	| p:PARAMETER {s=""+p->getText()+"";}
	| DOTS {throw std::exception();}
	| FC_TRUE {s="TRUE ";}
	| FC_FALSE {s=std::string("FALSE ");}
	| PI {s=std::string("PI");}
	| UNKNOWN {throw std::exception();}
	| NONE {s=std::string("");}
	| INFTY {s=std::string("infinity ");}
	| E {s=std::string("exp(1)");}
	| I {s=std::string("I");}
	| NATURALNUMBERS {throw std::exception();}
	| PRIMES {throw std::exception();}
	| INTEGERS {s=std::string("Z_");}
	| RATIONALS {s=std::string("Q_");}
	| REALS {s=std::string("R_");}
	| COMPLEXES {s=std::string("C_");}
	|#(ENUMERATION {s=std::string("");} (a=expr {if (s!="") s+=", "; s+=a;})* )
	|#(PAIR a=expr b=expr {throw std::exception();})
	|#(LBRACKET a=expr {s="["+a+"]";})
	|#(VECTOR a=expr {s="["+a+"]";})
	|#(MATRIX a=expr {s="["+a+"]";})
	|#(MATRIXROW a=expr {s="["+a+"]";})
	|(#(FUNCTION #(LOG expr) expr))=>(#(FUNCTION #(LOG a=expr) b=expr {s="log("+a+", "+b+")";}))
	|(#(FUNCTION #(ROOT expr) expr))=>(#(FUNCTION #(ROOT a=expr) b=expr {s="surd("+b+", "+a+")";}))
	|#(FUNCTION a=expr b=expr {s=""+a+"("+b+")";})
	|#(LPAREN a=expr {s="("+a+")";})
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
	| ARG {s="arg";}
	| GCD {s="gcd";}
	| LCM {s="lcm";}
	| CONJUGATE {s="conjugate";}
	| TRANSPONATE {throw std::exception();}
	| COMPLEMENTER {throw std::exception();}
	| EXP {s="exp";}
	| LOG {s="ln";}
	| SQRT {s="sqrt";}
	| CEIL {s="ceil";}
	| FLOOR {s="floor";}
        ;
