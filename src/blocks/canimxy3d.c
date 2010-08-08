/**
   \file canimxy3d.c
   \author Benoit Bayol
   \version 1.0
   \date September 2006 - January 2007
   \brief CANIMXY3D is a scope in 3D which draw its input as a XY scope, there is animation.
   \see CANIMXY3D.sci in macros/scicos_blocks/Sinks/
*/

#include "blocks.h"

void canimxy3d (scicos_block * block, int flag)
{
  Sciprintf ("canimxy3d is to be done for nsp \n");
}

#if 0
#include "scoMemoryScope.h"
#include "scoWindowScope.h"
#include "scoMisc.h"
#include "scoGetProperty.h"
#include "scoSetProperty.h"
#include "blocks.h"

/** \fn canimxy3d_draw(scicos_block * block, ScopeMemory ** pScopeMemory, int firstdraw)
    \brief Function to draw or redraw the window
*/
void canimxy3d_draw (scicos_block * block, ScopeMemory ** pScopeMemory,
		     int firstdraw)
{
  int i;			//As usual
  int *ipar;			//Integer Parameters
  int color_number;		//Flag on Color
  int *color;
  int *line_size;
  int nbr_curves;
  int animed;
  int win;			//Windows ID : To give a name to the window
  int buffer_size;		//Buffer Size
  int win_pos[2];		//Position of the Window
  int win_dim[2];		//Dimension of the Window
  int nipar;
  double *rpar;			//Reals parameters
  double xmin, xmax, ymin, ymax, zmin, zmax, alpha, theta;	//Ymin and Ymax are vectors here
  scoGraphicalObject Pinceau;	//Pointer to each polyline of each axes
  scoGraphicalObject Gomme;	//Pointer to each polyline of each axes
  scoGraphicalObject Trait;	//Pointer to each trache of each axes
  int number_of_subwin;
  int number_of_curves_by_subwin;
  int dimension = 3;
  int gomme_color;
  int size = 0;
  char *label;

  /*Retrieving Parameters */
  ipar = GetIparPtrs (block);
  nipar = GetNipar (block);
  rpar = GetRparPtrs (block);
  win = ipar[0];
  color_number = ipar[1];
  buffer_size = ipar[2];
  label = GetLabelPtrs (block);

  color = (int *) scicos_malloc (color_number * sizeof (int));
  line_size = (int *) scicos_malloc (color_number * sizeof (int));
  for (i = 0; i < color_number; i++)
    {
      color[i] = ipar[i + 3];
      line_size[i] = ipar[i + 3 + color_number];
    }
  size = 2 * color_number;
  animed = ipar[size + 3];
  win_pos[0] = ipar[size + 4];
  win_pos[1] = ipar[size + 5];
  win_dim[0] = ipar[size + 6];
  win_dim[1] = ipar[size + 7];
  xmin = rpar[0];
  xmax = rpar[1];
  ymin = rpar[2];
  ymax = rpar[3];
  zmin = rpar[4];
  zmax = rpar[5];
  alpha = rpar[6];
  theta = rpar[7];
  number_of_subwin = 1;
  nbr_curves = ipar[size + 8];


  /* If only one element to draw */
  if (buffer_size == 1)
    {
      number_of_curves_by_subwin = nbr_curves;
      if (firstdraw == 1)
	{
	  scoInitScopeMemory (GetPtrWorkPtrs (block), pScopeMemory,
			      number_of_subwin, &number_of_curves_by_subwin);
	  scoSetShortDrawSize (*pScopeMemory, 0, 1);
	  scoSetLongDrawSize (*pScopeMemory, 0, 0);
	}

      scoInitOfWindow (*pScopeMemory, dimension, win, win_pos, win_dim, &xmin,
		       &xmax, &ymin, &ymax, &zmin, &zmax);
      if (scoGetScopeActivation (*pScopeMemory) == 1)
	{
	  pFIGURE_FEATURE (scoGetPointerScopeWindow (*pScopeMemory))->pixmap =
	    1;
	  pFIGURE_FEATURE (scoGetPointerScopeWindow (*pScopeMemory))->wshow =
	    1;

	  for (i = 0; i < scoGetNumberOfCurvesBySubwin (*pScopeMemory, 0);
	       i++)
	    {
	      scoAddPolylineForShortDraw (*pScopeMemory, 0, i, color[i]);
	      Pinceau = scoGetPointerShortDraw (*pScopeMemory, 0, i);

	      sciSetMarkSize (Pinceau, line_size[i]);

	      pPOLYLINE_FEATURE (Pinceau)->n1 = 1;
	    }
	}
    }
  /*else if 2 or more elements */
  else
    {
      number_of_curves_by_subwin = 2 * nbr_curves;	//it is a trick to recognize the type of scope, not sure it is a good way because normally a curve is the combination of a short and a longdraw
      if (firstdraw == 1)
	{
	  scoInitScopeMemory (GetPtrWorkPtrs (block), pScopeMemory,
			      number_of_subwin, &number_of_curves_by_subwin);
	}
      scoInitOfWindow (*pScopeMemory, dimension, win, win_pos, win_dim, &xmin,
		       &xmax, &ymin, &ymax, &zmin, &zmax);
      if (scoGetScopeActivation (*pScopeMemory) == 1)
	{
	  gomme_color =
	    sciGetBackground (scoGetPointerAxes (*pScopeMemory, 0));

	  if (firstdraw == 1)
	    {
	      scoSetShortDrawSize (*pScopeMemory, 0, 2);
	      scoSetLongDrawSize (*pScopeMemory, 0, buffer_size);
	    }

	  for (i = 0; i < nbr_curves; i++)
	    {
	      /*if mark style */
	      if (color[i] <= 0)
		{
		  //because of color[0] is negative it will add a black mark with style number color[0]
		  scoAddPolylineForShortDraw (*pScopeMemory, 0, i, color[i]);
		  scoAddPolylineForShortDraw (*pScopeMemory, 0, i + nbr_curves, color[i]);	//same type of mark and black for the rubber
		  scoAddPolylineForLongDraw (*pScopeMemory, 0, i, color[i]);

		  Pinceau = scoGetPointerShortDraw (*pScopeMemory, 0, i);
		  Gomme =
		    scoGetPointerShortDraw (*pScopeMemory, 0, i + nbr_curves);
		  Trait = scoGetPointerLongDraw (*pScopeMemory, 0, i);

		  sciSetMarkSize (Pinceau, line_size[i]);
		  sciSetMarkSize (Gomme, line_size[i]);
		  sciSetMarkSize (Trait, line_size[i]);

		  pPOLYLINE_FEATURE (Pinceau)->n1 = 1;
		  pPOLYLINE_FEATURE (Gomme)->n1 = 1;
		  sciSetMarkForeground (Gomme, gomme_color);	//here the rubber becomes colored like the background of the axes
		  pPOLYLINE_FEATURE (Trait)->n1 = buffer_size - 1;
		}
	      /*if line style */
	      else
		{
		  scoAddPolylineForShortDraw (*pScopeMemory, 0, i, color[i]);
		  scoAddPolylineForShortDraw (*pScopeMemory, 0,
					      i + nbr_curves, gomme_color);
		  scoAddPolylineForLongDraw (*pScopeMemory, 0, i, color[i]);

		  Pinceau = scoGetPointerShortDraw (*pScopeMemory, 0, i);
		  Gomme =
		    scoGetPointerShortDraw (*pScopeMemory, 0, i + nbr_curves);
		  Trait = scoGetPointerLongDraw (*pScopeMemory, 0, i);

		  sciSetLineWidth (Pinceau, line_size[i]);
		  sciSetLineWidth (Gomme, line_size[i]);
		  sciSetLineWidth (Trait, line_size[i]);

		  pPOLYLINE_FEATURE (Pinceau)->n1 = 2;
		  pPOLYLINE_FEATURE (Gomme)->n1 = 2;
		  pPOLYLINE_FEATURE (Trait)->n1 = buffer_size;
		}
	    }

	}
    }
  if (scoGetScopeActivation (*pScopeMemory) == 1)
    {
      pSUBWIN_FEATURE (scoGetPointerAxes (*pScopeMemory, 0))->alpha = alpha;
      pSUBWIN_FEATURE (scoGetPointerAxes (*pScopeMemory, 0))->theta = theta;

      scoAddTitlesScope (*pScopeMemory, label, "x", "y", "z");
    }
  scicos_free (color);
  scicos_free (line_size);
}

