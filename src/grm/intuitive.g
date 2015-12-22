header{
#include <iostream>
#include <map>
#include <set>
#include <h/fcAST.h>
#include <h/misc.h>
#ifndef EXPR_TYPE
#define EXPR_TYPE
//typedef enum {set, number, function, logical, empty/*, relation*/, unknown} ExprType;
#endif
}

header "pre_include_cpp"{
#include "IntuitiveLexer.hpp"
}

options {
	language="Cpp";
}

/////TODO: start using DEGREE, lim, det, matrice, piecewise, dots...

/**
 * This file creates tokens (IntuitiveLexer), and an AST (IntuitiveParser) from an intuitive formula (~LaTeX, Mathematica, Maple, YACAS syntax), the output uses Intuitive AST format.
 * Generation depends on the following files:
 *
 * Compilation depends on the following files:
 * h/fcAST.h, h/misc.h
 * From this file the following files will be created:
 * IntuitiveLexer.cpp, IntuitiveLexer.hpp, IntuitiveParser.cpp, IntuitiveParser.hpp, IntuitiveTokenTypes.hpp, IntuitiveTokenTypes.txt
 * @author Gabor Bakos (baga@users.sourceforge.net)
 * @version: $Id: intuitive.g,v 1.38 2010/04/14 22:05:17 kovzol Exp $
 */


class IntuitiveLexer extends Lexer;
options
{
	k=9;
	caseSensitive=false;
	exportVocab=Intuitive;
	testLiterals=false;
	charVocabulary = '\3'..'\377';
	noConstructors = true;
	defaultErrorHandler=false;
}
{
	/**
	 * The language type. Just for internal use.
	 * This has role in number recognition.
	 */
	typedef enum languageType {DEFAULT, SIMPLE, AMERICAN, EUROPEAN} languageType;
	languageType langtype;
	Language lang;
	/**
	 * Defines whether i is variable or the imaginary i.
	 */
	bool isIVariable;

	/**
	 * Do you want to disallow some variable-name?
	 */
	bool restrictedLetters;
	std::set<std::string> allowedVariables;

	bool allowLongVars;
public:
	/**
	 * Adds a new letter to the acceptable variables.
	 * @param s A variable name.
	 */
	void addAllowedLetter(const std::string s)
	{
		restrictedLetters=true;
		allowedVariables.insert(s);
	}

	/**
	 * @param allowLongVariables With true value it will allow variable/parameter names to be more than one character long.
	 */
	void setLongVars(const bool allowLongVariables)
	{
		allowLongVars=allowLongVariables;
	}

	/**
	 * The constructor with std::istream
	 * @param in The input stream
	 */
	IntuitiveLexer(ANTLR_USE_NAMESPACE(std)istream& in)
	: ANTLR_USE_NAMESPACE(antlr)CharScanner(new ANTLR_USE_NAMESPACE(antlr)CharBuffer(in),false), langtype(DEFAULT), isIVariable(false), restrictedLetters(false)
	{
	}

	/**
	 * The constructor with antlr::InputBuffer
	 * @param ib The input buffer
	 */
	IntuitiveLexer(ANTLR_USE_NAMESPACE(antlr)InputBuffer& ib)
	: ANTLR_USE_NAMESPACE(antlr)CharScanner(ib,false), langtype(DEFAULT), isIVariable(false), restrictedLetters(false)
	{
	}

	/**
	 * The constructor with antlr::LexerSharedInputState
	 * @param state The input state
	 */
	IntuitiveLexer(const ANTLR_USE_NAMESPACE(antlr)LexerSharedInputState& state)
	: ANTLR_USE_NAMESPACE(antlr)CharScanner(state,false), langtype(DEFAULT), isIVariable(false), restrictedLetters(false)
	{
	}

	/**
	 * Sets isIVariable to ivar
	 * @param ivar This will be the value of isIVariable
	 */
	void setIsIVariable(bool ivar)
	{
		isIVariable = ivar;
	}

	/**
	 * Sets the inputs language type from the t variable
	 * @param t The input language of type Language.
	 */
	void setLanguage(Language t)
	{
		switch (t)
		{
			case en:
			case ge:
				langtype=AMERICAN;
				break;
			case hu:
			case fr:
				langtype=EUROPEAN;
				break;
			case simple:
				langtype=SIMPLE;
				break;
			case C:
			default:
				langtype=DEFAULT;
				break;
		}
		lang=t;
	}

private:
}

WS	:	(' '
	|	'\t'
	|	'\n'
	|	'\r'
	)
		{ _ttype = ANTLR_USE_NAMESPACE(antlr)Token::SKIP; }
	;

LPAREN	:	'('
	;

RPAREN	:	')'
	;

LBRACKET:	'['
	;

RBRACKET:	']'
	;

LBRACE	:	'{'
	;

RBRACE	:	'}'
	;

PLUS	:	'+'
	;

MINUS	:	'-'
	;

MUPADPM	:	{LA(1)=='s' && LA(2)=='y' && LA(3)=='m' && LA(4)=='b' && LA(5)=='o' && LA(6)=='l' && LA(7)==':' && LA(8)==':' && LA(9)=='p' && LA(10)=='l' && LA(11)=='u' && LA(12)=='s' && LA(13)=='m' && LA(14)=='n'}? "symbol::plusmn" {$setType(PM);}
	;

MULT	:	{LA(1) == '*' && LA(2) != '*'}? '*'
	;

DIV	:	'/'
	;

MOD	:	{LA(1)=='m' && LA(2)=='o' && LA(3)=='d'}? "mod"
	;

MODPOS	:	{LA(1)=='m' && LA(2)=='o' && LA(3)=='d' && LA(4)=='p'}? "modp"
	;

MODS	:	{LA(1)=='m' && LA(2)=='o' && LA(3)=='d' && LA(4)=='s'}? "mods"
	;

GCD	:	{LA(1)=='g' && LA(2)=='c' && LA(3)=='d'}? "gcd"
	;

LCM	:	{LA(1)=='l' && LA(2)=='c' && LA(3)=='m'}? "lcm"
	;

ASSIGN	:	":="
	;

COLON	:	':'
	;

EQUAL	:	('=' ('=')?)
	;

NEQ	:	"!="
	;

NEQPASCAL:	"<>" {$setType(NEQ);}
	;

FC_TRUE	:	{LA(1)=='t' && LA(2)=='r' && LA(3)=='u' && LA(4)=='e'}? "true"
	;

IGAZ	:	{lang==hu && LA(1)=='i' && LA(2)=='g' && LA(3)=='a' && LA(4)=='z'}? "igaz" {$setType(FC_TRUE);}
	;

VRAI	:	{lang==fr && LA(1)=='v' && LA(2)=='r' && LA(3)=='a' && LA(4)=='i'}? "vrai" {$setType(FC_TRUE);}
	;

FC_FALSE	:	{LA(1)=='f' && LA(2)=='a' && LA(3)=='l' && LA(4)=='s' && LA(5)=='e'}? "false"
	;

HAMIS	:	{lang==hu && LA(1)=='h' && LA(2)=='a' && LA(3)=='m' && LA(4)=='i' && LA(5)=='s'}? "hamis" {$setType(FC_FALSE);}
	;

FAUX	:	{lang==fr && LA(1)=='f' && LA(2)=='a' && LA(3)=='u' && LA(4)=='x'}? "faux" {$setType(FC_FALSE);}
	;

AND	:	{LA(1)=='a' && LA(2)=='n' && LA(3)=='d'}? "and"
	;

ES	:	{lang==hu && (LA(1)=='e' ) && LA(2)=='s'}? ('e') 's' {$setType(AND);}
	;

ET	:	{lang==fr && LA(1)=='e' && LA(2)=='t'}? "et" {$setType(AND);}
	;

ANDSIGN	:	('&' ('&')?) {$setType(AND);}
	;

OR	:	{LA(1)=='o' && LA(2)=='r'}? "or"
	;

VAGY	:	{lang==hu && LA(1)=='v' && LA(2)=='a' && LA(3)=='g' && LA(4)=='y'}? "vagy" {$setType(OR);}
	;

OU	:	{lang==fr && LA(1)=='o' && LA(2)=='u'}? "vagy" {$setType(OR);}
	;

ORSIGN	:	("||") {$setType(OR);}
	;

LESS	:	'<'
	;

LEQ	:	"<="
	;

GREATER	:	'>'
	;

GEQ	:	">="
	;

IMPLY	:	{LA(1)=='i' && LA(2)=='m' && LA(3)=='p' && LA(4)=='l' && LA(5)=='y'}? "imply"
	;

IMPLYSIGN:	("->" | "=>") {$setType(IMPLY);}
	;

RIMPLY	:	{LA(1)=='r' && LA(2)=='i' && LA(3)=='m' && LA(4)=='p' && LA(5)=='l' && LA(6)=='y'}? "rimply"
	;

/*RIMPLYSIGN:	("<-") {$setType(RIMPLY);}
	;
*/
IFF	:	{LA(1)=='i' && LA(2)=='f' && LA(3)=='f'}?  "iff"
	;

IFFSIGN	:	("<->" | "<=>") {$setType(IFF);}
	;

SETIN	:	{LA(1)=='i' && LA(2)=='n'}? "in"
	;

SETNI	:	{LA(1)=='n' && LA(2)=='i'}? "ni"
	;

SETUNION:	{LA(1)=='u' && LA(2)=='n' && LA(3)=='i' && LA(4)=='o' && LA(5)=='n'}? "union"
	;

SETINTERSECT:	{LA(1)=='i' && LA(2)=='n' && LA(3)=='t' && LA(4)=='e' && LA(5)=='r' && LA(6)=='s' && LA(7)=='e' && LA(8)=='c' && LA(9)=='t'}? "intersect"
	;

//SETMULT	:	'\u2A09'
//	;

NOT	:	{LA(1)=='n' && LA(2)=='o' && LA(3)=='t'}? "not"
	;

NEM	:	{LA(1)=='n' && LA(2)=='e' && LA(3)=='m'}? "nem" {$setType(NOT);}
	;

NON	:	{lang==fr && LA(1)=='n' && LA(2)=='o' && LA(3)=='n'}? "non" {$setType(NOT);}
	;

FORALL	:	{LA(1)=='f' && LA(2)=='o' && LA(3)=='r' && LA(4)=='a' && LA(5)=='l' && LA(6)=='l'}? "forall"
	;

MINDEN	:	{LA(1)=='m' && LA(2)=='i' && LA(3)=='n' && LA(4)=='d' && LA(5)=='e' && LA(6)=='n'}? "minden" {$setType(FORALL);}
	;

EXISTS	:	{LA(1)=='e' && LA(2)=='x' && LA(3)=='i' && LA(4)=='s' && LA(5)=='t' && LA(6)=='s'}? "exists"
	;

LETEZIK	:	{lang==hu && LA(1)=='l' && (LA(2)=='e') && LA(3)=='t' && LA(4)=='e' && LA(5)=='z' && LA(6)=='i' && LA(7)=='k'}? ("letezik") {$setType(EXISTS);}
	;

MATRIX	:	{LA(1)=='m' && LA(2)=='a' && LA(3)=='t' && LA(4)=='r' && LA(5)=='i' && LA(6)=='x'}? "matrix";

protected
COMMA	:	','
	;

CCOMMA	:	{LA(1)==',' && ((LA(2)!='0' && LA(2)!='1' && LA(2)!='2' && LA(2)!='3' && LA(2)!='4' && LA(2)!='5' && LA(2)!='6' && LA(2)!='7' && LA(2)!='8' && LA(2)!='9') | langtype!=EUROPEAN)}? ','
	;

protected
DOT	:	'.'
	;

CIRCUM	:	{(LA(1) == '^' && LA(2) != '^') || (LA(1) == '*' && LA(2) == '*')}? ('^' | "**")
	;

MATRIXPRODUCT_DOT:	{LA(1) == '.' && LA(2)<'0' || LA(2)>'9' && LA(2) != '.'}? DOT
	;

MATRIXEXPONENTIATION	:	{LA(1) == '^' && LA(2)=='^'}? "^^"
	;

ABSSIGN	:	'|'
	;

protected
DIGIT	:	'0'..'9'
	;

