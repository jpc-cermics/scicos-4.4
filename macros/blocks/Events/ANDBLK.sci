function [x,y,typ]=ANDBLK(job,arg1,arg2)
// Copyright INRIA

  function diagram=andblock_subdiagram() 
    andlog=ANDLOG_f('define')
    andlog.graphics.enter[orig=[194,133],sz=[60,60],flip=%t,pout=9,pein=[4;11]];
    input_port1=CLKIN_f('define')
    input_port1.graphics.enter[orig=[149,287], sz=[20,20],flip=%t,exprs='1',peout=4,ipar=1];
    input_port1.model.ipar=1; // exprs='1'
    output_port=CLKOUT_f('define')
    output_port.graphics.enter[orig=[450,83], sz=[20,20],flip=%t,exprs='1',pein=8,ipar=1];
    input_port1.model.ipar=1; // exprs='1'
    input_port2=CLKIN_f('define')
    input_port2.graphics.enter[orig=[141,330],sz=[20,20],flip=%t,exprs='2',peout=6,ipar=2];
    input_port1.model.ipar=2; // exprs='2'
    ifthel=IFTHEL_f('define')
    ifthel.graphics.enter[orig=[331,137],sz=[60,60],flip=%t,pin=9, pein=12, peout=[8;0]];
    split=CLKSPLIT_f('define')
    split.graphics.enter[orig=[234;275.78348],pein=6,peout=[11;12]];
    
    diagram=scicos_diagram()
    diagram.objs(1)=andlog
    diagram.objs(2)=input_port1
    diagram.objs(3)=output_port
    diagram.objs(4)=scicos_link(xx=[169;214;214],yy=[297;297;198.71],ct=[5,-1],from=[2,1],to=[1,1])  
    diagram.objs(5)=input_port2
    diagram.objs(6)=scicos_link(xx=[161;234;234],yy=[340;340;275.78],ct=[5,-1],from=[5,1],to=[10,1])  
    diagram.objs(7)=ifthel
    diagram.objs(8)=scicos_link(xx=[351;351;450],yy=[131.29;93;93],ct=[5,-1],from=[7,1],to=[3,1])  
    diagram.objs(9)=scicos_link(xx=[262.57;322.43],yy=[163;167],ct=[1,1],from=[1,1],to=[7,1])  
    diagram.objs(10)=split
    diagram.objs(11)=scicos_link(xx=[234;234],yy=[275.78;198.71], ct=[5,-1],from=[10,1],to=[1,2])   
    diagram.objs(12)=scicos_link(xx=[234;361;361],yy=[275.78;275.78;202.71],ct=[5,-1],from=[10,2],to=[7,1])   
  endfunction
  
  x=[];y=[],typ=[]
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
    x=arg1
   case 'define' then
    
    x=scicos_block()
    x.gui='ANDBLK'
    x.graphics.sz=[20,20]
    x.graphics.gr_i=list('xstringb(orig(1),orig(2),'' ANDBLK '',sz(1),s"+...
			 "z(2),''fill'')',8);
    x.graphics.pein=[0;0]
    x.graphics.peout=0
    x.model.sim='csuper'
    x.model.evtin=[1;1]
    x.model.evtout=1
    x.model.blocktype='h'
    x.model.firing=%f
    x.model.dep_ut=[%f %f];
    x.model.rpar=andblock_subdiagram();
  end
endfunction
