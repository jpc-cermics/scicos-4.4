/*
 * Copyright (C) 2007-2010 Inria/Metalau 
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 *--------------------------------------------------------------------------*/

#include "blocks.h"

/*      Ouputs nx*dt delayed input  */

void delay4 (scicos_block * block, int flag)
{
  double *y = GetRealOutPortPtrs (block, 1);
  double *z = GetDstate (block);
  int nz = GetNdstate (block);
  double *u = GetRealInPortPtrs (block, 1);

  int i;

  if (flag == 1 || flag == 4 || flag == 6)
    {
      y[0] = z[0];
    }
  else if (flag == 2)
    {
      /*  shift buffer */
      for (i = 0; i <= nz - 2; i++)
	{
	  z[i] = z[i + 1];
	}
      /* add new point to the buffer */
      z[nz - 1] = u[0];
    }
}