NUMBER	:	(DOT DOT DOT)=>(DOT DOT DOT) {$setType(DOTS);}
	|	{LA(1)=='.' && LA(2)=='.'}? (DOT DOT) {$setType(INTERVAL);}
	|	{langtype==AMERICAN}? (
			(DIGIT DIGIT DIGIT (',' DIGIT DIGIT DIGIT)+) => (DIGIT DIGIT DIGIT (','! DIGIT DIGIT DIGIT)+ ((DOT DIGIT)=>DOT ((DIGIT DIGIT DIGIT ',')=> ((DIGIT DIGIT DIGIT (','!))+ DIGIT ((DIGIT DIGIT)=>(DIGIT DIGIT) | (DIGIT)=>DIGIT)?) | (DIGIT)+))?  (('e' ('+' | '-')? DIGIT)=>('e' ('+' | '-')? (DIGIT)+ |) )? )
		|	(DIGIT DIGIT (',' DIGIT DIGIT DIGIT)+) => (DIGIT DIGIT (','! DIGIT DIGIT DIGIT)+ ((DOT DIGIT)=>DOT ((DIGIT DIGIT DIGIT ',')=> ((DIGIT DIGIT DIGIT (','!))+ DIGIT ((DIGIT DIGIT)=>(DIGIT DIGIT) | (DIGIT)=>DIGIT)?) | (DIGIT)+))?  (('e' ('+' | '-')? DIGIT)=>('e' ('+' | '-')? (DIGIT)+ )?|) )
		|	(DIGIT (',' DIGIT DIGIT DIGIT)+) => ((DIGIT (','! DIGIT DIGIT DIGIT)+) ((DOT DIGIT)=>DOT ((DIGIT DIGIT DIGIT ' ')=> ((DIGIT DIGIT DIGIT (','!))+ DIGIT ((DIGIT DIGIT)=>(DIGIT DIGIT) | (DIGIT)=>DIGIT)?) | (DIGIT)+))?  (('e' ('+' | '-')? DIGIT)=>('e' ('+' | '-')? (DIGIT)+|) )? )
		|	((DIGIT)+ ((DOT DIGIT)=>DOT ((DIGIT DIGIT DIGIT ',')=> ((DIGIT DIGIT DIGIT (','!))+ DIGIT ((DIGIT DIGIT)=>(DIGIT DIGIT) | (DIGIT)=>DIGIT)?) | (DIGIT)+))?  (('e' ('+' | '-')? DIGIT)=>('e' ('+' | '-')? (DIGIT)+ )?|) )
		|	(DOT DIGIT)=>(DOT ((DIGIT DIGIT DIGIT ',')=> ((DIGIT DIGIT DIGIT (','!))+ DIGIT ((DIGIT DIGIT)=>(DIGIT DIGIT) | (DIGIT)=>DIGIT)?) | (DIGIT)+) (("e" ("+" | "-")? DIGIT)=>(( 'e' ('+' | '-')? (DIGIT)+ )|))? )
		)
	|	{langtype==DEFAULT}? (((DIGIT)+ ((',' | DOT) (DIGIT)+)? ('e' ('+' | '-')? (DIGIT)+ )? ) | ((',' | DOT) (DIGIT)+)  (('e' ('+' | '-')? DIGIT)=>('e' ('+' | '-')? (DIGIT)+ )? |))
	|	{langtype==SIMPLE}? (((DIGIT)+ (DOT (DIGIT)+)? ('e' ('+' | '-')? (DIGIT)+ )? ) | (DOT (DIGIT)+)  (('e' ('+' | '-')? DIGIT)=>('e' ('+' | '-')? (DIGIT)+ )?|) )
	|	{langtype==EUROPEAN}? (//options {greedy=true;}:
			(DIGIT DIGIT DIGIT (' ' DIGIT DIGIT DIGIT)+) => (DIGIT DIGIT DIGIT (' '! DIGIT DIGIT DIGIT)+ (((',' | DOT) DIGIT)=>(','! {$append(".");}|DOT) ((DIGIT DIGIT DIGIT ' ')=> ((DIGIT DIGIT DIGIT (' '!))+ DIGIT ((DIGIT DIGIT)=>(DIGIT DIGIT) | (DIGIT)=>DIGIT)?) | (DIGIT)+))? (('e' ('+' | '-')? DIGIT)=>('e' ('+' | '-')? (DIGIT)+ )?|) )
		|	(DIGIT DIGIT (' ' DIGIT DIGIT DIGIT)+) => (DIGIT DIGIT (' '! DIGIT DIGIT DIGIT)+ (((',' | DOT) DIGIT)=>(','! {$append(".");}|DOT) ((DIGIT DIGIT DIGIT ' ')=> ((DIGIT DIGIT DIGIT (' '!))+ DIGIT ((DIGIT DIGIT)=>(DIGIT DIGIT) | (DIGIT)=>DIGIT)?) | (DIGIT)+))?  (('e' ('+' | '-')? DIGIT)=>('e' ('+' | '-')? (DIGIT)+ )?|) )
		|	(DIGIT (' ' DIGIT DIGIT DIGIT)+) => ((DIGIT (' '! DIGIT DIGIT DIGIT)+) (((',' | DOT) DIGIT)=>(','! {$append(".");}|DOT) ((DIGIT DIGIT DIGIT ' ')=> ((DIGIT DIGIT DIGIT (' '!))+ DIGIT ((DIGIT DIGIT)=>(DIGIT DIGIT) | (DIGIT)=>DIGIT)?) | (DIGIT)+))?  (('e' ('+' | '-')? DIGIT)=>('e' ('+' | '-')? (DIGIT)+ )?|) )
		|	((DIGIT)+ (((',' | DOT) DIGIT)=>(','! {$append(".");}|DOT) ((DIGIT DIGIT DIGIT ' ')=> ((DIGIT DIGIT DIGIT (' '!))+ DIGIT ((DIGIT DIGIT)=>(DIGIT DIGIT) | (DIGIT)=>DIGIT)?) | (DIGIT)+))? (('e' ('+' | '-')? DIGIT)=>('e' ('+' | '-')? (DIGIT)+ )?|) )
		|	((',' | DOT) DIGIT)=>((',' {$setText(".")} | DOT) ((DIGIT DIGIT DIGIT ' ')=> ((DIGIT DIGIT DIGIT (' '!))+ DIGIT ((DIGIT DIGIT)=>(DIGIT DIGIT) | (DIGIT)=>DIGIT)?) | (DIGIT)+) /*(options {greedy=true;}: /*(DIGIT DIGIT DIGIT (' '!)?))* DIGIT ((DIGIT DIGIT)=>(DIGIT DIGIT) | (DIGIT)=>DIGIT | )*/ (("e" ("+" | "-")? DIGIT)=>(( 'e' ('+' | '-')? (DIGIT)+ )|))? )
		)
	;

protected
BACKSLASH	:	'\\'
	;

UNDERSCORE	:	'_'
	;

DFACTORIAL	:	"!!"
	;

FACTORIAL	:	'!'
	;

DERIVEX	:	'\''
	;

LATEXKEYWORD:	BACKSLASH
		(	("sgn")=>SGN {$setType(SGN);}
		|	("sin")=>SIN {$setType(SIN);}
		|	("cos")=>COS {$setType(COS);}
		|	("tan")=>TAN {$setType(TAN);}
		|	("tg")=>TG {$setType(TG);}
		|	("sec")=>SEC {$setType(SEC);}
		|	("cosec")=>COSEC {$setType(COSEC);}
		|	("csc")=>CSC {$setType(CSC);}
		|	("cot")=>COT {$setType(COT);}
		|	("ctg")=>CTG {$setType(CTG);}
		|	("sinh")=>SINH {$setType(SINH);}
		|	("sh")=>SH {$setType(SH);}
		|	("cosh")=>COSH {$setType(COSH);}
		|	("ch")=>CH {$setType(CH);}
		|	("tanh")=>TANH {$setType(TANH);}
		|	("tgh")=>TGH {$setType(TGH);}
		|	("sech")=>SECH {$setType(SECH);}
		|	("cosech")=>COSECH {$setType(COSECH);}
		|	("csch")=>CSCH {$setType(CSCH);}
		|	("coth")=>COTH {$setType(COTH);}
		|	("ctgh")=>CTGH {$setType(CTGH);}
		|	("arcsin")=>ARCSIN {$setType(ARCSIN);}
		|	("arccos")=>ARCCOS {$setType(ARCCOS);}
		|	("arctan")=>ARCTAN {$setType(ARCTAN);}
		|	("arctg")=>ARCTG {$setType(ARCTG);}
		|	("arcsec")=>ARCSEC {$setType(ARCSEC);}
		|	("arccosec")=>ARCCOSEC {$setType(ARCCOSEC);}
		|	("arccsc")=>ARCCSC {$setType(ARCCSC);}
		|	("arccot")=>ARCCOT {$setType(ARCCOT);}
		|	("arcctg")=>ARCCTG {$setType(ARCCTG);}
		|	("arcsinh")=>ARCSINH {$setType(ARCSINH);}
		|	("arcsh")=>ARCSH {$setType(ARCSH);}
		|	("arccosh")=>ARCCOSH {$setType(ARCCOSH);}
		|	("arcch")=>ARCCH {$setType(ARCCH);}
		|	("arctanh")=>ARCTANH {$setType(ARCTANH);}
		|	("arctgh")=>ARCTGH {$setType(ARCTGH);}
		|	("arcsech")=>ARCSECH {$setType(ARCSECH);}
		|	("arccosech")=>ARCCOSECH {$setType(ARCCOSECH);}
		|	("arccsch")=>ARCCSCH {$setType(ARCCSCH);}
		|	("arccoth")=>ARCCOTH {$setType(ARCCOTH);}
		|	("arcctgh")=>ARCCTGH {$setType(ARCCTGH);}
		|	("asin")=>ASIN {$setType(ASIN);}
		|	("acos")=>ACOS {$setType(ACOS);}
		|	("atan")=>ATAN {$setType(ATAN);}
		|	("atg")=>ATG {$setType(ATG);}
		|	("asec")=>ASEC {$setType(ASEC);}
		|	("acosec")=>ACOSEC {$setType(ACOSEC);}
		|	("acsc")=>ACSC {$setType(ACSC);}
		|	("acot")=>ACOT {$setType(ACOT);}
		|	("actg")=>ACTG {$setType(ACTG);}
		|	("asinh")=>ASINH {$setType(ASINH);}
		|	("ash")=>ASH {$setType(ASH);}
		|	("acosh")=>ACOSH {$setType(ACOSH);}
		|	("ach")=>ACH {$setType(ACH);}
		|	("atanh")=>ATANH {$setType(ATANH);}
		|	("atgh")=>ATGH {$setType(ATGH);}
		|	("asech")=>ASECH {$setType(ASECH);}
		|	("acosech")=>ACOSECH {$setType(ACOSECH);}
		|	("acsch")=>ACSCH {$setType(ACSCH);}
		|	("acoth")=>ACOTH {$setType(ACOTH);}
		|	("actgh")=>ACTGH {$setType(ACTGH);}
		|	("alpha")=>"alpha" {$setType(ALPHA);}
		|	("beta")=>"beta" {$setType(BETA);}
		|	("gamma")=>"gamma" {if ($getText[1]=='G') $setType(GAMMAG); else $setType(GAMMA);}
		|	("delta")=>"delta" {if ($getText[1]=='D') $setType(DELTAG); else $setType(DELTA);}
		|	("epsilon")=>"epsilon" {$setType(EPSILON);}
		|	("varepsilon")=>"varepsilon" {$setType(EPSILON);} //
		|	("zeta")=>"zeta" {$setType(ZETA);}
		|	("eta")=>"eta" {$setType(ETA);}
		|	("theta")=>"theta" {if ($getText[1]=='T') $setType(THETAG); else $setType(THETA);} //
		|	("vartheta")=>"vartheta" {$setType(THETA);}
		|	("iota")=>"iota" {$setType(IOTA);}
		|	("kappa")=>"kappa" {$setType(KAPPA);}
		|	("lambda")=>"lambda" {if ($getText[1]=='L') $setType(LAMBDAG); else $setType(LAMBDA);}
		|	("mu")=>"mu" {$setType(MU);}
		|	("nu")=>"nu" {$setType(NU);}
		|	("xi")=>"xi" {if ($getText[1]=='X') $setType(XIG); else $setType(XI);}
		|	("omicron")=>"omicron" {$setType(OMICRON);}
		|	("pi")=>"pi" {if ($getText[1]=='P') $setType(PIG); else $setType(PI); } //
		|	("varpi")=>"varpi" {$setType(PI);}
		|	("rho")=>"rho" {$setType(RHO);}
		|	("varrho")=>"varrho" {$setType(RHO);} //
		|	("sigma")=>"sigma" {if ($getText[1]=='S') $setType(SIGMAG); else $setType(SIGMA);}
		|	("varsigma")=>"varsigma" {$setType(SIGMA);}
		|	("tau")=>"tau" {$setType(TAU);}
		|	("upsilon")=>"upsilon" {if ($getText[1]=='U') $setType(UPSILONG); else $setType(UPSILON);}
		|	("phi")=>"phi" {if ($getText[1]=='P') $setType(PHIG); else $setType(PHI);}
		|	("varphi")=>"varphi" {$setType(PHI);} //
		|	("chi")=>"chi" {$setType(CHI);}
		|	("psi")=>"psi" {if ($getText[1]=='P') $setType(PSIG); else $setType(PSI);}
		|	("omega")=>"omega" {if ($getText[1]=='O') $setType(OMEGAG); else $setType(OMEGA);}
		|	("lceil")=>"lceil" {$setType(LCEIL);}
		|	("rceil")=>"rceil" {$setType(RCEIL);}
		|	("lfloor")=>"lfloor" {$setType(LFLOOR);}
		|	("rfloor")=>"rfloor" {$setType(RFLOOR);}
		|	("frac")=>"frac" {$setType(FRAC);}
		|	("dfrac")=>"dfrac" {$setType(FRAC);}
		|	("mathrm")=>"mathrm" {$setType(MATHRM);}
		|	("mathbb")=>"mathbb" {$setType(MATHBB);}
		|	("sqrt")=>SQRT {$setType(TEXSQRT);}
		|	("infty")=>"infty" {$setType(INFTY);}
		|	("log")=>LOG {$setType(LOG);}
		|	("lg")=>LG {$setType(LG);}
		|	("ln")=>LN {$setType(LN);}
		|	("partial")=>"partial" {$setType(PARTIAL);}
		|	("dot")=>"dot" {$setType(DERIVET);}
		|	("ddot")=>"ddot" {$setType(DDERIVET);}
		|	("dots")=>"dots" {$setType(DOTS);}
		|	("int")=>"int" {$setType(TEXINT);}
		|	("sum")=>"sum" {$setType(TEXSUM);}
		|	("prod")=>"prod" {$setType(TEXPROD);}
		|	("pm")=>"pm" {$setType(PM);}
		|	("mp")=>"mp" {$setType(MP);}
		|	("re")=>"re" {$setType(RE);}
		|	("im")=>"im" {$setType(IM);}
		|	("wedge")=>"wedge" {$setType(AND);}
		|	("land")=>"land" {$setType(AND);}
		|	("vee")=>"vee" {$setType(OR);}
		|	("lor")=>"lor" {$setType(OR);}
		|	("neq")=>"neq" {$setType(NEQ);}
		|	("leq")=>"leq" {$setType(LEQ);}
		|	("le")=>"le" {$setType(LEQ);}
		|	("nless")=>"nless" {$setType(NOTLESS);}
		|	("lneq")=>"lneq" {$setType(LESSNOTEQ);}
		|	("nleq")=>"nleq" {$setType(NOTLEQ);}
		|	("ngtr")=>"ngtr" {$setType(NOTGREATER);}
		|	("gneq")=>"gneq" {$setType(GREATERNOTEQ);}
		|	("ngeq")=>"ngeq" {$setType(NOTGEQ);}
		|	("geq")=>"geq" {$setType(GEQ);}
		|	("ge")=>"ge" {$setType(GEQ);}
		|	("times")=>"times" {$setType(SETMULT);}
		|	("setminus")=>"setminus" {$setType(SETMINUS);}
		|	("in")=>"in" {$setType(SETIN);}
		|	("ni")=>"ni" {$setType(SETNI);}
		|	("owns")=>"owns" {$setType(SETNI);}
		|	("cup")=>"cup" {$setType(SETUNION);}
		|	("cap")=>"cap" {$setType(SETINTERSECT);}
		|	("subset")=>"subset" {$setType(SETSUBSET);}
		|	("subseteq")=>"subseteq" {$setType(SETSUBSETEQ);}
		|	("nsubseteq")=>"nsubseteq" {$setType(SETNOTSUBSETEQ);}
		|	("subsetneq")=>"subsetneq" {$setType(SETSUBSETNEQ);}
		|	("supset")=>"supset" {$setType(SETSUPSET);}
		|	("supseteq")=>"supseteq" {$setType(SETSUPSETEQ);}
		|	("nsupseteq")=>"nsupseteq" {$setType(SETNOTSUPSETEQ);}
		|	("supsetneq")=>"supsetneq" {$setType(SETSUPSETNEQ);}
		|	("rightarrow")=>"rightarrow" {$setType(IMPLY);}
		|	("leftarrow")=>"leftarrow" {$setType(RIMPLY);}
		|	("leftrightarrow")=>"leftrightarrow" {$setType(IFF);}
		|	("iff")=>"iff" {$setType(IFF);}
		|	("neg")=>"neg" {$setType(NOT);}
		|	("lnot")=>"lnot" {$setType(NOT);}
		|	("forall")=>"forall" {$setType(FORALL);}
		|	("exists")=>"exists" {$setType(EXISTS);}
		|	("overline")=>"overline" {$setType(TEXOVERLINE);}
		|	("circ")=>"circ" {$setType(FUNCMULT);}
		|	("lim")=>"lim" {$setType(TEXLIM);}
		|	("liminf")=>"liminf" {$setType(TEXLIMINF);}
		|	("limsup")=>"limsup" {$setType(TEXLIMSUP);}
		|	("inf")=>"inf" {$setType(TEXINF);}
		|	("sup")=>"sup" {$setType(TEXSUP);}
		|	("min")=>"min" {$setType(TEXMIN);}
		|	("max")=>"max" {$setType(TEXMAX);}
		|	("argmin")=>"argmin" {$setType(ARGMIN);}
		|	("argmax")=>"argmax" {$setType(ARGMAX);}
		|	("to")=>"to" {$setType(REAL);}
		|	("searrow")=>"searrow" {$setType(RIGHT);}
		|	("nearrow")=>"nearrow" {$setType(LEFT);}
		|	("left" DOT)=>("left" DOT {$setType(TEXLEFTDOT);})
		|	("left")=>"left" {$setType(TEXLEFT);}
		|	("right" DOT)=>("right" DOT {$setType(TEXRIGHTDOT);})
		|	("right")=>"right" {$setType(TEXRIGHT);}
		|	("factorof")=>"factorof" {$setType(TEXFACTOROF);}
		|	("pmod")=>"pmod" {$setType(TEXPMOD);}
		|	("bmod")=>"bmod" {$setType(TEXBMOD);}
		|	("equiv")=>"equiv" {$setType(TEXEQUIV);}
		|	("pmatrix")=>"pmatrix" {$setType(TEXPMATRIX);}
		|	("cr")=>"cr" {$setType(TEXCR);}
		|	('{')=>'{' {$setType(LTEXSET);}
		|	('}')=>'}' {$setType(RTEXSET);}
		|	('a'..'z')+
		|	{$setType(SETMINUS);}
		)
	;

