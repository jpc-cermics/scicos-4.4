function [x,y,typ]=SRFLIPFLOP(job,arg1,arg2)
// Copyright INRIA

  function draw_srflipflop(orig,sz,o)
    [x,y,typ]=standard_inputs(o)
    dd=sz(1)/8,de=sz(1)*(1/2+1/8);
    w=sz(1)*(1/2-1/8);
    h=sz(2)/4;
    xstringb(orig(1)+dd,y(1)-4,'S',w,h,'fill');
    xstringb(orig(1)+dd,y(2)-4,'R',w,h,'fill');
    [x,y,typ]=standard_outputs(o) ;
    txt='Q'
    xstringb(orig(1)+de,y(1)-4,'Q',w,h,'fill');
    xstringb(orig(1)+de,y(2)-4,'!Q',w,h,'fill');
    w = sz(1);
    h = sz(2)*(1/4)
    xstringb(orig(1),orig(2)-1.5*h,'SR FLIP-FLOP',w,h,'fill');
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
    newpar=list()
    xx=arg1.model.rpar.objs(2)// get the 1/z block
    exprs=xx.graphics.exprs(1)
    model=xx.model;
    init_old= model.odstate(1)
    while %t do
      [ok,init,exprs0]=getvalue(['Set parameters';'The Initial Value must be 0 or 1 of type int8';..
	                       'Negative values are considered as int8(0)';..
			       'Positive values are considered as int8(1)'] ,..
			   ['Initial Value'],..
			   list('vec',1),exprs)
      if ~ok then break,end
      if i2m(init) <=0 then init=m2i(0,'int8');
      elseif i2m(init) >0 then init=m2i(1,'int8');
      end
      if ok then 
	xx.graphics.exprs(1)=exprs0
	model.odstate(1)=init
	xx.model=model
	arg1.model.rpar.objs(2)=xx// Update
	break
      end
    end
    if ~init_old.equal[init] then 
      // parameter  changed
      newpar(size(newpar)+1)=1;// Notify modification
      y=max(y,2);
    end
    x=arg1
    typ=newpar
   case 'define' then
     scs_m=srflipflop_define()

     model=scicos_model()
     model.sim='csuper'
     model.in=[1;1]
     model.in2=[1;1]
     model.out=[1;1]
     model.out2=[1;1]
     model.intyp=[5 5]
     model.outtyp=[5 5]
     model.blocktype='h'
     model.firing=%f
     model.dep_ut=[%t %f]
     model.rpar=scs_m
     gr_i=['draw_srflipflop(orig,sz,o);'];
     x=standard_define([2 3],model,[],gr_i,'SRFLIPFLOP');
  end
endfunction

function scs_m=srflipflop_define()
  scs_m = instantiate_diagram ();
  blk = LOGIC('define')
  exprs= [ "[0 1;1 0;1 0;1 0;0 1;0 1;0 0;0 0]"; "1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 3);
  blk = set_block_nout (blk, 2);
  blk = set_block_evtnin (blk, 0);
  blk = set_block_evtnout (blk, 0);
  blk = set_block_origin (blk, [   298.5040,201.4507 ]);
  blk = set_block_size (blk, [   40,40 ]);
  blk.model.evtout= mat_create(0,1);
  [scs_m, block_tag_1] = add_block(scs_m, blk);
  
  blk = DOLLAR_m('define')
  exprs=   [ "m2i(0,''int8'')"; "1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 1);
  blk = set_block_nout (blk, 1);
  blk = set_block_evtnin (blk, 0);
  blk = set_block_evtnout (blk, 0);
  blk = set_block_flip (blk, %t);
  blk = set_block_origin (blk, [   299.2373,254.2507 ]);
  blk = set_block_size (blk, [   40,40 ]);
  blk.model.sim= list("dollar4_m",4);
  blk.model.evtout= mat_create(0,1);
  [scs_m, block_tag_2] = add_block(scs_m, blk);

  blk = SPLIT_f('define')
  blk = set_block_nin (blk, 1);
  blk = set_block_nout (blk, 2);
  blk = set_block_origin (blk, [   363.0373,248.5840 ]);
  blk = set_block_size (blk, [   0.3333,0.3333 ]);
  [scs_m, block_tag_5] = add_block(scs_m, blk);

  blk = OUT_f('define')
  exprs= [ "2" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 1);
  blk = set_block_origin (blk, [   367.0754,204.7840 ]);
  blk = set_block_size (blk, [   20,20 ]);
  [scs_m, block_tag_7] = add_block(scs_m, blk);

  blk = IN_f('define')
  exprs= [ "1"; "-1"; "-1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nout (blk, 1);
  blk = set_block_origin (blk, [   249.9326,211.4507 ]);
  blk = set_block_size (blk, [   20,20 ]);
  [scs_m, block_tag_9] = add_block(scs_m, blk);

  blk = IN_f('define')
  exprs= [ "2"; "-1"; "-1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nout (blk, 1);
  blk = set_block_origin (blk, [   249.9326,201.4507 ]);
  blk = set_block_size (blk, [   20,20 ]);
  [scs_m, block_tag_11] = add_block(scs_m, blk);

  blk = OUT_f('define')
  exprs=  [ "1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 1);
  blk = set_block_origin (blk, [   383.0373,238.5840 ]);
  blk = set_block_size (blk, [   20,20 ]);
  [scs_m, block_tag_13] = add_block(scs_m, blk);
  points=[   15.9619,0 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_1, "1"],[block_tag_5, "1"],points);
  points=[   -18.5619,          0;           0,   -42.8000 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_2, "1"],[block_tag_1, "1"],points);
  points=[         0,25.6667 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_5, "1"],[block_tag_2, "1"],points);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_1, "2"],[block_tag_7, "1"],points);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_9, "1"],[block_tag_1, "2"],points);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_11, "1"],[block_tag_1, "3"],points);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_5, "2"],[block_tag_13, "1"],points);

  scs_m=do_silent_eval(scs_m);
endfunction
