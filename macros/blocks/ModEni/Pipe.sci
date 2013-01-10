function [x,y,typ]=Pipe(job,arg1,arg2)
// Pipe implicit element

  x=[];y=[];typ=[];
  select job
   case "plot" then
    standard_draw(arg1,%f,standard_draw_ports)
   case "getinputs" then
    [x,y,typ]=standard_inputs(arg1)
   case "getoutputs" then
    [x,y,typ]=standard_outputs(arg1)
   case "getorigin" then
    [x,y]=standard_origin(arg1)
   case "set" then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    while %t do
      [ok,L,D,price,mass,LeadTime,exprs]=getvalue('Set Pipe block parameter',..
						  ['L [m]';'D [m]';'price [k€]';'mass [T]';'Lead Time [Day]'], ...
						  list('vec',1,'vec',1,'vec',1,'vec',1,'vec',1),exprs)
      if ~ok then break, end
      model.rpar=[L;D;price;mass;LeadTime]
      model.equations.parameters(2)=list(L,D,price,mass,LeadTime)
      graphics.exprs=exprs
      x.graphics=graphics;x.model=model
      break
    end
    
   case "define" then
    model=scicos_model()
    L=1
    D=0.5
    price=5
    mass=5
    LeadTime=5
    model.rpar=[L;D;price;mass;LeadTime]
    model.sim='Hydraulics'
    model.blocktype='c'
    model.dep_ut=[%t %f]
    mo=modelica()
    mo.model='HydroTuyau'
    mo.inputs='p'
    mo.outputs='n'
    mo.parameters=list(['L';'D';'price';'mass';'LeadTime'],list(L,D,price,mass,LeadTime))
    model.equations=mo
    
    model.in=ones(size(mo.inputs,'*'),1)
    model.out=ones(size(mo.outputs,'*'),1)
    
    exprs=[string(L);string(D);string(price);string(mass);string(LeadTime)]
    gr_i=['xrects([orig(1);orig(2)+sz(2);sz(1);sz(2)],scs_color(2))'];
    x=standard_define([2 0.5],model,exprs,list(gr_i,0),'Pipe')
    
    x.graphics.in_implicit=['I']
    x.graphics.out_implicit=['I']
  end
endfunction
