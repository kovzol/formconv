#ifndef STRINGHU_H
#define STRINGHU_H

#include <string>
#include <iostream>

struct stringhu
{
	enum ragok {NOT_ALLOWED, NONE, VAL, SZOR, BOL, DIK, DIKON, ES, RA, NAK};
	enum hangrend {MELYHANGRENDU, VEGYESHANGRENDU, MAGASHANGRENDU}; //Nem pontos a megnevezés, inkább a végére koncentrál...
        enum nevelo {NINCS, AZ, EGY};
	enum letter {A, AA, B, C, CS, D, DZ, DZS, E, EE, F, G, GY, H, I, II, J, K, L, LY, M, N, NY, O, OO, OE, OEOE, P, Q, R, S, SZ, T, TY, U, UU, UE, UEUE, V, W, X, Y, Z, ZS};
	enum expressionlength {ZERO, ONE, TWO, THREE, MORE};
	enum type {SZAM, OSSZEG, KULONBSEG, SZORZAT, HATVANY, HANYADOS, OSSZETETT};
	
	std::string kitevo, egeszresz, tortresz;
	ragok r;
	hangrend hr;
	letter last;
	expressionlength el;
	nevelo ne;
	type t;
	
	void sethangrend();
	void setletters();
//	void ragoz();
	void ragoz(const ragok r);
	void ragoz(const nevelo n);


	stringhu();
	stringhu(const std::string s);
	stringhu(const char *s);
	stringhu(const stringhu &sd);
	std::string str;
	friend std::ostream& operator<<(std::ostream& os, const stringhu& sd);
	stringhu& operator+(const std::string s);
	friend stringhu& operator+(const std::string s, stringhu &sd);
	friend stringhu& operator+(const char *s, stringhu &sd);
	stringhu& operator+(stringhu &sd);
	stringhu& operator=(const stringhu &sd);
	stringhu& operator+=(const stringhu &s);
	stringhu& operator+=(const char *s);
	bool operator==(const char *s);
};

#endif
