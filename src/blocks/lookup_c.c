#include "blocks.h"

/*    Masoud Najafi, January 2008 */
/*    Copyright INRIA
 *    Scicos block simulator
 *    Lookup table block
 */

int FindIndex (int, double, int, int, double *, int);

int Myevalhermite (const double *t, double *xa, double *xb, double *ya,
		   double *yb, double *da, double *db, double *h, double *dh,
		   double *ddh, double *dddh, int *i);

void lookup_c (scicos_block * block, int flag)
{
  void **_work = GetPtrWorkPtrs (block);
  double *_rpar = GetRparPtrs (block);
  int *_ipar = GetIparPtrs (block);
  /* double *_evout= GetNevOutPtrs(block); */
  double a, b, c, y1, y2, t1, t2, *RPAR; /* T;*/
  int *ind, inow, i, ip1, nPoints, Order, /* Periodic,*/ Extrapo;
  double *y, *u, u0;
  double d1, d2, h, dh, ddh, dddh;

  RPAR = _rpar;
  nPoints = _ipar[0];
  Order = _ipar[1];
  /* Periodic = _ipar[2]; */
  Extrapo = _ipar[3];
  /* T = RPAR[nPoints - 1] - RPAR[0]; */

  switch (flag)
    {
      /* init */
    case 4:
      {				/* the workspace is used to store discrete counter value */
	if ((*_work = scicos_malloc (1 * sizeof (int))) == NULL)
	  {
	    set_block_error (-16);
	    return;
	  }
	ind = *_work;
	ind[0] = 0;

	return;
      }
      /* event date computation */
    case 1:
      {
	y = GetRealOutPortPtrs (block, 1);
	u = GetRealInPortPtrs (block, 1);
	u0 = u[0];
	ind = *_work;
	i = ind[0];
	ip1 = i + 1;

	if ((Extrapo == 0)
	    || ((Extrapo == 1)
		&& ((Order == 0) || (Order == 8) || (Order == 9))))
	  {
	    if (u0 < RPAR[0])
	      {
		y[0] = RPAR[nPoints];
		break;
	      }
	    if (u0 >= RPAR[nPoints - 1])
	      {
		y[0] = RPAR[nPoints * 2 - 1];
		break;
	      }
	  }

	if (u0 < RPAR[i])
	  {
	    i = FindIndex (Order, u0, 0, i, RPAR, nPoints);
	    ip1 = i + 1;
	  }
	else if (u0 >= RPAR[ip1])
	  {
	    i = FindIndex (Order, u0, ip1, nPoints - 1, RPAR, nPoints);
	    ip1 = i + 1;
	  }
	ind[0] = i;

	if (Order == 0)
	  {			/* (METHOD=='zero order-below') */
	    y[0] = RPAR[nPoints + i];
	    break;
	  }

	if (Order == 8)
	  {			/* (METHOD=='zero order-above') */
	    y[0] = RPAR[nPoints + i + 1];
	    break;
	  }

	if (Order == 9)
	  {			/* (METHOD=='zero order-nearest') */
	    if (u0 < (RPAR[i] + RPAR[i + 1]) / 2)
	      y[0] = RPAR[nPoints + i];
	    else
	      y[0] = RPAR[nPoints + i + 1];
	    break;
	  }

	if (Order == 1)
	  {
	    t1 = RPAR[i];
	    t2 = RPAR[i + 1];
	    y1 = RPAR[nPoints + i];
	    y2 = RPAR[nPoints + i + 1];
	    y[0] = (y2 - y1) * (u0 - t1) / (t2 - t1) + y1;
	    break;
	  }

	if ((Order == 2) && (nPoints > 2))
	  {
	    t1 = RPAR[i];
	    a = RPAR[2 * nPoints + i];
	    b = RPAR[2 * nPoints + i + nPoints - 1];
	    c = RPAR[2 * nPoints + i + 2 * nPoints - 2];
	    y[0] = a * (u0 - t1) * (u0 - t1) + b * (u0 - t1) + c;
	    break;
	  }

	if ((Order >= 3) && (Order <= 7))
	  {
	    t1 = RPAR[i];
	    t2 = RPAR[i + 1];
	    y1 = RPAR[nPoints + i];
	    y2 = RPAR[nPoints + i + 1];
	    d1 = RPAR[2 * nPoints + i];
	    d2 = RPAR[2 * nPoints + i + 1];
	    /*-- this function is defined in curve_c.c ---*/
	    Myevalhermite (&u0, &t1, &t2, &y1, &y2, &d1, &d2, &h, &dh, &ddh,
			   &dddh, &inow);
	    y[0] = h;
	    break;
	  }
      }
      /* event date computation */
    case 3:
      {
	/*        ind=*_work;
		  i=ind[0];

		  if ((Order==1)||(Order==0)){
		  i=ind[2];
		  if (i==nPoints-1){ 
		  if (Periodic==1) {
		  i=0;
		  ind[0]=-1;
		  ind[1]=0;
		  }
		  }
		  if (i<nPoints-1) {
		  _evout[0]=RPAR[i+1]-RPAR[i];

		  ind[2]=i+1;
		  }
		  if (ind[2]==1)  ind[3]++;
		  }

		  if (Order>=2){
		  if ( Periodic) {
		  _evout[0]=T;
		  }else{
		  if (ind[3]==0) {
		  _evout[0]=T;
		  }
		  }
		  ind[3]++;
		  ind[0]=-1;
		  ind[1]=0;

		  } */
	break;
      }

      /* finish */
    case 5:
      {
	scicos_free (*_work);	/*free the workspace */
	break;
      }

    default:
      break;
    }
}



int FindIndex (int order, double inp, int idown, int iup, double *data, int N)
{
  int im;
  if (inp <= data[0])
    return 0;
  if (inp >= data[N - 1])
    return N - 2;
  /*
    if ((order==0) || (order==8)|| (order==9)) {
    if (inp>=data[N-1] ) return (N-1);
    }else {
    if (inp>=data[N-1] ) return (N-2);
    }
  */

  while (idown + 1 != iup)
    {
      im = (int) ((idown + iup) / 2);
      if (inp >= data[im])
	{
	  idown = im;
	}
      else if (inp < data[im])
	{
	  iup = im;
	}
    }

  return idown;
}
