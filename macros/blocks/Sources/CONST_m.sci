function [x,y,typ]=CONST_m(job,arg1,arg2)
// Copyright INRIA

  function blk_draw(sz,orig,orient,label)  
    dx=sz(1)/5;dy=sz(2)/10;
    w=sz(1)-2*dx;h=sz(2)-2*dy;
    txt=C;
    xstringb(orig(1)+dx,orig(2)+dy,txt,w,h,'fill');
  endfunction
  
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    C=arg1.graphics.exprs;
    standard_draw(arg1)
   case 'getinputs' then
    x=[];y=[];typ=[];
   case 'getoutputs' then
    [x,y,typ]=standard_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    while %t do
      [ok,C,exprs]=getvalue('Set Constant Block',..
			    ['Constant'],list('vec',-1),exprs)
      if ~ok then break,end
      nout=size(C)
      if ~isempty(find(nout==0)) then
	message('C must have at least one element')
      else
	model.sim=list('cstblk4_m',4)
	model.opar=list(C)
        [ot,str]=do_get_type(C)
	if ot==9 then 
	  message("type "+str+"not recognized");ok=%f;
	  break;
	end
	model.rpar=[]
	[model,graphics,ok]=set_io(model,graphics,list(),list(nout,ot),[],[])
	graphics.exprs=exprs;
	x.graphics=graphics;x.model=model
	break;
      end
    end
   case 'define' then
    C=[1]
    model=scicos_model()
    model.sim=list('cstblk4',4)
    model.in=[]
    model.out=size(C,1)
    model.in2=[]
    model.out2=size(C,2)
    model.rpar=C
    model.opar=list()
    model.blocktype='d'
    model.dep_ut=[%f %f]
    exprs=sci2exp(C)
    gr_i="blk_draw(sz,orig,orient,model.label)";	
    x=standard_define([2 2],model,exprs,gr_i,'CONST_m');
  end
endfunction
