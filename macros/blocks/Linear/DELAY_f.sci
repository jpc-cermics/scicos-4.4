function [x,y,typ]=DELAY_f(job,arg1,arg2)
// Copyright INRIA

  function blk = DELAY_define()
    evtdly=EVTDLY_f('define')
    evtdly.graphics.orig=[243,296]
    evtdly.graphics.sz=[40,40]
    evtdly.graphics.flip=%t
    evtdly.graphics.exprs=['0.1';'1']
    evtdly.graphics.pein=10
    evtdly.graphics.peout=7
    evtdly.model.rpar=0.1
    evtdly.model.firing=0
    
    register=REGISTER_f('define')
    register.graphics.orig=[238,195]
    register.graphics.sz=[50,50]
    register.graphics.flip=%t
    register.graphics.exprs='0;0;0;0;0;0;0;0;0;0'
    register.graphics.pin=6
    register.graphics.pout=5
    register.graphics.pein=9
    
    input_port=IN_f('define')
    input_port.graphics.orig=[92,210]
    input_port.graphics.sz=[20,20]
    input_port.graphics.flip=%t
    input_port.graphics.exprs=['1';'1']
    input_port.graphics.pout=6
    input_port.model.ipar=1
    
    output_port=OUT_f('define')
    output_port.graphics.orig=[440,210]
    output_port.graphics.sz=[20,20]
    output_port.graphics.flip=%t
    output_port.graphics.exprs=['1';'1']
    output_port.graphics.pin=5
    output_port.model.ipar=1
    
    split=CLKSPLIT_f('define')
    split.graphics.orig=[263;271.2]
    split.graphics.pein=7,
    split.graphics.peout=[9;10]
    
    diagram=scicos_diagram();
    diagram.objs(1)=input_port
    diagram.objs(2)=output_port
    diagram.objs(3)=register
    diagram.objs(4)=evtdly
    diagram.objs(5)=scicos_link(xx=[296.6;440],yy=[220;220],..
				from=[3,1],to=[2,1])
    diagram.objs(6)=scicos_link(xx=[112;229.4],yy=[220;220],..
				from=[1,1],to=[3,1])
    diagram.objs(7)=scicos_link(xx=[263;263],yy=[290.3;271.2],ct=[5,-1],..
				from=[4,1],to=[8,1])
    diagram.objs(8)=split
    diagram.objs(9)=scicos_link(xx=[263;263],yy=[271.2;250.7],ct=[5,-1],..
				from=[8,1],to=[3,1])
    diagram.objs(10)=scicos_link(xx=[263;308.6;308.6;263;263],..
				 yy=[271.2;271.2;367;367;341.7],..
				 ct=[5,-1],from=[8,2],to=[4,1]) 
    blk=scicos_block()
    blk.gui='DELAY_f'
    blk.graphics.sz=[2,2]
    blk.graphics.gr_i=list('xstringb(orig(1),orig(2),''Delay'',sz(1),s"+...
			 "z(2),''fill'')',8) 
    blk.graphics.pin=0
    blk.graphics.pout=0
    blk.model.sim='csuper'
    blk.model.in=1
    blk.model.out=1
    blk.model.blocktype='h'
    blk.model.dep_ut=[%f %f]
    blk.model.rpar=diagram
    blk.graphics.exprs =[evtdly.graphics.exprs(1);register.graphics.exprs];

  endfunction

  function [blk,newpar]=DELAY_f_set(blk,dt,z0,exprs)
    // propagate values in the contained diagram
    // paths to updatable parameters or states
    blk.graphics.exprs  = exprs;
    if blk.model.rpar.objs(1)==mlist('Deleted') then
      ppath = list(4,5)  //compatibility with translated blocks
    else
      ppath = list(3,4)
    end
    newpar=list();
    register=blk.model.rpar.objs(ppath(1)); //data structure of register block
    evtdly=blk.model.rpar.objs(ppath(2)); //data structure of evtdly block
    //Change the clock
    evtdly.graphics.exprs(1)=exprs(1);
    //      evtdly.model.firing=0; //initial delay firing date
    if evtdly.model.rpar<>dt then
      //Discretisation time step
      evtdly.model.rpar=dt
      newpar($+1)=ppath(2); // notify clock changes
    end
    blk.model.rpar.objs(ppath(2))=evtdly
    //Change the register
    register.graphics.exprs=exprs(2)
    if or(register.model.dstate<>z0(:)) then
      //Register initial state
      register.model.dstate=z0(:)
      newpar($+1)=ppath(1); // notify register changes
    end
    blk.model.rpar.objs(ppath(1))=register;
  endfunction

  // the function
    
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
     x=arg1;
     if ~arg1.graphics.iskey['exprs'] || isempty(arg1.graphics.exprs) then
       exprs = DELAY_f('exprs',arg1);
     else
       exprs = arg1.graphics.exprs;
     end
     while %t do
       [ok,dt,z0,exprs]=getvalue(['This block implements as a discretised delay';
				  'it is consist of a shift register and a clock';
				  'value of the delay is given by;'
				  'the discretisation time step multiplied by the';
				  'number-1 of state of the register'],...
				 ['Discretisation time step';
				  'Register initial state'],list('vec',1,'vec',-1),exprs)
       if ~ok then return;end;// cancel
       mess=[];
       if prod(size(z0))<2 then
	 mess=[mess;'Register length must be at least 2';' ']
	 ok=%f;
       end    
       if dt<=0 then
	 mess=[mess;'Discretisation time step must be positive';' ']
	 ok=%f;
       end
       if ~ok then
	 message(mess);
       else
	 break;
       end
     end
     [x,newpar]=DELAY_f_set(arg1,dt,z0,exprs);
     y=acquire('needcompile',def=0);
     typ=newpar;
   case 'define' then
     x = DELAY_define();
   case 'exprs' then
     blk = arg1;
     // re-creates exprs form data in diagram
     // backwrd compatibility for old schemes.
     if blk.model.rpar.objs(1)==mlist('Deleted') then
       ppath = list(4,5)  //compatibility with translated blocks
     else
       ppath = list(3,4)
     end
     register=blk.model.rpar.objs(ppath(1)); //data structure of register block
     evtdly=blk.model.rpar.objs(ppath(2)); //data structure of evtdly block
     exprs=[evtdly.graphics.exprs(1); register.graphics.exprs];
     x=exprs;
  end
  
endfunction
