#ifndef FASTCOMPUTE_H
#define FASTCOMPUTE_H
#include <IntuitiveLexer.hpp>
#include <IntuitiveParser.hpp>
#include <ContentTransform.hpp>
#include <ComplexCompute.hpp>
#include <ComplexComputeBoost.hpp>
#include <antlr/AST.hpp>
#include <antlr/ANTLRException.hpp>
#include <antlr/CommonAST.hpp>
#include <sstream>
#include <h/fcAST.h>
#include <h/fccomplexAST.h>
#include <h/fastcomplexcompute.h>
#include <h/fcversion.h>

//typedef std::complex<double> complex;

///A special formula-type just for ComplexCompute
template<class T> struct formula
{
	RefFcComplexAST tree;//TODO This should be a bit more templateish...
	T *comp;
	public:
	/**
	 * The constructor for the formula
	 * @param t a parsed and transformed AST
	 * @param c A pointer for a ComplexCompute class
	 */
	formula(RefFcComplexAST t, T *c):tree(t) //TODO This should be a bit more templateish...
	{
		comp=c;
	}

	/**
	 * Create a formula from the string.
	 * @param s a string containing the formula in intuitive format.
	 */
	formula(const std::string &s)
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
		tree = ct.getAST();

		//This transformation creates a new tree a bit more easier to compute it's value
		ComplexComputeBoost ccb;
		//This transformation needs a new factory of this type.
		antlr::ASTFactory my_factory2("FcComputeAST<std::complex<double> >", FcComputeAST<std::complex<double> >::factory);
		//Init the transformator
		ccb.initializeASTFactory(my_factory2);
		ccb.setASTFactory(&my_factory2);

		//Transform the tree
		ccb.inp(RefFcComplexAST(tree));

		//Get the transformed tree
		tree = RefFcComplexAST(ccb.getAST()); //TODO This should be a bit more templateish...

		//Create FastComplexCompute for the formula
		comp=new T();
	}

	complex<double> evaluate(const std::string &s, const std::complex<double> &c) const//TODO This should be a bit more templateish...
	{
		//Set s to c
		comp->setValue(s, c);
		//Compute
		return comp->inp(tree);
	}

	complex<double> evaluate(const std::complex<double> &c) const//TODO This should be a bit more templateish...
	{
		//Set z to c
		comp->setValue(c);
		//Compute
		return comp->inp(tree);
	}

	~formula()
	{
		delete comp;
	}
};

/**
 * Creates a (FastComplexCompute specific) formula from a string
 * @param s a string to create the formula
 * @return The formula
 */
template<class T> formula<T> *formconv_prepare(const std::string &s)
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
	antlr::RefAST tree = ct.getAST();
	
	//This transformation creates a new tree a bit more easier to compute it's value
	ComplexComputeBoost ccb;
	//This transformation needs a new factory of this type.
	antlr::ASTFactory my_factory2("FcComputeAST<std::complex<double> >", FcComputeAST<std::complex<double> >::factory);
	//Init the transformator
	ccb.initializeASTFactory(my_factory2);
	ccb.setASTFactory(&my_factory2);
	
	//Transform the tree
	ccb.inp(RefFcComplexAST(tree));
	
	//Get the transformed tree
	RefFcComplexAST tb = RefFcComplexAST(ccb.getAST()); //TODO This should be a bit more templateish...
	//Create FastComplexCompute for the formula
	T *comp=new T();

	//Return the new formula
	return new formula<T>(tb, comp);
}

// This code unfortunately seems not to work on gcc-4.0.x or gcc-3.3.x.
// Probably a bug exists in gcc. Tested on 4.0.2 (OpenSuSE Linux 10.0)
// and 3.3.1 (SuSE 9.0).
#ifndef BROKEN_GCC
template<> formula<FastComplexCompute <std::complex <double > > > *formconv_prepare(const std::string &s)
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
	antlr::RefAST tree = ct.getAST();
	
	//This transformation creates a new tree a bit more easier to compute it's value
	ComplexComputeBoost ccb;
	//This transformation needs a new factory of this type.
	antlr::ASTFactory my_factory2("FcComputeAST<std::complex<double> >", FcComputeAST<std::complex<double> >::factory);
	//Init the transformator
	ccb.initializeASTFactory(my_factory2);
	ccb.setASTFactory(&my_factory2);
	
	//Transform the tree
	ccb.inp(RefFcComplexAST(tree));
	
	//Get the transformed tree
	RefFcComplexAST tb = RefFcComplexAST(ccb.getAST()); //TODO This should be a bit more templateish...
	//Create FastComplexCompute for the formula
	FastComplexCompute<std::complex <double> > *comp=new FastComplexCompute <std::complex <double> >();

	//Return the new formula
	return new formula<FastComplexCompute <std::complex <double> > >(tb, comp);
}
#endif

/**
 * Evaluates the formula
 * T is preferably FastComplexCompute
 * @param f the formula to evaluate
 * @param s a string, which contains a variable to set
 * @param c a value to set the variable
 * @return The result of the formula at s=c
 */
template <class T>
complex<double> formconv_evaluate(const formula<T> *f, const std::string &s, std::complex<double> c)//TODO This should be a bit more templateish...
{
	//Set s to c
	f->comp->setValue(s, c);
	//Compute
	return f->comp->inp(f->tree);
}

/**
 * Evaluates the given formula at z=c value.
 * T is expected to be FastComplexCompute
 * @param f The ponter to the formula
 * @param c The new value of z
 */
template <class T>
complex<double> formconv_evaluate(const formula<T> *f, std::complex<double> c)//TODO This should be a bit more templateish...
{
	//Set s to c
	f->comp->setValue(c);
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
