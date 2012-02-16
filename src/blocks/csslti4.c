#include "blocks.h"

void deprectaed_csslti4 (scicos_block * block, int flag)
{
  /*  Copyright INRIA

      Scicos block simulator
      continuous state space linear system simulator
      rpar(1:nx*nx)=A
      rpar(nx*nx+1:nx*nx+nx*nu)=B
      rpar(nx*nx+nx*nu+1:nx*nx+nx*nu+nx*ny)=C
      rpar(nx*nx+nx*nu+nx*ny+1:nx*nx+nx*nu+nx*ny+ny*nu)=D 
  */

  int un = 1, lb, lc, ld;
  int nx = GetNstate (block);
  double *x = GetState (block);
  double *xd = GetDerState (block);
  double *rpar = GetRparPtrs (block);
  double *y = GetRealOutPortPtrs (block, 1);
  double *u = GetRealInPortPtrs (block, 1);
  int noutsz = GetOutPortRows (block, 1);
  int ninsz = GetInPortRows (block, 1);

  lb = nx * nx;
  lc = lb + nx * ninsz;

  if (flag == 1 || flag == 6)
    {
      /* y=c*x+d*u     */
      ld = lc + nx * noutsz;
      if (nx == 0)
	{
	  nsp_calpack_dmmul (&rpar[ld], &noutsz, u, &ninsz, y, &noutsz,
			     &noutsz, &ninsz, &un);
	}
      else
	{
	  nsp_calpack_dmmul (&rpar[lc], &noutsz, x, &nx, y, &noutsz, &noutsz,
			     &nx, &un);
	  nsp_calpack_dmmul1 (&rpar[ld], &noutsz, u, &ninsz, y, &noutsz,
			      &noutsz, &ninsz, &un);
	}
    }

  else if (flag == 0)
    {
      /* xd=a*x+b*u */
      nsp_calpack_dmmul (&rpar[0], &nx, x, &nx, xd, &nx, &nx, &nx, &un);
      nsp_calpack_dmmul1 (&rpar[lb], &nx, u, &ninsz, xd, &nx, &nx, &ninsz,
			  &un);
    }
}
