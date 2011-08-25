function [x,y,typ]=DEBUG_SCICOS(job,arg1,arg2)
  x=[];y=[];typ=[]
  select job
    case 'plot' then
      standard_draw(arg1)
    case 'getinputs' then
      [x,y,typ]=standard_inputs(arg1)
    case 'getoutputs' then
      x=[];y=[];typ=[];
    case 'getorigin' then
      [x,y]=standard_origin(arg1)
    case 'set' then
      x=arg1;
      graphics=arg1.graphics;exprs=graphics.exprs
      textmp=exprs(2)
      ok=%t
      head = ['Enter scilab instructions for debugging.';
	      'Inputs are block and flag, output is block.'];
      //## set param of scstxtedit
      ptxtedit=scicos_txtedit(clos = 0, typ  = "debugblock", head=head);
            
      non_interactive = exists('getvalue') && getvalue.get_fname[]== 'setvalue';
      
      while %t
        [txt,Quit] = scstxtedit(textmp,ptxtedit);
	if isempty(txt) || Quit then 
	  ok =%f;break; // a cancel 
	end
	tt=['function block=debug_scicos(block,flag)';
	    txt;
	    'endfunction'];
	ok=execstr(tt,errcatch=%t);
	if ~ok then
	  message(['Error in the instructions defining debug_scicos:';lasterror()])
	  if non_interactive then 
	    message(['Error: set failed for DEBUG_SCICOS but we are in a non "+...
		     '  interactive function and thus we abort the set !']);
	    break;
	  else 
	    continue;
	  end
	end
	save(file('join',[getenv('NSP_TMPDIR');'debug_scicos']), debug_scicos)
	exprs(2)=txt
	if (scicos_debug()<>2 & scicos_debug()<>3) then
	  scicos_debug(2)
	end
	break;
      end
      if ok then
        needc=~isequal(graphics.exprs,exprs)
        graphics.exprs=exprs;
        x.graphics=graphics;
        if needc then
	  resume(needcompile=4);
        else
	  return
        end
      end
    case 'define' then
      model=scicos_model()
      model.sim=list('%debug_scicos',99)
      model.blocktype='d'
      exprs=list('','pause')
      gr_i=['xstringb(orig(1),orig(2),''Debug'',sz(1),sz(2),''fill'')']
      x=standard_define([2 2],model,exprs,gr_i,'DEBUG_SCICOS');
  end
endfunction
