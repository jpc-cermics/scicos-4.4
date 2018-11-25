function [x,y,typ]=DELAY_f(job,arg1,arg2)
  // Copyright INRIA
  // contains a diagram inside

  function scs_m = DELAY_define()
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
    
    scs_m=scicos_diagram();
    scs_m.objs(1)=input_port
    scs_m.objs(2)=output_port
    scs_m.objs(3)=register
    scs_m.objs(4)=evtdly
    scs_m.objs(5)=scicos_link(xx=[296.6;440],yy=[220;220],
				from=[3,1],to=[2,1])
    scs_m.objs(6)=scicos_link(xx=[112;229.4],yy=[220;220],
				from=[1,1],to=[3,1])
    scs_m.objs(7)=scicos_link(xx=[263;263],yy=[290.3;271.2],ct=[5,-1],
				from=[4,1],to=[8,1])
    scs_m.objs(8)=split
    scs_m.objs(9)=scicos_link(xx=[263;263],yy=[271.2;250.7],ct=[5,-1],
				from=[8,1],to=[3,1])
    scs_m.objs(10)=scicos_link(xx=[263;308.6;308.6;263;263],
				 yy=[271.2;271.2;367;367;341.7],
				 ct=[5,-1],from=[8,2],to=[4,1])
  endfunction

  function [blk,newpar]=DELAY_f_set(blk,dt,z0,exprs)
    // propagate values in the contained diagram
    // paths to updatable parameters or states
    blk.graphics.exprs  = exprs;
    ppath = list(3,4);
    newpar=list();
    register=blk.model.rpar.objs(ppath(1)); //data structure of register block
    evtdly=blk.model.rpar.objs(ppath(2)); //data structure of evtdly block
    evtdly.graphics.exprs(1)=exprs(1);
    if evtdly.model.rpar<>dt then
      evtdly.model.rpar=dt;  //Discretisation time step
      newpar($+1)=ppath(2); // notify clock changes
    end
    blk.model.rpar.objs(ppath(2))=evtdly
    //Change the register
    register.graphics.exprs=exprs(2:$)
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
     y=acquire('needcompile',def=0);
     // be sure that exprs is now in block
     [x,changed]= DELAY_f('upgrade',arg1);
     if changed then y = max(y,2);end
     newpar=list();
     exprs=x.graphics.exprs;
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
     [x,newpar]=DELAY_f_set(x,dt,z0,exprs);
     typ=newpar;
     resume(needcompile=y);
   case 'define' then
     scs_m  = DELAY_define();
     model=scicos_model(sim="csuper",in=1,out=1,
			rpar=scs_m,ipar=1,blocktype="h",dep_ut=[%f %f]);
     gr_i=list('xstringb(orig(1),orig(2),''Delay'',sz(1),sz(2),''fill'')',8);
     x=standard_define([2 2],model,[],gr_i,'DELAY_f');
     evtdly= scs_m.objs(4);
     register= scs_m.objs(3);
     x.graphics.exprs =[evtdly.graphics.exprs(1);register.graphics.exprs];
  
   case 'upgrade' then
     // upgrade if necessary
     y = %f;
     if ~arg1.graphics.iskey['exprs'] || isempty(arg1.graphics.exprs) then
       // arg1 do not have a correct exprs field
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
       x1 = DELAY_f('define');
       x=arg1;
       x.model.rpar= x1.model.rpar;
       x.graphics.exprs = exprs;
       x.model.rpar.objs(3).graphics.exprs = register.graphics.exprs;
       x.model.rpar.objs(4).graphics.exprs = evtdly.graphics.exprs;
     else
       x=arg1;
       y=%f;
     end
  end
  
endfunction
