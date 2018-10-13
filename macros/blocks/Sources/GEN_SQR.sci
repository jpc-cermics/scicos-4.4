function [x,y,typ]=GEN_SQR(job,arg1,arg2)
  //Generated from SuperBlock on 8-Feb-2008
  // contains a diagram inside
  
  x=[];y=[];typ=[];
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
      arg1.model.ipar=1;
      typ=list()
      graphics=arg1.graphics;
      exprs=graphics.exprs
      Btitre= "Set GEN_SQR parameters";
      Exprs0=["Amin";"Amax";"rule";"F"]
      Bitems=["Minimum Value";
	      "Maximum Value";
	      "Initial Value( 1= Minimum Value 2= Maximum Value)";
	      "Period (sec)"];
      Ss= list("mat",[-1,-1],"mat",[-1,-1],"pol",-1,"pol",-1)
      context=hash(10)
      x=arg1
      ok=%f
      while ~ok do
	[ok,context.Amin,context.Amax,context.rule,context.F,exprs]=getvalue(Btitre,Bitems,Ss,exprs)
	if ~ok then return;end
	sblock=x.model.rpar
	[new_context,ierr]=script2var(sblock.props.context,context)
	if ierr==0 then
	  [sblock,%w,needcompile2,ok]=do_eval(sblock,list(),context)
	  if ok then
            y=max(2,y,needcompile2)
            x.graphics.exprs=exprs
            x.model.rpar=sblock
            break
	  end
	else
	  message(lasterror())
	  ok=%f
	end
      end
      resume(needcompile=y);
    case 'define' then
      scs_m=GEN_SQR_define()
      model=scicos_model(sim="csuper", in=[],in2=[],intyp=1,out=-1,out2=-2,outtyp=-1,
			 evtin=[],evtout=[],state=[],dstate=[],odstate=list(),
			 rpar=scs_m,ipar=1,opar=list(),blocktype="h",firing=[],
			 dep_ut=[%f,%f],label="",nzcross=0,nmode=0,equations=list());
      // [Amin; Amax; rule; F];
      exprs=[ "-1"; "1"; "1"; "1"]
      gr_i=list(["xx=[1 2 2 3 3 4 4 5 5 6]/7;";
		 "yy=[1 1 3 3 1 1 3 3 1 1]/4;";
		 "x=orig(1)*ones(1,10)+sz(1)*xx;";
		 "y=orig(2)*ones(1,10)+sz(2)*yy;";
		 "xpolys(x'',y'');"],8)
      x=standard_define([3,2],model,exprs,gr_i,'GEN_SQR');
    case 'upgrade' then
      x=arg1;
  end
endfunction

function scs_m=GEN_SQR_define()
  scs_m = instantiate_diagram ();
  context= ...
  [ "if type(Amin,''short'')<>type(Amax,''short'') then ";
    "   error(''Minimum value and Maximum value must have the same type'');";
    "end";
    "if and(rule<>[1;2]) then error(''Initial Value must be 1 (for Min) or 2 (for Max)'');end";
    "if Amin>Amax then error(''Maximum value must be greater than the Minimum Value'');end";
    "P=%pi./F";
    "" ];
  scs_m.props.context= context;
  // scs_m = set_model_workspace(scs_m,context);
  blk = Counter('define')
  exprs= [ "1"; "2"; "rule" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nout (blk, 1);
  blk = set_block_evtnin (blk, 1);
  blk = set_block_origin (blk, [    18.2299,339.5057 ]);
  blk = set_block_size (blk, [   60,40 ]);
  [scs_m, block_tag_1] = add_block(scs_m, blk);
  blk = CONST_m('define')
  exprs= [ "Amin" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nout (blk, 1);
  blk = set_block_origin (blk, [    38.0961,293.8220 ]);
  blk = set_block_size (blk, [   40,40 ]);
  blk.model.sim= list("cstblk4_m",4);
  [scs_m, block_tag_2] = add_block(scs_m, blk);
  blk = CONST_m('define')
  exprs= [ "Amax" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nout (blk, 1);
  blk = set_block_origin (blk, [    37.3789,245.0239 ]);
  blk = set_block_size (blk, [   40,40 ]);
  blk.model.sim= list("cstblk4_m",4);
  [scs_m, block_tag_3] = add_block(scs_m, blk);
  blk = SELECT_m('define')
  exprs= [ "-1"; "2"; "1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 2);
  blk = set_block_nout (blk, 1);
  blk = set_block_evtnin (blk, 2);
  blk = set_block_origin (blk, [   116.2695,269.4229 ]);
  blk = set_block_size (blk, [   40,40 ]);
  [scs_m, block_tag_4] = add_block(scs_m, blk);
  blk = ESELECT_f('define')
  exprs= [ "2"; "0"; "0" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 1);
  blk = set_block_evtnin (blk, 0);
  blk = set_block_evtnout (blk, 2);
  blk = set_block_origin (blk, [   106.9461,339.7496 ]);
  blk = set_block_size (blk, [   60,40 ]);
  [scs_m, block_tag_7] = add_block(scs_m, blk);
  blk = OUT_f('define')
  exprs= [ "1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_bg_color (blk, 8);
  blk = set_block_nin (blk, 1);
  blk = set_block_origin (blk, [   184.4024,278.7520 ]);
  blk = set_block_size (blk, [   20,20 ]);
  [scs_m, block_tag_11] = add_block(scs_m, blk);
  blk = SampleCLK('define')
  exprs= [ "F/2"; "0" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_bg_color (blk, 8);
  blk = set_block_evtnout (blk, 1);
  blk = set_block_origin (blk, [    18.3137,403.5743 ]);
  blk = set_block_size (blk, [   60,40 ]);
  [scs_m, block_tag_13] = add_block(scs_m, blk);
  points=[   21.0306,0 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_2, "1"],[block_tag_4, "1"],points);
  points=[   21.7478,0 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_3, "1"],[block_tag_4, "2"],points);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_1, "1"],[block_tag_7, "1"],points);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_event_link(scs_m,[block_tag_7, "1"],[block_tag_4, "1"],points);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_event_link(scs_m,[block_tag_7, "2"],[block_tag_4, "2"],points);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_4, "1"],[block_tag_11, "1"],points);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_event_link(scs_m,[block_tag_13, "1"],[block_tag_1, "1"],points);
  scs_m=do_silent_eval(scs_m);
endfunction
