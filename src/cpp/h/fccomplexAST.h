#ifndef FCCOMPLEXAST
#define FCCOMPLEXAST

#include <antlr/CommonAST.hpp>
#include <string>
#include <complex>

#define REFFCCOMPLEXAST RefFcComplexAST

//template <class T> class FcComputeAST<T>;

///AST type for IntuitiveParser
template <class T> class FcComputeAST : public ANTLR_USE_NAMESPACE(antlr)CommonAST
{
	public:
		//copy constructor
		FcComputeAST<T>(const FcComputeAST<T> &t) : CommonAST(t), value(t.value)
		{
		}

		//default constructor
		FcComputeAST<T>() : CommonAST(), value(0)
		{
		}
		
		virtual ~FcComputeAST<T>()
		{
		}
		
		virtual void initialize(int t, const ANTLR_USE_NAMESPACE(std)string &txt)
		{
			CommonAST::initialize(t, txt);
			value=0;
		}
		
		virtual void initialize(ANTLR_USE_NAMESPACE(antlr)RefToken t)
		{
			CommonAST::initialize(t);
			value=0;
		}
		
		virtual void initialize(ANTLR_USE_NAMESPACE(antlr)RefAST t)
		{
			CommonAST::initialize(t);
			value=0;
		}
		
		virtual void initialize(antlr::ASTRefCount<FcComputeAST<T> > t)
		{
			CommonAST::initialize((antlr::RefAST)t);
			value=t->value;
		}
		
		void addChild(antlr::ASTRefCount<FcComputeAST<T> > t)
		{
			BaseAST::addChild(ANTLR_USE_NAMESPACE(antlr)RefAST(t));
		}
		
		void setFirstChild(antlr::ASTRefCount<FcComputeAST<T> > t)
		{
			BaseAST::setFirstChild(ANTLR_USE_NAMESPACE(antlr)RefAST(t));
		}
		
		void setFirstChild(ANTLR_USE_NAMESPACE(antlr)RefAST t)
		{
			BaseAST::setFirstChild(t);
		}
		
		void setNextSibling(antlr::ASTRefCount<FcComputeAST<T> > t)
		{
			BaseAST::setNextSibling(ANTLR_USE_NAMESPACE(antlr)RefAST(t));
		}
		
		void setNextSibling(ANTLR_USE_NAMESPACE(antlr)RefAST t)
		{
			BaseAST::setNextSibling(t);
		}
		
		antlr::ASTRefCount<FcComputeAST<T> > getFirstChild()
		{
			return antlr::ASTRefCount<FcComputeAST<T> >(down);
		}
		
		antlr::ASTRefCount<FcComputeAST<T> > getNextSibling()
		{
			return antlr::ASTRefCount<FcComputeAST<T> >(right);
		}
		
/*		std::string toString()
		{
			return text;
		}
*/		
		virtual ANTLR_USE_NAMESPACE(antlr)RefAST clone()
		{
			return ANTLR_USE_NAMESPACE(antlr)RefAST(new FcComputeAST<T> (*this));
		}
		
		static ANTLR_USE_NAMESPACE(antlr)RefAST factory()
		{
			return ANTLR_USE_NAMESPACE(antlr)RefAST(antlr::ASTRefCount<FcComputeAST<T> >(new FcComputeAST<T> ()));
		}
		
		T value;
};
typedef ANTLR_USE_NAMESPACE(antlr)ASTRefCount<FcComputeAST<std::complex<double> > > RefFcComplexAST;
typedef FcComputeAST<std::complex<double> > FcComplexAST;
//template <class T> typedef ANTLR_USE_NAMESPACE(antlr)ASTRefCount<FcComputeAST<std::complex<T> > > RefFcComputeAST<T>;


#endif