ROOT:	{LA(1)=='r' && LA(2)=='o' && LA(3)=='o' && LA(4)=='t'}? "root"
	;

SURD:	{LA(1)=='s' && LA(2)=='u' && LA(3)=='r' && LA(4)=='d'}? "surd"
	;

INFTY: {LA(1)=='i' && LA(2)=='n' && LA(3)=='f' && LA(4)=='i' && LA(5)=='n' && LA(6)=='i' && LA(7)=='t' && LA(8)=='y'}? "infinity"
	;

SGN: {LA(1)=='s' && LA(2)=='g' && LA(3)=='n'}? "sgn"
	;

SIN: {LA(1)=='s' && LA(2)=='i' && LA(3)=='n'}? "sin"
	;

COS: {LA(1)=='c' && LA(2)=='o' && LA(3)=='s'}? "cos"
	;

TAN:	{LA(1)=='t' && LA(2)=='a' && LA(3)=='n'}? "tan"
	;

TG:	{LA(1)=='t' && LA(2)=='g'}? "tg"
	;

SEC: {LA(1)=='s' && LA(2)=='e' && LA(3)=='c'}? "sec"
	;

COSEC: {LA(1)=='c' && LA(2)=='o' && LA(3)=='s' && LA(4)=='e' && LA(5)=='c'}? "cosec"
	;

CSC: {LA(1)=='c' && LA(2)=='s' && LA(3)=='c'}? "csc"
	;

COT:	{LA(1)=='c' && LA(2)=='o' && LA(3)=='t'}? "cot"
	;

CTG:	{LA(1)=='c' && LA(2)=='t' && LA(3)=='g'}? "ctg"
	;

SINH: {LA(1)=='s' && LA(2)=='i' && LA(3)=='n' && LA(4)=='h'}? "sinh"
	;

SH: {LA(1)=='s' && LA(2)=='h'}? "sh"
	;

COSH: {LA(1)=='c' && LA(2)=='o' && LA(3)=='s' && LA(4)=='h'}? "cosh"
	;

CH: {LA(1)=='c' && LA(2)=='h'}? "ch"
	;

TANH:	{LA(1)=='t' && LA(2)=='a' && LA(3)=='n' && LA(4)=='h'}? "tanh"
	;

TGH:	{LA(1)=='t' && LA(2)=='g' && LA(3)=='h'}? "tgh"
	;

SECH: {LA(1)=='s' && LA(2)=='e' && LA(3)=='c' && LA(4)=='h'}? "sech"
	;

COSECH: {LA(1)=='c' && LA(2)=='o' && LA(3)=='s' && LA(4)=='e' && LA(5)=='c' && LA(6)=='h'}? "cosech"
	;

CSCH: {LA(1)=='c' && LA(2)=='s' && LA(3)=='c' && LA(4)=='h'}? "csch"
	;

COTH:	{LA(1)=='c' && LA(2)=='o' && LA(3)=='t' && LA(4)=='h'}? "coth"
	;

CTGH:	{LA(1)=='c' && LA(2)=='t' && LA(3)=='g' && LA(4)=='h'}? "ctgh"
	;

ARCSIN: {LA(1)=='a' && LA(2)=='r' && LA(3)=='c' && LA(4)=='s' && LA(5)=='i' && LA(6)=='n'}? "arcsin"
	;

ASIN: {LA(1)=='a' && LA(2)=='s' && LA(3)=='i' && LA(4)=='n'}? "asin"
	;

ARCCOS: {LA(1)=='a' && LA(2)=='r' && LA(3)=='c' && LA(4)=='c' && LA(5)=='o' && LA(6)=='s'}? "arccos"
	;

ACOS: {LA(1)=='a' && LA(2)=='c' && LA(3)=='o' && LA(4)=='s'}? "acos"
	;

ARCTAN:	{LA(1)=='a' && LA(2)=='r' && LA(3)=='c' && LA(4)=='t' && LA(5)=='a' && LA(6)=='n'}? "arctan"
	;

ATAN: {LA(1)=='a' && LA(2)=='t' && LA(3)=='a' && LA(4)=='n'}? "atan"
	;

ARCTG:	{LA(1)=='a' && LA(2)=='r' && LA(3)=='c' && LA(4)=='t' && LA(5)=='g'}? "arctg"
	;

ATG: {LA(1)=='a' && LA(2)=='t' && LA(3)=='g'}? "atg"
	;

ARCSEC: {LA(1)=='a' && LA(2)=='r' && LA(3)=='c' && LA(4)=='s' && LA(5)=='e' && LA(6)=='c'}? "arcsec"
	;

ASEC: {LA(1)=='a' && LA(2)=='s' && LA(3)=='e' && LA(4)=='c'}? "asec"
	;

ARCCOSEC: {LA(1)=='a' && LA(2)=='r' && LA(3)=='c' && LA(4)=='c' && LA(5)=='o' && LA(6)=='s' && LA(7)=='e' && LA(8)=='c'}? "arccosec"
	;

ACOSEC: {LA(1)=='a' && LA(2)=='c' && LA(3)=='o' && LA(4)=='s' && LA(5)=='e' && LA(6)=='c'}? "acosec"
	;

ARCCSC: {LA(1)=='a' && LA(2)=='r' && LA(3)=='c' && LA(4)=='c' && LA(5)=='s' && LA(6)=='c'}? "arccsc"
	;

ACSC: {LA(1)=='a' && LA(2)=='c' && LA(3)=='s' && LA(4)=='c'}? "acsc"
	;

ARCCOT:	{LA(1)=='a' && LA(2)=='r' && LA(3)=='c' && LA(4)=='c' && LA(5)=='o' && LA(6)=='t'}? "arccot"
	;

ACOT: {LA(1)=='a' && LA(2)=='c' && LA(3)=='o' && LA(4)=='t'}? "acot"
	;

ARCCTG:	{LA(1)=='a' && LA(2)=='r' && LA(3)=='c' && LA(4)=='c' && LA(5)=='t' && LA(6)=='g'}? "arcctg"
	;

ACTG: {LA(1)=='a' && LA(2)=='c' && LA(3)=='t' && LA(4)=='g'}? "actg"
	;

ARCSINH: {LA(1)=='a' && LA(2)=='r' && LA(3)=='c' && LA(4)=='s' && LA(5)=='i' && LA(6)=='n' && LA(7)=='h'}? "arcsinh"
	;

ASINH: {LA(1)=='a' && LA(2)=='s' && LA(3)=='i' && LA(4)=='n' && LA(5)=='h'}? "asinh"
	;

ARCSH: {LA(1)=='a' && LA(2)=='r' && LA(3)=='c' && LA(4)=='s' && LA(5)=='h'}? "arcsh"
	;

ASH: {LA(1)=='a' && LA(2)=='s' && LA(3)=='h'}? "ash"
	;

ARCCOSH: {LA(1)=='a' && LA(2)=='r' && LA(3)=='c' && LA(4)=='c' && LA(5)=='o' && LA(6)=='s' && LA(7)=='h'}? "arccosh"
	;

ACOSH: {LA(1)=='a' && LA(2)=='c' && LA(3)=='o' && LA(4)=='s' && LA(5)=='h'}? "acosh"
	;

ARCCH: {LA(1)=='a' && LA(2)=='r' && LA(3)=='c' && LA(4)=='c' && LA(5)=='h'}? "arcch"
	;

ACH: {LA(1)=='a' && LA(2)=='c' && LA(3)=='h'}? "ach"
	;

ARCTANH:	{LA(1)=='a' && LA(2)=='r' && LA(3)=='c' && LA(4)=='t' && LA(5)=='a' && LA(6)=='n' && LA(7)=='h'}? "arctanh"
	;

ATANH: {LA(1)=='a' && LA(2)=='t' && LA(3)=='a' && LA(4)=='n' && LA(5)=='h'}? "atanh"
	;

ARCTGH:	{LA(1)=='a' && LA(2)=='r' && LA(3)=='c' && LA(4)=='t' && LA(5)=='g' && LA(6)=='h'}? "arctgh"
	;

ATGH: {LA(1)=='a' && LA(2)=='t' && LA(3)=='g' && LA(4)=='h'}? "atgh"
	;

ARCSECH: {LA(1)=='a' && LA(2)=='r' && LA(3)=='c' && LA(4)=='s' && LA(5)=='e' && LA(6)=='c' && LA(7)=='h'}? "arcsech"
	;

ASECH: {LA(1)=='a' && LA(2)=='s' && LA(3)=='e' && LA(4)=='c' && LA(5)=='h'}? "asech"
	;

ARCCOSECH: {LA(1)=='a' && LA(2)=='r' && LA(3)=='c' && LA(4)=='c' && LA(5)=='o' && LA(6)=='s' && LA(7)=='e' && LA(8)=='c' && LA(9)=='h'}? "arccosech"
	;

ACOSECH: {LA(1)=='a' && LA(2)=='c' && LA(3)=='o' && LA(4)=='s' && LA(5)=='e' && LA(6)=='c' && LA(7)=='h'}? "acosech"
	;

ARCCSCH: {LA(1)=='a' && LA(2)=='r' && LA(3)=='c' && LA(4)=='c' && LA(5)=='s' && LA(6)=='c' && LA(7)=='h'}? "arccsch"
	;

ACSCH: {LA(1)=='a' && LA(2)=='c' && LA(3)=='s' && LA(4)=='c' && LA(5)=='h'}? "acsch"
	;

