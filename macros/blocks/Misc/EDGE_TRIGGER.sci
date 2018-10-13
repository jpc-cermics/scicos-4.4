function [x,y,typ]=EDGE_TRIGGER(job,arg1,arg2)
  // contains a diagram inside
  
  function blk=EDGE_TRIGGER_define()
    scs_m = instantiate_diagram ();
    blk = EDGETRIGGER('define')
    exprs= [ "0" ]
    blk=set_block_exprs(blk,exprs);
    blk = set_block_nin (blk, 1);
    blk = set_block_nout (blk, 1);
    blk = set_block_origin (blk, [   288.5863,257.1131 ]);
    blk = set_block_size (blk, [   60,40 ]);
    [scs_m, block_tag_1] = add_block(scs_m, blk);
    blk = IFTHEL_f('define')
    exprs= [ "0"; "0" ]
    blk=set_block_exprs(blk,exprs);
    blk = set_block_nin (blk, 1);
    blk = set_block_evtnin (blk, 0);
    blk = set_block_evtnout (blk, 2);
    blk = set_block_origin (blk, [   388.2887,247.1131 ]);
    blk = set_block_size (blk, [   60,60 ]);
    [scs_m, block_tag_2] = add_block(scs_m, blk);
    blk = IN_f('define')
    exprs= [ "1" ]
    blk=set_block_exprs(blk,exprs);
    blk = set_block_nout (blk, 1);
    blk = set_block_origin (blk, [   240.0149,267.1131 ]);
    blk = set_block_size (blk, [   20,20 ]);
    [scs_m, block_tag_4] = add_block(scs_m, blk);
    blk = CLKOUTV_f('define')
    exprs= [ "1" ]
    blk=set_block_exprs(blk,exprs);
    blk = set_block_evtnin (blk, 1);
    blk = set_block_origin (blk, [   398.2887,181.3988 ]);
    blk = set_block_size (blk, [   20,30 ]);
    [scs_m, block_tag_6] = add_block(scs_m, blk);
    points=[ 5.8333,0 ]
    [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_1, "1"],[block_tag_2, "1"],points);
    points=mat_create(0,0)
    [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_4, "1"],[block_tag_1, "1"],points);
    points=mat_create(0,0)
    [scs_m,obj_num] = add_event_link(scs_m,[block_tag_2, "1"],[block_tag_6, "1"],points);
    scs_m=do_silent_eval(scs_m);
    
    model = mlist(["model","sim","in","in2","intyp","out","out2","outtyp","evtin","evtout",...
		   "state","dstate","odstate","rpar","ipar","opar","blocktype",...
		   "firing","dep_ut","label","nzcross","nmode","equations"],"csuper",-1,[],1,[],[],1,[],1,[],[],list(),...
		  scs_m,[],list(),"h",[],[%f,%f],"",0,0,list())
    gr_i='xstringb(orig(1),orig(2),[''EDGE'';''TRIGGER''],sz(1),sz(2),''fill'')';
    blk=standard_define([2 2],model,[],gr_i,'EDGE_TRIGGER');
    blk.graphics.exprs = blk.model.rpar.objs(1).graphics.exprs;
    
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
     [x,changed]=EDGE_TRIGGER('upgrade',arg1);
     if changed then y = max(y,2);end
     newpar=list();
     blk=x.model.rpar.objs(1);
     blk_new = blk;
     ok = execstr("blk_new="+blk.gui+"(""set"",blk)", errcatch=%t);
     if ~ok then
       message(["Error: cannot set parameters in EDGE_TRIGGER_f block";
		catenate(lasterror())]);
       return;
     end
     if ~blk.equal[blk_new] then
       // parameter or states changed
       x.model.rpar.objs(1) = blk_new; // Update
       x.graphics.exprs = blk_new.graphics.exprs;
       newpar(1)=1;// Notify modification
     end
     typ=newpar;
     resume(needcompile=y);
     
    case 'define' then
      x= EDGE_TRIGGER_define();
    case 'upgrade' then
      // upgrade if necessary
      y = %f;
      if ~arg1.graphics.iskey['exprs'] || isempty(arg1.graphics.exprs) then
	// arg1 do not have a correct exprs field
	exprs =  arg1.model.rpar.objs(1).graphics.exprs;
	x = EDGE_TRIGGER('define');
	x.graphics.exprs = exprs;
	x.model.rpar.objs(1).graphics.exprs = exprs;
      else
	x=arg1;
	y=%f;
      end
  end
endfunction
