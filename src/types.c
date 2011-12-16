/* Nsp
 * Copyright (C) 2011-2011 Jean-Philippe Chancelier Enpc/Cermics, Alan
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
#include <nsp/nsp.h>
#include <nsp/objects.h>

static int scicos_is(NspObject *obj,const char *type)
{
  NspHash *Block = (NspHash*) obj;
  NspObject *T;
  if ( !IsHash(obj)) return FALSE;
  if (nsp_hash_find(Block,"type",&T) == FAIL) return FALSE;
  if ( !IsString(T) ) return FALSE;
  if ( strcmp(((NspSMatrix *)T)->S[0],type) != 0) return FALSE;
  return TRUE;
}

int scicos_is_block(NspObject *obj)
{
  return scicos_is(obj,"Block");
}

int scicos_is_link(NspObject *obj)
{
  return scicos_is(obj,"Link");
}

int scicos_is_text(NspObject *obj)
{
  return scicos_is(obj,"Text");
}

const char *scicos_get_sim(NspObject *obj) 
{
  char *sim1=NULL;
  NspObject *M,*S;
  if (scicos_is_block(obj) == FALSE ) return sim1;
  if (nsp_hash_find((NspHash *)obj ,"model",&M) == FAIL) return sim1;
  if (!IsHash(M)) return sim1;
  if (nsp_hash_find((NspHash *) M,"sim",&S) == FAIL) return sim1;
  /* sim = list(string | ,number) | string */
  if (IsList(S)) 
    {
      /* first element */
      NspObject *S1=nsp_list_get_element((NspList *)S,0);
      if ( !IsString(S1) ) return sim1;
      sim1 = ((NspSMatrix *) S1)->S[0];
    }
  else if ( IsString(S)) 
    {
      sim1 = ((NspSMatrix *) S)->S[0];
    }
  return sim1;
}


int scicos_is_split(NspObject *obj)
{
  const char *sim1= scicos_get_sim(obj);
  if ( sim1 == NULL) return FALSE;
  if (strcmp(sim1,"split") != 0 && strcmp(sim1,"lsplit") != 0 )
    return FALSE;
  return TRUE;
}

int scicos_is_modelica_block(NspObject *obj)
{
  NspObject *M,*S;
  if ( scicos_is_block(obj) == FALSE ) return FALSE;
  if (nsp_hash_find((NspHash *)obj ,"model",&M) == FAIL) return FALSE;
  if (!IsHash(M)) return FALSE;
  if (nsp_hash_find((NspHash *) M,"equations",&S) == FAIL) return FALSE;
  /* sim = list(string | ,number) | string */
  if ( ! IsList(S)) return FALSE;
  if (nsp_list_length((NspList *)S)==0) return FALSE;
  return TRUE;
}



