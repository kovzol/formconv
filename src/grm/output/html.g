header "pre_include_hpp"{
#include <string>
#include <h/misc.h>
#include <h/fcAST.h>
using namespace std;
}

options {
        language=Cpp;
}

/**
 * This file creates a string from an Intuitive type AST (less errors, if it is after presentation transformation).
 * Generation depends on the following files:
 * IntuitiveTokenTypes.txt
 * Compilation depends on the following files:
 * h/misc.h h/fcAST.h
 * From this file the following files will be created:
 * HTMLOutput.cpp, HTMLOutput.hpp, HTMLOutputTokenTypes.hpp, HTMLOutputTokenTypes.txt
 * @author Gabor Bakos (baga@users.sourceforge.net)
 */

class HTMLOutput extends TreeParser;
options {
	importVocab=Intuitive;
	noConstructors = true;
	ASTLabelType = "RefFcAST";
	defaultErrorHandler=false;
}

{
public:
	/**
	 * Sets the input's language.
	 * @param l The proper language
	 */
	void setLanguage(Language l)
	{
		lang=l;
	}

	/**
	 * Sets whether you want to see \left(, \right) pairs in the output.
	 * @param t The new value for dynamicParentheses
	 */
	void setDynamicParentheses(bool t=true)
	{
		dynamicParentheses=t;
	}

	/**
	 * Sets whether you want to change simple (, ) to (, ), [, ], and {, }.
	 * @param t The new value for beautyParentheses
	 */
	void setBeautyParentheses(bool t=true)
	{
		beautyParentheses=t;
	}

	/**
	 * The constructor.
	 */
	HTMLOutput() : antlr::TreeParser(), dynamicParentheses(false), beautyParentheses(false), isInSupIndex(0), isInSubIndex(0), lang(C), enumStrat(normal), rowCount(0)
	{
	}

protected:
	bool lastWasFunction, dynamicParentheses, beautyParentheses;
	int isInSupIndex, isInSubIndex;
	double height, fontSize, width;
	Language lang;
	EnumerationStrategy enumStrat;
	int rowCount;
	std::string format(const std::string& s, double size) const
	{
//		if (isInSupIndex==0 && isInSubIndex==0)
//		{
			char intSize[5];
			sprintf(intSize, "%d", (int)size);
			return "<font style=\"font-size: "+std::string(intSize)+"pt\">"+s+"</font>";
//		} else
//		{
//			return s;
//		}
	}
	std::string trStart() const
	{
		return "<tr>";
	}
	std::string tableStart(const std::string &args="") const
	{
		return (isInSupIndex==0 && isInSubIndex==0)?"<table cellspacing=\"0\" cellpadding=\"0\""+args+">"+trStart():"";
	}
	std::string trEnd() const
	{
		return "</tr>";
	}
	std::string tableEnd() const
	{
		return (isInSupIndex==0 && isInSubIndex==0)?(trEnd()+"</table>"):"";
	}
	std::string tdLeft() const
	{
		return (isInSupIndex==0 && isInSubIndex==0)?"<td align=\"left\" nowrap=\"nowrap\">":"";
	}
	std::string tdCenter() const
	{
		return (isInSupIndex==0 && isInSubIndex==0)?"<td align=\"center\" nowrap=\"nowrap\">":"";
	}
	std::string tdRight() const
	{
		return (isInSupIndex==0 && isInSubIndex==0)?"<td align=\"right\" nowrap=\"nowrap\">":"";
	}
	std::string tdEnd() const
	{
		return (isInSupIndex==0 && isInSubIndex==0)?"</td>":"";
	}
	std::string supStart() const
	{
		return "</td><td>";//"<sup>";
	}
	std::string supEnd() const
	{
		return "</td></tr><tr><td>&nbsp;</td></tr></table>";//"</sup>";
	}
	std::string subStart() const
	{
		return "<sub>";
	}
	std::string subEnd() const
	{
		return "</sub>";
	}
}

inp returns [string s] {string a;}:
	({isInSubIndex=isInSupIndex=0; height=fontSize=12; width=0.0;} a=expr {s=a;})
	|
	;

