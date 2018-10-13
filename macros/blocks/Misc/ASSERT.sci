function [x,y,typ]=ASSERT(job,arg1,arg2)
  // Generated from SuperBlock on 25 octobre 2013
  // Modified by hand, Alan, Enpc 2013
  // regenerated 2018, jpc
  // contains a diagram inside
  
  function blk_draw(sz,orig,orient,label)
    orig=arg1.graphics.orig;
    sz=arg1.graphics.sz;
    orient=arg1.graphics.flip;
    
    xrect(orig(1),orig(2)+sz(2),sz(1),sz(2));
    rx=sz(1)*0.65;
    ry=sz(2)*0.3;
    r=0.5
    xarc(orig(1)+0.5*sz(1),
         orig(2)+0.8*sz(2),
         0.3*sz(1),
         0.6*sz(2),
         0,
         360*64,thickness=2);
    xx=[orig(1)+rx orig(1)+rx;
        orig(1)+0.55*sz(1) orig(1)+0.75*sz(1)];
    yy=[orig(2)+ry orig(2)+ry ;
        orig(2)+sz(2)/2 orig(2)+0.6*sz(2)];
    xpoly(xx,yy,thickness=1);
    xpoly([orig(1);orig(1)+sz(1)*0.5],[orig(2)+sz(2)/2;orig(2)+sz(2)/2],thickness=1)
  endfunction
  
  x=[];y=[];typ=[];
  select job
    case 'plot' then
      standard_draw(arg1,%f);
    case 'getinputs' then
      [x,y,typ]=standard_inputs(arg1)
    case 'getoutputs' then
      x=[];y=[];typ=[]
    case 'getorigin' then
      [x,y]=standard_origin(arg1)
    case 'set' then
      y=acquire('needcompile',def=0);
      typ=list()
      graphics=arg1.graphics;
      exprs=graphics.exprs
      Btitre="Set Assertion block parameters"
      Exprs0=["opar";"ipar";"zc"]
      Bitems=["Callback expression when assertion fails(if any)";
              "Behavior when assertion fails(0:print message, 1: stop, 2: end, 3: block error)";
              "Use zero crossing(0:no, 1:yes)" ]
      ss=list("str",1,"mat",1,"mat",1)
      scicos_context=hash(10)
      x=arg1
      ok=%f
      while ~ok do
	[ok,scicos_context.opar,scicos_context.ipar,scicos_context.zc,exprs]=getvalue(Btitre,Bitems,ss,exprs)
	scicos_context.ip2=1
	if scicos_context.opar.equal[emptystr()] || isempty(scicos_context.opar) then
	  scicos_context.opar=[]
	else
	  scicos_context.opar=int8([ascii(scicos_context.opar),0])
	end
	if ~ok then return;end
	%scicos_context=scicos_context
	sblock=x.model.rpar
	[%scicos_context,ierr]=script2var(sblock.props.context,%scicos_context)
	if ierr<>0 then
	  message(catenate(lasterror()));
	  ok=%f
	else
	  [sblock,%w,needcompile2,ok]=do_eval(sblock,list(),%scicos_context);
	  if ok then
            y=max(2,y,needcompile2)
            x.graphics.exprs=exprs
            x.model.rpar=sblock
            break
	  else
            message(catenate(lasterror()));
	  end
	end
      end
    case 'define' then
      x_0=scicos_model();
      x_0.in2=     [   -2 ]
      x_0.evtout= []
      x_0.evtin= []
      x_0.intyp=     [   -1 ]
      x_0.sim=     [ "csuper" ]
      x_0.in=     [   -1 ]
      x_0.out2= []
      x_0.out= []
      x_0.blocktype=     [ "h" ]
      x_0.ipar=     [   1 ]
      model=x_0;clear('x_0');
      model.rpar= assert_define();
      zc=0
      opar=emptystr()
      ipar=2
      ip2=1
      exprs=[opar;sci2exp(ipar,0);sci2exp(zc,0)]
      gr_i="blk_draw(sz,orig,orient,model.label)";
      x=standard_define([2,1],model,exprs,gr_i,'ASSERT')

    case 'upgrade' then
      x=arg1;
  end
endfunction

function scs_m=assert_define () 
  scs_m = instantiate_diagram ();

  blk = IN_f('define');
  exprs=  [ "1"; "-1"; "-1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nout (blk, 1);
  blk = set_block_origin (blk, [   151.4286,380.0000 ]);
  blk = set_block_size (blk, [   20,20 ]);
  [scs_m, block_tag_1] = add_block(scs_m, blk);

  blk = ABS_VALUEi('define');
  exprs= [ "zc" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 1);
  blk = set_block_nout (blk, 1);
  blk = set_block_origin (blk, [   230,340 ]);
  blk = set_block_size (blk, [   40,40 ]);
  [scs_m, block_tag_2] = add_block(scs_m, blk);

  blk = generic_block3('define');
  exprs= ...
  [ "assertion";
    "4";
    "mat_create(0,2)";
    "1";
    "mat_create(0,2)";
    "1";
    "1";
    "mat_create(0,0)";
    "mat_create(0,0)";
    "mat_create(0,0)";
    "list()";
    "mat_create(0,0)";
    "[ipar ip2]";
    "list(opar)";
    "0";
    "0";
    "mat_create(0,0)";
    "n";
    "n" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 0);
  blk = set_block_nout (blk, 0);
  blk = set_block_evtnin (blk, 1);
  blk = set_block_origin (blk, [   370,250 ]);
  blk = set_block_size (blk, [   40,40 ]);
  [scs_m, block_tag_4] = add_block(scs_m, blk);

  blk = IFTHEL_f('define');
  exprs=[ "0"; "zc" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 1);
  blk = set_block_evtnin (blk, 0);
  blk = set_block_evtnout (blk, 2);
  blk = set_block_origin (blk, [   330,330 ]);
  blk = set_block_size (blk, [   60,60 ]);
  [scs_m, block_tag_5] = add_block(scs_m, blk);

  points=[    30,     0;      0,   -30 ]
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_1, "1"],[block_tag_2, "1"],points);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_2, "1"],[block_tag_5, "1"],points);
  points=[          0,   -14.2857;     20.0000,          0 ]
  [scs_m,obj_num] = add_event_link(scs_m,[block_tag_5, "2"],[block_tag_4, "1"],points);

  scs_m=do_silent_eval(scs_m);

endfunction
