#ifndef FCAST
#define FCAST

#include <antlr/CommonAST.hpp>
#include <string>
#include <cstdio>

#define REFFCAST RefFcAST

///Rough type for the IntuitiveParser
typedef enum RoughType {notset, unknown, number, fc_set, logical, function} RoughType;

class FcAST;

typedef ANTLR_USE_NAMESPACE(antlr)ASTRefCount<FcAST> RefFcAST;

///AST type for IntuitiveParser
class FcAST : public ANTLR_USE_NAMESPACE(antlr)CommonAST
{
	public:
		//copy constructor
		FcAST(const FcAST &t) : CommonAST(t), typeName(t.typeName)
		{
			roughType=t.roughType;
		}

		//default constructor
		FcAST() : CommonAST(), typeName("")
		{
			roughType=notset;
		}
		
/*		FcAST(const ANTLR_USE_NAMESPACE(antlr)CommonAST &t) : CommonAST(t), typeName("")
		{
			roughType=notset;
		}
*/		
		virtual ~FcAST()
		{
		}
		
		virtual void initialize(int t, const ANTLR_USE_NAMESPACE(std)string &txt)
		{
			CommonAST::initialize(t, txt);
			roughType=notset;
			parenDepth=0;
			typeName=ANTLR_USE_NAMESPACE(std)string("notset");
		}
		
		virtual void initialize(ANTLR_USE_NAMESPACE(antlr)RefToken t)
		{
			CommonAST::initialize(t);
/*			roughType=t.roughType;
			typeName=t.typeName;
			parenDepth=t.parenDepth;*/
		}
		
		virtual void initialize(ANTLR_USE_NAMESPACE(antlr)RefAST t)
		{
			CommonAST::initialize(t);
/*			roughType=((FcAST)*t).roughType;
			typeName=((FcAST)*t).typeName;
			parenDepth=t.parenDepth;*/
		}
		
		virtual void initialize(RefFcAST t)
		{
			CommonAST::initialize((antlr::RefAST)t);
			roughType=t->roughType;
			typeName=t->typeName;
			parenDepth=t->parenDepth;
		}
		
		void addChild(RefFcAST t)
		{
			BaseAST::addChild(ANTLR_USE_NAMESPACE(antlr)RefAST(t));
		}
		
		void setFirstChild(RefFcAST t)
		{
			BaseAST::setFirstChild(ANTLR_USE_NAMESPACE(antlr)RefAST(t));
		}
		
		void setFirstChild(ANTLR_USE_NAMESPACE(antlr)RefAST t)
		{
			BaseAST::setFirstChild(t);
		}
		
		void setNextSibling(RefFcAST t)
		{
			BaseAST::setNextSibling(ANTLR_USE_NAMESPACE(antlr)RefAST(t));
		}
		
		void setNextSibling(ANTLR_USE_NAMESPACE(antlr)RefAST t)
		{
			BaseAST::setNextSibling(t);
		}
		
		RefFcAST getFirstChild()
		{
			return RefFcAST(down);
		}
		
		RefFcAST getNextSibling()
		{
			return RefFcAST(right);
		}
		
		std::string toString()
		{
			return "["+text+", "+FcAST::Type(roughType)+"]";
		}
		
		virtual ANTLR_USE_NAMESPACE(antlr)RefAST clone()
		{
			return ANTLR_USE_NAMESPACE(antlr)RefAST(new FcAST(*this));
		}
		
		static ANTLR_USE_NAMESPACE(antlr)RefAST factory()
		{
			return ANTLR_USE_NAMESPACE(antlr)RefAST(RefFcAST(new FcAST()));
		}

		static std::string Type(RoughType t0)
		{
			switch (t0) {
				case unknown: return std::string("unknown"); break;
				case number: return std::string("number"); break;
				case fc_set: return std::string("set"); break;
				case logical: return std::string("logical"); break;
				case function: return std::string("function"); break;
				case notset: return std::string("notset"); break;
				default: return std::string("nem tudom");
			}
		}

		static void printType(RoughType t0)
		{
//			puts(s);
			switch (t0) {
				case unknown: puts("unknown"); break;
				case number: puts("number"); break;
				case fc_set: puts("set"); break;
				case logical: puts("logical"); break;
				case function: puts("function"); break;
				case notset: puts("notset"); break;
				default: puts("nem tudom");
			}
		}


		RoughType roughType;
		std::string typeName;
		unsigned int parenDepth;
};
#endif