expr returns [string s]
	{
		string a,b,c,d;
		double size=fontSize;
		double beforeAHeight=height, beforeBHeight=height, afterBHeight=height;
		double beforeAWidth=width, beforeBWidth=width, afterBWidth=width;
		double beforeAFontSize=fontSize, beforeBFontSize=fontSize, afterBFontSize=fontSize;
		lastWasFunction=false;
		
		bool tmp=false;
		bool computed=false;
		bool locLastWasFunction=false;
	}
	:
	(#(PLUS {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format("+", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(MINUS {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format("&minus;", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(NEG {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; s=tableStart()+tdCenter()+format(" &minus;", size)+tdEnd()+tdLeft()+a+tdEnd()+tableEnd(); computed=true;})
	|#(MULT {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format(" &sdot; ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(MATRIXPRODUCT {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format(" &sdot; ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(MATRIXEXPONENTIATION {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=0.0; tmp=lastWasFunction;} {isInSupIndex++;} {beforeBHeight=height; beforeBFontSize=fontSize; fontSize/=1.5;} b=expr {afterBHeight=height; afterBFontSize=fontSize; fontSize=beforeBFontSize;} {isInSupIndex--;}
	  {//TODO put angle brackets.
		string::size_type pos=a.find("<sup/>");
		if (pos!=string::npos && tmp /*&& pos<11*/)
		{
			a.replace(pos, 6, supStart()+b+supEnd());
			pos=a.find("<td ");
			a.replace(pos, 4, "<td rowspan=\"2\" ");
			s=tableStart()+tdRight()+a;
		}
		else
		{
			s=tableStart()+"<td rowspan=\"2\">"+a+supStart()+b+supEnd();
		}
		computed=true;
		height=beforeBHeight+afterBHeight*0.3;
	  })
	|#(INVISIBLETIMES {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdLeft()+format(" ", size)+b+tdEnd()+tableEnd();})
	|#(DIV {beforeAHeight=height; beforeAWidth=width; width=0.0; beforeAFontSize=fontSize;} a=expr {beforeBWidth=width; width=0.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBWidth=width; afterBHeight=height; afterBFontSize=fontSize; width=beforeAWidth+max(beforeBWidth, afterBWidth);} {if (isInSubIndex==0 && isInSupIndex==0) {if (beforeBWidth>=afterBWidth) s=tableStart()+tdCenter()+tableStart(" border=\"1\" frame=\"below\" rules=\"none\"")+tdCenter()+"<center>"+a+"</center>"+tdEnd()+tableEnd()+trStart()+tdCenter()+"<center>"+b+"</center>"+tdEnd()+trEnd()+tableEnd(); else s=tableStart()+tdCenter()+a+trEnd()+tableStart(" border=\"1\" frame=\"above\" rules=\"none\"")+tdCenter()+b+tableEnd()+tableEnd();} else {s=tableStart()+tdRight()+a+tdCenter()+"/"+tdLeft()+b+tdEnd()+tableEnd();} height=beforeBHeight+afterBHeight+6; computed=true;})
	|#(MOD {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=3.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format(" mod ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(MODP {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=3.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format(" mod ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(FACTOROF {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=0.5; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format("|", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(EQUIV {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+format("&equiv; ", size)+b+tdEnd()+tableEnd();})
	|#(CIRCUM {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=0.0; tmp=lastWasFunction;} {isInSupIndex++;} {beforeBHeight=height; beforeBFontSize=fontSize; fontSize/=1.5;} b=expr {afterBHeight=height; afterBFontSize=fontSize; fontSize=beforeBFontSize;} {isInSupIndex--;}
	  {
		string::size_type pos=a.find("<sup/>");
		if (pos!=string::npos && tmp /*&& pos<11*/)
		{
			a.replace(pos, 6, supStart()+b+supEnd());
			pos=a.find("<td ");
			a.replace(pos, 4, "<td rowspan=\"2\" ");
			s=tableStart()+tdRight()+a;
		}
		else
		{
			s=tableStart()+"<td rowspan=\"2\">"+a+supStart()+b+supEnd();
		}
		computed=true;
		height=beforeBHeight+afterBHeight*0.3;
	  })
	|#(FACTORIAL {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=0.5; s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format("!", size)+tdEnd()+tableEnd(); computed=true;})
	|#(DFACTORIAL {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format("!!", size)+tdEnd()+tableEnd(); computed=true;})
	|#(UNDERSCORE {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=0.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+subStart()+b+subEnd()+tdEnd()+tableEnd(); /*computed=true; height=beforeBHeight+afterBHeight*0.3;*/})
	|#(PM {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr ({width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format("&plusmn; ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd(); return s;})? {s=tableStart()+tdRight()+format("&plusmn; ", size)+a+tdEnd()+tableEnd();})
	|#(MP {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr ({width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+format("&minus;", size)+a+tdEnd()+tdCenter()+format("&plusmn; ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd(); return s;})? {s=tableStart()+tdRight()+format("&minus;&plusmn;", size)+a+tdEnd()+tableEnd();})
	|#(DERIVE {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdCenter()+format(" &partial;", size)+"<hr noshade=\"noshade\">"+format("&partial; ", size)+b+tdEnd()+tdLeft()+a+tdEnd()+tableEnd(); computed=true; height=beforeBHeight+afterBHeight+6;})//TODO similarly to DIV
	|#(DERIVET {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {s=tableStart()+".<div/>"+tdCenter()+a+tableEnd(); computed=true;})
	|#(DDERIVET {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {s=tableStart()+"..<div/>"+tdCenter()+a+tableEnd(); computed=true;})
	|#(DERIVEX {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {s=tableStart()+tdRight()+a+format("'", size)+tdEnd()+tableEnd(); computed=true;})
	|#(NTHDERIVE {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {isInSupIndex++;} {beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {isInSupIndex--;} c=expr {s=tableStart()+tdCenter()+format("&partial;", size)+supStart()+b+supEnd()+"<hr noshade=\"noshade\">"+tdEnd()+tdLeft()+format("&partial;", size)+c+tdEnd()+tdLeft()+a+tdEnd()+tableEnd(); computed=true; height=beforeBHeight+afterBHeight+6;})//TODO similarly to DIV
