#include "blocks.h"


void matztran_m (scicos_block * block, int flag)
{
  double *ur;
  double *yr;
  double *ui;
  double *yi;
  int nu, mu;

  nu = GetInPortRows (block, 1);
  mu = GetInPortCols (block, 1);

  ur = GetRealInPortPtrs (block, 1);
  ui = GetImagInPortPtrs (block, 1);
  yr = GetRealOutPortPtrs (block, 1);
  yi = GetImagOutPortPtrs (block, 1);
  scicos_mtran (ur, nu, yr, mu, nu, mu);
  scicos_mtran (ui, nu, yi, mu, nu, mu);
}
