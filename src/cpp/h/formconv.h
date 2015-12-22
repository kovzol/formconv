#ifndef FORMCONV_H
#define FORMCONV_H

/**
 * @deprecated in favor of fastcompute.h
 */


#include <IntuitiveLexer.hpp>
#include <IntuitiveParser.hpp>
#include <ContentTransform.hpp>
#include <ComplexCompute.hpp>
#include <antlr/AST.hpp>
#include <antlr/CommonAST.hpp>
#include <sstream>
#include <h/fcAST.h>
#include <h/fcversion.h>

//typedef std::complex<double> complex;

///A special formula-type just for ComplexCompute
template<class T> struct formula
{
	RefFcAST tree;
	T *comp;
	public:
	/**
	 * The constructor for the formula
	 * @param t a parsed and transformed AST
	 * @param c A pointer for a ComplexCompute class
	 */
	formula(RefFcAST t, T *c):tree(t)
	{
		comp=c;
	}
};

/**
 * Creates a (ComplexCompute specific) formula from a string
 * @param s a string to create the formula
 * @return The formula
 */
template<class T> formula<T> *formconv_prepare(std::string s)
{
	//Please always use a factory like this for the IntuitiveParser
	antlr::ASTFactory my_factory("FcAST", FcAST::factory);
	//Create a stringstream for parsing s
	std::stringstream ss(s, std::stringstream::in);
	//Create a lexer
	IntuitiveLexer lexer(ss);
	//Set the language - This is important!!!
	lexer.setLanguage(hu);
	//Set the lexer for the parser
	IntuitiveParser parser(lexer);
	//Parser initialization
	parser.initializeASTFactory(my_factory);
	parser.setASTFactory(&my_factory);
	
	//Setting some useful defaults, it is not important, but recommended
	//See IntuitiveParser.g for further information
	parser.init();
	//Start the parsing
	parser.expr();
	
	//Create the first transformator
	ContentTransform ct;
	//Init it
	ct.initializeASTFactory(my_factory);
	ct.setASTFactory(&my_factory);

	//Get the AST for further transformations and apply the transformation
	ct.inp(RefFcAST(parser.getAST()));
	
	//The second transformation is not necessary, because ComplexCompute does not
	//know the transformed features
	
	//Get the AST for furter computations
	RefFcAST tree = RefFcAST(ct.getAST());
	
	//Create ComplexCompute for the formula
	T *comp=new T();
	//Init it
	comp->initializeASTFactory(my_factory);
	comp->setASTFactory(&my_factory);
	//Return the new formula
	return new formula<T>(tree, comp);
}

/**
 * Evaluates the formula
 * @param f the formula to evaluate
 * @param s a string, which contains a variable to set
 * @param c a value to set the variable
 * @return The result of the formula at s=c
 */
template <class T>
complex<double> formconv_evaluate(const formula<T> *f, const std::string s, std::complex<double> c)
{
	//Set s to c
	f->comp->setValue(s, c);
	//Compute
	return f->comp->inp(f->tree);
}

/**
 * Deletes the formula
 */
template <class T>
void formconv_free(formula<T> *f)
{
	delete f->comp;
}

#endif
