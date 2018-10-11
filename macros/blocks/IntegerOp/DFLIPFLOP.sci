function [x,y,typ]=DFLIPFLOP(job,arg1,arg2)
// Copyright INRIA

  function dflipflop_draw(orig,sz,o)
    [x,y,typ]=standard_inputs(o)
    dd=sz(1)/8,de=sz(1)*(1/2+1/8);
    w=sz(1)*(1/2-1/8);
    h=sz(2)/4;
    xstringb(orig(1)+dd,y(1)-4,'D',w,h,'fill');
    xstringb(orig(1)+dd,y(2)-4,'clk',w,h,'fill');
    xstringb(orig(1)+dd,y(3)-4,'en',w,h,'fill');
    [x,y,typ]=standard_outputs(o) ;
    txt='Q'
    xstringb(orig(1)+de,y(1)-4,'Q',w,h,'fill');
    xstringb(orig(1)+de,y(2)-4,'!Q',w,h,'fill');
    w = sz(1);
    h = sz(2)*(1/4)
    xstringb(orig(1),orig(2)-1.5*h,'D FLIP-FLOP',w,h,'fill');
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
    model.in=[1;1;1]
    model.in2=[1;1;1]
    model.out=[1;1]
    model.out2=[1;1]
    model.intyp=[5 1 1]
    model.outtyp=[5 5]
    model.blocktype='h'
    model.firing=%f
    model.dep_ut=[%t %f]
    model.rpar=dflipflop_define();
    model.ipar=1;
    gr_i=['dflipflop_draw(orig,sz,o);'];
    x=standard_define([2 3],model,[],gr_i,'DFLIPFLOP');
  end
endfunction

