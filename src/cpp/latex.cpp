
#include <iostream>
#include <string>

#include "IntuitiveLexer.hpp"
#include "IntuitiveParser.hpp"
#include "LaTeXOutput.hpp"
#include "PresentationTransform.hpp"
#include "antlr/AST.hpp"
#include "antlr/CommonAST.hpp"
#include <h/fcAST.h>

int main( int, char** )
{
	//Just to avoid the unnecessary antlr:: and std:: prefixes
	ANTLR_USING_NAMESPACE(std)
	ANTLR_USING_NAMESPACE(antlr)
	try {
		//Please always use a factory like this for the IntuitiveParser
		ASTFactory my_factory("FcAST", FcAST::factory);
		//Create a lexer
		IntuitiveLexer lexer(cin);
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
		//Get the AST for further transformations
		RefCommonAST ast = RefCommonAST(parser.getAST());
		
		//Create the presentation transformator
		PresentationTransform pt;
		//Set wheter or not simplify (remove unnecessary parentheses from the
		//formula)
		pt.setSimplify();
		//Init it
		pt.initializeASTFactory(my_factory);
		pt.setASTFactory(&my_factory);
		//Set wheter or not change the invisible times to visible times
		pt.setInvisibleTimes(automatic);

//		cout << endl << parser.getAST()->toStringList() << endl;
		//Use the transformation
		pt.inp((RefFcAST)parser.getAST());
//		cout << "Transformation end." << endl;
//		cout << "Transformed: " << endl << pt.getAST()->toStringList() << endl;

		//Create LaTeXOutput to create LaTeX ouptut from ast
		LaTeXOutput latex;
		//Init it
		latex.initializeASTFactory(my_factory);
		latex.setASTFactory(&my_factory);
		//Setting the language is recommended
		latex.setLanguage(hu);
		//Wheter or not use dynamic parentheses
		latex.setDynamicParentheses(true);
		
		std::string s=latex.inp(RefFcAST(pt.getAST()));
		cout << s << endl;

		if (ast)
		{
			cout << ast->toStringList() << endl; //just for debug
			//Creates and puts out the stdout the LaTeX output
			//(Does not handle errors)
			cout << "Transformed to: " << pt.getAST()->toStringList() << endl;
		}
		else
			cout << "null AST" << endl;
	}
	catch( ANTLRException& e )
	{
		cerr << "exception: " << e.getMessage() << endl;
		return -1;
	}
	catch( exception& e )
	{
		cerr << "exception: " << e.what() << endl;
		return -1;
	}
	return 0;
}

