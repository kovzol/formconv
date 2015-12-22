//This file is just for tesing (From this will be bin/mathmlin)


#include <iostream>

#include "ContMathMLInLexer.hpp"
#include "ContMathMLInParser.hpp"
#include "ContMathMLToIntuitiveTransform.hpp"
#include "COutput.hpp"
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
		ContMathMLInLexer lexer(cin);
		//Set the language - This is important!!!
//		lexer.setLanguage(hu);
		//Set the lexer for the parser
		ContMathMLInParser parser(lexer);

		//Parser initialization
		parser.initializeASTFactory(my_factory);
		parser.setASTFactory(&my_factory);

		//Setting some useful defaults, it is not important, but recommended
		//See IntuitiveParser.g for further information
//		parser.init();
		//Start the parsing
		parser.inp();
		//Get the AST for further transformations
		RefFcAST ast = RefFcAST(RefFcAST(parser.getAST()));
//		puts("parsing end");

		//Transformator to the Intuitive-compatible format
		ContMathMLToIntuitiveTransform tr;
		
		//Init the transformator
		tr.setASTFactory(&my_factory);
		
		//Transformate it
		tr.inp(ast);
//		puts("transformation end");
		
		//To create the C output
		COutput c;

		//Init it
		c.setASTFactory(&my_factory);
		c.init();

		if (ast)
		{
			//Print out the AST
			cout << ast->toStringList() << endl; //Just for debug
			//Print out the root's roughType
//			FcAST::printType(ast->roughType); //Just for debug
			//Print out the transformed tree
//			cout << (tr.getAST())->toStringList() << endl; //just for debug

			//Get the output string
			string *str = c.inp(RefFcAST(tr.getAST()));
			
			string *init = c.getDeclarations();

			//Defining the possibly necessery functions, just an example...
//			cout << "#include <math.h>\n#define FC_REAL_TYPE double\n#define FC_INTEGER_TYPE long int\n#define FC_RATIONAL_TYPE my_rational\n#define FC_VAR_TYPE double\n#define FC_COMPLEX_TYPE my_complex\n";
			
			cout << *init;

			//Print out the necessary/used functions
			string *s=c.getFunctions();
			cout << *s << endl;

			//Print out the C expression
			cout << *str << endl;
			
			//Free the return variables
			delete s;
			delete str;
			delete init;
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

