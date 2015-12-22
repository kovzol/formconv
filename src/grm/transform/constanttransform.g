  header {
#include <string>
#include <antlr/ASTFactory.hpp>
#include <h/fcAST.h>
#include <limits>
#include <cstdlib>
#include <sstream>
#include <cmath>
#include <gmpxx.h>
using namespace std;
}

header "post_include_cpp"
{
	const rational ConstantTransform::err = rational(1, std::numeric_limits<INTTYPE>::max());
}

options {
        language=Cpp;
}

/**
 * This file creates an AST. The input must be in Intuitive AST format.
 * This phase collects the constant expressions and precompute it.
 * It may set change the expressions like x^(1.0/3) to (sgn(x)*abs(x)^(1.0/3))
 *
 * Generation depends on the following files:
 * IntuitiveTokenTypes.txt
 * Compilation depends on the following files:
 * h/fcAST.h
 * From this file the following files will be created:
 * ConstantTransform.cpp, ConstantTransform.hpp, ConstantTransformTokenTypes.hpp, ConstantTransformTokenTypes.txt
 *
 * @version $Id: constanttransform.g,v 1.10 2012/06/26 10:52:33 baga Exp $
 * @author Gabor Bakos (baga@users.sourceforge.net)
 */

class ConstantTransform extends TreeParser;
options {
	importVocab=Intuitive;
	buildAST=true;
	ASTLabelType="RefFcAST";
	defaultErrorHandler=false;
}

{
//#define castt(x) ((antlr::RefAST)x)

#define INTTYPE mpz_class
#define rational mpq_class

	bool convertDecimal;
	bool convertExponents;

	const static rational err; //(1, std::numeric_limits<INTTYPE>::max())

	const std::string itos(INTTYPE i) const
	{
		std::stringstream s;
		s << i;
		return s.str();
	}
	
	const char * const removeZeroes(const char * str) const
	{
	  for (; *str=='0'; str++);
	  if (!*str) --str;
	  return str;
	}

	RefFcAST getAsAST(const rational r)
	{
		if (r<rational())
		{
			INTTYPE get_num=-r.get_num();
			return #(#[DIV, "/"], #[NUMBER, itos(get_num)], #(#[NEG, "-"], #[NUMBER, itos(r.get_den())]));
		}
		return #(#[DIV, "/"], #[NUMBER, itos(r.get_num())], #[NUMBER, itos(r.get_den())]);
	}

	const rational powi(const rational base, INTTYPE exponent) const
	{
		if (exponent==0)
		{
			return rational(1);
		}
		if (exponent<0)
		{
			return rational(1)/powi(base, -exponent);
		}
		rational multiplier=base;
		rational ret=rational(1);
		while (exponent>0)
		{
			if (exponent%2==1)
			{
				ret*=multiplier;
			}
			multiplier*=multiplier;
			exponent/=2;
		}
		return ret;
	}

	const INTTYPE factorial(INTTYPE n) const
	{
		INTTYPE ret=1;
		INTTYPE stop=2;
		for (INTTYPE i=n+1; i-->stop;)
		{
			ret*=i;
		}
		return ret;
	}

	const INTTYPE dfactorial(INTTYPE n) const
	{
		INTTYPE ret=1;
		INTTYPE stop=0;
		INTTYPE step=2;
		for (INTTYPE i=n; i>stop; i-=step)
		{
			ret*=i;
		}
		return ret;
	}

public:
	void setConvertDecimal(const bool convert)
	{
		convertDecimal=convert;
	}

	void setConvertExponents(const bool convert)
	{
		convertExponents=convert;
	}
}

inp	{rational r1;}:	(r1=expr)
	|
	;

