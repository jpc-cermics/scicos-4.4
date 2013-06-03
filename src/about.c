/* -*-   Encoding: utf-8  -*-  */
/* Nsp
 * Copyright (C) 1998-2010 Jean-Philippe Chancelier Enpc/Cermics
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
 * about
 * jpc@cermics.enpc.fr 
 *--------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <gtk/gtk.h>
#include <nsp/config.h>
#include "scicos-logo.xpm" 

/* This shouls be elsewhere */
#define SCICOS_VERSION "4.4" 

void create_scicos_about(void)
{
  GdkPixbuf *pixbuf, *transparent;
  
  const gchar *authors[] = {
    "R. Nikoukhah",
    "A. Layec",
    "M. Najafi",
    "F. Nassif",
    "nsp port: J.Ph Chancelier and A. Layec",
    NULL
  };

#if 0
  const gchar *documentors[] = {
    "and many more...",
    NULL
  };
#endif

  const gchar *license =
    "This library is free software; you can redistribute it and/or\n"
    "modify it under the terms of the GNU Library General Public License as\n"
    "published by the Free Software Foundation; either version 2 of the\n"
    "License, or (at your option) any later version.\n" 
    "\n"
    "This library is distributed in the hope that it will be useful,\n"
    "but WITHOUT ANY WARRANTY; without even the implied warranty of\n"
    "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU\n"
    "Library General Public License for more details.\n"
    "\n"
    "You should have received a copy of the GNU Library General Public\n"
    "License along with the Gnome Library; see the file COPYING.LIB.  If not,\n"
    "write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,\n"
    "Boston, MA 02111-1307, USA.\n";
  
  pixbuf = NULL;
  transparent = NULL;
  pixbuf =gdk_pixbuf_new_from_xpm_data (scicos_logo);
  transparent = gdk_pixbuf_add_alpha (pixbuf, TRUE, 0xff, 0xff, 0xff);
  g_object_unref (pixbuf);
  /* gtk_about_dialog_set_email_hook (activate_email, NULL, NULL); */
  /* gtk_about_dialog_set_url_hook (activate_url, NULL, NULL);*/
  gtk_show_about_dialog (NULL,/*GTK_WINDOW (window),*/
			 "program-name", "Scicos",
			 "version", SCICOS_VERSION,
			 "copyright", "(C) 2004-2013 The Scicos Team",
			 "license", license,
			 "website", "http://www.scicos.org/",
			 "authors", authors,
#if 0
			 "documenters", documentors,
#endif
			 "logo", transparent,
                         "title", "About Scicos",
			 NULL);

  g_object_unref (transparent);
}
