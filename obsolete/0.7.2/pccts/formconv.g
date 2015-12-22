/*
 * General Formula converter
 * Version 0.1 (2003/02/12) by Zoltan Kovacs <kovzol@math.u-szeged.hu>
 * Version 0.2 (2003/02/12) by Zoltan Kovacs
 * Version 0.3 (2003/03/06) by Gabor Bakos <Bakos.Gabor.1@stud.u-szeged.hu>
 * Versions 0.4-0.6 are mostly written by Gabor Bakos
 * Updates and very small modifications by Zoltan Kovacs
 *
 * Based on "Calculator Demo" published by Ferenc Havasi, 2000
 * Thanks to Tibor Gyimothy, Laszlo Vidacs and Ferenc Havasi for their help
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Library or Lesser General Public License
 * (LGPL) as published by the Free Software Foundation.
 *
 * Version: $Id: formconv.g,v 1.2 2004/12/15 13:37:36 baga Exp $
 */
#header
<<
#include <string>
#include <set>
#include <cctype>
#include <iostream>
#include "AToken.h"
#include "AST.h"
using namespace std;
>>
/*Comment out the exception part, when DEBUG*/
 exception catch MismatchedToken: 
 		<<
		  exportSignal;
	 	>>
	   catch NoViableAlt:
	 	<<
		  exportSignal;
	 	>>

	   catch NoSemViableAlt:
 		<<
		  exportSignal;
 		>>
	   default:
	 	<<
		  exportSignal;
	 	>>
/*DEBUG end*/
#lexclass START
#token "/\*" <<mode(C_COMMENT); skip();>>
#token "//" <<mode(CPP_COMMENT); skip();>>

#token "[\ \t\r]" <<skip();>>
#token INTNUM "[0-9]+"
#token NUM "(([0-9]+ {\.[0-9]+})|(\.[0-9]+)) {[Ee] {\-} [0-9]+}"

#token ABS "{\\}[Aa][Bb][Ss]"
#token SQRT "{\\}[Ss][Qq][Rr][Tt]"
#token ROOT "{\\}[Rr][Oo][Oo][Tt]"
#token EXP "{\\}[Ee][Xx][Pp]"
#token LOG "{\\}[Ll][Oo][Gg]"
#token LN  "{\\}[Ll][Nn]"
#token LG  "{\\}[Ll][Gg]"
#token ARG "{\\}[Aa][Rr][Gg]"
#token RE "{\\}[Rr][Ee]"
#token IM "{\\}[Ii][Mm]"
#token CONJUGATE "[Cc][Oo][Nn][Jj][Uu][Gg][Aa][Tt][Ee]"
#token FLOOR "[Ff][Ll][Oo][Oo][Rr]"
#token CEIL "[Cc][Ee][Ii][Ll]"
#token SIN "{\\}[Ss][Ii][Nn]"
#token COS "{\\}[Cc][Oo][Ss]"
#token SEC "{\\}[Ss][Ee][Cc]"
#token COSEC "{\\}([Cc][Oo][Ss][Ee][Cc])|([Cc][Ss][Cc])"
#token TAN "{\\}[Tt][Aa][Nn]"
#token TG  "{\\}[Tt][Gg]"
#token COT "{\\}[Cc][Oo][Tt]"
#token CTG "{\\}[Cc][Tt][Gg]"
#token SINH "{\\}[Ss][Ii][Nn][Hh]"
#token SH  "{\\}[Ss][Hh]"
#token COSH "{\\}[Cc][Oo][Ss][Hh]"
#token CH  "{\\}[Cc][Hh]"
#token SECH "{\\}[Ss][Ee][Cc][Hh]"
#token COSECH "{\\}(([Cc][Oo][Ss][Ee][Cc][Hh])|([Cc][Ss][Cc][Hh]))"
#token TGH "{\\}[Tt][Gg][Hh]"
#token CTGH "{\\}[Cc][Tt][Gg][Hh]"
#token TANH "{\\}[Tt][Aa][Nn][Hh]"
#token COTH "{\\}[Cc][Oo][Tt][Hh]"
#token ARCSIN "{\\}[Aa]{[Rr][Cc]}[Ss][Ii][Nn]"
#token ARCCOS "{\\}[Aa]{[Rr][Cc]}[Cc][Oo][Ss]"
#token ARCSEC "{\\}[Aa]{[Rr][Cc]}[Ss][Ee][Cc]"
#token ARCCOSEC "{\\}(([Aa]{[Rr][Cc]}[Cc][Oo][Ss][Ee][CC])|([Aa]{[Rr][Cc]}[Cc][Ss][Cc]))"
#token ARCTAN "{\\}[Aa]{[Rr][Cc]}[Tt][Aa][Nn]"
#token ARCCOT "{\\}[Aa]{[Rr][Cc]}[Cc][Oo][Tt]"
#token ARCSINH "{\\}[Aa]{[Rr][Cc]}[Ss][Ii][Nn][Hh]"
#token ARCCOSH "{\\}[Aa]{[Rr][Cc]}[Cc][Oo][Ss][Hh]"
#token ARCSECH "{\\}[Aa]{[Rr][Cc]}[Ss][Ee][Cc][Hh]"
#token ARCCOSECH "{\\}(([Aa]{[Rr][Cc]}[Cc][Oo][Ss][Ee][CC][Hh])|([Aa]{[Rr][Cc]}[Cc][Ss][Cc][Hh]))"
#token ARCTANH "{\\}[Aa]{[Rr][Cc]}[Tt][Aa][Nn][Hh]"
#token ARCCOTH "{\\}[Aa]{[Rr][Cc]}[Cc][Oo][Tt][Hh]"

#token VARIABLE "[fFgGhHjJkKlLmMnNoOqQrRsStTuUvVwWxXyYzZ]"
#token CONST "[aAbBcCdDpP]|{%}[eEiI]"
#token INFTY "({\\}[Ii][Nn][Ff]{[Ii][Nn][Ii]}[Tt][Yy]) | ([Vv][Ee…È][Gg][Tt][Ee][Ll][Ee][Nn]) | ([Uu][Nn][Ee][Nn][Dd][Ll][Ii][Cc][Hh])"
#token UNDEFINED "[Uu][Nn][Dd][Ee][Ff][Ii][Nn][Ee][Dd] | [Ii][Nn][Dd] | [Nn][Ee][Mm][Ll][Ee…È][Tt][Ee][Zz][Ii][Kk] | [Nn][Ii][Cc][Hh][Tt][Ee][Xx][Ii][Ss][Tt][Ii][Ee][Rr][Tt] | [Nn][Oo][Tt][Ee][Xx][Ii][Ss][Tt][Ss]"
#token True "([Tt][Rr][Uu][Ee]) | ([Ii][Gg][Aa][Zz])"
#token False "([Ff][Aa][Ll][Ss][Ee]) | ([Hh][Aa][Mm][Ii][Ss])"
#token ALPHA "{[%\\]}[Aa][Ll](([Pp][Hh])|[Ff])[Aa]"
#token BETA "{[%\\]}[Bb][Ee…È][Tt][Aa]"
#token GAMMA "{[%\\]}[Gg][Aa][Mm][Mm][Aa]"
#token DELTA "{[%\\]}[Dd][Ee][Ll][Tt][Aa]"
#token EPSILON "{[%\\]}[Ee][Pp][Ss]{[Zz]}[Ii][Ll][Oo][Nn]"
#token ZETA "{[%\\]}{[Dd]}[Zz][Ee…È][Tt][Aa]"
#token ETA "{[%\\]}[Ee…È][Tt][Aa]"
#token THETA "{[%\\]}[Tt]{[Hh]}[Ee][Tt][Aa]"
#token IOTA "{[%\\]}[Ii][Oo”Û][Tt][Aa]"
#token KAPPA "{[%\\]}[Kk][Aa][Pp][Pp][Aa]"
#token LAMBDA "{[%\\]}[Ll][Aa][Mm][Bb][Dd][Aa]"
#token MU "{[%\\]}[Mm][Uu€˚]"
#token NU "{[%\\]}[Nn][Uu€˚]"
#token XI "{[%\\]}([Xx]|([Kk][Ss][Zz]))[IiÕÌ]"
#token OMICRON "{[%\\]}[Oo][Mm][Ii][CcKk][Rr][Oo][Nn]"
#token PI "{[%\\]}[Pp][IiÕÌ]"
#token RHO "{[%\\]}[Rr](([Hh][Oo])|[Oo”Û])"
#token SIGMA "{[%\\]}[Ss]{[Zz]}[Ii][Gg][Mm][Aa]"
#token TAU "{[%\\]}[Tt][Aa][Uu]"
#token UPSILON "{[%\\]}[Uu‹¸][Pp][Ss]{[Zz]}[Ii][Ll][Oo][Nn]"
#token PHI "{[%\\]}(([Pp][Hh])|([Ff]))[IiÕÌ]"
#token CHI "{[%\\]}(([Cc][Hh][Ii])|([Kk][Hh][IiÕÌ]))"
#token PSI "{[%\\]}[Pp](([Ss][Ii])|([Ss][Zz][IiÕÌ]))"
#token OMEGA "{[%\\]}[Oo”Û][Mm][Ee][Gg][Aa]"
#tokclass ROMAN_LETTER {VARIABLE CONST}
#tokclass GREEK_LETTER {ALPHA BETA GAMMA DELTA EPSILON ZETA ETA THETA IOTA KAPPA LAMBDA MU NU XI OMICRON PI RHO SIGMA TAU UPSILON PHI CHI PSI OMEGA}
#tokclass LETTER {ROMAN_LETTER GREEK_LETTER}
#tokclass LOG_CONST {True False}

