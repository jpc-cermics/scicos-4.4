function [x,y,typ]=ENDBLK(job,arg1,arg2)

  function diagram=make_end_block()
    blk= END_c('define');
    blk.graphics.orig=[272.104,249.11733];
    blk.graphics.sz=[40,40];
    blk.graphics.exprs="1.000E+08";
    blk.graphics.pein=2;
    blk.graphics.peout=2;
    
    diagram=scicos_diagram();
    diagram.props.title = "ENDBLK",
    diagram.objs(1)=blk;
    xlink=[292.104;292.104;261.83733;261.83733;292.104;292.104];
    ylink=[243.40305;234.45067;234.45067;305.584;305.584;294.83162];
    diagram.objs(2)=scicos_link(xx=xlink,yy=ylink,
				id="drawlink",
				thick=[0,0],
				ct=[5,-1],
				from=[1,1,0],
				to=[1,1,1]);
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
     diagram=make_end_block();
     model=scicos_model(sim="csuper",
			in=[],
			in2=[],
			intyp=1,
			out=[],
			out2=[],
			outtyp=1,
			evtin=[],
			evtout=[],
			state=[],
			dstate=[],
			odstate=list(),
			rpar=diagram,
			ipar=[],
			opar=list(),
			blocktype="h",
			firing=[],
			dep_ut=[%f,%f],
			label="",
			nzcross=0,
			nmode=0,
			equations=list())
     gr_i='xstringb(orig(1),orig(2),'' END '',sz(1),sz(2),''fill'')';
     x=standard_define([2 2],model,[],gr_i,'ENDBLK');
  end
endfunction