//	|#(NTHDERIVEX {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=a+"^{("+b+")}";})
//	|#(FUNCMULT expr expr)
//	|#(FUNCPLUS expr expr)
	|#(FUNCINVERSE {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {s=tableStart()+tdRight()+a+supStart()+format("&minus;1", size)+supEnd()+tdEnd()+tableEnd(); computed=true;})
	|#(DEFINTEGRAL {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=2.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {isInSubIndex++;} c=expr {isInSubIndex--; isInSupIndex++;} d=expr {isInSupIndex--;} {s=tableStart()+tdCenter()+format(" &int;", beforeBHeight)+subStart()+c+subEnd()+supStart()+d+supEnd()+tdEnd()+tdLeft()+a+tdEnd()+tdCenter()+format("d", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd(); computed=true;})
	|#(INDEFINTEGRAL {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=2.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdCenter()+format(" &int;", beforeBHeight)+tdEnd()+tdLeft()+a+tdEnd()+tdCenter()+format("d", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd(); computed=true;})
	|#(SUM {isInSubIndex++;} {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr b=expr {isInSubIndex--; isInSupIndex++;} c=expr {isInSupIndex--;} {width+=2.0; beforeBHeight=height; beforeBFontSize=fontSize;} d=expr {afterBHeight=height; afterBFontSize=fontSize;} {if (b=="") s=tableStart()+tdCenter()+format("&sum;", afterBHeight)+tdEnd()+tdLeft()+d+tdEnd()+tableEnd(); else s=tableStart()+tdCenter()+format("&sum;", afterBHeight)+subStart()+a+format(":=", size)+b+subEnd()+supStart()+c+supEnd()+tdEnd()+tdLeft()+d+tdEnd()+tableEnd();})
	|#(PROD {isInSubIndex++;} {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr b=expr {isInSubIndex--; isInSupIndex++;} c=expr {isInSupIndex--;} {width+=2.0; beforeBHeight=height; beforeBFontSize=fontSize;} d=expr {afterBHeight=height; afterBFontSize=fontSize;} {if (b=="") s=tableStart()+tdCenter()+format("&prod;", afterBHeight)+tdEnd()+tdLeft()+d+tdEnd()+tableEnd(); else s=tableStart()+tdCenter()+format("&prod;", afterBHeight)+subStart()+a+format(":=", size)+b+subEnd()+supStart()+c+supEnd()+tdEnd()+tdLeft()+d+tdEnd()+tableEnd();})
	|#(EQUAL {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format("=", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(NEQ {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format("&ne; ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(LESS {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format("&lt;", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(LEQ {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format("&le; ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(NOTLESS {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format("&ge; ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(LESSNOTEQ {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format("&lt; ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(NOTLEQ {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format("&gt; ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(GREATER {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format("&gt;", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(GEQ {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format("&ge; ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(NOTGREATER {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format("&le; ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(GREATERNOTEQ {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format("&gt; ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(NOTGEQ {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format("&lt; ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(SETSUBSET {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format(" &sub; ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(SETSUBSETEQ {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format(" &sube; ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(SETSUBSETNEQ {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format(" &sub; ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(SETNOTSUBSETEQ {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=2.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdCenter()+format("&not;", size)+tdEnd()+tdLeft()+a+tdEnd()+tdCenter()+format("&sube; ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(SETSUPSET {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format(" &sup; ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(SETSUPSETEQ {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format(" &supe; ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(SETSUPSETNEQ {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format(" &sup; ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(SETNOTSUPSETEQ {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=2.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdCenter()+format("&not;", size)+tdEnd()+tdLeft()+a+tdEnd()+tdCenter()+format("&supe; ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(SETIN {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format(" &isin; ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(SETNI {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format(" &ni; ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(SET {width+=2.0; beforeAHeight=height; beforeAFontSize=fontSize;} a=expr ({width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;})? {if (b=="") s=tableStart()+tdCenter()+format(" {", beforeBHeight)+tdEnd()+tdLeft()+a+tdEnd()+tdCenter()+format("}", beforeBHeight)+tdEnd()+tableEnd(); else s=tableStart()+tdCenter()+format("{", afterBHeight)+tdEnd()+tdLeft()+a+tdEnd()+tdCenter()+format("|", afterBHeight)+tdEnd()+tdLeft()+b+tdEnd()+tdCenter()+format("}", afterBHeight)+tdEnd()+tableEnd();})
	|#(SETMINUS {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format(" \\ ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(SETMULT {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format(" &lowast; ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(SETUNION {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format(" &cup; ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(SETINTERSECT {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format(" &cap; ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(ASSIGN {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=2.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format(" := ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(NOT {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; s=tableStart()+tdCenter()+format(" &not; ", size)+tdEnd()+tdLeft()+a+tdEnd()+tableEnd();})
	|#(AND {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdCenter()+format("&and; ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(OR {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format("&or;", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(IMPLY {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=2.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format("&rarr;", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(RIMPLY {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=2.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format("&larr;", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(IFF {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=2.5; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdRight()+a+tdEnd()+tdCenter()+format("&rarr;&larr;", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(FORALL {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=2.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdCenter()+format("&forall;", size)+tdEnd()+tdLeft()+a+tdEnd()+tdLeft()+format(": ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(EXISTS {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=2.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdCenter()+format("&exist;", size)+tdEnd()+tdLeft()+a+tdEnd()+tdLeft()+format(": ", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(LIM {isInSubIndex++;} {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=3.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {isInSubIndex--;} c=expr (d=expr)? {if (d=="") d="&rarr; "; s=tableStart()+tdCenter()+format(" lim", size)+subStart()+a+d+b+subEnd()+tdEnd()+tdLeft()+c+tdEnd()+tableEnd();})
	|#(LIMSUP {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr ({isInSubIndex++;} {width+=6.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {isInSubIndex--;})? {s=tableStart()+tdCenter()+format(" limsup", size)+subStart()+b+subEnd()+tdEnd()+tdLeft()+a+tdEnd()+tableEnd();})
	|#(LIMINF {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr ({isInSubIndex++;} {width+=6.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {isInSubIndex--;})? {s=tableStart()+tdCenter()+format(" liminf", size)+subStart()+b+subEnd()+tdEnd()+tdLeft()+a+tdEnd()+tableEnd();})
	|#(SUP {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr ({isInSubIndex++;} {width+=3.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {isInSubIndex--;})? {s=tableStart()+tdCenter()+format(" sup", size)+subStart()+b+subEnd()+tdEnd()+tdLeft()+a+tdEnd()+tableEnd();})
	|#(INF {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr ({isInSubIndex++;} {width+=3.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {isInSubIndex--;})? {s=tableStart()+tdCenter()+format(" inf", size)+subStart()+b+subEnd()+tdEnd()+tdLeft()+a+tdEnd()+tableEnd();})
	|#(MAX {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr ({isInSubIndex++;} {width+=3.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {isInSubIndex--;})? {s=tableStart()+tdCenter()+format(" max", size)+subStart()+b+subEnd()+tdEnd()+tdLeft()+a+tdEnd()+tableEnd();})
	|#(MIN {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr ({isInSubIndex++;} {width+=3.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {isInSubIndex--;})? {s=tableStart()+tdCenter()+format(" min", size)+subStart()+b+subEnd()+tdEnd()+tdLeft()+a+tdEnd()+tableEnd();})
	|#(ARGMAX {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr ({isInSubIndex++;} {width+=6.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {isInSubIndex--;})? {s=tableStart()+tdCenter()+format(" argmax", size)+subStart()+b+subEnd()+tdEnd()+tdLeft()+a+tdEnd()+tableEnd();})
	|#(ARGMIN {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr ({isInSubIndex++;} {width+=6.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {isInSubIndex--;})? {s=tableStart()+tdCenter()+format(" argmin", size)+subStart()+b+subEnd()+tdEnd()+tdLeft()+a+tdEnd()+tableEnd();})
	| LEFT {s=std::string("&darr; ");}
	| RIGHT {s=std::string("&uarr; ");}
	| REAL {s=std::string("&rarr; ");}
	| COMPLEX {s=std::string("&rarr; ");}
	|#(v:VARIABLE {s=format("<i>"+v->getText()+"</i>", fontSize); width+=v->getText().length(); height=fontSize; computed=true;})
	|#(n:NUMBER
		{
			s=format(n->getText(), fontSize); height=fontSize; width+=n->getText().length();
		})
	|#(p:PARAMETER {s=format("<i>"+p->getText()+"</i>", fontSize); height=fontSize; computed=true; width+=p->getText().length();})
	|#(DOTS {s=format("&hellip; ", fontSize); height=fontSize; computed=true; width+=3.0; })
	|#(FC_TRUE
	  {
	  	switch (lang)
		{
			case hu:
				s="igaz";
				break;
			case en:
				s="true";
				break;
			case ge:
				s="--true--";
				break;
			case fr:
				s="vrai";
				break;
			default:
				s="true";
				break;
		}
		s=format(s, fontSize); height=fontSize; computed=true; width+=4.0;
	  }
	  )
	|#(FC_FALSE
	  {
	  	switch (lang)
		{
			case hu:
				s="hamis";
				break;
			case en:
				s="false";
				break;
			case ge:
				s="--false--";
				break;
			case fr:
				s="faux";
				break;
			default:
				s="false";
				break;
		}
		s=format(s, fontSize); height=fontSize; computed=true; width+=5.0;
	  }
	  )
	|#(ALPHA {s=format("&alpha; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(BETA {s=format("&beta; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(GAMMA {s=format("&gamma; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(GAMMAG {s=format("&Gamma; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(DELTA {s=format("&delta; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(DELTAG {s=format("&Delta; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(EPSILON {s=format("&epsilon; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(ZETA {s=format("&zeta; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(ETA {s=format("&eta; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(THETA {s=format("&theta; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(THETAG {s=format("&Theta; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(IOTA {s=format("&iota; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(KAPPA {s=format("&kappa; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(LAMBDA {s=format("&lambda; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(LAMBDAG {s=format("&Lambda; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(MU {s=format("&mu; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(NU {s=format("&nu; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(XI {s=format("&xi; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(XIG {s=format("&Xi; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(OMICRON {s=format("&omicron; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(PI {s=format("&pi; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(PIG {s=format("&Pi; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(RHO {s=format("&rho; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(SIGMA {s=format("&sigma; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(SIGMAG {s=format("&Sigma; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(TAU {s=format("&tau; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(UPSILON {s=format("&upsilon; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(UPSILONG {s=format("&Upsilon; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(PHI {s=format("&phi; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(PHIG {s=format("&Phi; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(CHI {s=format("&chi; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(PSI {s=format("&psi; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(PSIG {s=format("&Psi; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(OMEGA {s=format("&omega; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(OMEGAG {s=format("&Omega; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(UNKNOWN {s=std::string(); height=fontSize; computed=true; width+=0.0;})
	|#(NONE {s=std::string(); height=fontSize; computed=true; width+=0.0;})
	|#(INFTY {s=format("&infin; ", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(E {s=format("e", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(I {s=format("i", fontSize); height=fontSize; computed=true; width+=1.0;})
	| (NATURALNUMBERS {s=format("<b>N</b>", fontSize); height=fontSize; computed=true; width+=1.0;})
	| (PRIMES {s=format("<b>P</b>", fontSize); height=fontSize; computed=true; width+=1.0;})
	| (INTEGERS {s=format("<b>Z</b>", fontSize); height=fontSize; computed=true; width+=1.0;})
	| (RATIONALS {s=format("<b>Q</b>", fontSize); height=fontSize; computed=true; width+=1.0;})
	| (REALS {s=format("<b>R</b>", fontSize); height=fontSize; computed=true; width+=1.0;})
	| (COMPLEXES {s=format("<b>C</b>", fontSize); height=fontSize; computed=true; width+=1.0;})
	|#(ENUMERATION {s=std::string(""); int count=0;}
		(
			{
				beforeAFontSize=max(fontSize, beforeAFontSize);
			}
			a=expr
			{
				s+=a;
				switch (enumStrat)
				{
					case normal:
						s+=", ";
						beforeAHeight=max(height, beforeAHeight);
						break;
					case matrixRow:
						s+=tdEnd()+tdCenter();
						beforeAHeight=max(height, beforeAHeight);
						break;
					case matrix:
						s+=trEnd()+trStart()+tdCenter()+tdEnd();
						beforeAHeight+=height;
						break;
					default:
						throw std::exception();
				}
				width+=1.0;
				++count;
			}
		)*
		{
			if (s!="")
			{
				switch (enumStrat)
				{
					case normal:
						s.erase(s.length()-2);
						break;
					case matrixRow:
						s.erase(s.length()-tdEnd().length()-tdCenter().length());
						break;
					case matrix:
						s.erase(s.length()-trEnd().length()-trStart().length()-tdCenter().length()-tdEnd().length());
						break;
					default:
						break;
				}
			}
			width-=1.0;
		}
	  )
	|#(PAIR {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {if (b=="") s=format("&partial; ", size)+a; else s=format("&partial; ", size)+a+b;})//TODO compute width
	|#(lparen:LPAREN {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr
		{
			if (dynamicParentheses)
			{
				if (beautyParentheses)
					switch (#lparen->parenDepth)
					{
						case 1:
							s=tableStart()+tdCenter()+format(" (", height+1)+tdEnd()+tdLeft()+a+tdEnd()+tdCenter()+format(")", height+1)+tableEnd();
						break;
						case 2:
							s=tableStart()+tdCenter()+format(" [", height+1)+tdEnd()+tdLeft()+a+tdEnd()+tdCenter()+format("]", height+1)+tableEnd();
						break;
						default:
							s=tableStart()+tdCenter()+format(" {", height+1)+tdEnd()+tdLeft()+a+tdEnd()+tdCenter()+format("}", height+1)+tableEnd();
						break;
					}
				else
					s=tableStart()+tdCenter()+format(" (", height+1)+tdEnd()+tdLeft()+a+tdEnd()+tdCenter()+format(")", height+1)+tableEnd();
			}
			else
			{
				if (beautyParentheses)
					switch (#lparen->parenDepth)
					{
						case 1:
							s=tableStart()+tdCenter()+" ("+tdEnd()+tdLeft()+a+tdEnd()+tdCenter()+")"+tableEnd();
						break;
						case 2:
							s=tableStart()+tdCenter()+" ["+tdEnd()+tdLeft()+a+tdEnd()+tdCenter()+"]"+tableEnd();
						break;
						default:
							s=tableStart()+tdCenter()+"{"+tdEnd()+tdLeft()+a+tdEnd()+tdCenter()+"}"+tableEnd();
						break;
					}
				else
					s=tableStart()+tdCenter()+" ("+tdEnd()+tdLeft()+a+tdEnd()+tdCenter()+")"+tableEnd();
			}
			computed=true;
			height=height+1;
			width+=2.0;
		}

	)
	|#(LBRACKET {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {if (dynamicParentheses) s=tableStart()+tdCenter()+format(" [", height+1)+tdEnd()+tdLeft()+a+tdEnd()+tdCenter()+format("]", height+1)+tableEnd(); else s=tableStart()+tdCenter()+" ["+tdEnd()+tdLeft()+a+tdEnd()+tdCenter()+"]"+tdEnd()+tableEnd(); computed=true; height=height+1; width+=2.0;})
	|#(VECTOR {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {if (dynamicParentheses) s=tableStart()+tdCenter()+format(" [", height+1)+tdEnd()+tdLeft()+a+tdEnd()+tdCenter()+format("]", height+1)+tableEnd(); else s=tableStart()+tdCenter()+" ["+tdEnd()+tdLeft()+a+tdEnd()+tdCenter()+"]"+tdEnd()+tableEnd(); computed=true; height=height+1; width+=2.0;})
	|#(MATRIXROW {beforeAHeight=height; beforeAFontSize=fontSize;++rowCount;enumStrat=matrixRow;} a=expr {s=tdCenter()+a+tdEnd(); computed=true; height=height+1; width+=2.0;enumStrat=matrix;})
	|#(MATRIX {beforeAHeight=height; beforeAFontSize=fontSize; rowCount=0;enumStrat=matrix;} a=expr {s=tableStart()+tdRight()+format(" (", height+1)+tdEnd()+a/*.substr(tdCenter().length()+tdEnd().length())*/; /*s.resize(s.length()-trEnd().length()-trStart().length());*/ s+=tdLeft()+format(")", height+1)+tdEnd()+tableEnd(); computed=true; height=height+1; width+=2.0; enumStrat=normal;})
	|#(FUNCTION {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=2.0; beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;}
		{
			s=tableStart()+tdRight()+a+"<sup/>"+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();
			lastWasFunction=true;
			locLastWasFunction=true;
		}
	  )
	|#(type:TYPEDEF s=expr {if (#type->getText().find("vector")!=std::string::npos) s=tableStart(" border=\"1\" frame=\"below\" rules=\"none\"")+tdLeft()+s+tdEnd()+tableEnd(); computed=true; width+=0.0;})
	|#(DECLARE {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s="";})
	|#(LAMBDACONSTRUCT {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s="";})
	|#(SIZEOF {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {if (dynamicParentheses && isInSupIndex==0 && isInSubIndex==0) s=tableStart(" border=\"1\" frame=\"vsides\" rules=\"none\"")+tdLeft()+a+tdEnd()+tableEnd(); else s=tableStart()+tdCenter()+" |"+tdEnd()+tdLeft()+a+tdEnd()+tdCenter()+"|"+tdEnd()+tableEnd(); computed=false; height+=1; width+=1.0;})
	|#(ABS {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {if (dynamicParentheses && isInSupIndex==0 && isInSubIndex==0) s=tableStart(" border=\"1\" frame=\"vsides\" rules=\"none\"")+tdLeft()+a+tdEnd()+tableEnd(); else s=tableStart()+tdCenter()+" |"+tdEnd()+tdLeft()+a+tdEnd()+tdCenter()+"|"+tdEnd()+tableEnd(); computed=true; height+=1; width+=1.0;})
	|s=func
	) {if (!computed) {height=max(beforeBHeight, afterBHeight);}}
	{lastWasFunction=locLastWasFunction;}
	;

