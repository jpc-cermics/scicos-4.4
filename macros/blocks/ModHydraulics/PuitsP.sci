function [x,y,typ]=PuitsP(job,arg1,arg2)
// Copyright INRIA
// exemple d'un bloc implicit, 
//   -  sans entree ni sortie de conditionnement
//   -  avec une entree et une sortie de type implicit et de dimension 1
//   - avec un dialogue de saisie de parametre

  function blk_draw(sz,orig,orient,label)
    if orient then
      x1=3*arg1.graphics.sz(1)/7;x2=0
    else
      x1=0;x2=arg1.graphics.sz(1)
    end
    xfpolys(orig(1)+x1+[0;4;4;0]*sz(1)/7,orig(2)+[0;0;4;4]*sz(2)/4,scs_color(15))
    xsegs(orig(1)+x2-(1-2*orient)*[0;3;2;3;2;3]*sz(1)/7,orig(2)+[2;2;1.5;2;2.5;2]*sz(2)/4)
    xstringb(orig(1)+x1,orig(2),'P',4*sz(1)/7,sz(2),'fill');
  endfunction
  
  x=[];y=[];typ=[];

  select job
   case 'plot' then
    standard_draw(arg1,%f)
   case 'getinputs' then
    // [x,y,typ]=puit_inputs(arg1)
    [x,y,typ]=standard_inputs(arg1)
   case 'getoutputs' then
    x=[];y=[];typ=[];
    //  [x,y,typ]=standard_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    while %t do
      [ok,P0,T0,H0,option_temperature,exprs]=getvalue('Thermal-hydraulic drain parameters', ..
						      ['Pressure of the thermohydraulic source: P0 (Pa)';..
		    'Temperature of the thermohydraulic source: T0 (K)';..
		    'Specific Enthaly of the thermohydraulic source: H0 (J/kg)';..
		    'Temperature option. 1: fixed temperature - 2: fixed enthalpy'], ..
						      list('vec',-1,'vec',-1,'vec',-1,'vec',-1),exprs)
      if ~ok then break,end
      model.rpar=[P0;T0;H0;option_temperature]
      model.equations.parameters(2)=list(P0,T0,H0,option_temperature)
      graphics.exprs=exprs
      x.graphics=graphics;x.model=model
      break
    end
   case 'define' then
    model=scicos_model()
    P0=100000
    T0=290
    H0=100000
    option_temperature=1
    model.rpar=[P0;T0;H0;option_temperature]
    model.sim='Puits'
    model.blocktype='c'
    model.dep_ut=[%t %f]

    mo=modelica()
    mo.model='Puits'
    mo.inputs=['C'];
    mo.parameters=list(['P0';'T0';'H0';'option_temperature'],[P0;T0;H0;option_temperature])
    model.equations=mo
    model.in=ones(size(mo.inputs,'*'),1)
    //model.out=ones(size(mo.outputs,'*'),1)
    exprs=[string(P0);string(T0);string(H0);string(option_temperature)]
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([7/5 4/5],model,exprs,list(gr_i,0),'PuitsP');
    // x.graphics.in_implicit=['E';'E';'E';'I']
    x.graphics.in_implicit=['I']
    //x.graphics.out_implicit=[0]
  end
endfunction
