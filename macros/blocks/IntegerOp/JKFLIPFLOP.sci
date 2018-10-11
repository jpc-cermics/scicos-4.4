function [x,y,typ]=JKFLIPFLOP(job,arg1,arg2)
// Copyright INRIA
  
  function draw_jkflipflop(orig,sz,o)
    [x,y,typ]=standard_inputs(o)
    dd=sz(1)/8,de=sz(1)*(1/2+1/8);
    w=sz(1)*(1/2-1/8);
    h=sz(2)/4;
    xstringb(orig(1)+dd,y(1)-4,'J',w,h,'fill');
    xstringb(orig(1)+dd,y(2)-4,'clk',w,h,'fill');
    xstringb(orig(1)+dd,y(3)-4,'K',w,h,'fill');
    [x,y,typ]=standard_outputs(o) ;
    txt='Q'
    xstringb(orig(1)+de,y(1)-4,'Q',w,h,'fill');
    xstringb(orig(1)+de,y(2)-4,'!Q',w,h,'fill');
    w = sz(1);
    h = sz(2)*(1/4)
    xstringb(orig(1),orig(2)-1.5*h,'JK FLIP-FLOP',w,h,'fill');
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
     // if isempty(exprs) then exprs=sci2exp(int8(0));end
     newpar=list()
     xx=arg1.model.rpar.objs(1);// get the 1/z  block
     exprs=xx.graphics.exprs(1)
     model=xx.model;
     init_old= model.odstate(1)
     while %t do
       [ok,init,exprs0]=getvalue(['Set parameters';'The Initial Value must be 0 or 1 of type int8';
				  'Negatif values are considered as int8(0)';
				  'Positif values are considered as int8(1)'],
				 ['Initial Value'],
				 list('vec',1),exprs);
       if ~ok then break,end
       if i2m(init) <=0 then init=m2i(0,'int8');
       elseif i2m(init) >0 then init=m2i(1,'int8');
       end
       if ok then 
	 xx.graphics.exprs(1)=exprs0
	 model.odstate(1)=init
	 xx.model=model
	 arg1.model.rpar.objs(1)=xx;// Update
	 break
       end
     end
     if ok then
       if init_old<>init then 
         // parameter  changed
         newpar(size(newpar)+1)=1;// Notify modification
	 y=max(y,2);
       end
     end
     x=arg1
     typ=newpar
   case 'define' then
     model=scicos_model()
     model.sim='csuper'
     model.in=[1;1;1]
     model.in2=[1;1;1]
     model.out=[1;1]
     model.out2=[1;1]
     model.intyp=[5 1 5]
     model.outtyp=[5 5]
     model.blocktype='h'
     model.firing=%f
     model.dep_ut=[%t %f]
     // model.ipar=1 // turn to masked block
     if %t then 
       // using the new saved diagram obtained by 
       diagram=jklflipflop_diagram_new();
       diagram=do_eval(diagram);
       model.rpar=diagram;
     else
       model.rpar=jklflipflop_diagram()
     end
     gr_i=['draw_jkflipflop(orig,sz,o);'];
     x=standard_define([2 3],model,[],gr_i,'JKFLIPFLOP');
  end
endfunction


