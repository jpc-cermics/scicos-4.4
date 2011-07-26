function [x,y,typ]=ENDBLK(job,arg1,arg2)
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
    // The set method of ENDBLK will 
    // use the set method of internal blocks
    // we first get the pathes to updatable parameters or states
    ppath = list(1)
    newpar= list();
    y=0;
    for path=ppath do
      // loop on each  updatable parameter 
      // get the path to block 
      np=size(path,'*')
      spath=list()
      for k=1:np
	spath($+1:$+4)=('model','rpar','objs',path(k));
      end
      // get the block for which a set is to be done.
      xx=arg1(spath) 
      // call the set method
      ok=execstr('xxn='+xx.gui+'(''set'',xx)',errcatch=%t);
      if ~ok then 
	message(['Error: failed to set parameter block in ENDBLK';
	         catenate(lasterror())]);
	continue;
      end
      [needcompile]=scicos_object_check_needcompile(xx,xxn);
      // Update even if 
      arg1(spath)=xxn// Update
      newpar(size(newpar)+1)=path// Notify modification
      y=max(y,needcompile)
    end
    x=arg1;
    typ=newpar;
   case 'define' then
    scs_m_1=scicos_diagram(..
			   version="scicos4.2",..
			   props=scicos_params(..
					       wpar=[-159.096,811.104,-121.216,617.984,1323,1008,331,284,630,480,0,7,1.4],..
					       Title="ENDBLK",..
					       tol=[0.0001,0.000001,1.000E-10,100001,0,0],..
					       tf=100000,..
					       context=" ",..
					       void1=[],..
					       options=tlist(["scsopt","3D","Background","Link","ID","Cmap"],list(%t,33),[8,1],[1,5],..
						  list([5,1],[4,1]),[0.8,0.8,0.8]),..
					       void2=[],..
					       void3=[],..
					       doc=list()))
    scs_m_1.objs(1)=scicos_block(..
				 gui="END_c",..
				 graphics=scicos_graphics(..
						  orig=[272.104,249.11733],..
						  sz=[40,40],..
						  flip=%t,..
						  theta=0,..
						  exprs="1.000E+08",..
						  pin=[],..
						  pout=[],..
						  pein=2,..
						  peout=2,..
						  gr_i=list("xstringb(orig(1),orig(2),'' END '',sz(1),sz(2),''fill'');",8),..
						  id="",..
						  in_implicit=[],..
						  out_implicit=[]),..
				 model=scicos_model(..
						    sim=list("scicosexit",4),..
						    in=[],..
						    in2=[],..
						    intyp=1,..
						    out=[],..
						    out2=[],..
						    outtyp=1,..
						    evtin=1,..
						    evtout=1,..
						    state=[],..
						    dstate=[],..
						    odstate=list(),..
						    rpar=[],..
						    ipar=[],..
						    opar=list(),..
						    blocktype="d",..
						    firing=1.000E+08,..
						    dep_ut=[%f,%f],..
						    label="",..
						    nzcross=0,..
						    nmode=0,..
						    equations=list()),..
				 doc=list())
    scs_m_1.objs(2)=scicos_link(..
				xx=[292.104;292.104;261.83733;261.83733;292.104;292.104],..
				yy=[243.40305;234.45067;234.45067;305.584;305.584;294.83162],..
				id="drawlink",..
				thick=[0,0],..
				ct=[5,-1],..
				from=[1,1,0],..
				to=[1,1,1])
    model=scicos_model(..
		       sim="csuper",..
		       in=[],..
		       in2=[],..
		       intyp=1,..
		       out=[],..
		       out2=[],..
		       outtyp=1,..
		       evtin=[],..
		       evtout=[],..
		       state=[],..
		       dstate=[],..
		       odstate=list(),..
		       rpar=scs_m_1,..
		       ipar=[],..
		       opar=list(),..
		       blocktype="h",..
		       firing=[],..
		       dep_ut=[%f,%f],..
		       label="",..
		       nzcross=0,..
		       nmode=0,..
		       equations=list())
    gr_i='xstringb(orig(1),orig(2),'' END '',sz(1),sz(2),''fill'')';
    x=standard_define([2 2],model,[],gr_i,'ENDBLK');
  end
endfunction

