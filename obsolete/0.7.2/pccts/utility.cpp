#include "utility.h"

data::data(char d):depth(d), s(NULL) {}

data::data(string g):s(&g),depth(0) {}

data::data(string *g):s(g),depth(0) {}

data::data(char *c):s(new string(c)),depth(0) {}

data::~data()
{
	if (s!=NULL) delete s;
}

void numberchange(std::string &s, const char point, const char delimiter)
{
	int p,pos=s.find("."), l=s.length();
	if (pos!=std::string::npos) s[pos]=point;
	else pos=l;
	p=pos+1;
	while (p+3<l)
	{
		++l;
		s.insert(p+3,1,delimiter);
		p+=4;
	}
	while (pos-3>0)
	{
		s.insert(pos-3, 1, delimiter);
		pos-=3;
	}
}

