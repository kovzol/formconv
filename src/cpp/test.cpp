//This file is just for tesing (From this will be bin/intuitive)


#include <iostream>

#include "IntuitiveLexer.hpp"
#include "IntuitiveParser.hpp"
#include "antlr/AST.hpp"
#include "h/fcAST.h"
#include "antlr/CommonAST.hpp"

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
		RefFcAST ast = RefFcAST(parser.getAST());

		if (ast)
		{
			//Print out the AST
			cout << ast->toStringList() << endl;
			//Print out the root's roughType
			FcAST::printType(ast->roughType);
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