#token PLUS "{\\}\+"
#token MINUS "{\\}\-"
#token DIV "/"
#token FRAC "\\[Ff][Rr][Aa][Cc]"
#token MULT "{\\}\* | \\[Cc][Dd][Oo][Tt]"
#token CIRCUM "^|\*\*"
#token LPAREN "{\\left} \("
#token RPAREN "{\\right} \)"
#token LBRACKET "{\\left} \["
#token RBRACKET "{\\right} \]"
#token LBRACE "\{"
#token RBRACE "\}"
#token UNDERSCORE "_"

#token AND "([Aa][Nn][Dd]) | ([Ee…È][Ss]) | (&{&}) | (/\\) | (\\[Vv][Ee][Ee])"
#token NAND "([Nn][Aa][Nn][Dd]) | ([Nn][Ee…È][Ss])"
#token OR "([Oo][Rr]) | ([Vv][Aa][Gg][Yy]) | (\|\|) | (\\/) | (\\[Ww][Ee][Dd][Gg][Ee])"
#token NOR "([Nn][Oo][Rr]) | ([Nn][Vv][Aa][Gg][Yy])"
#token XOR "([Xx][Oo][Rr]) | ([Kk]{[Ii][Zz].}[Vv][Aa][Gg][Yy])"
#token IMPLY "(\->) | (\\[Rr][Ii][Gg][Hh][Tt][Aa][Rr][Rr][Oo][Ww])"
#token NOT "([Nn]([Oo][Tt]|[Ee][Mm])) | (\\[Nn][Ee][Gg])"

#token ASSIGN ":="

#token DOTS "({\\}ldots) | (\.\.\.)"

#token COMMA ","
#token COLON ":"
#token NL "[\n;]" <<newline();>>
#token EoF "@"

#token EQUAL "={=}"
#token LESS "<"
#token LE "(<=) | (\\[Ll][Ee][Qq])"
#token EL "=<"
#token GREATER ">"
#token GE "(>=) | (\\[Gg][Ee][Qq])"
#token EG "=>"
#token NEQ "(!=) | (<>) | (\\[Nn][Ee][Qq])"

#token UNION "([Uu⁄˙][Nn][Ii][Oo”Û]{[Nn]}) | (\\[Cc][Uu][Pp])"
#token INTERSECT "([Ii][Nn][Tt][Ee][Rr][Ss][Ee][Cc][Tt]) | ([Mm][Ee][Tt][Ss][Zz][Ee][Tt]) | (\\[Cc][Aa][Pp])"
#token EXCEPT "([Ee][Xx][Cc][Ee][Pp][Tt]) | \\[Ss][Ee][Tt][Mm][Ii][Nn][Uu][Ss]"
#token IN "({\\}[Ii][Nn]) | ([Ee][Ll][Ee][Mm][Ee])"
#token NI "{\\}[Nn][Ii]"
#token SUBSET "({\\}[Ss][Uu][Bb][Ss][Ee][Tt]) | ([Rr][…ÈEe][Ss][Zz][Hh][Aa][Ll][Mm][Aa][Zz][Aa])"
#token SUPSET "{\\}[Ss][Uu][Pp][Ss][Ee][Tt]"
#token SUBSETEQ "{\\}[Ss][Uu][Bb][Ss][Ee][Tt][Ee][Qq]"
#token SUPSET "{\\}[Ss][Uu][Pp][Ss][Ee][Tt][Ee][Qq]"
#token COMPLEMENTER "{\\}[CcKk][Oo][Mm][Pp][Ll][Ee][Nn][Tt]{[Ee][Rr]}"
#token CROSS "([Mm][Uu][Ll][Tt][Ii][Pp][Ll][Yy])| ({\\}[Tt][Ii][Mm][Ee][Ss]) | ◊"
#token FORALL "({\\}[Ff][Oo][Rr][Aa][Ll][Ll]) | ([Mm][Ii][Nn][Dd][Ee][Nn])"
#token EXISTS "({\\}[Ee][Xx][Ii][Ss][Tt][Ss]) | ([Ll][Ee…È][Tt][Ee][Zz][Ii][Kk])"

//Special sets
#token EMPTYSET "({\\}[Ee][Mm][Pp][Tt][Yy]{\ }[Ss][Ee][Tt]) | ([‹¸Uu][Rr][Ee][Ss]{\ }[Hh][Aa][Ll][Mm][Aa][Zz])"

#token TRANSPONATE "[Tt][Rr][Aa][Nn][Ss][Pp][Oo][Nn](([Aa][Tt][Ee]) | ([¡·Aa][Ll][Tt]))"

//tokens for ring computation
#token DIVI "([Dd][Ii][Vv]) | ([Hh][¡·Aa][Nn][Yy][Aa][Dd][Oo][Ss])"
#token MOD "([Mm][Oo][Dd]) | ([Mm][Aa][Rr][Aa][Dd][…È][Kk])"
#token GCD "([Gg][Cc][Dd]) | ([Ll][Nn][Kk][Oo])"
#token LCM "([Ll][Cc][Mm]) | ([Ll][Kk][Kk][Tt])"
#token FACTOR "([Ff][Aa][Cc][Tt][Oo][Rr] | ([Oo][Ss][Zz][Tt][”ÛOo]))"

//for typecasting
#token BOOL "([Bb][Oo][Oo][Ll]{[Ee][Aa][Nn]}) | ([Ll][Oo][Gg][Ii] (([Kk][Aa][Ii]) | [Cc][Aa][Ll]))"
#token INT "([Ii][Nn][Tt]{[Ee][Gg][Ee][Rr]}) | ([Ee][Gg][…ÈEe][Ss][Zz])"
#token RATIONAL "[Rr][Aa]([Tt][Ii][Oo][Nn][Aa][Ll]) | ([Cc][Ii][Oo][Nn][¡·Aa][Ll][Ii][Ss])"
#token REAL "([Rr][Ee][Aa][Ll]) | ([Ff][Ll][Oo][Aa][Tt]) | ([Dd][Oo][Uu][Bb][Ll][Ee]) | ([Vv][Aa][Ll][”Û][Ss])"
#token COMPLEX "[CcKk][Oo][Mm][Pp][Ll][Ee][Xx]"
#token CONSTANT "([Cc][Oo][Nn][Ss][Tt]{[Aa][Nn][Tt]}) | ([Kk][Oo][Nn][Ss][Tt](\. | [Aa][Nn][Ss]))"

#token FACTORIAL "!"
#token DFACTORIAL "!!"
#token ABSSIGN "\|"
#token NEG
#token MULTNONE
#token FUNCTION // name, {UNDESCORELOG index} arg exp
#token UFUNCTION // name, arg0 (COMMA arg_i)* exp // user defined function
#token UNDERSCORELOG
#token ENUMERATE
#token SET
#token SETDEF

