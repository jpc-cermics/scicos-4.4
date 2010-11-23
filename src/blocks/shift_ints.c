# include "blocks.h"

/* shift left */

#define SHIFT_LA(tag, type)					\
  void CNAME(shift_,tag) (scicos_block * block, int flag)	\
  {								\
    int i;							\
    int *ipar=  GetIparPtrs (block);				\
    int mu = GetInPortRows (block, 1);				\
    int nu = GetInPortCols (block, 1);				\
    type *u = (type *) GetInPortPtrs (block, 1);		\
    type *y = (type *) GetOutPortPtrs (block, 1);		\
    for (i = 0; i < mu * nu; i++)				\
      y[i] = u[i] << ipar[0];					\
  }

SHIFT_LA(8_LA, gint8)
SHIFT_LA(16_LA, gint16)
SHIFT_LA(32_LA, gint)

#undef SHIFT_LA

/* shift right */

#define SHIFT_RA(tag, type)					\
  void CNAME(shift_,tag) (scicos_block * block, int flag)	\
  {								\
    int  i;							\
    int mu = GetInPortRows (block, 1);				\
    int nu = GetInPortCols (block, 1);				\
    type *u = (type *) GetInPortPtrs (block, 1);		\
    type *y = (type *) GetOutPortPtrs (block, 1);		\
    int *ipar = GetIparPtrs (block);				\
    for (i = 0; i < mu * nu; i++)				\
      y[i] = u[i] >> (-ipar[0]);				\
  }

SHIFT_RA(8_RA, gint8)
SHIFT_RA(16_RA, gint16)
SHIFT_RA(32_RA, gint)
SHIFT_RA(u8_RA, guint8)
SHIFT_RA(u16_RA, guint16)
SHIFT_RA(u32_RA, guint)

#undef SHIFT_RA

/* shift right */

#define SHIFT_RC(tag, type,type1, nbits)			\
  void CNAME(shift_,tag) (scicos_block * block, int flag)	\
  {								\
    int  i, j;							\
    int mu = GetInPortRows (block, 1);				\
    int nu = GetInPortCols (block, 1);				\
    type v;							\
    type1 k= (type1) pow (2, nbits - 1);			\
    type *u = (type *) GetInPortPtrs (block, 1);		\
    type *y = (type *) GetOutPortPtrs (block, 1);		\
    int *ipar = GetIparPtrs (block);				\
    for (i = 0; i < mu * nu; i++)				\
      {								\
	v = u[i];						\
	for (j = 0; j < -ipar[0]; j++)				\
	  {							\
	    y[i] = v & 1;					\
	    if (y[i] == 0)					\
	      {							\
		y[i] = v >> 1;					\
		y[i] = y[i] & (k - 1);				\
	      }							\
	    else						\
	      {							\
		y[i] = v >> 1;					\
		y[i] = (y[i]) | (k);				\
	      }							\
	    v = y[i];						\
	  }							\
      }								\
  }

SHIFT_RC(8_RC, gint8,guint8, 8)
SHIFT_RC(16_RC, gint16,guint16, 16)
SHIFT_RC(32_RC, gint,guint, 32)

#undef SHIFT_RC 

/* shift left */

#define SHIFT_LC(tag, type,type1,nbits)				\
  void CNAME(shift_,tag) (scicos_block * block, int flag)	\
  {								\
    type1 k= (type1) pow (2, nbits - 1);			\
    type v;							\
    type *u = (type *)GetInPortPtrs (block, 1);			\
    type *y = (type *)GetOutPortPtrs (block, 1);     		\
    int i, j;							\
    int mu = GetInPortRows (block, 1);				\
    int nu = GetInPortCols (block, 1);				\
    int *ipar = GetIparPtrs (block);				\
    for (i = 0; i < mu * nu; i++)				\
      {								\
	v = u[i];						\
	for (j = 0; j < ipar[0]; j++)				\
	  {							\
	    y[i] = v & k;					\
	    if (y[i] == 0)					\
	      y[i] = v << 1;					\
	    else						\
	      {							\
		y[i] = v << 1;					\
		y[i] = (y[i]) | (1);				\
	      }							\
	    v = y[i];						\
	  }							\
      }								\
  }


SHIFT_LC(8_LC, gint8,guint8, 8)
SHIFT_LC(16_LC, gint16,guint16, 16)
SHIFT_LC(32_LC, gint,guint, 32)


#undef SHIFT_LC
 
