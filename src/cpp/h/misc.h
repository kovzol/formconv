#ifndef MISC_H
#define MISC_H

#include <vector>
#include <antlr/ASTFactory.hpp>
#include <antlr/CommonAST.hpp>
#include <antlr/ASTArray.hpp>
#include <string>

//Language type for the IntuitveLexer, and LaTeXOutput
typedef enum {C, hu, en, ge, fr, simple} Language;

//Precedence type in Presentation transform
typedef enum Precedence {NOTINPREC, PAREN, FUNCTIONDEF, POWER, MULTIPLY, ADDITION, RELATION, DISJUNCTION, CONJUNCTION, CONCLUSION} Precedence;

/**
 * This enum is responsible for strategy of the enumeration expansion.
 */
typedef enum {normal, matrixRow, matrix} EnumerationStrategy;
  
//Helper function for getting the Language type from a string
namespace formconvLanguage {
Language getLanguage(const std::string &s);
}

//For the PresentationTransform
typedef enum {no, automatic, yes} ThreeState;

template <class T> T manyToTwo(antlr::ASTFactory *astFactory, std::vector<T> &childs, int type, std::string s, T expr)
{
#ifndef __INTEL_COMPILER
	class
#endif
	std::vector<T>::iterator  it=childs.begin();
	expr=*it;
	++it;
	while (it!=childs.end())
	{
		expr=T(astFactory->make((new antlr::ASTArray(3))->add((antlr::RefAST)(astFactory->create(type, s)))->add((antlr::RefAST)expr)->add((antlr::RefAST)*it)));
		++it;
	}
	return expr;
}

#endif
