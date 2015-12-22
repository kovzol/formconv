#include <h/misc.h>

//Helper function for getting the Language type from a string
namespace formconvLanguage {
Language getLanguage(const std::string &s)
{
	if (s=="C")
		return C;
	else if (s=="en" || s=="english")
		return en;
	else if (s=="hu" || s=="hungarian")
		return hu;
	else if (s=="ge" || s=="german")
		return ge;
	else if (s=="fr" || s=="france")
		return fr;
	else if (s=="simple")
		return simple;
	else return C;
}
}
