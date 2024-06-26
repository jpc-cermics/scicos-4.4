function [x,y,typ]=HYSTHERESIS(job,arg1,arg2)

  function blk_draw(sz,orig,orient,label)
    xrect(orig(1)+0.329*sz(1),orig(2)+0.843*sz(2),0.282*sz(1),0.686*sz(2));
    xrect(orig(1)+0.613*sz(1),orig(2)+0.843*sz(2),0.256*sz(1),0.003*sz(2));
    xrect(orig(1)+0.082*sz(1),orig(2)+0.16*sz(2),0.245*sz(1),0.003*sz(2));
  endfunction
  
  x=[];y=[];typ=[]
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
      [ok,high_lim,low_lim,out_high,out_low,nzz,exprs]=getvalue('Set parameters',..
						  ['Switch on at';'Switch off at';'Output when on';
		    'Output when off';'Use zero crossing: yes (1), no (0)'],..
						  list('vec',1,'vec',1,'vec',1,'vec',1,'vec',1),exprs)
      if ~ok then break,end
      if low_lim>high_lim then
	message('switch on value must be larger than switch off value')
      else
	graphics.exprs=exprs;
	model.rpar=[high_lim,low_lim,out_high,out_low]'
	if nzz>0 then nzz=2,end
	model.nzcross=nzz
	x.graphics=graphics;x.model=model
	break
      end
    end
   case 'define' then
    in=1
    ipar=[0] // rule
    nzz=2
    rpar=[1;0;1;0]
    
    model=scicos_model()
    model.sim=list('hystheresis',4)
    model.in=in
    model.out=1
    model.rpar=rpar
    model.nzcross=nzz
    model.nmode=1
    model.blocktype='c'
    model.dep_ut=[%t %f]
    exprs=[string(rpar);string(sign(nzz))]
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2 2],model,exprs,gr_i,'HYSTHERESIS');
  end
endfunction
