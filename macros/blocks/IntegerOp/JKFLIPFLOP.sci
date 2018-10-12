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
     diagram=jklflipflop_define();
     model.rpar=diagram;
     gr_i=['draw_jkflipflop(orig,sz,o);'];
     x=standard_define([2 3],model,[],gr_i,'JKFLIPFLOP');
  end
endfunction

function scs_m=jklflipflop_define()
  scs_m = instantiate_diagram ();

  blk = DOLLAR_m('define');
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
  blk = EDGE_TRIGGER('define');
  exprs=  [ "0" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 1);
  blk = set_block_evtnout (blk, 1);
  blk = set_block_origin (blk, [   292.5245,323.5489 ]);
  blk = set_block_size (blk, [   60,40 ]);
  [scs_m, block_tag_2] = add_block(scs_m, blk);
  blk = LOGIC('define');
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
  blk = SPLIT_f('define');
  blk = set_block_nin (blk, 1);
  blk = set_block_nout (blk, 2);
  blk = set_block_origin (blk, [   368.8279,243.4507 ]);
  blk = set_block_size (blk, [   0.3333,0.3333 ]);
  [scs_m, block_tag_6] = add_block(scs_m, blk);
  blk = LOGICAL_OP('define');
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

  blk = SPLIT_f('define');
  blk = set_block_nin (blk, 1);
  blk = set_block_nout (blk, 2);
  blk = set_block_origin (blk, [   368.8279;223.0647 ]);
  blk = set_block_size (blk, [   0.3333,0.3333 ]);
  [scs_m, block_tag_10] = add_block(scs_m, blk);
  blk = IN_f('define');
  exprs=  [ "2";  "-1"; "-1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nout (blk, 1);
  blk = set_block_origin (blk, [   205.8180,333.5489 ]);
  blk = set_block_size (blk, [   20,20 ]);
  [scs_m, block_tag_13] = add_block(scs_m, blk);
  blk = IN_f('define');
  exprs= [ "1";"-1";  "-1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nout (blk, 1);
  blk = set_block_origin (blk, [   212.4228,213.2612 ]);
  blk = set_block_size (blk, [   20,20 ]);
  [scs_m, block_tag_15] = add_block(scs_m, blk);
  blk = IN_f('define');
  exprs= [ "3";  "-1";  "-1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nout (blk, 1);
  blk = set_block_origin (blk, [   213.8895,175.3932 ]);
  blk = set_block_size (blk, [   20,20 ]);
  [scs_m, block_tag_17] = add_block(scs_m, blk);
  blk = OUT_f('define');
  exprs=   [ "1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 1);
  blk = set_block_origin (blk, [   388.8279,233.4507 ]);
  blk = set_block_size (blk, [   20,20 ]);
  [scs_m, block_tag_19] = add_block(scs_m, blk);
  blk = OUT_f('define'); 
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
