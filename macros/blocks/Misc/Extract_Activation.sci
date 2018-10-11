function [x,y,typ]=Extract_Activation(job,arg1,arg2)

  function scs_m=extract_activation_define () 
    scs_m = instantiate_diagram ();
    blk = instantiate_block("IFTHEL_f");
    exprs= [ "0"; "0" ]
    blk=set_block_exprs(blk,exprs);
    blk = set_block_nin (blk, 1);
    blk = set_block_nout (blk, 0);
    blk = set_block_evtnin (blk, 0);
    blk = set_block_evtnout (blk, 2);
    blk = set_block_origin (blk, [   150.6505,143.8221 ]);
    blk = set_block_size (blk, [   60,60 ]);
    [scs_m, block_tag_1] = add_block(scs_m, blk);

    blk = instantiate_block("CLKSOMV_f");
    blk = set_block_bg_color (blk, 8);
    blk = set_block_evtnin (blk, 3);
    blk = set_block_evtnout (blk, 1);
    blk = set_block_origin (blk, [   169.8214,96.1462 ]);
    blk = set_block_size (blk, [   16.6667,16.6667 ]);
    [scs_m, block_tag_2] = add_block(scs_m, blk);

    blk = instantiate_block("IN_f");
    exprs= [ "1";  "-1";  "-1" ]
    blk=set_block_exprs(blk,exprs);
    blk = set_block_nout (blk, 1);
    blk = set_block_origin (blk, [   102.0790,163.8221 ]);
    blk = set_block_size (blk, [   20,20 ]);
    [scs_m, block_tag_5] = add_block(scs_m, blk);
    blk = instantiate_block("CLKOUTV_f");
    exprs= [ "1" ];
    blk=set_block_exprs(blk,exprs);
    blk = set_block_bg_color (blk, 8);
    blk = set_block_evtnin (blk, 1);
    blk = set_block_origin (blk, [   168.1548,38.5272 ]);
    blk = set_block_size (blk, [   20,30 ]);
    [scs_m, block_tag_7] = add_block(scs_m, blk);
    points=[          0,    -9.8728;    -20.6074,          0;           0,   -23.7554 ]
    [scs_m,obj_num] = add_event_link(scs_m,[block_tag_1, "1"],[block_tag_2, "1"],points);
    points=[          0,-26.5505 ]
    [scs_m,obj_num] = add_event_link(scs_m,[block_tag_1, "2"],[block_tag_2, "2"],points);
    points=mat_create(0,0)
    [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_5, "1"],[block_tag_1, "1"],points);
    points=mat_create(0,0)
    [scs_m,obj_num] = add_event_link(scs_m,[block_tag_2, "1"],[block_tag_7, "1"],points);
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
      scs_m=extract_activation_define () 
      model = mlist(["model","sim","in","in2","intyp","out","out2","outtyp","evtin","evtout",...
		     "state","dstate","odstate","rpar","ipar","opar","blocktype",...
		     "firing","dep_ut","label","nzcross","nmode","equations"],...
		    "csuper",-1,[],1,[],[],1,[],1,[],[],list(),...
		    scs_m,[],list(),"h",[],[%f,%f],"",0,0,list())
      gr_i='xstringb(orig(1),orig(2),[''Extract'';''Activation''],sz(1),sz(2),''fill'')';
      x=standard_define([3 2],model,[],gr_i,'Extract_Activation');
  end
endfunction

