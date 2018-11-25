function [x,y,typ]=JKFLIPFLOP(job,arg1,arg2)
  // Copyright INRIA
  // contains a diagram inside  
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
     // be sure that exprs is now in block
     [x,changed]=JKFLIPFLOP('upgrade',arg1);
     if changed then y = max(y,2);end
     exprs=x.graphics.exprs;
     // paths to updatable parameters or states
     newpar=list()
     blk=arg1.model.rpar.objs(1); // get the 1/z block
     blk_new=blk;
     while %t do
       [ok,init,exprs0]=getvalue(['Set parameters';'The Initial Value must be 0 or 1 of type int8';
				  'Negatif values are considered as int8(0)';
				  'Positif values are considered as int8(1)'],
				 ['Initial Value'],
				 list('vec',1),exprs);
       if ~ok then break,end
       if type(init,'short')=='m' then init=m2i(m,'int8');end
       if i2m(init) <=0 then init=m2i(0,'int8');
       elseif i2m(init) >0 then init=m2i(1,'int8');
       end
       blk_new.graphics.exprs(1)=exprs0;
       blk_new.model.odstate(1)=init;
       break
     end
     if ~blk.equal[blk_new] then 
       // parameter  changed
       x.model.rpar.objs(1)=blk_new;// update the block
       x.graphics.exprs = exprs0; 
       newpar(1)=1;// Notify modification
       y=max(y,2);
     end
     typ=newpar
     resume(needcompile=y);// propagate needcompile
     
   case 'define' then
     scs_m = jklflipflop_define();
     model= scicos_model(sim='csuper', in=[1;1;1], in2=[1;1;1], out=[1;1], out2=[1;1],
			 intyp=[5 1 5],outtyp=[5 5], blocktype='h', firing=%f,
			 dep_ut=[%t %f], ipar=1, rpar= scs_m);
     gr_i=['draw_jkflipflop(orig,sz,o);'];
     x=standard_define([2 3],model,[],gr_i,'JKFLIPFLOP');
     x.graphics.exprs = x.model.rpar.objs(1).graphics.exprs(1);
     
   case 'upgrade' then
     // upgrade if necessary
     if ~arg1.graphics.iskey['exprs'] || isempty(arg1.graphics.exprs) then
       // arg1 do not have a correct exprs field
       exprs =  arg1.model.rpar.objs(1).graphics.exprs;
       x1 = JKFLIPFLOP('define');
       x=arg1;
       x.model.rpar= x1.model.rpar;
       x.graphics.exprs = exprs(1);
       x.model.rpar.objs(1).graphics.exprs = exprs;
       y=%t;
     else
       x=arg1;
       y=%f;
     end
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
