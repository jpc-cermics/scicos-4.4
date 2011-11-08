function [x,y,typ]=OpAmp(job,arg1,arg2)

  function OpAmp_draw(orig,sz,orient)
    if ~exists('%zoom') then %zoom=1;end
    fz= 2*%zoom*4;
    if orient then;
      xx=orig(1)+[30,28,08,08,00,08,08,00,08,08,28,28]*(sz(1)/32);
      yy=orig(2)+[35,35,12,24,24,24,48,48,48,60,35,35]*(sz(2)/70);
      xstring(xx(4)+(sz(1)/32),yy(4),"-",posy="center",size=fz);
      xstring(xx(7)+(sz(1)/32),yy(7),"+",posy="center",size=fz);
    else;
      xx=orig(1)+[02,04,24,24,32,24,24,32,24,24,04,04]*(sz(1)/32);
      yy=orig(2)+[35,35,12,24,24,24,48,48,48,60,35,35]*(sz(2)/70);
      xstring(xx(4)-(sz(1)/32),yy(4),"-",posx="right",posy="center",size=fz);
      xstring(xx(7)-(sz(1)/32),yy(7),"+",posx="right",posy="center",size=fz);
    end;
    xpoly(xx,yy,thickness=1);
    xstring(orig(1)+sz(1)/2,orig(2),"Op",posx="center",posy="bottom",size=fz);
    //xrect(orig(1),orig(2)+sz(2),sz(1),sz(2));
  endfunction
  
  x=[];y=[];typ=[]
  select job
   case 'plot' then
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
    while %f do
      [ok,OLGain,SatH,SatL,exprs]=getvalue('Set the Operational Amplifier parameters',..
					   ['Open Loop Gain';'Positive saturation voltage';'Negative saturation voltage'],..
					   list('vec',1,'vec',1,'vec',1),exprs);
      if ~ok then break,end
      model.equations.parameters(2)=list(OLGain,SatH,SatL)
      graphics.exprs=exprs
      x.graphics=graphics;x.model=model
      break
    end
   case 'define' then
    //  OLGain=1000;
    //  SatH=10;
    // SatL=-10;
    // S=['OLGain';'SatH';'SatL'];
    // Z=eval(S);
    S=[];
    Z=[];
    model=scicos_model();
    model.sim='OpAmp';
    model.blocktype='c';
    model.dep_ut=[%t %f];
    mo=modelica();
    mo.model=model.sim;
    mo.inputs=['in_p';'in_n'];
    mo.outputs=['out'];
    mo.parameters=list(S,Z);
    model.equations=mo;
    model.in=ones(size(mo.inputs,'*'),1);
    model.out=ones(size(mo.outputs,'*'),1);
    model.rpar=Z;
    exprs=string(Z);
    gr_i=['OpAmp_draw(orig,sz,orient);'];
    x=standard_define([2 2],model,exprs,gr_i,'OpAmp');
    x.graphics.in_implicit=['I';'I']
    x.graphics.out_implicit=['I']
  end
endfunction


