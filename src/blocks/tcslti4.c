#include "blocks.h"

/*
 *  Scicos block simulator
 *  continuous state space linear system simulator
 *  rpar(1:nx*nx)=A
 *  rpar(nx*nx+1:nx*nx+nx*nu)=B
 *  rpar(nx*nx+nx*nu+1:nx*nx+nx*nu+nx*ny)=C
 *  rpar(nx*nx+nx*nu+nx*ny+1:nx*nx+nx*nu+nx*ny+ny*nu)=D 
 *  Copyright INRIA
 */

void tcslti4 (scicos_block * block, int flag)
{
  int nevprt = GetNevIn (block);
  int un = 1, lb, lc, ld;
  int nx = GetNstate (block);
  double *x = GetState (block);
  double *xd = GetDerState (block);
  double *rpar = GetRparPtrs (block);
  double *y = GetRealOutPortPtrs (block, 1);
  double *u1=NULL;
  double *u2;
  int noutsz = GetOutPortRows (block, 1);
  int ninsz;

  if (GetNin (block) == 2)
    {
      u1 = GetRealInPortPtrs (block, 1);
      u2 = GetRealInPortPtrs (block, 2);
      ninsz = GetInPortRows (block, 1);
    }
  else
    {
      u2 = GetRealInPortPtrs (block, 1);
      ninsz = 0;
    }

  lb = nx * nx;
  lc = lb + nx * ninsz;

  if (flag == 1 || flag == 6)
    {
      /* y=c*x+d*u1 */
      ld = lc + nx * noutsz;
      nsp_calpack_dmmul (&rpar[lc], &noutsz, x, &nx, y, &noutsz, &noutsz, &nx, &un);
      nsp_calpack_dmmul1 (&rpar[ld], &noutsz, u1, &ninsz, y, &noutsz, &noutsz, &ninsz, &un);
    }
  else if (flag == 2 && nevprt == 1)
    {
      /* x+=u2 */
      memcpy (x, u2, nx * sizeof (double));
    }
  else if (flag == 0 && nevprt == 0)
    {
      /* xd=a*x+b*u1 */
      nsp_calpack_dmmul (&rpar[0], &nx, x, &nx, xd, &nx, &nx, &nx, &un);
      nsp_calpack_dmmul1 (&rpar[lb], &nx, u1, &ninsz, xd, &nx, &nx, &ninsz, &un);
    }
}
