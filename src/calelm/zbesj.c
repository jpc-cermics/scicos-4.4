/* zbesj.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

/* Table of constant values */

static int c__4 = 4;
static int c__15 = 15;
static int c__16 = 16;
static int c__5 = 5;
static int c__14 = 14;
static int c__9 = 9;
static int c__1 = 1;

/*DECK ZBESJ 
 */
int
nsp_calpack_zbesj (double *zr, double *zi, double *fnu, int *kode, int *n,
		   double *cyr, double *cyi, int *nz, int *ierr)
{
  /* Initialized data */

  static double hpi = 1.57079632679489662;

  /* System generated locals */
  int i__1, i__2;
  double d__1, d__2;

  /* Builtin functions */
  double sqrt (double), cos (double), sin (double);

  /* Local variables */
  double alim, elim;
  double atol;
  int inuh;
  double fnul, rtol;
  int i__, k;
  double ascle, csgni, csgnr;
  int k1;
  int k2;
  double aa, bb, fn;
  int nl;
  double az;
  int ir;
  double rl, dig, cii, arg, r1m5;
  int inu;
  double tol, sti, zni, str, znr;

  /****BEGIN PROLOGUE  ZBESJ 
   ****PURPOSE  Compute a sequence of the Bessel functions J(a,z) for 
   *           complex argument z and real nonnegative orders a=b,b+1, 
   *           b+2,... where b>0.  A scaling option is available to 
   *           help avoid overflow. 
   ****LIBRARY   SLATEC 
   ****CATEGORY  C10A4 
   ****TYPE      COMPLEX (CBESJ-C, ZBESJ-C) 
   ****KEYWORDS  BESSEL FUNCTIONS OF COMPLEX ARGUMENT, 
   *            BESSEL FUNCTIONS OF THE FIRST KIND, J BESSEL FUNCTIONS 
   ****AUTHOR  Amos, D. E., (SNL) 
   ****DESCRIPTION 
   * 
   *                     ***A DOUBLE PRECISION ROUTINE*** 
   *        On KODE=1, ZBESJ computes an N member sequence of complex 
   *        Bessel functions CY(L)=J(FNU+L-1,Z) for real nonnegative 
   *        orders FNU+L-1, L=1,...,N and complex Z in the cut plane 
   *        -pi<arg(Z)<=pi where Z=ZR+i*ZI.  On KODE=2, CBESJ returns 
   *        the scaled functions 
   * 
   *           CY(L) = exp(-abs(Y))*J(FNU+L-1,Z),  L=1,...,N and Y=Im(Z) 
   * 
   *        which remove the exponential growth in both the upper and 
   *        lower half planes as Z goes to infinity.  Definitions and 
   *        notation are found in the NBS Handbook of Mathematical 
   *        Functions (Ref. 1). 
   * 
   *        Input 
   *          ZR     - DOUBLE PRECISION real part of argument Z 
   *          ZI     - DOUBLE PRECISION imag part of argument Z 
   *          FNU    - DOUBLE PRECISION initial order, FNU>=0 
   *          KODE   - A parameter to indicate the scaling option 
   *                   KODE=1  returns 
   *                           CY(L)=J(FNU+L-1,Z), L=1,...,N 
   *                       =2  returns 
   *                           CY(L)=J(FNU+L-1,Z)*exp(-abs(Y)), L=1,...,N 
   *                           where Y=Im(Z) 
   *          N      - Number of terms in the sequence, N>=1 
   * 
   *        Output 
   *          CYR    - DOUBLE PRECISION real part of result vector 
   *          CYI    - DOUBLE PRECISION imag part of result vector 
   *          NZ     - Number of underflows set to zero 
   *                   NZ=0    Normal return 
   *                   NZ>0    CY(L)=0, L=N-NZ+1,...,N 
   *          IERR   - Error flag 
   *                   IERR=0  Normal return     - COMPUTATION COMPLETED 
   *                   IERR=1  Input error       - NO COMPUTATION 
   *                   IERR=2  Overflow          - NO COMPUTATION 
   *                           (Im(Z) too large on KODE=1) 
   *                   IERR=3  Precision warning - COMPUTATION COMPLETED 
   *                           (Result has half precision or less 
   *                           because Abs(Z) or FNU+N-1 is large) 
   *                   IERR=4  Precision error   - NO COMPUTATION 
   *                           (Result has no precision because 
   *                           Abs(Z) or FNU+N-1 is too large) 
   *                   IERR=5  Algorithmic error - NO COMPUTATION 
   *                           (Termination condition not met) 
   * 
   **Long Description: 
   * 
   *        The computation is carried out by the formulae 
   * 
   *           J(a,z) = exp( a*pi*i/2)*I(a,-i*z),  Im(z)>=0 
   * 
   *           J(a,z) = exp(-a*pi*i/2)*I(a, i*z),  Im(z)<0 
   * 
   *        where the I Bessel function is computed as described in the 
   *        prologue to CBESI. 
   * 
   *        For negative orders, the formula 
   * 
   *           J(-a,z) = J(a,z)*cos(a*pi) - Y(a,z)*sin(a*pi) 
   * 
   *        can be used.  However, for large orders close to ints, the 
   *        the function changes radically.  When a is a large positive 
   *        int, the magnitude of J(-a,z)=J(a,z)*cos(a*pi) is a 
   *        large negative power of ten.  But when a is not an int, 
   *        Y(a,z) dominates in magnitude with a large positive power of 
   *        ten and the most that the second term can be reduced is by 
   *        unit roundoff from the coefficient.  Thus, wide changes can 
   *        occur within unit roundoff of a large int for a.  Here, 
   *        large means a>abs(z). 
   * 
   *        In most complex variable computation, one must evaluate ele- 
   *        mentary functions.  When the magnitude of Z or FNU+N-1 is 
   *        large, losses of significance by argument reduction occur. 
   *        Consequently, if either one exceeds U1=SQRT(0.5/UR), then 
   *        losses exceeding half precision are likely and an error flag 
   *        IERR=3 is triggered where UR=MAX(D1MACH(4),1.0D-18) is double 
   *        precision unit roundoff limited to 18 digits precision.  Also, 
   *        if either is larger than U2=0.5/UR, then all significance is 
   *        lost and IERR=4.  In order to use the INT function, arguments 
   *        must be further restricted not to exceed the largest machine 
   *        int, U3=I1MACH(9).  Thus, the magnitude of Z and FNU+N-1 
   *        is restricted by MIN(U2,U3).  In IEEE arithmetic, U1,U2, and 
   *        U3 approximate 2.0E+3, 4.2E+6, 2.1E+9 in single precision 
   *        and 4.7E+7, 2.3E+15 and 2.1E+9 in double precision.  This 
   *        makes U2 limiting in single precision and U3 limiting in 
   *        double precision.  This means that one can expect to retain, 
   *        in the worst cases on IEEE machines, no digits in single pre- 
   *        cision and only 6 digits in double precision.  Similar con- 
   *        siderations hold for other machines. 
   * 
   *        The approximate relative error in the magnitude of a complex 
   *        Bessel function can be expressed as P*10**S where P=MAX(UNIT 
   *        ROUNDOFF,1.0E-18) is the nominal precision and 10**S repre- 
   *        sents the increase in error due to argument reduction in the 
   *        elementary functions.  Here, S=MAX(1,ABS(LOG10(ABS(Z))), 
   *        ABS(LOG10(FNU))) approximately (i.e., S=MAX(1,ABS(EXPONENT OF 
   *        ABS(Z),ABS(EXPONENT OF FNU)) ).  However, the phase angle may 
   *        have only absolute accuracy.  This is most likely to occur 
   *        when one component (in magnitude) is larger than the other by 
   *        several orders of magnitude.  If one component is 10**K larger 
   *        than the other, then one can expect only MAX(ABS(LOG10(P))-K, 
   *        0) significant digits; or, stated another way, when K exceeds 
   *        the exponent of P, no significant digits remain in the smaller 
   *        component.  However, the phase angle retains absolute accuracy 
   *        because, in complex arithmetic with precision P, the smaller 
   *        component will not (as a rule) decrease below P times the 
   *        magnitude of the larger component.  In these extreme cases, 
   *        the principal phase angle is on the order of +P, -P, PI/2-P, 
   *        or -PI/2+P. 
   * 
   ****REFERENCES  1. M. Abramowitz and I. A. Stegun, Handbook of Mathe- 
   *                matical Functions, National Bureau of Standards 
   *                Applied Mathematics Series 55, U. S. Department 
   *                of Commerce, Tenth Printing (1972) or later. 
   *              2. D. E. Amos, Computation of Bessel Functions of 
   *                Complex Argument, Report SAND83-0086, Sandia National 
   *                Laboratories, Albuquerque, NM, May 1983. 
   *              3. D. E. Amos, Computation of Bessel Functions of 
   *                Complex Argument and Large Order, Report SAND83-0643, 
   *                Sandia National Laboratories, Albuquerque, NM, May 
   *                1983. 
   *              4. D. E. Amos, A Subroutine Package for Bessel Functions 
   *                of a Complex Argument and Nonnegative Order, Report 
   *                SAND85-1018, Sandia National Laboratory, Albuquerque, 
   *                NM, May 1985. 
   *              5. D. E. Amos, A portable package for Bessel functions 
   *                of a complex argument and nonnegative order, ACM 
   *                Transactions on Mathematical Software, 12 (September 
   *                1986), pp. 265-273. 
   * 
   ****ROUTINES CALLED  D1MACH, I1MACH, ZABS, ZBINU 
   ****REVISION HISTORY  (YYMMDD) 
   *  830501  DATE WRITTEN 
   *  890801  REVISION DATE from Version 3.2 
   *  910415  Prologue converted to Version 4.0 format.  (BAB) 
   *  920128  Category corrected.  (WRB) 
   *  920811  Prologue revised.  (DWL) 
   ****END PROLOGUE  ZBESJ 
   * 
   *    COMPLEX CI,CSGN,CY,Z,ZN 
   */
  /* Parameter adjustments */
  --cyi;
  --cyr;

  /* Function Body */
  /* 
   ****FIRST EXECUTABLE STATEMENT  ZBESJ 
   */
  *ierr = 0;
  *nz = 0;
  if (*fnu < 0.)
    {
      *ierr = 1;
    }
  if (*kode < 1 || *kode > 2)
    {
      *ierr = 1;
    }
  if (*n < 1)
    {
      *ierr = 1;
    }
  if (*ierr != 0)
    {
      return 0;
    }
  /*----------------------------------------------------------------------- 
   *    SET PARAMETERS RELATED TO MACHINE CONSTANTS. 
   *    TOL IS THE APPROXIMATE UNIT ROUNDOFF LIMITED TO 1.0E-18. 
   *    ELIM IS THE APPROXIMATE EXPONENTIAL OVER- AND UNDERFLOW LIMIT. 
   *    EXP(-ELIM).LT.EXP(-ALIM)=EXP(-ELIM)/TOL    AND 
   *    EXP(ELIM).GT.EXP(ALIM)=EXP(ELIM)*TOL       ARE INTERVALS NEAR 
   *    UNDERFLOW AND OVERFLOW LIMITS WHERE SCALED ARITHMETIC IS DONE. 
   *    RL IS THE LOWER BOUNDARY OF THE ASYMPTOTIC EXPANSION FOR LARGE Z. 
   *    DIG = NUMBER OF BASE 10 DIGITS IN TOL = 10**(-DIG). 
   *    FNUL IS THE LOWER BOUNDARY OF THE ASYMPTOTIC SERIES FOR LARGE FNU. 
   *----------------------------------------------------------------------- 
   *Computing MAX 
   */
  d__1 = nsp_calpack_d1mach (&c__4);
  tol = Max (d__1, 1e-18);
  k1 = nsp_calpack_i1mach (&c__15);
  k2 = nsp_calpack_i1mach (&c__16);
  r1m5 = nsp_calpack_d1mach (&c__5);
  /*Computing MIN 
   */
  i__1 = Abs (k1), i__2 = Abs (k2);
  k = Min (i__1, i__2);
  elim = (k * r1m5 - 3.) * 2.303;
  k1 = nsp_calpack_i1mach (&c__14) - 1;
  aa = r1m5 * k1;
  dig = Min (aa, 18.);
  aa *= 2.303;
  /*Computing MAX 
   */
  d__1 = -aa;
  alim = elim + Max (d__1, -41.45);
  rl = dig * 1.2 + 3.;
  fnul = (dig - 3.) * 6. + 10.;
  /*----------------------------------------------------------------------- 
   *    TEST FOR PROPER RANGE 
   *----------------------------------------------------------------------- 
   */
  az = nsp_calpack_zabs (zr, zi);
  fn = *fnu + (*n - 1);
  aa = .5 / tol;
  bb = nsp_calpack_i1mach (&c__9) * .5;
  aa = Min (aa, bb);
  if (az > aa)
    {
      goto L260;
    }
  if (fn > aa)
    {
      goto L260;
    }
  aa = sqrt (aa);
  if (az > aa)
    {
      *ierr = 3;
    }
  if (fn > aa)
    {
      *ierr = 3;
    }
  /*----------------------------------------------------------------------- 
   *    CALCULATE CSGN=EXP(FNU*HPI*I) TO MINIMIZE LOSSES OF SIGNIFICANCE 
   *    WHEN FNU IS LARGE 
   *----------------------------------------------------------------------- 
   */
  cii = 1.;
  inu = (int) (*fnu);
  inuh = inu / 2;
  ir = inu - (inuh << 1);
  arg = (*fnu - (inu - ir)) * hpi;
  csgnr = cos (arg);
  csgni = sin (arg);
  if (inuh % 2 == 0)
    {
      goto L40;
    }
  csgnr = -csgnr;
  csgni = -csgni;
L40:
  /*----------------------------------------------------------------------- 
   *    ZN IS IN THE RIGHT HALF PLANE 
   *----------------------------------------------------------------------- 
   */
  znr = *zi;
  zni = -(*zr);
  if (*zi >= 0.)
    {
      goto L50;
    }
  znr = -znr;
  zni = -zni;
  csgni = -csgni;
  cii = -cii;
L50:
  nsp_calpack_zbinu (&znr, &zni, fnu, kode, n, &cyr[1], &cyi[1], nz, &rl,
		     &fnul, &tol, &elim, &alim);
  if (*nz < 0)
    {
      goto L130;
    }
  nl = *n - *nz;
  if (nl == 0)
    {
      return 0;
    }
  rtol = 1. / tol;
  ascle = nsp_calpack_d1mach (&c__1) * rtol * 1e3;
  i__1 = nl;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      /*      STR = CYR(I)*CSGNR - CYI(I)*CSGNI 
       *      CYI(I) = CYR(I)*CSGNI + CYI(I)*CSGNR 
       *      CYR(I) = STR 
       */
      aa = cyr[i__];
      bb = cyi[i__];
      atol = 1.;
      /*Computing MAX 
       */
      d__1 = Abs (aa), d__2 = Abs (bb);
      if (Max (d__1, d__2) > ascle)
	{
	  goto L55;
	}
      aa *= rtol;
      bb *= rtol;
      atol = tol;
    L55:
      str = aa * csgnr - bb * csgni;
      sti = aa * csgni + bb * csgnr;
      cyr[i__] = str * atol;
      cyi[i__] = sti * atol;
      str = -csgni * cii;
      csgni = csgnr * cii;
      csgnr = str;
      /* L60: */
    }
  return 0;
L130:
  if (*nz == -2)
    {
      goto L140;
    }
  *nz = 0;
  *ierr = 2;
  return 0;
L140:
  *nz = 0;
  *ierr = 5;
  return 0;
L260:
  *nz = 0;
  *ierr = 4;
  return 0;
}				/* zbesj_ */
