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
 * MathMLOutput.cpp, MathMLOutput.hpp, MathMLOutputTokenTypes.hpp, MathMLOutputTokenTypes.txt
 * 
 * After construction it is recommended to call init()
 * @author Gabor Bakos (baga@users.sourceforge.net)
 */

class MathMLOutput extends TreeParser;
options {
	importVocab=Intuitive;
	ASTLabelType = "RefFcAST";
	defaultErrorHandler=false;
}

{
protected:
	bool isIndent;
	std::string incIndent;
	std::string declares;
	bool useBVar;
	std::string getTypeName(std::string t)
	{
	    std::string typeName="";
	    if (t.find("vector")!=std::string::npos)
	    {
	      typeName="vector";
	    }
	    else if (t.find("function")!=std::string::npos)
	    {
	    	std::string::size_type pos=t.find("nargs");
		typeName="function";
		if (pos!=std::string::npos)
		{
		  std::string::size_type pos1=t.find("\"", pos);
		  std::string::size_type pos2=t.find("\"", pos1);
		  typeName+="\" nargs=\""+t.substr(pos1, pos2);
		}
	    }
	    else if (t.find("matrix")!=std::string::npos)
	    {
	      typeName="matrix";
	    }
	    else if (t.find("matrixrow")!=std::string::npos)
	    {
	      typeName="matrixrow";
	    }
	    else if (t.find("set")!=std::string::npos)
	    {
	      typeName="set";
	    }
	    else if (t.find("list")!=std::string::npos)
	    {
	      typeName="list";
	    }
	    return typeName;
	}

private:
	std::string convertToEntities(std::string text)
	{
		if (text=="alpha")
		{
			return "&alpha;";
		}
		else if (text=="beta")
		{
			return "&beta;";
		}
//		else if (text=="gamma")
//		{
//			return "&gamma;";
//		}
		else if (text=="Gamma")
		{
			return "&Gamma;";
		}
		else if (text=="delta")
		{
			return "&delta;";
		}
		else if (text=="Delta")
		{
			return "&Delta;";
		}
		else if (text=="epsilon")
		{
			return "&epsiv;";
		}
		else if (text=="zeta")
		{
			return "&zeta;";
		}
		else if (text=="eta")
		{
			return "&eta;";
		}
		else if (text=="theta")
		{
			return "&thetav;";
		}
		else if (text=="Theta")
		{
			return "&Theta;";
		}
		else if (text=="iota")
		{
			return "&itoa;";
		}
		else if (text=="kappa")
		{
			return "&kappa;";
		}
		else if (text=="lambda")
		{
			return "&lambda;";
		}
		else if (text=="Lambda")
		{
			return "&Lambda;";
		}
		else if (text=="mu")
		{
			return "&mu;";
		}
		else if (text=="nu")
		{
			return "&nu;";
		}
		else if (text=="xi")
		{
			return "&xi;";
		}
		else if (text=="omicron")
		{
			return "&3BF;";
		}
		else if (text=="Pi")
		{
			return "&Pi;";
		}
		else if (text=="rho")
		{
			return "&rho;";
		}
		else if (text=="sigma")
		{
			return "&sigma;";
		}
		else if (text=="Sigma")
		{
			return "&Sigma;";
		}
		else if (text=="tau")
		{
			return "&tau;";
		}
		else if (text=="upsilon")
		{
			return "&upsilon;";
		}
		else if (text=="Upsilon")
		{
			return "&Upsilon;";
		}
		else if (text=="phi")
		{
			return "&phi;";
		}
		else if (text=="Phi")
		{
			return "&Phi;";
		}
		else if (text=="chi")
		{
			return "&chi;";
		}
		else if (text=="psi")
		{
			return "&psi;";
		}
		else if (text=="Psi")
		{
			return "&Psi;";
		}
		else if (text=="omega")
		{
			return "&omega;";
		}
		else if (text=="Omega")
		{
			return "&Omega;";
		}
		else
		{
			return text;
		}
	}

public:
	void init()
	{
		declares="";
		isIndent=true;
		incIndent="  ";
	}
private:
}

inp returns [string s] {string a;}:
	(a=expr["\n"] {s=a;})
	|
	;

