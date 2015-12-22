/*
 * General formula converter.
 * Command line option parser.
 * A demonstration what the library can do.
 * $Id: formconv.cpp,v 1.36 2010/08/28 13:20:24 kovzol Exp $
 */

#include <iostream>
#include <fstream>
#include <tclap/CmdLine.h>
#include <map>

#include <h/misc.h>
#include <h/fcAST.h>
#include <h/fcversion.h>

#include <COutput.hpp>
#include <CComplexOutput.hpp>
#include <ComplexCompute.hpp>
#include <ContMathMLInLexer.hpp>
#include <ContMathMLInParser.hpp>
#include <ContMathMLToIntuitiveTransform.hpp>
#include <ContentTransform.hpp>
#include <ContentTransform2.hpp>
#include <ConstantTransform.hpp>
#include <IntuitiveLexer.hpp>
#include <IntuitiveParser.hpp>
#include <JavaOutput.hpp>
#include <LaTeXOutput.hpp>
#include <LispLexer.hpp>
#include <LispParser.hpp>
#include <LispOutput.hpp>
#include <MathMLOutput.hpp>
#include <MathematicaOutput.hpp>
#include <MaximaOutput.hpp>
#include <MapleOutput.hpp>
#include <GnuplotOutput.hpp>
#include <MupadOutput.hpp>
#include <HTMLOutput.hpp>
#include <PresentationTransform.hpp>
#include <Transform.hpp>

#ifdef TCLAP_CONSTRAINT_H
#define ARGS(BOOL, CMD) CMD, BOOL
#else
#define ARGS(BOOL, CMD) BOOL, CMD
#endif

using namespace TCLAP;
using namespace std;
using namespace antlr;

