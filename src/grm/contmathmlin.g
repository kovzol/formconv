header{
#include <h/fcAST.h>
}

options {
	language="Cpp";
}

/**
 * This file creates tokens (ContMathMLInLexer), and an AST(ContMathMLInParser) from a MathML file, the output uses MathML AST format.
 * Generation depends on the following files:
 * IntuitiveTokenTypes.txt
 * Compilation depends on the following files:
 * h/fcAST.h
 * From this file the following files will be created:
 * ContMathMLInLexer.cpp, ContMathMLInLexer.hpp, ContMathMLInParser.cpp, ContMathMLInParser.hpp, ContMathMLInTokenTypes.hpp, ContMathMLInTokenTypes.txt
 * @author Gabor Bakos (baga@users.sourceforge.net)
 */

class ContMathMLInParser extends Parser;
options
{
	k=1;
	importVocab=Intuitive;
	exportVocab=ContMathMLIn;
//	importVocab=ContMathMLIn;
	ASTLabelType="RefFcAST";
	buildAST=true;
	defaultErrorHandler=false;
}

tokens {
	OAPPLY;
	OCI;
	OCN;
	OCSYMBOL;
	OBVAR;
	OMATH;
	ODECLARE;
	OLAMBDA;
	OSET;
	OLIST;
	OMATRIX;
	OMATRIXROW;
	OVECTOR;
	OPIECEWISE;
	OPIECE;
	OOTHERWISE;
	OLOWLIMIT;
	OUPLIMIT;
	ODEGREE;
	OLOGBASE;
	OINTERVAL;
	OCONDITION;
	ODOMAINOFAPPLICATION;
	OMOMENTABOUT;
	
	CAPPLY;
	CCI;
	CCN;
	CCSYMBOL;
	CBVAR;
	CMATH;
	CDECLARE;
	CLAMBDA;
	CSET;
	CLIST;
	CMATRIX;
	CMATRIXROW;
	CVECTOR;
	CPIECEWISE;
	CPIECE;
	COTHERWISE;
	CLOWLIMIT;
	CUPLIMIT;
	CDEGREE;
	CLOGBASE;
	CINTERVAL;
	CCONDITION;
	CDOMAINOFAPPLICATION;
	CMOMENTABOUT;

	MFACTORIAL;
	MSEP;
	MMINUS;
	MABS;
	MCONJUGATE;
	MARG;
	MREAL;
	MIMAGINARY;
	MFLOOR;
	MCEILING;
	MINVERSE;
	MIDENT;
	MDOMAIN;
	MCODOMAIN;
	MIMAGE;
	MSIN;
	MCOS;
	MTAN;
	MSEC;
	MCSC;
	MCOT;
	MSINH;
	MCOSH;
	MTANH;
	MSECH;
	MCSCH;
	MCOTH;
	MARCSIN;
	MARCCOS;
	MARCTAN;
	MARCSEC;
	MARCCSC;
	MARCCOT;
	MARCSINH;
	MARCCOSH;
	MARCTANH;
	MARCSECH;
	MARCCSCH;
	MARCCOTH;
	MROOT;
	MEXP;
	MLN;
	MLOG;
	MDETERMINANT;
	MTRANSPOSE;
	MDIVERGENCE;
	MGRAD;
	MCURL;
	MLAPLACIAN;
	MCARD;
	MQUOTIENT;
	MDIVIDE;
	MREM;
	MSETDIFF;
	MVECTORPRODUCT;
	MSCALARPRODUCT;
	MOUTERPRODUCT;
	MPLUS;
	MTIMES;
	MMAX;
	MMIN;
	MGCD;
	MLCM;
	MPOWER;
	MMEAN;
	MSDEV;
	MVARIANCE;
	MMEDIAN;
	MMODE;
	MNOT;
	MAND;
	MOR;
	MXOR;
	MSELECTOR;
	MUNION;
	MINTERSECT;
	MCARTESIANPRODUCT;
	MCOMPOSE;
	MEQUIVALENT;
	MAPPROX;
	MFACTOROF;
	MIMPLIES;
	MIIN;
	MNOTIN;
	MNOTSUBSET;
	MNOTPRSUBSET;
	MTENDSTO;
	MEQ;
	MLEQ;
	MLT;
	MGEQ;
	MGT;
	MSUBSET;
	MPRSUBSET;
	MINT;
	MSUM;
	MPRODUCT;
	MDIFF;
	MPARTIALDIFF;
	MFORALL;
	MEXISTS;
	MLIMIT;
	MPI;
	ME;
	MI;
	MGAMMA;
	MNATURALNUMBERS;
	MPRIMES;
	MINTEGERS;
	MRATIONALS;
	MREALS;
	MCOMPLEXES;
	MEMPTYSET;
	MINFTY;
	MTRUE;
	MFALSE;
	MNAN;
	MPM;
	MMP;

	EPM;
	EMP;
	EALPHA;
	EBETA;
	EGAMMA;
	EGAMMAG;
	EDELTA;
	EDELTAG;
	EEPSILON;
	EZETA;
	EETA;
	ETHETA;
	ETHETAG;
	EIOTA;
	EKAPPA;
	ELAMBDA;
	ELAMBDAG;
	EMU;
	ENU;
	EXI;
	EXIG;
	EOMICRON;
	EPI;
	EPIG;
	ERHO;
	ESIGMA;
	ESIGMAG;
	ETAU;
	EUPSILON;
	EUPSILONG;
	EPHI;
	EPHIG;
	ECHI;
	EPSI;
	EPSIG;
	EOMEGA;
	EOMEGAG;
	
	SPECNEG;
}

