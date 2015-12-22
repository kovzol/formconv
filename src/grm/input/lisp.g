header{
#include <h/fcAST.h>
#include <h/misc.h>
#include <cstring>
#include <vector>
#include <map>
}

options {
	language="Cpp";
}

/**
 * This file creates tokens (LispLexer), and an AST (LispParser) from a LISP file, the output uses Intuitive AST format.
 * Generation depends on the following files:
 * IntuitiveTokenTypes.txt
 * Compilation depends on the following files:
 * h/fcAST.h
 * From this file the following files will be created:
 * LispLexer.cpp, LispLexer.hpp, LispParser.cpp, LispParser.hpp, LispTokenTypes.hpp, LispTokenTypes.txt
 * @author Gabor Bakos (baga@users.sourceforge.net)
 */

//TODO: Use of radices other than 10.
//TODO: Use of control sequences, functions.
//TODO: Support the type modifiers.
//TODO: Testing!!!!

class LispParser extends Parser;
options
{
	k=1;
	importVocab=Intuitive;
	exportVocab=Lisp;
	ASTLabelType="RefFcAST";
	buildAST=true;
	defaultErrorHandler=false;
}
tokens
{
	LFALSE;
	LTRUE;
	LQUOTE;
	LSQRT;
	LISQRT;
	LEXP;
	LEXPT;
	LLOG;
	LMIN;
	LMAX;
	LMOD;
	LREM;
	LTRUNC;
	LROUND;
	LINCF;
	LDECF;
	LSETQ;
	LCONJUGATE;
	LGCD;
	LLCM;
	LABS;
	LPHASE;
	LSIGNUM;
	LCIS;
	LSIN;
	LCOS;
	LTAN;
	LASIN;
	LACOS;
	LATAN;
	LSINH;
	LCOSH;
	LTANH;
	LASINH;
	LACOSH;
	LATANH;
	LPI;
	LFLOAT;
	LRATIONAL;
	LRATIONALIZE;
	LCOMPLEX;
	LNUMERATOR;
	LDENOMINATOR;
	LIMAGPART;
	LREALPART;
	LEQUAL;
	LEQL;
	LAND;
	LOR;
	LNOT;
	LLOGAND;
	LLOGOR;
	LLOGXOR;
	LLOGEQV;
	LLOGMAND;
	LLOGNOR;
	LLOGANDC1;
	LLOGANDC2;
	LLOGORC1;
	LLOGORC2;
	LLOGNOT;
	LLOGTEST;
	LLOGBITP;
	LASH;
	LLOGCOUNT;
	LINTEGERLENGTH;
	LRANDOM;
}

{
	static std::string getNominator(const std::string &text)
	{
		std::string::size_type pos = text.find('/');
		return text.substr(0, pos);
	}
	static std::string getDenominator(const std::string &text)
	{
		std::string::size_type pos = text.find('/');
		return text.substr(pos+1);
	}

	RefFcAST createRational(const std::string &text) const
	{
		return #(#[DIV, "/"], createReal(getNominator(text)), createReal(getDenominator(text)));
	}

	RefFcAST createReal(const std::string &text) const
	{
		if (text[0]=='-')
		{
			return #(#[NEG, "-"], createReal(text.substr(1)));
		}
		else if (text.find('/')!=std::string::npos)
		{
			return createRational(text);
		}
		else
		{
			return #(#[NUMBER, text]);
		}
	}
}

inp	:	(expr)*
	;