expr returns [rational r = err] {rational r1, r2;}	:
	 !#(plus:PLUS r1=plus1:expr r2=plus2:expr {r=(r1!=err && r2!=err)?r1+r2:err; if (r!=err) #expr=getAsAST(r); else #expr=#(#plus, #plus1, #plus2);})
	|!#(minus:MINUS r1=minus1:expr r2=minus2:expr {r=(r1!=err && r2!=err)?r1-r2:err; if (r!=err) #expr=getAsAST(r); else #expr=#(#minus, #minus1, #minus2);})
	|!#(neg:NEG r1=neg1:expr {r=r1!=err?rational()-r1:err; if (r!=err) {#expr=getAsAST(r);} else #expr=#(#neg, #neg1);})
	|!#(mult:MULT r1=mult1:expr r2=mult2:expr {r=(r1!=err && r2!=err)?r1*r2:err; if (r!=err) #expr=getAsAST(r); else #expr=#(#mult, #mult1, #mult2);})
	|!#(div:DIV r1=div1:expr r2=div2:expr {r=(r1!=err && r2!=err && r2!=rational())?r1/r2:err; if (r!=err) #expr=getAsAST(r); else #expr=#(#div, #div1, #div2);})
	| #(MOD r1=expr r2=expr {r=(r1!=err && r2!=err && r1.get_den()==1 && r2.get_den()==1)?r1.get_num()%r2.get_num():err; if (r!=err) #expr=getAsAST(r);})
	| #(MODP r1=expr r1=expr r1=expr)
	| #(EQUIV r1=expr r1=expr)
	| #(MATRIXPRODUCT r1=expr r1=expr)
	| #(MATRIXEXPONENTIATION r1=expr r1=expr)
	| #(FACTOROF r1=expr r1=expr)
	|!#(circum:CIRCUM r1=circum1:expr r2=circum2:expr
		{
			r=(r1!=err && r2!=err && r2.get_den()==1)?powi(r1,r2.get_num()):err;
			if (r!=err)
			{
				#expr=getAsAST(r);
			}
			else if (r2!=err && r2.get_num()%2!=0 && r2.get_den()>1 && r2.get_den()%2==1 && convertExponents)
			{
				#expr=#(#[MULT, "*"], #(#circum, #(#[FUNCTION, "function"], #[ABS, "abs"], #circum1), getAsAST(r2)), #(#[FUNCTION, "function"], [SGN, "sgn"], #circum1));
			}
			else if (r2!=err && r2.get_den()>1 && r2.get_den()%2==1 && convertExponents)
			{
				#expr=#(#circum, #(#[FUNCTION, "function"], #[ABS, "abs"], #circum1), getAsAST(r2));
			}
			else
			{
				#expr=#(#circum, #circum1, #circum2);
			}
		})
	|!#(FACTORIAL r1=expr {r=(r1!=err && r1.get_den()==1 && r1>=rational())?rational(factorial(r1.get_num())):err; if (r!=err) #expr=getAsAST(r);})
	|!#(DFACTORIAL r1=expr {r=(r1!=err && r1.get_den()==1 && r1>=rational(-1))?rational(dfactorial(r1.get_num())):err; if (r!=err) #expr=getAsAST(r);})
	| #(UNDERSCORE r1=expr r1=expr)
	| #(PM r1=expr (r1=expr)?)
	| #(MP r1=expr (r1=expr)?)
	| #(DERIVE r1=expr r1=expr)
	| #(NTHDERIVE r1=expr r1=expr r1=expr)
	| #(NTHDERIVEX r1=expr r1=expr)
	| #(FUNCINVERSE r1=expr)
//	| #(FUNCMULT expr expr)
//	| #(FUNCPLUS expr exrp)
	| #(DEFINTEGRAL r1=expr r1=expr r1=expr r1=expr)
	| #(INDEFINTEGRAL r1=expr r1=expr)
	| #(SUM r1=expr r1=expr r1=expr r1=expr)
	| #(PROD r1=expr r1=expr r1=expr r1=expr)
	| #(EQUAL r1=expr r1=expr)
	| #(NEQ r1=expr r1=expr)
	| #(LESS r1=expr r1=expr)
	| #(LEQ r1=expr r1=expr)
	| #(NOTLESS r1=expr r1=expr)
	| #(LESSNOTEQ r1=expr r1=expr)
	| #(NOTLEQ r1=expr r1=expr)
	| #(GREATER r1=expr r1=expr)
	| #(GEQ r1=expr r1=expr)
	| #(NOTGREATER r1=expr r1=expr)
	| #(GREATERNOTEQ r1=expr r1=expr)
	| #(NOTGEQ r1=expr r1=expr)
//	| #(SETPOW expr expr)
//	| #(SETGENERATED expr)
	| #(SETSUBSET r1=expr r1=expr)
	| #(SETSUBSETEQ r1=expr r1=expr)
