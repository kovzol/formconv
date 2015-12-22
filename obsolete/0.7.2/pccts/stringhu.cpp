#include "stringhu.h"

stringhu::stringhu():str("")
{}

stringhu::stringhu(const std::string s): str(s)
{}

stringhu::stringhu(const char *s):str(s)
{}

stringhu::stringhu(const stringhu &sd):str(sd.str), r(sd.r), ne(sd.ne), hr(sd.hr), last(sd.last), el(sd.el), t(sd.t)
{}

std::ostream& operator<<(std::ostream& os, const stringhu& sd)
{
	return os << sd.str;
}

stringhu& stringhu::operator+(const std::string s)
{
	str+=s;
	return *this;
}

stringhu& operator+(const std::string s, stringhu &sd)
{
	sd.str=s+sd.str;
	return sd;
}

stringhu& operator+(const char *s, stringhu &sd)
{
	sd.str=s+sd.str;
	return sd;
}

stringhu& stringhu::operator+(stringhu &sd)
{
	str+=sd.str;
	return *this;
}

stringhu& stringhu::operator=(const stringhu &sd)
{
	str=sd.str;
}

stringhu& stringhu::operator+=(const stringhu &s)
{
	str+=s.str;
	return *this;
}

stringhu& stringhu::operator+=(const char *s)
{
	str+=s;
	return *this;
}

bool stringhu::operator==(const char *s)
{
	return str==s;
}

void stringhu::sethangrend()
{
	switch (str[str.find_last_of("aáeéiíoóöõuúüû")])
	{
		case 'a':
		case 'á':
		case 'o':
		case 'ó':
		case 'u':
		case 'ú':
			hr=MELYHANGRENDU; break;
		case 'ö':
		case 'õ':
			hr=VEGYESHANGRENDU; break;
		default:
			hr=MAGASHANGRENDU; break;
	}
}

