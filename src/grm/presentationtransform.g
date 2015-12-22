header {
#include <string>
#include <h/misc.h>
#include <h/fcAST.h>
#include <stdio.h>
using namespace std;
}

options {
        language=Cpp;
}

/**
 * This file creates an AST. The input must use the Intuitive AST format. This uses some transformations for better output.
 * Generation depends on the following files:
 * IntuitiveTokenTypes.txt
 * Compilation depends on the following files:
 * h/misc.h
 * From this file the following files will be created:
 * PresentationTransform.cpp, PresentationTransform.hpp, PresentationTransformTokenTypes.hpp, PresentationTransformTokenTypes.txt
 *
 * Possible options:
 *   simplify - removes the unnecessary parentheses
 *   invisibleTimes - sets times to invisibleTimes
 *   divAsFrac - when possible use frac instead /
 *   simplifyPower - remove the parentheses from the exponent
 * @author Gabor Bakos (baga@users.sourceforge.net)
 * @version $Id: presentationtransform.g,v 1.38 2010/04/14 22:05:17 kovzol Exp $
 *
 * TODO review simplifyPower==false
 */

class PresentationTransform extends TreeParser;
options {
	buildAST=true;
	importVocab=Intuitive;
	ASTLabelType = "RefFcAST";
//      ASTLabelType = "antlr.CommonAST";
	defaultErrorHandler=false;
}

{
#define castt(x) ((antlr::RefAST)x)
	bool simplify, simplifyPower;
	int up, down;
	ThreeState invisibleTimes, divAsFrac;

	typedef Precedence (*pointerToTokenPrecedence) (const int t);

	pointerToTokenPrecedence tokenPrecedence;

	public:
	void setSimplify(const bool val=true)
	{
		simplify=val;
	}
	
	void setSimplifyPower(const bool val=true)
	{
		simplifyPower=val;
	}
	
	void setInvisibleTimes(const ThreeState t)
	{
		invisibleTimes=t;
	}

	void setDivAsFrac(const ThreeState val=yes)
	{
		divAsFrac = val;
	}

	void setTokenPrecedence(pointerToTokenPrecedence functionPointer)
	{
		tokenPrecedence = functionPointer;
	}

	static Precedence presentationTokenPrecedence(const int t)
	{
		Precedence ret=NOTINPREC;
		switch (t)
		{
			case PLUS:
			case MINUS:
			case SETUNION:
			case SETINTERSECT:
			case SETMINUS:
			case PM:
			case MP:
			case SUM:
			case NEG:
				ret=ADDITION;
				break;
			case MULT:
			case DIV:
			case FUNCMULT:
			case SETMULT:
			case PROD:
			case MATRIXPRODUCT:
				ret=MULTIPLY;
				break;
			case CIRCUM:
			case MATRIXEXPONENTIATION:
				ret=POWER;
				break;
			case LPAREN:
			case LBRACKET:
			case ABS:
				ret=PAREN;
				break;
			case EQUAL:
			case NEQ:
			case LESS:
			case LEQ:
			case NOTLESS:
			case NLEQ:
			case GREATER:
			case GEQ:
			case NOTGREATER:
			case NGEQ:
			case SETSUBSET:
			case SETSUBSETEQ:
			case SETSUBSETNEQ:
			case SETNOTSUBSETEQ:
			case SETSUPSET:
			case SETSUPSETEQ:
			case SETSUPSETNEQ:
			case SETNOTSUPSETEQ:
			case SETIN:
			case SETNI:
			case SETNOTIN:
			case SETNOTNI:
				ret=RELATION;
				break;
			case OR:
				ret=DISJUNCTION;
				break;
			case AND:
				ret=CONJUNCTION;
				break;
			case IMPLY:
			case RIMPLY:
				ret=CONCLUSION;
				break;

		}
		return ret;
	}

protected:

/*	Precedence tokenPrecedence(const antlr::AST &p) const
	{
		return tokenPrecedence(p.getType());
	}

	Precedence tokenPrecedence(const RefFcAST p) const
	{
		return tokenPrecedence(p->getType());
	}
*/
	RefFcAST correct(RefFcAST p_AST, RefFcAST left, RefFcAST right)
	{
		Precedence pr=tokenPrecedence(p_AST->getType());
		if (pr)
		{
//			RefFcAST left=p->getFirstChild(), right=p->getNextSibling();
			Precedence pr0=tokenPrecedence(left->getType()), pr1=tokenPrecedence(right->getType());
//			printf("pr: %d,\tpr0:%d,\tpr1:%d\n", pr, pr0, pr1);
			if (pr0)
			{
				if (pr0>pr)
				{
					if (pr1)
					{
						if (pr1>pr)
						{
							p_AST->parenDepth=max(left->parenDepth+1, right->parenDepth+1);
							return #(p, #(#[LPAREN, "("], left), #(#[LPAREN, "("], right));
						}
						else
						if (right->getType()==LPAREN && simplify)
						{
							pr1=tokenPrecedence(right->getFirstChild()->getType());
							if (pr1<pr)
							{
								right=right->getFirstChild();
							}
						}
						else
						if (pr1==pr && (p_AST->getType()==MINUS || p_AST->getType()==PM || p_AST->getType()==MP || p_AST->getType()==DIV))
						{
							right=#(#[LPAREN, "("], right);
							++(right->parenDepth);
						}
					}
					else
					{
						right=#(#[LPAREN, "("], right);
						++(right->parenDepth);
					}
					p_AST->parenDepth=max(left->parenDepth+1, right->parenDepth);
					return #(p, #(#[LPAREN, "("], left), right);
				}
				if (left->getType()==LPAREN && simplify)
				{
					pr0=tokenPrecedence(left->getFirstChild()->getType());
					if (pr0<=pr)
					{
						left=left->getFirstChild();
					}
				}
			}
			if (pr1)
			{
				if (pr1>pr)
				{
					p_AST->parenDepth=max(left->parenDepth, right->parenDepth+1);
					return #(p, left, #(#[LPAREN, "("], right));
				}
				else
				if (right->getType()==LPAREN && simplify)
				{
					pr1=tokenPrecedence(right->getFirstChild()->getType());
					if (pr1<pr)
					{
						right=right->getFirstChild();
					}
				}
				else
				{
					const int type = p_AST->getType();
					if (pr1>pr || (pr1==pr && (type==MINUS || type==PM || type==MP || type==DIV)))
					{
						right=#(#[LPAREN, "("], right);
						++(right->parenDepth);
					}
				}
			}
			left->setNextSibling(antlr::nullAST);
			right->setNextSibling(antlr::nullAST);
		}
		p_AST->parenDepth=max(left->parenDepth, right->parenDepth);
		return #(p_AST, left, right);
	}
}

