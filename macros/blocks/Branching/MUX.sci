function [x,y,typ]=MUX(job,arg1,arg2)
// Copyright INRIA

  function blk_draw(sz,orig,orient,label)
    txt="Mux";
    fz=2*acquire("%zoom",def=1)*4;
    xstring(orig(1)+sz(1)/2,orig(2)+sz(2),txt,posx="center",posy="bottom",size=fz);
  endfunction
  
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
      [ok,in,exprs]=getvalue('Set MUX block parameters',..
			     'Number of input ports or vector of sizes',list('vec',-1),exprs)
      if ~ok then break,end
      if size(in,'*')==1 then
	if in<1|in>31 then
	  message('Block must have at least one input port and at most 31')
	  ok=%f
	else
	  it=-ones(in,1)
	  ot=-1
	  inp=[-[1:in]',ones(in,1)]
	  oup=[0,1]
	  [model,graphics,ok]=set_io(model,graphics,...
				     list(inp,it),...
				     list(oup,ot),[],[])
	end
      else
	if size(in,'*')==0| or(in==0)|size(in,'*')>31 then
	  message(['Block must have at least one input port';
		   'and at most 31. Size 0 is not allowed. '])
	  ok=%f
	else
	  if min(in)<0 then nout=0,else nout=sum(in),end
	  it=-ones(size(in,'*'),1)
	  ot=-1
	  inp=[in(:),ones(size(in,'*'),1)]
	  oup=[nout,1]
	  [model,graphics,ok]=set_io(model,graphics,...
				     list(inp,it),...
				     list(oup,ot),[],[])
	end
      end
      if ok then
	graphics.exprs=exprs;
	x.graphics=graphics;x.model=model
	break
      end
    end
   case 'define' then
    in=2
    model=scicos_model()
    model.sim=list('multiplex',4)
    model.in=-[1:in]'
    model.intyp=-ones(in,1)
    model.out=0
    model.outtyp=-1
    model.blocktype='c'
    model.dep_ut=[%t %f]
    exprs=string(in)
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([.5 2],model,exprs,gr_i,'MUX')
  end
endfunction
