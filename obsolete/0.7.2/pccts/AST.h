#ifndef AST_h
#define AST_h

/**
 * Version: $Id: AST.h,v 1.2 2004/12/15 13:37:36 baga Exp $
 */

#include "ASTBase.h"
#include "AToken.h"
#include "ATokPtr.h"
typedef ANTLRCommonToken ANTLRToken;

#define NOT_IMPLEMENTED 2
#define DEBUG 0

enum language {DEFAULT, HUNGARIAN, ENGLISH, FRENCH, GERMAN, SPANISH, ITALIAN, CHINESE};

class AST : public ASTBase {
protected:
	ANTLRTokenPtr token;
public:
	bool isBool;
	bool isInteger;
	bool isInanIntegralDomain;//it is in an Integral ring, if (isInanIntegralDomain || isPolynomial) /
		//Hun: Integritástartomány, Pl.: Z, R[x],
	bool isPolynomial;//this may be false, even if it is a Polynomial: ex.: 4; 3.4; ..., I don't want to accept sqrt(x) as a Polynomial
	bool isRational;
	bool isReal;
	bool isConstant;
	bool isSet;
	bool isList;

//Kellene figyelni a 0-nál nagyobbságot is. Lehet, hogy nem megfelelõ a bool logika.
//
//
public:
	/* These ctor are called when you ref node constructor #[tok,s] */
	AST(ANTLRTokenType tok, char *s) : isBool(false), isInteger(false), isInanIntegralDomain(false), isPolynomial(true), isRational(false), isReal(true), isConstant(false), isSet(false), isList(false)
	{
		token = new ANTLRToken(tok, s);
	}
	AST(ANTLRTokenType tok, int i=0) : isBool(false), isInteger(false), isInanIntegralDomain(false), isPolynomial(false), isRational(false), isReal(true), isConstant(false), isSet(false), isList(false)
	{
		token = new ANTLRToken(tok, "");
	}
	AST(ANTLRTokenPtr t) : isBool(false), isInteger(false), isInanIntegralDomain(false), isPolynomial(false), isRational(false), isReal(true), isConstant(false), isSet(false), isList(false)
	{
		token = t;
	}
	AST(const AST &t)	// shallow copy constructor
	{
		token = t.token;
		isBool=t.isBool;
		isInteger=t.isInteger;
		isInanIntegralDomain=t.isInanIntegralDomain;
		isPolynomial=t.isPolynomial;
		isRational=t.isRational;
		isReal=t.isReal;
		isConstant=t.isConstant;
		isSet=t.isSet;
		isList=t.isList;
		setDown(NULL);
		setRight(NULL);
	}
	virtual void preorder_action(void *x)
	{
		char *s = token->getText();
		printf(" %s",s);
	}
	virtual int type() { return token->getType(); }
	char *getText()	   { return token->getText(); }
	void setText(char *s) { token->setText(s); }
	virtual PCCTS_AST *shallowCopy()
	{
	    return new AST(*this);
	}

	virtual PCCTS_AST *deepCopy()
	{
	    PCCTS_AST *ret=new AST(*this);
	    PCCTS_AST *current=this->down();
	    PCCTS_AST *cursor=ret;
	    if (current)
	    {
		    cursor->setDown(current->deepCopy());
		    cursor=cursor->down();
		    current=current->right();
	    }
	    while (current)
	    {
		    cursor->setRight(current->deepCopy());
		    cursor=cursor->right();
		    current=current->right();
	    }
	    return ret;
	}

	void copyProperties(const AST &t)
	{
		isBool=t.isBool;
		isInteger=t.isInteger;
		isInanIntegralDomain=t.isInanIntegralDomain;
		isPolynomial=t.isPolynomial;
		isRational=t.isRational;
		isReal=t.isReal;
		isConstant=t.isConstant;
	}
};

#endif

