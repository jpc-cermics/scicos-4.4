function [x,y,typ]=FROM(job,arg1,arg2)

  function blk_draw(sz,orig,orient,label)
    orig=arg1.graphics.orig;
    sz=arg1.graphics.sz;
    orient=arg1.graphics.flip;
    tg='['+arg1.graphics.exprs(1)+']';
    if orient then
      xx=orig(1)+[0 0 0;0 1/2 3/4;3/4 7/8 1;1 7/8 3/4;3/4 1/2 0]'*sz(1);
      yy=orig(2)+[0 1/2 1;1 1 1;1 3/4 1/2;1/2 1/4 0;0 0 0]'*sz(2);
      x1=0
    else
      xx=orig(1)+[0 1/8 1/4;1/4 1/2 1;1 1 1;1 1/2 1/4;1/4 1/8 0]'*sz(1);
      yy=orig(2)+[1/2 3/4 1 ;1 1 1;1 1/2 0;0 0 0;0 1/4 1/2]'*sz(2);
      x1=1/4
    end
    xpolys(xx,yy, color= default_color(1),thickness=2);
    xstringb(orig(1)+x1*sz(1),orig(2),tg,(1-x1)*sz(1),sz(2));
  endfunction
  
  x=[];y=[];typ=[]
  select job
   case 'plot' then
    // do not draw the frame 
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
    if size(exprs,'*')==1 then //compatibility
      exprs(2)='1';
      exprs(1)=sci2exp(exprs(1),0)
    end
    while %t do
      [ok,tag,BS,exprs]=getvalue('Set parameters',..
				 ['Tag','Output Type (1=Signal 2=Bus)'],..
				 list('gen',-1,'vec',1),exprs)
      if ~ok then break,end
      if BS==1 then graphics.out_implicit='E';
      elseif BS==2 then graphics.out_implicit='B';
      else message(' The Output Type must 1 or 2');ok=%f;
      end
      if ok then 
	if model.opar<>list(tag) then needcompile=4;y=needcompile,end
	graphics.exprs=exprs;
	model.opar=list(tag)
	x.model=model
	x.graphics=graphics
	break
      end
    end
    resume(needcompile)
   case 'define' then
    model=scicos_model()
    model.sim='from'
    model.in=[]
    model.in2=[]
    model.intyp=1
    model.out=-1
    model.out2=-2
    model.outtyp=-1
    model.ipar=[]
    model.opar=list('A')
    model.blocktype='c'
    model.dep_ut=[%f %f]
    exprs=[sci2exp('A');sci2exp(1)];
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([1.5 1.5],model,exprs,gr_i,'FROM');
    x.graphics.id="From"
  end
endfunction
