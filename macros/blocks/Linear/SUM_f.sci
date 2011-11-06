function [x,y,typ]=SUM_f(job,arg1,arg2)
// Copyright INRIA

  function blk_draw(sz,orig,orient,label)
    wd = xget('wdim')
    graphics = arg1.graphics; 
    orig = graphics.orig,
    sz = graphics.sz
    orient = graphics.flip
    thick  =xget('thickness');
    rx = sz(1)*p/2
    ry = sz(2)/2
    gr_i = arg1.graphics.gr_i
    if type(gr_i,'short')=='l' then 
      xfarcs([orig(1);orig(2)+sz(2);sz(1)*p;sz(2);0;360*64],gr_i(2))
    end
    xarc(orig(1),orig(2)+sz(2),sz(1)*p,sz(2),0,360*64)
    xsegs(orig(1)+rx*[1/2.3 1;2-1/2.3 1],orig(2)+ry*[1 2-1/2.3;1,1/2.3],style=0)
    xset('thickness',thick);
    if orient then  //standard orientation (port)
      out= [0  -1/14
	    1/7    0
	    0   1/14]*3
      xfpoly(sz(1)*out(:,1)+orig(1)+sz(1)*p,sz(2)*out(:,2)+orig(2)+sz(2)/2,1)
    else //tilded orientation
      out = [  0   -1/14
	       -1/7    0
	       0   1/14]*3
      xfpoly(sz(1)*out(:,1)+orig(1),sz(2)*out(:,2)+orig(2)+sz(2)/2,1)
    end
  endfunction
    
  x=[];y=[];typ=[];
  p=1 //pixel sizes ratio
  select job
   case 'plot' then
    function noports(o) ;endfunction
    standard_draw(arg1,%f,noports);
   case 'getinputs' then
    graphics=arg1.graphics; 
    orig=graphics.orig,
    sz=graphics.sz
    orient=graphics.flip
    wd=xget('wdim');
    if orient then
      t=[%pi -%pi/2 0]
    else
      t=[%pi %pi/2 0]
    end
    r=sz(2)/2
    rx=r*p
    x=(rx*sin(t)+(orig(1)+rx)*ones_deprecated(t))
    y=r*cos(t)+(orig(2)+r)*ones_deprecated(t)
    typ=ones_deprecated(x)
   case 'getoutputs' then
    graphics=arg1.graphics; 
    orig=graphics.orig,
    sz=graphics.sz
    orient=graphics.flip
    graphics=arg1.graphics
    wd=xget('wdim');
    if orient then
      t=%pi/2
      dx=sz(1)/7
    else
      t=-%pi/2
      dx=-sz(1)/7
    end
    r=sz(2)/2
    rx=r*p
    x=(rx*sin(t)+(orig(1)+rx)*ones_deprecated(t))+dx
    y=r*cos(t)+(orig(2)+r)*ones_deprecated(t)
    typ=ones_deprecated(x)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
   case 'define' then
    model=scicos_model()
    model.sim=list('plusblk',2)
    model.in=[-1;-1;-1]
    model.out=-1
    model.blocktype='c'
    model.dep_ut=[%t %f]
    gr_i="blk_draw(sz,orig,orient,model.label)";
    exprs=[]
    x=standard_define([1 1]/1.2,model,exprs,gr_i,'SUM_f');
  end
endfunction