function scs_m=jklflipflop_diagram_new()
// internal diagram of block poo
  x_0=scicos_diagram();
  x_1=scicos_params();
  x_1.wpar=      [   182.7768,   107.6623,   555.8425,   422.2770,   608.0000,   429.0000 ,...
		     0,    29.5000,   523.0000,   454.0000,   503.0000,    99.0000 ,...
		     1.4000,   521.0000,   370.0000 ]
  x_1.context=      [ " " ]
  x_2=scicos_options();
  x_3=list();
  x_3(1)=        [   5,   1 ]
  x_3(2)=        [   4,   1 ]
  x_2.ID=x_3;clear('x_3');
  x_1.options=x_2;clear('x_2');
  x_1.title=      [ "SuperBlock" ]
  x_1.tf=      [   60 ]
  x_1.Title=      [ "JKFLIPFLOP" ]
  x_1.tol=      [   1.000e-04;
		    1.000e-06;
		    1.000e-10;
		    1.000e+05;
		    0;
		    0;
		    0 ]
  x_0.props=x_1;clear('x_1');
  x_1=list();
  x_2=DOLLAR_m('define');
  x_2.graphics.peout= []
  x_2.graphics.exprs=       [ "m2i(0,''int8'')";
		    "1" ]
  x_2.graphics.pin=       [   7 ]
  x_2.graphics.pout=       [   5 ]
  x_2.graphics.in_implicit=       [ "E" ]
  x_2.graphics.out_implicit=       [ "E" ]
  x_2.graphics.sz=       [   40,   40 ]
  x_2.graphics.flip=       [  %f ]
  x_2.graphics.pein= []
  x_2.graphics.orig=       [   299.9696,   261.5840 ]
  x_1(1)=x_2;clear('x_2');
  x_2=EDGE_TRIGGER('define');
  x_2.graphics.peout=       [   8 ]
  x_2.graphics.pin=       [   14 ]
  x_2.graphics.in_implicit=       [ "E" ]
  x_2.graphics.sz=       [   60,   40 ]
  x_2.graphics.orig=       [   292.5245,   323.5489 ]
  x_1(2)=x_2;clear('x_2');
  x_2=LOGIC('define');
  x_2.graphics.peout= []
  x_2.graphics.exprs=       [ "[0;1;1;1;0;0;1;0]";
		    "0" ]
  x_2.graphics.pin=       [    5;
		    16;
		    18 ]
  x_2.graphics.pout=       [   4 ]
  x_2.graphics.in_implicit=       [ "E";
		    "E";
		    "E" ]
  x_2.graphics.out_implicit=       [ "E" ]
  x_2.graphics.sz=       [   40,   40 ]
  x_2.graphics.pein=       [   8 ]
  x_2.graphics.orig=       [   302.7961,   202.5278 ]
  x_1(3)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.xx=       [   351.3676;
		    368.8279;
		    368.8279 ]
  x_2.yy=       [   222.5278;
		    222.5278;
		    223.0647 ]
  x_2.from=       [   3,   1,   0 ]
  x_2.to=       [   10,    1,    1 ]
  x_1(4)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.xx=       [   291.3982;
		    274.1823;
		    274.1823;
		    294.2247 ]
  x_2.yy=       [   281.5840;
		    281.5840;
		    232.5278;
		    232.5278 ]
  x_2.from=       [   1,   1,   0 ]
  x_2.to=       [   3,   1,   1 ]
  x_1(5)=x_2;clear('x_2');
  x_2=SPLIT_f('define');
  x_2.graphics.pin=       [   11 ]
  x_2.graphics.pout=       [    7;
		    20 ]
  x_2.graphics.in_implicit=       [ "E" ]
  x_2.graphics.out_implicit=       [ "E";
		    "E";
		    "E" ]
  x_2.graphics.sz=       [   0.3333,   0.3333 ]
  x_2.graphics.orig=       [   368.8279,   243.4507 ]
  x_1(6)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.xx=       [   368.8279;
		    368.8279;
		    345.6839 ]
  x_2.yy=       [   243.4507;
		    281.5840;
		    281.5840 ]
  x_2.from=       [   6,   1,   0 ]
  x_2.to=       [   1,   1,   1 ]
  x_1(7)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.xx=       [   322.5245;
		    374.6974;
		    374.6974;
		    322.7961 ]
  x_2.yy=       [   317.8346;
		    317.8346;
		    248.2421;
		    248.2421 ]
  x_2.from=       [   2,   1,   0 ]
  x_2.ct=       [    5,   -1 ]
  x_2.to=       [   3,   1,   1 ]
  x_1(8)=x_2;clear('x_2');
  x_2=LOGICAL_OP('define');
  x_2.graphics.peout= []
  x_2.graphics.exprs=       [ "1";
		    "5";
		    "5";
		    "0" ]
  x_2.graphics.pin=       [   12 ]
  x_2.graphics.pout=       [   22 ]
  x_2.graphics.in_implicit=       [ "E" ]
  x_2.graphics.out_implicit=       [ "E" ]
  x_2.graphics.sz=       [   60,   40 ]
  x_3=list();
  x_3(1)=        [ "xstringb(orig(1),orig(2),[''Logical Op '';OPER],sz(1),sz(2),''fill'');" ]
  x_3(2)=        [   8 ]
  x_2.graphics.gr_i=x_3;clear('x_3');
  x_2.graphics.pein= []
  x_2.graphics.orig=       [   377.6322,   159.2536 ]
  x_1(9)=x_2;clear('x_2');
  x_2=SPLIT_f('define');
  x_2.graphics.pin=       [   4 ]
  x_2.graphics.pout=       [   11;
		    12 ]
  x_2.graphics.in_implicit=       [ "E" ]
  x_2.graphics.out_implicit=       [ "E";
		    "E";
		    "E" ]
  x_2.graphics.sz=       [   0.3333,   0.3333 ]
  x_2.graphics.orig=       [   368.8279;
		    223.0647 ]
  x_1(10)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.xx=       [   368.8279;
		    368.8279 ]
  x_2.yy=       [   223.0647;
		    243.4507 ]
  x_2.from=       [   10,    1,    0 ]
  x_2.to=       [   6,   1,   1 ]
  x_1(11)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.xx=       [   368.8279;
		    368.8279;
		    369.0607 ]
  x_2.yy=       [   223.0647;
		    177.7867;
		    179.2536 ]
  x_2.from=       [   10,    2,    0 ]
  x_2.to=       [   9,   1,   1 ]
  x_1(12)=x_2;clear('x_2');
  x_2=IN_f('define');
  x_2.graphics.exprs=       [ "2";
		    "-1";
		    "-1" ]
  x_2.graphics.pout=       [   14 ]
  x_2.graphics.sz=       [   20,   20 ]
  x_2.graphics.orig=       [   205.8180,   333.5489 ]
  x_1(13)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.from=       [   13,    1,    0 ]
  x_2.xx=       [   225.8180;
		    273.9531;
		    283.9531 ]
  x_2.yy=       [   343.5489;
		    343.5489;
		    343.5489 ]
  x_2.to=       [   2,   1,   1 ]
  x_1(14)=x_2;clear('x_2');
  x_2=IN_f('define');
  x_2.graphics.pout=       [   16 ]
  x_2.graphics.sz=       [   20,   20 ]
  x_2.graphics.orig=       [   212.4228,   213.2612 ]
  x_1(15)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.from=       [   15,    1,    0 ]
  x_2.xx=       [   232.4228;
		    284.2247;
		    284.2247;
		    294.2247 ]
  x_2.yy=       [   223.2612;
		    223.2612;
		    222.5278;
		    222.5278 ]
  x_2.to=       [   3,   2,   1 ]
  x_1(16)=x_2;clear('x_2');
  x_2=IN_f('define');
  x_2.graphics.exprs=       [ "3";
		    "-1";
		    "-1" ]
  x_2.graphics.pout=       [   18 ]
  x_2.graphics.sz=       [   20,   20 ]
  x_2.graphics.orig=       [   213.8895,   175.3932 ]
  x_1(17)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.from=       [   17,    1,    0 ]
  x_2.xx=       [   233.8895;
		    284.2247;
		    284.2247;
		    294.2247 ]
  x_2.yy=       [   185.3932;
		    185.3932;
		    212.5278;
		    212.5278 ]
  x_2.to=       [   3,   3,   1 ]
  x_1(18)=x_2;clear('x_2');
  x_2=OUT_f('define');
  x_2.graphics.sz=       [   20,   20 ]
  x_2.graphics.orig=       [   388.8279,   233.4507 ]
  x_2.graphics.pin=       [   20 ]
  x_1(19)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.from=       [   6,   2,   0 ]
  x_2.xx=       [   368.8279;
		    388.8279 ]
  x_2.yy=       [   243.4507;
		    243.4507 ]
  x_2.to=       [   19,    1,    1 ]
  x_1(20)=x_2;clear('x_2');
  x_2=OUT_f('define');
  x_2.graphics.exprs=       [ "2" ]
  x_2.graphics.sz=       [   20,   20 ]
  x_2.graphics.orig=       [   466.2036,   169.2536 ]
  x_2.graphics.pin=       [   22 ]
  x_1(21)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.from=       [   9,   1,   0 ]
  x_2.xx=       [   446.2036;
		    466.2036 ]
  x_2.yy=       [   179.2536;
		    179.2536 ]
  x_2.to=       [   21,    1,    1 ]
  x_1(22)=x_2;clear('x_2');
  x_0.objs=x_1;clear('x_1');
  scs_m=x_0;clear('x_0');