func returns [string s]
	{
		string a,b;
		double size=fontSize;
		double beforeAHeight=height, beforeBHeight=height, afterBHeight=height;
		double beforeAFontSize=fontSize, beforeBFontSize=fontSize, afterBFontSize=fontSize;
		const string exp="<sup/>";
	}
	:
	(#(SGN {s=format("sgn ", size); width+=3.0;})
	|#(SIN {s=format("sin ", size); width+=3.0;})
	|#(COS {s=format("cos ", size); width+=3.0;})
	|#(TAN
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s=format("tan ", size);
				break;
			case hu:
	  			s=format("tg ", size);
				break;
			default:
				s=format("tan ", size);
				break;
		}
		width+=3.0;
	  })
	|#(SEC {s=format("sec ", size); width+=3.0;})
	|#(COSEC
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s=format("csc ", size);
				break;
			case hu:
	  			s=format("cosec ", size);
				break;
			default:
				s=format("csc ", size);
				break;
		}
		width+=4.0;
	  })
	|#(COT
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s=format("cot ", size);
				break;
			case hu:
	  			s=format("ctg ", size);
				break;
			default:
				s=format("cot ", size);
				break;
		}
		width+=3.0;
	  })
	|#(SINH
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s=format("sinh ", size);
				break;
			case hu:
	  			s=format("sh ", size);
				break;
			default:
				s=format("sinh ", size);
				break;
		}
		width+=3.0;
	  })
	|#(COSH
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s=format("cosh ", size);
				break;
			case hu:
	  			s=format("ch ", size);
				break;
			default:
				s=format("cosh ", size);
				break;
		}
		width+=3.0;
	  })
	|#(TANH
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s=format("tanh ", size);
				break;
			case hu:
	  			s=format("tgh ", size);
				break;
			default:
				s=format("tanh ", size);
				break;
		}
		width+=3.0;
	  })
	|#(SECH {s=format("sech ", size); width+=4.0;})
	|#(COSECH {s=format("cosech ", size); width+=6.0;})
	|#(COTH
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s=format("coth ", size);
				break;
			case hu:
	  			s=format("ctgh ", size);
				break;
			default:
				s=format("coth ", size);
				break;
		}
		width+=4.0;
	  })
	|#(ARCSIN {s=format("arcsin ", size); width+=6.0;})
	|#(ARCCOS {s=format("arccos ", size); width+=6.0;})
	|#(ARCTAN
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s=format("arctan ", size);
				break;
			case hu:
	  			s=format("arctg ", size);
				break;
			default:
				s=format("arctan ", size);
				break;
		}
		width+=6.0;
	  })
	|#(ARCSEC {s=format("arcsec ", size); width+=6.0;})
	|#(ARCCOSEC
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s=format("arccsc ", size);
				break;
			case hu:
	  			s=format("arccosec ", size);
				break;
			default:
				s=format("arccsc ", size);
				break;
		}
		width+=7.0;
	  })
	|#(ARCCOT
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s=format("arccot ", size);
				break;
			case hu:
	  			s=format("arcctg ", size);
				break;
			default:
				s=format("arccot ", size);
				break;
		}
		width+=7.0;
	  })
	|#(ARCSINH
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s=format("arcsinh ", size);
				break;
			case hu:
	  			s=format("arcsh ", size);
				break;
			default:
				s=format("arcsinh ", size);
				break;
		}
		width+=7.0;
	  })
	|#(ARCCOSH
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s=format("arccosh ", size);
				break;
			case hu:
	  			s=format("arcch ", size);
				break;
			default:
				s=format("arccosh ", size);
				break;
		}
		width+=6.0;
	  })
	|#(ARCTANH
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s=format("arctanh ", size);
				break;
			case hu:
	  			s=format("arctgh ", size);
				break;
			default:
				s=format("arctanh ", size);
				break;
		}
		width+=7.0;
	  })
	|#(ARCSECH {s=format("arcsech ", size); width+=7.0;})
	|#(ARCCOSECH
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s=format("arccsch ", size);
				break;
			case hu:
	  			s=format("arccosech ", size);
				break;
			default:
				s=format("arccsch ", size);
				break;
		}
		width+=8.0;
	  })
	|#(ARCCOTH
	  {
	  	switch (lang)
		{
			case en:
			case ge:
			case fr:
				s=format("arccoth ", size);
				break;
			case hu:
	  			s=format("arcctgh ", size);
				break;
			default:
				s=format("arccoth ", size);
				break;
		}
		width+=7.0;
	  })
	|#(ERF {s=format("erf", size); width+=3.0;})
	|#(IM {s=format("&image; ", size); width+=1.0;})
	|#(RE {s=format("&real; ", size); width+=1.0;})
	|#(ARG {s=format("arg ", size); width+=3.0;})
	|#(GCD
		{
			switch (lang)
			{
				case hu:
					s=format("lnko", size);
					break;
				default:
					s=format("gcd", size);
					break;
			}
			width+=3.0;
		})
	|#(LCM
		{
			switch (lang)
			{
				case hu:
					s=format("lkkt", size);
					break;
				default:
					s=format("lcm", size);
					break;
			}
			width+=3.0;
		})
	|#(CONJUGATE {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {s=tableStart(" border=\"1\" frame=\"above\" rules=\"none\"")+tdLeft()+a+tdEnd()+tableEnd(); width+=0.0;})
	|#(TRANSPONATE {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; s=a+"<sup>T</sup>";})
	|#(COMPLEMENTER {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=0.0; s=tableStart(" border=\"1\" frame=\"above\" rules=\"none\"")+tdLeft()+a+tdEnd()+tableEnd();})
	|#(EXP {isInSupIndex++;} {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {--isInSupIndex;} {width+=1.0; s=format("e", size)+supStart()+a+supEnd();})
	|#(LN {s=format("ln ", size); width+=2.0;})
	|#(LG {s=format("lg ", size); width+=2.0;})
	|#(LOG {s=format("log", size);} ({width+=3.0; isInSubIndex++;} {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {isInSubIndex--;} {s+=subStart()+a+subEnd();})?)
	|#(ROOT ({isInSupIndex++;} {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; isInSupIndex--;} {beforeBHeight=height; beforeBFontSize=fontSize;} b=expr {afterBHeight=height; afterBFontSize=fontSize;} {s=tableStart()+tdCenter()+supStart()+a+supEnd()+format("&radic;", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})?)
	|#(SQRT {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.0; s=tableStart()+tdCenter()+format("&radic;", size)+tdEnd()+tdLeft()+b+tdEnd()+tableEnd();})
	|#(CEIL {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.5; s=tableStart()+tdCenter()+format("&lceil; ", size)+tdEnd()+tdLeft()+a+tdEnd()+tdCenter()+format("&rceil; ", size)+tdEnd()+tableEnd();})
	|#(FLOOR {beforeAHeight=height; beforeAFontSize=fontSize;} a=expr {width+=1.5; s=tableStart()+tdCenter()+format("&lfloor; ", size)+tdEnd()+tdLeft()+a+tdEnd()+tdCenter()+format("&rfloor; ", size)+tdEnd()+tableEnd();})
	)
        {lastWasFunction=true;}
	;

