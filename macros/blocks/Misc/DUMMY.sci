function [x,y,typ]=DUMMY(job,arg1,arg2)
  // A dummy block used at compile time to check dimensions
  x=[];y=[];typ=[];
  select job
    case 'plot' then
      standard_draw(arg1)
    case 'getinputs' then
      [x,y,typ]=standard_inputs(arg1)
    case 'getoutputs' then
      [x,y,typ]=standard_outputs(arg1)
    case 'getorigin' then
      [x,y]=standard_origin(arg1)
    case 'set' then
      x=arg1
    case 'define' then
      //----------- Define

      function blk = DUMMY_define(old)
	blk = scicos_block(gui='DUMMY');
	gr_i=["txt=[""DUMMY""];";
	      "xstringb(orig(1),orig(2),txt,sz(1),sz(2),""fill"")"];
	blk.graphics.gr_i = gr_i;
	if nargin == 1 then
	  blk = set_block_params_from(blk, old);
	  blk.graphics.exprs = old.gui;
	  if type(blk.graphics.in_implicit,'short')== 's' then 
	    blk.graphics.in_implicit = strsubst(blk.graphics.in_implicit,'I','E');
	  end
	  if type(blk.graphics.out_implicit,'short')== 's' then 
	    blk.graphics.out_implicit = strsubst(blk.graphics.out_implicit,'I','E');
	  end
	else
	  blk.graphics.sz = [2, 2];
	end
      endfunction
      if nargin == 2 then 
	x= DUMMY_define(arg1);
      else
	x= DUMMY_define();
      end
  end
endfunction

function scs_m= scicos_dummy(scs_m)
  for i=1:length(scs_m.objs)
    o = scs_m.objs(i);
    if o.type == 'Block' && o.model.iskey['equations'] then
      o_new= DUMMY('define',o);
      scs_m.objs(i)=o_new;
    elseif o.type == 'Block' && or(o.model.sim(1) ==  ['super','csuper','asuper']) then
      [scsm1]= scicos_dummy(o.model.rpar);
      scs_m.objs(i).model.rpar = scsm1;
    elseif o.type == 'Link' then
      // replace implicit by explicit but explicit can be 1 or 3 what's the difference ?
      if o.ct(2) == 2 then  o.ct(2) == 1;scs_m.objs(i)=o;end
    end
  end
endfunction