#lexclass C_COMMENT
#token "\n" <<skip(); newline();>>
#token "\*/" <<mode(START); skip();>>
#token "\*~[/]" <<skip();>>
#token "~[\*\n]+" <<skip();>>

#lexclass CPP_COMMENT
#token "\n" <<skip(); newline(); mode(START);>>
#token "~[\n]+" <<skip();>>

class PP {
<<
	set<string> defined_logical_variables;
	set<string> defined_integer_variables;
	set<string> defined_real_variables;
	set<string> defined_complex_variables;
	set<string> defined_quaternion_variables;
	set<string> defined_logical_vector_variables;
	set<string> defined_integer_vector_variables;
	set<string> defined_real_vector_variables;
	set<string> defined_complex_vector_variables;
	set<string> defined_quaternion_vector_variables;
	set<string> defined_matrix_variables;
	set<string> defined_functions;
	set<string> defined_operators;
	set<char> allowed_letters;
	bool C_precedence, type_check, booleans, sets, functions;
	bool lists;
	AST *prev, *prevm;
//	bool prevBool, prevInteger, prevInaRing, prevPolynomial, prevRational, prevReal, prevConstant;
public:
	void convert2std(int type, string &s)
	{
		if (s[0]=='\\') s.erase(0,1);
		switch (type)
		{
			case CONST: if (s[0]=='%')
			              if (tolower(s[1])=='e') s="e";
				      else s="i";
				    break;
			case VARIABLE: break;
			case ALPHA: if (s[0]=='A') s="Alpha"; else s="alpha"; break;
			case BETA: if (s[0]=='B') s="Beta"; else s="beta"; break;
			case GAMMA: if (s[0]=='G') s="Gamma"; else s="gamma"; break;
			case DELTA: if (s[0]=='D') s="Delta"; else s="delta"; break;
			case EPSILON: if (s[0]=='E') s="Epsilon"; else s="epsilon"; break;
			case ZETA: if (s[0]=='Z') s="Zeta"; else s="zeta"; break;
			case ETA: if (s[0]=='E' || s[0]=='…') s="Eta"; else s="eta"; break;
			case THETA: if (s[0]=='T') s="Theta"; else s="theta"; break;
			case IOTA: if (s[0]=='I') s="Iota"; else s="iota"; break;
			case KAPPA: if (s[0]=='K') s="Kappa"; else s="kappa"; break;
			case LAMBDA: if (s[0]=='L') s="Lambda"; else s="lambda"; break;
			case MU: if (s[0]=='M') s="Mu"; else s="mu"; break;
			case NU: if (s[0]=='N') s="Nu"; else s="nu"; break;
			case XI: if (s[0]=='K' || s[0]=='X') s="Xi"; else s="xi"; break;
			case OMICRON: if (s[0]=='O') s="Omicron"; else s="omicron"; break;
			case PI: if (s[0]=='%') s="pi"; else if (s=="PI" || s=="PÕ") s="Pi"; else s="pi"; break;
			case RHO: if (s[0]=='R') s="Rho"; else s="rho"; break;
			case SIGMA: if (s[0]=='S') s="Sigma"; else s="sigma"; break;
			case TAU: if (s[0]=='T') s="Tau"; else s="tau"; break;
			case UPSILON: if (s[0]=='U' || s[0]=='‹') s="Upsilon"; else s="upsilon"; break;
			case PHI: if (s[0]=='P' || s[0]=='F') s="Phi"; else s="phi"; break;
			case CHI: if (s[0]=='C' || s[0]=='K') s="Chi"; else s="chi"; break;
			case PSI: if (s[0]=='P') s="Psi"; else s="psi"; break;
			case OMEGA: if (s[0]=='O' || s[0]=='”') s="Omega"; else s="omega"; break;
			default: break;
		}
	}

	bool in(int type, const char *s, set<string> &t)
	{
		return in(type, string(s), t);
	}

	bool in(int type, string s, set<string> &t)
	{
		convert2std(type, s);
		bool retval=t.find(s)!=t.end();
		return retval;
	}

	void put(int type, const char *s, set<string> &t)
	{
		put(type,string(s),t);
	}

	void put(int type, string s, set<string> &t)
	{
		convert2std(type, s);
		t.insert(s);
	}

	void remove(int type, const char *s, set<string> &t)
	{
		remove(type,string(s),t);
	}

	void remove(int type, string s, set<string> &t)
	{
		convert2std(type, s);
		if (in(type, s, t)) t.erase(s);
	}

	void set_C_precedence(bool b)
	{
		C_precedence=b;
	}

	bool get_C_precedence()
	{
		return C_precedence;
	}

	void set_booleans(bool b)
	{
		booleans=b;
	}

	bool get_booleans()
	{
		return booleans;
	}

	void set_sets(bool b)
	{
		sets=b;
	}

	bool get_sets()
	{
		return sets;
	}

	void set_functions(bool b)
	{
		functions=b;
	}

	bool get_functions()
	{
		return functions;
	}

	void set_allowed_letters(const char *in)
	{
		for (const char *i=in; *i!=0; i++)
		{
			if (*i>='a' && *i<='z')
			{
				allowed_letters.insert(*i);
				allowed_letters.insert(*i-'a'+'A');
			}
			if (*i>='A' && *i<='Z')
			{
				allowed_letters.insert(*i);
				allowed_letters.insert(*i-'A'+'a');
			}
		}
	}

	bool allowed(ANTLRTokenType type, const char *text)
	{
		char t=*text;
		if (type==VARIABLE)
			if (allowed_letters.find(t)!=allowed_letters.end()) return true;
			else return false;
		else if (type==CONST)
		{
			if (t=='%') return true;
			else if (allowed_letters.find(t)!=allowed_letters.end()) return true;
			else return false;
		}
		else return true;
	}

	void set_type_check(bool b)
	{
		type_check=b;
	}

	bool get_type_check()
	{
		return type_check;
	}

	void setprev(const AST *a)
	{
/*		prevBool=a->isBool;
		prevInteger=a->isInteger;
		prevInaRing=a->isInanIntegralDomain;
		prevPolynomial=a->isPolynomial;
		prevRational=a->isRational;
		prevReal=a->isReal;
		prevConstant=a->isConstant;*/
		prev->isBool=a->isBool;
		prev->isInteger=a->isInteger;
		prev->isInanIntegralDomain=a->isInanIntegralDomain;
		prev->isPolynomial=a->isPolynomial;
		prev->isRational=a->isRational;
		prev->isReal=a->isReal;
		prev->isConstant=a->isConstant;
	}

	void setAND(AST *p0, AST *p1, AST *r)
	{
		r->isBool=p0->isBool && p1->isBool;
		r->isInteger=p0->isInteger && p1->isInteger;
		r->isInanIntegralDomain=p0->isInanIntegralDomain && p1->isInanIntegralDomain;
		r->isPolynomial=p0->isPolynomial && p1->isPolynomial;
		r->isRational=p0->isRational && p1->isRational;
		r->isReal=p0->isReal && p1->isReal;
		r->isConstant=p0->isConstant && p1->isConstant;
	}

