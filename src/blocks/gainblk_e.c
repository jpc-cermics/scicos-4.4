#include "blocks.h"

#define GAINBLK_e(name, type, inport, outport, getopar,bits )		\
  void name (scicos_block * block, int flag)				\
  {									\
    if ((flag == 1) | (flag == 6))					\
      {									\
	int i, j, l, ji, jl, il;					\
	type *u, *y;							\
	int mu, ny, my, mo, no;						\
	type *opar;							\
	double k, D, C;							\
									\
	mo = GetOparSize (block, 1, 1);					\
	no = GetOparSize (block, 1, 2);					\
	mu = GetInPortRows (block, 1);					\
	my = GetOutPortRows (block, 1);					\
	ny = GetOutPortCols (block, 1);					\
	u = inport (block, 1);						\
	y = outport (block, 1);						\
	opar = getopar (block, 1);					\
									\
	k = pow (2, bits) / 2;						\
	if (mo * no == 1)						\
	  {								\
	    for (i = 0; i < ny * mu; ++i)				\
	      {								\
		D = (double) (opar[0]) * (double) (u[i]);		\
		if ((D >= k) | (D < -k))				\
		  {							\
		    sciprint ("overflow error");			\
		    set_block_error (-4);				\
		    return;						\
		  }							\
		else							\
		  y[i] = (type) D;					\
	      }								\
	  }								\
	else								\
	  {								\
	    for (l = 0; l < ny; l++)					\
	      {								\
		for (j = 0; j < my; j++)				\
		  {							\
		    D = 0;						\
		    jl = j + l * my;					\
		    for (i = 0; i < mu; i++)				\
		      {							\
			ji = j + i * my;				\
			il = i + l * mu;				\
			C = (double) (opar[ji]) * (double) (u[il]);	\
			D = D + C;					\
		      }							\
		    if ((D >= k) | (D < -k))				\
		      {							\
			sciprint ("overflow error");			\
			set_block_error (-4);				\
			return;						\
		      }							\
		    else						\
		      y[jl] = (type) D;					\
		  }							\
	      }								\
	  }								\
      }									\
  }

GAINBLK_e(gainblk_i32e,SCSINT32_COP ,Getint32InPortPtrs, Getint32OutPortPtrs, Getint32OparPtrs, 32 )
GAINBLK_e(gainblk_ui32e,SCSUINT32_COP ,Getuint32InPortPtrs, Getuint32OutPortPtrs, Getuint32OparPtrs,32 )

GAINBLK_e(gainblk_i16e,SCSINT16_COP ,Getint16InPortPtrs, Getint16OutPortPtrs, Getint16OparPtrs, 16 )
GAINBLK_e(gainblk_ui16e,SCSUINT16_COP ,Getuint16InPortPtrs, Getuint16OutPortPtrs, Getuint16OparPtrs,16 )

GAINBLK_e(gainblk_i8e, SCSINT8_COP, Getint8InPortPtrs, Getint8OutPortPtrs, Getint8OparPtrs,8 )
GAINBLK_e(gainblk_ui8e,SCSUINT8_COP , Getuint8InPortPtrs, Getuint8OutPortPtrs, Getuint8OparPtrs,8 )


#define GAINBLK_tt_e(name, type, inport, outport, getopar,bits )	\
  void name (scicos_block * block, int flag)				\
  {									\
    if ((flag == 1) | (flag == 6))					\
      {									\
	int i;							\
	type *u, *y;							\
	int mu, nu, mo, no;						\
	type *opar;							\
	double k, D;							\
									\
	mo = GetOparSize (block, 1, 1);					\
	no = GetOparSize (block, 1, 2);					\
	mu = GetInPortRows (block, 1);					\
	nu = GetInPortCols (block, 1);					\
	u = inport (block, 1);						\
	y = outport (block, 1);						\
	opar = getopar (block, 1);					\
									\
	k = pow (2, bits) / 2;						\
	if (mo * no == 1)						\
	  {								\
	    for (i = 0; i < nu * mu; ++i)				\
	      {								\
		D = (double) (opar[0]) * (double) (u[i]);		\
		if ((D >= k) | (D < -k))				\
		  {							\
		    sciprint ("overflow error");			\
		    set_block_error (-4);				\
		    return;						\
		  }							\
		else							\
		  y[i] = (type) D;					\
	      }								\
	  }								\
	else								\
	  {								\
	    for (i = 0; i < nu * mu; ++i)				\
	      {								\
		D = (double) (opar[i]) * (double) (u[i]);		\
		if ((D >= k) | (D < -k))				\
		  {							\
		    sciprint ("overflow error");			\
		    set_block_error (-4);				\
		    return;						\
		  }							\
		else							\
		  y[i] = (type) D;					\
	      }								\
	  }								\
      }									\
  }

GAINBLK_tt_e(gainblk_i32e_tt,SCSINT32_COP ,Getint32InPortPtrs, Getint32OutPortPtrs, Getint32OparPtrs, 32 )
GAINBLK_tt_e(gainblk_ui32e_tt,SCSUINT32_COP ,Getuint32InPortPtrs, Getuint32OutPortPtrs, Getuint32OparPtrs,32 )

GAINBLK_tt_e(gainblk_i16e_tt,SCSINT16_COP ,Getint16InPortPtrs, Getint16OutPortPtrs, Getint16OparPtrs, 16 )
GAINBLK_tt_e(gainblk_ui16e_tt,SCSUINT16_COP ,Getuint16InPortPtrs, Getuint16OutPortPtrs, Getuint16OparPtrs,16 )

GAINBLK_tt_e(gainblk_i8e_tt, SCSINT8_COP, Getint8InPortPtrs, Getint8OutPortPtrs, Getint8OparPtrs,8 )
GAINBLK_tt_e(gainblk_ui8e_tt,SCSUINT8_COP , Getuint8InPortPtrs, Getuint8OutPortPtrs, Getuint8OparPtrs,8 )