//	| #(SETSUBSETNEQ expr expr)
	| #(SETNOTSUBSETEQ r1=expr r1=expr)
	| #(SETSUPSET r1=expr r1=expr)
	| #(SETSUPSETEQ r1=expr r1=expr)
//	| #(SETSUPSETNEQ expr expr)
	| #(SETNOTSUPSETEQ r1=expr r1=expr)
	| #(SETIN r1=expr r1=expr)
//	| #(SETNI expr expr)
	| #(SET r1=expr (r1=expr)?)
	| #(SETMINUS r1=expr r1=expr)
	| #(SETMULT r1=expr r1=expr)
	| #(SETUNION r1=expr r1=expr)
	| #(SETINTERSECT r1=expr r1=expr)
	| #(ASSIGN r1=expr r1=expr)
	| #(NOT r1=expr)
	| #(AND r1=expr r1=expr)
	| #(OR r1=expr r1=expr)
//	| #(NAND expr expr)
//	| #(NOR expr expr)
	| #(IMPLY r1=expr r1=expr)
//	| #(RIMPLY expr expr)
//	| #(IFF expr expr)
	| #(FORALL r1=expr r1=expr)
	| #(EXISTS r1=expr r1=expr)
	| #(LIM r1=expr r1=expr r1=expr (r1=expr)?)
	| #(LIMSUP r1=expr (r1=expr)?)
	| #(LIMINF r1=expr (r1=expr)?)
	| #(SUP r1=expr (r1=expr)?)
	| #(INF r1=expr (r1=expr)?)
	| #(MAX r1=expr (r1=expr)?)
	| #(MIN r1=expr (r1=expr)?)
	| #(ARGMAX r1=expr (r1=expr)?)
	| #(ARGMIN r1=expr (r1=expr)?)
	| LEFT
	| RIGHT
	| REAL
	| COMPLEX
	| VARIABLE
	| number:NUMBER
		{
			std::string text=#number->getText();
			std::size_t pos=text.find('.');
			if (pos!=std::string::npos && convertDecimal)
			{
				const INTTYPE get_num(removeZeroes((text.substr(0,pos)+text.substr(pos+1)).c_str()));
				INTTYPE get_den=1;
				for (int i = text.length()-pos-1; i-->0;)
				{
					get_den*=10;
				}
				rational result(get_num, get_den);
				#expr=#(#[DIV, "/"], #[NUMBER, itos(result.get_num())], #[NUMBER, itos(result.get_den())]);
				r=result;
			}
			else
			{
				r=rational(text.c_str());
			}
		}
	| PARAMETER
	| DOTS
	| FC_TRUE
	| FC_FALSE
/*	|!ALPHA {#expr=#[PARAMETER, "alpha"];}
	|!BETA {#expr=#[PARAMETER, "beta"];}
	|!GAMMA {#expr=#[PARAMETER, "gamma"];}
	|!GAMMAG {#expr=#[PARAMETER, "Gamma"];}
	|!DELTA {#expr=#[PARAMETER, "delta"];}
	|!DELTAG {#expr=#[PARAMETER, "Delta"];}
	|!EPSILON {#expr=#[PARAMETER, "epsilon"];}
	|!ZETA {#expr=#[PARAMETER, "zeta"];}
	|!ETA {#expr=#[PARAMETER, "eta"];}
	|!THETA {#expr=#[PARAMETER, "theta"];}
	|!THETAG {#expr=#[PARAMETER, "Theta"];}
	|!IOTA {#expr=#[PARAMETER, "iota"];}
	|!KAPPA {#expr=#[PARAMETER, "kappa"];}
	|!LAMBDA {#expr=#[PARAMETER, "lambda"];}
	|!LAMBDAG {#expr=#[PARAMETER, "Lambda"];}
	|!MU {#expr=#[PARAMETER, "mu"];}
	|!NU {#expr=#[PARAMETER, "nu"];}
	|!XI {#expr=#[PARAMETER, "xi"];}
	|!XIG {#expr=#[PARAMETER, "Xi"];}
	|!OMICRON {#expr=#[PARAMETER, "omicron"];}*/
	| PI
