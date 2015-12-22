header {
#include <string>
#include <sstream>
#include <h/misc.h>
#include <h/fcAST.h>
using namespace std;

typedef enum degreePosition {none, root, moment, diff} degreePosition;
}

options {
        language=Cpp;
}

/**
 * This file creates an Intuitive AST type AST from a MathML AST type AST, the output uses Intuitive AST format.
 * Generation depends on the following files:
 * IntuitiveTokenTypes.txt ContMathInTokenTypes.txt
 * Compilation depends on the following files:
 * h/misc.h h/fcAST.h
 * From this file the following files will be created:
 * ContMathMLToIntuitiveTransform.cpp, ContMathMLToIntuitiveTransform.hpp, ContMathMLToIntuitiveTransformTokenTypes.hpp, ContMathMLToIntuitiveTransformTokenTypes.txt
 * @author Gabor Bakos (baga@users.sourceforge.net)
 * $Id: contmathmltointuitive.g,v 1.20 2012/05/29 13:06:50 baga Exp $
 */

class ContMathMLToIntuitiveTransform extends TreeParser;
options {
	buildAST=true;
	importVocab=ContMathMLIn;
	ASTLabelType = "RefFcAST";
	defaultErrorHandler=false;
}

///Grrr! antlr does not support the pointer references in C++ mode. :-(

{
}

inp	:	expr
	|
	;