ARCCOTH:	{LA(1)=='a' && LA(2)=='r' && LA(3)=='c' && LA(4)=='c' && LA(5)=='o' && LA(6)=='t' && LA(7)=='h'}? "arccoth"
	;

ACOTH: {LA(1)=='a' && LA(2)=='c' && LA(3)=='o' && LA(4)=='t' && LA(5)=='h'}? "acoth"
	;

ARCCTGH:	{LA(1)=='a' && LA(2)=='r' && LA(3)=='c' && LA(4)=='c' && LA(5)=='t' && LA(6)=='g' && LA(7)=='h'}? "arcctgh"
	;

ACTGH: {LA(1)=='a' && LA(2)=='c' && LA(3)=='t' && LA(4)=='g' && LA(5)=='h'}? "actgh"
	;

ERF:	{LA(1)=='e' && LA(2)=='r' && LA(3)=='f'}? "erf"
	;

ABS:	{LA(1)=='a' && LA(2)=='b' && LA(3)=='s'}? "abs"
	;

EXP:	{LA(1)=='e' && LA(2)=='x' && LA(3)=='p'}? "exp"
	;

LOG:	{LA(1)=='l' && LA(2)=='o' && LA(3)=='g'}? "log"
	;

LN:	{LA(1)=='l' && LA(2)=='n'}? "ln"
	;

LG:	{LA(1)=='l' && LA(2)=='g'}? "lg"
	;

SQRT:	{LA(1)=='s' && LA(2)=='q' && LA(3)=='r' && LA(4)=='t'}? "sqrt"
	;

RE:	{LA(1)=='r' && LA(2)=='e'}? "re"
	;

IM:	{LA(1)=='i' && LA(2)=='m'}? "im"
	;

ARG:	{LA(1)=='a' && LA(2)=='r' && LA(3)=='g'}? "arg"
	;

CONJ:	{LA(1)=='c' && LA(2)=='o' && LA(3)=='n' && LA(4)=='j'}? "conj" {$setType(CONJUGATE);}
	;

CONJUGATE:	{LA(1)=='c' && LA(2)=='o' && LA(3)=='n' && LA(4)=='j' && LA(5)=='u' && LA(6)=='g' && LA(7)=='a' && LA(8)=='t' && LA(9)=='e'}? "conjugate"
	;

COMPLEMENTER:	{LA(1)=='c' && LA(2)=='o' && LA(3)=='m' && LA(4)=='p' && LA(5)=='l' && LA(6)=='e' && LA(7)=='m' && LA(8)=='e' && LA(9)=='n' && LA(10)=='t' && LA(11)=='e' && LA(12)=='r'}? "complementer"
	;

TRANSPONATE:	{LA(1)=='t' && LA(2)=='r' && LA(3)=='a' && LA(4)=='n' && LA(5)=='s' && LA(6)=='p' && LA(7)=='o' && LA(8)=='n' && LA(9)=='a' && LA(10)=='t' && LA(11)=='e'}? "transponate"
	;

CEIL:	{LA(1)=='c' && LA(2)=='e' && LA(3)=='i' && LA(4)=='l'}? "ceil"
	;

FLOOR:	{LA(1)=='f' && LA(2)=='l' && LA(3)=='o' && LA(4)=='o' && LA(5)=='r'}? "floor"
	;

INT:	{LA(1)=='i' && LA(2)=='n' && LA(3)=='t'}? "int"
	;

DIFF:	{LA(1)=='d' && LA(2)=='i' && LA(3)=='f' && LA(4)=='f'}? "diff"
	;

D	:	{LA(1)=='d'}? "d" {if (allowedVariables.find("d") != allowedVariables.end()) $setType(PARAMETER);}
	;

SUM:	{LA(1)=='s' && LA(2)=='u' && LA(3)=='m'}? "sum"
	;

PROD:	{LA(1)=='p' && LA(2)=='r' && LA(3)=='o' && LA(4)=='d'}? "prod"
	;

LIM:	{LA(1)=='l' && LA(2)=='i' && LA(3)=='m'}? "lim"
	;

LIMIT:	{LA(1)=='l' && LA(2)=='i' && LA(3)=='m' && LA(4)=='i' && LA(5)=='t'}? "limit" {$setType(LIM);}
	;

LEFT:	{LA(1)=='l' && LA(2)=='e' && LA(3)=='f' && LA(4)=='t'}? "left"
	;

RIGHT:	{LA(1)=='r' && LA(2)=='i' && LA(3)=='g' && LA(4)=='h' && LA(5)=='t'}? "right"
	;

REAL:	{LA(1)=='r' && LA(2)=='e' && LA(3)=='a' && LA(4)=='l'}? "real"
	;

COMPLEX:	{LA(1)=='c' && LA(2)=='o' && LA(3)=='m' && LA(4)=='p' && LA(5)=='l' && LA(6)=='e' && LA(7)=='x'}? "complex"
	;

LIMINF:	{LA(1)=='l' && LA(2)=='i' && LA(3)=='m' && LA(4)=='i' && LA(5)=='n' && LA(6)=='f'}? "liminf"
	;

LIMSUP:	{LA(1)=='l' && LA(2)=='i' && LA(3)=='m' && LA(4)=='s' && LA(5)=='u' && LA(6)=='p'}? "liminf"
	;
INF:	{LA(1)=='i' && LA(2)=='n' && LA(3)=='f'}? "inf"
	;

SUP:	{LA(1)=='s' && LA(2)=='u' && LA(3)=='p'}? "sup"
	;

MIN:	{LA(1)=='m' && LA(2)=='i' && LA(3)=='n'}? "min"
	;

MAX:	{LA(1)=='m' && LA(2)=='a' && LA(3)=='x'}? "max"
	;

ARGMIN:	{LA(1)=='a' && LA(2)=='r' && LA(3)=='g' && LA(4)=='m' && LA(5)=='i' && LA(6)=='n'}? "argmin"
	;

ARGMAX:	{LA(1)=='a' && LA(2)=='r' && LA(3)=='g' && LA(4)=='m' && LA(5)=='a' && LA(6)=='x'}? "argmax"
	;

VARIABLE: {(LA(1)=='x') || LA(1)=='y' || LA(1)=='z' || LA(1)=='r' || LA(1)=='t'}? ('x'..'z' | 'r' | 't') {!restrictedLetters || allowedVariables.find($getText) != allowedVariables.end()}?
	;

E:	{LA(1)=='e'}? 'e'
	;

I:	{LA(1)=='i' && (!isIVariable)}? 'i'
	;

PI:	{LA(1)=='p' && LA(2)=='i'}? "pi"
	;

MAXIMA_CONSTANTS:
	'%'! ("e" {$setType(E);} | "i" {$setType(I);} | "pi" {$setType(PI);})
	;

PARAMETER
	:	(//options {greedy=true;}:
		( ('a'..'q'|'s'|'u'..'w') ({allowLongVars}?('a'..'z'|'0'..'9')*|))
		| ('\"'! ('a'..'z'|'_'|'0'..'9')+ '\"'!)) {!restrictedLetters || allowedVariables.find($getText) != allowedVariables.end()}? {}
	;

DOLLAR:	"$";


class IntuitiveParser extends Parser;

options {
	exportVocab=Intuitive;
	ASTLabelType = "RefFcAST"; // change default of "AST"
	buildAST=true;
	noConstructors = true;
	defaultErrorHandler = false;
}

tokens
{
	NEG;
	ENUMERATION;
	PAIR;
	INVISIBLETIMES;
	MATRIXPRODUCT;
	PM;
	MP;
//TODO handle and use the outputs and transform these nodes
	CONSTRUCT; //TODO change the creation of some constructs in intuitive.g
	DECLARE;
	LAMBDACONSTRUCT;
	CONDITION;
	TYPEDEF; //TODO use in intuitive.g too
	FACTOROF;
	MODP;
	REM;
	EQUIV;
	CONGRUENT;
	CONSTGAMMA;
	INTEGERS;
	REALS;
	RATIONALS;
	NATURALNUMBERS;
	COMPLEXES;
	PRIMES;

	PARTIAL;
	DERIVET;
	DDERIVET;
	DERIVE;
	DEGREE;
	NTHDERIVE;
	NTHDERIVEX;
	FUNCTION;
	FUNCINVERSE;
	FUNCMULT;
	FUNCPLUS;
	INTERVAL;
	TEXINT;
	DEFINTEGRAL;
	INDEFINTEGRAL;
	DOTS;
	LCEIL;
	RCEIL;
	LFLOOR;
	RFLOOR;
	FRAC;
	MATHRM;
	MATHBB;
	TEXSQRT;
	TEXSUM;
	TEXPROD;
	TEXOVERLINE;
	TEXLIM;
	TEXLIMINF;
	TEXLIMSUP;
	TEXINF;
	TEXSUP;
	TEXMIN;
	TEXMAX;
	TEXARGMIN;
	TEXARGMAX;
	TEXLEFTDOT;
	TEXLEFT;
	TEXRIGHTDOT;
	TEXRIGHT;
	TEXFACTOROF;
	TEXPMOD;
	TEXBMOD;
	TEXEQUIV;
	TEXPMATRIX;
	TEXCR;
	TENDSTO;
	NOTLESS;
	LESSNOTEQ;
	NOTLEQ;
	NOTGREATER;
	GREATERNOTEQ;
	NOTGEQ;
	LTEXSET;
	RTEXSET;
	SETMINUS;
	SETPOW;
	SETMULT;
	SETGENERATED;
	SETSUBSET;
	SETSUBSETEQ;
	SETSUBSETNEQ;
	SETNOTSUBSETEQ;
	SETNOTSUBSET;
	SETSUPSET;
	SETSUPSETEQ;
	SETSUPSETNEQ;
	SETNOTSUPSETEQ;
	SET;
//	COMPLEMENTER;
	SIZEOF;
	VECTOR;
//	MATRIX;
	MATRIXROW;
//	TRANSPONATE;
	ALPHA;
	BETA;
	GAMMA;
	GAMMAG;
	DELTA;
	DELTAG;
	EPSILON;
	ZETA;
	ETA;
	THETA;
	THETAG;
	IOTA;
	KAPPA;
	LAMBDA;
	LAMBDAG;
	MU;
	NU;
	XI;
	XIG;
	OMICRON;
//	PI;
	PIG;
	RHO;
	SIGMA;
	SIGMAG;
	TAU;
	UPSILON;
	UPSILONG;
	PHI;
	PHIG;
	CHI;
	PSI;
	PSIG;
	OMEGA;
	OMEGAG;
	UNKNOWN;
	NONE;
}

