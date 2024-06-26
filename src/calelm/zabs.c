/* zabs.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

/*DECK ZABS 
 */
double nsp_calpack_zabs (double *zr, double *zi)
{
  /* System generated locals */
  double ret_val;

  /* Builtin functions */
  double sqrt (double);

  /* Local variables */
  double q, s, u, v;

  /****BEGIN PROLOGUE  ZABS 
   ****SUBSIDIARY 
   ****PURPOSE  Subsidiary to ZBESH, ZBESI, ZBESJ, ZBESK, ZBESY, ZAIRY and 
   *           ZBIRY 
   ****LIBRARY   SLATEC 
   ****TYPE      ALL (ZABS-A) 
   ****AUTHOR  Amos, D. E., (SNL) 
   ****DESCRIPTION 
   * 
   *    ZABS COMPUTES THE ABSOLUTE VALUE OR MAGNITUDE OF A DOUBLE 
   *    PRECISION COMPLEX VARIABLE CMPLX(ZR,ZI) 
   * 
   ****SEE ALSO  ZAIRY, ZBESH, ZBESI, ZBESJ, ZBESK, ZBESY, ZBIRY 
   ****ROUTINES CALLED  (NONE) 
   ****REVISION HISTORY  (YYMMDD) 
   *  830501  DATE WRITTEN 
   *  910415  Prologue converted to Version 4.0 format.  (BAB) 
   ****END PROLOGUE  ZABS 
   ****FIRST EXECUTABLE STATEMENT  ZABS 
   */
  u = Abs (*zr);
  v = Abs (*zi);
  s = u + v;
  /*----------------------------------------------------------------------- 
   *    S*1.0D0 MAKES AN UNNORMALIZED UNDERFLOW ON CDC MACHINES INTO A 
   *    TRUE FLOATING ZERO 
   *----------------------------------------------------------------------- 
   */
  s *= 1.;
  if (s == 0.)
    {
      goto L20;
    }
  if (u > v)
    {
      goto L10;
    }
  q = u / v;
  ret_val = v * sqrt (q * q + 1.);
  return ret_val;
L10:
  q = v / u;
  ret_val = u * sqrt (q * q + 1.);
  return ret_val;
L20:
  ret_val = 0.;
  return ret_val;
}				/* zabs_ */
