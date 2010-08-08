#include "blocks.h"

void matbyscal_s (scicos_block * block, int flag)
{
  if (flag == 1)
    {
      int nu, mu, i, ut;
      double v, *rpar;
      ut = GetInType (block, 1);
      mu = GetOutPortRows (block, 1);
      nu = GetOutPortCols (block, 1);
      rpar = GetRparPtrs (block);
      switch (ut)
	{
	case SCSINT32_N:
	  {
	    SCSINT32_COP *u1, *u2, *y1;
	    u1 = Getint32InPortPtrs (block, 1);
	    u2 = Getint32InPortPtrs (block, 2);
	    y1 = Getint32OutPortPtrs (block, 1);
	    for (i = 0; i < mu * nu; i++)
	      {
		v = (double) u1[i] * (double) u2[0];
		if (v < rpar[0])
		  v = rpar[0];
		else if (v > rpar[1])
		  v = rpar[1];
		y1[i] = (SCSINT32_COP) v;
	      }
	    break;
	  }

	case SCSINT16_N:
	  {
	    SCSINT16_COP *u1, *u2, *y1;
	    u1 = Getint16InPortPtrs (block, 1);
	    u2 = Getint16InPortPtrs (block, 2);
	    y1 = Getint16OutPortPtrs (block, 1);
	    for (i = 0; i < mu * nu; i++)
	      {
		v = (double) u1[i] * (double) u2[0];
		if (v < rpar[0])
		  v = rpar[0];
		else if (v > rpar[1])
		  v = rpar[1];
		y1[i] = (SCSINT16_COP) v;
	      }
	    break;
	  }

	case SCSINT8_N:
	  {
	    char *u1, *u2, *y1;
	    u1 = Getint8InPortPtrs (block, 1);
	    u2 = Getint8InPortPtrs (block, 2);
	    y1 = Getint8OutPortPtrs (block, 1);
	    for (i = 0; i < mu * nu; i++)
	      {
		v = (double) u1[i] * (double) u2[0];
		if (v < rpar[0])
		  v = rpar[0];
		else if (v > rpar[1])
		  v = rpar[1];
		y1[i] = (char) v;
	      }
	    break;
	  }

	case SCSUINT32_N:
	  {
	    SCSUINT32_COP *u1, *u2, *y1;
	    u1 = Getuint32InPortPtrs (block, 1);
	    u2 = Getuint32InPortPtrs (block, 2);
	    y1 = Getuint32OutPortPtrs (block, 1);
	    for (i = 0; i < mu * nu; i++)
	      {
		v = (double) u1[i] * (double) u2[0];
		if (v < rpar[0])
		  v = rpar[0];
		else if (v > rpar[1])
		  v = rpar[1];
		y1[i] = (SCSUINT32_COP) v;
	      }
	    break;
	  }

	case SCSUINT16_N:
	  {
	    SCSUINT16_COP *u1, *u2, *y1;
	    u1 = Getuint16InPortPtrs (block, 1);
	    u2 = Getuint16InPortPtrs (block, 2);
	    y1 = Getuint16OutPortPtrs (block, 1);
	    for (i = 0; i < mu * nu; i++)
	      {
		v = (double) u1[i] * (double) u2[0];
		if (v < rpar[0])
		  v = rpar[0];
		else if (v > rpar[1])
		  v = rpar[1];
		y1[i] = (SCSUINT16_COP) v;
	      }
	    break;
	  }

	case SCSUINT8_N:
	  {
	    SCSUINT8_COP *u1, *u2, *y1;
	    u1 = Getuint8InPortPtrs (block, 1);
	    u2 = Getuint8InPortPtrs (block, 2);
	    y1 = Getuint8OutPortPtrs (block, 1);
	    for (i = 0; i < mu * nu; i++)
	      {
		v = (double) u1[i] * (double) u2[0];
		if (v < rpar[0])
		  v = rpar[0];
		else if (v > rpar[1])
		  v = rpar[1];
		y1[i] = (SCSUINT8_COP) v;
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
