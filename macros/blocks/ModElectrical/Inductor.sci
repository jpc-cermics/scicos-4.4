function [x,y,typ]=Inductor(job,arg1,arg2)
// Copyright INRIA
  
  function blk_draw(sz,orig,orient,label) 
    if %t then 
      n=100;
      xx=linspace(0,10*%pi,n);
      xx=xx(5:$-4);
      a=0.4;b=1.0;
      x=a*xx -b*sin(xx);
      y=a -b*cos(xx);
      x=orig(1)+sz(1)*(x-min(x))/(max(x)-min(x));
      y=orig(2)+sz(2)*(y-min(y))/(max(y)-min(y));
      xpoly(x,y);
    else
      tt=linspace(0.04,0.96,100);
      xpoly(tt*sz(1)+orig(1),+orig(2)+abs(sin(18*(tt-0.04)))*sz(2),type="lines");
      xx=orig(1)+[0 0.04 0.04 0.04 0]*sz(1);
      yy=orig(2)+[1/2 1/2 0  1/2 1/2]*sz(2);
      xpoly(xx,yy) ;
      xx=orig(1)+[0.96 0.96 1   0.96 0.96 ]*sz(1);
      yy=orig(2)+[abs(sin(18*0.92))   1/2   1/2 1/2 abs(sin(18*0.92))]*sz(2);
      xpoly(xx,yy) ;
    end
    txt='L= '+L;
    xstringb(orig(1),orig(2)-sz(2),txt,sz(1),sz(2),'fill');
  endfunction
  
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    L=arg1.graphics.exprs;
    standard_draw(arg1,%f)
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
      [ok,L,exprs]=getvalue('Set Inductor block parameter',..
			    'L (H)',list('vec',1),exprs)
      if ~ok then break,end
      model.rpar=L
      model.equations.parameters(2)=list(L)
      graphics.exprs=exprs
      x.graphics=graphics;x.model=model
      break
    end
   case 'define' then
    model=scicos_model()
    model.in=[1];
    model.out=[1];
    L=1.d-5
    model.rpar=L
    model.sim='Inductor'
    model.blocktype='c'
    model.dep_ut=[%t %f]
    mo=modelica();
    mo.model='Inductor'
    mo.inputs='p';
    mo.outputs='n';
    mo.parameters=list('L',list(L))
    model.equations=mo;
    exprs=string(L)
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2 0.9],model,exprs,list(gr_i,0),'Inductor');
    x.graphics.in_implicit=['I']
    x.graphics.out_implicit=['I']
  end
endfunction