	~PP()
	{
	}
>>

/*inpset:	   (s:log_expr (NL^ inpset | EoF! <<#0=#(#[NL,"\n"],#s);>>))
	 | (NL^ inpset)
	 |
	;
*/
/*set_expr:  (enum_expr (INTERSECT | UNION | EXCEPT) enum_expr)? (enum_expr (INTERSECT^ | UNION^ | EXCEPT^) enum_expr)
	 | (enum_expr (INTERSECT | UNION | EXCEPT))? (enum_expr (INTERSECT | UNION | EXCEPT) log_expr)
	 |  (log_expr (INTERSECT | UNION | EXCEPT) enum_expr)? (log_expr (INTERSECT^ | UNION^ | EXCEPT^) enum_expr)
	 | (log_expr (INTERSECT | UNION | EXCEPT) log_expr)
	 ;*/

//Boolean operators allowed.
inplog:<<lists=true;>>
	   (LETTER ASSIGN log_expr)? (l0:LETTER <<put(l0->getType(),l0->getText(),defined_logical_variables);>> ASSIGN^ log_expr ((NL! inplog) | EoF!))
//	 | (LETTER ASSIGN)? (l1:LETTER << remove(l1->getType(),l1->getText(),defined_logical_variables);>> ASSIGN^ add_expr ((NL! inplog) | EoF!))
	 | (LETTER LBRACKET index_expr RBRACKET ASSIGN log_expr)?
	   ((l2:LETTER <<put(l2->getType(),l2->getText(),defined_logical_vector_variables);>> LBRACKET^ index_expr RBRACKET) ASSIGN^ log_expr ((NL! inplog) | EoF!))
	 | <<functions>>? (letter LPAREN index_expr (COMMA index_expr)* RPAREN ASSIGN)? ((letter LPAREN! i0:index_expr (COMMA index_expr)* RPAREN! <<#0=#(#[UFUNCTION,"UFUNCTION"],#0);>>) (ASSIGN! e0:log_expr! ((NL! inp0:inplog!) | EoF!)) <<#0=#(#[ASSIGN,":="],#0,#e0,#inp0);>> )
	 | (LETTER UNDERSCORE index_expr ASSIGN log_expr)?
	   ((l3:LETTER <<put(l3->getType(),l3->getText(),defined_logical_vector_variables);>> UNDERSCORE^ index_expr ) ASSIGN^ log_expr ((NL! inplog) | EoF!))
//	 | (LETTER LBRACKET index_expr RBRACKET ASSIGN add_expr)?
//	   ((l4:LETTER <<remove(l4->getType(),l4->getText(),defined_logical_vector_variables);>> LBRACKET^ index_expr RBRACKET) ASSIGN^ add_expr ((NL! inplog) | EoF!))
//	 | (LETTER UNDERSCORE index_expr ASSIGN add_expr)?
//	   ((l5:LETTER <<remove(l5->getType(),l5->getText(),defined_logical_vector_variables);>> UNDERSCORE^ index_expr ) ASSIGN^ add_expr ((NL! inplog) | EoF!))
	 | (LETTER LBRACKET index_expr COMMA index_expr RBRACKET ASSIGN)?
	   ((l6:LETTER <<put(l6->getType(),l6->getText(),defined_matrix_variables);>> LBRACKET^ index_expr COMMA index_expr RBRACKET) ASSIGN^ log_expr ((NL! inplog) | EoF!))
	 | (LETTER UNDERSCORE index_expr COMMA index_expr ASSIGN)?
	   ((l7:LETTER <<put(l7->getType(),l7->getText(),defined_matrix_variables);>> UNDERSCORE^ index_expr COMMA index_expr) ASSIGN^ log_expr ((NL! inplog) | EoF!))
	 | (LETTER UNDERSCORE LPAREN index_expr COMMA index_expr RPAREN ASSIGN)?
	   ((l8:LETTER <<put(l8->getType(),l8->getText(),defined_matrix_variables);>> UNDERSCORE^ LPAREN! index_expr COMMA index_expr RPAREN!) ASSIGN^ log_expr ((NL! inplog) | EoF!))
//	 | (add_expr COMMA)? (en:set_enum_expr ((NL^ inplog) | EoF!<<#0=#(#[NL,"\n"],#en);>>))
	 | (l:log_expr ((NL^ inplog) | EoF!<<#0=#(#[NL,"\n"],#l);>>))
//	 | (a:add_expr ((NL^ inplog) | EoF!<<#0=#(#[NL,"\n"],#a);>>))
	 | NL^ inplog
	 |
	;

index_expr:/*(log_expr)? log_expr
	 |*/ add_expr
	;

index_value: (LPAREN add_expr)? (LPAREN^ add_expr RPAREN)
//	 | (log_variable)? log_variable
	 | neg_fact_minus_func
	;

log_expr: <<C_precedence>>? log_exprC
	 | log_exprPascal
	;

log_exprPascal: (l0:log_expr1! <<#0=#l0;>>
                    (
                      (IMPLY)? (IMPLY! l1:log_expr1! <<#0=#(#[IMPLY,"->"],#0,#l1);>>)
//                      | (EG! l2:log_expr1! <<#0=#(#[IMPLY,"=>"],#0,#l2);>>)
                    )*
                )
	;


log_exprC: (l0:log_expr0! <<#0=#l0;>> 
               (
	         (IMPLY)? (IMPLY! l1:log_expr0! <<#0=#(#[IMPLY,"->"],#0,#l1);>>)
//		 | (EG! l2:log_expr0! <<#0=#(#[IMPLY,"=>"],#0,#l2);>>)
	       )*
	   )
	;

log_expr1: log_val1 ((EQUAL)? (EQUAL^ log_val1) //Pascal like precedence
	            |(NEQ^ log_val1)
		    )*
	;

log_val1: (log_val_or1 (((AND)? (AND^ log_val_or1) | (NAND^ log_val_or1))*));

log_val_or1: (neg_log_value // Pascal like precedence
	              ((OR)? (OR^ neg_log_value)
	             | (ABSSIGN)? (ABSSIGN! l1:neg_log_value! <<#0=#(#[OR,"|"],#0,#l1);>>)
	             | (NOR)? (NOR^ neg_log_value)
	             | (XOR^ neg_log_value))*
	   )
	;

log_expr0: (log_expr_or0 (((AND)? (AND^ log_expr_or0) | (NAND^ log_expr_or0))*));

log_expr_or0: (log_val0 // C like precedence
	             ( (OR)? (OR^ log_val0)
	             | (ABSSIGN)? (ABSSIGN! l1:log_val0! <<#0=#(#[OR,"|"],#0,#l1);>>)
	             | (NOR)? (NOR^ log_val0)
	             | (XOR^ log_val0))*
	   )
	;

log_val0:   (neg_log_value EQUAL)? neg_log_value EQUAL^ neg_log_value // C like precedence
	 | (neg_log_value NEQ)? neg_log_value NEQ^ neg_log_value
	 | neg_log_value
	;

neg_log_value:
	   (NOT^ neg_log_value)
	 | (FACTORIAL neg_log_value)? (FACTORIAL! l:neg_log_value <<#0=#(#[NOT,"!"],#l);>>)
	 | log_value
	;

log_value: (add_expr (/*EQUAL |*/ LESS | GREATER | LE | EL | GE | EG /*| NEQ*/))? rel_expr
	 | set_bool_expr//LETTER//log_variable //letter
	;

set_bool_expr: <<sets>>? (elements ((NI^ | IN^) elements)*)
	 | <<sets>>? ((FORALL^ | EXISTS^) set_bool_expr COLON! log_expr)
	 | elements
	;

elements: (set_expr COMMA)? set_enum_expr
	 | set_log_expr
	;

set_log_expr: <<sets>>? (set_expr ((SUPSET^ | SUBSET^ | SUBSETEQ^ | SUPSETEQ^ /*| EQUAL^ | NEQ^*/) set_expr)*)
	 | set_enum_expr
	;

set_enum_expr: (set_expr COMMA)? set_enum_expr0
	 | set
	;

set_enum_expr0: s0:set_expr <<#0=#(#[ENUMERATE, ","], #s0);>> (COMMA! s1:set_expr)+
	;

set_expr: <<sets>>? (set_expr0 ((INTERSECT^ | UNION^ | EXCEPT^) set_expr0)*)
	 | set_expr0
	;

set_expr0: <<sets>>? (set (CROSS^set)*)
	 | set
	;

set:	 <<sets>>? (LBRACE log_value (ABSSIGN | COLON))? (LBRACE! e0:log_value! (ABSSIGN! | COLON!) e1:log_expr! RBRACE! <<#0=#(#[SETDEF, "{ | }"], #e0, #e1);>>)
	 | <<sets>>? (LBRACE! {s:set_enum_expr!<<#0=#(#[LBRACE, "{"], #s);>>} RBRACE!<<if (#s==NULL) #0=#[EMPTYSET, "0"];>>)
	 | add_expr
	;

log_variable:
	   <<in(LT(1)->getType(), LT(1)->getText(), defined_logical_vector_variables)>>? (LETTER LBRACKET)?
	   (LETTER LBRACKET^ index_expr RBRACKET)
	 | <<in(LT(1)->getType(), LT(1)->getText(), defined_logical_vector_variables)>>?
	   (LETTER UNDERSCORE)? (LETTER UNDERSCORE^ index_value)
	 | <<in(LT(1)->getType(), LT(1)->getText(), defined_logical_variables)>>? LETTER
	;

rel_expr:  (add_expr ((LESS^ add_expr)
	             |(LE^ add_expr)
	             |(EL^ add_expr)
	             |(GREATER^ add_expr)
	             |(GE^ add_expr)
	             |(EG^ add_expr)
	             )*
	   )
	;

equation: add_expr EQUAL^ add_expr
	;

//Just equations allowed in formulas, boolean expressions, ... not.
inp_eqn:   (e:equation ((NL^ inp_eqn) | EoF!<<#0=#(#[NL,"\n"],#e);>>))
	 | NL^ inp_eqn
	 |
	;

//Just one relation allowed per formula.
inp:	  <<lists=true;>> (letter LPAREN index_expr (COMMA index_expr)* RPAREN ASSIGN index_expr)? ((letter LPAREN! i0:index_expr (COMMA index_expr)* RPAREN! <<#0=#(#[UFUNCTION,"UFUNCTION"],#0);>>) (ASSIGN! e0:index_expr! ((NL! inp0:inp!) | EoF!)) <<#0=#(#[ASSIGN,":="],#0,#e0,#inp0);>> )
	 | (letter ASSIGN rel_expr_inp)? (letter ASSIGN^ rel_expr_inp ((NL! inp) | EoF!))
	 | (letter ASSIGN)? (letter ASSIGN^ add_expr ((NL! inp) | EoF!))
	 | (rel_expr_inp)? (r:rel_expr_inp ((NL^ inp) | EoF!<<#0=#(#[NL,"\n"],#r);>>))
	 | (add_expr COMMA)? (en:enum_expr ((NL^ inp) | EoF! <<#0=#(#[NL,"\n"],#en);>>))
	 | (a:add_expr 
	 <<
#if DEBUG
	   printf("b:%d, i:%d, R:%d, r:%d, p:%d, a:%d, c:%d\n", #a->isBool, #a->isInteger, #a->isReal, #a->isRational, #a->isPolynomial, #a->isInanIntegralDomain, #a->isConstant);
		cout << prevm->isPolynomial << prev->isPolynomial;

#else
#endif
	 >>
	 ((NL^ inp) | EoF!<<#0=#(#[NL,"\n"],#a);>>))
	 | NL^ inp
	 |
	;

rel_expr_inp:  (add_expr ((EQUAL^ add_expr)
	             |(LESS^ add_expr)
	             |(LE^ add_expr)
	             |(EL^ add_expr)
	             |(GREATER^ add_expr)
	             |(GE^ add_expr)
	             |(EG^ add_expr)
	             |(NEQ^ add_expr)
	             )+
	   )
	;

enum_expr: l0:add_expr <<#0=#(#[ENUMERATE, ", "], #l0);>>
	   (COMMA! e0:add_expr)+
	;

add_expr:
	(a0:neg_mult_expr
	<<
	  prev=#a0;
	>>)
	(   (p:PLUS^ a1:neg_mult_expr
	     <<
/*	       #p->isBool=false;
	       #p->isInteger=prevInteger && #a1->isInteger;
	       #p->isInanIntegralDomain=prevInaRing && #a1->isInanIntegralDomain;
	       #p->isPolynomial=prevPolynomial && #a1->isPolynomial;
	       #p->isRational=prevRational && */
	       setAND(prev, #a1, #p);
	       #p->isBool=false;
	       #p->isPolynomial=prev->isPolynomial || #a1->isPolynomial;
	       prev=#p;
	     >>
	    )
	  | (m:MINUS^ a2:neg_mult_expr
	     <<
	       setAND(prev, #a2, #m);
	       #m->isBool=false;
	       #m->isPolynomial=prev->isPolynomial || #a2->isPolynomial;
	       prev=#m;
	     >>

	    )
	)*
	;

neg_mult_expr:
	(   MINUS n:neg_mult_expr <<AST *n=new AST(NEG,"-"); #0=#(n,#n); n->copyProperties(*#n);>>
	)
	  | mult_expr
	;

mult_expr:
	p1:pow_expr! <<#0=prevm=#p1;>>
	(   (MULT)? (MULT! n0:neg_pow_expr!
	     <<
	       AST *m=new AST(MULT,"*");
	       #0=#(m,#0,#n0);
	       setAND(prevm,#n0,m);
	       m->isBool=false;
	       m->isPolynomial=prevm->isPolynomial || #n0->isPolynomial;
	       prevm=m;
	     >>
	    )
	  | (DIV)? (DIV!  n1:neg_pow_expr!
	     <<
	       AST *d=new AST(DIV,"/");
	       #0=#(d,#0,#n1);
	       setAND(prevm,#n1,d);
	       d->isBool=false;
	       d->isInteger=false;
	       d->isPolynomial=(prevm->isPolynomial || prevm->isConstant) && #n1->isConstant;
	       d->isInanIntegralDomain=false;
	       prevm=d;
	     >>
	    )
	  | (DIVI)? (DIVI! n2:neg_pow_expr!
	     <<
	       AST *d=new AST(DIVI,"Div");
	       #0=#(d,#0,#n2);
	       setAND(prevm,#n2,d);
#if DEBUG
#else
	       if (type_check && !(d->isInteger || d->isInanIntegralDomain || d->isPolynomial || (prevm->isPolynomial && #n2->isInanIntegralDomain))) setSignal(2);
#endif
	       d->isBool=false;
//	       d->isInteger=d->isInteger;
	       d->isPolynomial=(d->isPolynomial || d->isConstant);
//	       d->isInanIntegralDomain=d->isInteger;
	       prevm=d;
	     >>
	    )
	  | (MOD)? (MOD! n3:neg_pow_expr!
	     <<
	       AST *d=new AST(MOD,"Mod");
	       #0=#(d,#0,#n3);
	       setAND(prevm,#n3,d);
#if DEBUG
#else
	       if (type_check && !(d->isInteger || d->isInanIntegralDomain || d->isPolynomial || (prevm->isPolynomial && #n3->isInanIntegralDomain))) setSignal(2);
#endif
	       d->isBool=false;
	       d->isPolynomial=(prevm->isPolynomial || prevm->isConstant);
	       prevm=d;
	     >>
	    )
	  | (abs_fact)? (p2:pow_expr!
	     <<
	       AST *m=new AST(MULTNONE,"*");
	       #0=#(m,#0,#p2);
	       setAND(prevm,#p2,m);
	       m->isBool=false;
	       m->isPolynomial=prevm->isPolynomial || #p2->isPolynomial;
	       prevm=m;
	     >>
	    )
	)*
	;

neg_pow_expr:
	    (MINUS n:neg_pow_expr <<AST *n=new AST(NEG,"-"); #0=#(n,#n); n->copyProperties(*#n);>>)
	  | LBRACE! add_expr RBRACE!
	  | pow_expr
	;

abs_fact:
	    (ABSSIGN)? (ABSSIGN! a:add_expr! ABSSIGN! <<AST *a=new AST(ABS,"ABS"); #0=#(a,#a); a->copyProperties(*#a);>>)
	  | factorial
	;

abs_fact_minus_func:
	    (ABSSIGN)? (ABSSIGN! a:add_expr! ABSSIGN! <<AST *a=new AST(ABS,"ABS"); #0=#(a,#a); a->copyProperties(*#a);>>)
	  | fact
	;

pow_expr:
	(   a:abs_fact
	)
	{
	    (CIRCUM)? c:CIRCUM^ n:neg_pow_expr
	    <<
	      #c->isBool=false;
	      #c->isInteger=#a->isInteger && #n->isInteger;
	      #c->isPolynomial=#n->isInteger && #n->isConstant && #a->isPolynomial;
	      #c->isInanIntegralDomain=#n->isInteger && #n->isConstant && #a->isInanIntegralDomain;
	      #c->isRational=#n->isInteger && #a->isRational;
	      #c->isReal=#a->isReal && #n->isReal;
	      #c->isConstant=#a->isConstant && #n->isConstant;
	      #c->isPolynomial=#c->isPolynomial || #c->isConstant;
	    >>
	}
	;

funct:
	  SIN^
	| COS^
	| SEC^
	| COSEC^
	| (TAN | TG) <<#0=#[TAN,"TAN"];>>
	| (COT | CTG) <<#0=#[COT,"COT"];>>
	| (SINH | SH) <<#0=#[SINH,"SINH"];>>
	| (COSH | CH) <<#0=#[COSH,"COSH"];>>
	| SECH^
	| COSECH^
	| (TANH | TGH) <<#0=#[TANH,"TANH"];>>
	| (COTH | CTGH) <<#0=#[COTH,"COTH"];>>
	| ARCSIN^
	| ARCCOS^
	| ARCSEC^
	| ARCCOSEC^
	| (ARCTAN | ARCTG) <<#0=#[ARCTAN,"ARCTAN"];>>
	| (ARCCOT | ARCCTG) <<#0=#[ARCCOT,"ARCCOT"];>>
	| ARCSINH^
	| ARCCOSH^
	| ARCSECH^
	| ARCCOSECH^
	| ARCTANH^
	| ARCCOTH^
	| EXP^
	| ARG^
	| IM^
	| RE^
	| CONJUGATE^
	| SQRT^
	| LN^
	| COMPLEMENTER^
	| TRANSPONATE^
	;

neg_fact:
	    (MINUS n:neg_fact <<AST *n=new AST(NEG,"-"); #0=#(n,#n); n->copyProperties(*#n);>>)
	  | abs_fact
	;

neg_fact_minus_func:
	    (MINUS n:neg_fact_minus_func <<AST *n=new AST(NEG,"-"); #0=#(n,#n); n->copyProperties(*#n);>>)
	  | abs_fact_minus_func
	;

letter:
	<<allowed(LT(1)->getType(), LT(1)->getText())>>? (LETTER LBRACKET)?
	  (l0:LETTER
	   <<
	     string s(l0->getText());
	     convert2std(l0->getType(),s);
	     if (l0->getType()==CONST) #l0->isConstant=true;
	     else #l0->isConstant=false;//TODO: This is not correct, when type modifiers can be used.
	     #l0->isPolynomial=true;
	     #l0->isInanIntegralDomain=true;
	     l0->setText(s.c_str());
	   >>
		     LBRACKET^ index_expr {COMMA index_expr} RBRACKET)
	 | <<allowed(LT(1)->getType(), LT(1)->getText())>>? (LETTER UNDERSCORE LPAREN index_expr COMMA)?
	  (l1:LETTER
	   <<
	     string s(l1->getText());
	     convert2std(l1->getType(),s);
	     if (l1->getType()==CONST) #l1->isConstant=true;
	     else #l1->isConstant=false;//TODO: This is not correct, when type modifiers can be used.
	     #l1->isPolynomial=true;
	     #l1->isInanIntegralDomain=true;
	     l1->setText(s.c_str());
	   >>
	            UNDERSCORE^ LPAREN! index_expr COMMA index_expr RPAREN!)
	 | <<allowed(LT(1)->getType(), LT(1)->getText())>>? (LETTER UNDERSCORE index_expr COMMA)?
	  (l2:LETTER
	   <<
	     string s(l2->getText());
	     convert2std(l2->getType(),s);
	     if (l2->getType()==CONST) #l2->isConstant=true;
	     else #l2->isConstant=false;//TODO: This is not correct, when type modifiers can be used.
	     #l2->isPolynomial=true;
	     #l2->isInanIntegralDomain=true;
	     l2->setText(s.c_str());
	   >>
		    UNDERSCORE^ index_expr COMMA index_value)
	 | <<allowed(LT(1)->getType(), LT(1)->getText())>>? (LETTER UNDERSCORE)?
	  (l3:LETTER
	   <<
	     string s(l3->getText());
	     convert2std(l3->getType(),s);
	     if (l3->getType()==CONST) #l3->isConstant=true;
	     else #l3->isConstant=false;//TODO: This is not correct, when type modifiers can be used.
	     #l3->isPolynomial=true;
	     if (s=="i")
	     {
	       #l3->isReal=false;
	       #l3->isInanIntegralDomain=true;
	     }
	     l3->setText(s.c_str());
	   >>
		    UNDERSCORE^ index_value)
	 | <<allowed(LT(1)->getType(), LT(1)->getText())>>?[/*Comment out if DEBUG*/setSignal(3);/*till this.*/]
	  (l4:LETTER
	   <<
	     string s(l4->getText());
	     convert2std(l4->getType(),s);
//	     printf("%d\n",l4->getType());
	     if (l4->getType()==CONST) #l4->isConstant=true;
	     else #l4->isConstant=false;//TODO: This is not correct, when type modifiers can be used.
	     #l4->isPolynomial=true;
	     if (s=="i")
	     {
	       #l4->isReal=false;
	       #l4->isInanIntegralDomain=true;
	       #l4->isPolynomial=false;
	       #l4->isInteger=false;
	       #l4->isRational=false;
	       #l4->isConstant=true;
	     }
	     if (s=="pi")
	     {
	       #l4->isReal=true;
	       #l4->isInanIntegralDomain=false;
	       #l4->isPolynomial=false;
	       #l4->isRational=false;
	       #l4->isInteger=false;
	       #l4->isConstant=true;
	     }
	     l4->setText(s.c_str());
	   >>
	  )
	;

lparen: <<sets || booleans>>? (LPAREN^ log_expr RPAREN!)
	| (LPAREN! a:add_expr! lparen_ending[#a])
	| <<lists>>? (LBRACKET RBRACKET)? (LBRACKET! RBRACKET^)
	| <<lists>>? (LBRACKET! b:add_expr! lbracket_ending[#b])
	;

lparen_ending[AST *a]: <<lists>>? ((COMMA!  add_expr)+ RPAREN! <<#0=#(#[LPAREN,"("],#(#[ENUMERATE,","],a,#0),#[RPAREN,")"]);>>)
	| (RPAREN <<#0=#(#[LPAREN,"("],a,#0);>>)
	;

lbracket_ending[AST *a]: ((COMMA! add_expr)+ RBRACKET! <<#0=#(#[RBRACKET,"]"],#(#[ENUMERATE, ","],a,#0));>>)
	| RBRACKET! <<#0=#(#[RBRACKET,"]"],a);>>
	;

factfunc: <<functions>>? (letter LPAREN)? (letter (LPAREN! index_expr (COMMA index_expr)* RPAREN! <<#0=#(#[UFUNCTION,"UFUNCTION"],#0);>>))
	| fact
	;

fact:
		  (i:INTNUM! <<AST *i=new AST(NUM, #i->getText()); #0=i; i->isInteger=true; i->isInanIntegralDomain=true; i->isRational=true; i->isConstant=true; i->isPolynomial=false;>>)
		| (n:NUM^ <<#n->isInteger=false; #n->isRational=true; #n->isConstant=true; #n->isPolynomial=false;>>)
		| (inf:INFTY^ <<#inf->isReal=false; #inf->isConstant=true; #inf->isPolynomial=false;>>)
		| (UNDEFINED)
		| (letter)
		| (DOTS)
		| <<booleans || sets>>? LOG_CONST
//		| LETTER
		| lparen
/*		| (LPAREN add_expr COMMA)? (lp0:LPAREN^ lpe:enum_expr <<#lp0->copyProperties(*#lpe); prevm->copyProperties(*#lpe); prev->copyProperties(*#lpe);>> RPAREN)
		| (LBRACKET add_expr COMMA)? (LBRACKET! lpe0:enum_expr rb0:RBRACKET^<<#rb0->copyProperties(*#lpe0); prevm->copyProperties(*#lpe0); prev->copyProperties(*#lpe0);>> )
//		| <<sets>>? (lp:LPAREN^ lps:set_bool_expr <<#lp->copyProperties(*#lps); prevm->copyProperties(*#lps); prev->copyProperties(*#lps);>> RPAREN)
		| <<booleans || sets>>? (lp1:LPAREN^ lpl:log_expr <<#lp1->copyProperties(*#lpl); prevm->copyProperties(*#lpl); prev->copyProperties(*#lpl);>> RPAREN)
		| <<!sets && !booleans>>? (lp2:LPAREN^ lpa:add_expr <<#lp2->copyProperties(*#lpa); prevm->copyProperties(*#lpa); prev->copyProperties(*#lpa);>> RPAREN)*/
		| (funct LBRACKET)? (fun0:funct!
			LBRACKET! <<lists=false;>> arg0:add_expr! <<lists=true;>>RBRACKET!
			<<
			  AST *f=new AST(FUNCTION, "FUNCTION");
			  #0=#(f,#fun0,#arg0);
			  f->isRational=false;
			  f->isInteger=false;
			  f->isBool=false;
			  f->isPolynomial=false;
			  if (#arg0->isInanIntegralDomain && #fun0->type()==SQRT) f->isInanIntegralDomain=true;
			  else f->isInanIntegralDomain=false;
			  f->isReal=#arg0->isReal;
			  f->isConstant=#arg0->isConstant;
			>>)
		| (funct {CIRCUM neg_pow_expr} LPAREN)? (fun1:funct!<<lists=false;>> 
			({CIRCUM! exp:neg_pow_expr!}
			(LPAREN! arg:add_expr! <<lists=true;>> RPAREN)
			<<
			  AST *f=new AST(FUNCTION, "FUNCTION");
			  if (#exp==NULL) #0=#(f,#fun1,#arg);
			  else #0=#(f,#fun1,#arg,#exp);

			  f->isRational=false;
			  f->isInteger=false;
			  f->isBool=false;
			  f->isPolynomial=false;
			  if (#arg->isInanIntegralDomain && #fun1->type()==SQRT) f->isInanIntegralDomain=true;
			  else f->isInanIntegralDomain=false;
			  f->isReal=#arg->isReal;
			  f->isConstant=#arg->isConstant;
			>>)
		  )
		| /*(funct CIRCUM neg_pow_expr ~LPAREN)?*/ (fun5:funct! <<lists=false;>> 
			({CIRCUM! exp5:neg_pow_expr!}
			(arg5:neg_pow_expr!)<<lists=false;>> 
			<<
			  AST *f=new AST(FUNCTION, "FUNCTION");
			  if (#exp5==NULL) #0=#(f,#fun5,#arg5);
			  else #0=#(f,#fun5,#arg5,#exp5);

			  f->isRational=false;
			  f->isInteger=false;
			  f->isBool=false;
			  f->isPolynomial=false;
			  if (#arg5->isInanIntegralDomain && #fun5->type()==SQRT) f->isInanIntegralDomain=true;
			  else f->isInanIntegralDomain=false;
			  f->isReal=#arg5->isReal;
			  f->isConstant=#arg5->isConstant;
			>>)
		  )
		| (LOG LBRACKET add_expr COMMA)? (tlog0:LOG! <<lists=false;>> (LBRACKET! log1:add_expr! COMMA! arg2:add_expr! <<lists=true;>> RBRACKET!
		    <<
			AST *f=new AST(FUNCTION, "FUNCTION");
		        #0=#(f,#[LOG,tlog0->getText()],#[UNDERSCORELOG,"_"],#log1,#arg2);
			  f->isRational=false;
			  f->isInteger=false;
			  f->isBool=false;
			  f->isPolynomial=false;
			  f->isInanIntegralDomain=false;
			  f->isReal=#arg2->isReal;
			  f->isConstant=#arg2->isConstant;
		    >>)
		   )
		| (LOG LBRACKET add_expr RBRACKET)? (tlog2:LOG! <<lists=false;>> (LBRACKET! arg3:add_expr! <<lists=true;>> RBRACKET!
		    <<
			AST *f=new AST(FUNCTION, "FUNCTION");
			#0=#(f,#[LOG,tlog2->getText()],#arg3);
			  f->isRational=false;
			  f->isInteger=false;
			  f->isBool=false;
			  f->isPolynomial=false;
			  f->isInanIntegralDomain=false;
			  f->isReal=#arg3->isReal;
			  f->isConstant=#arg3->isConstant;
		    >>)
		   )
		
		| (LOG {UNDERSCORE neg_fact} {CIRCUM neg_pow_expr} LPAREN)? (tlog1:LOG! <<lists=false;>>
		   (
		        {UNDERSCORE! log0:neg_fact!}
		        {CIRCUM! exp1:neg_pow_expr!}
		        LPAREN! arg1:add_expr! <<lists=true;>> RPAREN!
		    <<
			AST *f=new AST(FUNCTION, "FUNCTION");
		        if (#exp1==NULL)
		          if (#log0!=NULL) #0=#(f,#[LOG,tlog1->getText()],#[UNDERSCORELOG,"_"],#log0,#arg1);
			  else #0=#(f,#[LOG,tlog1->getText()],#arg1);
			else
			  if (#log0!=NULL) #0=#(f,#[LOG,tlog1->getText()],#[UNDERSCORELOG,"_"],#log0,#arg1,#exp1);
			  else #0=#(f,#[LOG,tlog1->getText()],#arg1,#exp1);
			f->isRational=false;
			f->isInteger=false;
			f->isBool=false;
			f->isPolynomial=false;
			f->isInanIntegralDomain=false;
			f->isReal=#arg1->isReal;
			f->isConstant=#arg1->isConstant;
		    >>
		    )
		  )
		| /*(LOG UNDERSCORE neg_fact CIRCUM neg_pow_expr ~LPAREN)?*/ (tlog8:LOG! <<lists=false;>>
		   (    
		        {UNDERSCORE! log8:neg_fact!}
		        {CIRCUM! exp8:neg_pow_expr!}
		        arg8:neg_pow_expr!<<lists=true;>> 
		    <<
			AST *f=new AST(FUNCTION, "FUNCTION");
		        if (#exp8==NULL)
		          if (#log8!=NULL) #0=#(f,#[LOG,tlog8->getText()],#[UNDERSCORELOG,"_"],#log8,#arg8);
			  else #0=#(f,#[LOG,tlog8->getText()],#arg8);
			else
			  if (#log8!=NULL) #0=#(f,#[LOG,tlog8->getText()],#[UNDERSCORELOG,"_"],#log8,#arg8,#exp8);
			  else #0=#(f,#[LOG,tlog8->getText()],#arg8,#exp8);
//#0=#(f,#[LOG,tlog8->getText()],#[UNDERSCORELOG,"_"],#log8,#arg8,#exp8);
			f->isRational=false;
			f->isInteger=false;
			f->isBool=false;
			f->isPolynomial=false;
			f->isInanIntegralDomain=false;
			f->isReal=#arg8->isReal;
			f->isConstant=#arg8->isConstant;
		    >>
		    )
		  )
		| (LG LBRACKET)? (lg0:LG! <<lists=false;>> (LBRACKET! arglg1:add_expr! <<lists=true;>> RBRACKET!
		  <<
		    AST *f=new AST(FUNCTION, "FUNCTION");
		    #0=#(f,#[LOG,lg0->getText()],#[UNDERSCORELOG,"_"],#[NUM,"10"],#arglg1,#explg);
			f->isRational=false;
			f->isInteger=false;
			f->isBool=false;
			f->isPolynomial=false;
			f->isInanIntegralDomain=false;
			f->isReal=#arglg1->isReal;
			f->isConstant=#arglg1->isConstant;
		  >>
		     )
		   
		  )
		| (LG {CIRCUM neg_pow_expr} LPAREN)? (lg:LG! <<lists=false;>> ({CIRCUM! explg:neg_pow_expr!} 
		   
		     LPAREN! arglg:add_expr! <<lists=true;>> RPAREN!
		     <<
		       AST *f=new AST(FUNCTION, "FUNCTION");
		       #0=#(f,#[LOG,lg->getText()],#[UNDERSCORELOG,"_"],#[NUM,"10"],#arglg,#explg);
			f->isRational=false;
			f->isInteger=false;
			f->isBool=false;
			f->isPolynomial=false;
			f->isInanIntegralDomain=false;
			f->isReal=#arglg->isReal;
			f->isConstant=#arglg->isConstant;
		     >>)
		  )
		| (lg10:LG! <<lists=false;>> ({CIRCUM! explg0:neg_pow_expr!}
		   
		     arglg10:neg_pow_expr! <<lists=true;>>
		     <<
		       AST *f=new AST(FUNCTION, "FUNCTION");
		       #0=#(f,#[LOG,lg10->getText()],#[UNDERSCORELOG,"_"],#[NUM,"10"],#arglg10,#explg0);
			f->isRational=false;
			f->isInteger=false;
			f->isBool=false;
			f->isPolynomial=false;
			f->isInanIntegralDomain=false;
			f->isReal=#arglg10->isReal;
			f->isConstant=#arglg10->isConstant;
		     >>)
		  )
		| (ROOT LBRACKET add_expr COMMA)? ((r:ROOT! LBRACKET! <<lists=false;>> n0:add_expr! COMMA! b:add_expr! <<lists=true;>> RBRACKET!
			<<
			  #0=#(#r,#n0,#[LPAREN,"("],#b,#[RPAREN,")"]);
			  #r->isRational=false;
			  #r->isInteger=false;
			  #r->isBool=false;
			  #r->isInanIntegralDomain=(#n0->isInteger && #b->isInteger)?true:false;
			  #r->isReal=false;
			  #r->isPolynomial=#r->isConstant=#n0->isConstant && #b->isConstant;
			>>
			)
		  )
		| (ROOT LBRACKET)? (r2:ROOT^ LBRACKET! <<lists=false;>> n2:add_expr RBRACKET! LPAREN b2:add_expr <<lists=true;>> RPAREN
		   <<
			#r2->isRational=false;
			#r2->isInteger=false;
			#r2->isBool=false;
			#r2->isInanIntegralDomain=false;
			if (#b2->isInteger)
			  if (#n2->isInteger) #r2->isInanIntegralDomain=true;
			#r2->isReal=true;
			#r2->isPolynomial=#r2->isConstant=#n2->isConstant && #b2->isConstant;
		   >>
		  )
		| (ROOT LPAREN add_expr RPAREN LPAREN)? (r3:ROOT^ LPAREN! <<lists=false;>> n3:add_expr RPAREN! LPAREN b3:add_expr <<lists=true;>> RPAREN
		   <<
			#r3->isRational=false;
			#r3->isInteger=false;
			#r3->isBool=false;
			#r3->isInanIntegralDomain=false;
			if (#b3->isInteger)
			  if (#n3->isInteger) #r3->isInanIntegralDomain=true;
			#r3->isReal=true;
			#r3->isPolynomial=#r3->isConstant=#n3->isConstant && #b3->isConstant;
		   >>
		  )
		| (r4:ROOT! LPAREN! <<lists=false;>> n4:add_expr! COMMA! b4:add_expr! <<lists=true;>> RPAREN
		   <<
			#0=#(#r4,#n4,#[LPAREN,"("],#b4,#[RPAREN,")"]);
			#r4->isRational=false;
			#r4->isInteger=false;
			#r4->isBool=false;
			#r4->isInanIntegralDomain=false;
			if (#b4->isInteger)
			  if (#n4->isInteger) #r4->isInanIntegralDomain=true;
			#r4->isReal=true;
			#r4->isPolynomial=#r4->isConstant=#n4->isConstant && #b4->isConstant;
		   >>
		  )
		| (ABS LBRACKET)? (abs0:ABS^ LBRACKET! x0:add_expr RBRACKET!
		   <<
			#abs0->copyProperties(*#x0);
			#abs0->isReal=true;
		   >>
		  )
		| (abs1:ABS^ x1:neg_fact
		   <<
			#abs1->copyProperties(*#x1);
			#abs1->isReal=true;
		   >>
		  )
		| (FLOOR LBRACKET)? (f0:FLOOR^ LBRACKET! <<lists=false;>> x2:add_expr <<lists=true;>> RBRACKET!
		   <<
		     #f0->copyProperties(*#x2);
		     #f0->isInteger=true;
		     #f0->isRational=true;
		     #f0->isInanIntegralDomain=true;
		     #f0->isBool=false;
		   >>
		  )
		| (f1:FLOOR^ <<lists=false;>> x3:neg_fact <<lists=true;>>
		   <<
		     #f1->copyProperties(*#x3);
		     #f1->isInteger=true;
		     #f1->isRational=true;
		     #f1->isInanIntegralDomain=true;
		     #f1->isBool=false;
		   >>
		  )
		| (CEIL LBRACKET)? (c0:CEIL^ LBRACKET! <<lists=false;>> x4:add_expr <<lists=true;>> RBRACKET!
		   <<
		     #c0->copyProperties(*#x4);
		     #c0->isInteger=true;
		     #c0->isRational=true;
		     #c0->isInanIntegralDomain=true;
		     #c0->isBool=false;
		   >>
		  )
		| (c1:CEIL^ <<lists=false;>> x5:neg_fact <<lists=true;>>
		   <<
		     #c1->copyProperties(*#x5);
		     #c1->isInteger=true;
		     #c1->isRational=true;
		     #c1->isInanIntegralDomain=true;
		     #c1->isBool=false;
		   >>
		  )
		| (FRAC LBRACE add_expr RBRACE LBRACE)? (FRAC! LBRACE! a0:add_expr! RBRACE! LBRACE! a1:add_expr! RBRACE!
		   <<
		     AST *d=new AST(DIV,"/");
		     #0=#(d,#(#[LPAREN,"("],#a0,#[RPAREN,")"]),#(#[LPAREN,"("],#a1,#[RPAREN,")"]));
		     d->isBool=false;
		     d->isInteger=false;
		     d->isRational=#a0->isRational && #a1->isRational;
		     d->isInanIntegralDomain=false;
		     d->isConstant=#a0->isConstant && #a1->isConstant;
		     d->isPolynomial=((#a0->isConstant || #a1->isConstant) && #a0->isPolynomial && #a1->isConstant);
		     d->isReal=#a0->isReal && #a1->isReal;
		   >>
		  )
		| (FRAC LBRACE)? (FRAC! LBRACE! a2:add_expr! RBRACE! l0:neg_fact!
		   <<
		     AST *d=new AST(DIV,"/");
		     #0=#(d,#(#[LPAREN,"("],#a2,#[RPAREN,")"]),#(#[LPAREN,"("],#l0,#[RPAREN,")"]));
		     d->isBool=false;
		     d->isInteger=false;
		     d->isRational=#a2->isRational && #l0->isRational;
		     d->isInanIntegralDomain=false;
		     d->isConstant=#a2->isConstant && #l0->isConstant;
		     d->isPolynomial=((#a2->isConstant || #l0->isConstant) && #a2->isPolynomial && #l0->isConstant);
		     d->isReal=#a2->isReal && #l0->isReal;
		   >>
		  )
		| (FRAC neg_fact LBRACE)? (FRAC! l1:neg_fact! LBRACE! a3:add_expr! RBRACE!
		   <<
		     AST *d=new AST(DIV,"/");
		     #0=#(d,#(#[LPAREN,"("],#l1,#[RPAREN,")"]),#(#[LPAREN,"("],#a3,#[RPAREN,")"]));
		     d->isBool=false;
		     d->isInteger=false;
		     d->isRational=#l1->isRational && #a3->isRational;
		     d->isInanIntegralDomain=false;
		     d->isConstant=#l1->isConstant && #a3->isConstant;
		     d->isPolynomial=((#l1->isConstant || #a3->isConstant) && #l1->isPolynomial && #a3->isConstant);
		     d->isReal=#l1->isReal && #a3->isReal;
		   >>
		  )
		| (FRAC! l2:neg_fact! l3:neg_fact!
		   <<
		     AST *d=new AST(DIV,"/");
		     #0=#(d,#(#[LPAREN,"("],#l2,#[RPAREN,")"]),#(#[LPAREN,"("],#l3,#[RPAREN,")"]));
		     d->isBool=false;
		     d->isInteger=false;
		     d->isRational=#l2->isRational && #l3->isRational;
		     d->isInanIntegralDomain=false;
		     d->isConstant=#l2->isConstant && #l3->isConstant;
		     d->isPolynomial=((#l2->isConstant || #l3->isConstant) && #l2->isPolynomial && #l3->isConstant);
		     d->isReal=#l2->isReal && #l3->isReal;
		   >>
		  )
		;

factorial:
	  (factfunc DFACTORIAL)? (f0:factfunc d:DFACTORIAL^
	    <<
	      #d->copyProperties(*#f0);
#if DEBUG
#else
	      if (type_check && !(#d->isInteger)) setSignal(2);
#endif
	    >>
	  )
	| (factfunc FACTORIAL)? (f1:factfunc f:FACTORIAL^ 
	   <<
	     #f->copyProperties(*#f1);
#if DEBUG
#else
	     if (type_check && !(#f->isInteger)) setSignal(2);
#endif
	   >>
	  )
	| factfunc
	;

}

