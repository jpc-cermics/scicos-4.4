function [x,y,typ]=DLATCH(job,arg1,arg2)
  // Copyright INRIA
  // contains a diagram inside
  // upgrade ok 
  function dlatch_draw(orig,sz,o)
    [x,y,typ]=standard_inputs(o)
    dd=sz(1)/8,de=sz(1)*(1/2+1/8);
    w=sz(1)*(1/2-1/8);
    h=sz(2)/4;
    xstringb(orig(1)+dd,y(1)-4,'D',w,h,'fill');
    xstringb(orig(1)+dd,y(2)-4,'C',w,h,'fill');
    [x,y,typ]=standard_outputs(o) ;
    txt='Q'
    xstringb(orig(1)+de,y(1)-4,'Q',w,h,'fill');
    xstringb(orig(1)+de,y(2)-4,'!Q',w,h,'fill');
    w = sz(1);
    h = sz(2)*(1/4)
    xstringb(orig(1),orig(2)-1.5*h,'DLATCH',w,h,'fill');
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
    
    model=scicos_model()
    model.sim='csuper'
    model.in=[1;1]
    model.in2=[1;1]
    model.out=[1;1]
    model.out2=[1;1]
    model.intyp=[5 -1]
    model.outtyp=[5 5]
    model.blocktype='h'
    model.firing=%f
    model.dep_ut=[%t %f]
    model.rpar= dlatch_define();
    gr_i=['dlatch_draw(orig,sz,o);'];
    x=standard_define([2 3],model,[],gr_i,'DLATCH');
   case 'upgrade' then
     x=arg1
  end
endfunction

function scs_m=dlatch_define()
  scs_m = instantiate_diagram ();
  blk = CONST_m('define')
  exprs= [ "m2i(0,''int8'')" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 0);
  blk = set_block_nout (blk, 1);
  blk = set_block_evtnin (blk, 0);
  blk = set_block_evtnout (blk, 0);
  blk = set_block_origin (blk, [    89.6256,223.4447 ]);
  blk = set_block_size (blk, [   20;20 ]);
  blk.model.sim= list("cstblk4_m",4);
  [scs_m, block_tag_1] = add_block(scs_m, blk);

  blk = IFTHEL_f('define')
  exprs= [ "0"; "1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 1);
  blk = set_block_nout (blk, 0);
  blk = set_block_evtnin (blk, 0);
  blk = set_block_evtnout (blk, 2);
  blk = set_block_origin (blk, [   233.3769,340.3054 ]);
  blk = set_block_size (blk, [   60,60 ]);
  [scs_m, block_tag_2] = add_block(scs_m, blk);

  blk = LOGICAL_OP('define')
  exprs= [ "2"; "1"; "5"; "0" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 2);
  blk = set_block_nout (blk, 1);
  blk = set_block_evtnin (blk, 0);
  blk = set_block_evtnout (blk, 0);
  blk = set_block_origin (blk, [   152.8890,260.2450 ]);
  blk = set_block_size (blk, [   60,40 ]);
  blk.model.evtout= mat_create(0,1);
  [scs_m, block_tag_3] = add_block(scs_m, blk);

  blk = SAMPHOLD_m('define')
  exprs= [ "5" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 1);
  blk = set_block_nout (blk, 1);
  blk = set_block_evtnin (blk, 1);
  blk = set_block_evtnout (blk, 0);
  blk = set_block_origin (blk, [   233.7216,260.2450 ]);
  blk = set_block_size (blk, [   40,40 ]);
  blk.model.evtout= mat_create(0,1);
  [scs_m, block_tag_4] = add_block(scs_m, blk);

  blk = LOGICAL_OP('define')
  exprs=  [ "1"; "5"; "5"; "0" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 1);
  blk = set_block_nout (blk, 1);
  blk = set_block_evtnin (blk, 0);
  blk = set_block_evtnout (blk, 0);
  blk = set_block_origin (blk, [   317.4670,309.4681 ]);
  blk = set_block_size (blk, [   60,40 ]);
  blk.model.evtout= mat_create(0,1);
  [scs_m, block_tag_8] = add_block(scs_m, blk);

  blk = SPLIT_f('define')
  blk = set_block_nin (blk, 1);
  blk = set_block_nout (blk, 2);
  blk = set_block_origin (blk, [   305.0960,280.8328 ]);
  blk = set_block_size (blk, [   0.3333,0.3333 ]);
  [scs_m, block_tag_10] = add_block(scs_m, blk);

  blk = IN_f('define')
  exprs= [ "2";"-1";"-1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nout (blk, 1);
  blk = set_block_origin (blk, [   104.8055,340.3054 ]);
  blk = set_block_size (blk, [   20,20 ]);
  [scs_m, block_tag_12] = add_block(scs_m, blk);

  blk = IN_f('define')
  exprs=  [ "1";"-1"; "-1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nout (blk, 1);
  blk = set_block_origin (blk, [   104.3176,276.9117 ]);
  blk = set_block_size (blk, [   20,20 ]);
  [scs_m, block_tag_14] = add_block(scs_m, blk);

  blk = OUT_f('define')
  exprs= [ "2" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 1);
  blk = set_block_origin (blk, [   406.0384,319.4681 ]);
  blk = set_block_size (blk, [   20,20 ]);
  [scs_m, block_tag_16] = add_block(scs_m, blk);

  blk = OUT_f('define')
  exprs= [ "1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 1);
  blk = set_block_origin (blk, [   405.0960,250.8328 ]);
  blk = set_block_size (blk, [   20,20 ]);
  [scs_m, block_tag_18] = add_block(scs_m, blk);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_3, "1"],[block_tag_4, "1"],points);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_event_link(scs_m,[block_tag_2, "1"],[block_tag_4, "1"],points);
  points=[   26.1206,0 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_1, "1"],[block_tag_3, "2"],points);
  points=[   22.8030,0.2830 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_4, "1"],[block_tag_10, "1"],points);
  points=[         0,48.6353 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_10, "1"],[block_tag_8, "1"],points);
  points=[   50,    0;     0,   20 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_12, "1"],[block_tag_2, "1"],points);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_14, "1"],[block_tag_3, "1"],points);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_8, "1"],[block_tag_16, "1"],points);
  points=[    50,     0;      0,   -20 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_10, "2"],[block_tag_18, "1"],points);
  scs_m=do_silent_eval(scs_m);
endfunction


