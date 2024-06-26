function [x,y,typ]=PENDULUM_ANIM(job,arg1,arg2)
// Animation of the cart-pendulum problem

  function blk_draw(sz,orig,orient,label)
    xx=orig(1)+sz(1)*[.4 .6 .6 .4 .4]
    yy=orig(2)+sz(2)*[.2 .2 .4 .4 .2]
    xpoly(xx,yy,type="lines",thickness=2);
    xx=orig(1)+sz(1)*[.5 .6]
    yy=orig(2)+sz(2)*[.4 .8]
    xpoly(xx,yy,thickness=2)
  endfunction
  
  x=[];y=[];typ=[]
  select job
   case 'plot' then
    standard_draw(arg1)
   case 'getinputs' then
    [x,y,typ]=standard_inputs(o)
   case 'getoutputs' then
    x=[];y=[];typ=[];
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;dstate=model.dstate
    p_names =  ['Pendulum length';'Cart size (square side)';'Slope';
		'Xmin';'Xmax';  'Ymin'; 'Ymax' ];
    p_types =  list('vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1);
    while %t do
      [ok,plen,csiz,phi,xmin,xmax,ymin,ymax,exprs]=getvalue('Set Scope parameters',p_names, p_types,exprs);
      if ~ok then break,end
      mess=[]
      if plen<=0|csiz<=0 then
        mess=[mess;'Pendulum lenght and cart size must be positive.';' ']
        ok=%f
      end
      if ymin>=ymax then
        mess=[mess;'Ymax must be greater than Ymin';' ']
        ok=%f
      end
      if xmin>=xmax then
        mess=[mess;'Xmax must be greater than Xmin';' ']
        ok=%f
      end
      if ~ok then
        message(mess)
      else
        rpar=[plen;csiz;phi;xmin;xmax;ymin;ymax]
        model.rpar=rpar;
        graphics.exprs=exprs;
        x.graphics=graphics;x.model=model
        break
      end
    end
   case 'define' then
    plen=2; csiz=2; phi=0;
    xmin=-5;xmax=5;ymin=-5;ymax=5

    model=scicos_model()
    model.sim=list('anim_pen',5)
    model.in=[1;1]
    model.evtin=1
    model.dstate=0
    model.rpar=[plen;csiz;phi;xmin;xmax;ymin;ymax]
    model.blocktype='d'
    model.dep_ut=[%f %f]
    
    exprs=string(model.rpar);
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([3 3],model,exprs,gr_i,'PENDULUM_ANIM');
  end
endfunction




