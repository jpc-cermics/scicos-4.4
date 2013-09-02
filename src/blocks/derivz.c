#include "blocks.h"

/*
#define DECLARA(type_u)					\
  void derivz_##type_u(scicos_block * block, int flag)  \
  {							\
    type_u *u = GetInPortPtrs(block, 1);		\
    type_u *y = GetOutPortPtrs(block, 1);		\
    							\
    int n = GetInPortRows(block, 1);			\
    int m = GetInPortCols(block, 1);			\
    							\
    type_u *K    = GetOparPtrs(block, 1);		\
    type_u *maxp = GetOparPtrs(block, 2);		\
    type_u *minp = GetOparPtrs(block, 3);		\
    							\
    type_u *init = GetOzPtrs(block,1);			\
    							\
    int *satur = GetIparPtrs(block);			\
    							\
    double *z = GetDstate(block);			\
    							\
    double t = GetScicosTime(block);			\
    							\
    int i;						\
    							\
    if (flag == 4) {					\
      *z=t;						\
    }							\
    else if (flag == 1) {				\
      if (t>*z) {					\
        double diff_t = (t-*z);				\
        double a = ((double) *K)/diff_t;		\
        for(i=0;i<m*n;i++) {				\
          y[i]=((type_u) a)*u[i] - init[i];		\
        }						\
        if (satur) {					\
          for(i=0;i<m*n;i++) {				\
            if (y[i]<*minp) y[i]=*minp;			\
            else if (y[i]>*maxp) y[i]=*maxp;		\
          }						\
        }						\
      }							\
    }							\
    else if (flag == 2) {				\
      if (t>*z) {					\
        double diff_t = (t-*z);				\
        double a = ((double) *K)/diff_t;		\
        for(i=0;i<m*n;i++) {				\
          init[i]=((type_u) a)*u[i];			\
        }						\
        *z=t;						\
      }							\
    }							\
  }

DECLARA(SCSINT32_COP)
DECLARA(SCSINT16_COP)
DECLARA(SCSINT8_COP)
DECLARA(SCSUINT32_COP) 
DECLARA(SCSUINT16_COP) 
DECLARA(SCSUINT8_COP)

#undef DECLARA
*/

void derivz_SCSREAL_COP(scicos_block * block, int flag)
{
  SCSREAL_COP *u = GetRealInPortPtrs(block, 1);
  SCSREAL_COP *y = GetRealOutPortPtrs(block, 1);
  
  int n = GetInPortRows(block, 1);
  int m = GetInPortCols(block, 1);
  
  SCSREAL_COP *K    = GetOparPtrs(block, 1);
  SCSREAL_COP *maxp = GetOparPtrs(block, 2);
  SCSREAL_COP *minp = GetOparPtrs(block, 3);
    
  SCSREAL_COP *init = GetOzPtrs(block,1);
  
  int *satur = GetIparPtrs(block);
  
  double *z = GetDstate(block);
  
  double t = GetScicosTime(block);

  int i;
  
  if (flag == 4) {
    *z=t;
  }
  else if (flag == 1) {
    if (t>*z) {
      double diff_t = (t-*z);
      double a = ((double) *K)/diff_t;
      for(i=0;i<m*n;i++) {
        y[i]=((SCSREAL_COP) a)*u[i] - init[i];
      }
      if (satur) {
        for(i=0;i<m*n;i++) {
	  if (y[i]<*minp) y[i]=*minp;
	  else if (y[i]>*maxp) y[i]=*maxp;
	}
      }
    }
  }
  else if (flag == 2) {
    if (t>*z) {
      double diff_t = (t-*z);
      double a = ((double) *K)/diff_t;
      for(i=0;i<m*n;i++) {
        init[i]=((SCSREAL_COP) a)*u[i];
      }
      *z=t;
    }
  }
}
 
