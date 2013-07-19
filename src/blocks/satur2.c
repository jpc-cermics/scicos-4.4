#include "blocks.h"

#define DECLARA(typeu,typey)					 \
  void satur_dyn_##typeu##_##typey (scicos_block *block,int flag)\
  {								 \
   /* u1[0]:upper limit, u3[1]:lower limit */			 \
   								 \
   double *g = GetGPtrs(block);					 \
   int ng = GetNg(block);					 \
   								 \
   int *mode = GetModePtrs(block);				 \
   								 \
   typeu *up   = (typeu *)GetInPortPtrs(block, 1);		 \
   typeu *down = (typeu *)GetInPortPtrs(block, 3);		 \
   typeu *u    = (typeu *)GetInPortPtrs(block, 2);		 \
   								 \
   typey *y = (typey *)GetOutPortPtrs(block, 1);		 \
   								 \
   if (flag == 1) {						 \
     /* TODO check up>down ? */					 \
     if (!areModesFixed(block) || ng == 0) {			 \
       if (*u >= *up)        *y = (typey) *up;			 \
       else if (*u <= *down) *y = (typey) *down;		 \
       else                  *y = (typey) *u;			 \
     } else {							 \
       if (*mode == 1)      *y = (typey) *up;			 \
       else if (*mode == 2) *y = (typey) *down;			 \
       else                 *y = (typey) *u;			 \
     }								 \
   }								 \
   else if (flag == 9) {					 \
     g[0] = (double) (*u - *up);				 \
     g[1] = (double) (*u - *down);				 \
     if (!areModesFixed(block)) {				 \
       if (g[0] >= 0)      *mode = 1;				 \
       else if (g[1] <= 0) *mode = 2;				 \
       else                *mode = 3;				 \
     }								 \
   }								 \
 }

DECLARA(SCSREAL_COP,SCSREAL_COP)
DECLARA(SCSREAL_COP,SCSINT32_COP)
DECLARA(SCSREAL_COP,SCSINT16_COP)
DECLARA(SCSREAL_COP,SCSINT8_COP)
DECLARA(SCSREAL_COP,SCSUINT32_COP)
DECLARA(SCSREAL_COP,SCSUINT16_COP)
DECLARA(SCSREAL_COP,SCSUINT8_COP)

DECLARA(SCSINT32_COP,SCSREAL_COP)
DECLARA(SCSINT32_COP,SCSINT32_COP)
DECLARA(SCSINT32_COP,SCSINT16_COP)
DECLARA(SCSINT32_COP,SCSINT8_COP)
DECLARA(SCSINT32_COP,SCSUINT32_COP)
DECLARA(SCSINT32_COP,SCSUINT16_COP)
DECLARA(SCSINT32_COP,SCSUINT8_COP)

DECLARA(SCSINT16_COP,SCSREAL_COP)
DECLARA(SCSINT16_COP,SCSINT32_COP)
DECLARA(SCSINT16_COP,SCSINT16_COP)
DECLARA(SCSINT16_COP,SCSINT8_COP)
DECLARA(SCSINT16_COP,SCSUINT32_COP)
DECLARA(SCSINT16_COP,SCSUINT16_COP)
DECLARA(SCSINT16_COP,SCSUINT8_COP)

DECLARA(SCSINT8_COP,SCSREAL_COP)
DECLARA(SCSINT8_COP,SCSINT32_COP)
DECLARA(SCSINT8_COP,SCSINT16_COP)
DECLARA(SCSINT8_COP,SCSINT8_COP)
DECLARA(SCSINT8_COP,SCSUINT32_COP)
DECLARA(SCSINT8_COP,SCSUINT16_COP)
DECLARA(SCSINT8_COP,SCSUINT8_COP)

DECLARA(SCSUINT32_COP,SCSREAL_COP)
DECLARA(SCSUINT32_COP,SCSINT32_COP)
DECLARA(SCSUINT32_COP,SCSINT16_COP)
DECLARA(SCSUINT32_COP,SCSINT8_COP)
DECLARA(SCSUINT32_COP,SCSUINT32_COP)
DECLARA(SCSUINT32_COP,SCSUINT16_COP)
DECLARA(SCSUINT32_COP,SCSUINT8_COP)

DECLARA(SCSUINT16_COP,SCSREAL_COP)
DECLARA(SCSUINT16_COP,SCSINT32_COP)
DECLARA(SCSUINT16_COP,SCSINT16_COP)
DECLARA(SCSUINT16_COP,SCSINT8_COP)
DECLARA(SCSUINT16_COP,SCSUINT32_COP)
DECLARA(SCSUINT16_COP,SCSUINT16_COP)
DECLARA(SCSUINT16_COP,SCSUINT8_COP)

DECLARA(SCSUINT8_COP,SCSREAL_COP)
DECLARA(SCSUINT8_COP,SCSINT32_COP)
DECLARA(SCSUINT8_COP,SCSINT16_COP)
DECLARA(SCSUINT8_COP,SCSINT8_COP)
DECLARA(SCSUINT8_COP,SCSUINT32_COP)
DECLARA(SCSUINT8_COP,SCSUINT16_COP)
DECLARA(SCSUINT8_COP,SCSUINT8_COP)

#undef DECLARA

void satur_dyn(scicos_block * block, int flag)
{
  /* u1[0]:upper limit, u3[1]:lower limit */
  
  double *g = GetGPtrs(block);
  int ng = GetNg(block);
  
  int *mode = GetModePtrs(block);
  
  SCSREAL_COP *up   = GetRealInPortPtrs(block, 1);
  SCSREAL_COP *down = GetRealInPortPtrs(block, 3);
  SCSREAL_COP *u    = GetRealInPortPtrs(block, 2);
  
  SCSREAL_COP *y = GetRealOutPortPtrs(block, 1);

  if (flag == 1) {
    /* TODO check up>down ? */
    if (!areModesFixed(block) || ng == 0) {
      if (*u >= *up)        *y = (SCSREAL_COP) *up;
      else if (*u <= *down) *y = (SCSREAL_COP) *down;
      else                  *y = (SCSREAL_COP) *u;
    } else {
      if (*mode == 1)      *y = (SCSREAL_COP) *up;
      else if (*mode == 2) *y = (SCSREAL_COP) *down;
      else                 *y = (SCSREAL_COP) *u;
    }
  }
  else if (flag == 9) {
    g[0] = (double) (*u - *up);
    g[1] = (double) (*u - *down);
    if (!areModesFixed(block)) {
      if (g[0] >= 0)      *mode = 1;
      else if (g[1] <= 0) *mode = 2;
      else                *mode = 3;
    }
  }
}