expr[string indent] returns [string s]
	{
		string a,b,c,d;
	}
	:
	 #(PLUS a=expr[indent+incIndent] b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<plus/>"+a+""+b+(isIndent?indent:"")+"</apply>";})
	|#(MINUS a=expr[indent+incIndent] b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<minus/>"+a+""+b+(isIndent?indent:"")+"</apply>";})
	|#(NEG a=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<minus/>"+a+(isIndent?indent:"")+"</apply>";})
	|#(MULT a=expr[indent+incIndent] b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<times/>"+a+""+b+(isIndent?indent:"")+"</apply>";})
	|#(DIV a=expr[indent+incIndent] b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<divide/>"+a+""+b+(isIndent?indent:"")+"</apply>";})
	|#(MATRIXPRODUCT a=expr[indent+incIndent] b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<times/>"+a+""+b+(isIndent?indent:"")+"</apply>";})
	|#(MATRIXEXPONENTIATION a=expr[indent+incIndent] b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<power/>"+a+""+b+(isIndent?indent:"")+"</apply>";})
	|#(MOD a=expr[indent+incIndent] b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<rem/>"+a+""+b+(isIndent?indent:"")+"</apply>";})
	|#(MODP a=expr[indent+incIndent] b=expr[indent+incIndent] c=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<eq/><apply><rem/>"+a+""+c+"</apply><apply><rem/>"+b+""+c+"</apply></apply>";})
	|#(EQUIV a=expr[indent+incIndent] b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<equivalent/>"+a+""+b+(isIndent?indent:"")+"</apply>";})
	|#(FACTOROF a=expr[indent+incIndent] b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<factorof/>"+a+""+b+(isIndent?indent:"")+"</apply>";})
	|#(CIRCUM a=expr[indent+incIndent] b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<power/>"+a+""+b+(isIndent?indent:"")+"</apply>";})
	|#(FACTORIAL a=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<factorial/>"+a+(isIndent?indent:"")+"</apply>";})
	|#(DFACTORIAL a=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<factorial/>"+a+(isIndent?indent:"")+"</apply>"; throw std::exception();})
	|#(UNDERSCORE a=expr[indent+incIndent] b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<selector/>"+a+""+b+(isIndent?indent:"")+"</apply>";})
	|#(PM a=expr[indent+incIndent] (b=expr[indent+incIndent])? {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<csymbol>&PlusMinus;</csymbol>"+a+b+(isIndent?indent:"")+"</apply>";})
	|#(MP a=expr[indent+incIndent] (b=expr[indent+incIndent])? {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<csymbol>&MinusPlus;</csymbol>"+a+b+(isIndent?indent:"")+"</apply>";})
	|#(DERIVE a=expr[indent+incIndent] {useBVar=true;} b=expr[indent+incIndent] {useBVar=false;} {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<diff/><bvar>"+b+"</bvar>"+a+(isIndent?indent:"")+"</apply>";})
	|#(NTHDERIVE a=expr[indent+incIndent] b=expr[indent+incIndent+incIndent] {useBVar=true;} c=expr[indent+incIndent] {useBVar=false;} {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<diff/>"+(isIndent?indent+incIndent:"")+"<bvar>"+c+(isIndent?indent+incIndent+incIndent:"")+"<degree>"+b+(isIndent?indent+incIndent+incIndent:"")+"</degree>"+(isIndent?indent+incIndent:"")+"</bvar>"+a+(isIndent?indent:"")+"</apply>";})
	|#(DEFINTEGRAL a=expr[indent+incIndent] {useBVar=true;} b=expr[indent+incIndent] {useBVar=false;} c=expr[indent+incIndent] d=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<int/>"+(isIndent?indent+incIndent:"")+"<bvar>"+b+(isIndent?indent+incIndent:"")+"</bvar>"+(isIndent?indent+incIndent:"")+"<lowlimit>"+c+(isIndent?indent+incIndent:"")+"</lowlimit>"+(isIndent?indent+incIndent:"")+"<uplimit>"+d+(isIndent?indent+incIndent:"")+"</uplimit>"+a+(isIndent?indent:"")+"</apply>";})
	|#(INDEFINTEGRAL a=expr[indent+incIndent] {useBVar=true;} b=expr[indent+incIndent] {useBVar=false;} {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<int/>"+(isIndent?indent+incIndent:"")+"<bvar>"+b+(isIndent?indent+incIndent:"")+"</bvar>"+a+(isIndent?indent:"")+"</apply>";})
	|#(SUM {useBVar=true;} a=expr[indent+incIndent] {useBVar=false;} b=expr[indent+incIndent] c=expr[indent+incIndent] d=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<sum/>"+(isIndent?indent+incIndent:"")+"<bvar>"+a+(isIndent?indent+incIndent:"")+"</bvar>"+(isIndent?indent+incIndent:"")+"<lowlimit>"+b+(isIndent?indent+incIndent:"")+"</lowlimit>"+(isIndent?indent+incIndent:"")+"<uplimit>"+c+(isIndent?indent+incIndent:"")+"</uplimit>"+d+(isIndent?indent:"")+"</apply>";})
	|#(PROD {useBVar=true;} a=expr[indent+incIndent] {useBVar=false;} b=expr[indent+incIndent] c=expr[indent+incIndent] d=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<prod/>"+(isIndent?indent+incIndent:"")+"<bvar>"+a+(isIndent?indent+incIndent:"")+"</bvar>"+(isIndent?indent+incIndent:"")+"<lowlimit>"+b+(isIndent?indent+incIndent:"")+"</lowlimit>"+(isIndent?indent+incIndent:"")+"<uplimit>"+c+(isIndent?indent+incIndent:"")+"</uplimit>"+d+(isIndent?indent:"")+"</apply>";})
	|#(EQUAL a=expr[indent+incIndent] b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<eq/>"+a+""+b+(isIndent?indent:"")+"</apply>";})
	|#(NEQ a=expr[indent+incIndent] b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<neq/>"+a+""+b+(isIndent?indent:"")+"</apply>";})
	|#(LESS a=expr[indent+incIndent] b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<lt/>"+a+""+b+(isIndent?indent:"")+"</apply>";})
	|#(LEQ a=expr[indent+incIndent] b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<leq/>"+a+""+b+(isIndent?indent:"")+"</apply>";})
	|#(GREATER a=expr[indent+incIndent] b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<gt/>"+a+""+b+(isIndent?indent:"")+"</apply>";})
	|#(GEQ a=expr[indent+incIndent] b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<geq/>"+a+""+b+(isIndent?indent:"")+"</apply>";})
	|#(SETSUBSET a=expr[indent+incIndent] b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<prsubset/>"+a+""+b+(isIndent?indent:"")+"</apply>";})
	|#(SETSUBSETEQ a=expr[indent+incIndent] b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<subset/>"+a+""+b+(isIndent?indent:"")+"</apply>";})
	|#(SETIN a=expr[indent+incIndent] b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<in/>"+a+""+b+(isIndent?indent:"")+"</apply>";})
	|#(SET {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<set/><apply>";} (a=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<set/>"+a+(isIndent?indent:"")+"</apply>";} (b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<set/>"+(isIndent?indent+incIndent:"")+"<bvar>"+a+(isIndent?indent+incIndent:"")+"</bvar>"+(isIndent?indent+incIndent:"")+"<condition>"+b+(isIndent?indent+incIndent:"")+"</condition>"+(isIndent?indent:"")+"</apply>";})?)? )
	|#(SETMINUS a=expr[indent+incIndent] b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<setdiff/>"+a+""+b+(isIndent?indent:"")+"</apply>";})
	|#(SETMULT a=expr[indent+incIndent] b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<cartesianproduct/>"+a+""+b+(isIndent?indent:"")+"</apply>";})
	|#(SETUNION a=expr[indent+incIndent] b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<union/>"+a+""+b+(isIndent?indent:"")+"</apply>";})
	|#(SETINTERSECT a=expr[indent+incIndent] b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<intersect/>"+a+""+b+(isIndent?indent:"")+"</apply>";})
	|#(ASSIGN a=expr[indent+incIndent] b=expr[indent+incIndent] {s=""+a+"="+b+"";})
	|#(NOT a=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<not/>"+a+(isIndent?indent:"")+"</apply>";})
	|#(AND a=expr[indent+incIndent] b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<and/>"+a+""+b+(isIndent?indent:"")+"</apply>";})
	|#(OR a=expr[indent+incIndent] b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<or/>"+a+""+b+(isIndent?indent:"")+"</apply>";})
	|#(IMPLY a=expr[indent+incIndent] b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<implies/>"+a+""+b+(isIndent?indent:"")+"</apply>";})
	|#(IFF a=expr[indent+incIndent+incIndent] b=expr[indent+incIndent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<and/>"+(isIndent?indent+incIndent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<implies/>"+a+""+b+(isIndent?indent+incIndent:"")+"</apply>"+(isIndent?indent+incIndent:"")+"<apply>"+(isIndent?indent+incIndent+incIndent:"")+"<implies>"+b+""+a+(isIndent?indent+incIndent:"")+"</apply>"+(isIndent?indent:"")+"</apply>";})
	|#(FORALL {useBVar=true;} a=expr[indent+incIndent] {useBVar=false;} b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<forall/>"+(isIndent?indent+incIndent:"")+"<bvar>"+a+(isIndent?indent+incIndent:"")+"</bvar>"+b+(isIndent?indent:"")+"</apply>";})
	|#(EXISTS {useBVar=true;} a=expr[indent+incIndent] {useBVar=false;} b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<exists/>"+(isIndent?indent+incIndent:"")+"<bvar>"+a+(isIndent?indent+incIndent:"")+"</bvar>"+b+(isIndent?indent:"")+"</apply>";})
	|#(LIM a=expr[indent+incIndent] b=expr[indent+incIndent+incIndent] c=expr[indent+incIndent] (d=expr[indent+incIndent])? {if (d=="") b=(isIndent?indent+incIndent:"")+"<lowlimit>"+b+(isIndent?indent+incIndent:"")+"</lowlimit>"; else b=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<condition/>"+(isIndent?indent+incIndent:"")+"<tendsto type=\""+d+"\">"+a+b+(isIndent?indent+incIndent:"")+"</apply>"; s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+"<limit/>"+(isIndent?indent+incIndent:"")+"<bvar>"+a+(isIndent?indent+incIndent:"")+"</bvar>"+b+c+(isIndent?indent:"")+"</apply>";})
	|#(LIMSUP a=expr[indent+incIndent] (b=expr[indent+incIndent])? {throw std::exception();})
	|#(LIMINF a=expr[indent+incIndent] (b=expr[indent+incIndent])? {throw std::exception();})
	|#(SUP a=expr[indent+incIndent] (b=expr[indent+incIndent])? {throw std::exception();})
	|#(INF a=expr[indent+incIndent] (b=expr[indent+incIndent])? {throw std::exception();})
	|#(MAX a=expr[indent+incIndent] (b=expr[indent+incIndent])? {throw std::exception();})
	|#(MIN a=expr[indent+incIndent] (b=expr[indent+incIndent])? {throw std::exception();})
	|#(ARGMAX a=expr[indent+incIndent] b=expr[indent+incIndent] {throw std::exception();})
	|#(ARGMIN a=expr[indent+incIndent] b=expr[indent+incIndent] {throw std::exception();})
	| LEFT {s=std::string("below");}
	| RIGHT {s=std::string("above");}
	| REAL {s=std::string("two-sided");}
	| COMPLEX {throw std::exception();}
	| v:VARIABLE {s=(isIndent?indent:"")+"<ci>"+v->getText()+"</ci>";}
	| n:NUMBER {s=(isIndent?indent:"")+"<cn>"+n->getText()+"</cn>";}
	| p:PARAMETER {s=(isIndent?indent:"")+"<ci>"+convertToEntities(p->getText())+"</ci>";}
	| DOTS {throw std::exception();}
	| FC_TRUE {s=(isIndent?indent:"")+"<true/>";}
	| FC_FALSE {s=std::string((isIndent?indent:"")+"<false/>");}
	| PI {s=std::string((isIndent?indent:"")+"<pi/>");}
	| UNKNOWN {throw std::exception();}
	| NONE {s=std::string("");}
	| INFTY {s=std::string((isIndent?indent:"")+"<infinity/>");}
	| E {s=std::string((isIndent?indent:"")+"<exponentiale/>");}
	| I {s=std::string((isIndent?indent:"")+"<imaginaryi/>");}
	| NATURALNUMBERS {s=std::string((isIndent?indent:"")+"<naturalnumbers/>");}
	| PRIMES {s=std::string((isIndent?indent:"")+"<primes/>");}
	| INTEGERS {s=std::string((isIndent?indent:"")+"<integers/>");}
	| RATIONALS {s=std::string((isIndent?indent:"")+"<rationals/>");}
	| REALS {s=std::string((isIndent?indent:"")+"<reals/>");}
	| COMPLEXES {s=std::string((isIndent?indent:"")+"<complexes/>");}
	|#(ENUMERATION {s=std::string(""); bool first=true;} (a=expr[indent] {if (!first && useBVar) s+=(isIndent?indent:"")+"</bvar>"+(isIndent?indent:"")+"<bvar>"; first=false; s+=a; s+="";})* )
	|#(PAIR a=expr[indent+incIndent] b=expr[indent] {throw std::exception();})
	|#(LBRACKET a=expr[indent+incIndent] {s=(isIndent?indent:"")+"<vector>"+a+(isIndent?indent:"")+"</vector>";})
	|#(VECTOR a=expr[indent+incIndent] {s=(isIndent?indent:"")+"<vector>"+a+(isIndent?indent:"")+"</vector>";})
	|#(MATRIX a=expr[indent+incIndent] {s=(isIndent?indent:"")+"<matrix>"+a+(isIndent?indent:"")+"</matrix>";})
	|#(MATRIXROW a=expr[indent+incIndent] {s=(isIndent?indent:"")+"<matrixrow>"+a+(isIndent?indent:"")+"</matrixrow>";})
	|#(FUNCTION a=expr[indent+incIndent] b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<apply>"+(isIndent?indent+incIndent:"")+a+""+b+(isIndent?indent:"")+"</apply>";})
	|#(type:TYPEDEF a=expr[indent+incIndent]
	  {
	    std::string t=#type->getText();
	    std::string typeName=getTypeName(t);
	    declares+=(isIndent?indent:"")+"<declare type=\""+typeName+"\">"+a+(isIndent?indent:"")+"</declare>";})
	|#(decl:DECLARE a=expr[indent+incIndent] b=expr[indent+incIndent] {std::string typeName=getTypeName(#decl->getText()); declares=(isIndent?indent:"")+"<declare type=\""+typeName+"\">"+a+b+(isIndent?indent:"")+"</declare>";})
	|#(LAMBDACONSTRUCT {useBVar=true;} a=expr[indent+incIndent] {useBVar=false;} b=expr[indent+incIndent] {s=(isIndent?indent:"")+"<lambda>"+a+b+(isIndent?indent:"")+"</lambda>";})
	//Functions
	| SIZEOF {s="<card/>";}
	| ABS {s="<abs/>";}
	| SGN {s="<sgn/>";}
	| SIN {s="<sin/>";}
	| COS {s="<cos/>";}
	| TAN {s="<tan/>";}
	| SEC {s="<sec/>";}
	| COSEC {s="<csc/>";}
	| COT {s="<cot/>";}
	| SINH {s="<sinh/>";}
	| COSH {s="<cosh/>";}
	| TANH {s="<tanh/>";}
	| SECH {s="<sech/>";}
	| COSECH {s="<csch/>";}
	| COTH {s="<coth/>";}
	| ARCSIN {s="<arcsin/>";}
	| ARCCOS {s="<arccos/>";}
	| ARCTAN {s="<arctan/>";}
	| ARCSEC {s="<arcsec/>";}
	| ARCCOSEC {s="<arccsc/>";}
	| ARCCOT {s="<arccot/>";}
	| ARCSINH {s="<arcsinh/>";}
	| ARCCOSH {s="<arccosh/>";}
	| ARCTANH {s="<arctanh/>";}
	| ARCSECH {s="<arcsech/>";}
	| ARCCOSECH {s="<arccsch/>";}
	| ARCCOTH {s="<arccoth/>";}
	| ERF {s="<ci>erf</ci>";}
	| IM {s="<imaginary/>";}
	| RE {s="<real/>";}
	| ARG {s="<arg/>";}
	| GCD {s="<gcd/>";}
	| LCM {s="<lcm/>";}
	| CONJUGATE {s="<conjugate/>";}
	| TRANSPONATE {s="<transpose/>";}
	| COMPLEMENTER {s="complementer("; throw std::exception();}
	| EXP {s="<exp/>";}
	| #(LOG {s="<log/>";} (a=expr[indent+incIndent] {s="<log/>"+(isIndent?indent+incIndent:"")+"<logbase>"+a+(isIndent?indent+incIndent:"")+"</logbase>";})?)
	| SQRT {s="<root/>";}
	| #(ROOT a=expr[indent+incIndent] {s="<root/>"+(isIndent?indent+incIndent:"")+"<degree>"+a+(isIndent?indent+incIndent:"")+"</degree>";})
	| CEIL {s="<ceil/>";}
	| FLOOR {s="<floor/>";}
        ;
