function [x,y,typ]=GTKRANGE(job,arg1,arg2)
  //Source block; output defined by tk widget scale
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
    [ok,mi,ml,mu,ms,exprs]=getvalue('Set gtkrange parameters',..
        ['Initial Value';'Min value';'Max value';'Normalization'],..
        list('vec',1,'vec',1,'vec',1,'vec',1),exprs)
    // a scalar value in the range [min,max] and divided by
    // normalisation. 
    if ok then
      graphics.exprs=exprs
      model.rpar=[mi,ml,mu,ms];
      x.graphics=graphics;x.model=model
    end
    case 'define' then
    mi=0;ml=-10;mu=10;ms=1;// default parameter values
    model=scicos_model()
    model.sim=list('gtkrange',4);
    model.out=1
    model.evtin=1
    model.rpar=[mi,ml,mu,ms]
    model.blocktype='d'
    model.dep_ut=[%f %f]
    exprs=[sci2exp(mi);sci2exp(ml);sci2exp(mu);sci2exp(ms)]
    gr_i=['xstringb(orig(1),orig(2),''Gtk range'',sz(1),sz(2),''fill'')']
    x=standard_define([3 2],model,exprs,gr_i,'GTKRANGE');
  end
endfunction 