{
	protected:
	/**
	 * This variable is responsible wheter i is a variable, or imaginary i.
	 */
	bool isIReallyVariable, isIPossiblyVariable;
	///This is responsible for knowing the depth of indexes.
	int depth;
	/**
	 * This is just for automatic setting isIVariable.
	 * If you don't need it, try to remove it and correct compilation errors.
	 */
	IntuitiveLexer *lexer;

	///Just for the Maple like use of clear variable
	bool noApostrophes;
	///This stands for wheter or not you want sum, prod, int, diff, ...
	bool allowComputingFunctions;
	///These variables will be treated as functions
	std::set<std::string> functionNames;
	///The variables used in the formula
	std::set<std::string> usedVariables;
	///The parameters used in the formula
	std::set<std::string> usedParameters;
	///These variables will be treated as logical variables
	std::set<std::string> logicalVariables;
	///These variables will be treated as set variables
	std::set<std::string> setVariables;

	/**
	 * Duplicates and returns the input AST
	 * @param ast The AST to duplicate
	 * @return The duplicated AST
	 */
	RefFcAST dupTree(const RefFcAST ast) //const
	{
		return RefFcAST(getASTFactory()->dupTree((antlr::RefAST)ast));
	}

	public:
	/**
	 * Adds the variable name to the list of variables treated as a function variable.
	 * @param s The name of the variable.
	 */
	void addFunctionName(const std::string s)
	{
		functionNames.insert(s);
	}

	/**
	 * Adds the variable name to the list of variables treated as a logical variable.
	 * @param s The name of the variable.
	 */
	void addLogicalVariable(const std::string s)
	{
		logicalVariables.insert(s);
	}

	/**
	 * Adds the variable name to the list of variables treated as a set variable.
	 * @param s The name of the variable.
	 */
	void addSetVariable(const std::string s)
	{
		setVariables.insert(s);
	}

	/**
	 * Gets the set of the used variables in the current formula.
	 * @return The set<std::string> of used variables.
	 */
	const std::set<std::string> &getUsedVariables() const
	{
		return usedVariables;
	}

	/**
	 * Sets wheter the user may use functions like diff, int, sum, prod.
	 * This is useful, if you want to create an interface for questions.
	 * @param allow The new value of allowComputingFunctions
	 */
	void setAllowComputingFunctions(const bool allow)
	{
		allowComputingFunctions=allow;
	}

	/**
	 * This sets some useful defaults.
	 */
	void init()
	{
		functionNames.insert("f");
		functionNames.insert("g");
		functionNames.insert("h");
		functionNames.insert("F");
		functionNames.insert("G");
		functionNames.insert("u");
		functionNames.insert("v");
		logicalVariables.insert("X");
		logicalVariables.insert("Y");
		logicalVariables.insert("Z");
		setVariables.insert("A");
		setVariables.insert("B");
		setVariables.insert("C");
		setVariables.insert("D");
	}
	private:
	/**
	 * Just for debug... This prints a label string and the roughType.
	 * @param s The label string (char *)
	 * @param t0 The roughType to print out.
	 */
/*	void deb(const char *s, const RoughType t0) const
	{
		puts(s);
		switch (t0) {
			case unknown: puts("unknown"); break;
			case number: puts("number"); break;
			case fc_set: puts("set"); break;
			case logical: puts("logical"); break;
			case function: puts("function"); break;
			case notset: puts("notset"); break;
			default: puts("nem tudom");
		}
	}
*/
	protected:
	/**
	 * Sets the isIVariable in the lexer. This is responsible for automatic recognition of the type of i.
	 * @param ivar The new value of isIVariable
	 */
	void setIsIVariable(const bool ivar = true)
	{
		lexer->setIsIVariable(ivar || isIReallyVariable);
		isIPossiblyVariable = ivar;
	}

	/**
	 * Changes every node's type and/or text int the tree, where the changing conditions met.
	 * If type==fromType, then change to toType.
	 * If the previous cond. met, and condStr!="" and text==condStr then changes the text to toStr
	 * @param ast The root of the AST.
	 * @param fromType The type condition.
	 * @param toType (optional) The result type
	 * @param toStr (optional) Changes the text to this
	 * @param condStr Changes iff the text of the node is condStr
	 */
	void changeAll(RefFcAST ast, const int fromType, int toType, const std::string &toStr="", const std::string &condStr="")
	{
		if (ast!=antlr::nullAST)
		{
			if (ast->getType()==fromType)
			{
				if (condStr!="")
				{
					if (condStr==ast->getText())
						ast->setText(toStr);
				}
				else if (toStr!="")
				{
					ast->setText(toStr);
				}
				ast->setType(toType);
			}
			if (ast->getFirstChild()!=antlr::nullAST)
				for (ast=ast->getFirstChild(); ast->getNextSibling()!=antlr::nullAST; ast=ast->getNextSibling())
				{
					changeAll(ast, fromType, toType, toStr, condStr);
				}
		}
	}
	public:
	/**
	 * The constructor for IntuitiveParser with TokenBuffer
	 * and k
	 * @param tokenBuf The initializer TokenBuffer
	 * @param k The look-ahead
	 */
	IntuitiveParser(ANTLR_USE_NAMESPACE(antlr)TokenBuffer& tokenBuf, int k)
	: ANTLR_USE_NAMESPACE(antlr)LLkParser(tokenBuf,k), isIReallyVariable(false), allowComputingFunctions(true)
	{
	}

	/**
	 * The constructor for IntuitiveParser with TokenBuffer
	 * @param tokenBuf The initializer TokenBuffer
	 */
	IntuitiveParser(ANTLR_USE_NAMESPACE(antlr)TokenBuffer& tokenBuf)
	: ANTLR_USE_NAMESPACE(antlr)LLkParser(tokenBuf,1), isIReallyVariable(false), allowComputingFunctions(true)
	{
	}

	/**
	 * The constructor for IntuitiveParser with TokenStream
	 * and k
	 * @param _lexer The initializer TokenStream (must be an IntuitiveLexer)
	 * @param k The look-ahead
	 */
	IntuitiveParser(ANTLR_USE_NAMESPACE(antlr)TokenStream& _lexer, int k)
	: ANTLR_USE_NAMESPACE(antlr)LLkParser(_lexer,k), isIReallyVariable(false), allowComputingFunctions(true)
	{
		lexer = dynamic_cast<IntuitiveLexer *>(&_lexer);
	}

	/**
	 * The constructor for IntuitiveParser with TokenStream
	 * @param _lexer The initializer TokenStream (must be an IntuitiveLexer)
	 */
	IntuitiveParser(ANTLR_USE_NAMESPACE(antlr)TokenStream& _lexer)
	: ANTLR_USE_NAMESPACE(antlr)LLkParser(_lexer,1), isIReallyVariable(false), allowComputingFunctions(true)
	{
		lexer = dynamic_cast<IntuitiveLexer *>(&_lexer);
	}

	/**
	 * The constructor for IntuitiveParser with ParserSharedInputState
	 * @param state The initializer ParserSharedInputState
	 */
	IntuitiveParser(const ANTLR_USE_NAMESPACE(antlr)ParserSharedInputState& state)
	: ANTLR_USE_NAMESPACE(antlr)LLkParser(state,1), isIReallyVariable(false), allowComputingFunctions(true)
	{
	}

}

