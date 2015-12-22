header {
#include <complex>
#include <map>
#include <string>
#include <exception>
#include <cstdlib>
#include <h/fcAST.h>
using namespace std;
}

options {
        language=Cpp;
}

/**
 * This file creates just a complex number output, does not create AST. The input must use Intuitive AST format.
 * Generation depends on the following files:
 * IntuitiveTokenTypes.txt
 * Compilation depends on the following files:
 * h/fcAST.h
 * From this file the following files will be created:
 * ComplexCompute.cpp, ComplexCompute.hpp, ComplexComputeTokenTypes.hpp, ComplexComputeTokenTypes.txt
 * @author Gabor Bakos (baga@users.sourceforge.net)
 */

class ComplexCompute extends TreeParser;
options {
	importVocab=Intuitive;
	ASTLabelType = "RefFcAST";
	defaultErrorHandler=false;
}

{
public:
	void setValue(std::string s, std::complex<double> v)
	{
		val[s]=v;
	}

protected:
	map<std::string, std::complex<double> > val;
	complex<double> value(std::string s)
	{
		map<std::string, std::complex<double> >::iterator it=val.find(s);
		if (it==val.end())
			throw std::exception();
		return it->second;
	}
}

inp returns [std::complex<double> s] {std::complex<double> a;}:
	(a=expr {s=a;})
	|
	;

