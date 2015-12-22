#ifndef UTILITY_DATASTRUCTURES
#define UTILITY_DATASTRUCTURES
#include <string>
using std::string;

struct data
{
	data(char d=0);
	data(string g);
	data(string *g);
	data(char *c);
	~data();
	char depth;
	string *s;//Do NOT delete!!! The destructor will! (Sorry it is easier if it is public.)
};

void numberchange(std::string &s, const char point, const char delimiter);

#endif

