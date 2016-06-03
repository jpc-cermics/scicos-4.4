/*
 * Copyright (C) 2019-2014 Jean-Philippe Chancelier Enpc/Cermics
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
 * a gtkswitch block
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

typedef struct _gtkswitch_data gtkswitch_data;

struct _gtkswitch_data
{
  int value; /* value of the switch 1 or 2 */
  int changed;
  GtkWidget *window;
};

static void create_switch_controls (gtkswitch_data *D,int initial);

void scicos_gtkswitch_block (scicos_block * block, int flag)
{
  int *ipar = GetIparPtrs (block);     /* parameters */
  double *y = GetRealOutPortPtrs (block, 1);
  int mu1 = GetInPortRows (block, 1);
  int nu1 = GetInPortCols (block, 1);
  double *u1 = GetRealInPortPtrs (block, 1);
  double *u2 = GetRealInPortPtrs (block, 2);
  if (flag == 4)
    {
      int i;
      gtkswitch_data *D;
      if ((D= malloc(sizeof(gtkswitch_data)))== NULL)
	{
	  Coserror ("Cannot set up data for gtkswitch block\n");
	  return;
	}
      *block->work = D;
      D->value = *ipar;
      D->changed  = FALSE;
      create_switch_controls (D,ipar[0]);
      D->value = *ipar;
      if ( D->value == 1)
	for (i = 0; i < mu1*nu1; i++) y[i] = u1[i];
      else
	for (i = 0; i < mu1*nu1; i++) y[i] = u2[i];
    }
  else if (flag == 1 || flag == 6 )
    {
      int i;
      gtkswitch_data *D = (gtkswitch_data *) (*block->work);
      if (D == NULL || D->value == 1)
	for (i = 0; i < mu1*nu1; i++) y[i] = u1[i];
      else
	for (i = 0; i < mu1*nu1; i++) y[i] = u2[i];
    }
  else if (flag == 5)
    {
      gtkswitch_data *D = (gtkswitch_data *) (*block->work);
      gtk_widget_destroy(D->window);
      free(D);
      *block->work = NULL;
    }
}



static void cb_draw_value1( GtkToggleButton *button, gtkswitch_data *D)
{
  D->value = 1;
}

static void cb_draw_value2( GtkToggleButton *button, gtkswitch_data *D )
{
  D->value = 2;
}

static void create_switch_controls (gtkswitch_data *D,int initial)
{
  GSList *group;
  GtkWidget *button;
  GtkWidget *window = NULL;
  GtkWidget *box1;
  GtkWidget *box2;

  D->window = window = gtk_window_new (GTK_WINDOW_TOPLEVEL);
  g_signal_connect (window, "destroy",
		    G_CALLBACK (gtk_widget_destroyed),
		    &window);
  gtk_window_set_title (GTK_WINDOW (window), "switch controls");
  gtk_container_set_border_width (GTK_CONTAINER (window), 0);
#if GTK_CHECK_VERSION (3,0,0)
  box1 = gtk_box_new (GTK_ORIENTATION_VERTICAL, 0);
#else
  box1 = gtk_vbox_new (FALSE, 0);
#endif
  gtk_container_add (GTK_CONTAINER (window), box1);
  gtk_widget_show (box1);

#if GTK_CHECK_VERSION (3,0,0)
  box2 = gtk_box_new (GTK_ORIENTATION_VERTICAL, 10);
#else
  box2 = gtk_vbox_new (FALSE, 10);
#endif
  gtk_container_set_border_width (GTK_CONTAINER (box2), 10);
  gtk_box_pack_start (GTK_BOX (box1), box2, TRUE, TRUE, 0);
  gtk_widget_show (box2);

  button = gtk_radio_button_new_with_label (NULL, "input one");
  gtk_box_pack_start (GTK_BOX (box2), button, TRUE, TRUE, 0);
  if (initial == 1)
    gtk_toggle_button_set_active (GTK_TOGGLE_BUTTON (button), TRUE);
  gtk_widget_show (button);
  g_signal_connect (button, "toggled", G_CALLBACK (cb_draw_value1), D);

#if GTK_CHECK_VERSION (3,0,0)
  group = gtk_radio_button_get_group (GTK_RADIO_BUTTON (button));
#else
  group = gtk_radio_button_group (GTK_RADIO_BUTTON (button));
#endif

  button = gtk_radio_button_new_with_label(group, "input two");
  if (initial == 2)
    gtk_toggle_button_set_active (GTK_TOGGLE_BUTTON (button), TRUE);
  g_signal_connect (button, "toggled", G_CALLBACK (cb_draw_value2), D);

  gtk_box_pack_start (GTK_BOX (box2), button, TRUE, TRUE, 0);
  gtk_widget_show (button);

  gtk_widget_show (window);
}