endfunction

function scs_m=jklflipflop_define()
  scs_m = instantiate_diagram ();
  blk = instantiate_block("DOLLAR_m");
  exprs=  [ "m2i(0,''int8'')"; "1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 1);
  blk = set_block_nout (blk, 1);
  blk = set_block_evtnin (blk, 0);
  blk = set_block_evtnout (blk, 0);
  blk = set_block_flip (blk, %t);
  blk = set_block_origin (blk, [   299.9696,261.5840 ]);
  blk = set_block_size (blk, [   40,40 ]);
  blk.model.evtout= mat_create(0,1);
  [scs_m, block_tag_1] = add_block(scs_m, blk);
  blk = instantiate_block("EDGE_TRIGGER");
  exprs=  [ "0" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 1);
  blk = set_block_evtnout (blk, 1);
  blk = set_block_origin (blk, [   292.5245,323.5489 ]);
  blk = set_block_size (blk, [   60,40 ]);
  [scs_m, block_tag_2] = add_block(scs_m, blk);
  blk = instantiate_block("LOGIC");
  exprs=  [ "[0;1;1;1;0;0;1;0]";  "0" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 4);
  blk = set_block_nout (blk, 1);
  blk = set_block_evtnin (blk, 1);
  blk = set_block_evtnout (blk, 0);
  blk = set_block_origin (blk, [   302.7961,202.5278 ]);
  blk = set_block_size (blk, [   40,40 ]);
  blk.model.evtout= mat_create(0,1);
  [scs_m, block_tag_3] = add_block(scs_m, blk);
  blk = instantiate_block("SPLIT_f");
  blk = set_block_nin (blk, 1);
  blk = set_block_nout (blk, 2);
  blk = set_block_origin (blk, [   368.8279,243.4507 ]);
  blk = set_block_size (blk, [   0.3333,0.3333 ]);
  [scs_m, block_tag_6] = add_block(scs_m, blk);
  blk = instantiate_block("LOGICAL_OP");
  exprs= [ "1";  "5";  "5";  "0" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 1);
  blk = set_block_nout (blk, 1);
  blk = set_block_evtnin (blk, 0);
  blk = set_block_evtnout (blk, 0);
  blk = set_block_origin (blk, [   377.6322,159.2536 ]);
  blk = set_block_size (blk, [   60,40 ]);
  blk.model.evtout= mat_create(0,1);
  [scs_m, block_tag_9] = add_block(scs_m, blk);

  blk = instantiate_block("SPLIT_f");
  blk = set_block_nin (blk, 1);
  blk = set_block_nout (blk, 2);
  blk = set_block_origin (blk, [   368.8279;223.0647 ]);
  blk = set_block_size (blk, [   0.3333,0.3333 ]);
  [scs_m, block_tag_10] = add_block(scs_m, blk);
  blk = instantiate_block("IN_f");
  exprs=  [ "2";  "-1"; "-1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nout (blk, 1);
  blk = set_block_origin (blk, [   205.8180,333.5489 ]);
  blk = set_block_size (blk, [   20,20 ]);
  [scs_m, block_tag_13] = add_block(scs_m, blk);
  blk = instantiate_block("IN_f");
  exprs= [ "1";"-1";  "-1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nout (blk, 1);
  blk = set_block_origin (blk, [   212.4228,213.2612 ]);
  blk = set_block_size (blk, [   20,20 ]);
  [scs_m, block_tag_15] = add_block(scs_m, blk);
  blk = instantiate_block("IN_f");
  exprs= [ "3";  "-1";  "-1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nout (blk, 1);
  blk = set_block_origin (blk, [   213.8895,175.3932 ]);
  blk = set_block_size (blk, [   20,20 ]);
  [scs_m, block_tag_17] = add_block(scs_m, blk);
  blk = instantiate_block("OUT_f");
  exprs=   [ "1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 1);
  blk = set_block_origin (blk, [   388.8279,233.4507 ]);
  blk = set_block_size (blk, [   20,20 ]);
  [scs_m, block_tag_19] = add_block(scs_m, blk);
  blk = instantiate_block("OUT_f");
  exprs=   [ "2" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 1);
  blk = set_block_origin (blk, [   466.2036,169.2536 ]);
  blk = set_block_size (blk, [   20,20 ]);
  [scs_m, block_tag_21] = add_block(scs_m, blk);

  points=[ 17.4603,0 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_3, "1"],[block_tag_10, "1"],points);
  points=[ -17.2159,0; 0, -49.0562 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_1, "1"],[block_tag_3, "1"],points);
  points=[ 0,38.1333 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_6, "1"],[block_tag_1, "1"],points);
  points=[52.1729,0; 0, -69.5925 ]
  [scs_m,obj_num] = add_event_link(scs_m,[block_tag_2, "1"],[block_tag_3, "1"],points);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_10, "1"],[block_tag_6, "1"],points);
  points=[0,-45.2780 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_10, "2"],[block_tag_9, "1"],points);
  points=[ 48.1351,0 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_13, "1"],[block_tag_2, "1"],points);
  points=[51.8019,0; 0,-0.7334 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_15, "1"],[block_tag_3, "2"],points);
  points=[ 50.3352, 0;0, 27.1346 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_17, "1"],[block_tag_3, "3"],points);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_6, "2"],[block_tag_19, "1"],points);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_9, "1"],[block_tag_21, "1"],points);
  scs_m=do_silent_eval(scs_m);
endfunction