expr {std::vector<RefFcAST> childs; RefFcAST dummy, dummy2;}:
	  !#(OMATH ll:expr {#expr=#ll;})
	|!#(ocn:OCN ((l1:MNUMBER {std::string text = #l1->getText(); if (text[text.length() - 1] == '.') text+="0"; #expr=#[NUMBER, text];} 
	(msep:MSEP exponent:expr {
	#expr=(#ocn->getText().find("rational") != string::npos) ?
	  #(#[DIV, #msep->getText()], #expr,  #exponent)
	  : (#ocn->getText().find("complex-cartesian") != string::npos) ?
	    #(#[PLUS, #msep->getText()], #expr, #(#[MULT, "^"], #[I, "i"], #exponent))
	    : (#ocn->getText().find("complex-polar") != string::npos) ?
	      #(#[MULT, #msep->getText()], #expr, #(#[CIRCUM, "^"], #[E, "e"], #(#[MULT, "*"], #[I, "i"], #exponent)))
	      : #(#[MULT, #msep->getText()], #expr, #(#[CIRCUM, "^"], #[NUMBER, "10"], #exponent));})?)
	  | (MPI {#expr=#[PI, "&pi;"];})
	  | (ME {#expr=#[E, "&ee;"];})
	  | (MI {#expr=#[I, "&ii;"];})
	  | (MGAMMA {#expr=#[CONSTGAMMA, "&gamma;"];})
	  | (MTRUE {#expr=#[FC_TRUE, "&true;"];})
	  | (MFALSE {#expr=#[FC_FALSE, "&false;"];})
	  | (MINFTY {#expr=#[INFTY, "&infty;"];}) ))
	|!#(oci:OCI mid:expr {if (mid->getType()==MID) #expr=#[VARIABLE, #mid->getText()]; else #expr=#mid; std::string ss=#oci->getText(); std::string::size_type place=ss.find("type"); if (place!=std::string::npos) {if (ss.find("real", place)!=std::string::npos) #expr=#(#[TYPEDEF, "real"], #expr); else if (ss.find("integer", place)!=std::string::npos) #expr=#(#[TYPEDEF, "integer"], #expr); else if (ss.find("complex", place)!=std::string::npos) #expr=#(#[TYPEDEF, "complex"], #expr); else if (ss.find("rational", place)!=std::string::npos) #expr=#(#[TYPEDEF, "rational"], #expr); else if (ss.find("vector", place)!=std::string::npos) #expr=#(#[TYPEDEF, "vector"], #expr); else if (ss.find("matrix", place)!=std::string::npos) #expr=#(#[TYPEDEF, "matrix"], #expr);}})
	| MID {#MID->setType(VARIABLE);}
	|!#(MPLUS {childs.erase(childs.begin(), childs.end());} (l2:expr {childs.push_back(#l2);})+ {#expr=manyToTwo<RefFcAST>(getASTFactory(), childs, PLUS, "+", #expr);})
	|!#(MMINUS l3:expr (l4:expr)? {if (#l4!=antlr::nullAST) #expr=#(#[MINUS, "-"], #l3, #l4); else #expr=#(#[NEG, "-"], #l3);})
	|!#(MTIMES {childs.erase(childs.begin(), childs.end());} (l5:expr {childs.push_back(#l5);})+ {#expr=manyToTwo<RefFcAST>(getASTFactory(), childs, MULT, "*", #expr);})
	| #(MDIVIDE expr expr {#MDIVIDE->setType(DIV);})
	| #(MPM expr (expr)? {#MPM->setType(PM);})
	| #(MMP expr (expr)? {#MMP->setType(MP);})
	| #(MPOWER expr expr {#MPOWER->setType(CIRCUM);})
	| #(MFACTORIAL expr {#MFACTORIAL->setType(FACTORIAL);})
	|!#(MSELECTOR l6:expr (l7:expr (l8:expr)?)? {if (#l7==antlr::nullAST) #expr=#l6; else if (#l8==antlr::nullAST) #expr=#(#[UNDERSCORE, "_"], #l6, #l7); else #expr=#(#[UNDERSCORE, "_"], #l6, #(#[ENUMERATION, "{enum , }"], #l7, #l8));})
	|!#(MDIFF (l9:expr (l10:expr)? {if (#l10==antlr::nullAST) #expr=#(#[DERIVE, "'"], #l9, #[VARIABLE, "x"]); else #expr=#(#[DERIVE, "d/dx"], #l10, #l9);} | (!b0:bvar[diff] !ee0:expr
	{
		if (#b0->getType()==DEGREE)
		{
			RefFcAST first=#b0->getFirstChild();
			RefFcAST second=first->getNextSibling();
			antlr::RefAST firstdup=astFactory->dupTree((antlr::RefAST)first);
			antlr::RefAST seconddup=astFactory->dupTree((antlr::RefAST)second);
			#expr=#(#[NTHDERIVE, "d/dx"], #ee0, firstdup, seconddup);
		}
		else
		{
			#expr=#(#[NTHDERIVE, "d/dx"], #ee0, #[NUMBER, "1"], #b0);
		}
	}
	)))
	|!#(MABS l11:expr {#expr=#(#[FUNCTION, "function"], #[ABS, "|"], #l11);})
	|!#(MCONJUGATE l12:expr {#expr=#(#[FUNCTION, "function"], #[CONJUGATE, "conjugate"], #l12);})
	|!#(MARG l13:expr {#expr=#(#[FUNCTION, "function"], #[ARG, "arg"], #l13);})
	|!#(MREAL l14:expr {#expr=#(#[FUNCTION, "function"], #[RE, "re"], #l14);})
	|!#(MIMAGINARY l15:expr {#expr=#(#[FUNCTION, "function"], #[IM, "im"], #l15);})
	|!#(MFLOOR l16:expr {#expr=#(#[FUNCTION, "function"], #[FLOOR, "floor"], #l16);})
	|!#(MCEILING l17:expr {#expr=#(#[FUNCTION, "function"], #[CEIL, "|"], #l17);})
	|!#(MNOT l18:expr {#expr=#(#[NOT, "not"], #l18);})
	|!#(MINVERSE l19:expr {#expr=#(#[FUNCINVERSE, "^{}"], #l19);})
	|!#(MDOMAIN l20:expr) //TODO?
	|!#(MCODOMAIN l21:expr) //TODO?
	|!#(MIMAGE l22:expr) //TODO?
	|!#(MSIN l23:expr {#expr=#(#[FUNCTION, "function"], #[SIN, "sin"], #l23);})
	|!#(MCOS l24:expr {#expr=#(#[FUNCTION, "function"], #[COS, "cos"], #l24);})
	|!#(MTAN l25:expr {#expr=#(#[FUNCTION, "function"], #[TAN, "tan"], #l25);})
	|!#(MSEC l26:expr {#expr=#(#[FUNCTION, "function"], #[SEC, "sec"], #l26);})
	|!#(MCSC l27:expr {#expr=#(#[FUNCTION, "function"], #[COSEC, "csc"], #l27);})
	|!#(MCOT l28:expr {#expr=#(#[FUNCTION, "function"], #[COT, "cot"], #l28);})
	|!#(MSINH l33:expr {#expr=#(#[FUNCTION, "function"], #[SINH, "sinh"], #l33);})
	|!#(MCOSH l34:expr {#expr=#(#[FUNCTION, "function"], #[COSH, "cosh"], #l34);})
	|!#(MTANH l35:expr {#expr=#(#[FUNCTION, "function"], #[TANH, "tanh"], #l35);})
	|!#(MSECH l36:expr {#expr=#(#[FUNCTION, "function"], #[SECH, "sech"], #l36);})
	|!#(MCSCH l37:expr {#expr=#(#[FUNCTION, "function"], #[COSECH, "csch"], #l37);})
	|!#(MCOTH l38:expr {#expr=#(#[FUNCTION, "function"], #[COTH, "coth"], #l38);})
	|!#(MARCSIN l43:expr {#expr=#(#[FUNCTION, "function"], #[ARCSIN, "asin"], #l43);})
	|!#(MARCCOS l44:expr {#expr=#(#[FUNCTION, "function"], #[ARCCOS, "acos"], #l44);})
	|!#(MARCTAN l45:expr {#expr=#(#[FUNCTION, "function"], #[ARCTAN, "atan"], #l45);})
	|!#(MARCSEC l46:expr {#expr=#(#[FUNCTION, "function"], #[ARCSEC, "asec"], #l46);})
	|!#(MARCCSC l47:expr {#expr=#(#[FUNCTION, "function"], #[ARCCOSEC, "acsc"], #l47);})
	|!#(MARCCOT l48:expr {#expr=#(#[FUNCTION, "function"], #[ARCCOT, "acot"], #l58);})
	|!#(MARCSINH l53:expr {#expr=#(#[FUNCTION, "function"], #[ARCSINH, "asinh"], #l53);})
	|!#(MARCCOSH l54:expr {#expr=#(#[FUNCTION, "function"], #[ARCCOSH, "acosh"], #l54);})
	|!#(MARCTANH l55:expr {#expr=#(#[FUNCTION, "function"], #[ARCTANH, "atanh"], #l55);})
	|!#(MARCSECH l56:expr {#expr=#(#[FUNCTION, "function"], #[ARCSECH, "asech"], #l56);})
	|!#(MARCCSCH l57:expr {#expr=#(#[FUNCTION, "function"], #[ARCCOSECH, "acsch"], #l57);})
	|!#(MARCCOTH l58:expr {#expr=#(#[FUNCTION, "function"], #[ARCCOTH, "acoth"], #l58);})
	|!#(MEXP l59:expr {#expr=#(#[FUNCTION, "function"], #[EXP, "exp"], #l59);})
	|!#(MLN l60:expr {#expr=#(#[FUNCTION, "function"], #[LN, "ln"], #l60);})
	|!#(MDETERMINANT l61:expr /*{#expr=#(#[FUNCTION, "function"], #[DETERMINANT, "det"], #l61);}*/)
	|!#(MTRANSPOSE l62:expr {#expr=#(#[FUNCTION, "function"], #[TRANSPONATE, "transpose"], #l62);})
	|!#(MDIVERGENCE l63:expr) //TODO?
	|!#(MGRAD l64:expr) //TODO
	|!#(MCURL l65:expr) //TODO
	|!#(MLAPLACIAN l66:expr) //TODO
	|!#(MCARD l67:expr {#expr=#(#[FUNCTION, "function"], #[SIZEOF, "card"], #l67);})
	|!#(MLOG l68:expr (l69:expr)? {if (#l69==antlr::nullAST) #expr=#(#[FUNCTION, "function"], #[LOG, "log"], #l68); else #expr=#(#[FUNCTION, "function"], #(#[LOG, "log"], #l69), #l68);})
	|!#(MROOT (#(ODEGREE l70:expr))? l71:expr {if (#l70==antlr::nullAST) #expr=#(#[FUNCTION, "function"], #[SQRT, "root"], #l71); else #expr=#(#[FUNCTION, "function"], #(#[ROOT, "root"], #l70), #l71);})
	|!#(MQUOTIENT l72:expr l73:expr {#expr->setType(DIV/*??*/);}) //TODO
	| #(MREM l74:expr l75:expr {#expr->setType(MOD);})
	|!#(MIMPLIES l76:expr l77:expr {#expr=#(#[IMPLY, "implies"], #l76, l77);})
	|!#(MNEQ l78:expr l79:expr {#expr=#(#[NEQ, "neq"], #l78, #l79);})
	|!#(MEQUIVALENT l80:expr l81:expr {#expr->setType(EQUIV);})
	|!#(MAPPROX l82:expr l83:expr) //TODO?
	|!#(MFACTOROF l84:expr l85:expr {#expr->setType(FACTOROF);})
	|!#(MSETDIFF l86:expr l87:expr {#expr=#(#[SETMINUS, "setdiff"], #l86, #l87);})
	|!#(MIIN l88:expr l89:expr {#expr=#(#[SETIN, "in"], #l88, #l89);})
	|!#(MNOTIN l90:expr l91:expr {#expr=#(#[SETNOTIN, "notin"], #l88, #l89);})
	|!#(MNOTSUBSET l92:expr l93:expr {#expr=#(#[SETNOTSUBSETEQ, "notsubset"], #l92, #l93);})
	|!#(MNOTPRSUBSET l94:expr l95:expr {#expr=#(#[SETNOTSUBSET, "notprsubset"], #l94, #l95);})
	|!#(MVECTORPRODUCT l96:expr l97:expr) //TODO
	|!#(MSCALARPRODUCT l98:expr l99:expr) //TODO
	|!#(MOUTERPRODUCT l100:expr l101:expr) //TODO
	|!#(mtt:MTENDSTO l102:expr l103:expr {std::string s=#mtt->getText(); if (s.find("above")!=std::string::npos) #expr=#(#[TENDSTO, s], #l102, #l103, #[RIGHT, "above"]); else if (s.find("below")!=std::string::npos) #expr=#(#[TENDSTO, s], #l102, #l103, #[LEFT, "below"]); else if (s.find("two-sided")!=std::string::npos) #expr=#(#[TENDSTO, s], #l102, #l103, #[REAL, "two-sided"]); else #expr=#(#[TENDSTO, s], #l102, #l103, #[REAL, ""]);})
	|!#(MSUBSET {childs.erase(childs.begin(), childs.end());} (l104:expr {childs.push_back(#l104);})+ {#expr=manyToTwo<RefFcAST>(getASTFactory(), childs, SETSUBSETEQ, "setsubset", #expr);})
	|!#(MPRSUBSET {childs.erase(childs.begin(), childs.end());} (l105:expr {childs.push_back(#l105);})+ {#expr=manyToTwo<RefFcAST>(getASTFactory(), childs, SETSUBSET, "prsetsubset", #expr);})
	|!#(OSET ((l106:expr)* | l107:construct)) //TODO
	|!#(OLIST ((l108:expr)* | l109:construct)) //TODO
	|!#(OMATRIX {#expr=#(#[ENUMERATION, ", "]);}((OMATRIXEOW l110:expr {#expr->addChild(#l110);})* | l111:construct))
	|!#(MINT ((OBVAR OLOWLIMIT)=>(l122:bvar[none] (#(OLOWLIMIT l123:expr) #(OUPLIMIT l124:expr))? l125:expr {if (#l123==antlr::nullAST || #l124==antlr::nullAST) #expr=#(#[INDEFINTEGRAL, "int"], #l125, #l122); else #expr=#(#[DEFINTEGRAL, "int"], #l125, #l122, #l123, #l124);}) | l126:construct))
	|!#(MSUM ((OBVAR OLOWLIMIT)=>(l112:bvar[none] #(OLOWLIMIT l113:expr) #(OUPLIMIT l114:expr) l115:expr {#expr=#(#[SUM, "sum"], #l112, #l113, #l114, #l115);}) | l116:construct))
	|!#(MPRODUCT ((OBVAR OLOWLIMIT)=>(l117:bvar[none] #(OLOWLIMIT l118:expr) #(OUPLIMIT l119:expr) l120:expr {#expr=#(#[PROD, "product"], #l117, #l118, #l119, #l120);}) | l121:construct))
	|!#(MPARTIALDIFF expr) //TODO: This won't be easy...
	|!#(MFORALL {dummy=#expr=#[NONE];} (forallbvar:bvar[none] {#expr=#(#[FORALL], #forallbvar, #expr);})* forallexpr:expr {dummy=#forallexpr;})
	|!#(MEXISTS {dummy=#expr=#[NONE];} (existsbvar:bvar[none] {#expr=#(#[FORALL], #existsbvar, #expr);})* existsexpr:expr {dummy=#existsexpr;})
	|!#(mlimit:MLIMIT limbvar:expr limto:expr limexpr:expr (limtype:expr)? {if (#limto->getType()!=CONDITION && #limto->getType()!=TENDSTO) #expr=#(#[LIM, #mlimit->getText()], #limbvar, #limexpr, #[REAL, "real"]); else {if (#limto->getType()==CONDITION) #limto=#limto->getFirstChild(); if (#limto->getType()==TENDSTO) {RefFcAST to=#limto->getFirstChild()->getNextSibling(), how=to->getNextSibling(); #expr=#(#[LIM, #mlimit->getText()], #limbvar, to, how);} else throw std::exception();}})//Possible problem... TODO review, use ASTFactory dupTree!
	| #(ODECLARE l127:expr (l128:expr)? {#expr->setType(DECLARE);})
	|!#(OVECTOR {#expr=#[ENUMERATION, ","];} (l129:expr{#expr->addChild(#l129);})+ {#expr=#(#[VECTOR, "vector"], #expr);})
	|!#(lambda:OLAMBDA {#expr=#([ENUMERATION, "enum"]);} (l130:bvar[none] {#expr->addChild(#l130);})* l131:expr {#expr=#(#[LAMBDACONSTRUCT, #lambda->getText()], #expr, #l131);})
	| (MNATURALNUMBERS {#expr->#setType(NATURALNUMBERS);})
	| (MPRIMES {#expr->#setType(PRIMES);})
	| (MINTEGERS {#expr->#setType(INTEGERS);})
	| (MRATIONALS {#expr->#setType(RATIONALS);})
	| (MREALS {#expr->#setType(REALS);})
	| (MCOMPLEXES {#expr->#setType(COMPLEXES);})
	| (MEMPTYSET {#expr->setType(SET);})
	|!#(MGCD {childs.erase(childs.begin(), childs.end());} (l132:expr {childs.push_back(#l132);})+ {#expr=manyToTwo<RefFcAST>(getASTFactory(), childs, GCD, "gcd", #expr);})
	|!#(MLCM {childs.erase(childs.begin(), childs.end());} (l133:expr {childs.push_back(#l133);})+ {#expr=manyToTwo<RefFcAST>(getASTFactory(), childs, LCM, "lcm", #expr);})
	|!#(MEQ {childs.erase(childs.begin(), childs.end());} (l134:expr {childs.push_back(#l134);})+ {#expr=manyToTwo<RefFcAST>(getASTFactory(), childs, EQUAL, "eq", #expr);})
	|!#(MLT {childs.erase(childs.begin(), childs.end());} (l135:expr {childs.push_back(#l135);})+ {#expr=manyToTwo<RefFcAST>(getASTFactory(), childs, LESS, "lt", #expr);})
	|!#(MGT {childs.erase(childs.begin(), childs.end());} (l136:expr {childs.push_back(#l136);})+ {#expr=manyToTwo<RefFcAST>(getASTFactory(), childs, GREATER, "gt", #expr);})
	|!#(MLEQ {childs.erase(childs.begin(), childs.end());} (l137:expr {childs.push_back(#l137);})+ {#expr=manyToTwo<RefFcAST>(getASTFactory(), childs, LEQ, "leq", #expr);})
	|!#(MGEQ {childs.erase(childs.begin(), childs.end());} (l138:expr {childs.push_back(#l138);})+ {#expr=manyToTwo<RefFcAST>(getASTFactory(), childs, GEQ, "geq", #expr);})
	| entities
        ;

bvar[degreePosition type]	:	!#(OBVAR l0:expr {#bvar=#l0;} (#(ODEGREE lll:expr {if (type==diff) {#bvar=#(#[DEGREE, "^"], #lll, #l0);} else #bvar=#(#[DEGREE, "^"], #bvar, #lll);}))?)
	;

construct:	#(ODOMAINOFAPPLICATION expr)
	|	((#(OBVAR expr))* #(OCONDITION expr))
	;

entities:
		(EALPHA {#entities->#setType(ALPHA);})
	|	(EBETA {#entities->#setType(BETA);})
	|	(EGAMMA {#entities->#setType(GAMMA);})
	|	(EGAMMAG {#entities->#setType(GAMMAG);})
	|	(EDELTA {#entities->#setType(DELTA);})
	|	(EDELTAG {#entities->#setType(DELTAG);})
	|	(EEPSILON {#entities->#setType(EPSILON);})
	|	(EZETA {#entities->#setType(ZETA);})
	|	(EETA {#entities->#setType(ETA);})
	|	(ETHETA {#entities->#setType(THETA);})
	|	(ETHETAG {#entities->#setType(THETAG);})
	|	(EIOTA {#entities->#setType(IOTA);})
	|	(EKAPPA {#entities->#setType(KAPPA);})
	|	(ELAMBDA {#entities->#setType(LAMBDA);})
	|	(ELAMBDAG {#entities->#setType(LAMBDAG);})
	|	(EMU {#entities->#setType(MU);})
	|	(ENU {#entities->#setType(NU);})
	|	(EXI {#entities->#setType(XI);})
	|	(EXIG {#entities->#setType(XIG);})
//	|	(EOMICRON {#entities->#setType(OMICRON);})
	|	(ERHO {#entities->#setType(RHO);})
	|	(ESIGMA {#entities->#setType(SIGMA);})
	|	(ESIGMAG {#entities->#setType(SIGMAG);})
	|	(ETAU {#entities->#setType(TAU);})
	|	(EUPSILON {#entities->#setType(UPSILON);})
	|	(EUPSILONG {#entities->#setType(UPSILONG);})
	|	(EPHI {#entities->#setType(PHI);})
	|	(EPHIG {#entities->#setType(PHIG);})
	|	(ECHI {#entities->#setType(CHI);})
	|	(EPSI {#entities->#setType(PSI);})
	|	(EPSIG {#entities->#setType(PSIG);})
	|	(EOMEGA {#entities->#setType(OMEGA);})
	;

