function [ok,tt,cancel,libss,cflags]=CC4(funam,tt,libss,cflags)
// Copyright INRIA
//
  if nargin < 3 then libss="";end
  if nargin < 4 then cflags="";end
  
  cancel=%f
  if isempty(tt) then
    textmp=['#include <scicos/scicos_block4.h>';
	    ''
	    'void '+funam+'(scicos_block *block,int flag)'];
    textmp($+1)='{'
    textmp=[textmp]

    textmp($+1)='  /* init */'
    textmp($+1)='  if (flag == 4) {'
    textmp($+1)='   ';
    if out<>0 then
      textmp($+1)='  /* output computation */ ';
      textmp($+1)='  } else if(flag == 1) {'
      textmp($+1)='   ';
    end
    if nx<>0 then
      textmp($+1)='  /* derivative or residual computation */'
      textmp($+1)='  } else if(flag == 0) {'
      textmp($+1)='   ';
    end
    if nzcr<>0 then
      textmp($+1)='  /* zero crossing surface and mode computation */'
      textmp($+1)='  } else if(flag == 9) {'
      textmp($+1)='   ';
    end
    if nz<>0 then
      textmp($+1)='  /* computation of next discrete state*/ '
      textmp($+1)='  } else if(flag == 2) { '
      textmp($+1)='   ';
    elseif min(nx,nzcr+nevin)>0 then
      textmp($+1)='  /* computation of jumped state*/ '
      textmp($+1)='  } else if(flag == 2) {'
      textmp($+1)='   ';
    end
    if nevout<>0 then
      textmp($+1)='  /* computation of output event times*/'
      textmp($+1)='  } else if(flag == 3) {'
      textmp($+1)='   '
    end
    textmp($+1)='  /* ending */'
    textmp($+1)='  } else  if (flag == 5) {'
    textmp($+1)='   ';
    textmp($+1)='  }'
    textmp($+1)='}'
    textmp($+1)='';
  else
    textmp=tt;
  end
  
  tt = textmp
  ok   = %t
  // set param of scstxtedit
  head = ['Here is a skeleton of the C functions\n'+...
	  'you should fill:'];
  while %t 
    txt = editsmat('Cfunc edition',textmp,comment=head);
    if isempty(txt) then 
      // empty answer from editsmat means Cancel edition.
      cancel=%t
      ok=%f;
      break;
    end
    [libss,cflags,ok,cancel]=get_dynamic_lib_dir(txt,funam,'c',libss, cflags);
    if cancel || ~ok then 
      break;
    end
    [ok]=scicos_block_link(funam,txt,'c',libss,cflags)
    if ok then
      ok = %t;cancel = %f; tt=txt
      break;
    end
    textmp=txt;
  end
endfunction