inp	:	({down=up=0;} e:expr {if (#e->getType()==LPAREN && simplify) #inp=#e->getFirstChild();})
	|
	;

expr	:
	 !#(l0:PLUS l1:expr l2:expr {#expr=correct(#l0, #l1, #l2);})
	|!#(l3:MINUS l4:expr l5:expr {#expr=correct(#l3, #l4, #l5);})
	|!#(negSign:NEG neg:expr {Precedence p=tokenPrecedence(#neg->getType()); if (p<tokenPrecedence(NEG) && #neg->getType()!=LPAREN && !(#neg->getType()==DIV && divAsFrac != no) && #neg->getType()!=NUMBER && #neg->getType()!=VARIABLE && #neg->getType()!=PARAMETER && #neg->getType()!=E && #neg->getType()!=I) #expr=#(#negSign, #(#[LPAREN, "("], #neg)); else if (simplify && #neg->getType()==LPAREN && !(#neg->getFirstChild()->getType()==PLUS || #neg->getFirstChild()->getType()==MINUS)) {antlr::ASTFactory *astf = getASTFactory(); antlr::RefAST tmp = astf->dupTree(castt(#neg->getFirstChild())); #expr=#(#negSign, tmp);} else #expr=#(#negSign, #neg);})
	|!#(l6:MULT l7:expr l8:expr {#expr=correct(#l6, #l7, #l8); if (!((#l7->getType()==NUMBER || #l7->getType()==MULT || #l7->getType()==INVISIBLETIMES) && (#l8->getType()==NUMBER || #l8->getType()==MULT || #l8->getType()==INVISIBLETIMES)) && invisibleTimes==automatic) #l6->setType(INVISIBLETIMES); else if (invisibleTimes==yes) #l6->setType(INVISIBLETIMES);})
	|!#(mp0:MATRIXPRODUCT mp1:expr mp2:expr {#expr=correct(#mp0, #mp1, #mp2); if (!(#mp1->getType()==NUMBER || #mp2->getType()==NUMBER) && invisibleTimes==automatic) #mp0->setType(INVISIBLETIMES); else if (invisibleTimes==yes) #mp0->setType(INVISIBLETIMES);})
	|!#(me0:MATRIXEXPONENTIATION me1:expr me2:expr {#expr=correct(#me0, #me1, #me2);})
	|!#(d:DIV e1:expr e2:expr
	{
		if (divAsFrac==yes || (divAsFrac==automatic && up==0 && down==0))
		{
			if (!simplify)
			{
				#expr=#(#d, #e1, #e2);
			}
			else if (#e1->getType()==LPAREN && #e2->getType()!=LPAREN)
			{
				#e1=#e1->getFirstChild();
				#e1->setNextSibling(antlr::nullAST);
				#expr=#(#d, #e1, #e2);
			}
			else if (#e1->getType()==LPAREN && #e2->getType()==LPAREN)
			{
				#e1=#e1->getFirstChild();
				#e1->setNextSibling(antlr::nullAST);
				#e2=#e2->getFirstChild();
				#e2->setNextSibling(antlr::nullAST);
				#expr=#(#d,#e1, #e2);
			}
			else if (#e1->getType()!=LPAREN && #e2->getType()!=LPAREN)
			{
				#expr=#(#d, #e1, #e2);
			}
			else if (#e1->getType()!=LPAREN && #e2->getType()==LPAREN)
			{
				#e2=#e2->getFirstChild();
				#e2->setNextSibling(antlr::nullAST);
				#expr=#(#d,#e1,#e2);
			}
		}
		else
		{
			#expr=correct(#d, #e1, #e2);
		}
	}
	  )
	| #(MOD expr expr)
	| #(MODPOS expr expr {#expr->setType(MOD);})
	| #(MODS expr expr {#expr->setType(MOD);})
	| #(TEXPMOD expr expr {#expr->setType(MODP);})
	| #(MODP expr expr)
	| #(TEXBMOD expr expr {#expr->setType(MOD);})
	| #(TEXFACTOROF expr expr {#expr->setType(FACTOROF);})
	| #(FACTOROF expr expr)
	| #(TEXEQUIV expr expr {#expr->setType(EQUIV);})
	| #(EQUIV expr expr)
	|!#(CIRCUM e3:expr {++up;} e4:expr {--up;}
		{
			if (#e4->getType()==LPAREN && simplifyPower)
			{
				antlr::ASTFactory* astf =  getASTFactory();
				antlr::RefAST tmp = astf->dupTree(castt(#e4->getFirstChild()));
				if (#e3->getType()==DIV || #e3->getType()==NEG)
					#expr=#(#[CIRCUM], #(#[LPAREN],#e3),tmp);
				else
					#expr=#(#[CIRCUM], #e3, tmp);					}
			else if (#e3->getType()==/*FUNCTION && #e3->getFirstChild()->getType()==*/EXP)
			{
				#expr=#(#[CIRCUM], #(#[LPAREN, "("], #e3), #e4);
			}
			else
			{
				Precedence pr=tokenPrecedence(#e3->getType()), c=tokenPrecedence(CIRCUM);
				if (pr>c)
				{
					Precedence pr2=tokenPrecedence(#e4->getType());
					if (pr2>c)
						#expr=#(#[CIRCUM], #(#[LPAREN, "("], #e3), #(#[LPAREN, "("], #e4));
					else
						#expr=#(#[CIRCUM], #(#[LPAREN, "("], #e3), #e4);
				}
				else
				{
					Precedence pr2=tokenPrecedence(#e4->getType());
					if (pr2>c)
						#expr=#(#[CIRCUM], #e3, #(#[LPAREN, "("], #e4));
					else
						#expr=#(#[CIRCUM], #e3, #e4);
				}
			}
		}
	   )
	| #(FACTORIAL expr)
	| #(DFACTORIAL expr)
	| #(UNDERSCORE expr {++down;} expr {--down;})
	|!#(l11:PM l12:expr (l13:expr)? {Precedence p=tokenPrecedence(#l12->getType()); if (#l13!=antlr::nullAST) {#expr=correct(#l11, #l12, #l13); } else {if (p && simplify!=no && #l11->getType()!=LPAREN) #expr=#(#l11, #(#[LPAREN, "("], #l12)); else #expr=#(#l11, #l12);}})
	|!#(l14:MP l15:expr (l16:expr)? {Precedence p=tokenPrecedence(#l15->getType()); if (#l16!=antlr::nullAST) {#expr=correct(#l14, #l15, #l16);} else {if (p && simplify!=no && #l15->getType()!=LPAREN) #expr=#(#l14, #(#[LPAREN, "("], #l15)); else #expr=#(#l14, #l15);}})
	| #(DERIVE expr expr)
	| #(DERIVET expr)
	| #(DDERIVET expr)
	| #(DERIVEX expr)
	| #(NTHDERIVE expr expr expr)
	|!#(NTHDERIVEX eee0:expr eee1:expr {if (simplifyPower) #expr=#(#[CIRCUM, "^"], #eee0, #(#[LPAREN, "("], #eee1)); else #expr=#(#NTHDERIVEX, #eee0, #eee1);})
//	| #(FUNCMULT expr expr)
//	| #(FUNCPLUS expr exrp)
	| #(FUNCINVERSE expr)
	| #(DEFINTEGRAL expr expr expr expr)
	| #(INDEFINTEGRAL expr expr)
	| #(SUM expr expr expr expr)
	| #(PROD expr expr expr expr)
	| #(l21:EQUAL l22:expr l23:expr {#expr=correct(#l21, #l22, #l23);})
	| #(l24:NEQ l25:expr l26:expr {#expr=correct(#l24, #l25, #l26);})
	| #(l27:LESS l28:expr l29:expr {#expr=correct(#l27, #l28, #l29);})
	| #(l270:LEQ l280:expr l290:expr {#expr=correct(#l270, #l280, #l290);})
	| #(l31:NOTLESS l32:expr l33:expr {#expr=correct(#l31, #l32, #l33);})
	| #(l34:LESSNOTEQ l35:expr l36:expr {#expr=correct(#l34, #l35, #l36);})
	| #(l37:NOTLEQ l38:expr l39:expr {#expr=correct(#l37, #l38, #l39);})
	| #(l41:GREATER l42:expr l43:expr {#expr=correct(#l41, #l42, #l43);})
	| #(l410:GEQ l420:expr l430:expr {#expr=correct(#l410, #l420, #l430);})
	| #(l44:NOTGREATER l45:expr l46:expr {#expr=correct(#l44, #l45, #l46);})
	| #(l47:GREATERNOTEQ l48:expr l49:expr {#expr=correct(#l47, #l48, #l49);})
	| #(l51:NOTGEQ l52:expr l53:expr {#expr=correct(#l51, #l52, #l53);})
//	| #(SETPOW expr expr)
//	| #(SETGENERATED expr)
	| #(l61:SETSUBSET l62:expr l63:expr {#expr=correct(#l61, #l62, #l63);})
	| #(l64:SETSUBSETEQ l65:expr l66:expr {#expr=correct(#l64, #l65, #l66);})
	| #(l67:SETSUBSETNEQ l68:expr l69:expr {#expr=correct(#l67, #l68, #l69);})
	| #(l71:SETNOTSUBSETEQ l72:expr l73:expr {#expr=correct(#l71, #l72, #l73);})
	| #(l74:SETSUPSET l75:expr l76:expr {#expr=correct(#l74, #l75, #l76);})
	| #(l77:SETSUPSETEQ l78:expr l79:expr {#expr=correct(#l77, #l78, #l79);})
	| #(l81:SETSUPSETNEQ l82:expr l83:expr {#expr=correct(#l81, #l82, #l83);})
	| #(l84:SETNOTSUPSETEQ l85:expr l86:expr {#expr=correct(#l84, #l85, #l86);})
	| #(l87:SETIN l88:expr l89:expr {#expr=correct(#l87, #l88, #l89);})
	| #(l91:SETNI l92:expr l93:expr)
	| #(SET expr (expr)?)
	| #(l101:SETMINUS l102:expr l103:expr {#expr=correct(#l101, #l102, #l103);})
	| #(l104:SETMULT l105:expr l106:expr {#expr=correct(#l104, #l105, #l106);})
	| #(l107:SETUNION l108:expr l109:expr {#expr=correct(#l107, #l108, #l109);})
	| #(l111:SETINTERSECT l112:expr l113:expr {#expr=correct(#l111, #l112, #l113);})
	| #(ASSIGN expr expr)
	| #(NOT expr)
	| #(l121:AND l122:expr l123:expr {#expr=correct(#l121, #l122, #l123);})
	| #(l124:OR l125:expr l126:expr {#expr=correct(#l124, #l125, #l126);})
//	| #(NAND expr expr)
//	| #(NOR expr expr)
	| #(l141:IMPLY l142:expr l143:expr {#expr=correct(#l141, #l142, #l143);})
	| #(l144:RIMPLY l145:expr l146:expr {#expr=correct(#l144, #l145, #l146);})
	| #(l151:IFF l152:expr l153:expr {#expr=correct(#l151, #l152, #l153);})
	| #(FORALL expr expr)
	| #(EXISTS expr expr)
	| #(LIM expr expr expr (expr)?)
	| #(LIMSUP expr (expr)?)
	| #(LIMINF expr (expr)?)
	| #(SUP expr (expr)?)
	| #(INF expr (expr)?)
	| #(MAX expr (expr)?)
	| #(MIN expr (expr)?)
	| #(ARGMAX expr expr)
	| #(ARGMIN expr expr)
	| LEFT
	| RIGHT
	| REAL
	| COMPLEX
	| variable:VARIABLE {#variable->parenDepth=0;}
	|!num:NUMBER
	{
		std::string s=#num->getText();
		std::string::size_type pos=s.find('e');
		if (pos==std::string::npos)
			pos=s.find('E');
		if (pos!=std::string::npos)
			#expr=#(#[MULT, "*"], #[NUMBER, s.substr(0, pos)], #(#[CIRCUM, "^"], #[NUMBER, "10"], #[NUMBER, s.substr(pos+1)]));
		else
			#expr=#num;
		#num->parenDepth=0;
	}
	| parameter:PARAMETER {#parameter->parenDepth=0;}
	| DOTS
	| FC_TRUE
	| FC_FALSE
	| ALPHA
	| BETA
	| GAMMA
	| GAMMAG
	| DELTA
	| DELTAG
	| EPSILON
	| ZETA
	| ETA
	| THETA
	| THETAG
	| IOTA
	| KAPPA
	| LAMBDA
	| LAMBDAG
	| MU
	| NU
	| XI
	| XIG
	| OMICRON
	| PI
	| PIG
	| RHO
	| SIGMA
	| SIGMAG
	| TAU
	| UPSILON
	| UPSILONG
	| PHI
	| PHIG
	| CHI
	| PSI
	| PSIG
	| OMEGA
	| OMEGAG
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
	| #(enumeration:ENUMERATION {RefFcAST prev=(RefFcAST)antlr::nullAST;} (p:expr
				{
					if (simplify)
					{
						if (prev!=(RefFcAST)antlr::nullAST)
							prev->setNextSibling(#p);
						if (#p->getType()==LPAREN && #p->getFirstChild()->getType()!=ENUMERATION)
						{
							if (prev==(RefFcAST)antlr::nullAST)
							{
								#enumeration->setFirstChild(#p->getFirstChild());
								#p=#p->getFirstChild();
							}
							else
							{
								prev->setNextSibling(#p->getFirstChild());
								#p=#p->getFirstChild();
							}
						}
					}
					prev=#p;
				}
			)*
	   )
	| #(PAIR expr expr)
	|!#(l:LPAREN a:expr
		{
			if (simplify && (#a->getType()==LPAREN || #a->getType()==ABS || #a->getType()==FUNCTION))
			{
				#expr=#a;
			}
			else
			{
				#expr=#(#l,#a);
				#l->parenDepth=#a->parenDepth+1;
			}
		}
	   )
	|!#(lbracket:LBRACKET lbracketExpr:expr
	{
		if (#lbracketExpr->getType()==ENUMERATION && antlr::nullAST != #lbracketExpr->getFirstChild() && #lbracketExpr->getFirstChild()->getType()==VECTOR)
		{
			#expr=#(#[MATRIX, "(matrix)"], #lbracketExpr);
			RefFcAST it=#lbracketExpr->getFirstChild();
			for (;it!=antlr::nullAST; it=it->getNextSibling())
			{
				it->setType(MATRIXROW);
				it->setText("(row)");
			}
		}
		else if (#lbracketExpr->getType()==ENUMERATION)
		{
			#expr=#(#[VECTOR, "(vec)"], #lbracketExpr);
		}
		else
		{
			#expr=#(#lbracket, #lbracketExpr);
		}
	})
	| #(MATRIX expr)
	| #(MATRIXROW expr)
	| #(VECTOR expr)
	|!#(GCD (gcd0:expr (gcd1:expr)?)? {if (!simplifyPower) #expr=#GCD; else if (#gcd1!=antlr::nullAST) #expr=#(#[FUNCTION, "function"], #GCD, #(#[ENUMERATION, ", "], #gcd0, #gcd1)); else #expr=#(#[FUNCTION, "function"], #GCD, #gcd0);})
	|!#(LCM (lcm0:expr (lcm1:expr)?)? {if (!simplifyPower) #expr=#LCM; else if (#lcm1!=antlr::nullAST) #expr=#(#[FUNCTION, "function"], #LCM, #(#[ENUMERATION, ", "], #lcm0, #lcm1)); else #expr=#(#[FUNCTION, "function"], #LCM, #lcm0);})
	|!#(FUNCTION funcName:expr funcArg:expr
	   {
	    if (simplifyPower)
		{
         const Precedence arg = tokenPrecedence(#funcArg->getType());
		 if (arg != NOTINPREC && arg != PAREN && arg != FUNCTIONDEF)
         {
           #funcArg = #(#[LPAREN, "("], #funcArg);
         }
	     const int type=#funcName->getType();
	     antlr::ASTFactory *astf = getASTFactory();
             RefFcAST name = RefFcAST(astf->dupTree(castt(#funcName)));
	     if ((type==CEIL || type==FLOOR || type==ABS || type==SQRT || type==EXP || type==COMPLEMENTER || type==CONJUGATE || type==TRANSPONATE) && #FUNCTION->getText()=="function")
	     {
	       if (#funcArg->getType()==LPAREN)
		   {
		     #expr=astf->dupTree(castt(#funcArg->getFirstChild()));
	         #expr=#(name, #expr);
		   }
	       else
	         #expr=#(name, #funcArg);
	     }
	     else
	     if (type==ROOT)
	     {
	       if (#funcArg->getType()==LPAREN)
		   {
		     #expr=astf->dupTree(castt(#funcArg->getFirstChild()));
	         #expr=#(name, astf->dupTree(castt(#funcName->getFirstChild())), #expr);
		   }
	       else
	         #expr=#(name, astf->dupTree(castt(#funcName->getFirstChild())), #funcArg);
	     }
	     else
/*	     if (#funcArg->getType()==CIRCUM && (#funcArg->getFirstChild()->getType() == LPAREN || ((divAsFrac == yes || divAsFrac == automatic) && #funcArg->getFirstChild()->getType() == DIV)))//This is not correct in every transformations, but good, in this case.
	     {
	       RefFcAST exp0=astf->dupTree(castt(#funcArg->getFirstChild())), exp1=astf->dupTree(castt(exp0->getNextSibling()));
	       exp0->setNextSibling(antlr::nullAST);
	       #expr=#(#[CIRCUM, "^"], #(#FUNCTION, #funcName, exp0), exp1);
	     }
	     else*/
	     {
	     	#expr=#(#FUNCTION, #funcName, #funcArg);
	     }
		}
		else
		{
		 #expr=#(#FUNCTION, #funcName, #funcArg);
		}
	   })
	| #(TYPEDEF expr)
	|!#(decl:DECLARE decl0:expr (decl1:expr)?
	   {
		std::string s=#decl->getText();
		if (s.find("function")!=std::string::npos)
			#expr=#(#decl, #(#[FUNCTION, "userFunction"], #decl0), #decl1);
		else
		if (s.find("vector")!=std::string::npos)
		{
			if (#decl1==antlr::nullAST)
				#expr=#(#[TYPEDEF, #decl->getText()], #decl0);
			else
				#expr=#(#[ASSIGN], #(#[TYPEDEF, #decl0->getText()], #decl0), #decl1);
		}
		else
			#expr=#(#[ASSIGN, #decl->getText()], #decl0, #decl1);
	   })
	| #(LAMBDACONSTRUCT expr expr)
	| #(SIZEOF expr)
	| #(ABS (expr)?)
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
	| #(CONJUGATE (expr)?)
	| #(TRANSPONATE (expr)?)
	| #(COMPLEMENTER (expr)?)
	| #(EXP (expr)?)
	| LN
	| LG
	| #(LOG (expr)?)
	| #(SQRT (expr)?)
	| #(ROOT expr (expr)?)
	| #(CEIL (expr)?)
	| #(FLOOR (expr)?)
        ;