expr {std::vector<RefFcAST> childs; RefFcAST dummy;}	:	((constant)
	|	(LLPAREN!
			(
				(u:unary_op! e0:expr! {if (#u->getType()==LONEPLUS) #expr=#(#[PLUS, "+"], #e0, #[NUMBER, "1"]); else if (#u->getType()==LMINUSONE) #expr=#(#[MINUS, "-"], #e0, #[NUMBER, "1"]); else #expr=#(#[FUNCTION, "function"], #u, #e0);})
			|	(b:binary_op! e10:expr! e11:expr! {#expr=#(#[FUNCTION, "function"], #b, #e10, #e11);})
			|	(ub:ubi_op! e20:expr! (e21:expr!)? {#expr=#(#[FUNCTION, "function"], #(#ub, #e21), #e20);})
			|	(n0:n0ary_op! (e30:expr! {childs.push_back(#e30);})* {#expr=manyToTwo<RefFcAST>(getASTFactory(), childs, #n0->getType(), #n0->getText(), 0);})
			|	(n1:n1ary_op! (e40:expr! {childs.push_back(#e40);})+ {#expr=manyToTwo<RefFcAST>(getASTFactory(), childs, #n1->getType(), #n1->getText(), 0);})
			)
		LRPAREN!))
	;

constant:	LFALSE {#LFALSE->setType(FC_FALSE);}
	|	LTRUE {#LTRUE->setType(FC_TRUE);}
	|	num:LNUMBER! {std::string text=#num->getText(); if (text[0]=='#' && (text[1]=='c' || text[1]=='C')) {std::string::size_type fpos=text.find_first_of(" \t\r\n"), lpos=text.find_last_of(" \t\r\n"); std::string real=text.substr(2, fpos-2), imag=text.substr(lpos+1); #constant=#(#[PLUS, "+"], createReal(real), #(#[MULT, " "], createReal(imag), #[I, "i"]));} else #constant=createReal(text);}
	|	LPI {#LPI->setType(PI);}
	|	LVARIABLE {#LVARIABLE->setType(VARIABLE);}
	;

unary_op:	LSIN {#LSIN->setType(SIN);}
	|	LCOS {#LCOS->setType(COS);}
	|	LTAN {#LTAN->setType(TAN);}
	|	LASIN {#LASIN->setType(ARCSIN);}
	|	LACOS {#LACOS->setType(ARCCOS);}
	|	LATAN {#LATAN->setType(ARCTAN);}
	|	LSINH {#LSINH->setType(SINH);}
	|	LCOSH {#LCOSH->setType(COSH);}
	|	LTANH {#LTANH->setType(TANH);}
	|	LASINH {#LASINH->setType(ARCSINH);}
	|	LACOSH {#LACOSH->setType(ARCCOSH);}
	|	LATANH {#LATANH->setType(ARCTANH);}
	|	LEXP {#LEXP->setType(EXP);}
//	|	LNUMERATOR
//	|	LDENUMINATOR
//	|	LRATIONAL
//	|	LRATIONALIZE
	|	LREALPART {#LREALPART->setType(RE);}
	|	LIMAGPART {#LIMAGPART->setType(IM);}
//	|	LLOGNOT
//	|	LLOGCOUNT
//	|	LINTEGERLENGTH
	|	LONEPLUS
	|	LMINUSONE
	|	LFLOOR {#LFLOOR->setType(FLOOR);}
	|	LCEILING {#LCEILING->setType(CEIL);}
	;

binary_op:	LEXPT {#LEXPT->setType(CIRCUM);}
	|	LMOD {#LMOD->setType(MOD);}
//	|	LREM {LREM->setType();}
//	|	LLOGTEST
//	|	LLOGBITP
//	|	LASH
	;

ubi_op	:	LLOG {#LLOG->setType(LOG);}
//	|	LINC {#LINC->setType(INC);}
//	|	LDEC {#LDEC->setType(DEC);}
//	|	LFLOOR {#LFLOOR->setType(FLOOR);}
//	|	LCEILING {#LCEILING->setType(CEIL);}
//	|	LTRUNCATE {#LTRUNCATE->setType();}
//	|	LROUND {#LROUND->setType(ROUND);}
//	|	LFLOAT
//	|	LCOMPLEX
//	|	LRANDOM
	;

n0ary_op:	LPLUS {#LPLUS->setType(PLUS);}
	|	LTIMES {#LTIMES->setType(MULT);}
	|	LAND {#LAND->setType(AND);}
	|	LOR {#LOR->setType(OR);}
	|	LLOGIOR
	|	LLOGXOR
	|	LLOGAND
	|	LLOGEQV
	|	LLOGNAND
	|	LLOGNOR
	|	LLOGANDC1
	|	LLOGANDC2
	|	LLOGORC1
	|	LLOGORC2
	;

n1ary_op:	LDIV {#LDIV->setType(DIV);}
	|	LMINUS {#LMINUS->setType(LMINUS);}
	|	LEQUAL {#LEQUAL->setType(EQUAL);}
	|	LEQL {#LEQL->setType(EQUAL);}
	|	LEQUALSIGN {#LEQUALSIGN->setType(EQUAL);}
	|	LNEQ {#LNEQ->setType(NEQ);}
	|	LLEQ {#LLEQ->setType(LEQ);}
	|	LGEQ {#LGEQ->setType(GEQ);}
	|	LLESS {#LLESS->setType(LESS);}
	|	LGREATER {#LGREATER->setType(GREATER);}
	|	LMIN {#LMIN->setType(MIN);}
	|	LMAX{#LMAX->setType(MAX);}
	;

class LispLexer extends Lexer;
options
{
	k=2;
//	caseSensitive=false;
//	exportVocab=MathMLIn;
	exportVocab=Lisp;
	testLiterals=false;
	caseSensitive=false;
	
	charVocabulary = '\0'..'\377';
	defaultErrorHandler=false;
}

{
private:
	struct comparator
	{
		bool operator()(const char *s1, const char *s2) const
		{
			return strcmp(s1, s2) < 0;
		}
	};
	std::map<const char *, int, comparator> tokens;
	void add(std::map<const char *, int, comparator> &tokens, const char *str, int token)
	{
//		tokens[str] = token;
		tokens.insert(std::map<const char *, int, comparator>::value_type(str, token));
	}

public:
	void init()
	{
		add(tokens, "nil", LFALSE);
		add(tokens, "t", LTRUE);
		add(tokens, "quote", LQUOTE);
		add(tokens, "sqrt", LSQRT);
		add(tokens, "isqrt", LISQRT);
		add(tokens, "exp", LEXP);
		add(tokens, "expt", LEXPT);
		add(tokens, "log", LLOG);
		add(tokens, "min", LMIN);
		add(tokens, "max", LMAX);
		add(tokens, "mod", LMOD);
		add(tokens, "rem", LREM);
		add(tokens, "trunc", LTRUNC);
		add(tokens, "round", LROUND);
		add(tokens, "incf", LINCF);
		add(tokens, "decf", LDECF);
		add(tokens, "setq", LSETQ);
		add(tokens, "conjugate", LCONJUGATE);
		add(tokens, "gcd", LGCD);
		add(tokens, "lcm", LLCM);
		add(tokens, "abs", LABS);
		add(tokens, "phase", LPHASE);
		add(tokens, "signum", LSIGNUM);
		add(tokens, "cis", LCIS);
		add(tokens, "sin", LSIN);
		add(tokens, "cos", LCOS);
		add(tokens, "tan", LTAN);
		add(tokens, "asin", LASIN);
		add(tokens, "acos", LACOS);
		add(tokens, "atan", LATAN);
		add(tokens, "sinh", LSINH);
		add(tokens, "cosh", LCOSH);
		add(tokens, "tanh", LTANH);
		add(tokens, "asinh", LASINH);
		add(tokens, "acosh", LACOSH);
		add(tokens, "atanh", LATANH);
		add(tokens, "pi", LPI);
		add(tokens, "float", LFLOAT);
		add(tokens, "rational", LRATIONAL);
		add(tokens, "rationalize", LRATIONALIZE);
		add(tokens, "complex", LCOMPLEX);
		add(tokens, "numerator", LNUMERATOR);
		add(tokens, "denominator", LDENOMINATOR);
		add(tokens, "imagpart", LIMAGPART);
		add(tokens, "realpart", LREALPART);
		add(tokens, "equal", LEQUAL);
		add(tokens, "eql", LEQL);
		add(tokens, "and", LAND);
		add(tokens, "or", LOR);
		add(tokens, "not", LNOT);
		add(tokens, "logand", LLOGAND);
		add(tokens, "logior", LLOGOR);
		add(tokens, "logxor", LLOGXOR);
		add(tokens, "logeqv", LLOGEQV);
		add(tokens, "lognand", LLOGNAND);
		add(tokens, "lognor", LLOGNOR);
		add(tokens, "logandc1", LLOGANDC1);
		add(tokens, "logandc2", LLOGANDC2);
		add(tokens, "logorc1", LLOGORC1);
		add(tokens, "logorc2", LLOGORC2);
		add(tokens, "lognot", LLOGNOT);
		add(tokens, "logtest", LLOGTEST);
		add(tokens, "logbitp", LLOGBITP);
		add(tokens, "ash", LASH);
		add(tokens, "logcount", LLOGCOUNT);
		add(tokens, "integer-length", LINTEGERLENGTH);
		add(tokens, "random", LRANDOM);
	}
}

WS	:	(' '
	|	'\t'
	)
	{ _ttype = ANTLR_USE_NAMESPACE(antlr)Token::SKIP; }
	;

protected
DIGIT	:	'0'..'9'
	;

LQUOTEABBREV:	"'"
	;

LLPAREN	:	"("
	;

LRPAREN	:	")"
	;

LPLUS	:	{LA(1)=='+' && (LA(2)<'0' || LA(2)>'9')}? "+"
	;

LMINUS	:	{LA(1)=='-' && (LA(2)<'0' || LA(2)>'9')}? "-"
	;

LTIMES	:	"*"
	;

LDIV	:	"/"
	;

LONEPLUS:	"1+"
	;

LMINUSONE:	"1-"
	;

LEQUALSIGN:	"="
	;

LNEQ	:	"/="
	;

LLESS	:	"<"
	;

LLEQ	:	"<="
	;

LGREATER:	">"
	;

LGEQ	:	">="
	;

protected
LREALNUMBER:	('+'!|'-')? (DIGIT)+ (('.' (DIGIT)+ ('e' ('-')? (DIGIT)+)?) | ('e' ('-')? (DIGIT)+) | ('/' (DIGIT)+))?
	;

LNUMBER	:	(('#' 'c' '('! /*((DIGIT (DIGIT)? ('r')) | 'x' | 'o' | 'b')*/ LREALNUMBER (' '!|'\t'!|'\r'! {newline();}|'\n'! {newline();})+ {$append(' ');} LREALNUMBER ')'!) | LREALNUMBER)
	;//TODO create a bit more sophisticated parser.

LVARIABLE:	('_' | 'a'..'z')  ('0'..'9' | '_' | 'a'..'z' | '-' | '+' | '*' | '/')* 
	{
		std::map<const char *, int, comparator>::iterator tokenIt;
		tokenIt=tokens.find($getText.c_str());
		if (tokenIt != tokens.end())
		{
			int token = (*tokenIt).second;
			$setType(token);
		}
	}
	;

COMMENT	:	";" (options {greedy=false;}:.)* NL {_ttype = ANTLR_USE_NAMESPACE(antlr)Token::SKIP; }
	;

NL	:	(('\n' {newline();})
	|	('\r' {newline();}))
	{_ttype = ANTLR_USE_NAMESPACE(antlr)Token::SKIP;}
	;

