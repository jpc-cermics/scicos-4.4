#include "blocks.h"

#define DECLARA(typeu,typey)					\
  void logic2_##typeu##_##typey (scicos_block *block,int flag)	\
  {								\
    typeu *u = (typeu *)GetInPortPtrs(block,1);			\
    typey *y = (typey *)GetOutPortPtrs(block,1);		\
    typey *opar = (typey *)GetOparPtrs(block,1);		\
    								\
    int nu = GetInPortSize (block, 1, 1);			\
    int no = GetOparSize (block, 1, 1);				\
    int mo = GetOparSize (block, 1, 2);				\
    								\
    int inp, num;						\
    int i;							\
    								\
    if ((flag == 1) || (flag == 6)) {				\
      /* compute row index */					\
      num = 0;							\
      for (i = 0; i < nu; i++) {				\
        inp = (int) u[nu-1-i];					\
        if (inp > 0)						\
          inp = 1;						\
        else							\
          inp = 0;						\
        inp = inp << i;						\
        num = num + inp;					\
      }								\
      								\
      /* copy values of the truth table in output */		\
      for (i = 0; i < mo; i++) {      				\
        y[i] = opar[num + i * no];				\
      }								\
    }								\
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

void logic2(scicos_block * block, int flag)
{
  
  SCSREAL_COP *u = GetRealInPortPtrs(block,1); 
  SCSREAL_COP *y = GetRealOutPortPtrs(block,1); 
  SCSREAL_COP *opar = GetRealOparPtrs(block,1); 
  
  int nu = GetInPortSize (block, 1, 1);
  int no = GetOparSize (block, 1, 1);
  int mo = GetOparSize (block, 1, 2);
  
  int inp, num;
  int i;
   
  if ((flag == 1) || (flag == 6)) {
    /* compute row index */
    num = 0;
    for (i = 0; i < nu; i++) {
      inp = (int) u[nu-1-i];
      if (inp > 0)
        inp = 1;
      else
         inp = 0;
      inp = inp << i;
      num = num + inp;
    }
    
    /* copy values of the truth table in output */
    for (i = 0; i < mo; i++) {      
      y[i] = opar[num + i * no];
    }
  }
  
}
