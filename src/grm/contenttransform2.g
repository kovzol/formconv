header {
#include <string>
#include <antlr/ASTFactory.hpp>
#include <h/fcAST.h>
using namespace std;
}

options {
        language=Cpp;
}

/**
 * This file creates an AST. The input must be in Intuitive AST format. This is the second stage of content transformation.
 * Generation depends on the following files:
 * IntuitiveTokenTypes.txt
 * Compilation depends on the following files:
 * h/fcAST.h
 * From this file the following files will be created:
 * ContentTransform2.cpp, ContentTransform2.hpp, ContentTransform2TokenTypes.hpp, ContentTransform2TokenTypes.txt
 * @author Gabor Bakos (baga@users.sourceforge.net)
 */

class ContentTransform2 extends TreeParser;
options {
	importVocab=Intuitive;
	buildAST=true;
	ASTLabelType="RefFcAST";
	defaultErrorHandler=false;
}

{
#define castt(x) ((antlr::RefAST)x)
	RefFcAST getLastNode(const RefFcAST p)
	{
		RefFcAST ret=p;
		while (ret->getFirstChild()!=antlr::nullAST)
		{
			ret=ret->getFirstChild();
			while (ret->getNextSibling()!=antlr::nullAST)
				ret=ret->getNextSibling();
		}
		return ret;
	}

	RefFcAST getFirstNode(const RefFcAST p)
	{
		RefFcAST ret=p;
		while (ret->getFirstChild()!=antlr::nullAST)
			ret=ret->getFirstChild();
		return ret;
	}

	bool inline isSetRelation(RefFcAST r)
	{
		int t=r->getType();
		if (t==SETSUBSET || t==SETSUBSETEQ || t==SETNOTSUBSETEQ || t==SETSUBSET || t==SETSUBSETEQ || t==SETNOTSUBSETEQ || t==EQUAL || t==NEQ)
			return true;
		else
			return false;
	}

	bool inline isArithmRelation(RefFcAST r)
	{
		int t=r->getType();
		if (t==EQUAL || t==NEQ || t==LESS || t==LEQ || t==NOTLESS || t==NOTLEQ || t==GREATER || t==GEQ || t==NOTGREATER || t==NOTGEQ)
			return true;
		else return false;
	}

	bool isSetIn(RefFcAST r)
	{
		int t=r->getType();
		if (t==SETIN || t==SETNI)
			return true;
		else
			return false;
	}
	
	bool inline isRelation(RefFcAST r)
	{
		return (isArithmRelation(r) || isSetRelation(r) || isSetIn(r));
	}

	void correctRelation(RefFcAST root)
	{
		antlr::ASTFactory *astf=getASTFactory();
		RefFcAST left=root->getFirstChild(), right=left->getNextSibling();
		int /*rtype=root->getType(), ltype=left->getType(),*/ rightType=right->getType();
		if (isRelation(root))
		{
//		puts("1");
		if (rightType==ENUMERATION)
		{
//		puts("2");
			if (isArithmRelation(root) || isSetRelation(root))
			{
				RefFcAST it=right->getFirstChild();
				bool wasDots=false;
				if (it!=antlr::nullAST)
				{
					int count = 0;
					for (;it->getNextSibling()!=antlr::nullAST; it=it->getNextSibling(), ++count)
					{
						if (it->getType()==DOTS)
							wasDots=true;
					}
					if (!wasDots)
					{
						it=right->getFirstChild();
						RefFcAST tmp=#(astf->dup(castt(root)), astf->dupTree(castt(left)), astf->dupTree(castt(it)));
						it=it->getNextSibling();
						if (root->getType() != EQUAL)
						{
							for (; it!=antlr::nullAST; it=it->getNextSibling())
								tmp=#(#[AND, "and"], tmp, #(astf->dup(castt(root)), astf->dupTree(castt(left)), astf->dupTree(castt(it))));
							root->setType(AND);
							root->setText("and");
						}
						else
						{
							for (; it!=antlr::nullAST; it=it->getNextSibling())
								tmp=#(#[OR, "or"], tmp, #(astf->dup(castt(root)), astf->dupTree(castt(left)), astf->dupTree(castt(it))));
							root->setType(OR);
							root->setText("or");
						}
						root->setFirstChild(tmp->getFirstChild());
					}
/*					printf("%d", count);
					if (count == 2)
					{
						RefFcAST rightMost = left;
						while (isArithmRelation(rightMost) || isSetRelation(rightMost))
						{
							rightMost = rightMost->getFirstChild()->getNextSibling();
						}
						puts(rightMost->toStringList().c_str());
						RefFcAST tmp=#(astf->dup(castt(root)), astf->dupTree(castt(rightMost)), astf->dupTree(castt(it)));
						root->setType(AND);
						root->setText("and");
						root->setFirstChild(tmp->getFirstChild());
					}*/
//					correctRelation(root->getFirstChild());
//					correctRelation(root->getFirstChild()->getNextSibling());
				}
			}
			if (isSetIn(root))
			{
				root->setType(SETSUPSETEQ);
				root->setText("supseteq");
				RefFcAST tmp=#(#[SET, "setDef"], astf->dupTree(castt(right)));
				root->getFirstChild()->setNextSibling(tmp);
			}
		}
/*		else
		{
//		puts("3");
			if (isRelation(left))
			{//FIXME Itt folytasd! Nem tudom, hogy hogyan kellene... :-(
//		puts("4");
				RefFcAST leftRight = left->getFirstChild()->getNextSibling();
				if (leftRight->getType() == ENUMERATION)
				{
					puts(("leftRight: " + leftRight->toStringList()+"\n").c_str());
					int count = 0;
					for (RefFcAST it = leftRight->getFirstChild(); it != antlr::nullAST; it = it->getNextSibling(), ++count);
					printf("cca: %d\n", count);
					if (count == 2)
					{
						root->setType(AND);
						root->setText("and");
						RefFcAST it = leftRight->getFirstChild();
						RefFcAST tmp=#(astf->dup(castt(root)), astf->dupTree(castt(it->getNextSibling())), astf->dupTree(castt(right)));
						root->setFirstChild(tmp);
					}
				}
			}
		}*/
		}

	}





}

