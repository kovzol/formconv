header {
#include <string>
#include <h/misc.h>
#include <h/fcAST.h>
using namespace std;
}

options {
        language=Cpp;
}


/**
 * This file creates a string from an Intuitive type AST (less errors, if it is after presentation transformation).
 * Generation depends on the following files:
 * IntuitiveTokenTypes.txt
 * Compilation depends on the following files:
 * h/misc.h h/fcAST.h
 * From this file the following files will be created:
 * LaTeXOutput.cpp, LaTeXOutput.hpp, LaTeXOutputTokenTypes.hpp, LaTeXOutputTokenTypes.txt
 * @author Gabor Bakos (baga@users.sourceforge.net)
 */

class LaTeXOutput extends TreeParser;
options {
	importVocab=Intuitive;
	noConstructors = true;
	ASTLabelType = "RefFcAST";
	defaultErrorHandler=false;
}

{
public:
	/**
	 * Sets the input's language.
	 * @param l The proper language
	 */
	void setLanguage(Language l)
	{
		lang=l;
	}

	/**
	 * Sets whether you want to see \left(, \right) pairs in the output.
	 * @param t The new value for dynamicParentheses
	 */
	void setDynamicParentheses(bool t=true)
	{
		dynamicParentheses=t;
	}

	/**
	 * Sets whether you want to change simple (, ) to (, ), [, ], and {, }.
	 * @param t The new value for beautyParentheses
	 */
	void setBeautyParentheses(bool t=true)
	{
		beautyParentheses=t;
	}

	/**
	 * The constructor.
	 */
	LaTeXOutput() : antlr::TreeParser(), dynamicParentheses(false), beautyParentheses(false), lang(C), enumStrategy(normal)
	{
	}

protected:
	bool lastWasFunction, dynamicParentheses, beautyParentheses;
	Language lang;

	EnumerationStrategy enumStrategy;
}

inp returns [string s] {string a;}:
	(a=expr {s=a;})
	|
	;

expr returns [string s]
	{
		string a,b,c,d;
		lastWasFunction=false;
		bool tmp=false, locLastWasFunction=false;
	}
	:
	(
	 #(PLUS a=expr b=expr {s=""+a+"+"+b+"";})
	|#(MINUS a=expr b=expr {s=""+a+"-"+b+"";})
	|#(NEG a=expr {s="-"+a+"";})
	|#(MULT a=expr b=expr {s=""+a+"\\cdot "+b+"";})
	|#(MATRIXPRODUCT a=expr b=expr {s=""+a+"\\cdot "+b+"";})
	|#(MATRIXEXPONENTIATION a=expr b=expr {s=""+a+"^{"+b+"}";})
	|#(INVISIBLETIMES a=expr b=expr {s=""+a+"\\, "+b+"";})
	|#(DIV a=expr b=expr {s="\\frac{"+a+"}{"+b+"}";})
	|#(MOD a=expr b=expr {s=""+a+"\\bmod "+b+"";})
	|#(MODP a=expr b=expr {s=""+a+"\\pmod {"+b+"}";})
	|#(FACTOROF a=expr b=expr {s=""+a+"\\left|"+b+"\\right.";})
	|#(EQUIV a=expr b=expr {s=""+a+"\\equiv "+b+"";})
//	|(#(CIRCUM func[""] expr))? #(CIRCUM a=func["^{}"] b=expr {s=""+a+""; string::size_type pos=s.find("^{}"); s.replace(pos, 2, "^{"+b);})
	|#(CIRCUM a=expr {tmp=lastWasFunction;} b=expr
	  {
	  	s=a;
		string::size_type pos=s.find("^{}");
		if (pos!=string::npos && tmp /*&& pos<11*/)
			s.replace(pos, 2, "^{"+b);
		else
//			if (s.compare(0,11,"\\mathrm{e}^"))
//				s="("+a+")^{"+b+"}";
//			else
				s=""+a+"^{"+b+"}";})
	|#(FACTORIAL a=expr {s=""+a+"!";})
	|#(DFACTORIAL a=expr {s=""+a+"!!";})
	|#(UNDERSCORE a=expr b=expr {s=""+a+"_{"+b+"}";})
	|#(PM a=expr (b=expr)? {if (b!="") s=""+a+"\\pm "+b+""; else s="\\pm "+a+"";})
	|#(MP a=expr (b=expr)? {if (b!="") s=""+a+"\\mp "+b+""; else s="\\mp "+a+"";})
	|#(DERIVE a=expr b=expr {s="\\frac {\\partial } {\\partial "+b+"}"+a+"";})
	|#(DERIVET a=expr {s="\\dot {"+a+"}";})
	|#(DDERIVET a=expr {s="\\ddot {"+a+"}";})
	|#(DERIVEX a=expr {s=""+a+"'";})
	|#(NTHDERIVE a=expr b=expr c=expr {s="\\frac{\\partial^{"+b+"}}{\\partial "+c+"^{"+b+"}}"+a+"";})
