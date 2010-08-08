/* wdpow1.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

int
nsp_calpack_wdpow1 (int *n, double *vr, double *vi, int *iv, double *p,
		    int *ip, double *rr, double *ri, int *ir, int *ierr)
{
  /* System generated locals */
  int i__1;

  /* Local variables */
  int ierr1, i__, ii, iscmpl;
  int iip, iir;

  /*!purpose 
   *    computes V^P with V complex vector and P real vector 
   *!calling sequence 
   *    subroutine wdpow1(n,vr,vi,iv,p,ip,rr,ri,ir,ierr) 
   *    int n,iv,ip,ir,ierr 
   *    double precision vr(*),vi(*),p(*),rr(*),ri(*) 
   * 
   *    n    : number of elements of V and P vectors 
   *    vr   : array containing real part of V elements 
   *           real(V(i))=vr(1+(i-1)*iv) 
   *    vi   : array containing imaginary part of V elements 
   *           imag(V(i))=vi(1+(i-1)*iv) 
   *    iv   : increment between two V elements in v (may be 0) 
   *    p    : array containing P elements P(i)=p(1+(i-1)*ip) 
   *    ip   : increment between two P elements in p (may be 0) 
   *    rr   : array containing real part of the results vector R: 
   *           real(R(i))=rr(1+(i-1)*ir) 
   *    ri   : array containing imaginary part of the results vector R: 
   *           imag(R(i))=ri(1+(i-1)*ir) 
   *    ir   : increment between two R elements in rr and ri 
   *    ierr : error flag 
   *           ierr=0 if ok 
   *           ierr=1 if 0**0 
   *           ierr=2 if  0**k with k<0 
   *!origin 
   *Serge Steer INRIA 1996 
   *! 
   *    Copyright INRIA 
   * 
   */
  /* Parameter adjustments */
  --ri;
  --rr;
  --p;
  --vi;
  --vr;

  /* Function Body */
  *ierr = 0;
  iscmpl = 0;
  /* 
   */
  ii = 1;
  iip = 1;
  iir = 1;
  i__1 = *n;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      nsp_calpack_wdpowe (&vr[ii], &vi[ii], &p[iip], &rr[iir], &ri[iir],
			  &ierr1);
      /*        if(ierr.ne.0) return 
       */
      *ierr = Max (*ierr, ierr1);
      ii += *iv;
      iip += *ip;
      iir += *ir;
      /* L20: */
    }
  /* 
   */
  return 0;
}				/* wdpow1_ */
