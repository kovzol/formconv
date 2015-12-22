header {
#include <string>
#include <stack>
#include <map>
#include <set>
#include <cstdio>
#include <exception>
#include <h/fcAST.h>
//using namespace std;
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
 * CComplexOutput.cpp, CComplexOutput.hpp, CComplexOutputTokenTypes.hpp, CComplexOutputTokenTypes.txt
 * @author Gabor Bakos (baga@users.sourceforge.net)
 * @version $Id: ccomplex.g,v 1.6 2010/04/21 19:53:24 kovzol Exp $
 */

class CComplexOutput extends TreeParser;
options {
	importVocab=Intuitive;
      ASTLabelType = "RefFcAST";
	defaultErrorHandler=false;
}

{
/**
 * Used, but not defined #define constants in the output:
 * FC_VAR_TYPE, FC_REAL_TYPE, FC_RATIONAL_TYPE, FC_COMPLEX_TYPE,
 * FC_INTEGER_TYPE, FC_VAR_IT_TYPE
 * Please define them if you want to compile your program!
 */
	private:
		std::string functions;
		int numOfFunctions;
		std::map<std::string, std::string> variables;
		std::set<std::string> vectors, matrices;
		bool forceFloatDiv;
		bool collectVariables;
		
		std::string toVectorDeclaration(const std::string s)
		{
			std::string ret=s;
			if (vectors.find(ret) != vectors.end())
				ret="*"+ret;
			if (matrices.find(ret) != matrices.end())
				ret="**"+ret;
			return ret;
		}

		std::string getVars(bool funcarg=true)
		{
			std::string ret="";
			for (std::map<std::string, std::string>::iterator it = variables.begin(); it != variables.end(); ++it)
				if ((*it).second != "FC_VAR_IT_TYPE ")
					if (funcarg)
						ret+=", "+(*it).second+" "+toVectorDeclaration((*it).first)+"";
					else
						ret+=(*it).second+" "+toVectorDeclaration((*it).first)+";\n";
			return ret;
		}

	public:
		std::string *getFunctions()
		{
			return new std::string(functions);
		}

		std::string *getDeclarations()
		{
			std::string *ret = new std::string(getVars(false)); /*new std::string("");
for (map<std::string, std::string>::iterator it = variables.begin(); it != variables.end(); ++it) *ret+=(*it).second+" "+(*it).first+";\n";*/
			return ret;
		}

		void setForceFloatDivision(bool newValue)
		{
		    forceFloatDiv = newValue;
		}

		void init(int num=0)
		{
			numOfFunctions=num;
			forceFloatDiv=false;
			collectVariables=true;
		}
}

inp returns [std::string *s] {std::string a;}:
	(a=expr {s=new std::string(a);})
	|
	;

expr returns [std::string s]
	{
		std::string a,b,c,d;
		bool oldCorrectVariables=collectVariables;
	}
	:
	 #(PLUS a=expr b=expr {s="("+a+"+"+b+")";})
	|#(MINUS a=expr b=expr {s="("+a+"-"+b+")";})
	|#(NEG a=expr {s="(-("+a+"))";})
	|#(MULT a=expr b=expr {s="("+a+"*"+b+")";})
	|#(DIV a=expr b=expr {s="("+a+(forceFloatDiv ? "*1.0" : "")+"/"+b+")";})
	|#(MATRIXPRODUCT a=expr b=expr {s="("+a+"*"+b+")";})//Assuming the * operator is overloaded for matrices too.
	|#(MOD a=expr b=expr {s="("+a+"%"+b+")";})
	|#(MODP a=expr b=expr c=expr {s="("+a+"%"+c+"=="+b+"%"+c+")";})
	|#(EQUIV a=expr b=expr {throw std::exception();})
	|#(FACTOROF a=expr b=expr {s="("+b+"%"+a+"==0)";})
	|#(CIRCUM a=expr b=expr {s="cpow("+a+","+b+")";})
	|#(FACTORIAL a=expr {s="factorial("+a+")";})
	|#(DFACTORIAL a=expr {s="dfactorial("+a+")";})
	|#(UNDERSCORE a=expr b=expr {s=""+a+"["+b+"]";})
	|#(PM a=expr b=expr {throw std::exception();})
	|#(MP a=expr b=expr {throw std::exception();})
	|#(DERIVE a=expr b=expr{throw std::exception();})
	|#(DEFINTEGRAL a=expr b=expr c=expr d=expr {throw std::exception();})
	|#(INDEFINTEGRAL a=expr b=expr {throw std::exception();})
	|#(SUM {collectVariables=false;} a=expr {collectVariables=oldCorrectVariables;} b=expr c=expr d=expr { char num[7]; sprintf(num, "%d", numOfFunctions); std::string defvars=getVars(true); s="FC_VAR_TYPE fc_func"+std::string(num)+"(int ___start, int ___stop"+defvars+")\n{\n  FC_VAR_TYPE ___p=0;\n  for (FC_VAR_IT_TYPE "+a+"=___start; "+a+"<=___stop; ++"+a+")\n  {\n    ___p+="+d+";\n  }\n  return ___p;\n}\n"; functions+=s; defvars=""; for (std::map<std::string, std::string>::iterator it = variables.begin(); it != variables.end(); ++it) defvars+=", "+(*it).first;  s="fc_func"+std::string(num)+"("+b+", "+c+defvars+")"; ++numOfFunctions;})
	|#(PROD {collectVariables=false;} a=expr {collectVariables=oldCorrectVariables;} b=expr c=expr d=expr { char num[7]; sprintf(num, "%d", numOfFunctions); std::string defvars=getVars(true); s="FC_VAR_TYPE fc_func"+std::string(num)+"(int ___start, int ___stop"+defvars+")\n{\n  FC_VAR_TYPE ___p=1;\n  for (FC_VAR_IT_TYPE "+a+"=___start; "+a+"<=___stop; ++"+a+")\n  {\n    ___p*="+d+";\n  }\n  return ___p;\n}\n"; functions+=s; defvars=""; for (std::map<std::string, std::string>::iterator it = variables.begin(); it != variables.end(); ++it) defvars+=", "+(*it).first;  s="fc_func"+std::string(num)+"("+b+", "+c+defvars+")"; ++numOfFunctions;})
	|#(EQUAL a=expr b=expr {throw std::exception();})
	|#(NEQ a=expr b=expr {throw std::exception();})
	|#(LESS a=expr b=expr {throw std::exception();})
	|#(LEQ a=expr b=expr {throw std::exception();})
	|#(GREATER a=expr b=expr {throw std::exception();})
	|#(GEQ a=expr b=expr {throw std::exception();})
	|#(SETSUBSET a=expr b=expr {throw std::exception();})
	|#(SETSUBSETEQ a=expr b=expr {throw std::exception();})
	|#(SETIN a=expr b=expr {throw std::exception();})
	|#(SET a=expr (b=expr)? {throw std::exception();})
	|#(SETMINUS a=expr b=expr {throw std::exception();})
	|#(SETMULT a=expr b=expr {throw std::exception();})
	|#(SETUNION a=expr b=expr {throw std::exception();})
	|#(SETINTERSECT a=expr b=expr {throw std::exception();})
	|#(ASSIGN a=expr b=expr {s=""+a+"="+b+"";})
	|#(NOT a=expr {throw std::exception();})
	|#(AND a=expr b=expr {throw std::exception();})
	|#(OR a=expr b=expr {throw std::exception();})
	|#(IMPLY a=expr b=expr {throw std::exception();})
	|#(IFF a=expr b=expr {throw std::exception();})
	|#(FORALL a=expr b=expr {throw std::exception();})
	|#(EXISTS a=expr b=expr {throw std::exception();})
	|#(LIM a=expr a=expr a=expr (a=expr)? {throw std::exception();})
	|#(LIMSUP a=expr (a=expr)? {throw std::exception();})
	|#(LIMINF a=expr (a=expr)? {throw std::exception();})
	|#(SUP a=expr (a=expr)? {throw std::exception();})
	|#(INF a=expr (a=expr)? {throw std::exception();})
	|#(MAX a=expr (a=expr)? {throw std::exception();})
	|#(MIN a=expr (a=expr)? {throw std::exception();})
	|#(ARGMAX a=expr (a=expr)? {throw std::exception();})
	|#(ARGMIN a=expr (a=expr)? {throw std::exception();})
	| LEFT {throw std::exception();}
	| RIGHT {throw std::exception();}
	| REAL {throw std::exception();}
	| COMPLEX {throw std::exception();}
	| v:VARIABLE {s=v->getText(); if (variables[s]=="") variables[s]=collectVariables?"FC_VAR_TYPE ":"FC_VAR_IT_TYPE ";}
	| n:NUMBER {s=n->getText();}
	| p:PARAMETER {s=p->getText(); if (variables[s]=="") variables[s]=collectVariables?"FC_VAR_TYPE ":"FC_VAR_IT_TYPE ";}
	| DOTS {throw std::exception();}
	| FC_TRUE {s=std::string("(!0)");}
	| FC_FALSE {s=std::string("(0)");}
	| PI {s=std::string("M_PI");}
	| UNKNOWN {throw std::exception();}
	| NONE {s=std::string("");}
	| INFTY {s=std::string("1e300");}
	| E {s=std::string("exp(1)");}
	| I {s=std::string("I");}
	| NATURALNUMBERS {throw std::exception();}
	| PRIMES {throw std::exception();}
	| INTEGERS {throw std::exception();}
	| RATIONALS {throw std::exception();}
	| REALS {throw std::exception();}
	| COMPLEXES {throw std::exception();}
	|#(ENUMERATION (a=expr {s+=a; s+="][";})* {s=s.substr(0, s.length()-2);})
	|#(PAIR a=expr b=expr {throw std::exception();})
	|#(LBRACKET a=expr {s="["+a+"]";})
	|#(VECTOR a=expr {s="["+a+"]";})
	|#(MATRIX a=expr {s="["+a+"]";})
	|#(MATRIXROW a=expr {s="["+a+"]";})
	|#(FUNCTION a=expr b=expr {s=""+a+""+b+"))";})
	|#(tdef:TYPEDEF a=expr {std::string ss=#tdef->getText(); if (ss=="real") variables[a]=std::string("FC_REAL_TYPE "); else if (ss=="integer") variables[a]=std::string("FC_INTEGER_TYPE "); else if (ss=="complex") variables[a]=std::string("FC_COMPLEX_TYPE "); else if (ss=="rational") variables[a]=std::string("FC_RATIONAL "); else if (ss=="vector") vectors.insert(a); else if (ss=="matrix") matrices.insert(a); s=a;})
	|#(DECLARE a=expr b=expr {std::string args=#expr->getText(); s=""; if (args.find("function")!=std::string::npos) {if (!(#a[0]=='F' && #a[1]=='C' && #a[2]=='_')) functions+="\nFC_VAR_TYPE "+a+b; else functions+="\n"+a+b;}})
	|#(LAMBDACONSTRUCT a=expr {for (std::string::size_type i=0; i<a.length(); ++i) {if (a[i]=='[') a[i]=' '; else if (a[i]==']') a[i]=',';}} b=expr {s="("+a+")\n{\n  return "+b+";\n}\n";})
	//Functions
	| SIZEOF {s="(sizeof("; throw std::exception();}
	| ABS {s="(cabs(";}
	| SGN {s="(sgn(";}
	| SIN {s="(csin(";}
	| COS {s="(ccos(";}
	| TAN {s="(ctan(";}
	| SEC {s="(1e0/ccos(";}
	| COSEC {s="(1e0/csin(";}
	| COT {s="(1e0/ctan(";}
	| SINH {s="(csinh(";}
	| COSH {s="(ccosh(";}
	| TANH {s="(ctanh(";}
	| SECH {s="(1e0/ccosh(";}
	| COSECH {s="(1e0/csinh(";}
	| COTH {s="(1e0/ctanh(";}
	| ARCSIN {s="(casin(";}
	| ARCCOS {s="(cacos(";}
	| ARCTAN {s="(catan(";}
	| ARCSEC {s="(cacos(1e0/";}
	| ARCCOSEC {s="(casin(1e0/";}
	| ARCCOT {s="(catan(1e0/";}
	| ARCSINH {s="(casinh(";}
	| ARCCOSH {s="(cacosh(";}
	| ARCTANH {s="(catanh(";}
	| ARCSECH {s="(cacosh(1e0/";}
	| ARCCOSECH {s="(casinh(1e0/";}
	| ARCCOTH {s="(catan(1e0/";}
	| ERF {throw std::exception();}
	| IM {s="(cimag(";}
	| RE {s="(creal(";}
	| ARG {s="(carg(";}
	| GCD {s="(gcd(";}
	| LCM {s="(lcm(";}
	| CONJUGATE {s="(conj(";}
	| TRANSPONATE {s="transponate("; throw std::exception();}
	| COMPLEMENTER {s="complementer("; throw std::exception();}
	| EXP {s="(cexp(";}
	| #(LOG {s="(clog(";} (a=expr {s="((1e0/log("+a+"))*clog(";})?)
	| SQRT {s="(csqrt(";}
	| #(ROOT a=expr {s="cexp((1e0/"+a+")*clog(";})
	| CEIL {s="(ceil(";}
	| FLOOR {s="(floor(";}
        ;
