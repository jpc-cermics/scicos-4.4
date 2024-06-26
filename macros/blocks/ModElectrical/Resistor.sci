function [x,y,typ]=Resistor(job,arg1,arg2)
// Copyright INRIA
// exemple d'un bloc implicit, 
//   -  sans entree ni sortie de conditionnement
//   -  avec une entree et une sortie de type implicit et de dimension 1
//   - avec un dialogue de saisie de parametre

  function blk_draw(sz,orig,orient,label)
    xx=[0,1,1,7,7,8,7,7,1,1]/8;
    yy=[1,1,0,0,1,1,1,2,2,1]/2;
    xpoly(orig(1)+xx*sz(1),orig(2)+yy*sz(2)); 
    txt="R= "+R;
    style=2;
    xstringb(orig(1),orig(2)-3*sz(2),txt,sz(1),2*sz(2),"fill");
  endfunction 
  
  x=[];y=[];typ=[];
  select job
   case 'plot' then
    R=arg1.graphics.exprs;
    standard_draw(arg1,%f);
   case 'getinputs' then
    [x,y,typ]=standard_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=standard_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    while %t do
      [ok,R,exprs]=getvalue('Set Resistor block parameter',..
			    'R (ohm)',list('vec',1),x.graphics.exprs);
      if ~ok then break,end // cancel 
      x.model.rpar=R
      x.model.equations.parameters(2)=list(R)
      x.graphics.exprs=exprs
      break;
    end
   case 'define' then
    model=scicos_model()
    R=0.01
    model.rpar=R
    model.sim='resistor'
    model.blocktype='c'
    model.dep_ut=[%t %f]
    mo=modelica()
    mo.model='Resistor'
    mo.inputs='p';
    mo.outputs='n';
    mo.parameters=list('R',list(R))
    model.equations=mo
    model.in=ones(size(mo.inputs,'*'),1)
    model.out=ones(size(mo.outputs,'*'),1)
    exprs=string(R)
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2 0.18],model,exprs,list(gr_i,0),'Resistor');
    x.graphics.in_implicit=['I']
    x.graphics.out_implicit=['I']
  end
endfunction
