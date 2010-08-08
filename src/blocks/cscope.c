/*
 * Benoit Bayol version 1.0
 * September 2006 - January 
 * CSCOPE is a typical scope which links its input to the simulation 
 * time but there is only one input instead of CMSCOPE
 * CSCOPE.sci in macros/scicos_blocks/Sinks/
 */

#include "blocks.h"

void cscope (scicos_block * block, int flag)
{
  Sciprintf ("cscope is to be done for nsp \n");
}


#if 0
#include "scoMemoryScope.h"
#include "scoWindowScope.h"
#include "scoMisc.h"
#include "scoGetProperty.h"
#include "scoSetProperty.h"

static void cscope_draw (scicos_block * block, ScopeMemory ** pScopeMemory,
			 int firstdraw)
{
  int i;
  double *rpar;
  int *ipar, nipar;
  double period;
  int dimension;
  double ymin, ymax, xmin, xmax;
  int buffer_size;
  int win_pos[2];
  int win_dim[2];
  int win;
  int number_of_subwin;
  int number_of_curves_by_subwin[1];
  int *colors;
  char *label;

  /*Retrieving Parameters */
  rpar = GetRparPtrs (block);
  ipar = GetIparPtrs (block);
  nipar = GetNipar (block);
  buffer_size = ipar[2];
  win = ipar[0];
  period = rpar[3];
  win_pos[0] = ipar[(nipar - 1) - 3];
  win_pos[1] = ipar[(nipar - 1) - 2];
  win_dim[0] = ipar[(nipar - 1) - 1];
  win_dim[1] = ipar[nipar - 1];
  dimension = 2;
  number_of_curves_by_subwin[0] = GetInPortRows (block, 1);

  number_of_subwin = 1;
  ymin = rpar[1];
  ymax = rpar[2];
  label = GetLabelPtrs (block);

  colors =
    (int *) scicos_malloc (number_of_curves_by_subwin[0] * sizeof (int));
  for (i = 0; i < number_of_curves_by_subwin[0]; i++)
    {
      colors[i] = ipar[3 + i];
    }

  /*Allocating memory */
  if (firstdraw == 1)
    {
      scoInitScopeMemory (GetPtrWorkPtrs (block), pScopeMemory,
			  number_of_subwin, number_of_curves_by_subwin);
      /*Must be placed before adding polyline or other elements */
      scoSetLongDrawSize (*pScopeMemory, 0, 50);
      scoSetShortDrawSize (*pScopeMemory, 0, buffer_size);
      scoSetPeriod (*pScopeMemory, 0, period);
    }

  xmin = period * scoGetPeriodCounter (*pScopeMemory, 0);
  xmax = period * (scoGetPeriodCounter (*pScopeMemory, 0) + 1);

  /*Creating the Scope */
  scoInitOfWindow (*pScopeMemory, dimension, win, win_pos, win_dim, &xmin,
		   &xmax, &ymin, &ymax, NULL, NULL);
  if (scoGetScopeActivation (*pScopeMemory) == 1)
    {
      scoAddTitlesScope (*pScopeMemory, label, "t", "y", NULL);
      /*Add a couple of polyline : one for the shortdraw and one for the longdraw */
      scoAddCoupleOfPolylines (*pScopeMemory, colors);
      /* scoAddPolylineLineStyle(*pScopeMemory,colors); */
    }
  scicos_free (colors);
}

/** \fn void cscope(scicos_block * block,int flag)
    \brief the computational function
    \param block A pointer to a scicos_block
    \param flag An int which indicates the state of the block (init, update, ending)
*/

void cscope (scicos_block * block, int flag)
{
  void **_work = GetPtrWorkPtrs (block);
  ScopeMemory *pScopeMemory;
  int i;
  double t;
  int NbrPtsShort;
  double *u1;
  scoGraphicalObject pShortDraw;
  int **user_data_ptr, *size_ptr;

  switch (flag)
    {
    case Initialization:
      {
	cscope_draw (block, &pScopeMemory, 1);
	break;
      }
    case StateUpdate:
      {
	scoRetrieveScopeMemory (_work, &pScopeMemory);
	if (scoGetPointerScopeWindow (pScopeMemory) == NULL)
	  return;
	if (scoGetScopeActivation (pScopeMemory) == 1)
	  {
	    t = GetScicosTime (block);
	    /*Retreiving Scope in the _work */


	    /*Maybe we are in the end of axes so we have to draw new ones */
	    scoRefreshDataBoundsX (pScopeMemory, t);

	    //Cannot be factorized depends of the scope
	    u1 = GetRealInPortPtrs (block, 1);
	    for (i = 0; i < scoGetNumberOfCurvesBySubwin (pScopeMemory, 0);
		 i++)
	      {
		pShortDraw = scoGetPointerShortDraw (pScopeMemory, 0, i);
		NbrPtsShort = pPOLYLINE_FEATURE (pShortDraw)->n1;
		pPOLYLINE_FEATURE (pShortDraw)->pvx[NbrPtsShort] = t;
		pPOLYLINE_FEATURE (pShortDraw)->pvy[NbrPtsShort] = u1[i];
		pPOLYLINE_FEATURE (pShortDraw)->n1++;
	      }
	    //End of Cannot

	    //Draw the Scope
	    scoDrawScopeAmplitudeTimeStyle (pScopeMemory, t);
	  }
	break;
      }
    case Ending:
      {
	scoRetrieveScopeMemory (_work, &pScopeMemory);
	if (scoGetScopeActivation (pScopeMemory) == 1)
	  {
	    if (scoGetPointerScopeWindow (pScopeMemory) != NULL)
	      {
		sciSetUsedWindow (scoGetWindowID (pScopeMemory));
		pShortDraw = sciGetCurrentFigure ();
		sciGetPointerToUserData (pShortDraw, &user_data_ptr,
					 &size_ptr);
		FREE (*user_data_ptr);
		*user_data_ptr = NULL;
		*size_ptr = 0;
		scoDelCoupleOfPolylines (pScopeMemory);
	      }
	  }
	scoFreeScopeMemory (_work, &pScopeMemory);
	break;
      }
    }
}
#endif
