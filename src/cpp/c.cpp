
#include <iostream>
#include <string>

#include "IntuitiveLexer.hpp"
#include "IntuitiveParser.hpp"
#include "COutput.hpp"
#include "ContentTransform.hpp"
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
		RefFcAST ast = RefFcAST(parser.getAST());
		
		//Create the first transformator
		ContentTransform ct;
		//Init it
		ct.initializeASTFactory(my_factory);
		ct.setASTFactory(&my_factory);
		
//		cout << endl << parser.getAST()->toStringList() << endl; //Just for debug
		//Use the transformation
		ct.inp(RefFcAST(parser.getAST()));
//		cout << "Transformation end." << endl;
//		cout << "Transformed: " << endl << ct.getAST()->toStringList() << endl;
		
		//The second transformation is not necessary, because COutput does not
		//know the transformed features
		//Use COutput to create C output
		COutput c;
		//Init it
		c.initializeASTFactory(my_factory);
		c.setASTFactory(&my_factory);
		
//		std::string s=java.inp(ct.getAST());
//		cout << s << endl;

		if (ast)
		{
//			cout << ast->toStringList() << endl; //Just for debug
//			cout << "Transformed to: " << ct.getAST()->toStringList() << endl;
			//Creates and puts out the stdout the C style output
			//(Does not handle errors)
			cout << c.inp(RefFcAST(ct.getAST())) << endl;
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

