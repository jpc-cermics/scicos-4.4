function [x,y,typ]=ENDBLK(job,arg1,arg2)
  // contains a diagram inside
  
  function diagram=make_end_block()
    blk= END_c('define');
    blk.graphics.orig=[272.104,249.11733];
    blk.graphics.sz=[40,40];
    blk.graphics.exprs="1.000E+08";
    blk.graphics.pein=2;
    blk.graphics.peout=2;
    
    diagram=scicos_diagram();
    diagram.props.title = "ENDBLK",
    diagram.objs(1)=blk;
    xlink=[292.104;292.104;261.83733;261.83733;292.104;292.104];
    ylink=[243.40305;234.45067;234.45067;305.584;305.584;294.83162];
    diagram.objs(2)=scicos_link(xx=xlink,yy=ylink,id="drawlink",
				thick=[0,0],ct=[5,-1],from=[1,1,0],to=[1,1,1]);
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
     y=acquire('needcompile',def=0);
     // be sure that exprs is now in block
     [x,changed]=ENDBLK('upgrade',arg1);
     if changed then y = max(y,2);end
     newpar=list();
     blk=x.model.rpar.objs(1);
     blk_new = blk;
     ok = execstr("blk_new="+blk.gui+"(""set"",blk)", errcatch=%t);
     if ~ok then
       message(["Error: cannot set parameters in ENDBLK";
		catenate(lasterror())]);
       return;
     end
     if ~blk.equal[blk_new] then
       // parameter or states changed
       x.model.rpar.objs(1) = blk_new; // Update
       x.graphics.exprs = blk_new.graphics.exprs;
       newpar(1)=1;// Notify modification
       [needcompile]=scicos_object_check_needcompile(blk,blk_new);
       y = max(y,needcompile);
     end
     typ=newpar;
     resume(needcompile=y);
   case 'define' then
     diagram=make_end_block();
     model=scicos_model(sim="csuper",in=[],in2=[],intyp=1,out=[],out2=[],outtyp=1,evtin=[],
			evtout=[],state=[],dstate=[],odstate=list(),rpar=diagram,ipar=1,
			opar=list(),blocktype="h",firing=[],dep_ut=[%f,%f],label="",
			nzcross=0,nmode=0,equations=list())
     gr_i='xstringb(orig(1),orig(2),'' END '',sz(1),sz(2),''fill'')';
     x=standard_define([2 2],model,[],gr_i,'ENDBLK');
     x.graphics.exprs = x.model.rpar.objs(1).graphics.exprs;
   case 'upgrade' then
     // upgrade if necessary
     y = %f;
     if ~arg1.graphics.iskey['exprs'] || isempty(arg1.graphics.exprs) then
       // arg1 do not have a correct exprs field
       exprs =  arg1.model.rpar.objs(1).graphics.exprs;
       x1 = ENDBLK('define');
       x=arg1;
       x.model.rpar= x1.model.rpar;
       x.graphics.exprs = exprs;
       x.model.rpar.objs(1).graphics.exprs = exprs;
     else
       x=arg1;
       y=%f;
     end
  end
endfunction