/** \fn void canimxy3d(scicos_block * block, int flag)
    \brief the computational function
    \param block A pointer to a scicos_block
    \param flag An int which indicates the state of the block (init, update, ending)
*/
void canimxy3d (scicos_block * block, int flag)
{
  void **_work = GetPtrWorkPtrs (block);
  /* Declarations */
  double *u1, *u2, *u3;
  ScopeMemory *pScopeMemory;
  scoGraphicalObject pShortDraw;
  int **user_data_ptr, *size_ptr;

  /* State Machine Control */
  switch (flag)
    {
    case Initialization:
      {

	canimxy3d_draw (block, &pScopeMemory, 1);
	break;			//Break of the switch condition don t forget it
      }				//End of Initialization

    case StateUpdate:
      {
	scoRetrieveScopeMemory (_work, &pScopeMemory);
	if (scoGetPointerScopeWindow (pScopeMemory) == NULL)
	  return;
	if (scoGetScopeActivation (pScopeMemory) == 1)
	  {
	    /* Charging Elements */

	    /*Retrieve Elements */
	    u1 = GetRealInPortPtrs (block, 1);
	    u2 = GetRealInPortPtrs (block, 2);
	    u3 = GetRealInPortPtrs (block, 3);

	    scoDrawScopeAnimXYStyle (pScopeMemory, u1, u2, u3);
	  }
	break;			//Break of the switch don t forget it !
      }				//End of stateupdate

      //This case is activated when the simulation is done or when we close scicos
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
	      }
	  }
	scoFreeScopeMemory (_work, &pScopeMemory);
	break;			//Break of the switch
      }
      //free the memory which is allocated at each turn by some variables

    }
}
#endif
