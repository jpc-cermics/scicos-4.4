/*
 * Copyright (C) 2019-2010 Jean-Philippe Chancelier Enpc/Cermics
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
 * a gtkscale block
 *--------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <math.h>
#include <time.h>

#include <gtk/gtk.h>

#include "blocks.h"
#include <nsp/matrix.h>
#include <nsp/imatrix.h>
#include <nsp/cells.h>
#include <nsp/hash.h>
#include <nsp/datas.h>

typedef struct _gtkscale_data gtkscale_data;

struct _gtkscale_data
{
  double value;
  int changed;
  GtkWidget *window;
};

static void create_range_controls (gtkscale_data *D,double initial, double lower, double upper) ;

void scicos_gtkrange_block (scicos_block * block, int flag)
{
  double *rpar = GetRparPtrs (block);
  double *y = GetRealOutPortPtrs (block, 1);
  if (flag == 4)
    {
      gtkscale_data *D;
      if ((D= malloc(sizeof(gtkscale_data)))== NULL)
	{
	  Coserror ("Cannot set up data for gtkscale block\n");
	  return;
	}
      *block->work = D;
      D->value = 0;
      D->changed  = FALSE;
      create_range_controls (D,rpar[0],rpar[1],rpar[2]);
      *y = rpar[0]/ rpar[3];
    }
  else if (flag == 1 || flag == 6 )
    {
      gtkscale_data *D = (gtkscale_data *) (*block->work);
      *y = D->value/ rpar[3];
    }
  else if (flag == 5)
    {
      gtkscale_data *D = (gtkscale_data *) (*block->work);
      gtk_widget_destroy(D->window);
      free(D);
    }
}

static void  adjustment_value_changed(GtkAdjustment *adjustment,gpointer user_data)
{
  gtkscale_data *D = (gtkscale_data *) user_data;
  double x = gtk_adjustment_get_value (adjustment);
  /* printf("Adjustment changed to %f\n",x); */
  D->changed = TRUE;
  D->value = x;
}

static void create_range_controls (gtkscale_data *D,double initial, double lower, double upper)
{
  GtkWidget *window = NULL;
  GtkWidget *box1;
  GtkWidget *box2;
  GtkWidget *scale;
  GtkAdjustment *adjustment;
  GtkWidget *hbox;
  D->window = window = gtk_window_new (GTK_WINDOW_TOPLEVEL);
  /*
  gtk_window_set_screen (GTK_WINDOW (window),
			 gtk_widget_get_screen (widget));
  */
  g_signal_connect (window, "destroy",
		    G_CALLBACK (gtk_widget_destroyed),
		    &window);
  gtk_window_set_title (GTK_WINDOW (window), "range controls");
  gtk_container_set_border_width (GTK_CONTAINER (window), 0);
#if GTK_CHECK_VERSION (3,0,0)
  box1 = gtk_box_new (GTK_ORIENTATION_VERTICAL, 0);
#else
  box1 = gtk_vbox_new (FALSE, 0);
#endif
  gtk_container_add (GTK_CONTAINER (window), box1);
  gtk_widget_show (box1);
#if GTK_CHECK_VERSION (3,0,0)
  box2 = gtk_box_new (GTK_ORIENTATION_VERTICAL, 0);
#else
  box2 = gtk_vbox_new (FALSE, 10);
#endif
  gtk_container_set_border_width (GTK_CONTAINER (box2), 10);
  gtk_box_pack_start (GTK_BOX (box1), box2, TRUE, TRUE, 0);
  gtk_widget_show (box2);

  /* initial, lower,upper, step_incr, page_incr,page size */
  printf("Adjustment %f %f %f\n",initial,lower,upper);

  adjustment =GTK_ADJUSTMENT(gtk_adjustment_new (initial , lower, upper+1.0, 0.1, 1.0, 1.0));
  /*
     gtk_adjustment_get_value ()
     gtk_adjustment_set_value ()
  */

  g_signal_connect (adjustment, "value-changed",
		    G_CALLBACK (adjustment_value_changed),
		    (gpointer) D);
#if GTK_CHECK_VERSION (3,0,0)
  scale = gtk_scale_new (GTK_ORIENTATION_HORIZONTAL,
			 GTK_ADJUSTMENT (adjustment));
#else
  scale = gtk_hscale_new (GTK_ADJUSTMENT (adjustment));
#endif
  gtk_widget_set_size_request (GTK_WIDGET (scale), 150, -1);
#if GTK_CHECK_VERSION (3,0,0)
#else
  gtk_range_set_update_policy (GTK_RANGE (scale), GTK_UPDATE_DELAYED);
#endif
  gtk_scale_set_digits (GTK_SCALE (scale), 2 );
  gtk_scale_set_draw_value (GTK_SCALE (scale), TRUE);
  gtk_box_pack_start (GTK_BOX (box2), scale, TRUE, TRUE, 0);
  gtk_widget_show (scale);

#if GTK_CHECK_VERSION (3,0,0)
  hbox = gtk_box_new (GTK_ORIENTATION_HORIZONTAL, 0);
  scale = gtk_scale_new (GTK_ORIENTATION_VERTICAL,
			  GTK_ADJUSTMENT (adjustment));
#else
  hbox = gtk_hbox_new (FALSE, 0);
  scale = gtk_vscale_new (GTK_ADJUSTMENT (adjustment));
#endif

  gtk_widget_set_size_request (scale, -1, 200);
  gtk_scale_set_digits (GTK_SCALE (scale), 2);
  gtk_scale_set_draw_value (GTK_SCALE (scale), TRUE);
  gtk_box_pack_start (GTK_BOX (hbox), scale, TRUE, TRUE, 0);
  gtk_widget_show (scale);

  /* gtk_range_set_inverted (GTK_RANGE (scale), TRUE); */

  gtk_box_pack_start (GTK_BOX (box2), hbox, TRUE, TRUE, 0);
  gtk_widget_show (hbox);

  gtk_widget_show (window);
}
