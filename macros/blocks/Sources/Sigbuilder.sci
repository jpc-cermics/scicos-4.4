function [x,y,typ]=Sigbuilder(job,arg1,arg2)
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
    //paths to updatable parameters or states
    ppath = list(1,3)
    newpar=list();
    y=acquire('needcompile',def=0);
    for path=ppath do
      spath=list('model','rpar','objs',path);
      xx=arg1(spath)// get the block
      ok=execstr('xxn='+xx.gui+'(''set'',xx)',errcatch=%t);
      if ~ok then 
	message(['Error: failed to set parameter block in Sigbuilder';
	         catenate(lasterror())]);
	continue;
      end
      if ~xx.equal[xxn] then 
	[needcompile]=scicos_object_check_needcompile(xx,xxn);
	// parameter or states changed
	arg1(spath)=xxn// Update
	newpar(size(newpar)+1)=path // Notify modification
	y=max(y,needcompile);
      end
    end
    x=arg1
    typ=newpar
    resume(needcompile=y);
   case 'define' then
     // define the block
     scs_m_1=Sigbuilder_define()
     model=scicos_model(sim="csuper",in=[],in2=[],intyp=1,out=-1,out2=[],outtyp=1,
			evtin=[],evtout=1,state=[],dstate=[],odstate=list(),
			rpar=scs_m_1,ipar=[],opar=list(),blocktype="h",firing=[],
			dep_ut=[%f,%f],label="",nzcross=0,nmode=0,equations=list())
     // we use the gr_i of the internal curve 
     gr_i = ['arg1=arg1.model.rpar.objs(1);'
	     'model=arg1.model;';
	     model.rpar.objs(1).graphics.gr_i(1)];
     x=standard_define([2 2],model,[],gr_i,'Sigbuilder');
  end
endfunction

// just in case for compatibility 
function [X,Y,orpar]=Do_Spline2(N,order,x,y)
  [X,Y,orpar]=Do_Spline(N,order,x,y);
endfunction

function scs_m=Sigbuilder_define()
  scs_m = instantiate_diagram ();
  blk = instantiate_block("CURVE_c");
  exprs= ...
  [ "3";
    "[0,1,2]";
    "[10,20,-30]";
    "yes";
    "no" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nout (blk, 1);
  blk = set_block_evtnin (blk, 1);
  blk = set_block_evtnout (blk, 1);
  blk = set_block_origin (blk, [   329.6347,606.1852 ]);
  blk = set_block_size (blk, [   40,40 ]);
  [scs_m, block_tag_1] = add_block(scs_m, blk);

  blk = instantiate_block("OUT_f");
  exprs=[ "1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 1);
  blk = set_block_origin (blk, [   398.2062,616.1852 ]);
  blk = set_block_size (blk, [   20,20 ]);
  [scs_m, block_tag_5] = add_block(scs_m, blk);
  
  blk = instantiate_block("CLKSPLIT_f");
  blk = set_block_evtnin (blk, 1);
  blk = set_block_evtnout (blk, 2);
  blk = set_block_origin (blk, [   349.4953;565.1070 ]);
  blk = set_block_size (blk, [   0.3333,0.3333 ]);
  [scs_m, block_tag_3] = add_block(scs_m, blk);

  blk = instantiate_block("CLKOUTV_f");
  exprs=[ "1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_evtnin (blk, 1);
  blk = set_block_origin (blk, [   339.4953,505.1070 ]);
  blk = set_block_size (blk, [   20,30 ]);
  [scs_m, block_tag_7] = add_block(scs_m, blk);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_event_link(scs_m,[block_tag_1, "1"],[block_tag_3, "1"],points);
  points=[    -82.7993,           0;            0,    125.8878;      82.9387,           0 ]
  [scs_m,obj_num] = add_event_link(scs_m,[block_tag_3, "2"],[block_tag_1, "1"],points);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_1, "1"],[block_tag_5, "1"],points);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_event_link(scs_m,[block_tag_3, "1"],[block_tag_7, "1"],points);
  scs_m=do_silent_eval(scs_m);
endfunction
