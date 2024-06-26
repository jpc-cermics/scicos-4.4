#ifndef SCICOS_BLOCKS_DEF_H 
#define SCICOS_BLOCKS_DEF_H 

#include <nsp/nsp.h>
#include <nsp/blas.h>
#include <nsp/matutil.h>
#include "../librand/grand.h" /* rand_ranf() */
#include "../system/files.h" /*  FSIZE */
#include "scicos/simul4.h"
#include "scicos/blocks.h"
#include "../calelm/calpack.h" 
#include "../control/ctrlpack.h" 
/* 
#ifdef NEW_GRAPHICS
#include <nsp/graphics-new/Graphics.h> 
#else 
#include <nsp/graphics-old/Graphics.h> 
#endif 
*/

#ifndef sciprint 
#define  sciprint Sciprintf
#endif 

#ifndef NULL
#define NULL    0
#endif

#endif 