/*	|!PIG {#expr=#[PARAMETER, "Pi"];}
	|!RHO {#expr=#[PARAMETER, "rho"];}
	|!SIGMA {#expr=#[PARAMETER, "sigma"];}
	|!SIGMAG {#expr=#[PARAMETER, "Sigma"];}
	|!TAU {#expr=#[PARAMETER, "tau"];}
	|!UPSILON {#expr=#[PARAMETER, "upsilon"];}
	|!UPSILONG {#expr=#[PARAMETER, "Upsilon"];}
	|!PHI {#expr=#[PARAMETER, "phi"];}
	|!PHIG {#expr=#[PARAMETER, "Phi"];}
	|!CHI {#expr=#[PARAMETER, "chi"];}
	|!PSI {#expr=#[PARAMETER, "psi"];}
	|!PSIG {#expr=#[PARAMETER, "Psi"];}
	|!OMEGA {#expr=#[PARAMETER, "omega"];}
	|!OMEGAG {#expr=#[PARAMETER, "Omega"];}*/
	| UNKNOWN
	| NONE
	| INFTY
	| E
	| I
	| NATURALNUMBERS
	| PRIMES
	| INTEGERS
	| RATIONALS
	| REALS
	| COMPLEXES
	| #(ENUMERATION (r1=expr)*)
	| #(PAIR r1=expr r1=expr)
	| #(LPAREN r=expr)
	| #(LBRACKET r1=expr)
	| #(VECTOR r1=expr)
	| #(MATRIXROW r1=expr)
	| #(MATRIX r1=expr)
	| #(GCD (r1=expr (r1=expr)?)?)
	| #(LCM (r1=expr (r1=expr)?)?)
	|!#(func:FUNCTION r1=funcType:expr r2=funcArg:expr
		{
			if (#funcType->getType()==ABS && r2!=err)
			{
				r=abs(r2);
				#expr=getAsAST(r);
			}
			else if (#funcType->getType()==ROOT)
			{
				if (r1.get_den()==1)
				{
					if (r2 != err)
					{
						rational root, r3=r2;
						if (r2 < rational())
						{
							if (r1.get_num()%2==1)
							{
								r3=-r2;
							}
							else
							{
								r=err;
							}
						}
						root=rational((INTTYPE)std::exp(1.0/r1.get_num().get_d()*std::log(r3.get_num().get_d()))), (INTTYPE)std::exp(1.0/r1.get_num().get_d()*std::log(r3.get_den().get_d()));
						if (powi(root, r1.get_num())==r3)
						{
							r=(r2<rational() && r1.get_num()%2==1)?rational()-root:root;
							#expr=#getAsAST(r);
						}
						else
						{
							r=err;
							#expr=#(#func, #funcType, #funcArg);
						}
					}
					else if (r1.get_num()%2==1 && convertExponents)
					{
						#expr=#(#[MULT, "*"], #(#[CIRCUM, "^"], #(#[FUNCTION, "function"], #[ABS, "abs"], #funcArg), getAsAST(rational(1)/r1)), #(#[FUNCTION, "function"], [SGN, "sgn"], #funcArg));
						r=err;
					}
					else
					{
						#expr=#(#func, #funcType, #funcArg);
						r=err;
					}
				}
				else
				{
					#expr=#(#func, #funcType, #funcArg);
					r=err;
				}
			} else
			{
				#expr=#(#func, #funcType, #funcArg);
				r=err;
			}
		})
	| #(TYPEDEF r1=expr)
	| #(DECLARE r1=expr r1=expr)
	| #(LAMBDACONSTRUCT r1=expr r1=expr)
	| SIZEOF
	| ABS
	| SGN
	| SIN
	| COS
	| TAN
	| SEC
	| COSEC
	| COT
	| SINH
	| COSH
	| TANH
	| SECH
	| COSECH
	| COTH
	| ARCSIN
	| ARCCOS
	| ARCTAN
	| ARCSEC
	| ARCCOSEC
	| ARCCOT
	| ARCSINH
	| ARCCOSH
	| ARCTANH
	| ARCSECH
	| ARCCOSECH
	| ARCCOTH
	| ERF
	| IM
	| RE
	| ARG
	| CONJUGATE
	| TRANSPONATE
	| COMPLEMENTER
	| EXP
	| LN
	| #(LOG (r1=expr)?)
	| SQRT
	| #(ROOT r1=expr {r=r1;})
	| CEIL
	| FLOOR
        ;

