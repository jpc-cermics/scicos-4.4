function [x,y,typ]=DOLLAR(job,arg1,arg2)
// Copyright INRIA
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
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    //backward compatibility
    if size(exprs,'*')<2 then exprs(2)='0';end
    
    non_interactive = scicos_non_interactive();
    
    while %t do
      [ok,a,inh,exprs]=getvalue('Set 1/z block parameters',..
				['initial condition';'Inherit (no:0, yes:1)'],...
				list('mat',[-1 -2],'vec',-1),exprs)
      if ~ok then break; end;
      out=[size(a,1) size(a,2)];if out==0 then out=[],end
      in=out
      model.sim=list('dollar4_m',4)
      model.odstate=list(a);
      model.dstate=[];
      [ot,str]=do_get_type(a);
      if ot==9 then 
	message("type "+str+"not recognized");ok=%f;
	break;
      end
      it=ot;
      if ot==1 && (size(a,1)==1 || size(a,2)==1) then
	model.sim=list('dollar4',4);
	model.dstate=a(:);
	model.odstate=list();
      end
      [model,graphics,ok]=set_io(model,graphics,list(in,it),list(out,ot),ones(1-inh,1),[])
      if ok then
	graphics.exprs=exprs;
	x.graphics=graphics;x.model=model
	break
      end
      if non_interactive then 
	message(['Error: set failed for DOLLAR but we are in a non ";
		 '  interactive function and thus we abort the set !']);
	break;
      end
    end
   case 'define' then
    z=0
    inh=0
    in=1
    exprs=string([z;inh])
    model=scicos_model()
    model.sim=list('dollar4',4)
    model.in=in
    model.out=in
    model.evtin=1-inh
    model.dstate=z
    model.blocktype='d'
    model.dep_ut=[%f %f]

    gr_i='xstringb(orig(1),orig(2),''1/z'',sz(1),sz(2),''fill'')'
    x=standard_define([2 2],model,exprs,gr_i,'DOLLAR');
  end
endfunction

