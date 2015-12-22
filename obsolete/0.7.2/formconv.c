/*
 * General formula converter.
 * Command line option parser.
 * $Id: formconv.c,v 1.3 2006/07/26 06:03:32 kovzol Exp $
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdlib.h>
#include <getopt.h>

#include "config.h"
#include "src/tokens.h"
#include "src/PP.h"
#include "STreeParser.h"
#include "src/TreeParser_Maple_out.h"
#include "src/TreeParser_LaTeX_out.h"
#include "src/TreeParser_yacas_out.h"
#include "src/TreeParser_Beautify.h"
#include "src/TreeParser_Expand.h"
#include "src/TreeParser_Maxima_out.h"
#include "src/TreeParser_MathML_out.h"
#include "src/TreeParser_gnuplot_out.h"
#include "src/TreeParser_ccomplex_out.h"
#include "src/TreeParser_c_out.h"
#include "src/TreeParser_MuPAD_out.h"
#include "src/TreeParser_Java_out.h"
#include "src/TreeParser_verb_hu_out.h"
#include "src/TreeParser_html_out.h"
typedef ANTLRCommonToken ANTLRToken;
#include "src/DLGLexer.h"
#include "PBlackBox.h"
#include "pccts/AST.h"

#define PACKAGE "Formula Converter (formconv)"
#define COPYRIGHT \
 "Copyright (C) 2003-2006 Zoltan Kovacs <kovzol@math.u-szeged.hu>\n" \
 "Copyright (C) 2003-2006 Gabor Bakos <Bakos.Gabor.1@stud.u-szeged.hu>\n" \
 "This is free software with ABSOLUTELY NO WARRANTY."

#define FORMAT_LENGTH 12
#define FORMATS 18

#define F_C 0
#define F_LATEX 1
#define F_MAPLE 2
#define F_MUPAD 3
#define F_MAXIMA 4
#define F_MATHEMATICA 5
#define F_LISP 6
#define F_INTUITIVE 7
#define F_HTML_VALIGN 8
#define F_VERB_EN 9
#define F_VERB_HU 10
#define F_YACAS 11
#define F_MATHML 12
#define F_GNUPLOT 13
#define F_PARSE 14
#define F_JAVA 15
#define F_HTML 16
#define F_CCOMPLEX 17

const char format[FORMATS][FORMAT_LENGTH] =
  { "c", "latex", "maple", "mupad", "maxima",
  "mathematica", "lisp", "intuitive", "html_valign",
  "verb_en", "verb_hu","yacas","mathml","gnuplot",
	"parse", "java", "html", "ccomplex"
};

const char langs[][FORMAT_LENGTH] =
	{ "default", "hungarian", "english", "french", "german", "spanish", "italian", "chinese"
	};

const char langnum=sizeof(langs)/FORMAT_LENGTH;

int
number_of (const char format[][FORMAT_LENGTH], const int max,const  char *format_text)
{
  int i, found = -1;
  for (i = 0; i < max && (found == -1); ++i)
    if (strcmp (format[i], format_text) == 0)
      found = i;
  return found;
}

int
main (int argc, char **argv)
{
  int c, i;
  char *ifname = "/dev/stdin", *ofname = "/dev/stdout", *prefix =
    "", *suffix = "", *header = "", *footer = "", *allowed_letters =
    "abceinptxyz";
  int input_format = F_INTUITIVE, output_format = F_LATEX, input_lang, output_lang;
  int dynamic_parentheses = 1, cdots = 1, beauty_parentheses = 0, autosimplify = 1, last = 0, first = 0, sets = 0, boolean = 0, equation = 0, C_precedence = 0, type_check = 0, functions = 0;
  language ilang=DEFAULT, olang=DEFAULT;
  int err_code=0;

  char *str_olang=getenv("FC_OUTPUT_LANG");
  if (str_olang)
  {
	  int onum=number_of(langs, langnum, str_olang);
	  if (onum>=0) olang=(language) onum;
  }
  
  while (1)
    {
      int option_index = 0;
      static struct option long_options[] = {
        {"input-file", 1, 0, 'i'},
        {"output-file", 1, 0, 'o'},
        {"input-format", 1, 0, 'I'},
        {"output-format", 1, 0, 'O'},
        {"help", 0, 0, 'h'},
        {"version", 0, 0, 'v'},
        {"no-dynamic-parentheses", 0, 0, 'd'},
        {"no-cdots", 0, 0, 'c'},
        {"beauty-parentheses", 0, 0, 'b'},
        {"no-auto-simplify", 0, 0, 'a'},
        {"C-precedence", 0, 0, 'P'},
	{"type-check", 0, 0, 't'},
	{"allow-functions", 0, 0, 'f'},
        {"input-content", 1, 0, 'C'},
	{"allowed-letters", 1, 0, 'A'},
	{"header", 1, 0, 'H'},
	{"footer", 1, 0, 'F'},
	{"prefix", 1, 0, 'p'},
	{"suffix", 1, 0, 's'},
	{"input-lang", 1, 0, 'l'},
	{"output-lang", 1, 0, 'L'},
	{0, 0, 0, 0}
      };

      c = getopt_long (argc, argv, "i:o:I:O:hvdcbaPtC:A:fH:F:p:s:l:L:", long_options,
		       &option_index);
      if (c == -1)
	break;

      switch (c)
	{
	case 0:
	  printf ("option %s", long_options[option_index].name);
	  if (optarg)
	    printf (" with arg %s", optarg);
	  printf ("\n");
	  break;

	case 'I':
	  input_format = number_of (format, FORMATS, optarg);
	  if (input_format == -1)
	    {
	      fprintf (stderr, "Unhandled input format: %s\n", optarg);
	      exit (1);
	    }
	  break;

	case 'O':
	  output_format = number_of (format, FORMATS, optarg);
	  if (output_format == -1)
	    {
	      fprintf (stderr, "Unhandled output format: %s\n", optarg);
	      exit (1);
	    }
	  break;

	case 'o':
	  ofname = optarg;
	  break;

	case 'i':
	  ifname = optarg;
	  break;

	case 'v':
	  printf ("%s %s\n%s\n", PACKAGE, VERSION, COPYRIGHT);
	  exit (0);
	  break;

	case 'd':
	  dynamic_parentheses = 0;
	  break;

	case 'c':
	  cdots = 0;
	  break;

	case 'h':
	  printf
	    ("%s converts mathematical formulae\nfrom one format to another. "
	     "Default source is standard input and \ndestination is standard output. "
	     "If the input formula is incorrect,\nthe program exits with error code 1.\n"
	     "Default conversion is \"intuitive\" to \"latex\".\n\n",
	     PACKAGE);
	  printf ("Usage: formconv [[-I | --input-format] input_format]\n"
		  "\t\t[[-O | --output-format] output_format]\n"
		  "\t\t[[-i | --input-file] input_file]\n"
		  "\t\t[[-o | --output-file] output_file]\n"
		  "\t\t[[-H | --header] string_to_write_to_the_beginning]\n"
		  "\t\t[[-F | --footer] string_to_write_to_the_end]\n"
		  "\t\t[[-p | --prefix] string_to_write_before_every_formula]\n"
		  "\t\t[[-s | --suffix] string_to_write_after_every_formula]\n"
		  "\t\t[[-C | --input-content] expression | boolean-expression | equation]\n"
		  "\t\t[[-A | --allowed-letters string_with_valid_letters]\n"
		  "\t\t[-d | --no-dynamic-parentheses]\n"
		  "\t\t[-c | --no-cdots]\n"
		  "\t\t[-b | --beauty-parentheses]\n"
		  "\t\t[-a | --no-auto-simplify]\n"
		  "\t\t[-P | --C-precedence]\n"
		  "\t\t[-t | --type-check]\n"
		  "\t\t[-f | --allow-functions]\n"
		  "\t\t[[-l | --input-lang] language_name]\n"
		  "\t\t[[-L | --output-lang] language_name]\n");
	  printf ("\n");
	  printf ("Available formats:");
	  for (i = 0; i < FORMATS; ++i)
	    printf (" %s", format[i]);
	  printf ("\n\n%s\n", COPYRIGHT);
	  exit (0);
	  break;

	case 'b':
	  beauty_parentheses = 1;
	  break;

	case 'a':
	  autosimplify = 0;
	  break;

	case 'P':
	  C_precedence = 1;
	  break;

	case 't':
	  type_check = 1;
	  break;

	case 'H':
	  header = optarg;
	  break;

	case 'F':
	  footer = optarg;
	  break;

	case 'p':
	  prefix = optarg;
	  break;

	case 's':
	  suffix = optarg;
	  break;

	case 'C':
	  if (strcmp(optarg, "set-expression") == 0)
	    sets = 1;
	  else if (strcmp (optarg, "boolean-expression") == 0)
	    boolean = 1;
	  else if (strcmp (optarg, "equation") == 0)
	    equation = 1;
	  else if (strcmp (optarg, "expression") == 0);
	  else
	    {
	      printf
		("The supported input-content types are: set-expression, boolean-expression, equation, expression\n");
	      exit (1);
	    }
	  break;

	case 'A':
	  allowed_letters = optarg;
	  break;

	case 'f':
	  functions = 1;
	  break;

	case 'l':
	  input_lang = number_of (langs, langnum, optarg);
	  if (input_lang == -1)
	    {
	      fprintf (stderr, "Unhandled input language: %s\n", optarg);
	      exit (1);
	    }
	  else
	  {
		  ilang=(language)input_lang;
	  }
	  break;

	case 'L':
	  output_lang = number_of (langs, langnum, optarg);
	  if (output_lang == -1)
	    {
	      fprintf (stderr, "Unhandled output language: %s\n", optarg);
	      exit (1);
	    }
	  else
	  {
		  olang=(language)output_lang;
	  }
	  break;

	default:
	  printf ("Type `formconv --help' for help\n");
	  exit (1);
	}
    }

  if (optind < argc)
    {
      printf ("Type `formconv --help' for help\n");
      exit (1);
    }

  if (!
      ((input_format == F_INTUITIVE)
       && ((output_format == F_LATEX) || (output_format == F_MAPLE)
	   || (output_format == F_YACAS) || (output_format == F_MAXIMA)
	   || (output_format == F_MATHML) || (output_format == F_GNUPLOT)
	   || (output_format == F_MUPAD) || (output_format == F_HTML_VALIGN)
	   || (output_format == F_PARSE) || (output_format == F_JAVA)
	   || (output_format == F_VERB_HU) || (output_format == F_HTML)
	   || (output_format == F_CCOMPLEX) || (output_format == F_C))))
    {
      printf ("Conversion from %s to %s is not supported yet\n",
	      format[input_format], format[output_format]);
      exit (1);
    }

  ParserBlackBox < DLGLexer, PP, ANTLRToken > p (ifname /*stdin */ );
  AST *root = NULL, *result;

  p.parser ()->set_C_precedence (C_precedence == 1);
  p.parser ()->set_booleans (boolean == 1);
  p.parser ()->set_sets (sets == 1);
  p.parser ()->set_type_check (type_check == 1);
  p.parser ()->set_functions (functions == 1);
  p.parser ()->set_allowed_letters (allowed_letters);

