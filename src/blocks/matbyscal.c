#include "blocks.h"

#define matbscal_n(y1,u1,u2,mu,nu)		\
  {for (i=0;i<mu*nu;i++) y1[i]=u1[i]*u2[0];}

void matbyscal (scicos_block * block, int flag)
{
  if (flag == 1)
    {
      int nu, mu, i, ut;
      ut = GetInType (block, 1);
      mu = GetOutPortRows (block, 1);
      nu = GetOutPortCols (block, 1);
      switch (ut)
	{
	case SCSREAL_N:
	  {
	    double *u1, *u2, *y1;
	    u1 = GetRealInPortPtrs (block, 1);
	    u2 = GetRealInPortPtrs (block, 2);
	    y1 = GetRealOutPortPtrs (block, 1);
	    matbscal_n (y1, u1, u2, mu, nu);
	    break;
	  }

	case SCSINT32_N:
	  {
	    SCSINT32_COP *u1, *u2, *y1;
	    u1 = Getint32InPortPtrs (block, 1);
	    u2 = Getint32InPortPtrs (block, 2);
	    y1 = Getint32OutPortPtrs (block, 1);
	    matbscal_n (y1, u1, u2, mu, nu);
	    break;
	  }

	case SCSINT16_N:
	  {
	    SCSINT16_COP *u1, *u2, *y1;
	    u1 = Getint16InPortPtrs (block, 1);
	    u2 = Getint16InPortPtrs (block, 2);
	    y1 = Getint16OutPortPtrs (block, 1);
	    matbscal_n (y1, u1, u2, mu, nu);
	    break;
	  }

	case SCSINT8_N:
	  {
	    char *u1, *u2, *y1;
	    u1 = Getint8InPortPtrs (block, 1);
	    u2 = Getint8InPortPtrs (block, 2);
	    y1 = Getint8OutPortPtrs (block, 1);
	    matbscal_n (y1, u1, u2, mu, nu);
	    break;
	  }

	case SCSUINT32_N:
	  {
	    SCSUINT32_COP *u1, *u2, *y1;
	    u1 = Getuint32InPortPtrs (block, 1);
	    u2 = Getuint32InPortPtrs (block, 2);
	    y1 = Getuint32OutPortPtrs (block, 1);
	    matbscal_n (y1, u1, u2, mu, nu);
	    break;
	  }

	case SCSUINT16_N:
	  {
	    SCSUINT16_COP *u1, *u2, *y1;
	    u1 = Getuint16InPortPtrs (block, 1);
	    u2 = Getuint16InPortPtrs (block, 2);
	    y1 = Getuint16OutPortPtrs (block, 1);
	    matbscal_n (y1, u1, u2, mu, nu);
	    break;
	  }

	case SCSUINT8_N:
	  {
	    SCSUINT8_COP *u1, *u2, *y1;
	    u1 = Getuint8InPortPtrs (block, 1);
	    u2 = Getuint8InPortPtrs (block, 2);
	    y1 = Getuint8OutPortPtrs (block, 1);
	    matbscal_n (y1, u1, u2, mu, nu);
	    break;
	  }

	case SCSCOMPLEX_N:
	  {
	    double *u1r, *u2r, *y1r;
	    double *u1i, *u2i, *y1i;
	    u1r = GetRealInPortPtrs (block, 1);
	    u2r = GetRealInPortPtrs (block, 2);
	    y1r = GetRealOutPortPtrs (block, 1);
	    u1i = GetImagInPortPtrs (block, 1);
	    u2i = GetImagInPortPtrs (block, 2);
	    y1i = GetImagOutPortPtrs (block, 1);
	    for (i = 0; i < mu * nu; i++)
	      {
		y1r[i] = (u1r[i] * u2r[0]) - (u1i[i] * u2i[0]);
		y1i[i] = (u1r[i] * u2i[0]) + (u1i[i] * u2r[0]);
	      }
	    break;
	  }

	default:
	  {
	    set_block_error (-4);
	    return;
	  }
	}
    }

}