inp	:	(XML!)? (OMATH^ (expr)? CMATH!)
	;

expr	:	((OAPPLY! (/*(unary expr)
			|*/
			  ((MFACTORIAL^ | MABS^ | MCONJUGATE^ | MARG^ | MREAL^ | MIMAGINARY^ | MFLOOR^ | MCEILING^ | MNOT^ | MINVEERSE^ | MDOMAIN^ | MCODOMAIN^ | MIMAGE^ | MSIN^ | MCOS^ | MTAN^ | MSEC^ | MCSC^ | MCOT^ | MSINH^ | MCOSH^ | MTANH^ | MSECH^ | MCSCH^ | MCOTH^ | MARCSIN^ | MARCCOS^ | MARCTAN^ | MARCSEC^ | MARCCSC^ | MARCCOT^ | MARCSINH^ | MARCCOSH^ | MARCTANH^ | MARCSECH^ | MARCCSCH^ | MARCCOTH^ | MEXP^ | MLN^ | MDETERMINANT^ | MTRANSPOSE^ | MDIVERGENCE^ | MGRAD^ | MCURL^ | MLAPLACIAN^ | MCARD^) expr)
//			| (binary expr expr)
			| ((MQUOTIENT^ | MDIVIDE^ | MPOWER^ | MREM^ | MIMPLIES^ | MNEQ^ | MEQUIVALENT^ | MAPPROX^ | MFACTOROF^ | MSETDIFF^ | MIIN^ | MNOTIN^  | MNOTSUBSET^ | MNOTPRSUBSET^ | MVECTORPRODUCT^ | MSCALARPRODUCT^ | MOUTERPRODUCT^ | MTENDSTO^) expr expr)
			| (MMINUS^ expr (expr)?)
			| (OCSYMBOL! (EPM^ {#EPM->setType(MPM);} | EMP^ {#EMP->setType(MMP);}) CCSYMBOL! expr (expr)?)
//			| (nary)
			| ((MSELECTOR^ | MSUBSET^ | MPRSUBSET^) (expr)+)
			| integrate
			| diff
			| partialdiff
			| sum
			| product
			| limit
			| log
			| root
			| moment
			| min
			| max
			| forall
			| exists
			| naryops
			)
		CAPPLY!)
	|	(OCN^
			(	(MNUMBER (sep (numOrNeg | PRIV_LPAREN! numOrNeg PRIV_RPAREN!))?)
			| (SPECNEG! (MNUMBER (sep (numOrNeg | PRIV_LPAREN! numOrNeg PRIV_RPAREN!))?) {#expr=#(#[MMINUS, "minus"], #expr);})
			|	EPI {#EPI->setType(MPI);}
			|	EE {#EE->setType(ME);}
			|	EI {#EI->setType(MI);}
			|	EGAMMA {#EGAMMA->setType(MGAMMA);}
			|	EINFTY {#EINFTY->setType(MINFTY);}
			|	ETRUE {#ETRUE->setType(MTRUE);}
			|	EFALSE {#EFALSE->setType(MFALSE);}
			|	ENAN {#ENAN->setType(MNAN);}
			)
		CCN!)
	|	constant
	|	ci
	|	(ODECLARE^ expr expr CDECLARE!)
	|	(OLAMBDA^ (bvar)+ expr CLAMBDA!)
	|	(OPIECEWISE^ (pieces)+ (otherwise)? CPIECEWISE!)
	|	MIDENT^
	)
	;

numOrNeg : ((SPECNEG! m0:MNUMBER! {#numOrNeg = #(#[MMINUS, "-"], #(#[OCN, "cn"], #m0));}) | m1:MNUMBER! {#numOrNeg=#(#[OCN, "cn"], #m1);})
  ;

ci	:	(OCI^ (MID/* | pmexpr*/ | greekletter) CCI!)
	|	(OCSYMBOL! (MID^ | expr) CCSYMBOL!)
	;

greekletter:	EALPHA | EBETA | EGAMMAG | EDELTA | EDELTAG | EEPSILON | EZETA | EETA | ETHETA | ETHETAG | EIOTA | EKAPPA | ELAMBDA | ELAMBDAG | EMU | ENU | EXI | EXIG | EPIG | ERHO | ESIGMA | ESIGMAG | ETAU | EUPSILON | EUPSILONG | EPHI | EPHIG | ECHI | EPSI | EPSIG | EOMEGA | EOMEGAG
	;

constant:
	(	ME
	|	MI
	|	MNAN
	|	MTRUE
	|	MFALSE
	|	MPI
	|	MGAMMA
	|	MINFTY) {#constant=#(#[OCN, "cn"], #constant);}
	;

condition:	(OCONDITION^ expr CCONDITION!)
	;

interval:	(OINTERVAL^ expr expr CINTERVAL!)
	;

lowlimit:	(OLOWLIMIT^ expr CLOWLIMIT!)
	;

limits	:	lowlimit
	|	(OUPLIMIT^ expr CUPLIMIT!)
	;

bvar	:	(OBVAR^ expr (degree)? CBVAR!)
	;

degree	:	(ODEGREE^ expr CDEGREE!)
	;

pieces	:	(OPIECE^ expr expr CPIECE!)
	;

otherwise:	(OOTHERWISE^ expr expr COTHERWISE!)
	;

sep	:	MSEP
	;

domofapp:	(ODOMAINOFAPPLICATION^ expr CDOMAINOFAPPLICATION!)
	;

cdomain	:	(bvar)* ((limits (limits)?) | domofapp | condition)
	;

/*unary	:	MFACTORIAL | MABS | MCONJUGATE | MARG | MREAL | MIMAGINARY | MFLOOR | MCEILING | MNOT | MINVEERSE | MDOMAIN | MCODOMAIN | MIMAGE | MSIN | MCOS | MTAN | MSEC | MCSC | MCOT | MSINH | MCOSH | MTANH | MSECH | MCSCH | MCOTH | MARCSIN | MARCCOS | MARCTAN | MARCSEC | MARCCSC | MARCCOT | MARCSINH | MARCCOSH | MARCTANH | MARCSECH | MARCCSCH | MARCCOTH | MEXP | MLN | MDETERMINANT | MTRANSPOSE | MDIVERGENCE | MGRAD | MCURL | MLAPLACIAN | MCARD
	;
*/
integrate:	(MINT^ (cdomain)? expr)
	;

diff	:	(MDIFF^ (bvar)? expr)
	;

partialdiff:	(MPARTIALDIFF^ (bvar)* (degree)? expr)
	;

sum	:	(MSUM^ cdomain expr)
	;

product	:	(MPRODUCT^ cdomain expr)
	;

limit	:	(MLIMIT (bvar)* (lowlimit | condition) expr)
	;

log	:	MLOG^ (OLOGBASE! expr CLOGBASE!)? expr
	;

root	:	MROOT^ (degree)? expr
	;

moment	:	MMOMENT^ (degree)? (momentabout)? expr
	;

momentabout:	(OMOMENTABOUT^ expr CMOMENTABOUT!)
	;

min	:	(MMIN^ ((cdomain expr) | (expr)+))
	;

max	:	(MMAX^ ((cdomain expr) | (expr)+))
	;

forall	:	(MFORALL^ cdomain expr)
	;

exists	:	(MEXISTS^ cdomain expr)
	;

naryops	:	((MPLUS^ | MTIMES^ | MGCD^ | MLCM^ | MMEAN^ | MSDEV^ | MVARIANCE^ | MMEDIAN | MMODE^ | MAND^ | MOR^ | MXOR^ | MUNION^ | MINTERSECT^ | MCARTESIANPRODUCT^ | MCOMPOSE^ | MEQ^ | MLEQ^ | MLT^ | MGEQ^ | MGT^) ((cdomain expr) | (expr)+))
	;

/*binary	:	MQUOTIENT | MDIVIDE | MPOWER | MREM | MIMPLIES | MNEQ | MEQUIVALENT | MAPPROX | MFACTOROF | MSETDIFF | MIIN | MNOTIN  | MNOTSUBSET | MNOTPRSUBSET | MVECTORPRODUCT | MSCALARPRODUCT | MOUTERPRODUCT | MTENDSTO
	;
*/
/*nary	:	((MSELECTOR^ | MSUBSET^ | MPRSUBSET^) (expr)+)
	;
*/
constructs:	(OSET^ (expr)+ CSET!)
	|	(OLIST^ (expr)+ CLIST!)
	|	(OVECTOR^ (expr)+ CVECTOR!)
	;

class ContMathMLInLexer extends Lexer;
options
{
	k=2;
//	caseSensitive=false;
//	exportVocab=MathMLIn;
	exportVocab=ContMathMLIn;
	testLiterals=false;
	charVocabulary = '\0'..'\377';
}
WS	:	(' '
	|	'\t'
	|	('\n' {newline();})
	|	('\r' {newline();})
	)
	{ _ttype = ANTLR_USE_NAMESPACE(antlr)Token::SKIP; }
	;

protected
DIGIT	:	'0'..'9'
	;

protected
NSPREFIX:	MID ":"
	;

MNUMBER	:	((DIGIT)+ ('.' (DIGIT)*)? | ('.' (DIGIT)*))
	;

MID	:	('a'..'z' | 'A'..'Z') ('a'..'z' | 'A'..'Z' | '0'..'9' | '_')*
	;

ENTITIES:	'&' (("pi;" {$setType(EPI);})
	|	("ExponentialE;" {$setType(EE);})
	|	("ee;" {$setType(EE);})
	|	("ImaginaryI;" {$setType(EI);})
	|	("ii;" {$setType(EI);})
	|	("infin;")=>("infin;" {$setType(EINFTY);})
	|	("infty;" {$setType(EINFTY);})
	|	("true;" {$setType(ETRUE);})
	|	("false;" {$setType(EFALSE);})
	|	("NotANumber;" {$setType(ENAN);})
	|	("NaN;" {$setType(ENAN);})
	|	("PlusMinus;" {$setType(EPM);})
	|	("plusmn;" {$setType(EPM);})
	|	("pm;" {$setType(EPM);})
	|	("MinusPlus;" {$setType(EMP);})
	|	("mnplus;" {$setType(EMP);})
	|	("mp;" {$setType(EMP);})
	|	("alpha;" {$setType(EALPHA);})
	|	("beta;" {$setType(EBETA);})
	|	("gamma;" {$setType(EGAMMA);})
	|	("Gamma;" {$setType(EGAMMAG);})
	|	("delta;" {$setType(EDELTA);})
	|	("Delta;" {$setType(EDELTAG);})
	|	("epsi" ("v")? ";" {$setType(EEPSILON);})
	|	("zeta;" {$setType(EZETA);})
	|	("eta;" {$setType(EETA);})
	|	("theta" ('v')? ';' {$setType(ETHETA);})
	|	("Theta;" {$setType(ETHETAG);})
	|	("iota;" {$setType(EIOTA);})
	|	("kappa" ('v')? ';' {$setType(EKAPPA);})
	|	("lambda;" {$setType(ELAMBDA);})
	|	("Lambda;" {$setType(ELAMBDAG);})
	|	("mu;" {$setType(EMU);})
	|	("nu;" {$setType(ENU);})
	|	("xi;" {$setType(EXI);})
	|	("Xi;" {$setType(EXIG);})
//	|	("omicron;" {$setType(EOMICRON);})
	|	("Pi;" {$setType(PIG);})
	|	("rho" ('v')? ';' {$setType(ERHO);})
	|	("sigma;" {$setType(ESIGMA);})
	|	("Sigma;" {$setType(ESIGMAG);})
	|	("tau;" {$setType(ETAU);})
	|	("upsi" ("lon")? ";" {$setType(EUPSILON);})
	|	("Upsi" ("lon")? ";" {$setType(EUPSILONG);})
	|	("phi" ('v')? ';' {$setType(EPHI);})
	|	("Phi;" {$setType(EPHIG);})
	|	("chi;" {$setType(ECHI);})
	|	("psi;" {$setType(EPSI);})
	|	("Psi;" {$setType(EPSIG);})
	|	("omega;" {$setType(EOMEGA);})
	|	("Omega;" {$setType(EOMEGAG);})
	|	("var" (("epsilon;" {$setType(EEPSILON);})
			|	("kappa;" {$setType(EKAPPA);})
			|	("phi;" {$setType(EPHI);})
			|	("rho;" {$setType(ERHO);})
			|	("sigma;" {$setType(ESIGMA);})
			|	("theta;" {$setType(ETHETA);})
			)
		)
//	|	(((('0')? '0')? '0')? ('B' | 'b') '1')=>(((('0')? '0')? '0')? ('B' | 'b') '1' ';' {$setType(EPM);})	//000B1 &pm; 02213 &mp;
	|	(('B' | 'b') "1;" {$setType(EPM);})
	|	("000" ('B' | 'b'))=>("000" ('B' | 'b') "1;" {$setType(EPM);})
	|	("00" ('B' | 'b'))=>("00" ('B' | 'b') "1;" {$setType(EPM);})
	|	("0" ('B' | 'b'))=>("0" ('B' | 'b') "1;" {$setType(EPM);})
	|	(('0')? "2213;" {$setType(EMP);})
	|	( ('0' ('0')?)? '3'
		  (	(('B'|'b')
				(
					'1' {$setType(EALPHA);}
				|	'2' {$setType(EBETA);}
				|	'3' {$setType(EGAMMA);}
				|	'4' {$setType(EDELTA);}
				|	'5' {$setType(EEPSILON);}
				|	'6' {$setType(EZETA);}
				|	'7' {$setType(EETA);}
				|	'8' {$setType(ETHETA);}
				|	'9' {$setType(EIOTA);}
				|	('A'|'a') {$setType(EKAPPA);}
				|	('B'|'b') {$setType(ELAMBDA);}
				|	('C'|'c') {$setType(EMU);}
				|	('D'|'d') {$setType(ENU);}
				|	('E'|'e') {$setType(EXI);}
//				|	('F'|'f') {$setType(EOMICRON);}
				)
			) |
			(('C'|'c')
				(
					'0' {$setType(EPI);}
				|	'1' {$setType(ERHO);}
				|	'3' {$setType(ESIGMA);}
				|	'4' {$setType(ETAU);}
				|	'5' {$setType(EUPSILON);}
				|	'6' {$setType(EPHI);}
				|	'7' {$setType(ECHI);}
				|	'8' {$setType(EPSI);}
				|	'9' {$setType(EOMEGA);}
				)
			) |
			(('A'|'a')
				(
					'0' {$setType(PIG);}
				|	'3' {$setType(ESIGMAG);}
				|	'5' {$setType(EUPSILONG);}
				|	'6' {$setType(EPHIG);}
				|	'8' {$setType(EPSIG);}
				|	'9' {$setType(EOMEGAG);}
				)
			) |
			('9'
				(
					'3' {$setType(EGAMMAG);}
				|	'4' {$setType(EDELTAG);}
				|	'8' {$setType(ETHETAG);}
				|	('B'|'b') {$setType(ELAMBDAG);}
				|	('E'|'e') {$setType(EXIG);}
				)
			) |
			(('D'|'d')
				(
					'5' {$setType(EPHI);}
				)
			) |
			(('F'|'f')
				(
					'0' {$setType(EKAPPA);}
				|	'1' {$setType(ERHO);}
				|	'5' {$setType(EEPSILON);}
				)
			)
		  ) ';'
		)
	)
	;

protected
TEXT	:	('"' (options {
			greedy=false;
			}: .
			)+
		'"')
		| ('\'' (options {
			greedy=false;
			}: .
			)+
		'\'')
	;

XML	:	("<?xml" (((WS)+ "version")=>((WS)+ "version" "=" (WS)* '"' MNUMBER '"'))? (((WS)+ "encoding")=>((WS)+ "encoding" (WS)* "=" (WS)* TEXT))? (WS)* "?>")
	;

OPENING	{std::string s;}:	("<"! (WS!)* ((NSPREFIX)=>NSPREFIX!)? MID {s=$getText;} ((WS!)+ ((((NSPREFIX)=> (NSPREFIX!))? MID "=" TEXT) (WS!)*)*)?
		((">"!
		{
			if (s=="apply")
			{
				$setType(OAPPLY);
			}
			else if (s=="ci")
			{
				$setType(OCI);
			}
			else if (s=="cn")
			{
				$setType(OCN);
			}
			else if (s=="csymbol")
			{
				$setType(OCSYMBOL);
			}
			else if (s=="bvar")
			{
				$setType(OBVAR);
			}
			else if (s=="math")
			{
				$setType(OMATH);
			}
			else if (s=="declare")
			{
				$setType(ODECLARE);
			}
			else if (s=="lambda")
			{
				$setType(OLAMBDA);
			}
			else if (s=="set")
			{
				$setType(OSET);
			}
			else if (s=="list")
			{
				$setType(OLIST);
			}
			else if (s=="matrix")
			{
				$setType(OMATRIX);
			}
			else if (s=="matrixrow")
			{
				$setType(OMATRIXROW);
			}
			else if (s=="vector")
			{
				$setType(OVECTOR);
			}
			else if (s=="piecewise")
			{
				$setType(OPIECEWISE);
			}
			else if (s=="piece")
			{
				$setType(OPIECE);
			}
			else if (s=="otherwise")
			{
				$setType(OOTHERWISE);
			}
			else if (s=="lowlimit")
			{
				$setType(OLOWLIMIT);
			}
			else if (s=="uplimit")
			{
				$setType(OUPLIMIT);
			}
			else if (s=="degree")
			{
				$setType(ODEGREE);
			}
			else if (s=="logbase")
			{
				$setType(OLOGBASE);
			}
			else if (s=="interval")
			{
				$setType(OINTERVAL);
			}
			else if (s=="condition")
			{
				$setType(OCONDITION);
			}
			else if (s=="domainofapplication")
			{
				$setType(ODOMAINOFAPPLICATION);
			}
			else if (s=="momentabout")
			{
				$setType(OMOMENTABOUT);
			}
		}
		)
		|
		("/"! (WS!)* ">"!
		{
			if (s=="factorial")
			{
				$setType(MFACTORIAL);
			}
			else if (s=="sep")
			{
				$setType(MSEP);
			}
			else if (s=="minus")
			{
				$setType(MMINUS);
			}
			else if (s=="abs")
			{
				$setType(MABS);
			}
			else if (s=="conjugate")
			{
				$setType(MCONJUGATE);
			}
			else if (s=="arg")
			{
				$setType(MARG);
			}
			else if (s=="real")
			{
				$setType(MREAL);
			}
			else if (s=="imaginary")
			{
				$setType(MIMAGINARY);
			}
			else if (s=="floor")
			{
				$setType(MFLOOR);
			}
			else if (s=="ceiling")
			{
				$setType(MCEILING);
			}
			else if (s=="inverse")
			{
				$setType(MINVERSE);
			}
			else if (s=="ident")
			{
				$setType(MIDENT);
			}
			else if (s=="domain")
			{
				$setType(MDOMAIN);
			}
			else if (s=="codomain")
			{
				$setType(MCODOMAIN);
			}
			else if (s=="image")
			{
				$setType(MIMAGE);
			}
			else if (s=="sin")
			{
				$setType(MSIN);
			}
			else if (s=="cos")
			{
				$setType(MCOS);
			}
			else if (s=="tan")
			{
				$setType(MTAN);
			}
			else if (s=="sec")
			{
				$setType(MSEC);
			}
			else if (s=="csc")
			{
				$setType(MCSC);
			}
			else if (s=="cot")
			{
				$setType(MCOT);
			}
			else if (s=="sinh")
			{
				$setType(MSINH);
			}
			else if (s=="cosh")
			{
				$setType(MCOSH);
			}
			else if (s=="tanh")
			{
				$setType(MTANH);
			}
			else if (s=="sech")
			{
				$setType(MSECH);
			}
			else if (s=="csch")
			{
				$setType(MCSCH);
			}
			else if (s=="coth")
			{
				$setType(MCOTH);
			}
			else if (s=="arcsin")
			{
				$setType(MARCSIN);
			}
			else if (s=="arccos")
			{
				$setType(MARCCOS);
			}
			else if (s=="arctan")
			{
				$setType(MARCTAN);
			}
			else if (s=="arcsec")
			{
				$setType(MARCSEC);
			}
			else if (s=="arccsc")
			{
				$setType(MARCCSC);
			}
			else if (s=="arccot")
			{
				$setType(MARCCOT);
			}
			else if (s=="arcsinh")
			{
				$setType(MARCSINH);
			}
			else if (s=="arccosh")
			{
				$setType(MARCCOSH);
			}
			else if (s=="arctanh")
			{
				$setType(MARCTANH);
			}
			else if (s=="arcsech")
			{
				$setType(MARCSECH);
			}
			else if (s=="arccsch")
			{
				$setType(MARCCSCH);
			}
			else if (s=="arccoth")
			{
				$setType(MARCCOTH);
			}
			else if (s=="root")
			{
				$setType(MROOT);
			}
			else if (s=="exp")
			{
				$setType(MEXP);
			}
			else if (s=="ln")
			{
				$setType(MLN);
			}
			else if (s=="log")
			{
				$setType(MLOG);
			}
			else if (s=="determinant")
			{
				$setType(MDETERMINANT);
			}
			else if (s=="transpose")
			{
				$setType(MTRANSPOSE);
			}
			else if (s=="divergence")
			{
				$setType(MDIVERGENCE);
			}
			else if (s=="grad")
			{
				$setType(MGRAD);
			}
			else if (s=="curl")
			{
				$setType(MCURL);
			}
			else if (s=="laplacian")
			{
				$setType(MLAPLACIAN);
			}
			else if (s=="card")
			{
				$setType(MCARD);
			}
			else if (s=="quotient")
			{
				$setType(MQUOTIENT);
			}
			else if (s=="divide")
			{
				$setType(MDIVIDE);
			}
			else if (s=="rem")
			{
				$setType(MREM);
			}
			else if (s=="setdiff")
			{
				$setType(MSETDIFF);
			}
			else if (s=="vectorproduct")
			{
				$setType(MVECTORPRODUCT);
			}
			else if (s=="scalarproduct")
			{
				$setType(MSCALARPRODUCT);
			}
			else if (s=="outerproduct")
			{
				$setType(MOUTERPRODUCT);
			}
			else if (s=="plus")
			{
				$setType(MPLUS);
			}
			else if (s=="times")
			{
				$setType(MTIMES);
			}
			else if (s=="max")
			{
				$setType(MMAX);
			}
			else if (s=="min")
			{
				$setType(MMIN);
			}
			else if (s=="gcd")
			{
				$setType(MGCD);
			}
			else if (s=="lcm")
			{
				$setType(MLCM);
			}
			else if (s=="power")
			{
				$setType(MPOWER);
			}
			else if (s=="mean")
			{
				$setType(MMEAN);
			}
			else if (s=="msdev")
			{
				$setType(MSDEV);
			}
			else if (s=="variance")
			{
				$setType(MVARIANCE);
			}
			else if (s=="median")
			{
				$setType(MMEDIAN);
			}
			else if (s=="mode")
			{
				$setType(MMODE);
			}
			else if (s=="not")
			{
				$setType(MNOT);
			}
			else if (s=="and")
			{
				$setType(MAND);
			}
			else if (s=="or")
			{
				$setType(MOR);
			}
			else if (s=="xor")
			{
				$setType(MXOR);
			}
			else if (s=="selector")
			{
				$setType(MSELECTOR);
			}
			else if (s=="union")
			{
				$setType(MUNION);
			}
			else if (s=="intersect")
			{
				$setType(MINTERSECT);
			}
			else if (s=="cartesianproduct")
			{
				$setType(MCARTESIANPRODUCT);
			}
			else if (s=="compose")
			{
				$setType(MCOMPOSE);
			}
			else if (s=="equivalent")
			{
				$setType(MEQUIVALENT);
			}
			else if (s=="approx")
			{
				$setType(MAPPROX);
			}
			else if (s=="factorof")
			{
				$setType(MFACTOROF);
			}
			else if (s=="implies")
			{
				$setType(MIMPLIES);
			}
			else if (s=="in")
			{
				$setType(MIIN);
			}
			else if (s=="notin")
			{
				$setType(MNOTIN);
			}
			else if (s=="notsubset")
			{
				$setType(MNOTSUBSET);
			}
			else if (s=="notprsubset")
			{
				$setType(MNOTPRSUBSET);
			}
			else if (s=="tendsto")
			{
				$setType(MTENDSTO);
			}
			else if (s=="eq")
			{
				$setType(MEQ);
			}
			else if (s=="leq")
			{
				$setType(MLEQ);
			}
			else if (s=="lt")
			{
				$setType(MLT);
			}
			else if (s=="geq")
			{
				$setType(MGEQ);
			}
			else if (s=="gt")
			{
				$setType(MGT);
			}
			else if (s=="subset")
			{
				$setType(MSUBSET);
			}
			else if (s=="prsubset")
			{
				$setType(MPRSUBSET);
			}
			else if (s=="int")
			{
				$setType(MINT);
			}
			else if (s=="sum")
			{
				$setType(MSUM);
			}
			else if (s=="product")
			{
				$setType(MPRODUCT);
			}
			else if (s=="diff")
			{
				$setType(MDIFF);
			}
			else if (s=="partialdiff")
			{
				$setType(MPARTIALDIFF);
			}
			else if (s=="forall")
			{
				$setType(MFORALL);
			}
			else if (s=="exists")
			{
				$setType(MEXISTS);
			}
			else if (s=="limit")
			{
				$setType(MLIMIT);
			}
			else if (s=="naturalnumbers")
			{
				$setType(MNATURALNUMBERS);
			}
			else if (s=="primes")
			{
				$setType(MPRIMES);
			}
			else if (s=="integers")
			{
				$setType(MINTEGERS);
			}
			else if (s=="rationals")
			{
				$setType(MRATIONALS);
			}
			else if (s=="reals")
			{
				$setType(MREALS);
			}
			else if (s=="complexes")
			{
				$setType(MCOMPLEXES);
			}
			else if (s=="exponentiale")
			{
				$setType(ME);
			}
			else if (s=="imaginaryi")
			{
				$setType(MI);
			}
			else if (s=="notanumber")
			{
				$setType(MNAN);
			}
			else if (s=="true")
			{
				$setType(MTRUE);
			}
			else if (s=="false")
			{
				$setType(MFALSE);
			}
			else if (s=="emptyset")
			{
				$setType(MEMPTYSET);
			}
			else if (s=="pi")
			{
				$setType(MPI);
			}
			else if (s=="eulergamma")
			{
				$setType(MGAMMA);
			}
			else if (s=="infinity")
			{
				$setType(MINFTY);
			}
		}
		)
		)
	)
	;

CLOSING	{std::string s;}:	("</"! (WS!)* ((NSPREFIX)=>NSPREFIX!)? MID {s=$getText;} (WS!)* ">"!
	{
		if (s=="apply")
		{
			$setType(CAPPLY);
		}
		else if (s=="ci")
		{
			$setType(CCI);
		}
		else if (s=="cn")
		{
			$setType(CCN);
		}
		else if (s=="csymbol")
		{
			$setType(CCSYMBOL);
		}
		else if (s=="bvar")
		{
			$setType(CBVAR);
		}
		else if (s=="math")
		{
			$setType(CMATH);
		}
		else if (s=="declare")
		{
			$setType(CDECLARE);
		}
		else if (s=="lambda")
		{
			$setType(CLAMBDA);
		}
		else if (s=="set")
		{
			$setType(CSET);
		}
		else if (s=="list")
		{
			$setType(CLIST);
		}
		else if (s=="matrix")
		{
			$setType(CMATRIX);
		}
		else if (s=="matrixrow")
		{
			$setType(CMATRIXROW);
		}
		else if (s=="vector")
		{
			$setType(CVECTOR);
		}
		else if (s=="piecewise")
		{
			$setType(CPIECEWISE);
		}
		else if (s=="piece")
		{
			$setType(CPIECE);
		}
		else if (s=="otherwise")
		{
			$setType(COTHERWISE);
		}
		else if (s=="lowlimit")
		{
			$setType(CLOWLIMIT);
		}
		else if (s=="uplimit")
		{
			$setType(CUPLIMIT);
		}
		else if (s=="degree")
		{
			$setType(CDEGREE);
		}
		else if (s=="logbase")
		{
			$setType(CLOGBASE);
		}
		else if (s=="interval")
		{
			$setType(CINTERVAL);
		}
		else if (s=="condition")
		{
			$setType(CCONDITION);
		}
		else if (s=="domainofapplication")
		{
			$setType(CDOMAINOFAPPLICATION);
		}
		else if (s=="momentabout")
		{
			$setType(CMOMENTABOUT);
		}
	})
	;
SPECNEG : "-"
  ;

MSEP : "*10^"
  ;

PRIV_LPAREN : "("
  ;

PRIV_RPAREN : ")"
  ;

COMMENT	:	"<!--" (options {greedy=false;}: .)* "-->" {_ttype = ANTLR_USE_NAMESPACE(antlr)Token::SKIP; }
	;

