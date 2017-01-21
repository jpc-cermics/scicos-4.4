function [x,y,typ]=SOM_f(job,arg1,arg2)
// Copyright INRIA
  
  function blk_draw(sz,orig,orient,label)
    wd=xget('wdim')
    orig=arg1.graphics.orig;
    sz=arg1.graphics.sz;
    orient=arg1.graphics.flip;
    // patt=xget('dashes');xset('dashes',27)
    rx=sz(1)*p/2
    ry=sz(2)/2
    gr_i=arg1.graphics.gr_i;
    if type(gr_i,'short')=='l' then 
      xfarcs([orig(1);orig(2)+sz(2);sz(1)*p;sz(2);0;360*64],gr_i(2))
    end
    xarc(orig(1),orig(2)+sz(2),sz(1)*p,sz(2),0,360*64)
    xsegs(orig(1)+rx*[1/2.3 1;2-1/2.3 1],orig(2)+ry*[1 2-1/2.3;1,1/2.3],style=27)
    if orient then  //standard orientation
      out= [0  -1/14
	    1/7    0
	    0   1/14]*3
      xfpoly(sz(1)*out(:,1)+orig(1)+sz(1)*p,sz(2)*out(:,2)+orig(2)+sz(2)/2,1)
    else //tilded orientation
      out= [0   -1/14
	    -1/7    0
	    0   1/14]*3
      xfpoly(sz(1)*out(:,1)+orig(1),sz(2)*out(:,2)+orig(2)+sz(2)/2,1)
    end
  endfunction
  
  x=[];y=[];typ=[];
  p=1 //pixel sizes ratio
  select job
   case 'plot' then
    // no frame 
    function noports(o) ;endfunction
    standard_draw(arg1,%f,noports);
   case 'getinputs' then
    orig=arg1.graphics.orig;
    sz=arg1.graphics.sz;
    orient=arg1.graphics.flip;

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
    orig=arg1.graphics.orig;
    sz=arg1.graphics.sz;
    orient=arg1.graphics.flip;

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
    graphics=arg1.graphics;
    model=arg1.model;
    exprs=graphics.exprs
    if size(exprs,'*')==2 then exprs=exprs(2),end
    if size(exprs,'*')<>3 then exprs=string(model.rpar),end
    if graphics.flip then
      labs=['down','left','up']
    else
      labs=['down','right','up']
    end

    non_interactive = exists('getvalue') && ...
	( getvalue.get_fname[]== 'setvalue' || getvalue.get_fname[]== 'getvalue_doc');
    if ~non_interactive then 
      message(['This sum block is obsolete'
	       'parameters cannot be modified. Please replace it with new sum block';
	       'and gain blocks in the linear palette'
	       ' '
	       'Input ports are located at up, side and  down positions.'
	       'Current gains are:' 
	       part(labs(:),1:7)+'  '+exprs(:)]);
    end
   case 'define' then
    sgn=[1;1;1]

    model=scicos_model()
    model.sim=list('sum',2)
    model.in=[-1;-1;-1]
    model.out=-1
    model.rpar=sgn
    model.blocktype='c'
    model.dep_ut=[%t %f]

    exprs=[sci2exp(1);sci2exp(sgn)]
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([1 1]/1.2,model,exprs,gr_i,'SOM_f');
  end
endfunction
