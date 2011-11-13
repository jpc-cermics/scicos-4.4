function [x,y,typ]=BPLATFORM(job,arg1,arg2)

  function blk_draw(sz,orig,orient,label)
    xx=orig(1)+sz(1)*[3 7 7 3 3]/10;
    yy=orig(2)+sz(2)*[5 5 4 4 5 ]/10;
    xpoly(xx,yy,type="lines");
    xx=orig(1)+sz(1)*[5 4.5 5.5 4.5 5.5 4.5 5.5 4.5  5.5 4.5  5.5]/10;
    yy=orig(2)+sz(2)*[4 3.5 3.0 3.5 3.0 2.5 2.0 1.5  1.0 0.5 0]/10;
    xpoly(xx,yy,type="lines");
    xarc(orig(1)+sz(1)*0.4,orig(2)+sz(2)*0.8,sz(1)*0.2,sz(2)*0.2,0,360*64);
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
    while %t do
      [ok,plen,csiz,phi,xmin,xmax,ymin,ymax,exprs]=getvalue(..
						  'Set Scope parameters',..
						  ['Pendulum length';'Cart size (square side)';'Slope';
		    'Xmin';'Xmax';  'Ymin'; 'Ymax' ],..
						  list('vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1),exprs)
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
    xmin=-5;xmax=5;ymin=0;ymax=15

    model=scicos_model()
    model.sim=list('bplatform2',5)
    model.in=[1;1]
    model.evtin=1
    model.dstate=0
    model.rpar=[plen;csiz;phi;xmin;xmax;ymin;ymax]
    model.blocktype='d'
    model.dep_ut=[%f %f]
    gr_i="blk_draw(sz,orig,orient,model.label)";    
    exprs=string(model.rpar)
    x=standard_define([2 2],model,exprs,gr_i,'BPLATFORM');
  end
endfunction

