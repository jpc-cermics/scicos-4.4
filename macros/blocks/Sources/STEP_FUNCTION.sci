function [x,y,typ]=STEP_FUNCTION(job,arg1,arg2)
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
     // The parameters are stored in the STEP block which is the first one
     y=needcompile;
     step_blk = arg1.model.rpar.objs(1);
     newpar=list();
     if step_blk.gui <> 'STEP' then
       message(["Error: failed to set parameter block in STEP_FUNCTION";
		"The internal diagram does not contain a STEP block at position 1"]);
       return;
     end
     ok = execstr(sprintf("xxn=%s(""set"",step_blk);",step_blk.gui),errcatch=%t)
     if ~ok then 
       message(["Error: failed to set parameter block in STEP_FUNCTION";
		catenate(lasterror())]);
       continue;
     end
     if ~step_blk.equal[xxn] then 
       [needcompile]=scicos_object_check_needcompile(step_blk,xxn);
       // parameter or states changed
       arg1.model.rpar.objs(1) = xxn;// Update the STEP block 
       newpar = list(1); // Notify modification
       y=max(y,needcompile);
     end
     x=arg1;
     typ=newpar;
  case 'define' then
    
    function scsm=block_step_function()
      scsm=scicos_diagram();
      x_2=STEP('define');
      x_2.graphics.enter[pein = [2],orig = [82.2306,652.6813],pout = [4],sz = [40,40],peout= [2]];
      scsm.objs(1)=x_2;
      
      x_2=scicos_link();
      x_2.enter[to= [1,1,1],from=[1,1,0], ct=[5,-1]];
      x_2.xx=[102.2306;102.2306;63.7090;63.7090;102.2306;102.2306];
      x_2.yy=[646.9670;622.2884;622.2884;711.9845;711.9845;698.3956];
      scsm.objs(2)=x_2;
      
      x_2=OUT_f('define');
      x_2.graphics.enter[orig=[150.8020,662.6813],sz=[20,20],pin=[4]];
      x_2.model.enter[in=[-1],out=[],in2=[],out2=[],outtyp=[1],intyp=[1]];
      scsm.objs(3)=x_2;
       
      x_2=scicos_link();
      x_2.enter[to=[3,1,1],from=[1,1,0],xx=[130.8020;150.8020],yy=[672.6813;672.6813]];
      scsm.objs(4)=x_2;

      props=scicos_params();
      props.enter[zoom=[1],title=["STEP_FUNCTION","./"],tf=[14]];
      scsm.props=props;
    endfunction
     
    model = scicos_model();
    model.enter[out=[-1],opar= ["h"],dep_ut= [%f %f],sim="csuper", firing=%f];
    model.rpar =block_step_function();
    gr_i=["xpoly(orig(1)+[0.071;0.413;0.413;0.773]*sz(1),orig(2)+[0.195;0.195;0.635;0.635]*sz(2),type=""lines"",color=2)"];
    x=standard_define([2 2],model,[],gr_i,'STEP_FUNCTION');
  end
endfunction


  