inp	:	(expr)
	|
	;

expr	:
	  #(PLUS expr expr)
	| #(MINUS expr expr)
	| #(NEG expr)
	| #(MULT expr expr)
	| #(DIV expr expr)
	| #(MOD expr expr)
	| #(MODP expr expr expr)
	| #(EQUIV expr expr)
	| #(MATRIXPRODUCT expr expr)
	| #(MATRIXEXPONENTIATION expr expr)
	| #(FACTOROF expr expr)
	| #(CIRCUM expr expr)
	| #(FACTORIAL expr)
	| #(DFACTORIAL expr)
	| #(UNDERSCORE expr expr)
	| #(PM expr (expr)?)
	| #(MP expr (expr)?)
	| #(DERIVE expr expr)
	| #(NTHDERIVE expr expr expr)
	| #(NTHDERIVEX expr expr)
	| #(FUNCINVERSE expr)
//	| #(FUNCMULT expr expr)
//	| #(FUNCPLUS expr exrp)
	| #(DEFINTEGRAL expr expr expr expr)
	| #(INDEFINTEGRAL expr expr)
	| #(SUM expr expr expr expr)
	| #(PROD expr expr expr expr)
	| #(EQUAL expr expr)
	| #(NEQ expr expr)
	| #(LESS expr expr {correctRelation(#expr);})
	| #(LEQ expr expr)
	|!#(NOTLESS nless0:expr nless1:expr {#expr=#(#[NOT, "not"], #(#[LESS, "<"], nless0, nless1));})
	| #(LESSNOTEQ expr expr {#expr->setType(LESS);})
	|!#(NOTLEQ nleq0:expr nleq1:expr {#expr=#(#[NOT, "not"], #(#[LEQ, "\\leq"], #nleq1, #nleq0));})
	|/*!*/#(GREATER grt0:expr grt1:expr /*{#expr=#(#[LESS, "<"], #grt1, #grt0);}*/)
	|/*!*/#(GEQ geq0:expr geq1:expr /*{#expr=#(#[LEQ, "\\leq"], #geq1, #geq0);}*/)
	|!#(NOTGREATER ngrt0:expr ngrt1:expr {#expr=#(#[NOT, "not"], #(#[GREATER, ">"], #ngrt0, #ngrt1));})
	|!#(GREATERNOTEQ grtneq0:expr grtneq1:expr {#expr=#(#[GREATER, ">"], #grtneq0, #grtneq1);})
	|!#(NOTGEQ ngeq0:expr ngeq1:expr {#expr=#(#[NOT, "not"], #(#[GEQ, "\\geq"], #ngeq0, #ngeq1));})
