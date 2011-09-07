
#include <nsp/nsp.h> 
#include <scicos/scicos4.h>
#include <scicos/blocks.h>

void *scicos_malloc (size_t size)
{
  return malloc (size);
}

void scicos_free (void *p)
{
  free (p);
}

/*
 *    mtran transpose matrice a in matrix b 
 *    a et b do not share memory.
 *    na       nombre de ligne du tableau a dans le prog appelant 
 *    b,nb     definition similaire a celle de a,na 
 *    m        nombre de lignes de a et de colonnes de b 
 *    n        nombre de colonnes de a et de lignes de b 
 *!sous programmes utilises 
 *    neant 
 *! 
 * 
 */

int scicos_mtran (double *a, int na, double *b, int nb, int m, int n)
{
  int i, j, ia = 0, ib;
  ia = 0;
  for (j = 0; j < n; ++j)
    {
      ib = j;
      for (i = 0; i < m; ++i)
	{
	  b[ib] = a[ia + i];
	  ib += nb;
	}
      ia += na;
    }
  return 0;
}

/* the following function can be called from Modelica 
 * generated code 
 */

double exp_(double x) 
{
  return exp(x);
}

double log_(double x)
{
  return log(x);
}

double pow_(double x, double y)
{
  return pow(x,y);
}
