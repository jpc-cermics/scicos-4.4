#ifndef SUNDIALS_H 
#define SUNDIALS_H 

#include "cvode.h"          
#include "cvode_dense.h"    
#include "ida.h"
#include "ida_dense.h"
#include "nvector_serial.h" 
#include "sundials_dense.h" 
#include "sundials_types.h" 
#include "sundials_math.h"
#include "ida_impl.h"
#include "kinsol.h"
#include "kinsol_dense.h"
#include "dopri5m.h"

#define SUNDIALS_ONE   RCONST(1.0)
#define SUNDIALS_ZERO  RCONST(0.0)
#define SUNDIALS_T0    RCONST(0.0)   

#endif 
