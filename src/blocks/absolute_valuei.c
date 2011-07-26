#include "blocks.h"


#define DECLARA(type_uy)					\
  void absolute_valuei_##type_uy (scicos_block *block,int flag) \
  {								\
    type_uy *_u1=(type_uy *)GetInPortPtrs(block,1);		\
    type_uy *_y1=(type_uy *)GetOutPortPtrs(block,1);		\
    int i,nxm=GetInPortRows(block,1)*GetInPortCols(block,1);	\
    if (flag == 1) {						\
      for(i=0;i<nxm;++i){					\
	if (_u1[i]<0){						\
	  _y1[i]=-_u1[i];					\
	} else{							\
	  _y1[i]=_u1[i];					\
	}							\
      }								\
    }								\
  }

DECLARA(SCSINT32_COP)
DECLARA(SCSINT16_COP)
DECLARA(SCSINT8_COP)
DECLARA(SCSUINT32_COP)
DECLARA(SCSUINT16_COP)
DECLARA(SCSUINT8_COP)

#undef DECLARA

void  absolute_valuei_SCSREAL_COP(scicos_block *block,int flag)
{
  int ng=GetNg(block);
  double *g=GetGPtrs(block);
  int *mode=GetModePtrs(block);
  double *u1=GetRealInPortPtrs(block,1);
  double *y1=GetRealOutPortPtrs(block,1);
  int i,side;
  int nxm=GetInPortRows(block,1)*GetInPortCols(block,1);
  
  switch(flag) 
    {
    case 1:
      for(i=0;i<nxm;++i)
	{
	  if (!areModesFixed(block) || ng==0) 
	    {
	      side=(u1[i]<0) ? 2: 1;
	    }
	  else 
	    {
	      side=mode[i];
	    }
	  y1[i] = (side==1) ? u1[i] : -u1[i];
	}
      break;
    case 9:
      for(i=0;i<nxm;++i)
	{
	  g[i]=u1[i];
	  if (!areModesFixed(block)) 
	    mode[i]=(g[i]<0) ? 2: 1;
	}
    }
}
