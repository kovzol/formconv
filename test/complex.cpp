/*
 * Demo program which shows the power of the libformconv library.
 * Written by Z. Kovacs, modifications by G. Bakos.
 * Copyright (C) 2004-2005 Z. Kovacs, G. Bakos.
 */

#include <h/fastcompute.h>

int
main (int argc, char **argv)
{
  char myFormula[50];
  formula < FastComplexCompute < std::complex < double > > >*f;
  complex < double >c;
  double i, j, re, im;
  strcpy (myFormula, "sinz^2");
  f =
    formconv_prepare < FastComplexCompute < std::complex < double 
      > > >(myFormula);
  for (i = 0; i < 1; i += 0.3)
    {
      for (j = 0; j < 1; j += 0.3)
	{
	  c = complex < double >(i, j);
	  c =
	    formconv_evaluate < FastComplexCompute < std::complex <
	      double > > >(f, c);
	  re = real (c);
	  im = imag (c);
	  printf ("%5.3f+%5.3f*I ", re, im);
	}
      printf ("\n");
    }
  formconv_free < FastComplexCompute < std::complex < double > > >(f);
}