expr returns [std::complex<double> s]
	{
		std::complex<double> a=0,b,c,d;
	}
	:
	 #(PLUS a=expr b=expr {s=a+b;})
	|#(MINUS a=expr b=expr {s=a-b;})
	|#(NEG a=expr {s=-a;})
	|#(MULT a=expr b=expr {s=a*b;})
	|#(DIV a=expr b=expr {s=a/b;})
	|#(MATRIXPRODUCT a=expr b=expr {throw std::exception();})
	| n:NUMBER {s=complex<double>(atof((#n->getText()).c_str()), 0.0);}
	| p:PARAMETER {s=value(#p->getText());}
	|(#(FUNCTION SIN expr))=>#(FUNCTION SIN b=expr {s=sin(b);})
	|(#(FUNCTION COS expr))=>#(FUNCTION COS b=expr {s=cos(b);})
	|(#(FUNCTION TAN expr))=>#(FUNCTION TAN b=expr {s=tan(b);})
	|(#(FUNCTION COT expr))=>#(FUNCTION COT b=expr {s=tan(1.0/b);})
	|(#(FUNCTION ABS expr))=>#(FUNCTION ABS b=expr {s=abs(b);})
	|(#(FUNCTION IM expr))=>#(FUNCTION IM b=expr {s=imag(b);})
	|(#(FUNCTION RE expr))=>#(FUNCTION RE b=expr {s=real(b);})
	|(#(FUNCTION ARG expr))=>#(FUNCTION ARG b=expr {s=arg(b);})
	|(#(FUNCTION CONJUGATE expr))=>#(FUNCTION CONJUGATE b=expr {s=conj(b);})
	|(#(FUNCTION EXP expr))=>#(FUNCTION EXP b=expr {s=exp(b);})
	|(#(FUNCTION #(LOG (expr)?) expr))=>#(FUNCTION #(LOG (a=expr)?) b=expr {s=log(b); if (a!=0.0) s/=log(a);})
	|(#(FUNCTION SQRT expr))=>#(FUNCTION SQRT b=expr {s=sqrt(b);})
	|(#(FUNCTION #(ROOT expr) expr))=>#(FUNCTION #(ROOT a=expr) b=expr {s=exp(1.0/a*log(b));})
	|(#(FUNCTION SINH expr))=>#(FUNCTION SINH b=expr {s=sinh(b);})
	|(#(FUNCTION COSH expr))=>#(FUNCTION COSH b=expr {s=cosh(b);})
	|(#(FUNCTION TANH expr))=>#(FUNCTION TANH b=expr {s=tanh(b);})
	|(#(FUNCTION COTH expr))=>#(FUNCTION COTH b=expr {s=tanh(1.0/b);})
	|(#(FUNCTION SEC expr))=>#(FUNCTION SEC b=expr {s=cos(1.0/b);})
	|(#(FUNCTION COSEC expr))=>#(FUNCTION COSEC b=expr {s=sin(1.0/b);})
	|(#(FUNCTION SECH expr))=>#(FUNCTION SECH b=expr {s=cosh(1.0/b);})
	|(#(FUNCTION COSECH expr))=>#(FUNCTION COSECH b=expr {s=sinh(1.0/b);})
	|(#(FUNCTION ERF expr))=>#(FUNCTION ERF b=expr {throw std::exception();})
	|#(MOD a=expr b=expr {throw std::exception();/*s=a%b;*/})
	|#(MODP a=expr b=expr c=expr {throw std::exception();/*s=(a%c==b%c);*/})
	|#(EQUIV a=expr b=expr {throw std::exception();})
	|#(FACTOROF a=expr b=expr {throw std::exception();/*s=(b%a==0);*/})
	|#(CIRCUM a=expr b=expr {s=pow(a,b);})
	|#(FACTORIAL a=expr {/*s="factorial("+a+")";*/ throw std::exception();})
	|#(DFACTORIAL a=expr {/*s="dfactorial("+a+")";*/ throw std::exception();})
	|#(UNDERSCORE a=expr b=expr {/*s=""+a+"["+b+"]";*/ throw std::exception();})
	|#(PM a=expr b=expr {throw std::exception();})
	|#(MP a=expr b=expr {throw std::exception();})
	|#(DERIVE a=expr b=expr{throw std::exception();})
	|#(DEFINTEGRAL a=expr b=expr c=expr d=expr {throw std::exception();})
	|#(INDEFINTEGRAL a=expr b=expr {throw std::exception();})
	|#(SUM a=expr b=expr c=expr d=expr {/*s="for (ccomplex ___p=0.0, int "+a+"="+b+";"+a+"<="+c+";++"+a+"){___p+="+d+"}";*/} {throw std::exception();})
	|#(PROD a=expr b=expr c=expr d=expr {/*s="for (ccomplex ___p=1.0, int "+a+"="+b+";"+a+"<="+c+";++"+a+"){___p*="+d+"}";*/} {throw std::exception();})
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
	|#(ASSIGN a=expr b=expr {/*s=""+a+"="+b+""; */throw std::exception();})
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
	| v:VARIABLE {s=value(#v->getText());}
	| DOTS {throw std::exception();}
	| FC_TRUE {s=1;}
	| FC_FALSE {s=0;}
	| PI {s=M_PI;}
	| UNKNOWN {throw std::exception();}
	| NONE {s=0;}
	| INFTY {s=complex<double>(1e300, 0.0);}
	| E {s=exp(1.0);}
	| I {s=complex<double>(0.0, 1.0);}
	| NATURALNUMBERS {throw std::exception();}
	| PRIMES {throw std::exception();}
	| INTEGERS {throw std::exception();}
	| RATIONALS {throw std::exception();}
	| REALS {throw std::exception();}
	| COMPLEXES {throw std::exception();}
	|#(ENUMERATION {/*s=std::string("???");*/} (a=expr /*{s+=a; s+=",";}*/)* {throw std::exception();} )
	|#(PAIR a=expr b=expr {throw std::exception();})
	|#(LBRACKET a=expr {/*s="["+a+"]";*/ throw std::exception();})
	|#(VECTOR a=expr {/*s="["+a+"]";*/ throw std::exception();})
	|#(MATRIX a=expr {/*s="["+a+"]";*/ throw std::exception();})
	|#(MATRIXROW a=expr {/*s="["+a+"]";*/ throw std::exception();})
/*	|(#(FUNCTION ABS expr))=>#(FUNCTION ABS b=expr {s=cabs(b);})
	|(#(FUNCTION SIN expr))=>#(FUNCTION SIN b=expr {s=sin(b);})
	|(#(FUNCTION COS expr))=>#(FUNCTION COS b=expr {s=cos(b);})
	|(#(FUNCTION TAN expr))=>#(FUNCTION TAN b=expr {s=tan(b);})
	|(#(FUNCTION SEC expr))=>#(FUNCTION SEC b=expr {s=cos(1.0/b);})
	|(#(FUNCTION COSEC expr))=>#(FUNCTION COSEC b=expr {s=sin(1.0/b);})
	|(#(FUNCTION COT expr))=>#(FUNCTION COT b=expr {s=tan(1.0/b);})
	|(#(FUNCTION SINH expr))=>#(FUNCTION SINH b=expr {s=sinh(b);})
	|(#(FUNCTION COSH expr))=>#(FUNCTION COSH b=expr {s=cosh(b);})
	|(#(FUNCTION TANH expr))=>#(FUNCTION TANH b=expr {s=tanh(b);})
	|(#(FUNCTION SECH expr))=>#(FUNCTION SECH b=expr {s=cosh(1.0/b);})
	|(#(FUNCTION COSECH expr))=>#(FUNCTION COSECH b=expr {s=sinh(1.0/b);})
	|(#(FUNCTION COTH expr))=>#(FUNCTION COTH b=expr {s=tanh(1.0/b);})*/
	|(#(FUNCTION GCD expr))=>#(FUNCTION GCD b=expr {throw std::exception(); /*s=gcd(b);*//*b should be a vector...*/})
	|(#(FUNCTION LCM expr))=>#(FUNCTION LCM b=expr {throw std::exception(); /*s=lcm(b);*//*b should be a vector...*/})
	|(#(FUNCTION CEIL expr))=>#(FUNCTION CEIL b=expr {throw std::exception();})
	|(#(FUNCTION FLOOR expr))=>#(FUNCTION FLOOR b=expr {throw std::exception();})
/*	|#(FUNCTION a=expr b=expr {throw std::exception();})

	//Functions
	| SIZEOF {/*s="(sizeof(";* / throw std::exception();}
	| ARCSIN {throw std::exception();}
	| ARCCOS {throw std::exception();}
	| ARCTAN {throw std::exception();}
	| ARCSEC {throw std::exception();}
	| ARCCOSEC {throw std::exception();}
	| ARCCOT {throw std::exception();}
	| ARCSINH {throw std::exception();}
	| ARCCOSH {throw std::exception();}
	| ARCTANH {throw std::exception();}
	| ARCSECH {throw std::exception();}
	| ARCCOSECH {throw std::exception();}
	| ARCCOTH {throw std::exception();}
//	| ABS {s="(cabs(";}
//	| SIN {s="(csin(";}
/*	| COS {s="(ccos(";}
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
	| ARG {s="(carg(";}
	| IM {s="(cimag(";}
	| RE {s="(creal(";}
	| EXP {s="(cexp(";}
	| #(LOG {s="(clog(";} (a=expr {s="((1e0/clog("+a+"))*clog(";})?)
	| SQRT {s="(csqrt(";}
	| #(ROOT a=expr {s="cexp((1e0/"+a+")*clog(";})
	| CEIL {s="(ceil(";}
	| FLOOR {s="(floor(";}*/
        ;
