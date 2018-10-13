function [x,y,typ]=FROMWSB(job,arg1,arg2)

  function blk_draw(sz,orig,orient,label)  
    xstringb(orig(1),orig(2),"From workspace",sz(1),sz(2),"fill")
    txt=varnam;
    style=5;
    rectstr=stringbox(txt,orig(1),orig(2),0,style,1);
    fz=2*acquire("%zoom",def=1)*4;
    h=(rectstr(2,2)-rectstr(2,4))*fz;
    fnt=xget('font');
    xset('font', options.ID(1)(1), options.ID(1)(2));
    xstring(orig(1)+sz(1)/2, orig(2)-h-4,txt,posx='center',posy='up', size=fz);
    xset('font', fnt(1), fnt(2));
  endfunction
  
  x=[];y=[],typ=[]
  select job
   case 'plot' then
    varnam=string(arg1.model.rpar.objs(1).graphics.exprs(1))
    standard_draw(arg1)
   case 'getinputs' then
    [x,y,typ]=standard_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=standard_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    //paths to updatable parameters or states
    ppath = list(1)
    newpar=list();
    y=acquire('needcompile',def=0);
    for path=ppath do
      np=size(path,'*')
      spath=list()
      for k=1:np
	spath($+1)='model'
	spath($+1)='rpar'
	spath($+1)='objs'
	spath($+1)=path(k)
      end
      xx=arg1(spath)// get the block
      ok=execstr('xxn='+xx.gui+'(''set'',xx)',errcatch=%t);
      if ~ok then 
	message(['Error: failed to set parameter block in FROMWSB';
	         catenate(lasterror())]);
	continue;
      end
      if ~xx.equal[xxn] then 
	[needcompile]=scicos_object_check_needcompile(xx,xxn);
	// parameter or states changed
	arg1(spath)=xxn// Update
	newpar(size(newpar)+1)=path // Notify modification
	y=max(y,needcompile);
      end
    end
    x=arg1
    typ=newpar
   case 'define' then
     scs_m=FROM_WSB_define()
     model=scicos_model(sim="csuper",in=[],in2=[],intyp=1,out=-1,out2=-2,outtyp=1,
			evtin=[],evtout=[],state=[],dstate=[],odstate=list(),
			rpar=scs_m,ipar=[],opar=list(),blocktype="h",firing=[],
			dep_ut=[%f,%f],label="",nzcross=0,nmode=0,equations=list())
    //## modif made by hand
    gr_i="blk_draw(sz,orig,orient,model.label)";	
    x=standard_define([3.5 2],model,[],gr_i,'FROMWSB');
  end
endfunction

function scs_m=FROMWSB_define()
  scs_m = instantiate_diagram ();
  blk = instantiate_block("FROMWS_c");
  exprs= [ "V", "1", "1", "0" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_nin (blk, 0);
  blk = set_block_nout (blk, 1);
  blk = set_block_evtnin (blk, 1);
  blk = set_block_evtnout (blk, 1);
  blk = set_block_origin (blk, [   260.3707,261.5840 ]);
  blk = set_block_size (blk, [   70,40 ]);
  [scs_m, block_tag_1] = add_block(scs_m, blk);
  blk = instantiate_block("OUT_f");
  exprs= [ "1" ]
  blk=set_block_exprs(blk,exprs);
  blk = set_block_bg_color (blk, 8);
  blk = set_block_nin (blk, 1);
  blk = set_block_origin (blk, [   358.9421,271.5840 ]);
  blk = set_block_size (blk, [   20,20 ]);
  [scs_m, block_tag_3] = add_block(scs_m, blk);
  points=[ 0,-32.4190; -62.1333, 0;0,114.4000;62.1333, 0 ]
  [scs_m,obj_num] = add_event_link(scs_m,[block_tag_1, "1"],[block_tag_1, "1"],points);
  points=mat_create(0,0)
  [scs_m,obj_num] = add_explicit_link(scs_m,[block_tag_1, "1"],[block_tag_3, "1"],points);
  scs_m=do_silent_eval(scs_m);
endfunction
