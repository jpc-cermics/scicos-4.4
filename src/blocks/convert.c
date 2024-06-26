# include "blocks.h"

void convert (scicos_block * block, int flag)
{
  int m, n, i;
  int *ipar;
  double v, w, k;

  m = GetInPortRows (block, 1);
  n = GetInPortCols (block, 1);
  ipar = GetIparPtrs (block);

  if ((flag == 1) | (flag == 6))
    {
      switch (*ipar)
	{
	case 1:
	  {
	    void *u, *y;
	    int so;
	    so = GetSizeOfOut (block, 1);
	    u = GetInPortPtrs (block, 1);
	    y = GetOutPortPtrs (block, 1);
	    memcpy (y, u, m * n * so);
	    break;
	  }
	case 2:
	  {
	    double *u;
	    SCSINT32_COP *y;
	    u = GetRealInPortPtrs (block, 1);
	    y = Getint32OutPortPtrs (block, 1);
	    k = 0xFFFFFFFF + 1.0;
	    for (i = 0; i < m * n; i++)
	      {
		v = (double) u[i];
		w = v - (double) ((int) (v / k)) * k;
		if (fabs (w) > k / 2 - 1)
		  {
		    if (w >= 0)
		      w =
			(-k / 2 +
			 fabs (w - (double) ((int) (w / (k / 2))) * (k / 2)));
		    else
		      w =
			-(-(k / 2) +
			  fabs (w -
				(double) ((int) (w / (k / 2))) * (k / 2)));
		  }
		y[i] = (SCSINT32_COP) w;
	      }
	    break;
	  }
	case 3:
	  {
	    double *u;
	    SCSINT16_COP *y;
	    u = GetRealInPortPtrs (block, 1);
	    y = Getint16OutPortPtrs (block, 1);
	    k = 0x10000;
	    for (i = 0; i < m * n; i++)
	      {
		v = (double) u[i];
		w = v - (double) ((int) (v / k)) * k;
		if (fabs (w) > k / 2 - 1)
		  {
		    if (w >= 0)
		      w =
			(-k / 2 +
			 fabs (w - (double) ((int) (w / (k / 2))) * (k / 2)));
		    else
		      w =
			-(-(k / 2) +
			  fabs (w -
				(double) ((int) (w / (k / 2))) * (k / 2)));
		  }
		y[i] = (SCSINT16_COP) w;
	      }
	    break;
	  }
	case 4:
	  {
	    double *u;
	    char *y;
	    u = GetRealInPortPtrs (block, 1);
	    y = Getint8OutPortPtrs (block, 1);
	    k = 0x100;
	    for (i = 0; i < m * n; i++)
	      {
		v = (double) u[i];
		w = v - (double) ((int) (v / k)) * k;
		if (fabs (w) > k / 2 - 1)
		  {
		    if (w >= 0)
		      w =
			(-k / 2 +
			 fabs (w - (double) ((int) (w / (k / 2))) * (k / 2)));
		    else
		      w =
			-(-(k / 2) +
			  fabs (w -
				(double) ((int) (w / (k / 2))) * (k / 2)));
		  }
		y[i] = (char) w;
	      }
	    break;
	  }
	case 5:
	  {
	    double *u;
	    SCSUINT32_COP *y;
	    u = GetRealInPortPtrs (block, 1);
	    y = Getuint32OutPortPtrs (block, 1);
	    k = 0xFFFFFFFF + 1.0;
	    for (i = 0; i < m * n; i++)
	      {
		v = (double) u[i];
		w = v - (double) ((int) (v / k)) * k;
		y[i] = (SCSUINT32_COP) w;
	      }
	    break;
	  }
	case 6:
	  {
	    double *u;
	    SCSUINT16_COP *y;
	    u = GetRealInPortPtrs (block, 1);
	    y = Getuint16OutPortPtrs (block, 1);
	    k = 0x10000;
	    for (i = 0; i < m * n; i++)
	      {
		v = (double) u[i];
		w = v - (double) ((int) (v / k)) * k;
		y[i] = (SCSUINT16_COP) w;
	      }
	    break;
	  }
	case 7:
	  {
	    double *u;
	    SCSUINT8_COP *y;
	    u = GetRealInPortPtrs (block, 1);
	    y = Getuint8OutPortPtrs (block, 1);
	    k = 0x100;
	    for (i = 0; i < m * n; i++)
	      {
		v = (double) u[i];
		w = v - (double) ((int) (v / k)) * k;
		y[i] = (SCSUINT8_COP) w;
	      }
	    break;
	  }
	case 8:
	  {
	    SCSINT32_COP *u;
	    double *y;
	    u = Getint32InPortPtrs (block, 1);
	    y = GetRealOutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      y[i] = (double) u[i];
	    break;
	  }
	case 9:
	  {
	    SCSINT32_COP *u;
	    SCSINT16_COP *y;
	    u = Getint32InPortPtrs (block, 1);
	    y = Getint16OutPortPtrs (block, 1);
	    k = 0x10000;
	    for (i = 0; i < m * n; i++)
	      {
		v = (double) u[i];
		w = v - (double) ((int) (v / k)) * k;
		if (fabs (w) > k / 2 - 1)
		  {
		    if (w >= 0)
		      w =
			(-k / 2 +
			 fabs (w - (double) ((int) (w / (k / 2))) * (k / 2)));
		    else
		      w =
			-(-(k / 2) +
			  fabs (w -
				(double) ((int) (w / (k / 2))) * (k / 2)));
		  }
		y[i] = (SCSINT16_COP) w;
	      }
	    break;
	  }
	case 10:
	  {
	    SCSINT32_COP *u;
	    char *y;
	    u = Getint32InPortPtrs (block, 1);
	    y = Getint8OutPortPtrs (block, 1);
	    k = 0x100;
	    for (i = 0; i < m * n; i++)
	      {
		v = (double) u[i];
		w = v - (double) ((int) (v / k)) * k;
		if (fabs (w) > k / 2 - 1)
		  {
		    if (w >= 0)
		      w =
			(-k / 2 +
			 fabs (w - (double) ((int) (w / (k / 2))) * (k / 2)));
		    else
		      w =
			-(-(k / 2) +
			  fabs (w -
				(double) ((int) (w / (k / 2))) * (k / 2)));
		  }
		y[i] = (char) w;
	      }
	    break;
	  }
	case 11:
	  {
	    SCSINT32_COP *u;
	    SCSUINT16_COP *y;
	    u = Getint32InPortPtrs (block, 1);
	    y = Getuint16OutPortPtrs (block, 1);
	    k = 0x10000;
	    for (i = 0; i < m * n; i++)
	      {
		v = (double) u[i];
		w = v - (double) ((int) (v / k)) * k;
		y[i] = (SCSUINT16_COP) w;
	      }
	    break;
	  }
	case 12:
	  {
	    SCSINT32_COP *u;
	    SCSUINT8_COP *y;
	    u = Getint32InPortPtrs (block, 1);
	    y = Getuint8OutPortPtrs (block, 1);
	    k = 0x100;
	    for (i = 0; i < m * n; i++)
	      {
		v = (double) u[i];
		w = v - (double) ((int) (v / k)) * k;
		y[i] = (SCSUINT8_COP) w;
	      }
	    break;
	  }
	case 13:
	  {
	    SCSINT16_COP *u;
	    double *y;
	    u = Getint16InPortPtrs (block, 1);
	    y = GetRealOutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      y[i] = (double) u[i];
	    break;
	  }
	case 14:
	  {
	    SCSINT16_COP *u;
	    SCSINT32_COP *y;
	    u = Getint16InPortPtrs (block, 1);
	    y = Getint32OutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		y[i] = (SCSINT32_COP) u[i];
	      }
	    break;
	  }
	case 15:
	  {
	    SCSINT16_COP *u;
	    char *y;
	    u = Getint16InPortPtrs (block, 1);
	    y = Getint8OutPortPtrs (block, 1);
	    k = 0x100;
	    for (i = 0; i < m * n; i++)
	      {
		v = (double) u[i];
		w = v - (double) ((int) (v / k)) * k;
		if (fabs (w) > k / 2 - 1)
		  {
		    if (w >= 0)
		      w =
			(-k / 2 +
			 fabs (w - (double) ((int) (w / (k / 2))) * (k / 2)));
		    else
		      w =
			-(-(k / 2) +
			  fabs (w -
				(double) ((int) (w / (k / 2))) * (k / 2)));
		  }
		y[i] = (char) w;
	      }
	    break;
	  }
	case 16:
	  {
	    SCSINT16_COP *u;
	    SCSUINT32_COP *y;
	    u = Getint16InPortPtrs (block, 1);
	    y = Getuint32OutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		y[i] = (SCSUINT32_COP) u[i];
	      }
	    break;
	  }
	case 17:
	  {
	    SCSINT16_COP *u;
	    SCSUINT8_COP *y;
	    u = Getint16InPortPtrs (block, 1);
	    y = Getuint8OutPortPtrs (block, 1);
	    k = 0x100;
	    for (i = 0; i < m * n; i++)
	      {
		v = (double) u[i];
		w = v - (double) ((int) (v / k)) * k;
		y[i] = (SCSUINT8_COP) w;
	      }
	    break;
	  }
	case 18:
	  {
	    char *u;
	    double *y;
	    u = Getint8InPortPtrs (block, 1);
	    y = GetRealOutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      y[i] = (double) u[i];
	    break;
	  }
	case 19:
	  {
	    char *u;
	    SCSINT32_COP *y;
	    u = Getint8InPortPtrs (block, 1);
	    y = Getint32OutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		y[i] = (SCSINT32_COP) u[i];
	      }
	    break;
	  }
	case 20:
	  {
	    char *u;
	    SCSINT16_COP *y;
	    u = Getint8InPortPtrs (block, 1);
	    y = Getint16OutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		y[i] = (SCSINT16_COP) u[i];
	      }
	    break;
	  }
	case 21:
	  {
	    char *u;
	    SCSUINT32_COP *y;
	    u = Getint8InPortPtrs (block, 1);
	    y = Getuint32OutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		y[i] = (SCSUINT32_COP) u[i];
	      }
	    break;
	  }
	case 22:
	  {
	    char *u;
	    SCSUINT16_COP *y;
	    u = Getint8InPortPtrs (block, 1);
	    y = Getuint16OutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		y[i] = (SCSUINT16_COP) u[i];
	      }
	    break;
	  }
	case 23:
	  {
	    SCSUINT32_COP *u;
	    double *y;
	    u = Getuint32InPortPtrs (block, 1);
	    y = GetRealOutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      y[i] = (double) u[i];
	    break;
	  }
	case 24:
	  {
	    SCSUINT32_COP *u;
	    SCSINT16_COP *y;
	    u = Getuint32InPortPtrs (block, 1);
	    y = Getint16OutPortPtrs (block, 1);
	    k = 0x10000;
	    for (i = 0; i < m * n; i++)
	      {
		v = (double) u[i];
		w = v - (double) ((int) (v / k)) * k;
		if ((w) > k / 2 - 1)
		  {
		    w =
		      (-k / 2 +
		       fabs (w - (double) ((int) (w / (k / 2))) * (k / 2)));
		  }
		y[i] = (SCSINT16_COP) w;
	      }
	    break;
	  }
	case 25:
	  {
	    SCSUINT32_COP *u;
	    char *y;
	    u = Getuint32InPortPtrs (block, 1);
	    y = Getint8OutPortPtrs (block, 1);
	    k = 0x100;
	    for (i = 0; i < m * n; i++)
	      {
		v = (double) u[i];
		w = v - (double) ((int) (v / k)) * k;
		if ((w) > k / 2 - 1)
		  {
		    w =
		      (-k / 2 +
		       fabs (w - (double) ((int) (w / (k / 2))) * (k / 2)));
		  }
		y[i] = (char) w;
	      }
	    break;
	  }
	case 26:
	  {
	    SCSUINT32_COP *u;
	    SCSUINT16_COP *y;
	    u = Getuint32InPortPtrs (block, 1);
	    y = Getuint16OutPortPtrs (block, 1);
	    k = 0x10000;
	    for (i = 0; i < m * n; i++)
	      {
		v = (double) u[i];
		w = v - (double) ((int) (v / k)) * k;
		y[i] = (SCSUINT16_COP) w;
	      }
	    break;
	  }
	case 27:
	  {
	    SCSUINT32_COP *u;
	    SCSUINT8_COP *y;
	    u = Getuint32InPortPtrs (block, 1);
	    y = Getuint8OutPortPtrs (block, 1);
	    k = 0x100;
	    for (i = 0; i < m * n; i++)
	      {
		v = (double) u[i];
		w = v - (double) ((int) (v / k)) * k;
		y[i] = (SCSUINT8_COP) w;
	      }
	    break;
	  }
	case 28:
	  {
	    SCSUINT16_COP *u;
	    double *y;
	    u = Getuint16InPortPtrs (block, 1);
	    y = GetRealOutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      y[i] = (double) u[i];
	    break;
	  }
	case 29:
	  {
	    SCSUINT16_COP *u;
	    SCSINT32_COP *y;
	    u = Getuint16InPortPtrs (block, 1);
	    y = Getint32OutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		y[i] = (SCSINT32_COP) u[i];
	      }
	    break;
	  }
	case 30:
	  {
	    SCSUINT16_COP *u;
	    char *y;
	    u = Getuint16InPortPtrs (block, 1);
	    y = Getint8OutPortPtrs (block, 1);
	    k = 0x100;
	    for (i = 0; i < m * n; i++)
	      {
		v = (double) u[i];
		w = v - (double) ((int) (v / k)) * k;
		if (w > k / 2 - 1)
		  {
		    w =
		      (-k / 2 +
		       fabs (w - (double) ((int) (w / (k / 2))) * (k / 2)));
		  }
		y[i] = (char) w;
	      }
	    break;
	  }
	case 31:
	  {
	    SCSUINT16_COP *u;
	    SCSUINT32_COP *y;
	    u = Getuint16InPortPtrs (block, 1);
	    y = Getuint32OutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		y[i] = (SCSUINT32_COP) u[i];
	      }
	    break;
	  }
	case 32:
	  {
	    SCSUINT16_COP *u;
	    SCSUINT8_COP *y;
	    u = Getuint16InPortPtrs (block, 1);
	    y = Getuint8OutPortPtrs (block, 1);
	    k = 0x100;
	    for (i = 0; i < m * n; i++)
	      {
		v = (double) u[i];
		w = v - (double) ((int) (v / k)) * k;
		y[i] = (SCSUINT8_COP) w;
	      }
	    break;
	  }
	case 33:
	  {
	    SCSUINT8_COP *u;
	    double *y;
	    u = Getuint8InPortPtrs (block, 1);
	    y = GetRealOutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      y[i] = (double) u[i];
	    break;
	  }
	case 34:
	  {
	    SCSUINT8_COP *u;
	    SCSINT32_COP *y;
	    u = Getuint8InPortPtrs (block, 1);
	    y = Getint32OutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		y[i] = (SCSINT32_COP) u[i];
	      }
	    break;
	  }
	case 35:
	  {
	    SCSUINT8_COP *u;
	    SCSINT16_COP *y;
	    u = Getuint8InPortPtrs (block, 1);
	    y = Getint16OutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		y[i] = (SCSINT16_COP) u[i];
	      }
	    break;
	  }
	case 36:
	  {
	    SCSUINT8_COP *u;
	    SCSUINT32_COP *y;
	    u = Getuint8InPortPtrs (block, 1);
	    y = Getuint32OutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		y[i] = (SCSUINT32_COP) u[i];
	      }
	    break;
	  }
	case 37:
	  {
	    SCSUINT8_COP *u;
	    SCSUINT16_COP *y;
	    u = Getuint8InPortPtrs (block, 1);
	    y = Getuint16OutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		y[i] = (SCSUINT16_COP) u[i];
	      }
	    break;
	  }
	case 38:
	  {
	    double *u;
	    SCSINT32_COP *y, k1, k2;
	    u = GetRealInPortPtrs (block, 1);
	    y = Getint32OutPortPtrs (block, 1);
	    k1 = 0x7FFFFFFF;
	    k2 = 0x80000000;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (double) k1)
		  {
		    y[i] = k1;
		  }
		else if (u[i] < (double) (k2))
		  {
		    y[i] = k2;
		  }
		else
		  {
		    y[i] = (SCSINT32_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 39:
	  {
	    double *u;
	    SCSINT16_COP *y, k1, k2;
	    u = GetRealInPortPtrs (block, 1);
	    y = Getint16OutPortPtrs (block, 1);
	    k1 = 0x7FFF;
	    k2 = 0x8000;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (double) (k1))
		  {
		    y[i] = k1;
		  }
		else if (u[i] < (double) k2)
		  {
		    y[i] = k2;
		  }
		else
		  {
		    y[i] = (SCSINT16_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 40:
	  {
	    double *u;
	    char *y, k1, k2;
	    u = GetRealInPortPtrs (block, 1);
	    y = Getint8OutPortPtrs (block, 1);
	    k1 = 0x7F;
	    k2 = 0x80;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (double) k1)
		  {
		    y[i] = k1;
		  }
		else if (u[i] < (double) k2)
		  {
		    y[i] = k2;
		  }
		else
		  {
		    y[i] = (char) (u[i]);
		  }
	      }
	    break;
	  }
	case 41:
	  {
	    double *u;
	    SCSUINT32_COP *y, k1;
	    u = GetRealInPortPtrs (block, 1);
	    y = Getuint32OutPortPtrs (block, 1);
	    k1 = 0xFFFFFFFF;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (double) k1)
		  {
		    y[i] = k1;
		  }
		else if (u[i] < 0)
		  {
		    y[i] = 0;
		  }
		else
		  {
		    y[i] = (SCSUINT32_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 42:
	  {
	    double *u;
	    SCSUINT16_COP *y, k1;
	    u = GetRealInPortPtrs (block, 1);
	    y = Getuint16OutPortPtrs (block, 1);
	    k1 = 0xFFFF;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (double) k1)
		  {
		    y[i] = k1;
		  }
		else if (u[i] < 0)
		  {
		    y[i] = 0;
		  }
		else
		  {
		    y[i] = (SCSUINT16_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 43:
	  {
	    double *u;
	    SCSUINT8_COP *y, k1;
	    u = GetRealInPortPtrs (block, 1);
	    y = Getuint8OutPortPtrs (block, 1);
	    k1 = 0xFF;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (double) k1)
		  {
		    y[i] = k1;
		  }
		else if (u[i] < 0)
		  {
		    y[i] = 0;
		  }
		else
		  {
		    y[i] = (SCSUINT8_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 44:
	  {
	    SCSINT32_COP *u;
	    SCSINT16_COP *y, k1, k2;
	    u = Getint32InPortPtrs (block, 1);
	    y = Getint16OutPortPtrs (block, 1);
	    k1 = 0x7FFF;
	    k2 = 0x8000;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (SCSINT32_COP) (k1))
		  {
		    y[i] = k1;
		  }
		else if (u[i] < (SCSINT32_COP) (k2))
		  {
		    y[i] = k2;
		  }
		else
		  {
		    y[i] = (SCSINT16_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 45:
	  {
	    SCSINT32_COP *u;
	    char *y, k1, k2;
	    u = Getint32InPortPtrs (block, 1);
	    y = Getint8OutPortPtrs (block, 1);
	    k1 = 0x7F;
	    k2 = 0x80;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (SCSINT32_COP) (k1))
		  {
		    y[i] = k1;
		  }
		else if (u[i] < (SCSINT32_COP) (k2))
		  {
		    y[i] = k2;
		  }
		else
		  {
		    y[i] = (char) (u[i]);
		  }
	      }
	    break;
	  }
	case 46:
	  {
	    SCSINT32_COP *u;
	    SCSUINT32_COP *y;
	    u = Getint32InPortPtrs (block, 1);
	    y = Getuint32OutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] < 0)
		  {
		    y[i] = 0;
		  }
		else
		  {
		    y[i] = (SCSUINT32_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 47:
	  {
	    SCSINT32_COP *u;
	    SCSUINT16_COP *y, k1;
	    u = Getint32InPortPtrs (block, 1);
	    y = Getuint16OutPortPtrs (block, 1);
	    k1 = 0xFFFF;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (SCSINT32_COP) (k1))
		  {
		    y[i] = k1;
		  }
		else if (u[i] < 0)
		  {
		    y[i] = 0;
		  }
		else
		  {
		    y[i] = (SCSUINT16_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 48:
	  {
	    SCSINT32_COP *u;
	    SCSUINT8_COP *y, k1;
	    u = Getint32InPortPtrs (block, 1);
	    y = Getuint8OutPortPtrs (block, 1);
	    k1 = 0xFF;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (SCSINT32_COP) k1)
		  {
		    y[i] = k1;
		  }
		else if (u[i] < 0)
		  {
		    y[i] = 0;
		  }
		else
		  {
		    y[i] = (SCSUINT8_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 49:
	  {
	    SCSINT16_COP *u;
	    char *y, k1, k2;
	    u = Getint16InPortPtrs (block, 1);
	    y = Getint8OutPortPtrs (block, 1);
	    k1 = 0x7F;
	    k2 = 0x80;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (SCSINT16_COP) (k1))
		  {
		    y[i] = k1;
		  }
		else if (u[i] < (SCSINT16_COP) (k2))
		  {
		    y[i] = k2;
		  }
		else
		  {
		    y[i] = (char) (u[i]);
		  }
	      }
	    break;
	  }
	case 50:
	  {
	    SCSINT16_COP *u;
	    SCSUINT32_COP *y;
	    u = Getint16InPortPtrs (block, 1);
	    y = Getuint32OutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] < 0)
		  y[i] = 0;
		else
		  y[i] = (SCSUINT32_COP) u[i];
	      }
	    break;
	  }
	case 51:
	  {
	    SCSINT16_COP *u;
	    SCSUINT16_COP *y;
	    u = Getint16InPortPtrs (block, 1);
	    y = Getuint16OutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] < 0)
		  {
		    y[i] = 0;
		  }
		else
		  {
		    y[i] = (SCSUINT16_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 52:
	  {
	    SCSINT16_COP *u;
	    SCSUINT8_COP *y, k1;
	    u = Getint16InPortPtrs (block, 1);
	    y = Getuint8OutPortPtrs (block, 1);
	    k1 = 0xFF;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (SCSINT16_COP) k1)
		  {
		    y[i] = k1;
		  }
		else if (u[i] < 0)
		  {
		    y[i] = 0;
		  }
		else
		  {
		    y[i] = (SCSUINT8_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 53:
	  {
	    char *u;
	    SCSUINT32_COP *y;
	    u = Getint8InPortPtrs (block, 1);
	    y = Getuint32OutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] < 0)
		  y[i] = 0;
		else
		  y[i] = (SCSUINT32_COP) u[i];
	      }
	    break;
	  }
	case 54:
	  {
	    char *u;
	    SCSUINT16_COP *y;
	    u = Getint8InPortPtrs (block, 1);
	    y = Getuint16OutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] < 0)
		  {
		    y[i] = 0;
		  }
		else
		  {
		    y[i] = (SCSUINT16_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 55:
	  {
	    char *u;
	    SCSUINT8_COP *y;
	    u = Getint8InPortPtrs (block, 1);
	    y = Getuint8OutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] < 0)
		  {
		    y[i] = 0;
		  }
		else
		  {
		    y[i] = (SCSUINT8_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 56:
	  {
	    SCSINT32_COP *y, k1;
	    SCSUINT32_COP *u;
	    u = Getuint32InPortPtrs (block, 1);
	    y = Getint32OutPortPtrs (block, 1);
	    k1 = 0x7FFFFFFF;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (SCSUINT32_COP) (k1))
		  {
		    y[i] = k1;
		  }
		else
		  {
		    y[i] = (SCSINT32_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 57:
	  {
	    SCSUINT32_COP *u;
	    SCSINT16_COP *y, k1;
	    u = Getuint32InPortPtrs (block, 1);
	    y = Getint16OutPortPtrs (block, 1);
	    k1 = 0x7FFF;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (SCSUINT32_COP) k1)
		  {
		    y[i] = k1;
		  }
		else
		  {
		    y[i] = (SCSINT16_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 58:
	  {
	    SCSUINT32_COP *u;
	    char *y, k1;
	    u = Getuint32InPortPtrs (block, 1);
	    y = Getint8OutPortPtrs (block, 1);
	    k1 = 0x7F;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (SCSUINT32_COP) k1)
		  {
		    y[i] = k1;
		  }
		else
		  {
		    y[i] = (char) (u[i]);
		  }
	      }
	    break;
	  }
	case 59:
	  {
	    SCSUINT32_COP *u;
	    SCSUINT16_COP *y, k1;
	    u = Getuint32InPortPtrs (block, 1);
	    y = Getuint16OutPortPtrs (block, 1);
	    k1 = 0xFFFF;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (SCSUINT32_COP) (k1))
		  {
		    y[i] = k1;
		  }
		else
		  {
		    y[i] = (SCSUINT16_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 60:
	  {
	    SCSUINT32_COP *u;
	    SCSUINT8_COP *y, k1;
	    u = Getuint32InPortPtrs (block, 1);
	    y = Getuint8OutPortPtrs (block, 1);
	    k1 = 0xFF;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (SCSUINT32_COP) k1)
		  {
		    y[i] = k1;
		  }
		else
		  {
		    y[i] = (SCSUINT8_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 61:
	  {
	    SCSUINT16_COP *u;
	    SCSINT16_COP *y, k1;
	    u = Getuint16InPortPtrs (block, 1);
	    y = Getint16OutPortPtrs (block, 1);
	    k1 = 0x7FFF;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (SCSUINT16_COP) k1)
		  {
		    y[i] = k1;
		  }
		else
		  {
		    y[i] = (SCSINT16_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 62:
	  {
	    SCSUINT16_COP *u;
	    char *y, k1;
	    u = Getuint16InPortPtrs (block, 1);
	    y = Getint8OutPortPtrs (block, 1);
	    k1 = 0x7F;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (SCSUINT16_COP) k1)
		  {
		    y[i] = k1;
		  }
		else
		  {
		    y[i] = (char) (u[i]);
		  }
	      }
	    break;
	  }
	case 63:
	  {
	    SCSUINT16_COP *u;
	    SCSUINT8_COP *y, k1;
	    u = Getuint16InPortPtrs (block, 1);
	    y = Getuint8OutPortPtrs (block, 1);
	    k1 = 0xFF;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (SCSUINT16_COP) k1)
		  {
		    y[i] = k1;
		  }
		else
		  {
		    y[i] = (SCSUINT8_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 64:
	  {
	    SCSUINT8_COP *u;
	    char *y, k1;
	    u = Getuint8InPortPtrs (block, 1);
	    y = Getint8OutPortPtrs (block, 1);
	    k1 = 0x7F;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (SCSUINT8_COP) k1)
		  {
		    y[i] = k1;
		  }
		else
		  {
		    y[i] = (char) (u[i]);
		  }
	      }
	    break;
	  }
	case 65:
	  {
	    double *u;
	    SCSINT32_COP *y, k1, k2;
	    u = GetRealInPortPtrs (block, 1);
	    y = Getint32OutPortPtrs (block, 1);
	    k1 = 0x7FFFFFFF;
	    k2 = 0x80000000;
	    for (i = 0; i < m * n; i++)
	      {
		if ((u[i] > (double) k1) | (u[i] < (double) k2))
		  {
		    if (flag == 1)
		      {
			sciprint ("overflow error");
			set_block_error (-4);
			return;
		      }
		  }
		else
		  {
		    y[i] = (SCSINT32_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 66:
	  {
	    double *u;
	    SCSINT16_COP *y, k1, k2;
	    u = GetRealInPortPtrs (block, 1);
	    y = Getint16OutPortPtrs (block, 1);
	    k1 = 0x7FFF;
	    k2 = 0x8000;
	    for (i = 0; i < m * n; i++)
	      {
		if ((u[i] > (double) k1) | (u[i] < (double) k2))
		  {
		    if (flag == 1)
		      {
			sciprint ("overflow error");
			set_block_error (-4);
			return;
		      }
		  }
		else
		  {
		    y[i] = (SCSINT16_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 67:
	  {
	    double *u;
	    char *y, k1, k2;
	    u = GetRealInPortPtrs (block, 1);
	    y = Getint8OutPortPtrs (block, 1);
	    k1 = 0x7F;
	    k2 = 0x80;
	    for (i = 0; i < m * n; i++)
	      {
		if ((u[i] > (double) k1) | (u[i] < (double) k2))
		  {
		    if (flag == 1)
		      {
			sciprint ("overflow error");
			set_block_error (-4);
			return;
		      }
		  }
		else
		  {
		    y[i] = (char) (u[i]);
		  }
	      }
	    break;
	  }
	case 68:
	  {
	    double *u;
	    SCSUINT32_COP *y, k1;
	    u = GetRealInPortPtrs (block, 1);
	    y = Getuint32OutPortPtrs (block, 1);
	    k1 = 0xFFFFFFFF;
	    for (i = 0; i < m * n; i++)
	      {
		if ((u[i] > (double) k1) | (u[i] < 0))
		  {
		    if (flag == 1)
		      {
			sciprint ("overflow error");
			set_block_error (-4);
			return;
		      }
		  }
		else
		  {
		    y[i] = (SCSUINT32_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 69:
	  {
	    double *u;
	    SCSUINT16_COP *y, k1;
	    u = GetRealInPortPtrs (block, 1);
	    y = Getuint16OutPortPtrs (block, 1);
	    k1 = 0xFFFF;
	    for (i = 0; i < m * n; i++)
	      {
		if ((u[i] > (double) k1) | (u[i] < 0))
		  {
		    if (flag == 1)
		      {
			sciprint ("overflow error");
			set_block_error (-4);
			return;
		      }
		  }
		else
		  {
		    y[i] = (SCSUINT16_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 70:
	  {
	    double *u;
	    SCSUINT8_COP *y, k1;
	    u = GetRealInPortPtrs (block, 1);
	    y = Getuint8OutPortPtrs (block, 1);
	    k1 = 0xFF;
	    for (i = 0; i < m * n; i++)
	      {
		if ((u[i] > (double) k1) | (u[i] < 0))
		  {
		    if (flag == 1)
		      {
			sciprint ("overflow error");
			set_block_error (-4);
			return;
		      }
		  }
		else
		  {
		    y[i] = (SCSUINT8_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 71:
	  {
	    SCSINT32_COP *u;
	    SCSINT16_COP *y, k1, k2;
	    u = Getint32InPortPtrs (block, 1);
	    y = Getint16OutPortPtrs (block, 1);
	    k1 = 0x7FFF;
	    k2 = 0x8000;
	    for (i = 0; i < m * n; i++)
	      {
		if ((u[i] > (SCSINT32_COP) k1) | (u[i] < (SCSINT32_COP) k2))
		  {
		    if (flag == 1)
		      {
			sciprint ("overflow error");
			set_block_error (-4);
			return;
		      }
		  }
		else
		  {
		    y[i] = (SCSINT16_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 72:
	  {
	    SCSINT32_COP *u;
	    char *y, k1, k2;
	    u = Getint32InPortPtrs (block, 1);
	    y = Getint8OutPortPtrs (block, 1);
	    k1 = 0x7F;
	    k2 = 0x80;
	    for (i = 0; i < m * n; i++)
	      {
		if ((u[i] > (SCSINT32_COP) k1) | (u[i] < (SCSINT32_COP) k2))
		  {
		    if (flag == 1)
		      {
			sciprint ("overflow error");
			set_block_error (-4);
			return;
		      }
		  }
		else
		  {
		    y[i] = (char) (u[i]);
		  }
	      }
	    break;
	  }
	case 73:
	  {
	    SCSINT32_COP *u;
	    SCSUINT32_COP *y;
	    u = Getint32InPortPtrs (block, 1);
	    y = Getuint32OutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] < 0)
		  {
		    if (flag == 1)
		      {
			sciprint ("overflow error");
			set_block_error (-4);
			return;
		      }
		  }
		else
		  {
		    y[i] = (SCSUINT32_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 74:
	  {
	    SCSINT32_COP *u;
	    SCSUINT16_COP *y, k1;
	    u = Getint32InPortPtrs (block, 1);
	    y = Getuint16OutPortPtrs (block, 1);
	    k1 = 0xFFFF;
	    for (i = 0; i < m * n; i++)
	      {
		if ((u[i] > (SCSINT32_COP) k1) | (u[i] < 0))
		  {
		    if (flag == 1)
		      {
			sciprint ("overflow error");
			set_block_error (-4);
			return;
		      }
		  }
		else
		  {
		    y[i] = (SCSUINT16_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 75:
	  {
	    SCSINT32_COP *u;
	    SCSUINT8_COP *y, k1;
	    u = Getint32InPortPtrs (block, 1);
	    y = Getuint8OutPortPtrs (block, 1);
	    k1 = 0xFF;
	    for (i = 0; i < m * n; i++)
	      {
		if ((u[i] > (SCSINT32_COP) k1) | (u[i] < 0))
		  {
		    if (flag == 1)
		      {
			sciprint ("overflow error");
			set_block_error (-4);
			return;
		      }
		  }
		else
		  {
		    y[i] = (SCSUINT8_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 76:
	  {
	    SCSINT16_COP *u;
	    char *y, k1, k2;
	    u = Getint16InPortPtrs (block, 1);
	    y = Getint8OutPortPtrs (block, 1);
	    k1 = 0x7F;
	    k2 = 0x80;
	    for (i = 0; i < m * n; i++)
	      {
		if ((u[i] > (SCSINT16_COP) k1) | (u[i] < (SCSINT16_COP) k2))
		  {
		    if (flag == 1)
		      {
			sciprint ("overflow error");
			set_block_error (-4);
			return;
		      }
		  }
		else
		  {
		    y[i] = (char) (u[i]);
		  }
	      }
	    break;
	  }
	case 77:
	  {
	    SCSINT16_COP *u;
	    SCSUINT32_COP *y;
	    u = Getint16InPortPtrs (block, 1);
	    y = Getuint32OutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] < 0)
		  {
		    if (flag == 1)
		      {
			sciprint ("overflow error");
			set_block_error (-4);
			return;
		      }
		  }
		else
		  y[i] = (SCSUINT32_COP) u[i];
	      }
	    break;
	  }
	case 78:
	  {
	    SCSINT16_COP *u;
	    SCSUINT16_COP *y;
	    u = Getint16InPortPtrs (block, 1);
	    y = Getuint16OutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] < 0)
		  {
		    if (flag == 1)
		      {
			sciprint ("overflow error");
			set_block_error (-4);
			return;
		      }
		  }
		else
		  {
		    y[i] = (SCSUINT16_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 79:
	  {
	    SCSINT16_COP *u;
	    SCSUINT8_COP *y, k1;
	    u = Getint16InPortPtrs (block, 1);
	    y = Getuint8OutPortPtrs (block, 1);
	    k1 = 0xFF;
	    for (i = 0; i < m * n; i++)
	      {
		if ((u[i] > (SCSINT16_COP) k1) | (u[i] < 0))
		  {
		    if (flag == 1)
		      {
			sciprint ("overflow error");
			set_block_error (-4);
			return;
		      }
		  }
		else
		  {
		    y[i] = (SCSUINT8_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 80:
	  {
	    char *u;
	    SCSUINT32_COP *y;
	    u = Getint8InPortPtrs (block, 1);
	    y = Getuint32OutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] < 0)
		  {
		    if (flag == 1)
		      {
			sciprint ("overflow error");
			set_block_error (-4);
			return;
		      }
		  }
		else
		  y[i] = (SCSUINT32_COP) u[i];
	      }
	    break;
	  }
	case 81:
	  {
	    char *u;
	    SCSUINT16_COP *y;
	    u = Getint8InPortPtrs (block, 1);
	    y = Getuint16OutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] < 0)
		  {
		    if (flag == 1)
		      {
			sciprint ("overflow error");
			set_block_error (-4);
			return;
		      }
		  }
		else
		  {
		    y[i] = (SCSUINT16_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 82:
	  {
	    char *u;
	    SCSUINT8_COP *y;
	    u = Getint8InPortPtrs (block, 1);
	    y = Getuint8OutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] < 0)
		  {
		    if (flag == 1)
		      {
			sciprint ("overflow error");
			set_block_error (-4);
			return;
		      }
		  }
		else
		  {
		    y[i] = (SCSUINT8_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 83:
	  {
	    SCSINT32_COP *y, k1;
	    SCSUINT32_COP *u;
	    u = Getuint32InPortPtrs (block, 1);
	    y = Getint32OutPortPtrs (block, 1);
	    k1 = 0x7FFFFFFF;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (SCSUINT32_COP) k1)
		  {
		    if (flag == 1)
		      {
			sciprint ("overflow error");
			set_block_error (-4);
			return;
		      }
		  }
		else
		  {
		    y[i] = (SCSINT32_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 84:
	  {
	    SCSUINT32_COP *u;
	    SCSINT16_COP *y, k1;
	    u = Getuint32InPortPtrs (block, 1);
	    y = Getint16OutPortPtrs (block, 1);
	    k1 = 0x7FFF;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (SCSUINT32_COP) k1)
		  {
		    if (flag == 1)
		      {
			sciprint ("overflow error");
			set_block_error (-4);
			return;
		      }
		  }
		else
		  {
		    y[i] = (SCSINT16_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 85:
	  {
	    SCSUINT32_COP *u;
	    char *y, k1;
	    u = Getuint32InPortPtrs (block, 1);
	    y = Getint8OutPortPtrs (block, 1);
	    k1 = 0x7F;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (SCSUINT32_COP) k1)
		  {
		    if (flag == 1)
		      {
			sciprint ("overflow error");
			set_block_error (-4);
			return;
		      }
		  }
		else
		  {
		    y[i] = (char) (u[i]);
		  }
	      }
	    break;
	  }
	case 86:
	  {
	    SCSUINT32_COP *u;
	    SCSUINT16_COP *y, k1;
	    u = Getuint32InPortPtrs (block, 1);
	    y = Getuint16OutPortPtrs (block, 1);
	    k1 = 0xFFFF;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (unsigned) k1)
		  {
		    if (flag == 1)
		      {
			sciprint ("overflow error");
			set_block_error (-4);
			return;
		      }
		  }
		else
		  {
		    y[i] = (SCSUINT16_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 87:
	  {
	    SCSUINT32_COP *u;
	    SCSUINT8_COP *y, k1;
	    u = Getuint32InPortPtrs (block, 1);
	    y = Getuint8OutPortPtrs (block, 1);
	    k1 = 0xFF;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (SCSUINT32_COP) k1)
		  {
		    if (flag == 1)
		      {
			sciprint ("overflow error");
			set_block_error (-4);
			return;
		      }
		  }
		else
		  {
		    y[i] = (SCSUINT8_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 88:
	  {
	    SCSUINT16_COP *u;
	    SCSINT16_COP *y, k1;
	    u = Getuint16InPortPtrs (block, 1);
	    y = Getint16OutPortPtrs (block, 1);
	    k1 = 0x7FFF;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (SCSUINT16_COP) k1)
		  {
		    if (flag == 1)
		      {
			sciprint ("overflow error");
			set_block_error (-4);
			return;
		      }
		  }
		else
		  {
		    y[i] = (SCSINT16_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 89:
	  {
	    SCSUINT16_COP *u;
	    char *y, k1;
	    u = Getuint16InPortPtrs (block, 1);
	    y = Getint8OutPortPtrs (block, 1);
	    k1 = 0x7F;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (SCSUINT16_COP) k1)
		  {
		    if (flag == 1)
		      {
			sciprint ("overflow error");
			set_block_error (-4);
			return;
		      }
		  }
		else
		  {
		    y[i] = (char) (u[i]);
		  }
	      }
	    break;
	  }
	case 90:
	  {
	    SCSUINT16_COP *u;
	    SCSUINT8_COP *y, k1;
	    u = Getuint16InPortPtrs (block, 1);
	    y = Getuint8OutPortPtrs (block, 1);
	    k1 = 0xFF;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (SCSUINT16_COP) k1)
		  {
		    if (flag == 1)
		      {
			sciprint ("overflow error");
			set_block_error (-4);
			return;
		      }
		  }
		else
		  {
		    y[i] = (SCSUINT8_COP) (u[i]);
		  }
	      }
	    break;
	  }
	case 91:
	  {
	    SCSUINT8_COP *u;
	    char *y, k1;
	    u = Getuint8InPortPtrs (block, 1);
	    y = Getint8OutPortPtrs (block, 1);
	    k1 = 0x7F;
	    for (i = 0; i < m * n; i++)
	      {
		if (u[i] > (SCSUINT8_COP) k1)
		  {
		    if (flag == 1)
		      {
			sciprint ("overflow error");
			set_block_error (-4);
			return;
		      }
		  }
		else
		  {
		    y[i] = (char) (u[i]);
		  }
	      }
	    break;
	  }
	case 92:
	  {
	    double *u;
	    SCSINT32_COP *y;
	    u = GetRealInPortPtrs (block, 1);
	    y = GetBoolOutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		if (*(u + i) == 0)
		  *(y + i) = (SCSINT32_COP) 0;
		else
		  *(y + i) = (SCSINT32_COP) 1;
	      }
	    break;
	  }
	case 93:
	  {
	    SCSINT32_COP *u;
	    SCSINT32_COP *y;
	    u = Getint32InPortPtrs (block, 1);
	    y = GetBoolOutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		if (*(u + i) == 0)
		  *(y + i) = (SCSINT32_COP) 0;
		else
		  *(y + i) = (SCSINT32_COP) 1;
	      }
	    break;
	  }
	case 94:
	  {
	    SCSINT16_COP *u;
	    SCSINT32_COP *y;
	    u = Getint16InPortPtrs (block, 1);
	    y = GetBoolOutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		if (*(u + i) == 0)
		  *(y + i) = (SCSINT32_COP) 0;
		else
		  *(y + i) = (SCSINT32_COP) 1;
	      }
	    break;
	  }
	case 95:
	  {
	    char *u;
	    SCSINT32_COP *y;
	    u = Getint8InPortPtrs (block, 1);
	    y = GetBoolOutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		if (*(u + i) == 0)
		  *(y + i) = (SCSINT32_COP) 0;
		else
		  *(y + i) = (SCSINT32_COP) 1;
	      }
	    break;
	  }
	case 96:
	  {
	    SCSINT32_COP *u;
	    double *y;
	    u = GetBoolInPortPtrs (block, 1);
	    y = GetRealOutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		*(y + i) = (double) *(u + i);
	      }
	    break;
	  }
	case 97:
	  {
	    SCSINT32_COP *u;
	    SCSINT16_COP *y;
	    u = GetBoolInPortPtrs (block, 1);
	    y = Getint16OutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		*(y + i) = (SCSINT16_COP) * (u + i);
	      }
	    break;
	  }
	case 98:
	  {
	    SCSINT32_COP *u;
	    char *y;
	    u = GetBoolInPortPtrs (block, 1);
	    y = Getint8OutPortPtrs (block, 1);
	    for (i = 0; i < m * n; i++)
	      {
		*(y + i) = (char) *(u + i);
	      }
	    break;
	  }
	}
    }
}
