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
 * This file creates an AST. The input must use the Intuitive AST format. This is the first stage of content transformation.
 * Generation depends on the following files:
 * IntuitiveTokenTypes.txt
 * Compilation depends on the following files:
 * h/FcAST.h
 * From this file the following files will be created:
 * ContentTransform.cpp, ContentTransform.hpp, ContentTransformTokenTypes.hpp, ContentTransformTokenTypes.txt
 * @author Gabor Bakos (baga@users.sourceforge.net)
 */

class ContentTransform extends TreeParser;
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
		int rtype=root->getType(), ltype=left->getType();
		if (ltype==ENUMERATION)
		{
			if (isArithmRelation(root) || isSetRelation(root))
			{
				RefFcAST it=left->getFirstChild();
				bool wasDots=false;
//				left->setNextSibling(antlr::nullAST);
				if (it!=antlr::nullAST)
				{
					int count=0;
					for (;it->getNextSibling()!=antlr::nullAST; it=it->getNextSibling(), ++count)
					{
						if (it->getType()==DOTS)
							wasDots=true;
					}
/*					if (!wasDots && count > 2)
					{
						it=left->getFirstChild();
						RefFcAST tmp=#(astf->dup(castt(RefFcAST(root))), astf->dupTree(castt(RefFcAST(it))), astf->dupTree(castt(RefFcAST(right))));
						it=it->getNextSibling();
						for (; it!=antlr::nullAST; it=it->getNextSibling())
							tmp=#(#[AND, "and"], tmp, #(astf->dup(castt(root)), astf->dupTree(castt(it)), astf->dupTree(castt(right))));
						root->setType(AND);
						root->setText("and");
						root->setFirstChild(tmp->getFirstChild());
					}*/
					correctRelation(root->getFirstChild());
					correctRelation(root->getFirstChild()->getNextSibling());
				}
			}
			if (rtype==SETIN)
			{
				root->setType(SETSUBSETEQ);
				root->setText("subseteq");
				RefFcAST tmp=#(#[SET, "setDef"], astf->dupTree(castt(left)));
				root->setFirstChild(tmp);
				#root->getFirstChild()->setNextSibling(right);
			}
		}
/*		else //ltype!=ENUMERATION
		if (isArithmRelation(left) && isArithmRelation(root))
		{
			RefFcAST leftleft=left->getFirstChild(), leftright=leftleft->getNextSibling();
//			puts(("leftRight: " + leftright->toStringList() + "\n").c_str());
			if (leftright->getType() != ENUMERATION || leftright->getFirstChild()->getNextSibling()->getNextSibling() != antlr::nullAST)
			{
			left->setNextSibling(antlr::nullAST);
			RefFcAST tmp=#(#[AND, "and"], left, #(astf->dup(castt(root)), astf->dupTree(castt(leftright)), astf->dupTree(castt(right))));
			root->setType(AND);
			root->setText("and");
			root->setFirstChild(tmp->getFirstChild());
			root->getFirstChild()->getFirstChild()->getNextSibling()->setNextSibling(antlr::nullAST);
						correctRelation(root->getFirstChild());
						correctRelation(root->getFirstChild()->getNextSibling());
			}
		}*/
		else
		if (ltype==AND)
		{
			if (rtype==LESS || rtype==LEQ)
			{
				RefFcAST ll=left->getFirstChild(), lr=ll->getNextSibling();
				if (lr->getType()==LESS || lr->getType()==LEQ)
				{
					RefFcAST lrl=lr->getFirstChild(), lrr=lrl->getNextSibling();
					RefFcAST tmp=#(#[AND, "and"], astf->dupTree(castt(left)), #(astf->dup(castt(root)), astf->dupTree(castt(lrr)), astf->dupTree(castt(right))));
					root->setType(AND);
					root->setText("and");
					root->setFirstChild(tmp->getFirstChild());
				}
			}
		}
	}
	
	void correctModP(RefFcAST root, RefFcAST eq, RefFcAST p)
	{
		antlr::ASTFactory *astf = getASTFactory();
		if (eq->getType()==EQUIV)
		{
			RefFcAST left=eq->getFirstChild(), right=left->getNextSibling();
			if (left->getType()==EQUIV)
			{
				RefFcAST newRoot=#(#[AND, "and"], #[NONE, "none0"], #[NONE, "none1"]);
				correctModP(newRoot->getFirstChild(), left, RefFcAST(astf->dupTree(castt(p))));
				RefFcAST newP = RefFcAST(astf->dupTree(castt(p)));
				RefFcAST leftright = RefFcAST(left->getFirstChild()->getNextSibling());
				correctModP(newRoot->getFirstChild()->getNextSibling(), #(#[EQUIV, "eq"], RefFcAST(astf->dupTree(castt(leftright))), RefFcAST(astf->dupTree(castt(right)))), newP);
				root->setType(AND);
				root->setText("and");
				root->setFirstChild(newRoot->getFirstChild());
			}
			else
			{
				root->setType(MODP);
				root->setText("\\pmod");
				root->setFirstChild(astf->dupTree(castt(left)));
				root->getFirstChild()->setNextSibling(astf->dupTree(castt(right)));
				root->getFirstChild()->getNextSibling()->setNextSibling(RefFcAST(astf->dupTree(castt(p))));
			}
		} else 
		{
			//Report error
			throw std::exception();
		}
	}
}

