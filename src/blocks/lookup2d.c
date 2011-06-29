/* 
 * Copyright (C) 2007-2011 Ramine Nikoukhah (Inria) 
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

#define InterpExtrapBlin  1
#define InterpEndValue    2
#define InputNearest      3
#define InputBelow        4
#define InputAbove        5
#define InterpExtraplin   6

static double computeZ2 (const double *X,const double *Y,const double *Z,
			 int nx, int ny, int method,
			 double x, double y);
static int indexfinder2 (double x, int n,const double *LT);

void lookup2d (scicos_block * block, int flag)
{
  double *_rpar = GetRparPtrs (block);
  int *_ipar = GetIparPtrs (block);
  double *y, *u1, *u2;
  double *X, *Y, *Z;

  int Nx = _ipar[0];
  int Ny = _ipar[1];
  int method = _ipar[2];

  X = _rpar;
  Y = X + Nx;
  Z = Y + Ny;

  switch (flag)
    {
      /* init */
    case 4:

    case 1:
      u1 = GetRealInPortPtrs (block, 1);
      u2 = GetRealInPortPtrs (block, 2);
      y = GetRealOutPortPtrs (block, 1);
      y[0] = computeZ2 (X, Y, Z, Nx, Ny, method, u1[0], u2[0]);
      break;
    case 3:
    case 5:
    default:
      break;
    }
}

static double computeZ2 (const double *X,const double *Y,const double *Z,
			 int nx, int ny, int method,
			 double x, double y)
{
  int i, j, im, jm;
  double fq11, fq12, fq21, fq22, w, w1, w2, z = 0.;
  double x1, x2, x3, y1, y2, y3, z1, z2, z3, A, B, C, D;
  i = indexfinder2 (x, nx, X);
  j = indexfinder2 (y, ny, Y);

  if (method == InputNearest)
    {

      if ((X[i] - x) > (x - X[i - 1]))
	i = i - 1;
      if ((Y[j] - y) > (y - Y[j - 1]))
	j = j - 1;
      z = Z[i + j * nx];

    }
  else if (method == InputBelow)
    {
      im = i - 1;
      jm = j - 1;
      z = Z[im + jm * nx];
    }
  else if (method == InputAbove)
    {
      z = Z[i + j * nx];
    }
  else if (method == InterpEndValue)
    {
      if (x >= X[nx - 1])
	{
	  x = X[nx - 1];
	}
      else if (x <= X[0])
	{
	  x = X[0];
	};
      if (y >= Y[ny - 1])
	{
	  y = Y[ny - 1];
	}
      else if (y <= Y[0])
	{
	  y = Y[0];
	};
      im = i - 1;
      jm = j - 1;
      fq11 = Z[im + jm * nx];
      fq21 = Z[i + jm * nx];
      fq12 = Z[im + j * nx];
      fq22 = Z[i + j * nx];

      w = (X[i] - X[im]) * (Y[j] - Y[jm]);
      w1 = (fq11 * (X[i] - x) + fq21 * (x - X[im])) * (Y[j] - y);
      w2 = (fq12 * (X[i] - x) + fq22 * (x - X[im])) * (y - Y[jm]);
      z = (w1 + w2) / w;

    }
  else if (method == InterpExtrapBlin)
    {
      im = i - 1;
      jm = j - 1;
      fq11 = Z[im + jm * nx];
      fq21 = Z[i + jm * nx];
      fq12 = Z[im + j * nx];
      fq22 = Z[i + j * nx];

      w = (X[i] - X[im]) * (Y[j] - Y[jm]);
      w1 = (fq11 * (X[i] - x) + fq21 * (x - X[im])) * (Y[j] - y);
      w2 = (fq12 * (X[i] - x) + fq22 * (x - X[im])) * (y - Y[jm]);
      z = (w1 + w2) / w;
    }
  else if (method == InterpExtraplin)
    {				/* triangulation */
      /*
	If the linear interpolation scheme is selected, the 2D points
	are first triangulated. It is a network of triangles connecting
	the points together. It is used to interpolate.  The equation of
	the plane defined by the three vertices of a triangle is as
	follows: Ax+By+Cz+D=0; where A, B, and C, and D are computed
	from the coordinates of the three vertices (x1,y1,z1),
	(x2,y2,z2), & (x3,y3,z3).  which is the form of the plane
	equation used to compute the elevation at any point on the
	triangle.
      */

      im = i - 1;
      jm = j - 1;
      x1 = X[i];
      y1 = Y[jm];
      z1 = Z[i + nx * jm];
      x2 = X[im];
      y2 = Y[j];
      z2 = Z[im + nx * j];
      if (((x - x1) / (x2 - x1) > (y - y1) / (y2 - y1)))
	{
	  x3 = X[im];
	  y3 = Y[jm];
	  z3 = Z[im + nx * jm];
	}
      else
	{
	  x3 = X[i];
	  y3 = Y[j];
	  z3 = Z[i + nx * (j)];
	}
      A = y1 * (z2 - z3) + y2 * (z3 - z1) + y3 * (z1 - z2);
      B = z1 * (x2 - x3) + z2 * (x3 - x1) + z3 * (x1 - x2);
      C = x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2);
      D = -A * x1 - B * y1 - C * z1;
      z = -(A * x + B * y + D) / C;
    }
  return z;
}

static int indexfinder2 (double x, int n,const double *LT)
{
  int i1, i2, i_mid;

  /* if X(k-1)<= x < X(k) then i2=k */
  if (x <= LT[0])
    return 1;
  if (x >= LT[n - 1])
    return n - 1;
  i1 = 0;
  i2 = n - 1;

  while (i1 != i2 - 1)
    {
      i_mid = (int) ((i1 + i2) / 2);
      if (x >= LT[i_mid])
	i1 = i_mid;
      else
	i2 = i_mid;
    }
  return i2;
}
