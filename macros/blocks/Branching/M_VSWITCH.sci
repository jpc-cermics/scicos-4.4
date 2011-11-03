function [x,y,typ]=M_VSWITCH(job,arg1,arg2)
  
  function draw_m_switch(orig,sz)
  // used to draw the icon.
    nn=evstr(arg1.graphics.exprs(1));
    dd=sz(2)/(nn);
    d=dd*(0:(nn-1))
    rects=[orig(1)-0*d;orig(2)+sz(2)-d;sz(1)+0*d;dd+0*d];
    colors=8*ones_new(1,nn);
    colors(arg1.model.ipar+1)=3;
    xrects(rects,colors);
    xsegs([orig(1)+0*d;orig(1)+sz(1)+0*d],[orig(2)+sz(2)-d;orig(2)+sz(2)-d]);
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
    if ~exists('btn') then btn=2;end 
    if btn == 2 then       
      while %t do
	[ok,nin,exprs]=getvalue('Set parameters',...
				['number of inputs'],...
				list('vec',1),exprs);
	if ~ok then break,end
	nin=int(nin);
	if nin< 2  then
	  message('Number of inputs must be >=2 ')
	else
	  [model,graphics,ok]=check_io(model,graphics,[-ones_new(nin,1)],-1,[],[])
	  if ok then
	    model.ipar=1;
	    graphics.exprs=exprs;
	    x.graphics=graphics;x.model=model
	    break
	  end
	end
      end
    else 
      orig=o.graphics.orig;
      sz=o.graphics.sz;
      vs= linspace(orig(2),orig(2)+sz(2),size(model.in,'*')+1);
      i=bsearch(%pt(2),vs);
      if i<>0 then 
	x.model.ipar=size(model.in,'*')-1- (i-1);
      end
      printf("set %d \n",x.model.ipar);
    end
   case 'define' then
    in=[-1;-1]
    ipar=[1]
    nin=2
    model=scicos_model();
    model.sim=list('mvswitch',4)
    model.in=in
    model.out=-1
    model.ipar=ipar;
    model.blocktype='c'
    model.dep_ut=[%t %f]
    exprs=[string(nin)]
    gr_i=['draw_m_switch(orig,sz)'];
    x=standard_define([2 2],model,exprs,gr_i,'M_VSWITCH')
  end
endfunction