inp	:	(expr)
	|
	;

expr	:
	 #(p:PLUS e0:expr e1:expr
/*	   {
	   	if (#e0->getType()==PLUS)
			#expr=#(#p,#e0->getFirstChild(), #e1);
		else
			#expr=#(#p, #e0, #e1);
	   }*/)
	| #(MINUS expr expr)
	| #(NEG expr)
	| #(MULT l:expr r:expr
/*	  {
	   if (#r->getType()==MULT || #r->getType()==DIV)
	   	RefFcAST x=#r->getFirstChild();
		if (#r->getType()==MULT)
			#expr=#([MULT],[MULT], x->getNextSibling());
		else
			#expr=#([DIV],[MULT], x->getNextSibling());
		#expr->getFirstChild()->addChild(#l);
		#expr->getFirstChild()->getFirstChild()->setNextSibling(x->clone()/*astFactory->create(x)* /);
		
//		#expr->getFirstChild()->addChild(x);
/*		#x->setNextSibling(antlr:nullAST);
		#expr->getFirstChild()->getFirstChild()->getNextSibling()->setNextSibling(nullAST)* /
		RefFcAST last;
		for (int i=0; i<x->getNumberOfChildren(); ++i)
		{
			if (!i)
			{

			#expr->getFirstChild()->getFirstChild()->getNextSibling()->setFirstChild(x->getFirstChild());
//				last=x->getFirstChild();

			}
			else
			{
//				#expr->getFirstChild()->getFirstChild()->getNextSibling()->addChild(x->getFirstChild()->getNextSibling());
//				if (i<x->getNumberOfChildren()-1) last=last->getNextSibling();
			}
//			printf("i:%d\tnc:%d\n",i,x->getNumberOfChildren());
		}
		
	  	/*#expr=#(#r,[MULT],x->getNextSibling());
		#l->setNextSibling(x);
		#r->getFirstChild()->setFirstChild(l);
//		#x->setNextSibling(NULL);* /
	   } else
	   {
	   	#expr=#(MULT, #l, #r);
	   }
	  }*/)
/*	|!#(DIV l0:expr r0:expr
	  {if (r0->getType()==MULT || r0 -> getType()==DIV)
	   {
	   	AST x=r0->getFirstChild();
	  	#expr=#(r0,[DIV],x->getNextSibling());
		l0->setNextSibling(x);
		r0->getFirstChild()->setFirstChild(l);
	   }
	  })*/