expr	: {isIPossiblyVariable=false; depth=0; noApostrophes=false;} (logicExpr)? {if (isIReallyVariable) changeAll(#expr, I, VARIABLE, "i");} EOF!
	;

/*assignExpr
	:	addExpr
		(
			ASSIGN^
			assignExpr
		)?
	;
*/


//functionDef/* returns [ExprType t]*/ {ExprType t0, t1;}:	(t0=var COLON t0=setExpr {t0==fc_set || t0==unknown}? IMPLY t1=setExpr {t1==unknown || t1==fc_set}? CCOMMA (varList | LPAREN^ varList RPAREN!) IMPLY t1=addExpr)

//	;

//varList/* returns [ExprType t]*/ {ExprType t0, t1;}:	t0=var (CCOMMA t1=var)*
//	;

///Pascal like precedence
logicExpr	:	/*t0=*/logicEq (/*{t0==unknown || t0==logical}?*/ ((IMPLY^ /*t1=*/logicEq)
			|(RIMPLY^ /*t1=*/logicEq)
			|(IFF^ /*t1=*/logicEq)
//			|(NIMPLY^ logicEq)
//			|(NRIMPLY^ logicEq)
//			|(NIFF^ logicEq)
			)
			/*{t1==unknown || t1==logical}?*/ {#logicExpr->roughType=logical;})* /*{t=(t1==empty)?t0:logical;}*/
	;

logicEq	:	/*t0=*/logicOpAnd (/*{t0==unknown || t0==logical}?*/ (EQUAL^ /*t1=*/logicOpAnd)
			|(NEQ^ /*t1=*/logicOpAnd)
			/*{t1==unknown || t1==logical}?*/ {#logicEq->roughType=logical;})*
			/*{t=(t1==empty)?t0:t=logical;}*/
	;

logicOpAnd	:	/*t0=*/logicOpOr (/*{t0==unknown || t0==logical}?*/ AND^ /*t1=*/logicOpOr /*{t1==unknown || t1==logical}?*/ {#logicOpAnd->roughType=logical;})* /*{t=(t1==empty)?t0:logical;}*/
	;

logicOpOr	:	/*t0=*/negLogicValue (/*{t0==unknown || t0==logical}?*/ OR^ /*t1=*/negLogicValue /*{t1==unknown || t1==logical}?*/ {#logicOpOr->roughType=logical;})* /*{t=(t1==empty)?t0:logical;}*/
	;

negLogicValue	:	(NOT^ /*t0=*/negLogicValue /*{t0==unknown || t0==logical}?*/ {#negLogicValue->roughType=logical;})
	|	(FACTORIAL negLogicValue)=>(FACTORIAL /*t0=*/n:negLogicValue {#negLogicValue=#(#[NOT, "!"], #n);} /*{t0==unknown || t0==logical}?*/ {#negLogicValue->roughType=logical;})
	|	/*t0=*/logicValue //{t=t0;}
	;

logicValue	:	(logicConstant)=>(logicConstant /*{t=logical;}*/)
	|	/*t=*/setBooleanExpr {}
	;

setBooleanExpr	:
		  relExpr
		|(FORALL^ ((setBooleanExpr)=>/*t0=*/setBooleanExpr | /*t0=*/variable)  /*{t0==unknown || t0==logical}?*/ COLON! LPAREN^ /*t1=*/logicExpr RPAREN! /*{t1==unknown || t1==logical}?*/ /*{t=logical;}*/ {#setBooleanExpr->roughType=logical;})
		|(EXIST^ ((setBooleanExpr)=>/*t0=*/setBooleanExpr | /*t0=*/variable)  /*{t0==unknown || t0==logical}?*/ (COLON!)? LPAREN^ /*t1=*/logicExpr RPAREN! /*{t1==unknown || t1==logical}?*/ {#setBooleanExpr->roughType=logical;})
	;

relExpr	:	(/*t0=*/enumExpr (/*{t0==unknown || t0==fc_set || t0==logical || t0==number || t0==function}?*/ /*(EQUAL^ addExpr)
			|(NEQ^ addExpr)
			|*/((LESS^ /*t1=*/enumExpr)
			|(LEQ^ /*t1=*/enumExpr)
			|(NOTLESS^ /*t1=*/enumExpr)
			|(NLEQ^ /*t1=*/enumExpr)
			|(GREATER^ /*t1=*/enumExpr)
			|(GEQ^ /*t1=*/enumExpr)
			|(NOTGREATER^ /*t1=*/enumExpr)
			|(NGEQ^ /*t1=*/enumExpr)
			|(SETSUBSET^ /*t1=*/enumExpr)
			|(SETSUBSETEQ^ /*t1=*/enumExpr)
			|(SETSUBSETNEQ^ /*t1=*/enumExpr)
			|(SETNOTSUBSETEQ^ /*t1=*/enumExpr)
			|(SETSUPSET^ /*t1=*/enumExpr)
			|(SETSUPSETEQ^ /*t1=*/enumExpr)
			|(SETSUPSETNEQ^ /*t1=*/enumExpr)
			|(SETNOTSUPSETEQ^ /*t1=*/enumExpr)
			|(SETIN^ /*t1=*/enumExpr)
			|(SETNI^ /*t1=*/enumExpr)
			|(SETNOTIN^ /*t1=*/enumExpr)
			|(SETNOTNI^ /*t1=*/enumExpr)
			|(TEXEQUIV^ addExpr)
			|(TEXFACTOROF^ addExpr)
			)
//			|(EQUAL^ setExpr)
//			|(NEQ^ setExpr)
//			|(ABSSIGN^ t1=enumExpr)
			{#relExpr->roughType=logical;}
			)* //{t=(t1!=empty)?logical:t0;}
			(TEXPMOD^ texArg)?
		)
	;

logicConstant:	(FC_TRUE
	|	(MATHRM LBRACE FC_TRUE)=> (MATHRM! LBRACE! FC_TRUE RBRACE!)
	|	FC_FALSE
	|	MATHRM! LBRACE! FC_FALSE RBRACE!
	) {#logicConstant->roughType=logical;}
	;

addExpr{RoughType /*t=notset,*/ t0, t1=notset, sset=notset, fun=notset, un=notset;}:	(/*t0=*/p0:negMultExpr {t0=#p0->roughType;}/*{t0==unknown || t0==number || t0==function || t0==fc_set}?*/ {if (t0==function) fun=function; else if (t0==fc_set) sset=fc_set; else if (t0==unknown) un=unknown;}
			((PLUS^ /*t1=*/p1:negMultExpr {t1=#p1->roughType;} {if (t1==function) fun=function; else if (t1==fc_set) sset=fc_set; else if (t1==unknown) un=unknown;} /*{!(fun==function && sset==fc_set)}?*/)
			|(MINUS^ /*t1=*/p2:negMultExpr {t1=#p2->roughType;} {if (t1==function) fun=function; else if (t1==fc_set) sset=fc_set; else if (t1==unknown) un=unknown;} /*{!(fun==function && sset==fc_set)}?*/)
			|(SETINTERSECT^ /*t1=*/p3:negMultExpr {t1=#p3->roughType;} {if (t1==function) fun=function; else if (t1==fc_set) sset=fc_set; else if (t1==unknown) un=unknown;} /*{!(fun==function && sset==fc_set)}?*/)
			|(SETUNION^ /*t1=*/p4:negMultExpr {t1=#p4->roughType;} {if (t1==function) fun=function; else if (t1==fc_set) sset=fc_set; else if (t1==unknown) un=unknown;} /*{!(fun==function && sset==fc_set)}?*/)
			|(SETMINUS^ /*t1=*/p5:negMultExpr {t1=#p5->roughType;} {if (t1==function) fun=function; else if (t1==fc_set) sset=fc_set; else if (t1==unknown) un=unknown;} /*{!(fun==function && sset==fc_set)}?*/)
			|(PM^ /*t1=*/p6:negMultExpr {t1=#p6->roughType;} {if (t1==function) fun=function; else if (t1==fc_set) sset=fc_set; else if (t1==unknown) un=unknown;} /*{!(fun==function && sset==fc_set)}?*/)
			|(MP^ /*t1=*/p7:negMultExpr {t1=#p7->roughType;} {if (t1==function) fun=function; else if (t1==fc_set) sset=fc_set; else if (t1==unknown) un=unknown;} /*{!(fun==function && sset==fc_set)}?*/)
		{#addExpr->roughType=(un==unknown)?unknown:(fun==function)?function:(sset==fc_set)?fc_set:number;})*) //{t=(un==unknown)?unknown:(fun==function)?function:(sset==fc_set)?fc_set:number;}
	;

negMultExpr	: ((MINUS)=>(MINUS! /*t0=*/n:negMultExpr! {#negMultExpr=#(#[NEG,"-m"],#n);} {#negMultExpr->roughType=#n->roughType;})
	| (PM^ pm:negMultExpr {#negMultExpr->roughType=#pm->roughType;})
	| (MP^ mp:negMultExpr {#negMultExpr->roughType=#mp->roughType;})
	| (/*t0=*/multExpr /*{t0==unknown || t0==number || t0==function || t0==fc_set}?*/))//{t=t0;}
	;

multExpr{antlr::RefAST prev=antlr::nullAST; RoughType t0, t1=notset, un=notset/*, s=notset, fn=notset*/, last=notset;}:	(a:powExpr {prev=#a; /*last=t0; deb("atom0", t0);*/ t0=#a->roughType; last=t0;})/*{t0==unknown || t0==number || t0==function || t0==fc_set}?*/
		(options { generateAmbigWarnings=false;}:
			 (absAtom)=>(options {greedy=true;}: p:powExpr!
			 {;
			 t1=#p->roughType;
//			 deb("atom1",t1);
			 if (prev->getType()==NUMBER && #p->getType()==NUMBER)
			 {
			 	throw antlr::SemanticException("Multiplying two numbers, without the sign of multiplication.");
			 }
			 if (last==function && (#p->getType()==LPAREN || #p->getType()==LBRACKET))
			 {
			 	if (#multExpr==prev)
					#multExpr=#(#[FUNCTION, "userFunction"], #multExpr, #p);
				else
				{
					RefFcAST tmp=#(#[FUNCTION, "userFunction"], prev, #p);
					(#multExpr->getFirstChild())->setNextSibling(tmp);
				}
			 }
			 else
			 if (last==function && #p->getType()==CIRCUM && (#p->getFirstChild()->getType()==LPAREN || #p->getFirstChild()->getType()==LBRACKET))
			 {
				RefFcAST x=#p->getFirstChild(), y=x->getNextSibling();
				x->setNextSibling(antlr::nullAST);
				if (prev==#multExpr)
					#multExpr=#(#[CIRCUM, "^"], #(#[FUNCTION, "userFunction"], #multExpr, x), y);
				else
				{
					RefFcAST tmp=#(#[CIRCUM, "^"], #(#[FUNCTION, "userFunction"], prev, x), y);
					#multExpr->getFirstChild()->setNextSibling(tmp);
				}
			 }
			 else
			 {
				#multExpr=#(#[MULT, " "], #multExpr, #p);
			 }
			 prev=#p;
			 last=t1;
			 } {#multExpr->roughType=(un==unknown)?unknown:(last==function)?unknown:t1;})
			|(MULT^ p0:negPowExpr {t1=#p0->roughType;} {#multExpr->roughType=(un==unknown)?unknown:(last==function)?unknown:t1;})
			|(DIV^ p1:negPowExpr {t1=#p1->roughType;} {#multExpr->roughType=(un==unknown)?unknown:(last==function)?unknown:t1;})
			|(MATRIXPRODUCT_DOT^ pMat:negPowExpr {t1=#pMat->roughType;} {#multExpr->roughType=(un==unknown)?unknown:(last==function)?unknown:t1; #MATRIXPRODUCT_DOT->setType(MATRIXPRODUCT);})
			|(FUNCMULT^ p2:negPowExpr {t1=#p2->roughType;} {#multExpr->roughType=(un==unknown)?unknown:(last==function)?unknown:t1;})
			|(SETMULT^ p3:negPowExpr {t1=#p3->roughType;} {#multExpr->roughType=(un==unknown)?unknown:(last==function)?unknown:t1;})
			|((TEXBMOD^ | MODPOS^ | MODS^ | MOD^) p4:negPowExpr {t1=#p4->roughType;} {#multExpr->roughType=(un==unknown)?unknown:t1;})
		)* //{t=(t1==empty)?t0:(un==unknown)?unknown:(last==function)?unknown:t1;}
	;

negPowExpr	:	(/*(MINUS)=>*/(MINUS! /*t0=*/n:negPowExpr! {#negPowExpr=#(#[NEG,"-p"],#n);} {#negPowExpr->roughType=#n->roughType;})
	| (LBRACE! /*t0=*/addExpr RBRACE!)
	| (PM^ pm:negPowExpr {#negPowExpr->roughType=#pm->roughType;})
	| (MP^ mp:negPowExpr {#negPowExpr->roughType=#mp->roughType;})
	| (/*t0=*/powExpr)
	) //{t=t0;}
	;

powExpr{RoughType t0, t1=notset, t=notset;}:	(/*t0=*/e0:factorial /*{deb("powExpr", t0);}*/ /*{inputState->guessing==0 && (t0==unknown || t0==number || t0==function || t0==fc_set)}?*/ {t0=#e0->roughType; }
		((CIRCUM)=>(CIRCUM^ /*t1=*/e1:negPowExpr {t1=#e1->roughType;} /*{(t1==unknown || t1==fc_set || t1==number) && !(t0==function && t1==fc_set)}?*/
		{
			if (t0==function && #e1->getType()==NEG &&
				#e1->getFirstChild()->getType()==NUMBER &&
				#e1->getFirstChild()->getText()=="1")
			{
				#powExpr->setType(FUNCINVERSE);
				#powExpr->setText("^{}");
				#e0->setNextSibling(antlr::nullAST);
			}
			if (t0==function && #e1->getType()==LPAREN)
			{
				#powExpr->setType(NTHDERIVEX);
				#powExpr->setText("^{(n)}");
				#e0->setNextSibling(#e1->getFirstChild());
			}
			if (#e1->getType()==VARIABLE && #e1->getText()=="T")
			{
				#powExpr->setType(FUNCTION);
				#powExpr->setText("function");
				#powExpr->setFirstChild(#[TRANSPONATE, "^T"]);
				#powExpr->getFirstChild()->setNextSibling(#e0);
				#e0->setNextSibling(antlr::nullAST);
			}
			if (#e1->getType()==VARIABLE && #e1->getText()=="C")
			{
				#powExpr->setType(FUNCTION);
				#powExpr->setText("function");
				#powExpr->setFirstChild(#[COMPLEMENTER, "^C"]);
				#powExpr->getFirstChild()->setNextSibling(#e0);
				#e0->setNextSibling(antlr::nullAST);
			}
		} {if (t1==fc_set && t0==number) t=fc_set; else t=t0;})
		|(MATRIXEXPONENTIATION)=>(MATRIXEXPONENTIATION^ e2:negPowExpr {t=t0;})
		{#powExpr->roughType=t;}
		)?
		) //{t=t0;}
	;

factorial	:	(/*t0=*/a:absAtom
		( (FACTORIAL)=>/*{t0==unknown || t0==number}?*/ FACTORIAL^ {#factorial->roughType=#a->roughType;}
		| (DFACTORIAL)=>/*{t0==unknown || t0==number}?*/ DFACTORIAL^ {#factorial->roughType=#a->roughType;}
		| {!noApostrophes}? (DERIVEX)=>(/*{t0==unknown || t0==function || t0==number}?*/ (options { generateAmbigWarnings=false;}: DERIVEX^ {#factorial->roughType=function;})+)
		| {allowComputingFunctions}? (DERIVET)=>(/*{t0==unknown || t0==function || t0==number}?*/ (options { generateAmbigWarnings=false;}: DERIVET^ LBRACE! RBRACE! {#factorial->roughType=function;})+)
		| {allowComputingFunctions}? (DDERIVET)=>(/*{t0==unknown || t0==function || t0==number}?*/(options { generateAmbigWarnings=false;}: DDERIVET^ LBRACE! RBRACE! {#factorial->roughType=function;})+)
		{#factorial->roughType=#a->roughType;}
		)?
		) //{t=t0;}
	;

absAtom	:	(/*(ABSSIGN addExpr ABSSIGN)=>*/(ABSSIGN! /*t0=*/a:addExpr! /*{t0==unknown || t0==number || t0==fc_set || t0==function}?*/ ABSSIGN! {#absAtom=(#a->roughType!=fc_set) ? #(#[FUNCTION, "function"], #[ABS,"|"],#a) : #(#[SIZEOF, "|"], #a);} {if (#a->roughType==fc_set) #absAtom->roughType=number; else #absAtom->roughType=#a->roughType;} /*{t=t0=(t0==fc_set)?number:t0;}*/)
	|	(/*t0=*/atom /*{deb("absAtom", #absAtom->roughType);}*//*{t0==unknown || t0==number || t0==function || t0==fc_set}?*/))//{t=t0;}
	;

negAtom	:	((MINUS! /*t0=*/n:negAtom! /*{t0==unknown || t0==number || t0==function || t0==fc_set}?*/ {#negAtom=#(#[NEG,"-a"],#n);} {#negAtom->roughType=#n->roughType;} )
	|	(PM^ pm:negAtom {#negAtom->roughType=#pm->roughType;})
	|	(MP^ mp:negAtom {#negAtom->roughType=#mp->roughType;})
	|	(/*t0=*/absAtom /*{t0==unknown || t0==number || t0==fc_set || t0==function}?*/)) //{t=t0;}
	;

parens	:		(LPAREN^ /*t0=*/a:logicExpr RPAREN! /*{t0==unknown || t0==number || t0==function || t0==fc_set}?*/ /*t0=lparenEnding[#a, t0]*/ /*{t=t0;}*/ {#parens->roughType=#a->roughType;})
	|	(LBRACKET^ /*t0=*/f:forcedEnumExpr /*{t0==unknown || t0==number || t0==fc_set || t0==function}?*/ RBRACKET! /*{t=t0;}*/ {#parens->roughType=#f->roughType;} )
	|	(TEXLEFT! ((LPAREN^ l:logicExpr RPAREN! TEXRIGHT! {#parens->roughType=#l->roughType;}) | (LBRACKET^ fee:forcedEnumExpr RBRACKET! TEXRIGHT! {#parens->roughType=#fee->roughType;})))
	;

forcedEnumExpr /*returns [ExprType t] {ExprType t0, t1;}*/ {RoughType t=notset;}:	(/*t0=*/a0:addExpr /*{t0==unknown || t0==number || t0==fc_set}?*/ {t=#a0->roughType;} (CCOMMA! /*t1=*/a1:addExpr /*{t1==unknown || t1==number || t1==fc_set}?*/ /*{if (t0!=t1) t0=unknown;}*/ {if (t!=#a1->roughType) t=unknown;})*)?
		{#forcedEnumExpr=#(#[ENUMERATION, ",,"],#forcedEnumExpr);} {#forcedEnumExpr->roughType=t;} //{t=t0;}
	;

enumExpr /*returns [ExprType t] {ExprType t0, t1;}*/ {RoughType t=notset;}:	(/*t0=*/a0:addExpr /*{t0==unknown || t0==number || t0==fc_set}?*/ {t=#a0->roughType;} ((CCOMMA! /*t1=*/a1:addExpr  /*{t1==unknown || t1==number || t1==fc_set}?*/ /*{if (t1!=t0) t0=unknown;}*/ {if (t!=#a1->roughType) t=unknown;})+ {#enumExpr=#(#[ENUMERATION,",,,"], #enumExpr);})? /*{t=t0;}*/ {#enumExpr->roughType=t;})
	;

func	:	SGN
	|	SIN
	|	SINH
	|	SH! {#func=#[SINH,"sh"];}
	|	COS
	|	COSH
	|	CH! {#func=#[COSH,"ch"];}
	|	TAN
	|	TG! {#func=#[TAN,"tg"];}
	|	TANH
	|	TGH! {#func=#[TANH,"tgh"];}
	|	SEC
	|	SECH
	|	COSEC
	|	CSC! {#func=#[COSEC,"csc"];}
	|	COSECH
	|	CSCH! {#func=#[COSECH,"csch"];}
	|	COT
	|	CTG! {#func=#[COT,"ctg"];}
	|	COTH
	|	CTGH! {#func=#[COTH,"ctgh"];}
	|	ARCSIN
	|	ARCSINH
	|	ARCSH! {#func=#[ARCSINH,"arcsh"];}
	|	ARCCOS
	|	ARCCOSH
	|	ARCCH! {#func=#[ARCCOSH,"arcch"];}
	|	ARCTAN
	|	ARCTG! {#func=#[ARCTAN,"arctg"];}
	|	ARCTANH
	|	ARCTGH! {#func=#[ARCTANH,"arctgh"];}
	|	ARCSEC
	|	ARCSECH
	|	ARCCOSEC
	|	ARCCSC! {#func=#[ARCCOSEC,"arccsc"];}
	|	ARCCOSECH
	|	ARCCSCH! {#func=#[ARCCOSECH,"arccsch"];}
	|	ARCCOT
	|	ARCCTG! {#func=#[ARCCOT,"arcctg"];}
	|	ARCCOTH
	|	ARCCTGH! {#func=#[ARCCOTH,"arcctgh"];}
	|	ASIN! {#func=#[ARCSIN,"asin"];}
	|	ASINH! {#func=#[ARCSINH,"asinh"];}
	|	ASH! {#func=#[ARCSINH,"ash"];}
	|	ACOS! {#func=#[ARCCOS,"acos"];}
	|	ACOSH! {#func=#[ARCCOSH,"acosh"];}
	|	ACH! {#func=#[ARCCOSH,"ach"];}
	|	ATAN! {#func=#[ARCTAN,"atan"];}
	|	ATG! {#func=#[ARCTAN,"atg"];}
	|	ATANH! {#func=#[ARCTANH,"atan"];}
	|	ATGH! {#func=#[ARCTANH,"atgh"];}
	|	ASEC! {#func=#[ARCSEC,"asec"];}
	|	ASECH! {#func=#[ARCSECH,"asech"];}
	|	ACOSEC! {#func=#[ARCCOSEC,"acosec"];}
	|	ACSC! {#func=#[ARCCOSEC,"arccsc"];}
	|	ACOSECH! {#func=#[ARCCOSECH,"acosech"];}
	|	ACSCH! {#func=#[ARCCOSECH,"acsch"];}
	|	ACOT! {#func=#[ARCCOT,"acot"];}
	|	ACTG! {#func=#[ARCCOT,"arcctg"];}
	|	ACOTH! {#func=#[ARCCOTH,"acoth"];}
	|	ACTGH! {#func=#[ARCCOTH,"arcctgh"];}
	|	ERF
	|	ABS
	|	IM
	|	RE
	|	ARG
	|	CONJUGATE
	|	TRANSPONATE
	|	COMPLEMENTER
	|	EXP
	|	LN
	|	LG
	|	SQRT
	|	CEIL
	|	FLOOR
	;

funcName:	func
	|	(MATHRM LBRACE func)=>(MATHRM! LBRACE! func RBRACE!)
	;

derivedFuncName:{allowComputingFunctions}? (DERIVET^ LBRACE! funcName RBRACE!)
	|	{allowComputingFunctions}? (DDERIVET^ LBRACE! funcName RBRACE!)
	|	/*{!noApostrophes}?*/ {allowComputingFunctions}? (funcName DERIVEX)=>(funcName (DERIVEX^)+)
	|	funcName
	;

funcArg	:	  (NUMBER (VARIABLE | ABSSIGN | DERIVET | DDERIVET))=>(n:NUMBER! /*t0=*/v0:powExpr! /*{t0==unknown || t0==number || t0==fc_set}?*/ {#funcArg=#([MULT," "],#n,#v0);} /*{t=t0;}*/)
		| (PARAMETER absAtom)=>(p:PARAMETER! /*t0=*/v1:powExpr! /*{t0==unknown || t0==number || t0==fc_set}?*/ {#funcArg=#([MULT," "],#p,#v1);} /*{t=unknown;}*/ {#funcArg->roughType=unknown;})
		| (LPAREN)=>atom
		| /*t0=*/negPowExpr /*{t0==unknown || t0==number || t0==fc_set}?*/ //{t=t0;}
		;

d	:	D
	|	MATHRM! ((LBRACE! D RBRACE!) | D)
	;

functions{ bool hasExp=false;}:
		(derivedLogName)=>/*t0=*/logFunc //{t=t0;}
	|!	(derivedFuncName LBRACKET)=>(f0:derivedFuncName LBRACKET /*t0=*/a0:addExpr /*{t0==unknown || t0==number || t0==fc_set}?*/ RBRACKET {#functions=#(#[FUNCTION,"function"],#f0,#(#[LPAREN,"["],#a0));} /*{t=t0;}*/ {#functions->roughType=#a0->roughType;} )
	|!	(derivedFuncName LPAREN)=>(f1:derivedFuncName LPAREN /*t0=*/a1:addExpr /*{t0==unknown || t0==number || t0==fc_set}?*/ RPAREN {#functions=#(#[FUNCTION,"function"],#f1,#(LPAREN,#a1));} /*{t=t0;}*/ {#functions->roughType=#a1->roughType;} )
	|!	(derivedFuncName)=>(f2:derivedFuncName (c2:CIRCUM /*t0=*/e2:negPowExpr {hasExp=true;} /*{t0==unknown || t0==number}?*/)? /*t1=*/a2:funcArg /*{t1==unknown || t1==number || t1==fc_set}?*/ {if (hasExp) #functions=#(#c2,#(#[FUNCTION,"function"],#f2,#a2),#e2); else #functions=#(#[FUNCTION, "function"],#f2,#a2);} /*{t=t1;}*/ {#functions->roughType=#a2->roughType;})
	|!	{allowComputingFunctions}? (INT LPAREN addExpr RPAREN)=>(INT LPAREN /*t0=*/a3:addExpr /*{t0==unknown || t0==function || t0==number}?*/ RPAREN {#functions=#(#[INDEFINTEGRAL,"int"], #a3, #[VARIABLE,"x"]);} {#functions->roughType=function;})
	|!	{allowComputingFunctions}? (INT LPAREN addExpr CCOMMA variable RPAREN)=>(INT LPAREN /*t0=*/a8:addExpr CCOMMA /*t1=*/v0:variable RPAREN {#(#[INDEFINTEGRAL, "int"],#a8,#v0);} {#functions->roughType=function;})
	|!	{allowComputingFunctions}? (INT LPAREN! /*t0=*/a4:addExpr /*{t0==unknown || t0==number || t0==function}?*/ CCOMMA! /*t1=*/v1:variable EQUAL /*t2=*/a5:addExpr /*{t2==unknown || t2==number}?*/ INTERVAL /*t3=*/a6:addExpr /*{t3==unknown || t3==number}?*/ RPAREN {#functions=#(#[DEFINTEGRAL, "int"],#a4,#v1,#a5,#a6);} /*{t=(t2==t3 && t2==number)?number:function;}*/ {#functions->roughType=function;})
	|!	{allowComputingFunctions}? (DIFF LPAREN /*t0=*/a7:addExpr {#functions=#a7;} /*{t0==unknown || t0==number || t0==function}?*/ (CCOMMA /*t1=*/v2:variable (DOLLAR nth:addExpr)?) {if (#nth==antlr::nullAST) {#functions=#(#[DERIVE, "diff"], #functions, #v2);} else {#functions=#(#[NTHDERIVE, "diff"], #functions, #nth, #(#[PAIR, "pair"], #nth, #v2));}} RPAREN /*{t=function;}*/ {#functions->roughType=function;} )
	|!	{allowComputingFunctions}? (SUM LPAREN ((DERIVEX {noApostrophes=true;} a9:addExpr DERIVEX {noApostrophes=false;}) | (a10:addExpr {#a9=#a10;})) CCOMMA {noApostrophes=true; setIsIVariable(true); ++depth;} ((DERIVEX v3:variable  DERIVEX {noApostrophes=false;}) | v4:variable {#v3=#v4;}) {--depth; setIsIVariable(depth>0);} ((EQUAL|CCOMMA) a11:addExpr (INTERVAL|CCOMMA) a12:addExpr)? RPAREN {if (#a11!=antlr::nullAST) #functions=#(#SUM, #v3, #a11, #a12, #a9); else #functions=#(#SUM, #v3, #[NUMBER, "0"], #(#[MINUS, "-"], dupTree(#v3), #[NUMBER, "1"]), #a9);})
	|!	{allowComputingFunctions}? (LIM LPAREN a17:addExpr {++depth; setIsIVariable(true);} CCOMMA v7:variable (EQUAL | ASSIGN) a18:addExpr (CCOMMA (left:LEFT | right:RIGHT | real:REAL | cplex:COMPLEX) )? RPAREN {--depth; setIsIVariable(depth>0);}
	{
		if (#left!=antlr::nullAST)
			#functions=#(#LIM, #v7, #a18, #a17, #left);
		else if (#right!=antlr::nullAST)
			#functions=#(#LIM, #v7, #a18, #a17, #right);
		else if (#real!=antlr::nullAST)
			#functions=#(#LIM, #v7, #a18, #a17, #real);
		else if (#cplex!=antlr::nullAST)
			#functions=#(#LIM, #v7, #a18, #a17, #cplex);
		else
			#functions=#(#LIM, #v7, #a18, #a17, #[REAL, "real"]);

	})
	|	{allowComputingFunctions}? (GCD^ LPAREN! addExpr CCOMMA! addExpr RPAREN!)
	|	{allowComputingFunctions}? (LCM^ LPAREN! addExpr CCOMMA! addExpr RPAREN!)
	|	(MATRIX^
			(LPAREN! parens (CCOMMA! parens)+ RPAREN!)
			{#functions->setType(ENUMERATION); #functions=#(#[LBRACKET, "["], #functions);})
	;

logName	:	LOG
	|	(MATHRM LBRACE LOG)=>(MATHRM! LBRACE! LOG RBRACE!)
	;

derivedLogName	:	{allowComputingFunctions}? (logName DERIVEX)=>(logName (DERIVEX^)+)
	|	{allowComputingFunctions}? (DERIVET^ LBRACE! logName RBRACE!)
	|	{allowComputingFunctions}? (DDERIVET^ LBRACE! logName RBRACE!)
	|	logName
	;

logFunc{ bool hasExp=false, hasLog=false;}
	:	((derivedLogName LBRACKET addExpr CCOMMA)=>(l0:derivedLogName! LBRACKET! /*t0=*/a0:addExpr! /*{t0==unknown || t0==number}?*/ CCOMMA! /*t1=*/aa0:addExpr! /*{t0==unknown || t1==number || t1==fc_set}?*/ RBRACKET! {#logFunc=#(#[FUNCTION,"function"],#(#l0, #a0), #aa0); #logFunc->roughType=#aa0->roughType;} /*{t=t1;}*/)
	|	(derivedLogName LBRACKET addExpr RBRACKET)=>(l1:derivedLogName! LBRACKET! /*t0=*/aa1:addExpr! /*{t0==unknown || t0==number || t0==fc_set}?*/ RBRACKET! {#logFunc=#(#[FUNCTION,"function"],#l1, #aa1); #logFunc->roughType=#aa1->roughType;} /*{t=t0;}*/)
	|	(l2:derivedLogName! (UNDERSCORE! /*t0=*/a2:negAtom! /*{t0==unknown || t0==number}?*/ {hasLog=true;})? (CIRCUM! /*t1=*/e2:negPowExpr! /*{t1==unknown || t1==number}?*/ {hasExp=true;})? /*t2=*/aa2:funcArg! /*{t2==unknown || t2==number || t2==fc_set}?*/
	{
		if (hasExp)
			if (hasLog)
				#logFunc=#([CIRCUM,"^"], #(#[FUNCTION,"function"], #(#l2, #a2), #aa2), #e2);
			else
				#logFunc=#([CIRCUM,"^"], #(#[FUNCTION,"function"],#l2, #aa2), #e2);
		else
			if (hasLog)
				if (#aa2->getType() == CIRCUM && #aa2->getFirstChild()->getType() == LPAREN)
				{
					RefFcAST base=#aa2->getFirstChild(), exp=base->getNextSibling();
					base->setNextSibling(antlr::nullAST);
					#logFunc=#(#[CIRCUM, "^"], #(#[FUNCTION,"function"],#(#l2, #a2), base), exp);
				}
				else
					#logFunc=#(#[FUNCTION,"function"],#(#l2, #a2), #aa2);
			else
				if (#aa2->getType() == CIRCUM && #aa2->getFirstChild()->getType() == LPAREN)
				{
					RefFcAST base=#aa2->getFirstChild(), exp=base->getNextSibling();
					base->setNextSibling(antlr::nullAST);
					#logFunc=#(#[CIRCUM, "^"], #(#[FUNCTION,"function"],#l2, base), exp);
				}
				else
					#logFunc=#(#[FUNCTION,"function"],#l2, #aa2);

	} {#logFunc->roughType=#aa2->roughType;} /*{t=t2;}*/)
	)
	;

texArg	:	(LBRACE LBRACE)=>(LBRACE!texArg RBRACE!)
	|	(LBRACE!addExpr RBRACE!)
	|	negAtom
	;

texLogicArg	:	(LBRACE LBRACE)=>(LBRACE!texArg RBRACE!)
	|	(LBRACE! logicExpr RBRACE!)
	;

texEnumArg:	((LBRACE LBRACE)=>(LBRACE! texEnumArg RBRACE!)
	|	(LBRACE! enumExpr RBRACE! )
	|	(negAtom)
	)
	;

variable:
	((	VARIABLE
	|	PARAMETER
	|	ALPHA
	|	BETA
	|	GAMMA
	|	GAMMAG
	|	DELTA
	|	DELTAG
	|	EPSILON
	|	ZETA
	|	ETA
	|	THETA
	|	THETAG
	|	IOTA
	|	KAPPA
	|	LAMBDA
	|	LAMBDAG
	|	MU
	|	NU
	|	XI
	|	XIG
	|	OMICRON
//	|	PI;
	|	PIG
	|	RHO
	|	SIGMA
	|	SIGMAG
	|	TAU
	|	UPSILON
	|	UPSILONG
	|	PHI
	|	PHIG
	|	CHI
	|	PSI
	|	PSIG
	|	OMEGA
	|	OMEGAG
	)
	{depth++; setIsIVariable(true);}
	((UNDERSCORE)=>(UNDERSCORE^ /*t0=*/texEnumArg /*{t0==unknown || t0==fc_set || t0==number}?*/)
	|(LBRACKET)=>(LBRACKET! /*t0=*/enumExpr /*{t0==unknown || t0==fc_set || t0==number}?*/ RBRACKET! {#variable=#(#[UNDERSCORE, "[]"], #variable);}))?
	)
	{depth--; setIsIVariable(depth>0);}
	;

partial	:	(LBRACE! partial RBRACE!)
	|	PARTIAL
	|	d
	;

texSpec!:	(TEXSQRT LBRACKET)=>(TEXSQRT LBRACKET /*t0=*/a1:addExpr /*{t0==unknown || t0==number}?*/ RBRACKET /*t1=*/a2:texArg /*{t1==unknown || t1==number || t1==fc_set || t1==function}?*/ {#texSpec=#(#[FUNCTION,"function"],#(#[ROOT, "\\sqrt"],#a1),#a2);} {#texSpec->roughType=#a2->roughType;})
	|	(TEXSQRT)=>(TEXSQRT /*t0=*/a3:texArg /*{t0==unknown || t0==fc_set || t0==function || t0==number}?*/ {#texSpec=#(#[FUNCTION,"function"],#[SQRT, "\\sqrt"], #a3);} {#texSpec->roughType=#a3->roughType;})
	|	{allowComputingFunctions}? (TEXINT UNDERSCORE)=>(TEXINT UNDERSCORE /*t0=*/l0:texArg /*{t0==number || t0==unknown}?*/ CIRCUM /*t1=*/u0:texArg /*{t1==unknown || t1==number}?*/ /*t2=*/i0:addExpr /*{t2==unknown || t2==number}?*/ d /*t3=*/v0:variable {#texSpec=#(#[DEFINTEGRAL,"\\int"], #i0, #v0, #l0, #u0);} {#texSpec->roughType=#i0->roughType;})
	|	{allowComputingFunctions}? (TEXINT CIRCUM)=>(TEXINT CIRCUM /*t0=*/u1:texArg /*{t0==unknown || t0==number}?*/ UNDERSCORE /*t1=*/l1:texArg /*{t1==unknown || t1==number}?*/ /*t2=*/i1:addExpr /*{t2==unknown || t2==number}?*/ d /*t3=*/v1:variable {#texSpec=#(#[DEFINTEGRAL,"\\int"], #i1, #v1, #l1, #u1);} {#texSpec->roughType=#i1->roughType;})
	|	{allowComputingFunctions}? (TEXINT /*t0=*/i:addExpr /*{t0==unknown || t0==number}?*/ d /*t1=*/v:variable {#texSpec=#(#[INDEFINTEGRAL,"\\int"], #i, #v);} {#texSpec->roughType=function;})
	|	{allowComputingFunctions}? (TEXSUM UNDERSCORE LBRACE (variable | I) (ASSIGN | EQUAL))=>(TEXSUM UNDERSCORE LBRACE (/*t0=*/v2:variable | I {#I->setType(VARIABLE); #v2=#I; isIReallyVariable=true; usedVariables.insert(#I->getText());}) (ASSIGN | EQUAL) /*t1=*/l2:addExpr /*{t1==unknown || t1==number}?*/ RBRACE {--depth; setIsIVariable(depth>0);} CIRCUM /*t2=*/u2:texArg /*{t2==unknown || t2==number}?*/ /*t3=*/a7:texArg {#texSpec=#(#[SUM, "\\sum"], #v2, #l2, #u2, #a7);} {#texSpec->roughType=#a7->roughType;})
	|	{allowComputingFunctions}? (TEXSUM CIRCUM)=>(TEXSUM CIRCUM /*t0=*/u3:texArg /*{t0==unknown || t0==number}?*/ {++depth; setIsIVariable(true);} UNDERSCORE LBRACE /*t1=*/v3:variable (ASSIGN | EQUAL) /*t2=*/l3:addExpr /*{t2==unknown || t2==number}?*/ RBRACE {--depth; setIsIVariable(depth>0);} /*t3=*/a8:texArg /*{t3==unknown || t3==function || t3==number}?*/ {#texSpec=#(#[SUM, "\\sum"], #v3, #l3, #u3, #a8);} {#texSpec->roughType=#a8->roughType;})
	|	{allowComputingFunctions}? (TEXSUM UNDERSCORE LBRACE )=>(TEXSUM UNDERSCORE l10:texLogicArg a10:texArg {#texSpec=#(#[SUM, "\\sum"], #(#[CONDITION, "texCondition"], #l10), #[NONE], #[NONE], #a10);} {#texSpec->roughType=#a10->roughType;})
	|	{allowComputingFunctions}? (TEXSUM UNDERSCORE)=>(TEXSUM {++depth; setIsIVariable(true);}UNDERSCORE v4:variable {--depth; setIsIVariable(depth>0);}a9:texArg {#texSpec=#(#[SUM,"\\sum"], #v4, #[UNKNOWN], #[UNKNOWN], #a9);} {#texSpec->roughType=#a9->roughType;})
	//TODO create the sum on a set/condition and the outputs too.
	//TODO create the same for TEXPROD
	|	{allowComputingFunctions}? (FRAC LBRACE partial addExpr RBRACE LBRACE partial variable RBRACE)=>(FRAC LBRACE partial /*t0=*/a15:addExpr /*{t0==unknown || t0==number || t0==function}?*/ RBRACE LBRACE partial /*t1=*/v5:variable RBRACE {#texSpec=#(#[DERIVE, "\\frac \\partial"], #a15, #v5);} {#texSpec->roughType=function;})
	|	{allowComputingFunctions}? (FRAC partial LBRACE partial variable RBRACE)=>(FRAC partial LBRACE partial /*t0=*/v6:variable RBRACE /*t1=*/a16:texArg /*{t1==unknown || t1==number || t1==function}?*/ {#texSpec=#(#[DERIVE, "\\frac \\partial"], #a16, #v6);} {#texSpec->roughType=function;})
	|	{allowComputingFunctions}? (FRAC LBRACE partial CIRCUM negPowExpr RBRACE)=>(FRAC LBRACE partial CIRCUM /*t0=*/degUp0:negPowExpr /*{t0==number}?*/ RBRACE LBRACE {#texSpec=#[NONE, "end"];} (partial /*t1=*/v7:variable (CIRCUM /*t2=*/v70:negPowExpr /*{t2==number}?*/ {#v7=#(CIRCUM, #v7, #v70);})? {#texSpec=#(#[PAIR, "pair"], #v7, #texSpec);})+ RBRACE /*t3=*/a17:negMultExpr /*{t3==number || t3==unknown || t3==function}?*/ {#texSpec=#(#[NTHDERIVE, "\\frac \\partial"], #a17, #degUp0, #texSpec);} {#texSpec->roughType=function;})
	|	{allowComputingFunctions}? (FRAC LBRACE partial CIRCUM )=>(FRAC LBRACE partial CIRCUM /*t0=*/degUp1:negPowExpr /*{t0==number}?*/ /*t1=*/a18:addExpr /*{t1==unknown || t1==number || t1==function}?*/ RBRACE LBRACE {#texSpec=#[NONE, "end"];} (partial /*t2=*/v8:variable (CIRCUM /*t3=*/v80:negPowExpr /*{t3==number}?*/{#v8=#(CIRCUM, #v8, v80);})? {#texSpec=#(#[PAIR, "pair"], #v8, #texSpec);})+ RBRACE {#texSpec=#(#[NTHDERIVE, "\\frac \\partial"], #a18, #degUp1, #texSpec);} {#texSpec->roughType=function;})
	|	(FRAC /*t0=*/a5:texArg /*t1=*/a6:texArg /*{t0==unknown || t1==unknown || (t0==t1 && (t0==number || t0==function))}?*/ {#texSpec=#(#[DIV, "frac"], #a5, #a6);} {#texSpec->roughType=(#a6->roughType!=unknown)?#a5->roughType:#a6->roughType;})
	|	(LCEIL)=>(LCEIL /*t0=*/a13:addExpr /*{t0==number}?*/ RCEIL {#texSpec=#(#[FUNCTION,"function"],#[CEIL,"ceil "],#a13);} {#texSpec->roughType=#a13->roughType;})
	|	(LFLOOR)=>(LFLOOR /*t0=*/a14:addExpr /*{t0==number}?*/ RFLOOR {#texSpec=#(#[FUNCTION,"function"],#[FLOOR,"floor "],#a14);} {#texSpec->roughType=#a14->roughType;})
	|	(TEXOVERLINE)=>(TEXOVERLINE a20:texArg {if (#a20->roughType==fc_set) #texSpec=#(#[FUNCTION, "function"], #[COMPLEMENTER,"\\oveline(complementer)"], #a20); else #texSpec=#(#[FUNCTION, "function"], #[CONJUGATE, "\\overline(conj)"], #a20);})
	|	(MATHBB ((LBRACE mbbv0:VARIABLE RBRACE) | mbbv1:VARIABLE {#mbbv0=#mbbv1;}) {bool variable=false; if (#mbbv0->getText()=="R") #texSpec=#[REALS, "R"]; else if (#mbbv0->getText()=="Z") #texSpec=#[INTEGERS, "Z"]; else if (#mbbv0->getText()=="N") #texSpec=#[NATURALNUMBERS, "N"]; else if (#mbbv0->getText()=="Q") #texSpec=#[RATIONALS, "Q"]; else if (#mbbv0->getText()=="C") #texSpec=#[COMPLEXES, "C"]; else if (#mbbv0->getText()=="P") #texSpec=#[PRIMES, "P"]; else variable=true; if (variable) {#texSpec=#[VARIABLE, #mbbv0->getText()]; #texSpec->roughType=unknown;} else #texSpec->roughType=fc_set;})
	|	{allowComputingFunctions}? TEXLIM {++depth; setIsIVariable(true);} UNDERSCORE LBRACE limvar:variable (limtype:REAL | limtype0:LEFT {#limtype=#limtype0;} | limtype1:RIGHT {#limtype=#limtype1;} | limtype2:IMPLY {#limtype2->setType(REAL); #limtype=#limtype2;}) limto:addExpr RBRACE {--depth; setIsIVariable(depth>0);} limarg:texArg {if (#limtype->getType()==REAL) {RefFcAST to=#limto->getFirstChild(), next; if (to!=antlr::nullAST) next=to->getNextSibling(); if ((next!=antlr::nullAST && next->getType()==NUMBER) && next->getText()=="0") {if (#limto->getType()==PLUS) {#limtype->setType(RIGHT); #limto=dupTree(to);} else if (#limto->getType()==MINUS) {#limtype->setType(LEFT); #limto=dupTree(to);} else if (#limto->getType()==PM || #limto->getType()==MP) {#limtype->setType(REAL); #limto=dupTree(to);}}} #texSpec=#(#[LIM, "\\lim"], #limvar, #limto, #limarg, #limtype);}
	|	{allowComputingFunctions}? ((tf:TEXLIMINF {#tf->setType(LIMINF);} | tf0:TEXLIMSUP {#tf0->setType(LIMSUP); #tf=#tf0;} | tf1:TEXINF {#tf1->setType(INF); #tf=#tf1;} | tf2:TEXSUP {#tf2->setType(SUP); #tf=#tf2;} | tf3:TEXMIN {#tf3->setType(MIN); #tf=#tf3;} | tf4:TEXMAX {#tf4->setType(MAX); #tf=#tf4;} | tf5:TEXARGMIN {#tf5->setType(ARGMIN); #tf=#tf5;} | tf6:TEXARGMAX {#tf6->setType(ARGMAX); #tf=#tf6;}) {++depth; setIsIVariable(true);} (UNDERSCORE tfbvar:texLogicArg)? {--depth; setIsIVariable(depth>0);} tfarg:texArg {#texSpec=#(#tf, #tfarg, tfbvar);})// The order of arg and condition/bvar differs, from the lim's order.
	;

texMatrix	:
	(TEXPMATRIX^ LBRACE! texMatrixRow (TEXCR! texMatrixRow)+ RBRACE!) {#texMatrix->setType(ENUMERATION); #texMatrix->setText(",,"); #texMatrix->roughType=unknown; #texMatrix=#(#[LBRACKET, "["], #texMatrix); #texMatrix->roughType=unknown;}
	;

texMatrixRow	:
	(addExpr (AND! addExpr)+) {#texMatrixRow=#(#[ENUMERATION, ",,"], #texMatrixRow);  #texMatrixRow->roughType=unknown; #texMatrixRow=#(#[LBRACKET, "["], #texMatrixRow); #texMatrixRow->roughType=unknown;}
	;

atom{ std::string s;}:
		(({s=LT(1)->getText();} v:variable
		{
		if (s=="i" || s=="I")
			isIReallyVariable = true;
		if (#v->getType()==VARIABLE)
			usedVariables.insert(#v->getText());
		if (#v->getType()==PARAMETER)
			usedParameters.insert(#v->getText());
		if (#v->getType()==UNDERSCORE)
		{
			RefFcAST left=#v->getFirstChild(), right=left->getNextSibling();
			if (right->getType()==VARIABLE || right->getType()==NUMBER || right->getType()==PARAMETER)
			{
				if (left->getType()==VARIABLE)
					usedVariables.insert(left->getText()+"_"+right->getText());
				if (left->getType()==VARIABLE)
					usedVariables.insert(left->getText()+"_"+right->getText());
			}
		}
		if (functionNames.find(s)!=functionNames.end())
		{
			#v->roughType=function;
		}
		else if (setVariables.find(s)!=setVariables.end())
		{
			#v->roughType=fc_set;
		}
		else if (logicalVariables.find(s)!=logicalVariables.end())
		{
			#v->roughType=logical;
		}
		else #v->roughType=unknown;
		})
	|	(I UNDERSCORE)=>(I {#I->setType(VARIABLE); #I->roughType=unknown; isIReallyVariable=true; setIsIVariable(true);} UNDERSCORE^ texEnumArg {#atom->roughType=unknown;})
	|	(I LBRACKET)=>(I {#I->setType(VARIABLE); #I->roughType=unknown; isIReallyVariable=true; setIsIVariable(true);} LBRACKET! enumExpr RBRACKET! {#atom = #(#[UNDERSCORE, "_"], #atom); #atom->roughType=unknown;})
	|	(E UNDERSCORE)=>(E {#E->setType(VARIABLE); #E->roughType=unknown;} UNDERSCORE^ texEnumArg {#atom->roughType=unknown;})
	|	(E LBRACKET)=>(E {#E->setType(VARIABLE);} LBRACKET! enumExpr RBRACKET! {#atom = #(#[UNDERSCORE, "_"], #atom);})
	|	e:E {#e->roughType=number;}
	|	i:I {if (isIPossiblyVariable) {#i->setType(VARIABLE); isIReallyVariable = true; setIsIVariable(true); #i->roughType = unknown;} else #i->roughType=number;}
	|	pi:PI {#pi->roughType=number;}
	|	infty:INFTY {#infty->roughType=number;}
	|	inf:INF {#inf->roughType=number; #inf->setType(INFTY);}
	|	dots:DOTS {#dots->roughType=unknown;}
	|	num:NUMBER {#num->roughType=number;}
	|	!(LTEXSET logicValue (ABSSIGN | COLON))=>(LTEXSET e0:logicValue (ABSSIGN | COLON) e1:logicExpr RTEXSET {#atom=#(#[SET,"set"], #e0, #e1);} {#atom->roughType=fc_set;})
	|	!(LTEXSET RTEXSET)=>(LTEXSET RTEXSET {#atom=#(#[SET,"emptyset"]);} {#atom->roughType=fc_set;})
	|	!(LTEXSET (e2:enumExpr) RTEXSET {#atom=#(#[SET, "set"], #e2);} {#atom->roughType=fc_set;})
	|	(TEXSQRT | TEXINT | TEXSUM | TEXPROD | LCEIL | LFLOOR | FRAC | TEXOVERLINE | TEXLIM | TEXLIMSUP | TEXLIMINF | TEXMAX | TEXMIN | TEXSUP | TEXINF | TEXARGMAX | TEXARGMIN)=>texSpec
	|	texMatrix
	|	functions
	|	(parens)
	)
	;

