/* dsearch.f -- translated by f2c (version 19961017).
 *
 *
 */

#include "calpack.h"

int
nsp_calpack_dsearchc (double *x, int *m, double *val, int *n, int *indx,
		      int *occ, int *info)
{
  /* System generated locals */
  int i__1;

  /* Local variables */
  int i__, j, j1, j2;

  /* 
   * 
   *    PURPOSE 
   *       val(0..n) being an array (with strict increasing order and n >=1) 
   *       representing intervals, this routine, by the mean of a 
   *       dichotomic search, computes : 
   * 
   *          a/ for each X(i) its interval number indX(i) : 
   *                    indX(i) = j if  X(i) in (val(j-1), val(j)] 
   *                            = 1 if  X(i) = val(0) 
   *                            = 0 if  X(i) is not in [val(0),val(n)] 
   * 
   *          b/ the number of points falling in the interval j : 
   * 
   *             occ(j) = # { X(i) such that X(i) in (val(j-1), val(j)] } for j>1 
   *        and  occ(1) = # { X(i) such that X(i) in [val(0), val(1)] } 
   * 
   *    PARAMETERS 
   *       inputs : 
   *          m         int 
   *          X(1..m)   double float array 
   *          n         int 
   *          val(0..n) double float array (val(0) < val(1) < ....) 
   *       outputs 
   *          indX(1..m) int array 
   *          occ(1..n)  int array 
   *          info       int (number of X(i) not in [val(0), val(n)]) 
   * 
   *    AUTHOR 
   *       Bruno Pincon 
   * 
   */
  /* Parameter adjustments */
  --indx;
  --x;
  --occ;

  /* Function Body */
  i__1 = *n;
  for (j = 1; j <= i__1; ++j)
    {
      occ[j] = 0;
    }
  *info = 0;
  i__1 = *m;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      if (val[0] <= x[i__] && x[i__] <= val[*n])
	{
	  /*          X(i) is in [val(0),val(n)] : 
	   *          find j such that val(j-1) <= X(i) <= val(j) by a dicho search 
	   */
	  j1 = 0;
	  j2 = *n;
	  while (j2 - j1 > 1)
	    {
	      j = (j1 + j2) / 2;
	      if (x[i__] <= val[j])
		{
		  j2 = j;
		}
	      else
		{
		  j1 = j;
		}
	    }
	  /*          we have val(j1) < X(i) <= val(j2)  if j2 > 1  (j1=j2-1) 
	   *               or val(j1) <= X(i) <= val(j2) if j2 = 1  (j1=j2-1) 
	   *          so that j2 is the good interval number in all cases 
	   */
	  ++occ[j2];
	  indx[i__] = j2;
	}
      else
	{
	  /*X(i) is not in [val(0), val(n)] 
	   */
	  ++(*info);
	  indx[i__] = 0;
	}
    }
  return 0;
}				/* dsearchc_ */

/* 
************************************************************************** 
* 
*/
int
nsp_calpack_dsearchd (double *x, int *m, double *val, int *n, int *indx,
		      int *occ, int *info)
{
  /* System generated locals */
  int i__1;

  /* Local variables */
  int i__, j, j1, j2;

  /* 
   *    PURPOSE 
   *       val(1..n) being a strictly increasing array, this 
   *       routines by the mean of a dichotomic search computes : 
   * 
   *       a/ the number of occurences (occ(j)) of each value val(j) 
   *          in the array X : 
   * 
   *             occ(j) = #{ X(i) such that X(i) = val(j) } 
   * 
   *       b/ the array indX :  if X(i) = val(j) then indX(i) = j 
   *          (if X(i) is not in val then indX(i) = 0) 
   * 
   *    PARAMETERS 
   *       inputs : 
   *          m         int 
   *          X(1..m)   double float array 
   *          n         int 
   *          val(1..n) double float array (must be in a strict increasing order) 
   *       outputs : 
   *          occ(1..n)  int array 
   *          indX(1..m) int array 
   *          info       int  (number of X(i) which are not in val(1..n)) 
   * 
   *    AUTHOR 
   *       Bruno Pincon 
   * 
   */
  /* Parameter adjustments */
  --indx;
  --x;
  --occ;
  --val;

  /* Function Body */
  i__1 = *n;
  for (j = 1; j <= i__1; ++j)
    {
      occ[j] = 0;
    }
  *info = 0;
  i__1 = *m;
  for (i__ = 1; i__ <= i__1; ++i__)
    {
      if (val[1] <= x[i__] && x[i__] <= val[*n])
	{
	  /*          find j such that X(i) = val(j) by a dicho search 
	   */
	  j1 = 1;
	  j2 = *n;
	  while (j2 - j1 > 1)
	    {
	      j = (j1 + j2) / 2;
	      if (x[i__] < val[j])
		{
		  j2 = j;
		}
	      else
		{
		  j1 = j;
		}
	    }
	  /*          here we know that val(j1) <= X(i) <= val(j2)  with j2 = j1 + 1 
	   *          (in fact we have exactly  val(j1) <= X(i) < val(j2) if j2 < n) 
	   */
	  if (x[i__] == val[j1])
	    {
	      ++occ[j1];
	      indx[i__] = j1;
	    }
	  else if (x[i__] == val[j2])
	    {
	      /*(note: this case may hap 
	       */
	      ++occ[j2];
	      indx[i__] = j2;
	    }
	  else
	    {
	      /*X(i) is not in {val(1), val(2),..., val(n)} 
	       */
	      ++(*info);
	      indx[i__] = 0;
	    }
	}
      else
	{
	  /*X(i) is not in {val(1), val(2),..., val(n)} 
	   */
	  ++(*info);
	  indx[i__] = 0;
	}
    }
  return 0;
}				/* dsearchd_ */