#if DEBUG
  if (sets)
    p.parser ()->inplog ((ASTBase **) & root);
  else if (boolean)
    p.parser ()->inplog ((ASTBase **) & root);
  else if (equation)
    p.parser ()->inp_eqn ((ASTBase **) & root);
  else
    p.parser ()->inp ((ASTBase **) & root);
#else
  if (sets)
    p.parser ()->inplog ((ASTBase **) & root, &err_code);
  else if (boolean)
    p.parser ()->inplog ((ASTBase **) & root, & err_code);
  else if (equation)
    p.parser ()->inp_eqn ((ASTBase **) & root, & err_code);
  else
    p.parser ()->inp ((ASTBase **) & root, & err_code);
//  printf("%d\n",err_code); // for debug
#endif
  if (err_code && (output_format != F_PARSE))
    {
      root->destroy ();
      exit (-1);
    }
  switch (output_format)
    {
    case F_MAPLE:
      {
	    TreeParser_Expand e(ofname, false/*simplify*/, false /*log_equal*/);
		e.inp((SORASTBase **)&root, (SORASTBase **)&result);
		root->destroy();
//	    puts(""); result->preorder(); puts(""); fflush(stdout); //for debug
	    try {
	      TreeParser_Maple_out maple(ofname, prefix, suffix, header, footer);
	      maple.inp((SORASTBase **) &result);
	      result->destroy();
	    } catch (int i) {
	      fprintf(stderr, "Sorry maple or formconv do not support something in your formula.\n");
	      result->destroy();
	      exit(1);
	    }
      }
      break;
    case F_HTML_VALIGN:
    case F_LATEX:
      {
	    TreeParser_Beautify b(output_format == F_HTML_VALIGN, ofname/*, C_precedence == 0*/);
//	    root->preorder(); printf("\n");//for debug
	    if (autosimplify || (output_format == F_HTML_VALIGN))
	    {
		    b.inp((SORASTBase **)&root, (SORASTBase **)&result);
		    root->destroy();
		    if (output_format == F_HTML_VALIGN)
				{
				  result->destroy();
					break;
				}
	    }
	    else result=root;
//	    puts(""); result->preorder(); puts(""); fflush(stdout); //for debug
	    TreeParser_LaTeX_out latex(ofname, prefix, suffix, header, footer, olang/*HUNGARIAN*/, cdots==1, dynamic_parentheses==1, beauty_parentheses==1);
	    latex.inp((SORASTBase **) &result);
	    result->destroy();
	  }
	  break;
	case F_YACAS:
		{
			TreeParser_Expand e(ofname, false/*simplify*/, false /*log_equal*/);
			e.inp((SORASTBase **)&root, (SORASTBase **)&result);
			root->destroy();
			try {
				TreeParser_yacas_out yacas(ofname, prefix, suffix, header, footer);
				yacas.inp((SORASTBase **) &result);
				result->destroy();
			} catch (int i) {
				fprintf(stderr, "Sorry yacas or formconv do not support something in your formula.\n");
				result->destroy();
				exit(1);
			}
		}
		break;
	case F_MAXIMA:
		{
			TreeParser_Expand e(ofname, false/*simplify*/, false /*log_equal*/);
			e.inp((SORASTBase **)&root, (SORASTBase **)&result);
			root->destroy();
			try {
				TreeParser_Maxima_out maxima(ofname, prefix, suffix, header, footer);
				maxima.inp((SORASTBase **) &result);
				result->destroy();
			} catch (int i) {
				fprintf(stderr, "Sorry maxima or formconv do not support something in your formula.\n");
				result->destroy();
				exit(1);
			}
		}
		break;
	case F_MATHML:
		{
			TreeParser_Expand e(ofname, false/*simplify*/, false /*log_equal*/);
			e.inp((SORASTBase **)&root, (SORASTBase **)&result);
			root->destroy();
			try {
				TreeParser_MathML_out mathml(ofname, prefix, suffix, header, footer);
				mathml.inp((SORASTBase **) &result);
				result->destroy();
			} catch (int i) {
				fprintf(stderr, "Sorry MathML or formconv do not support something in your formula.\n");
				result->destroy();
				exit(1);
			}
		}
		break;
	case F_GNUPLOT:
		{
			TreeParser_Expand e(ofname, false/*simplify*/, false /*log_equal*/);
			e.inp((SORASTBase **)&root, (SORASTBase **)&result);
			root->destroy();
			try {
				TreeParser_gnuplot_out gnuplot(ofname, prefix, suffix, header, footer);
				gnuplot.inp((SORASTBase **) &result);
				result->destroy();
			} catch (int i) {
				fprintf(stderr, "Sorry gnuplot or formconv do not support something in your formula.\n");
				result->destroy();
				exit(1);
			}
		}
		break;
	case F_CCOMPLEX:
		{
			TreeParser_Expand e(ofname, false/*simplify*/, false /*log_equal*/);
			e.inp((SORASTBase **)&root, (SORASTBase **)&result);
			root->destroy();
			try {
				TreeParser_ccomplex_out ccomplex(ofname, prefix, suffix, header, footer);
				ccomplex.inp((SORASTBase **) &result);
				result->destroy();
			} catch (int i) {
				fprintf(stderr, "Sorry complex.h, math.h or formconv do not support something in your formula.\n");
				result->destroy();
				exit(1);
			}
		}
		break;
	case F_C:
		{
			TreeParser_Expand e(ofname, false/*simplify*/, false /*log_equal*/);
			e.inp((SORASTBase **)&root, (SORASTBase **)&result);
			root->destroy();
			try {
				TreeParser_c_out c(ofname, prefix, suffix, header, footer);
				c.inp((SORASTBase **) &result);
				result->destroy();
			} catch (int i) {
				fprintf(stderr, "Sorry math.h or formconv do not support something in your formula.\n");
				result->destroy();
				exit(1);
			}
		}
		break;
	case F_MUPAD:
		{
			TreeParser_Expand e(ofname, false/*simplify*/, false /*log_equal*/);
			e.inp((SORASTBase **)&root, (SORASTBase **)&result);
			root->destroy();
			try {
				TreeParser_MuPAD_out mupad(ofname, prefix, suffix, header, footer);
				mupad.inp((SORASTBase **) &result);
				result->destroy();
			} catch (int i) {
				fprintf(stderr, "Sorry MuPAD or formconv do not support something in your formula.\n");
				result->destroy();
				exit(1);
			}
		}
		break;
	case F_PARSE:
		{
			root->destroy();
			if (err_code) puts("no");
			else puts("yes");
		}
		break;
	case F_JAVA:
		{
			TreeParser_Expand e(ofname, false/*simplify*/, false /*log_equal*/);
			e.inp((SORASTBase **)&root, (SORASTBase **)&result);
			root->destroy();
			TreeParser_Java_out java(ofname, prefix, suffix, header, footer);
			try {
				java.inp((SORASTBase **) &result);
			} catch (int e)
			{
				result->destroy();
				fprintf(stderr, "Error while creating the Java output. Probably an unsupported function.\n");
				exit(-1);
			}
			result->destroy();
		}
		break;
	case F_VERB_HU:
      {
	    TreeParser_Beautify b(false, ofname/*, C_precedence == 0*/);
	    if (autosimplify)
	    {
		    b.inp((SORASTBase **)&root, (SORASTBase **)&result);
		    root->destroy();
	    }
	    else result=root;
//	    puts(""); result->preorder(); puts(""); fflush(stdout); //for debug
	    TreeParser_verb_hu_out verbhu(ofname, prefix, suffix, header, footer);
	    verbhu.inp((SORASTBase **) &result);
	    result->destroy();
	  }

		break;
	case F_HTML:
      {
	    TreeParser_Beautify b(false, ofname/*, C_precedence == 0*/);
	    if (autosimplify)
	    {
		    b.inp((SORASTBase **)&root, (SORASTBase **)&result);
		    root->destroy();
	    }
	    else result=root;
	    TreeParser_html_out html(ofname, prefix, suffix, header, footer, olang, cdots==1, dynamic_parentheses==1, beauty_parentheses==1);
	    html.inp((SORASTBase **) &result);
	    result->destroy();
	  }
		break;
	default:
	  exit(-1);
	  break;
  }
  return (0);
}
