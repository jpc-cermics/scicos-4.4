function [x,y,typ]=EDGE_TRIGGER(job,arg1,arg2)

  function blk=EDGE_TRIGGER_define()
    scs_m = instantiate_diagram ();
    blk = instantiate_block("EDGETRIGGER");
    exprs= [ "0" ]
    blk=set_block_exprs(blk,exprs);
    blk = set_block_nin (blk, 1);
    blk = set_block_nout (blk, 1);
    blk = set_block_origin (blk, [   288.5863,257.1131 ]);
    blk = set_block_size (blk, [   60,40 ]);
    [scs_m, block_tag_1] = add_block(scs_m, blk);
    blk = instantiate_block("IFTHEL_f");
    exprs= [ "0"; "0" ]
    blk=set_block_exprs(blk,exprs);
    blk = set_block_nin (blk, 1);
    blk = set_block_evtnin (blk, 0);
    blk = set_block_evtnout (blk, 2);
    blk = set_block_origin (blk, [   388.2887,247.1131 ]);
    blk = set_block_size (blk, [   60,60 ]);
    [scs_m, block_tag_2] = add_block(scs_m, blk);
    blk = instantiate_block("IN_f");
    exprs= [ "1" ]
    blk=set_block_exprs(blk,exprs);
    blk = set_block_nout (blk, 1);
    blk = set_block_origin (blk, [   240.0149,267.1131 ]);
    blk = set_block_size (blk, [   20,20 ]);
    [scs_m, block_tag_4] = add_block(scs_m, blk);
    blk = instantiate_block("CLKOUTV_f");
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
      newpar=list();
      if arg1.graphics.iskey['exprs'] && ~isempty(arg1.graphics.exprs) then
	arg1.model.rpar.objs(1).graphics.exprs = arg1.graphics.exprs;
      end
      // paths to updatable parameters or states
      blk = arg1.model.rpar.objs(1);
      while %t
	ok=execstr('blk_new='+blk.gui+'(''set'',blk)',errcatch=%t);
	if ~ok then 
	  message(['Error: failed to set parameter block in EDGE_TRIGGER ';
		   catenate(lasterror())]);
	  continue;
	end
	if ~blk.equal[blk_new] then 
	  [needcompile]=scicos_object_check_needcompile(blk,blk_new);
	  // parameter or states changed
	  arg1.model.rpar.objs(1)= blk_new;// Update
	  newpar(1)=1; // Notify modification
	  y=max(y,needcompile);
	  resume(needcompile=y);
	end
	break;
      end
      x=arg1
      typ=newpar;
    case 'define' then
      x= EDGE_TRIGGER_define();
  end
endfunction