/*	|!(#(DIV expr DIV) ) => (#(DIV x:expr y:DIV {/*#expr=#([DIV], #([DIV] #x,#y->getFirstChild()), #y->getFirstChild()->getNextSibling());* /
	RefFcAST z=#y ->getFirstChild();
	#expr=#([DIV],#([DIV],#x,z),z->getNextSibling());}))*/
	| #(DIV expr expr)
	| #(MOD expr expr)
	| #(MODPOS expr expr {#expr->setType(MOD);})
	| #(MODS expr expr {#expr->setType(MOD);})
	| #(TEXBMOD expr expr {#expr->setType(MOD);})
	| #(TEXPMOD pmod0:expr pmod1:expr {correctModP(#expr, #pmod0, #pmod1);})
	| #(TEXEQUIV expr expr {#expr->setType(EQUIV);})
	| #(MATRIXPRODUCT expr expr)
	| #(MATRIXEXPONENTIATION expr expr)
	| #(EQUIV expr expr)
	| #(FACTOROF expr expr)
	| #(TEXFACTOROF expr expr {#expr->setType(FACTOROF);})
	| #(CIRCUM expr expr)
	| #(FACTORIAL expr)
	| #(DFACTORIAL expr)
	| #(UNDERSCORE expr expr)
	| #(PM expr (expr)?)
	| #(MP expr (expr)?)
	| #(DERIVE expr expr)
	|!#(DERIVET dertexpr:expr {#expr=#(#[DERIVE, "^."], #dertexpr, #[VARIABLE, "t"]);})
	|!#(DDERIVET ddertexpr:expr {#expr=#(#[DERIVE, "^."], #(#[DERIVE, "^."], #ddertexpr, #[VARIABLE, "t"]), #[VARIABLE, "t"]);})
	|!#(DERIVEX derxexpr:expr {#expr=#(#[DERIVE, "'"], #derxexpr, #[VARIABLE, "x"]);})
	|!#(nthderive:NTHDERIVE what:expr (#(DEGREE first:expr second:expr) | (nth:expr (pairs:expr)?))
		{
			antlr::ASTFactory *astf=getASTFactory();
			if (#nth==antlr::nullAST && #pairs==antlr::nullAST)
			{
				#expr=#(#nthderive, #what, #first, #second);
//				puts(#expr->toStringList().c_str());
			}
			else
			if (#pairs==antlr::nullAST)
			{
				#expr=#(#nthderive, #what, #nth);
			}
			else
			if (#pairs->getType()==PAIR)
			{
				RefFcAST tmp=#pairs;
				RefFcAST circ=tmp->getFirstChild();
				RefFcAST newAST;
				if (circ->getType()==CIRCUM)
				{
					RefFcAST down=circ->getFirstChild();
					newAST=#(astf->dup(castt(#nthderive)), astf->dupTree(castt(#what)), astf->dupTree(castt(down->getNextSibling())), astf->dupTree(castt(down)));
				}
				else
				{
					newAST=#(astf->dup(castt(#nthderive)), astf->dupTree(castt(#what)), #[NUMBER, "1"], astf->dupTree(castt(circ)));
				}
				tmp=circ->getNextSibling();
				while (tmp->getType()==PAIR)
				{
					circ=tmp->getFirstChild();
					if (circ->getType()==CIRCUM)
					{
						RefFcAST down=circ->getFirstChild();
						newAST=#(astf->dup(castt(#nthderive)), astf->dupTree(castt(newAST)), astf->dupTree(castt(down->getNextSibling())), astf->dupTree(castt(down)));
					}
					else
					{
						newAST=#(astf->dup(castt(#nthderive)), astf->dupTree(castt(newAST)), #[NUMBER, "1"], astf->dupTree(castt(circ)));
					}
					tmp=circ->getNextSibling();
				}
				circ=tmp;
				if (circ->getType()==CIRCUM)
				{
					RefFcAST down=circ->getFirstChild();
					newAST=#(astf->dup(castt(#nthderive)), astf->dupTree(castt(newAST)), astf->dupTree(castt(down->getNextSibling())), astf->dupTree(castt(down)));
				}
				else
				{
					newAST=#(astf->dup(castt(#nthderive)), astf->dupTree(castt(newAST)), #[NUMBER, "1"], astf->dupTree(castt(circ)));
				}
				#expr=newAST;
			}
			else
			{
				if (#pairs->getFirstChild() == antlr::nullAST)
				{
					#expr=#(#nthderive, #what, #nth, #pairs);
				}
				else
				{
					RefFcAST tmp=#pairs->getFirstChild()->getNextSibling();
					if (tmp->equalsTree(castt(#nth)))
					{
						tmp=#pairs->getFirstChild();
						#expr=#(astf->dup(castt(#nthderive)), astf->dupTree(castt(#what)), astf->dupTree(castt(#nth)), astf->dupTree(castt(tmp)));
					}
					else
					{
						#expr=#(#nthderive, #what, #nth, #pairs);
					}
				}
			}
		}
	   )
	|!#(NTHDERIVEX nthder0:expr nthder1:expr {#expr=#(#[NTHDERIVE, "^(n)"], #nthder0, #nthder1, #[VARIABLE, "x"]);})
	| #(FUNCINVERSE expr)
//	| #(FUNCMULT expr expr)
//	| #(FUNCPLUS expr exrp)
	| #(DEFINTEGRAL expr expr expr expr)
	| #(INDEFINTEGRAL expr expr)
	| #(SUM expr expr expr expr)
	| #(PROD expr expr expr expr)
	| #(EQUAL expr expr {correctRelation(#expr);})
	| #(NEQ neq0:expr neq1:expr /*{#expr=#(#[NOT, "noteq"], #(#[EQUAL, "=="], neq0, neq1));}*/{correctRelation(#expr);})
	| #(LESS expr expr {correctRelation(#expr);})
	| #(LEQ expr expr {correctRelation(#expr);})
	| #(NOTLESS nless0:expr nless1:expr /*{#expr=#(#(#[LEQ, "\\leq"], nless1, nless0));}*/ {correctRelation(#expr);})
	| #(LESSNOTEQ expr expr {#expr->setType(LESS);} {correctRelation(#expr);})
	| #(NOTLEQ expr expr {correctRelation(#expr);})
	| #(GREATER expr expr /*{#expr=#(#[LESS, "<"], #grt1, #grt0);}*/ {correctRelation(#expr);})
	| #(GEQ expr expr /*{#expr=#(#[LEQ, "\\leq"], #geq1, #geq0);}*/ {correctRelation(#expr);})
	| #(NOTGREATER ngrt0:expr ngrt1:expr /*{#expr=#(#[LEQ, "\\leq"], #ngrt0, #ngrt1);}*/ {correctRelation(#expr);})
	| #(GREATERNOTEQ grtneq0:expr grtneq1:expr /*{#expr=#(#[LESS, "<"], #grtneq1, #grtneq0);}*/ {correctRelation(#expr);})
	| #(NOTGEQ ngeq0:expr ngeq1:expr /*{#expr=#(#[LESS, "<"], #ngeq0, #ngeq1);}*/ {correctRelation(#expr);})
//	| #(SETPOW expr expr)
//	| #(SETGENERATED expr)
	| #(SETSUBSET expr expr {correctRelation(#expr);})
	| #(SETSUBSETEQ expr expr {correctRelation(#expr);})
	|!#(SETSUBSETNEQ sbne0:expr sbne1:expr {#expr=#(#[SETSUBSET, "setsubsetneq"], #sbne0, #sbne1);} {correctRelation(#expr);})
	| #(SETNOTSUBSETEQ nse0:expr nse1:expr {correctRelation(#expr);})
	| #(SETSUPSET sp0:expr sp1:expr {correctRelation(#expr);})
	| #(SETSUPSETEQ spe0:expr spe1:expr {correctRelation(#expr);})
	| #(SETSUPSETNEQ expr expr {#expr->setType(SETSUPSET); correctRelation(#expr);})
	| #(SETNOTSUPSETEQ expr expr {correctRelation(#expr);})
	| #(SETIN expr expr {correctRelation(#expr);})
	|!#(SETNI ni0:expr ni1:expr {#expr=#(#[SETIN, "\\in"], ni1, ni0);})
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
	|!#(RIMPLY rim0:expr rim1:expr {#expr=#(#[IMPLY, "=>"], rim1, rim0);})
	|!#(IFF iff0:expr iff1:expr {#expr=#(#[AND, "and"], #(#[IMPLY, "=>"], iff0, iff1), #(#[IMPLY, "=>"], iff1, iff0));})
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
	|!n:NUMBER {string s=n->getText(); string::size_type pos=s.find('e'); if (pos==string::npos) pos=s.find('E'); if (pos!=string::npos) #expr=#(#[MULT,"*"], #[NUMBER,s.substr(0,pos)],#(#[CIRCUM,"^"],#[NUMBER,"10"],#[NUMBER,s.substr(pos+1)]));else #expr=#n;}
	| PARAMETER
	| DOTS
	| FC_TRUE
	| FC_FALSE
	|!ALPHA {#expr=#[PARAMETER, "alpha"];}
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
	|!OMICRON {#expr=#[PARAMETER, "omicron"];}
	| PI
	|!PIG {#expr=#[PARAMETER, "Pi"];}
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
	|!OMEGAG {#expr=#[PARAMETER, "Omega"];}
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
	|!#(PAIR pair0:expr pair1:expr {antlr::ASTFactory *astf=getASTFactory(); if (#pair1->getType()==NONE) #expr=astf->dupTree(castt(#pair0)); else #expr=#(PAIR, #pair0, #pair1);})
	|!#(LPAREN a:expr {if (#a->getType()==ENUMERATION && antlr::nullAST != #a->getFirstChild() && #a->getFirstChild()->getType()==VECTOR) #expr=#(#[MATRIX, "(matrix)"], #a); else if (#a->getType()==ENUMERATION) #expr=#(#[VECTOR, "(vec)"], #a); else #expr=#a;})
	|!#(lbracket:LBRACKET lbracketexpr:expr {if (#lbracketexpr->getType()==ENUMERATION && antlr::nullAST != #lbracketexpr->getFirstChild() && #lbracketexpr->getFirstChild()->getType()==VECTOR) #expr=#(#[MATRIX, "(matrix)"], #lbracketexpr); else if (#lbracketexpr->getType()==ENUMERATION) #expr=#(#[VECTOR, "(vec)"], #lbracketexpr);  else #expr=#(#lbracket, #lbracketexpr);})
	|!#(GCD gcd0:expr (gcd1:expr)? {if (#gcd1!=antlr::nullAST) #expr=#(#[FUNCTION, "function"], #GCD, #(#[ENUMERATION, ", "], #gcd0, #gcd1)); else #expr=#(#[FUNCTION, "function"], #GCD, #gcd0);})
	|!#(LCM lcm0:expr (lcm1:expr)? {if (#lcm1!=antlr::nullAST) #expr=#(#[FUNCTION, "function"], #LCM, #(#[ENUMERATION, ", "], #lcm0, #lcm1)); else #expr=#(#[FUNCTION, "function"], #LCM, #lcm0);})
	|!#(func:FUNCTION fname:expr farg:expr
		{
			antlr::ASTFactory *astf=getASTFactory();
			if (#fname->getType()==FUNCTION/* && #func->getText()=="userFunction"*/)
			{
				RefFcAST tmp=fname->getFirstChild();
				#expr=#(astf->dup(castt(#fname)), astf->dupTree(castt(tmp)), #(#func, astf->dupTree(castt(tmp->getNextSibling())), #farg));
			}
			else
			if (#fname->getType()==CIRCUM)
			{
				RefFcAST tmp=fname->getFirstChild();
				#expr=#(astf->dup(castt(#fname)), #(#func, astf->dupTree(castt(tmp)), #farg), astf->dupTree(castt(tmp->getNextSibling())));
			}
			else
			if (#fname->getType()==DERIVE || #fname->getType()==NTHDERIVE)
			{
				RefFcAST it=#fname;
				while (it->getFirstChild()->getType()==DERIVE || it->getFirstChild()->getType()==NTHDERIVE)
					it=it->getFirstChild();
				#expr=#fname;
				RefFcAST tmp=it->getFirstChild()->getNextSibling();
				RefFcAST newAST=#(astf->dup(castt(#func)), astf->dupTree(castt(it->getFirstChild())), astf->dupTree(castt(#farg)));
				it->setFirstChild(newAST);
				it->getFirstChild()->setNextSibling(tmp);
			}
			else
				#expr=#(#func, #fname, #farg);})
//	| #(SIZEOF expr {#expr=#(#[FUNCTION, "function"], #expr);})
//	| #(ABS expr {#expr=#(#[FUNCTION, "function"], #expr);})
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
	|!LN {#expr=#[LOG, "ln"];}
	|!LG {#expr=#(#[LOG, "log"], #[NUMBER, "10"]);}
	| #(LOG (expr)?)
	| SQRT
	| #(ROOT expr )
	| CEIL
	| FLOOR
        ;

