#ifndef FASTCOMPLEXCOMPUTE_H
#define FASTCOMPLEXCOMPUTE_H

#include <h/fccomplexAST.h>
#include <ComplexComputeBoostTokenTypes.hpp>
#include <map>
#include <complex>

template<class T> class FastComplexCompute : ComplexComputeBoostTokenTypes
{
protected:
	T z;
	std::map<std::string, T> vars;
	static T fc_sin(const T &s) {return sin(s);}
	static T fc_cos(const T &s) {return cos(s);}
	static T fc_tan(const T &s) {return tan(s);}
	static T fc_cot(const T &s) {return 1.0/tan(s);}
	static T fc_sec(const T &s) {return 1.0/cos(s);}
	static T fc_csc(const T &s) {return 1.0/sin(s);}
	static T fc_sinh(const T &s) {return sinh(s);}
	static T fc_cosh(const T &s) {return cosh(s);}
	static T fc_tanh(const T &s) {return tanh(s);}
	static T fc_coth(const T &s) {return 1.0/tanh(s);}
	static T fc_sech(const T &s) {return 1.0/cosh(s);}
	static T fc_csch(const T &s) {return 1.0/sinh(s);}
/*	static T fc_asin(const T &s) {return asin(s);}
	static T fc_acos(const T &s) {return acos(s);}
	static T fc_atan(const T &s) {return atan(s);}
	static T fc_acot(const T &s) {return atan(1.0/s);}
	static T fc_asec(const T &s) {return acos(1.0/s);}
	static T fc_acsc(const T &s) {return asin(1.0/s);}*/
	static T fc_exp(const T &s) {return exp(s);}
	static T fc_log(const T &s) {return log(s);}
	static T fc_log10(const T &s) {return log10(s);}
	static T fc_im(const T &s) {return imag(s);}
	static T fc_re(const T &s) {return real(s);}
	static T fc_norm(const T &s) {return abs(s);}
	static T fc_sqrt(const T &s) {return sqrt(s);}
	static T fc_arg(const T &s) {return arg(s);}
	static T fc_conj(const T &s) {return conj(s);}
	typedef T (*punfunc)(const T &);
	punfunc functions[1000];

public:
	void setValue(const T &v)
	{
		z=v;
	}
	void setValue(const std::string &s, const T &v)
	{
		vars[s]=v;
	}
	FastComplexCompute()
	{
		functions[SIN] = &fc_sin;
		functions[COS] = &fc_cos;
		functions[TAN] = &fc_tan;
		functions[COT] = &fc_cot;
		functions[SEC] = &fc_sec;
		functions[COSEC] = &fc_csc;
		functions[SINH] = &fc_sinh;
		functions[COSH] = &fc_cosh;
		functions[TANH] = &fc_tanh;
		functions[COTH] = &fc_coth;
		functions[SECH] = &fc_sech;
		functions[COSECH] = &fc_csch;
/*		functions[ASIN] = &fc_asin;
		functions[ACOS] = &fc_acos;
		functions[ATAN] = &fc_atan;
		functions[ACOT] = &fc_acot;
		functions[ASEC] = &fc_sec;
		functions[ACOSEC] = &fc_acsc;*/
		functions[EXP] = &fc_exp;
		functions[LOG] = &fc_log;
		functions[IM] = &fc_im;
		functions[RE] = &fc_re;
		functions[ABS] = &fc_norm;
		functions[SQRT] = &fc_sqrt;
		functions[ARG] = &fc_arg;
		functions[CONJUGATE] = &fc_conj;
		z=0.0;
	}
	public:
	T inp(antlr::ASTRefCount<FcComputeAST<T> > _t) const
	{
		if (_t!=antlr::nullAST)
		{
			return expr(_t);
		}
		else
		{
			return 0;
		}
	}
	
	public:
	T expr(antlr::ASTRefCount<FcComputeAST<T> > _t) const
	{
		int type=_t->getType();
		if (type<=DIV)
		{
			antlr::ASTRefCount<FcComputeAST<T> > left = _t->getFirstChild(), right = left->getNextSibling();
			T ret0 = expr(left), ret1 = expr(right);
			if (type<=MINUS)
			{
				if (type==PLUS)
				{
					return ret0+ret1;
				}
				else
				{
					return ret0-ret1;
				}
			}
			else
			{
				if (type==MULT)
				{
					return ret0*ret1;
				}
				else
				{
					return ret0/ret1;
				}
			}
		}
		else
		{
			if (type<=NUMBER)
			{
				if (type==CIRCUM)
				{
					antlr::ASTRefCount<FcComputeAST<T> > left = _t->getFirstChild(), right = left->getNextSibling();
					T ret0 = expr(left), ret1 = expr(right);
					return pow(ret0, ret1);
				}
				else
				{
					return _t->value;
				}
			}
			else
			{
				if (type==PARAMETER)
				{
					return z;
				}
				else
				{
					if (type>=VARIABLE)
					{
						if (type==VARIABLE)
						{
							return (vars.find(_t->getText()))->second;
						}
						else
						if (type==NEG)
						{
							antlr::ASTRefCount<FcComputeAST<T> > left = _t->getFirstChild();
							return -expr(left);
						}
					}
					else
					{
						antlr::ASTRefCount<FcComputeAST<T> > left = _t->getFirstChild();
						return (*functions[type])(expr(left));
					}
				}
			}
		}
		return 0.0; //TODO Search the problem. This shouldn't be here...
	}
};

#endif
