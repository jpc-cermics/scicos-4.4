#include "blocks.h"


#define DECLARA(type_u2)					\
  void switch2_##type_u2 (scicos_block *block,int flag)		\
  {								\
    int i=0,j,k,l;					       	\
    char *u;							\
    int *iparptrs=GetIparPtrs(block);				\
    int ipar =*iparptrs;					\
    type_u2 *thres=(type_u2 *)GetOparPtrs(block,1);		\
    int mu=GetInPortRows(block,1);				\
    int nu=GetInPortCols(block,1);				\
    int mu2=GetInPortRows(block,2);				\
    int nu2=GetInPortCols(block,2);				\
    type_u2 *u2=(type_u2 *)GetInPortPtrs(block,2);		\
    char *y=(char *)GetOutPortPtrs(block,1);			\
    int so=GetSizeOfOut(block,1);				\
    if (flag == 1) {						\
      if (mu2*nu2==1) so=so*mu*nu;				\
      k=0;							\
      for (j=0;j<mu2*nu2;j++) {					\
	i=3;							\
	if (ipar==0){						\
	  if (u2[j]>=thres[j]) i=1;				\
	}else if (ipar==1){					\
	  if (u2[j]>thres[j]) i=1;				\
	}else {							\
	  if (u2[j]!=thres[j]) i=1;				\
	}							\
	u=(char *)GetInPortPtrs(block,i);			\
	for (l=0;l<so;l++){					\
	  y[k+l]=u[k+l];					\
	}							\
	k=k+l;							\
      }								\
    }								\
  }

DECLARA (SCSINT32_COP)
DECLARA (SCSINT16_COP)
DECLARA (SCSINT8_COP)
DECLARA (SCSUINT32_COP) 
DECLARA (SCSUINT16_COP) 
DECLARA (SCSUINT8_COP)

#undef DECLARA
void switch2_SCSREAL_COP (scicos_block * block, int flag)
{
  int i = 0, j, k, l;
  int ng = GetNg (block);
  double *g = GetGPtrs (block);
  int *mode = GetModePtrs (block);
  char *yc = NULL, *u;
  int *iparptrs = GetIparPtrs (block);
  int ipar = *iparptrs;
  double *rpar = GetRparPtrs (block);
  int mu = GetInPortRows (block, 1);
  int nu = GetInPortCols (block, 1);
  int mu2 = GetInPortRows (block, 2);
  int nu2 = GetInPortCols (block, 2);
  double *u2 = GetRealInPortPtrs (block, 2);
  char *y = (char *) GetOutPortPtrs (block, 1);
  int so = GetSizeOfOut (block, 1);

  if (flag == 1)
    {
      if (GetInType (block, 1) == SCSCOMPLEX_N)
	yc = (char *) GetImagOutPortPtrs (block, 1);
      if (mu2 * nu2 == 1)
	so = so * mu * nu;	/* scalar control input */
      k = 0;
      for (j = 0; j < mu2 * nu2; j++)
	{
	  if (!areModesFixed (bloc) || ng == 0)
	    {
	      i = 3;
	      if (ipar == 0)
		{
		  if (u2[j] >= rpar[j])
		    i = 1;
		}
	      else if (ipar == 1)
		{
		  if (u2[j] > rpar[j])
		    i = 1;
		}
	      else
		{
		  if (u2[j] != rpar[j])
		    i = 1;
		}
	    }
	  else
	    {
	      if (mode[j] == 1)
		{
		  i = 1;
		}
	      else if (mode[j] == 2)
		{
		  i = 3;
		}
	    }
	  u = (char *) GetInPortPtrs (block, i);
	  for (l = 0; l < so; l++)
	    {
	      y[k + l] = u[k + l];
	    }
	  if (GetInType (block, 1) == SCSCOMPLEX_N)
	    {
	      u = (char *) GetImagInPortPtrs (block, i);
	      for (l = 0; l < so; l++)
		{
		  yc[k + l] = u[k + l];
		}
	    }
	  k = k + l;
	}
    }
  else if (flag == 9)
    {
      for (j = 0; j < mu2 * nu2; j++)
	{
	  g[j] = u2[j] - rpar[j];
	  if (!areModesFixed (phase))
	    {
	      mode[j] = 2;
	      if (ipar == 0)
		{
		  if (g[j] >= 0.0)
		    mode[j] = 1;
		}
	      else if (ipar == 1)
		{
		  if (g[j] > 0.0)
		    mode[j] = 1;
		}
	      else
		{
		  if (g[j] != 0.0)
		    mode[j] = 1;
		}
	    }
	}
    }
}
