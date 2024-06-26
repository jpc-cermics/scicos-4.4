function [x,y,typ]=GAINBLK_f(job,arg1,arg2)
  // Copyright INRIA

  function blk_draw(sz,orig,orient,label)
    orig=arg1.graphics.orig;
    sz=arg1.graphics.sz;
    orient=arg1.graphics.flip;
    if length(arg1.graphics.exprs(1))>6 then
      gain=part(arg1.graphics.exprs(1),1:4)+'..'
    else 
      gain=arg1.graphics.exprs(1);
    end
    if orient then
      xx=orig(1)+[0 1 0 0]*sz(1);
      yy=orig(2)+[0 1/2 1 0]*sz(2);
      x1=0
    else
      xx=orig(1)+[0   1 1 0]*sz(1);
      yy=orig(2)+[1/2 0 1 1/2]*sz(2);
      x1=1/4
    end
    gr_i=arg1.graphics.gr_i;
    if type(gr_i,'short')=='l' then
      coli=gr_i(2);
      if ~isempty(coli) then
	xfpolys(xx',yy',coli);
	xstringb(orig(1)+x1*sz(1),orig(2),gain,(1-x1)*sz(1),sz(2));
      else
	xpoly(xx,yy,type='lines',color=default_color(0));
	xstringb(orig(1)+x1*sz(1),orig(2),gain,(1-x1)*sz(1),sz(2));
      end
    else
      xpoly(xx,yy,type='lines',color=default_color(0));	
      xstringb(orig(1)+x1*sz(1),orig(2),gain,(1-x1)*sz(1),sz(2));
    end
  endfunction
  
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    // no frame 
    standard_draw(arg1,%f);
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
      [ok,gain,exprs]=getvalue('Set gain block parameters',..
			       ['Gain'],list('mat',[-1,-1]),exprs(1))
      if ~ok then break,end
      if isempty(gain) then
	message('Gain must have at least one element')
      else
	[out,in]=size(gain)
	[model,graphics,ok]=check_io(model,graphics,in,out,[],[])
	if ok then
	  graphics.exprs=exprs
	  model.rpar=gain(:);
	  x.graphics=graphics;x.model=model
	  break
	end
      end
    end
   case 'define' then
    gain=1
    in=1;out=1
    model=scicos_model()
    model.sim='gain'
    model.in=in
    model.out=out
    model.rpar=gain
    model.blocktype='c'
    model.dep_ut=[%t %f]
    
    exprs=[strcat(sci2exp(gain))]
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2 2],model,exprs,gr_i,'GAINBLK_f');
  end
endfunction