//	|#(NTHDERIVEX a=expr b=expr {s=a+"^{("+b+")}";})
//	|#(FUNCMULT expr expr)
//	|#(FUNCPLUS expr expr)
	|#(FUNCINVERSE a=expr {s=a+"^{-1}";})
	|#(DEFINTEGRAL a=expr b=expr c=expr d=expr {s="\\int_{"+c+"}^{"+d+"}"+a+"\\mathrm{d}"+b+"";})
	|#(INDEFINTEGRAL a=expr b=expr {s="\\int"+a+"\\mathrm{d}"+b+"";})
	|#(SUM a=expr b=expr c=expr d=expr {if (b=="") s="\\sum"+d+""; else s="\\sum_{"+a+":="+b+"}^{"+c+"}"+d+"";})
	|#(PROD a=expr b=expr c=expr d=expr {if (b=="") s="\\prod"+d+""; else s="\\prod_{"+a+":="+b+"}^{"+c+"}"+d+"";})
	|#(EQUAL a=expr b=expr {s=""+a+"="+b+"";})
	|#(NEQ a=expr b=expr {s=""+a+"\\neq "+b+"";})
	|#(LESS a=expr b=expr {s=""+a+"<"+b+"";})
	|#(LEQ a=expr b=expr {s=""+a+"\\leq "+b+"";})
	|#(NOTLESS a=expr b=expr {s=""+a+"\\nless "+b+"";})
	|#(LESSNOTEQ a=expr b=expr {s=""+a+"\\lneq "+b+"";})
	|#(NOTLEQ a=expr b=expr {s=""+a+"\\nleq "+b+"";})
	|#(GREATER a=expr b=expr {s=""+a+">"+b+"";})
	|#(GEQ a=expr b=expr {s=""+a+"\\geq "+b+"";})
	|#(NOTGREATER a=expr b=expr {s=""+a+"\\ngtr "+b+"";})
	|#(GREATERNOTEQ a=expr b=expr {s=""+a+"\\gneq "+b+"";})
	|#(NOTGEQ a=expr b=expr {s=""+a+"\\ngeq "+b+"";})
	|#(SETSUBSET a=expr b=expr {s=""+a+"\\subset "+b+"";})
	|#(SETSUBSETEQ a=expr b=expr {s=""+a+"\\subseteq "+b+"";})
	|#(SETSUBSETNEQ a=expr b=expr {s=""+a+"\\subsetneq "+b+"";})
	|#(SETNOTSUBSETEQ a=expr b=expr {s=""+a+"\\nsubseteq "+b+"";})
	|#(SETSUPSET a=expr b=expr {s=""+a+"\\supset "+b+"";})
	|#(SETSUPSETEQ a=expr b=expr {s=""+a+"\\supseteq "+b+"";})
	|#(SETSUPSETNEQ a=expr b=expr {s=""+a+"\\supsetneq "+b+"";})
	|#(SETNOTSUPSETEQ a=expr b=expr {s=""+a+"\\nsupseteq "+b+"";})
	|#(SETIN a=expr b=expr {s=""+a+"\\in "+b+"";})
	|#(SETNI a=expr b=expr {s=""+a+"\\ni "+b+"";})
	|#(SET a=expr (b=expr)? {if (b=="") s="\\left\\{"+a+"\\right\\}"; else s="\\left\\{"+a+"|"+b+"\\right\\}";})
	|#(SETMINUS a=expr b=expr {s=""+a+"\\setminus "+b+"";})
	|#(SETMULT a=expr b=expr {s=""+a+"\\times "+b+"";})
	|#(SETUNION a=expr b=expr {s=""+a+"\\cup "+b+"";})
	|#(SETINTERSECT a=expr b=expr {s=""+a+"\\cap "+b+"";})
	|#(ASSIGN a=expr b=expr {s=""+a+":="+b+"";})
	|#(NOT a=expr {s="\\not "+a+"";})
	|#(AND a=expr b=expr {s=""+a+"\\wedge "+b+"";})
	|#(OR a=expr b=expr {s=""+a+"\\vee "+b+"";})
	|#(IMPLY a=expr b=expr {s=""+a+"\\RightArrow "+b+"";})
	|#(RIMPLY a=expr b=expr {s=""+a+"\\LeftArrow "+b+"";})
	|#(IFF a=expr b=expr {s=""+a+"\\iff "+b+"";})
	|#(FORALL a=expr b=expr {s="\\forall "+a+": "+b+"";})
	|#(EXISTS a=expr b=expr {s="\\exists "+a+": "+b+"";})
	|#(LIM a=expr b=expr c=expr (d=expr)? {if (d=="") d="\\to "; s="\\lim _{"+a+""+d+""+b+"}{"+c+"}";})
	|#(LIMSUP a=expr (b=expr)? {s="\\limsup _{"+b+"}{"+a+"}";})
	|#(LIMINF a=expr (b=expr)? {s="\\liminf _{"+b+"}{"+a+"}";})
	|#(SUP a=expr (b=expr)? {s="\\sup _{"+b+"}{"+a+"}";})
	|#(INF a=expr (b=expr)? {s="\\inf _{"+b+"}{"+a+"}";})
	|#(MAX a=expr (b=expr)? {s="\\max _{"+b+"}{"+a+"}";})
	|#(MIN a=expr (b=expr)? {s="\\min _{"+b+"}{"+a+"}";})
	|#(ARGMAX a=expr (b=expr)? {s="\\mathrm{argmax} _{"+b+"}{"+a+"}";})
	|#(ARGMIN a=expr (b=expr)? {s="\\mathrm{argmin} _{"+b+"}{"+a+"}";})
	| LEFT {s=std::string("\\nearrow ");}
	| RIGHT {s=std::string("\\searrow ");}
	| REAL {s=std::string("\\to ");}
	| COMPLEX {s=std::string("\\to ");}
	|#(v:VARIABLE {s=v->getText();})
	|#(n:NUMBER
		{
			s=n->getText();
/*			string::size_type pos=s.find('e');
			if (pos==string::npos)
				pos=s.find('E');
			if (pos!=string::npos)
			{
				s.replace(pos, 1, "\\cdot 10 ^{"); s="("+s+"})";
			}*/
		})
	|#(p:PARAMETER {s=p->getText();})
	|#(DOTS {s=std::string("\\dots ");})
	|#(FC_TRUE
	  {
	  	switch (lang)
		{
			case hu:
				s="igaz";
				break;
			case en:
				s="true";
				break;
			case ge:
				s="--true--";
				break;
			case fr:
				s="vrai";
				break;
			default:
				s="true";
				break;
		}
		s="\\mathrm{"+s+"}";
	  }
	  )
	|#(FC_FALSE
	  {
	  	switch (lang)
		{
			case hu:
				s="hamis";
				break;
			case en:
				s="false";
				break;
			case ge:
				s="--false--";
				break;
			case fr:
				s="faux";
				break;
			default:
				s="false";
				break;
		}
		s="\\mathrm{"+s+"}";
	  }
	  )
	|#(ALPHA {s=std::string("\\alpha ");})
	|#(BETA {s=std::string("\\beta ");})
	|#(GAMMA {s=std::string("\\gamma ");})
	|#(GAMMAG {s=std::string("\\Gamma ");})
	|#(DELTA {s=std::string("\\delta ");})
	|#(DELTAG {s=std::string("\\Delta ");})
	|#(EPSILON {s=std::string("\\varepsilon ");})
	|#(ZETA {s=std::string("\\zeta ");})
	|#(ETA {s=std::string("\\eta ");})
	|#(THETA {s=std::string("\\vartheta ");})
	|#(THETAG {s=std::string("\\Theta ");})
	|#(IOTA {s=std::string("\\iota ");})
	|#(KAPPA {s=std::string("\\kappa ");})
	|#(LAMBDA {s=std::string("\\lambda ");})
	|#(LAMBDAG {s=std::string("\\Lambda ");})
	|#(MU {s=std::string("\\mu ");})
	|#(NU {s=std::string("\\nu ");})
	|#(XI {s=std::string("\\xi ");})
	|#(XIG {s=std::string("\\Xi ");})
	|#(OMICRON {s=std::string("\\omicron ");})
	|#(PI {s=std::string("\\pi ");})
	|#(PIG {s=std::string("\\Pi ");})
	|#(RHO {s=std::string("\\varrho ");})
	|#(SIGMA {s=std::string("\\sigma ");})
	|#(SIGMAG {s=std::string("\\Sigma ");})
	|#(TAU {s=std::string("\\tau ");})
	|#(UPSILON {s=std::string("\\upsilon ");})
	|#(UPSILONG {s=std::string("\\Upsilon ");})
	|#(PHI {s=std::string("\\varphi ");})
	|#(PHIG {s=std::string("\\Phi ");})
	|#(CHI {s=std::string("\\chi ");})
	|#(PSI {s=std::string("\\psi ");})
	|#(PSIG {s=std::string("\\Psi ");})
	|#(OMEGA {s=std::string("\\omega ");})
	|#(OMEGAG {s=std::string("\\Omega ");})
	|#(UNKNOWN {s=std::string();})
	|#(NONE {s=std::string();})
	|#(INFTY {s=std::string("\\infty ");})
	|#(E {s=std::string("\\mathrm{e}");})
	|#(I {s=std::string("\\mathrm{i}");})
	| (NATURALNUMBERS {s=std::string("\\mathbb{N}");})
	| (PRIMES {s=std::string("\\mathbb{P}");})
	| (INTEGERS {s=std::string("\\mathbb{Z}");})
	| (RATIONALS {s=std::string("\\mathbb{Q}");})
	| (REALS {s=std::string("\\mathbb{R}");})
	| (COMPLEXES {s=std::string("\\mathbb{C}");})
	|#(ENUMERATION
		{s=std::string("");}
		(a=expr
			{
				s+=a;
				switch (enumStrategy)
				{
					case normal:
						s+=",   ";
						break;
					case matrixRow:
						s+=" &  ";
						break;
					case matrix:
						s+="\\cr ";
						break;
					default:
						throw std::exception();
				}
			})*
		{
			if (s!="")
				s.erase(s.length()-4);
		})
	|#(PAIR a=expr b=expr {if (b=="") s="\\partial "+a+""; else s="\\partial "+a+""+b+"";})
	|#(lparen:LPAREN a=expr
		{
			if (dynamicParentheses)
			{
				if (beautyParentheses)
					switch (#lparen->parenDepth)
					{
						case 1:
							s="\\left("+a+"\\right)";
						break;
						case 2:
							s="\\left["+a+"\\right]";
						break;
						default:
							s="\\left\\{"+a+"\\right\\}";
						break;
					}
				else
							s="\\left("+a+"\\right)";
			}
			else
			{
				if (beautyParentheses)
					switch (#lparen->parenDepth)
					{
						case 1:
							s="("+a+")";
						break;
						case 2:
							s="["+a+"]";
						break;
						default:
							s="\\{"+a+"\\}";
						break;
					}
				else
					s="("+a+")";
			}
		}

	)
	|#(LBRACKET a=expr {if (dynamicParentheses) s="\\left["+a+"\\right]"; else s="["+a+"]";})
	|#(VECTOR a=expr {if (dynamicParentheses) s="\\left["+a+"\\right]"; else s="["+a+"]";})
	|#(MATRIX
		{enumStrategy=matrix;}
		a=expr
		{enumStrategy=normal; s="\\pmatrix{"+a+"}";}
	  )
	|#(MATRIXROW
		{enumStrategy=matrixRow;}
		s=expr
		{enumStrategy=matrix;}
	  )
	|#(FUNCTION a=expr b=expr
		{
			s=""+a+"^{}{"+b+"}";
			lastWasFunction=true;
			locLastWasFunction=true;
		}
	  )
	|#(type:TYPEDEF s=expr {if (#type->getText().find("vector")!=std::string::npos) s="\\underline{"+s+"}";})
	|#(DECLARE a=expr b=expr {s="";})
	|#(LAMBDACONSTRUCT a=expr b=expr {s="";})
	|#(SIZEOF a=expr {if (dynamicParentheses) s="\\left|"+a+"\\right|"; else s="|"+a+"|";})
	|#(ABS a=expr {if (dynamicParentheses) s="\\left|"+a+"\\right|"; else s="|"+a+"|";})
	
	|s=func
	) {lastWasFunction=locLastWasFunction;}
	;