//	| #(SETPOW expr expr)
//	| #(SETGENERATED expr)
	| #(SETSUBSET expr expr)
	| #(SETSUBSETEQ expr expr)
//	| #(SETSUBSETNEQ expr expr)
	|!#(SETNOTSUBSETEQ setnsubeq0:expr setnsubeq1:expr {#expr=#(#[NOT, "not"], #(#[SETSUBSET, "subset"], #setnsubeq0, #setnsubeq1));})
	| #(SETSUPSET expr expr)
	| #(SETSUPSETEQ expr expr)
//	| #(SETSUPSETNEQ expr expr)
	|!#(SETNOTSUPSETEQ setnsupeq0:expr setnsupeq1:expr {#expr=#(#[NOT, "not"], #(#[SETSUPSET, "supset"], #setnsupeq0, #setnsupeq1));})
	| #(SETIN expr expr {correctRelation(#expr);})
//	| #(SETNI expr expr)
	| #(SET expr (expr)?)
	| #(SETMINUS expr expr)
	| #(SETMULT expr expr)
	| #(SETUNION expr expr)
	| #(SETINTERSECT expr expr)
	| #(ASSIGN expr expr)
	| #(NOT expr)
	| #(AND expr expr)
	| #(OR expr expr)
//	| #(NAND expr expr)
//	| #(NOR expr expr)
	| #(IMPLY expr expr)
//	| #(RIMPLY expr expr)
//	| #(IFF expr expr)
	| #(FORALL expr expr)
	| #(EXISTS expr expr)
	| #(LIM expr expr expr (expr)?)
	| #(LIMSUP expr (expr)?)
	| #(LIMINF expr (expr)?)
	| #(SUP expr (expr)?)
	| #(INF expr (expr)?)
	| #(MAX expr (expr)?)
	| #(MIN expr (expr)?)
	| #(ARGMAX expr (expr)?)
	| #(ARGMIN expr (expr)?)
	| LEFT
	| RIGHT
	| REAL
	| COMPLEX
	| VARIABLE
	| NUMBER
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
	| #(ENUMERATION (expr)*)
	| #(PAIR expr expr)
	| #(LPAREN expr)
	| #(LBRACKET expr)
	| #(VECTOR expr)
	| #(MATRIXROW expr)
	| #(MATRIX matrixExpr:expr
	  {
		if (#matrixExpr->getType() == ENUMERATION)
		{
		  for (RefFcAST elem = #matrixExpr->getFirstChild(); elem != antlr::nullAST; elem = elem->getNextSibling())
		  {
			if (elem->getType() == VECTOR)
			{
			  elem->setType(MATRIXROW);
			  elem->setText("matrixRow");
		    }
		  }
	    }
	  }
	  )
	| #(GCD (expr (expr)?)?)
	| #(LCM (expr (expr)?)?)
	| #(FUNCTION expr expr)
	| #(TYPEDEF expr)
	| #(DECLARE expr expr)
	| #(LAMBDACONSTRUCT expr expr)
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
	| #(LOG (expr)?)
	| SQRT
	| #(ROOT expr)
	| CEIL
	| FLOOR
        ;

