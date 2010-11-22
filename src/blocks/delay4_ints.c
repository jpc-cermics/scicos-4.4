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

/* Outputs nx*dt delayed input */

#define DELAY4(tag, type)					\
  void CNAME(delay4_,tag) (scicos_block * block, int flag)	\
  {								\
    int i;							\
    type *u = (type *) GetInPortPtrs (block, 1);		\
    type *y = (type *) GetOutPortPtrs (block, 1);		\
    type *oz =(type *) GetOzPtrs (block, 1);			\
    int nz = GetOzSize (block, 1, 2);				\
    int mz = GetOzSize (block, 1, 1);				\
    								\
    if ((flag == 1) || (flag == 6) || (flag == 4))		\
      {								\
	y[0] = oz[0];						\
      }								\
    else if (flag == 2)						\
      {								\
	/*  shift buffer */					\
	for (i = 0; i <= (mz * nz) - 2; i++)			\
	  {							\
	    oz[i] = oz[i + 1];					\
	  }							\
	/* add new point to the buffer */			\
	oz[(mz * nz) - 1] = u[0];				\
      }								\
  }									

DELAY4(i8, gint8)
DELAY4(i16, gint16)
DELAY4(i32, gint)
DELAY4(u8, gint8)
DELAY4(u16, gint16)
DELAY4(u32, gint)

#undef DELAY4 