func returns [string s]
	{
		string a,b;
		const string exp="^{}";
	}
	:
	(#(SIN {s="\\sin ";/* std::cout << exp << std::endl;*/})
	|#(COS {s="\\cos ";})
	|#(SGN {s="\\mathrm{sgn} ";})
	|#(TAN
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s="\\tan ";
				break;
			case hu:
	  			s="\\mathrm{tg} ";
				break;
			default:
				s="\\tan ";
				break;
		}
	  })
	|#(SEC {s="\\sec ";})
	|#(COSEC
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s="\\csc ";
				break;
			case hu:
	  			s="\\mathrm{cosec} ";
				break;
			default:
				s="\\csc ";
				break;
		}
	  })
	|#(COT
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s="\\cot ";
				break;
			case hu:
	  			s="\\mathrm{ctg} ";
				break;
			default:
				s="\\cot ";
				break;
		}
	  })
	|#(SINH
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s="\\sinh ";
				break;
			case hu:
	  			s="\\mathrm{sh} ";
				break;
			default:
				s="\\sinh ";
				break;
		}
	  })
	|#(COSH
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s="\\cosh ";
				break;
			case hu:
	  			s="\\mathrm{ch} ";
				break;
			default:
				s="\\cosh ";
				break;
		}
	  })
	|#(TANH
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s="\\tanh ";
				break;
			case hu:
	  			s="\\mathrm{tgh} ";
				break;
			default:
				s="\\tanh ";
				break;
		}
	  })
	|#(SECH {s="\\sech ";})
	|#(COSECH
 	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s="\\csch ";
				break;
			case hu:
	  			s="\\mathrm{cosech} ";
				break;
			default:
				s="\\csch ";
				break;
		}
	  })
	|#(COTH
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s="\\coth ";
				break;
			case hu:
	  			s="\\mathrm{ctgh} ";
				break;
			default:
				s="\\coth ";
				break;
		}
	  })
	|#(ARCSIN {s="\\arcsin ";})
	|#(ARCCOS {s="\\arccos ";})
	|#(ARCTAN
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s="\\arctan ";
				break;
			case hu:
	  			s="\\mathrm{arctg} ";
				break;
			default:
				s="\\arctan ";
				break;
		}
	  })
	|#(ARCSEC {s="\\mathrm{arcsec} ";})
	|#(ARCCOSEC
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s="\\mathrm{arccsc} ";
				break;
			case hu:
	  			s="\\mathrm{arccosec} ";
				break;
			default:
				s="\\mathrm{arccsc} ";
				break;
		}
	  })
	|#(ARCCOT
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s="\\mathrm{arccot} ";
				break;
			case hu:
	  			s="\\mathrm{arcctg} ";
				break;
			default:
				s="\\mathrm{arccot} ";
				break;
		}
	  })
	|#(ARCSINH
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s="\\mathrm{arcsinh} ";
				break;
			case hu:
	  			s="\\mathrm{arcsh} ";
				break;
			default:
				s="\\mathrm{arcsinh} ";
				break;
		}
	  })
	|#(ARCCOSH
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s="\\mathrm{arccosh} ";
				break;
			case hu:
	  			s="\\mathrm{arcch} ";
				break;
			default:
				s="\\mathrm{arccosh} ";
				break;
		}
	  })
	|#(ARCTANH
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s="\\mathrm{arctanh} ";
				break;
			case hu:
	  			s="\\mathrm{arctgh} ";
				break;
			default:
				s="\\mathrm{arctanh} ";
				break;
		}
	  })
	|#(ARCSECH {s="\\mathrm{arcsech} ";})
	|#(ARCCOSECH
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s="\\mathrm{arccsch} ";
				break;
			case hu:
	  			s="\\mathrm{arccosech} ";
				break;
			default:
				s="\\mathrm{arccsch} ";
				break;
		}
	  })
	|#(ARCCOTH
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s="\\mathrm{arccoth} ";
				break;
			case hu:
	  			s="\\mathrm{arcctgh} ";
				break;
			default:
				s="\\mathrm{arccoth} ";
				break;
		}
	  })
	|#(ERF {s="\\mathrm{erf}";})
	|#(IM {s="\\Im ";})
	|#(RE {s="\\Re ";})
	|#(ARG {s="\\mathrm{arg} ";})
	|#(GCD
		{
			switch (lang)
			{
				case hu:
					s="\\mathrm{lnko}";
					break;
				default:
					s="\\gcd";
					break;
			}
		})
	|#(LCM
		{
			switch (lang)
			{
				case hu:
					s="\\mathrm{lkkt}";
					break;
				default:
					s="\\lcm";
					break;
			}
		})
	|#(CONJUGATE a=expr {s="\\overline{"+a+"}";})
	|#(TRANSPONATE a=expr {s=""+a+"^T";})
	|#(COMPLEMENTER a=expr {s="\\overline{"+a+"}";})
	|#(EXP a=expr {s="\\mathrm{e}^{"+a+"}";})
	|#(LN {s="\\ln ";})
	|#(LG {s="\\lg ";})
	|#(LOG {s="\\log";} (a=expr {s+="_{"+a+"}";})?)
	|#(ROOT (a=expr b=expr {s="\\sqrt["+a+"]{"+b+"}";})?)
	|#(SQRT a=expr {s="\\sqrt{"+a+"}";})
	|#(CEIL a=expr {s="\\lceil "+a+"\\rceil ";})
	|#(FLOOR a=expr {s="\\lfloor "+a+"\\rfloor ";})
	)
        {lastWasFunction=true;}
	;

