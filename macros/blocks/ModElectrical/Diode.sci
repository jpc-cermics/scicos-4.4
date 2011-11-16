function [x,y,typ]=Diode(job,arg1,arg2)
// Copyright INRIA

  function blk_draw(sz,orig,orient,label)
    if orient then 
      x=[orig(1),orig(1)+sz(1)*(1/4+1/8)];
      y=[orig(2)+sz(2)/2,orig(2)+sz(2)/2];
      xpoly(x,y,thickness=2);
      x=orig(1)+sz(1)*(1/4+1/8) + [0,0,sz(1)/4];
      dy=sz(2)/5;
      y=orig(2)+sz(2)/2 + [-dy,dy,0];
      xfpoly(x,y,thickness=1,color=0,fill_color=xget('color','gray'));
      x=[orig(1)+sz(1)*(1/2+1/8),orig(1)+sz(1)];
      y=[orig(2)+sz(2)/2,orig(2)+sz(2)/2];
      xpoly(x,y,thickness=2);
      x=[orig(1)+sz(1)*(1/2+1/8),orig(1)+sz(1)*(1/2+1/8)];
      y=[orig(2)+sz(2)/2-dy,orig(2)+sz(2)/2+dy];
      xpoly(x,y,thickness=2);
    else
      x=[orig(1)+sz(1),orig(1)+sz(1)-sz(1)*(1/4+1/8)];
      y=[orig(2)+sz(2)/2,orig(2)+sz(2)/2];
      xpoly(x,y,thickness=2);
      x=orig(1)+sz(1)-sz(1)*(1/4+1/8) + [0,0,-sz(1)/4];
      dy=sz(2)/5;
      y=orig(2)+sz(2)/2 + [-dy,dy,0];
      xfpoly(x,y,thickness=1,color=0,fill_color=xget('color','gray'));
      x=[orig(1)+sz(1)- sz(1)*(1/2+1/8),orig(1)];
      y=[orig(2)+sz(2)/2,orig(2)+sz(2)/2];
      xpoly(x,y,thickness=2);
      x=[orig(1)+sz(1)-sz(1)*(1/2+1/8),orig(1)+sz(1)-sz(1)*(1/2+1/8)];
      y=[orig(2)+sz(2)/2-dy,orig(2)+sz(2)/2+dy];
      xpoly(x,y,thickness=2);
    end
  endfunction
  
  x=[];y=[];typ=[];
  select job
   case 'plot' then
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
      [ok,Ids,Vt,Maxexp,R,exprs]=getvalue('Set Diode block parameter',..
					  ['Saturation current (A)',..
		    'Voltage equivalent to temperature (Volt)',..
		    'Max exponent for linear continuation',..
		    'R (ohm)'],	list('vec',1,'vec',1,'vec',1,'vec',1),exprs)
      if ~ok then break,end
      model.rpar=[Ids;Vt;Maxexp;R]
      model.equations.parameters=list(['Ids','Vt','Maxexp','R'],list(Ids,Vt,Maxexp,R))
      graphics.exprs=exprs
      x.graphics=graphics;x.model=model
      break
    end
   case 'define' then
    Ids=1.e-6; Vt=0.04; Maxexp=15; R=1.e8;
    model=scicos_model()
    model.rpar=[Ids;Vt;Maxexp;R]

    model.in=1;model.out=1;
    model.sim='Diode';
    model.blocktype='c'
    model.dep_ut=[%t %f]
    mo=modelica()
    mo.model='Diode';
    mo.inputs='p';
    mo.outputs='n';
    mo.parameters=list(['Ids','Vt','Maxexp','R'],list(Ids,Vt,Maxexp,R))

    model.equations=mo
    exprs=string([Ids;Vt;Maxexp;R])
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2 1],model,exprs,list(gr_i,0),'Diode');
    x.graphics.in_implicit=['I']
    x.graphics.out_implicit=['I']  
  end
endfunction
