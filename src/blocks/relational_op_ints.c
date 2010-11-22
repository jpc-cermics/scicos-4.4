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


#define CASE_OP(op,act)				\
  for (i = 0; i < m * n; i++)			\
    {						\
      if (u1[i] op  u2[i]) act;			\
    }

#define RELATIONAL_OP(tag, type)					\
  void CNAME(relational_op_,tag) (scicos_block * block, int flag)	\
  {									\
    int i;								\
    int _ng = GetNg (block);						\
    int *_mode = GetModePtrs (block);					\
    int *ipar= GetIparPtrs (block);					\
    int m = GetInPortRows (block, 1);					\
    int n = GetInPortCols (block, 1);					\
    double *_g = GetGPtrs (block);					\
    type *u1 =(type *) GetInPortPtrs (block, 1);			\
    type *u2 =(type *) GetInPortPtrs (block, 2);			\
    type *y =(type *) GetOutPortPtrs (block, 1);			\
    if (flag == 1)							\
      {									\
	if (_ng != 0 && areModesFixed (block))				\
	  {								\
	    for (i = 0; i < m * n; i++)					\
	      *(y + i) = _mode[i] - 1;					\
	  }								\
	else								\
	  {								\
	    for (i = 0; i < m * n; i++)  y[i] = 0;			\
	    switch (ipar[0])						\
	      {								\
	      case 0: CASE_OP(==, y[i] = 1);break;			\
	      case 1: CASE_OP(!=, y[i] = 1);break;			\
	      case 2: CASE_OP(<, y[i] = 1);break;			\
	      case 3: CASE_OP(<=, y[i] = 1);break;			\
	      case 4: CASE_OP(>, y[i] = 1);break;			\
	      case 5: CASE_OP(>=, y[i] = 1);break;			\
	      }								\
	  }								\
      }									\
    else if (flag == 9)							\
      {									\
	for (i = 0; i < m * n; i++)					\
	  _g[i] = *(u1 + i) - *(u2 + i);				\
	if ( !areModesFixed (block))					\
	  {								\
	    for (i = 0; i < m * n; i++) _mode[i] = (int) 1;		\
	    switch (ipar[0])						\
	      {								\
	      case 0: CASE_OP(==, _mode[i] = 2);break;			\
	      case 1: CASE_OP(!=, _mode[i] = 2);break;			\
	      case 2: CASE_OP(<, _mode[i] = 2);break;			\
	      case 3: CASE_OP(<=, _mode[i] = 2);break;			\
	      case 4: CASE_OP(>, _mode[i] = 2);break;			\
	      case 5: CASE_OP(>=, _mode[i] = 2);break;			\
	      }								\
	  }								\
      }									\
  }

RELATIONAL_OP(i8, gint8)
RELATIONAL_OP(i16, gint16)
RELATIONAL_OP(i32, gint)
RELATIONAL_OP(u8, gint8)
RELATIONAL_OP(u16, gint16)
RELATIONAL_OP(u32, gint)

#undef RELATIONAL_OP
