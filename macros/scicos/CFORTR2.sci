function [ok,tt]=CFORTR2(funam,tt)
// *flag for nsp 
// This is maybe to be fixed
  if isempty(tt) then
    
    textmp=['void '+funam+'(scicos_block *block,int flag)';
	    '\t{'; 
	    '\tswitch (flag)';
	    '\t{';
	    '\tcase 4 : /* initialization */';
	    '\t'+funam+"_bloc_init(block,flag);break;"];

    ttext=['#include <math.h>';
	   '#include <stdlib.h>';
	   '#include <scicos/scicos_block.h>';
	   '';
	   'static int '+funam+"_bloc_init(scicos_block *block,int flag)";
	   '\t{\n\treturn 0;\n\t}'];
    
    if nout<>0 then 
      textmp=[textmp;
	      '\tcase 1 :  /* output computation*/'
	      '\tset_block_error('+funam+"_bloc_outputs(block,flag));"
	      '\tbreak;'];
      
      ttext=[ttext;'static int '+funam+"_bloc_outputs(scicos_block *block,int flag)";
	     "\t{\n\treturn 0;\n\t}"];
    end
    
    if nx<>0 then 
      textmp=[textmp;
	      '\tcase 0:  /* derivative or residual computation*/';
	      '\tset_block_error('+funam+"_bloc_deriv(block,flag));";
	      '\tbreak;'];
      ttext=[ttext;'static int '+funam+"_bloc_deriv(scicos_block *block,int flag)";
	     "\t{\n\treturn 0;\n\t}"];
    end
    
    if ng <>0 then 
      textmp=[textmp;
	      '\tcase 9: /* zero crossing surface and mode computation*/';
	      '\tset_block_error('+funam+"_bloc_zcross(block,flag));";
	      '\tbreak;'];
      ttext=[ttext;'static int '+funam+"_bloc_zcross(scicos_block *block,int flag)";
	     "\t{\n\treturn 0;\n\t}"];
    end
    
    if nz<>0 then 
      textmp=[textmp;
	      '\tcase 2: /* computation of next discrete state*/ ';
	      '\tset_block_error('+funam+"_bloc_states(block,flag));";
	      '\tbreak;'];
      ttext=[ttext;'static int '+funam+"_bloc_states(scicos_block *block,int flag)";
	     "\t{\n\treturn 0;\n\t}"];
    elseif min(nx,ng+nevin)>0 then 
      textmp=[textmp;
	      '\tcase 2: /* computation of next discrete state*/ ';
	      '\tset_block_error('+funam+"_bloc_states(block,flag));";
	      '\tbreak;'];
      ttext=[ttext;'static int '+funam+"_bloc_states(scicos_block *block,int flag)";
	     "\t{\n\treturn 0;\n\t}"];
    end
    
    if nevout<>0 then 
      textmp=[textmp;
	      '\tcase 3: /* computation of output event times*/';
	      '\tset_block_error('+funam+"_bloc_evtout(block,flag));";
	      '\tbreak;'];
      ttext=[ttext;'static int '+funam+"_bloc_evtout(scicos_block *block,int flag)";
	     "\t{\n\treturn 0;\n\t}"];
    end
    textmp=[textmp;
	    '\tcase 5:  /* ending */'
	    '\tset_block_error('+funam+"_bloc_ending(block,flag));";
	    '\tbreak;'];
    ttext=[ttext;'static int '+funam+"_bloc_ending(scicos_block *block,int flag)";
	   "\t{\n\treturn 0;\n\t}"];
	      
    textmp=[ttext;'\n\n'; textmp;'\t}\n\t}'];
    
  else
    textmp=tt;
  end

  while 1==1
    [txt]=x_dialog(['Function definition in C';
		    'Here is a skeleton of the functions which';'you shoud edit'],..
		   textmp);
    
    if ~isempty(txt) then
      tt=txt
      [ok]=scicos_block_link(funam,tt,'c')
      if ok then
	textmp=txt;
      end
      break;
    else
      ok=%f;break;
    end  
  end


endfunction
