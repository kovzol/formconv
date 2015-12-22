
#include <iostream>
#include <string>

#include "IntuitiveLexer.hpp"
#include "IntuitiveParser.hpp"
#include "JavaOutput.hpp"
#include "ContentTransform.hpp"
#include "ContentTransform2.hpp"
#include "antlr/AST.hpp"
#include "antlr/CommonAST.hpp"
#include <h/fcAST.h>
			//Creates and puts out the stdout the C style output
			//(Does not handle errors)

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
		
		//Create the first transformator
		ContentTransform ct;
		//Init it
		ct.initializeASTFactory(my_factory);
		ct.setASTFactory(&my_factory);
		
//		cout << endl << parser.getAST()->toStringList() << endl;
		//Use the transformation
		ct.inp(RefFcAST(parser.getAST()));
//		cout << "Transformation end." << endl;
//		cout << "Transformed: " << endl << ct.getAST()->toStringList() << endl;
		
		//Create the second transformator
		ContentTransform2 ct2;
		//Init it
		ct2.initializeASTFactory(my_factory);
		ct2.setASTFactory(&my_factory);

		//Use the transformation
		ct2.inp(RefFcAST(ct.getAST()));
		
		//Create JavaOutput to create Java output
		JavaOutput java;
//		java.initializeASTFactory(my_factory);
//		java.setASTFactory(&my_factory);
		
		if (ast)
		{
//			cout << ast->toStringList() << endl; //Just for debug
//			cout << "Transformed to: " << ct.getAST()->toStringList() << endl;
//			cout << "Transformed to: " << ct2.getAST()->toStringList() << endl;
			//Creates and puts out the stdout the C style output
			//(Does not handle errors)
			std::string s=java.inp(RefFcAST(ct.getAST()));
			cout << s << endl;
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

