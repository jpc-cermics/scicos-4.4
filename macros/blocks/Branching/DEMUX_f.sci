function [x,y,typ]=DEMUX_f(job,arg1,arg2)
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
    while %t do
      [ok,out,exprs]=getvalue('Set DEMUX block parameters',..
			      ['Number of output ports or vector of sizes'],list('vec',-1),exprs)
      if ~ok then break,end
      if size(out,'*')==1 then
	if out<2 | out>8 then
	  message('Block must have at least 2 and at most 8 output ports')
	  ok=%f
	else
	  [model,graphics,ok]=check_io(model,graphics,0,-[1:out]',[],[])
	end
      else
        if size(out,'*')<2| size(out,'*')>8|or(out==0) then
	  message(['Block must have at least 2 and at most 8 output ports';
		'and size 0 is not allowed']   )
	  ok=%f
	else
	  if min(out)<0 then nin=0,else nin=sum(out),end
	  [model,graphics,ok]=check_io(model,graphics,nin,out(:),[],[])
	  if ok then out=size(out,'*'),end
	end
      end
      if ok then
	graphics.exprs=exprs;model.ipar=out
	x.graphics=graphics;x.model=model
	break
      end
    end
   case 'define' then
    out=2
    model=scicos_model()
    model.sim=list('demux',1)
    model.in=0 //????
    model.out=-[1:out]'
    model.ipar=out
    model.blocktype='c'
    model.firing=[]
    model.dep_ut=[%t %f]
    
    exprs=string(out)
    gr_i='xstringb(orig(1),orig(2),''Demux'',sz(1),sz(2),''fill'')'
    x=standard_define([2 2],model,exprs,gr_i,'DEMUX_f');
  end
endfunction