int main (int argc, char **argv)
{
	string inputFileName, outputFileName, inputFormat, outputFormat, prefix,
		suffix, header, footer, inputContent, tmp;
	ThreeState times;
	bool dynamicParentheses, beautyParentheses, autoSimplify, cPrecedence, typeCheck, disallowComputingFunctions, noLongVars, forceFloatDivision;
	vector<string> functionNames, changes, variable, allowedLetters;
	Language inputLanguage, outputLanguage;

	try {
		//Define command line object
		CmdLine cmd("Formula Converter (formconv)\nCopyright (C) 2003-2010 Zoltan Kovacs <kovzol@math.u-szeged.hu>\n"
		    "Copyright (C) 2003-2010 Gabor Bakos <baga@users.sourceforge.net>\n"
		    "This is free software with ABSOLUTELY NO WARRANTY.", ' ', FCVERSION_STRING);
		ValueArg<string> inputFileNameArg("i", "inputfile", "Specifies the input filename. (Default: standard input)", false,
#ifdef WIN32
		"con"
#else
		"/dev/stdin"
#endif
		, "string", cmd);
		ValueArg<string> outputFileNameArg("o", "outputfile", "Specifies the output filename. (Default: standard output)", false,
#ifdef WIN32
		"con"
#else
		"/dev/stdout"
#endif
		, "string", cmd);
		vector<string> allowedInputFormat;
		allowedInputFormat.push_back("intuitive");
		allowedInputFormat.push_back("contentMathML");
		allowedInputFormat.push_back("lisp");
#ifdef TCLAP_CONSTRAINT_H
		ValuesConstraint<string> constraintInputFormat(allowedInputFormat);
		ValueArg<string> inputFormatArg("I", "inputformat", "Specifies the format of the input.", false, "intuitive", &constraintInputFormat, cmd);
#else
		ValueArg<string> inputFormatArg("I", "inputformat", "Specifies the format of the input.", false, "intuitive", allowedInputFormat, cmd);
#endif
		vector<string> allowedOutputFormat;
		allowedOutputFormat.push_back("c");
		allowedOutputFormat.push_back("ccomplex");
		allowedOutputFormat.push_back("complexcompute");
		allowedOutputFormat.push_back("java");
		allowedOutputFormat.push_back("latex");
		allowedOutputFormat.push_back("mathematica");
		allowedOutputFormat.push_back("mathml");
		allowedOutputFormat.push_back("lisp");
		allowedOutputFormat.push_back("maxima");
		allowedOutputFormat.push_back("maple");
		allowedOutputFormat.push_back("gnuplot");
		allowedOutputFormat.push_back("mupad");
		allowedOutputFormat.push_back("html");
		allowedOutputFormat.push_back("debug");
		allowedOutputFormat.push_back("debugContent");
#ifdef TCLAP_CONSTRAINT_H
		ValuesConstraint<string> constraintOutputFormat(allowedOutputFormat);
		ValueArg<string> outputFormatArg("O", "ouputformat", "Specifies the format of the output.", false, "latex", &constraintOutputFormat, cmd);
#else
		ValueArg<string> outputFormatArg("O", "ouputformat", "Specifies the format of the output.", false, "latex", allowedOutputFormat, cmd);
#endif
		SwitchArg dynamicParenthesesArg("d", "dynamicparentheses", "Uses in LaTeX output \\left(, and \\right), ...", ARGS(true, cmd));
		vector<string> threeStateType;
		threeStateType.push_back("space");
		threeStateType.push_back("automatic");
		threeStateType.push_back("cdot");
#ifdef TCLAP_CONSTRAINT_H
		ValuesConstraint<string> constraintThreeStateType(threeStateType);
		ValueArg<string> timesArg("t", "times", "Prints space in presentation outputs instead of *, or \\cdot, depending on the value.", false, "automatic", &constraintThreeStateType, cmd);
#else
		ValueArg<string> timesArg("t", "times", "Prints space in presentation outputs instead of *, or \\cdot, depending on the value.", false, "automatic", threeStateType, cmd);
#endif
		SwitchArg beautyParenthesesArg("b", "beautyparentheses", "Uses in presentation outputs (, ), [, ], {, } instead of just (, ).", ARGS(false, cmd));
		SwitchArg autoSimplifyArg("a", "autosimplify", "Does not remove the unnecessary parentheses from the formulae.", ARGS(true, cmd));
//		SwitchArg pascalPrecedenceArg("P", "Pascalprecedence", "Uses Pascal precedence in input (else C precedence).", true, cmd);
//		SwitchArg typeCheckArg("t", "type-check", "Checks, whether the arguments can be used to the given operator.", false, cmd);
		SwitchArg disallowComputingFunctionsArg("D", "disallowcomputingfunctions", "Forbids the use of functions like sum, prod, int, diff...", ARGS(false, cmd));
		SwitchArg noLongVarsArg("n", "nolongvars", "Forbids the use of variable/parameter names longer than 1 character.", ARGS(false, cmd));
		MultiArg<string> functionNamesArg("f", "functionnames", "Use these names as user defined function names. (In input you are/will able to define functions with other names.)", false, "string", cmd);
//		ValueArg<string> inputContentArg("C", "inputcontent", "Specifies a restriction on the format of intuitive input.", false, "set-expression", allowedContentType, cmd);
		MultiArg<string> allowedLettersArg("A", "allowedletters", "Just these letters of accepted as variables or parameters in the input.", false, "string", cmd);
		ValueArg<string> headerArg("H", "header", "Prints this text before the output.", false, "", "string", cmd);
		ValueArg<string> footerArg("F", "footer", "Prints this text after the output.", false, "", "string", cmd);
		ValueArg<string> prefixArg("p", "prefix", "Prints this text before each formula.", false, "", "string", cmd);
		ValueArg<string> suffixArg("s", "suffix", "Prints this text after each formula.", false, "", "string", cmd);
		SwitchArg forceFloatDivArg("r", "forceFloatDiv", "Always selects the floating point division for the output of applicable.", ARGS(false, cmd));

		vector<string> languageType;
		languageType.push_back("hungarian");
		languageType.push_back("english");
		languageType.push_back("german");
		languageType.push_back("french");
		languageType.push_back("simple");
#ifdef TCLAP_CONSTRAINT_H
		ValuesConstraint<string> constraintLanguageType(languageType);
		ValueArg<string> inputLanguageArg("l", "inputlanguage", "Uses this language's specialties in the input.", false, "english", &constraintLanguageType, cmd);
		ValueArg<string> outputLanguageArg("L", "outputlanguage", "Uses this language's specialties in the output.", false, "english", &constraintLanguageType, cmd);
#else
		ValueArg<string> inputLanguageArg("l", "inputlanguage", "Uses this language's specialties in the input.", false, "english", languageType, cmd);
		ValueArg<string> outputLanguageArg("L", "outputlanguage", "Uses this language's specialties in the output.", false, "english", languageType, cmd);
#endif
		MultiArg<string> changesArg("x", "changename", "Changes the names of the variables/parameters to the given. (Ex.: -x x,x4 will change all x variable to x4) (Please use just one comma per rule.)", false, "string", cmd);
		MultiArg<string> variableArg("V", "variable", "Sets a variable in a computing output. (Ex.: -V x=4) (Please do not use spaces in the expression.)", false, "string", cmd);

		cmd.parse(argc, argv);
		inputFileName = inputFileNameArg.getValue();
		outputFileName = outputFileNameArg.getValue();
		inputLanguage = formconvLanguage::getLanguage(inputLanguageArg.getValue());
		outputLanguage = formconvLanguage::getLanguage(outputLanguageArg.getValue());
		inputFormat = inputFormatArg.getValue();
		outputFormat = outputFormatArg.getValue();
		dynamicParentheses = dynamicParenthesesArg.getValue();
		tmp = timesArg.getValue();
		if (tmp == "space")
			times = no;
		else if (tmp == "automatic")
			times = automatic;
		else if (tmp == "cdots")
			times = yes;
		else
			throw std::exception(); //This should not happen
		beautyParentheses = beautyParenthesesArg.getValue();
		autoSimplify = autoSimplifyArg.getValue();
//		cPrecedence = !(pascalPrecedenceArg.getValue());
//		typeCheck = typeCheckArg.getValue();
		disallowComputingFunctions = disallowComputingFunctionsArg.getValue();
		noLongVars = noLongVarsArg.getValue();
		forceFloatDivision = forceFloatDivArg.getValue();
		functionNames = functionNamesArg.getValue();
//		inputContent = inputContentArg.getValue();
		allowedLetters = allowedLettersArg.getValue();
		header = headerArg.getValue();
		footer = footerArg.getValue();
		prefix = prefixArg.getValue();
		suffix = suffixArg.getValue();
		changes = changesArg.getValue();
		variable = variableArg.getValue();
	} catch (ArgException &e)
	{
		cerr << "Error: " << e.error() << " in argument: " << e.argId() << endl;
	}
	try {
		//Setting the proper input and output streams
		ifstream inputStream(inputFileName.c_str());
		ofstream outputStream(outputFileName.c_str());
		//Creating the AST factory
		ASTFactory myFactory("FcAST", FcAST::factory);
		RefFcAST ast;
		if (inputFormat == "intuitive")
		{
			//Create the lexer
			IntuitiveLexer lexer(inputStream);
			lexer.setLanguage(inputLanguage);
			lexer.setLongVars(!noLongVars);
			
			//Setting the acceptable variable to the lexer
			for (vector<string>::iterator it = allowedLetters.begin(); it != allowedLetters.end(); ++it)
			{
				lexer.addAllowedLetter(*it);
			}
			//Create the parser
			IntuitiveParser parser(lexer);
			parser.initializeASTFactory(myFactory);
			parser.setASTFactory(&myFactory);
			//Setting the parameters for the parser
			for (vector<string>::iterator it = functionNames.begin(); it != functionNames.end(); ++it)
			{
				parser.addFunctionName(*it);
			}
			//Sets wheter you want to use sum, prod, int, diff, ...
			parser.setAllowComputingFunctions(!disallowComputingFunctions);
			//Start parsing
			parser.expr();
			//Get AST for further processing
			ast = RefFcAST(parser.getAST());
			if (outputFormat == "debug" || outputFormat == "debugContent")
			{
				if (ast)
					outputStream << "\nIntuitive input, before transformations.\n" << ast->toStringList();
				else
					outputStream << "null AST\n";
				outputStream.flush();
			}
		}
		else if (inputFormat == "contentMathML")
		{
			//Create the lexer
			ContMathMLInLexer lexer(inputStream);
			//Create the parser
			ContMathMLInParser parser(lexer);
			parser.initializeASTFactory(myFactory);
			parser.setASTFactory(&myFactory);
			//Start parsing
			parser.inp();
			//Get AST for further processing
			ast = RefFcAST(parser.getAST());
			if (outputFormat == "debug" || outputFormat == "debugContent")
			{
				if (ast)
					outputStream << "\nMathML input, before transformations.\n" << ast->toStringList();
				else
					outputStream << "null AST\n";
				outputStream.flush();
			}
			//Convert it to Intuitive AST format to able to process with other transforms, outputs.
			ContMathMLToIntuitiveTransform m2i;
			m2i.setASTFactory(&myFactory);
			m2i.inp(ast);
			ast = RefFcAST(m2i.getAST());
			if (outputFormat == "debug" || outputFormat == "debugContent")
			{
				if (ast)
					outputStream << "\nMathML input, before transformations.\n" << ast->toStringList();
				else
					outputStream << "null AST\n";
				outputStream.flush();
			}
		}
		else if (inputFormat == "lisp")
		{
			//Create the lexer
			LispLexer lexer(inputStream);
			lexer.init();
			//Create the parser
			LispParser parser(lexer);
			parser.initializeASTFactory(myFactory);
			parser.setASTFactory(&myFactory);
			//Start parsing
			parser.inp();
			//Get AST for further processing
			ast = RefFcAST(parser.getAST());
			//Convert it to Intuitive AST format to able to process with other transforms, outputs.
//			ContMathMLToIntuitiveTransform m2i;
//			m2i.setASTFactory(&myFactory);
//			m2i.inp(ast);
//			ast = RefFcAST(m2i.getAST());
			if (outputFormat == "debug" || outputFormat == "debugContent")
			{
				if (ast)
					outputStream << "\nMathML input, before transformations.\n" << ast->toStringList();
				else
					outputStream << "null AST\n";
				outputStream.flush();
			}
		}
		else
		{
			throw std::exception(); //This should not happen
		}
		//We have the result in AST, let's transform it to the proper form
		if (outputFormat == "latex" || outputFormat == "html" || outputFormat == "debug")
		{
			//Create the presentation transformator
			PresentationTransform pt;
			//Set the properties
			pt.setSimplify(autoSimplify);
			pt.setSimplifyPower(true);
			pt.setInvisibleTimes(times);
			pt.setTokenPrecedence(PresentationTransform::presentationTokenPrecedence);
			if (outputFormat == "latex")
			{
				pt.setDivAsFrac(yes);
			}
			else if (outputFormat == "html")
			{
				pt.setDivAsFrac(automatic);
			}
			else
			{
				pt.setDivAsFrac(automatic);
			}
			pt.initializeASTFactory(myFactory);
			pt.setASTFactory(&myFactory);
			//Do the transformation
			pt.inp(ast);
			ast = RefFcAST(pt.getAST());
			if (outputFormat == "debug")
			{
				if (ast)
					outputStream << "\nAfter presentation transformation.\n" << ast->toStringList() << "\n";
				else
					outputStream << "null AST\n";
				outputStream.flush();
			}
		} else //Not presentation transform
		{
			//Create the first transformation
			ContentTransform ct;
			ct.initializeASTFactory(myFactory);
			ct.setASTFactory(&myFactory);
			//Apply the transformation
			ct.inp(ast);
			//Get the result
			ast = RefFcAST(ct.getAST());
			if (outputFormat == "debugContent")
			{
				if (ast)
					outputStream << "\nAfter first content transformation.\n" << ast->toStringList();
				else
					outputStream << "null AST\n";
				outputStream.flush();
			}
			//Create the second transformation
			ContentTransform2 ct2;
			ct2.setASTFactory(&myFactory);
			//Apply the transformation
			ct2.inp(ast);
			//Get the result
			ast = RefFcAST(ct2.getAST());
			if (outputFormat == "debugContent")
			{
				if (ast)
					outputStream << "\nAfter second content transformation.\n" << ast->toStringList() << "\n";
				else
					outputStream << "null AST\n";
				outputStream.flush();
			}
		}
		if (!changes.empty())
		{
			//Create the transformator for (currently just) for changes
			Transform t;
			t.initializeASTFactory(myFactory);
			t.setASTFactory(&myFactory);
			for (vector<string>::iterator it = changes.begin(); it != changes.end(); ++it)
			{
				string::size_type pos = (*it).find(',');
				t.addChange((*it).substr(0, pos), (*it).substr(pos+1));
			}
			t.inp(ast);
			ast = RefFcAST(t.getAST());
			if (outputFormat == "debug" || outputFormat == "debugContent")
			{
				if (ast)
					outputStream << "\nAfter variable name changing transformation.\n" << ast->toStringList() << "\n";
				else
					outputStream << "null AST\n";
				outputStream.flush();
			}
		}
		//ast now contains the proper AST
		//Now creating the output
		outputStream << header;
		if (outputFormat == "latex")
		{
			//Create the proper object
			LaTeXOutput latex;
			latex.initializeASTFactory(myFactory);
			latex.setASTFactory(&myFactory);
			//Set the properties
			latex.setLanguage(outputLanguage);
			latex.setDynamicParentheses(dynamicParentheses);
			latex.setBeautyParentheses(beautyParentheses);
			//Get the result
			string s = latex.inp(ast);
			//TODO change it to the outputs
			outputStream << prefix;
			outputStream << s;
			//TODO change it to the outputs
			outputStream << suffix << endl;
		}
		else if (outputFormat == "html")
		{
			//Create the proper object
			HTMLOutput html;
			html.initializeASTFactory(myFactory);
			html.setASTFactory(&myFactory);
			//Set the properties
			html.setLanguage(outputLanguage);
			html.setDynamicParentheses(dynamicParentheses);
			html.setBeautyParentheses(beautyParentheses);
			//Get the result
			string s = html.inp(ast);
			//TODO change it to the outputs
			outputStream << prefix;
			outputStream << s;
			//TODO change it to the outputs
			outputStream << suffix << endl;
			outputStream.flush();
		}
		else if (outputFormat == "c")
		{
			//Create the proper object
			COutput c;
			c.initializeASTFactory(myFactory);
			c.setASTFactory(&myFactory);
			c.setForceFloatDivision(forceFloatDivision);
			c.init();
			//Get the result
			string *s = c.inp(ast);
			string *decl = c.getDeclarations();
			string *func = c.getFunctions();

			outputStream << *decl << *func;
			//TODO change it to the outputs
			outputStream << prefix;
			outputStream << *s;
			//TODO change it to the outputs
			outputStream << suffix << endl;
			
			//delete the unnecessary variables...
			delete s;
			delete decl;
			delete func;
		}
		else if (outputFormat == "ccomplex")
		{
			//Create the proper object
			CComplexOutput c;
			c.initializeASTFactory(myFactory);
			c.setASTFactory(&myFactory);
			c.setForceFloatDivision(forceFloatDivision);
			c.init();
			//Get the result
			string *s = c.inp(ast);
			string *decl = c.getDeclarations();
			string *func = c.getFunctions();

			outputStream << *decl << *func;
			//TODO change it to the outputs
			outputStream << prefix;
			outputStream << *s;
			//TODO change it to the outputs
			outputStream << suffix << endl;
			
			//delete the unnecessary variables...
			delete s;
			delete decl;
			delete func;
		}
		else if (outputFormat == "java")
		{
			//Create the proper object
			JavaOutput java;
			java.initializeASTFactory(myFactory);
			java.setASTFactory(&myFactory);
			//Get the result
			string s = java.inp(ast);
			//TODO change it to the outputs
			outputStream << prefix;
			outputStream << s;
			//TODO change it to the outputs
			outputStream << suffix << endl;
			outputStream.flush();
		}
		else if (outputFormat == "mathematica")
		{
			//Create the proper object
			MathematicaOutput mathematica;
			mathematica.initializeASTFactory(myFactory);
			mathematica.setASTFactory(&myFactory);
			//Get the result
			string s = mathematica.inp(ast);
			//TODO change it to the outputs
			outputStream << prefix;
			outputStream << s;
			//TODO change it to the outputs
			outputStream << suffix << endl;
			outputStream.flush();
		}
		else if (outputFormat == "mathml")
		{
			//Create the proper object
			MathMLOutput mathml;
			mathml.initializeASTFactory(myFactory);
			mathml.setASTFactory(&myFactory);
			mathml.init();
			//Get the result
			string s = mathml.inp(ast);
			//TODO change it to the outputs
			outputStream << prefix;
			outputStream << s;
			//TODO change it to the outputs
			outputStream << suffix << endl;
			outputStream.flush();
		}
		else if (outputFormat == "lisp")
		{
			//Create the proper object
			LispOutput lisp;
			lisp.initializeASTFactory(myFactory);
			lisp.setASTFactory(&myFactory);
			//Get the result
			string s = lisp.inp(ast);
			//TODO change it to the outputs
			outputStream << prefix;
			outputStream << s;
			//TODO change it to the outputs
			outputStream << suffix << endl;
			outputStream.flush();
		}
		else if (outputFormat == "complexcompute")
		{
			//Create the proper object
			ComplexCompute cc;
			cc.initializeASTFactory(myFactory);
			cc.setASTFactory(&myFactory);
			//Set the given variables
			for (vector<string>::iterator it = variable.begin(); it != variable.end(); ++it)
			{
				std::istringstream varinput((*it).substr((*it).find('=')+1));
				IntuitiveLexer varLexer(varinput);
				varLexer.setLanguage(inputLanguage);
				IntuitiveParser varParser(varLexer);
				varParser.initializeASTFactory(myFactory);
				varParser.setASTFactory(&myFactory);
				varParser.expr();
				complex<double> value = cc.inp(RefFcAST(varParser.getAST()));
				cc.setValue((*it).substr(0, (*it).find('=')), value);
			}
			//Get the result
			complex<double> z = cc.inp(ast);
			//TODO change it to the outputs
			outputStream << prefix;
			outputStream << z.real();
			if (abs(z.imag())>1E-40)
				outputStream << "+" << z.imag() << "i";
			//TODO change it to the outputs
			outputStream << suffix << endl;
			outputStream.flush();
		}
		else if (outputFormat == "maxima")
		{
			//Create the proper object
			MaximaOutput maxima;
			maxima.initializeASTFactory(myFactory);
			maxima.setASTFactory(&myFactory);
			//Get the result
			string s = maxima.inp(ast);
			//TODO change it to the outputs
			outputStream << prefix;
			outputStream << s;
			//TODO change it to the outputs
			outputStream << suffix << endl;
			outputStream.flush();
		}
		else if (outputFormat == "maple")
		{
			//Create the proper object
			MapleOutput maple;
			maple.initializeASTFactory(myFactory);
			maple.setASTFactory(&myFactory);
			//Get the result
			string s = maple.inp(ast);
			//TODO change it to the outputs
			outputStream << prefix;
			outputStream << s;
			//TODO change it to the outputs
			outputStream << suffix << endl;
			outputStream.flush();
		}
		else if (outputFormat == "gnuplot")
		{
			//Create the constant transformation
			ConstantTransform constTransform;
			constTransform.setASTFactory(&myFactory);
			constTransform.setConvertDecimal(true);
			constTransform.setConvertExponents(true);
			//Apply the transformation
			constTransform.inp(ast);
			//Get the result
			ast = RefFcAST(constTransform.getAST());
			if (outputFormat == "debugContent")
			{
				if (ast)
					outputStream << "\nAfter second constant transformation.\n" << ast->toStringList() << "\n";
				else
					outputStream << "null AST\n";
				outputStream.flush();
			}
			//Create the proper object
			GnuplotOutput gnuplot;
			gnuplot.initializeASTFactory(myFactory);
			gnuplot.setASTFactory(&myFactory);
			gnuplot.setForceFloatDivision(forceFloatDivision);
			//Get the result
			string s = gnuplot.inp(ast);
			//TODO change it to the outputs
			outputStream << prefix;
			outputStream << s;
			//TODO change it to the outputs
			outputStream << suffix << endl;
			outputStream.flush();
		}
		else if (outputFormat == "mupad")
		{
			//Create the proper object
			MupadOutput mupad;
			mupad.initializeASTFactory(myFactory);
			mupad.setWriteParen(false);
			mupad.setASTFactory(&myFactory);
//			outputStream << "\nAfter variable name changing transformation.\n" << ast->toStringList();
			if (autoSimplify)
			{
		        	//Create the presentation transformator
				PresentationTransform pt;
				//Set the properties
				pt.setSimplify(yes);
				pt.setSimplifyPower(false);
				pt.setInvisibleTimes(no);
				pt.setDivAsFrac(no);
				pt.setTokenPrecedence(MupadOutput::mupadTokenPrecedence);
				pt.initializeASTFactory(myFactory);
				pt.setASTFactory(&myFactory);
				//Do the transformation
				pt.inp(ast);
				ast = RefFcAST(pt.getAST());
//				outputStream << "\nAfter variable name changing transformation.\n" << ast->toStringList();
			}
			//Get the result
			string s = mupad.inp(ast);
			//TODO change it to the outputs
			outputStream << prefix;
			outputStream << s;
			//TODO change it to the outputs
			outputStream << suffix << endl;
			outputStream.flush();
		}
		outputStream << footer;
	} catch (ANTLRException& e)
	{
		cerr << "Exception: " << e.toString() << endl;
		return -1;
	} catch (exception& e)
	{
		cerr << "Exception: " << e.what() << endl;
		return -1;
	}
}
