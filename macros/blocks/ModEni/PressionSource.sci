function [x,y,typ]=PressionSource(job,arg1,arg2)

  function blk_draw(sz,orig,orient,label)
  // xrect(orig(1),orig(2)+sz(2),sz(1),sz(2),color=9);
    g=scs_color(2);
    tr=.1*sz(1);
    if ~orient then 
      tr = sz(1)/2;
    end
    c1=[tr+orig(1);orig(2)+sz(2)*(1/2+1/5); (2/5)*sz(1); (2/5)*sz(2);0;23040];
    xarc(c1,thickness=3,color=1);
    c2=[tr+orig(1)+(1/10)*sz(1);orig(2)+sz(2)*(1/2+1/5-1/10); (1/5)*sz(1); (1/5)*sz(2);0;23040];
    xarc(c2,thickness=1,color=2,background=2);
    if orient then  
      xstring(orig(1)+sz(1)/2,orig(2)+0.7*sz(2),"Pr")
    else  
      xstring(orig(1)+sz(1)/2,orig(2)+0.7*sz(2),"Pr")
    end;
    if orient then
      xfa=[orig(1)+sz(1)/2,orig(1)+sz(1)];
      xia=[orig(1),orig(1)+0.1*sz(1)];
    else
      xfa=[orig(1)+sz(1)/2,orig(1)];
      xia=[orig(1)+0.9*sz(1),orig(1)+sz(1)];
    end
    y=[orig(2)+sz(2)/2,orig(2)+sz(2)/2];
    xpoly(xia,y,thickness=1,color=2)  
    xarrows(xfa,y,style=xget('color','blue'),arsize=2*sz(2)/10);
  endfunction
  
  x=[];y=[];typ=[];
  select job
   case "plot" then
    standard_draw(arg1,%f);
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
      [ok,IsPa,userp,price,mass,LeadTime,exprs]=getvalue('Set PressionSource block parameter',..
						  ['choose the unity [Pa(1) atm(0)]';'pression';'price [k€]';'mass [T]';'Lead Time [Day]'], ...
						  list('vec',1,'vec',1,'vec',1,'vec',1,'vec',1),exprs)
      if ~ok then break, end
      model.rpar=[IsPa;userp;price;mass;LeadTime]
      model.equations.parameters(2)=list(IsPa,userp,price,mass,LeadTime)
      graphics.exprs=exprs
      x.graphics=graphics;x.model=model
      break
    end
   case "define" then
    model=scicos_model()
    IsPa=1
    userp=1
    price=5
    mass=5
    LeadTime=5
    model.rpar=[IsPa;userp;price;mass;LeadTime]
    model.sim='Hydraulics'
    model.blocktype='c'
    model.dep_ut=[%t %f]
    mo=modelica()
    mo.model='HydroPressionSource'
    mo.inputs='p'
    mo.outputs='n'
    mo.parameters=list(['IsPa';'userp';'price';'mass';'LeadTime'],list(userp,price,mass,LeadTime))
    model.equations=mo
    
    model.in=ones(size(mo.inputs,'*'),1)
    model.out=ones(size(mo.outputs,'*'),1)
    
    exprs=[string(IsPa);string(userp);string(price);string(mass);string(LeadTime)]
    // exprs=[string(qmax);string(K);string(timemax)]
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2 2],model,exprs,gr_i,'PressionSource')
    x.graphics.in_implicit=['I']
    x.graphics.out_implicit=['I']
  end
endfunction