function scs_m=dflipflop_define()
  scs_m = instantiate_diagram ();
  blk = CONST_m('define')
  exprs= [ "m2i(0,''int8'')" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 0);
  blk = set_block_nout (blk, 1);
  blk = set_block_evtnin (blk, 0);
  blk = set_block_evtnout (blk, 0);
  blk = set_block_origin (blk, [   109.6256,263.4447 ]);
  blk = set_block_size (blk, [   20,20 ]);
  blk.model.sim= list("cstblk4_m",4);
  blk.model.evtout= mat_create(0,1);
  [scs_m, block_tag_1] = add_block(scs_m, blk);
  
  blk = IFTHEL_f('define')
  exprs= [ "1";"1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 1);
  blk = set_block_nout (blk, 0);
  blk = set_block_evtnin (blk, 1);
  blk = set_block_evtnout (blk, 2);
  blk = set_block_origin (blk, [   239.9829,378.2166 ]);
  blk = set_block_size (blk, [   60,60 ]);
  [scs_m, block_tag_2] = add_block(scs_m, blk);
  
  blk = LOGICAL_OP('define')
  exprs=  [ "2"; "1"; "5"; "0" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 2);
  blk = set_block_nout (blk, 1);
  blk = set_block_evtnin (blk, 0);
  blk = set_block_evtnout (blk, 0);
  blk = set_block_origin (blk, [   152.8890,260.2450 ]);
  blk = set_block_size (blk, [   60,40 ]);
  blk.model.sim= list("logicalop_i8",4);
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
  exprs=  [ "1";    "5";    "5";    "0" ];
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 1);
  blk = set_block_nout (blk, 1);
  blk = set_block_evtnin (blk, 0);
  blk = set_block_evtnout (blk, 0);
  blk = set_block_origin (blk, [   373.2411,309.4681 ]);
  blk = set_block_size (blk, [   60,40 ]);
  blk.model.sim= list("logicalop_i8",4);
  blk.model.evtout= mat_create(0,1);
  [scs_m, block_tag_5] = add_block(scs_m, blk);
  
  blk = IN_f('define')
  exprs=  [ "3";  "-1";  "-1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nout (blk, 1);
  blk = set_block_origin (blk, [   199.4847,398.2166 ]);
  blk = set_block_size (blk, [   20,20 ]);
  [scs_m, block_tag_6] = add_block(scs_m, blk);
  
  blk = IN_f('define')
  exprs= [ "1"; "-1";  "-1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nout (blk, 1);
  blk = set_block_origin (blk, [   104.3176,276.9117 ]);
  blk = set_block_size (blk, [   20,20 ]);
  [scs_m, block_tag_7] = add_block(scs_m, blk);
  
  blk = OUT_f('define')
  exprs= [ "2" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 1);
  blk = set_block_origin (blk, [   457.4093,320.2013 ]);
  blk = set_block_size (blk, [   20,20 ]);
  [scs_m, block_tag_8] = add_block(scs_m, blk);
  
  blk = OUT_f('define')
  exprs=  [ "1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 1);
  blk = set_block_origin (blk, [   376.4669,270.8328 ]);
  blk = set_block_size (blk, [   20,20 ]);
  [scs_m, block_tag_9] = add_block(scs_m, blk);
  blk = ANDBLK('define')
  blk = set_block_evtnin (blk, 2);
  blk = set_block_evtnout (blk, 1);
  blk = set_block_origin (blk, [   233.7304,318.7441 ]);
  blk = set_block_size (blk, [   40,40 ]);
  [scs_m, block_tag_10] = add_block(scs_m, blk);
  
  blk = EDGE_TRIGGER('define')
  exprs=  [ "1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 1);
  blk = set_block_evtnout (blk, 1);
  blk = set_block_origin (blk, [   133.9064,385.3420 ]);
  blk = set_block_size (blk, [   60,40 ]);
  [scs_m, block_tag_11] = add_block(scs_m, blk);
  
  blk = IN_f('define')
  exprs=  [ "2";  "-1";  "-1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nout (blk, 1);
  blk = set_block_origin (blk, [    79.5948,395.4765 ]);
  blk = set_block_size (blk, [   20,20 ]);
  [scs_m, block_tag_12] = add_block(scs_m, blk);
  blk = Extract_Activation('define')
  blk = set_block_nin (blk, 1);
  blk = set_block_nout (blk, 0);
  blk = set_block_evtnin (blk, 0);
  blk = set_block_evtnout (blk, 1);
  blk = set_block_origin (blk, [   239.8219,456.5768 ]);
  blk = set_block_size (blk, [   60,40 ]);
  [scs_m, block_tag_13] = add_block(scs_m, blk);
  
  blk = SUM_f('define')
  blk = set_block_nin (blk, 3);
  blk = set_block_nout (blk, 1);
  blk = set_block_origin (blk, [   200.5252,469.1317 ]);
  blk = set_block_size (blk, [   16.6667,16.6667 ]);
  [scs_m, block_tag_14] = add_block(scs_m, blk);
  
  blk = SPLIT_f('define')
  blk = set_block_nin (blk, 1);
  blk = set_block_nout (blk, 2);
  blk = set_block_origin (blk, [   110.2558,405.4208 ]);
  blk = set_block_size (blk, [   0.3333,0.3333 ]);
  [scs_m, block_tag_15] = add_block(scs_m, blk);
  
  blk = SPLIT_f('define')
  blk = set_block_nin (blk, 1);
  blk = set_block_nout (blk, 2);
  blk = set_block_origin (blk, [   222.5413,408.2166 ]);
  blk = set_block_size (blk, [   0.3333,0.3333 ]);
  [scs_m, block_tag_16] = add_block(scs_m, blk);
  
  blk = SELECT_m('define')
  exprs= [ "5";  "2";   "1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 2);
  blk = set_block_nout (blk, 1);
  blk = set_block_evtnin (blk, 2);
  blk = set_block_evtnout (blk, 0);
  blk = set_block_origin (blk, [   298.8637,253.5732 ]);
  blk = set_block_size (blk, [   40,40 ]);
  blk.model.evtout= mat_create(0,1);
  [scs_m, block_tag_17] = add_block(scs_m, blk);
  
  blk = SPLIT_f('define')
  blk = set_block_nin (blk, 1);
  blk = set_block_nout (blk, 2);
  blk = set_block_origin (blk, [   357.5733,280.8328 ]);
  blk = set_block_size (blk, [   0.3333,0.3333 ]);
  [scs_m, block_tag_18] = add_block(scs_m, blk);
  
  blk = SPLIT_f('define')
  blk = set_block_nin (blk, 1);
  blk = set_block_nout (blk, 2);
  blk = set_block_origin (blk, [   140.3452,273.4916 ]);
  Blk = set_block_size (blk, [   0.3333,0.3333 ]);
  [scs_m, block_tag_19] = add_block(scs_m, blk);
  
  blk = CLKSPLIT_f('define')
  blk = set_block_evtnin (blk, 1);
  blk = set_block_evtnout (blk, 2);
  blk = set_block_origin (blk, [   253.7257,309.2954 ]);
  blk = set_block_size (blk, [   0.3333,0.3333 ]);
  [scs_m, block_tag_20] = add_block(scs_m, blk);

  points=mat_create(0,0)
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_3, "1"],[block_tag_4, "1"],points);
  points=[   1.07409, 0;0, 0.04690 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_1, "1"],[block_tag_19, "1"],points);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_6, "1"],[block_tag_16, "1"],points);
  points=[1.000e+01,0; 0, -3.333e-05; 5.000e+00,0; 0, -3.333e-09 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_7, "1"],[block_tag_3, "1"],points);
  points=[ 3.5127,0; 0, 0.7332 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_5, "1"],[block_tag_8, "1"],points);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_event_link(scs_m,[block_tag_2, "1"],[block_tag_10, "2"],points);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_event_link(scs_m,[block_tag_10, "1"],[block_tag_20, "1"],points);
  points=[0,-15.1694 ]
  [scs_m,obj_num] = add_event_link(scs_m,[block_tag_11, "1"],[block_tag_10, "1"],points);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_event_link(scs_m,[block_tag_13, "1"],[block_tag_2, "1"],points);
  points=[5.33050,0; 0, -0.05570 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_12, "1"],[block_tag_15, "1"],points);
  points=[2.04042,0; 0, -0.02132; 7.53959,0; 0, -0.05748 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_15, "1"],[block_tag_11, "1"],points);
  points=[0,6.371e+01; 4.930e+01,0; 0, -1.000e-04; 2.465e+01,0; 0,1.000e-03 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_15, "2"],[block_tag_14, "1"],points);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_16, "1"],[block_tag_2, "1"],points);
  points=[0,44.7849;-13.6827,0; 0,32.7969 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_16, "2"],[block_tag_14, "3"],points);
  points=[5.83880000, 0;0, -0.88830000; 2.91940714, 0;0,0.00005000 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_14, "1"],[block_tag_13, "1"],points);
  points=[4.000e+00,0; 0, -5.133e-03; 2.000e+00,0; 0, -3.333e-07 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_4, "1"],[block_tag_17, "1"],points);
  points=[ 10.1381, 0;0,7.2596 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_17, "1"],[block_tag_18, "1"],points);
  points=[0,4.864e+01; 3.548e+00,0; 0, -5.684e-14; 1.774e+00,0; 0, -4.700e-03 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_18, "1"],[block_tag_5, "1"],points);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_18, "2"],[block_tag_9, "1"],points);
  points=[ 1.986190000, 0;0, 0.086730000;0.993090714, 0;0, 0.000003333 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_19, "1"],[block_tag_3, "2"],points);
  points=[0, -2.578e+01; 1.499e+02,0; 0,1.920e+01;-1.429e-05,0; 0,3.333e-05 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_19, "2"],[block_tag_17, "2"],points);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_event_link(scs_m,[block_tag_20, "1"],[block_tag_4, "1"],points);
  points=[ 58.4713,0 ]
  [scs_m,obj_num] = add_event_link(scs_m,[block_tag_20, "2"],[block_tag_17, "1"],points);
  points=[0, -56.6078; 45.5474,0 ]
  [scs_m,obj_num] = add_event_link(scs_m,[block_tag_2, "2"],[block_tag_17, "2"],points);
  scs_m=do_silent_eval(scs_m);
endfunction