void stringhu::ragoz(const ragok ru)
{
	int l=str.length();
	if (r==NONE)
	{
		r=ru;
		switch (r)
		{
			case NONE:
				break;
			case VAL:
				sethangrend();
				switch (str[l-1])
				{
					case 'y':
						switch (str[l-2])
						{
							case 'g': if (hr==MELYHANGRENDU) str+="gyal";
									  else str+="gyel";
								  break;
							case 'l': if (hr==MELYHANGRENDU) str+="lyal";
									  else str+="lyel";
								  break;
							case 't': if (hr==MELYHANGRENDU) str+="tyal";
									  else str+="tyel";
								  break;
						}
						break;
					case 's':
						switch (str[l-2])
						{
							case 'c': if (hr==MELYHANGRENDU) str+="csal";
									  else str+="csel";
								  break;
							case 'z': if (hr==MELYHANGRENDU) str+="zsal"; //dzs-re ne végzõdjön semmi sem.:-)
									  else str+="zsel";
								  break;
							default: if (hr==MELYHANGRENDU) str+="sal";
									  else str+="sel";
								  break;
						}
						break;
					case 'z':
						switch (str[l-2])
						{
							case 's': if (hr==MELYHANGRENDU) str+="szal";
									  else str+="szel";
								  break;
							default: if (hr==MELYHANGRENDU) str+="zal";
									  else str+="zel";
								  break;
						}
						break;
					case 'a':
					case 'á':
					case 'e':
					case 'é':
					case 'i':
					case 'í':
					case 'o':
					case 'ó':
					case 'ö':
					case 'õ':
					case 'u':
					case 'ú':
					case 'ü':
					case 'û':
					{
						if (hr==MELYHANGRENDU)
							str+="val";
						else str+="vel";
					}
					break;
					default:
					{
						str+=str[l-1];
						if (hr==MELYHANGRENDU)
							str+="al";
						else str+="el";
					}
					break;
				}
				break;
			case BOL:
				sethangrend();
				switch (hr)
				{
					case MELYHANGRENDU:
						if (str.find_last_of('a')==l-1) str[l-1]='á';
						str+="ból"; break;
					case VEGYESHANGRENDU:
					case MAGASHANGRENDU:
						str+="bõl"; break;
				}
				break;
			case SZOR:
				sethangrend();
				switch (hr)
				{
					case MAGASHANGRENDU:
						str+="szer"; break;
					case VEGYESHANGRENDU:
						str+="ször"; break;
					case MELYHANGRENDU:
						if (str.find_last_of('a')==l-1) str[l-1]='á';
						str+="szor"; break;
				}
				break;
			case DIKON:
			case DIK:
			{
				int l=str.length();
				if (l>4 && str.substr(l-5)=="dikon")
				{
					str+="adikon";
				} else
				if (l>4 && str.substr(l-5)=="diken")
				{
					str+="ediken";
				} else
				if (l>4 && str.substr(l-5)=="nulla")
				{
					str+="dikon";
				} else
				if (l>2 && str.substr(l-3)=="egy")
				{
					str=str.substr(0,l-3);
					if (l==3) str+="elsõn";
					else str+="egyediken";
				} else
				if (l>4 && str.substr(l-5)=="kettõ")
				{
					str=str.substr(0,l-5);
					if (l==5) str+="másodikon"; // lehetne vsz. négyzeten is.
					else str+="kettediken";
				} else
				if (l>4 && str.substr(l-5)=="három")
				{
					str=str.substr(0,l-5);
					str+="harmadikon";
				} else
				if (l>3 && str.substr(l-4)=="négy")
				{
					str[l-3]='e';
					str+="ediken";
				} else
				if (l>1 && str.substr(l-2)=="öt")
				{
					str+="ödiken";
				} else
				if (l>2 && str.substr(l-3)=="hat")
				{
					str+="odikon";
				} else
				if (l>2 && str.substr(l-3)=="hét")
				{
					str[l-2]='e';
					str+="ediken";
				} else
				if (l>4 && str.substr(l-5)=="nyolc")
				{
					str+="adikon";
				} else
				if (l>5 && str.substr(l-6)=="kilenc")
				{
					str+="ediken";
				} else
				if (l>2 && str.substr(l-3)=="tíz")
				{
					str[l-2]='i';
					str+="ediken";
				} else
				if (l>3 && str.substr(l-4)=="húsz")
				{
					str[l-3]='u';
					str+="adikon";
				} else
				if (l>6 && str.substr(l-7)=="harminc")
				{
					str+="adikon";
				} else
				if (l>6 && str.substr(l-7)=="negyven")
				{
					str+="ediken";
				} else
				if (l>4 && str.substr(l-5)=="ötven")
				{
					str+="ediken";
				} else
				if (l>5 && str.substr(l-6)=="hatvan")
				{
					str+="adikon";
				} else
				if (l>5 && str.substr(l-6)=="hetven")
				{
					str+="ediken";
				} else
				if (l>7 && str.substr(l-8)=="nyolcvan")
				{
					str+="adikon";
				} else
				if (l>8 && str.substr(l-9)=="kilencven")
				{
					str+="ediken";
				} else
				if (l>3 && str.substr(l-4)=="száz")
				{
					str+="adikon";
				} else
				if (l>3 && str.substr(l-4)=="ezer")
				{
					str=str.substr(0, l-4);
					str+="ezrediken";
				} else
				if (l>4 && str.substr(l-5)=="illió")
				{
					str[l-1]='o';
					str+="modikon";
				} else 
				{
                    sethangrend();
					if (hr==MELYHANGRENDU)
						str+="adikon";
					else str+="ediken";
				}
				if (r==DIK)
				{
					if (str=="elsõn")
						str="elsõ";
					else str=str.substr(0, str.find_last_of('k')+1);
				}
//                                std::cout << "dikon: " << str << std::endl;
				break;
			}
			case NAK:
				sethangrend();
				switch (hr)
				{
					case MELYHANGRENDU: str+="nak"; break;
					case MAGASHANGRENDU:
					case VEGYESHANGRENDU: str+="nek"; break;
					default: break;
				}
				break;
			case RA:
				sethangrend();
				switch (hr)
				{
					case MELYHANGRENDU: str+="ra"; break;
					case MAGASHANGRENDU:
					case VEGYESHANGRENDU: str+="re"; break;
					default: break;
				}
				break;
		}
	}
}

void stringhu::ragoz(const nevelo n)
{
	if (ne==NINCS)
		switch (n)
		{
			case NINCS:
				ne=NINCS;
				break;
			case AZ:
			{
				int i=0;
				while (str[i]==' ' || str[i]=='\t') ++i;
				switch (str[i])
				{
					case 'a':
					case 'á':
					case 'A':
					case 'Á':
					case 'e':
					case 'é':
					case 'E':
					case 'É':
					case 'i':
					case 'í':
					case 'I':
					case 'Í':
					case 'o':
					case 'ó':
					case 'ö':
					case 'õ':
					case 'O':
					case 'Ó':
					case 'Ö':
					case 'Õ':
					case 'u':
					case 'ú':
					case 'ü':
					case 'û':
					case 'U':
					case 'Ú':
					case 'Ü':
					case 'Û':
						str="az "+str; break;
					default: str="a "+str; break;
				}
			}
			break;
			case EGY:
			{
				str="egy "+str; break;
			}
			break;
		}
}

