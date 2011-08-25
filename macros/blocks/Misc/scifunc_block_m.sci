function [x,y,typ]=scifunc_block_m(job,arg1,arg2)
//%Description
// job=='plot' :      block drawing
//                    arg1 is block data structure
//                    arg2 :unused
// job=='getinputs' : return position and type of inputs ports
//                    arg1 is block data structure
//                    x  : x coordinates of ports
//                    x  : y coordinates of ports
//                    typ: type of ports
// job=='getoutputs' : return position and type of outputs ports
//                    arg1 is block data structure
//                    x  : x coordinates of ports
//                    x  : y coordinates of ports
//                    typ: type of ports
// job=='getorigin'  : return block origin coordinates
//                    x  : x coordinates of block origin
//                    x  : y coordinates of block origin
// job=='set'        : block parameters acquisition 
//                    arg1 is block data structure
//                    x is returned block data structure
// job=='define'     : corresponding block data structure initialisation
//                    arg1: name of block parameters acquisition macro
//                    x   : block data structure
//%Block data-structure definition
// bl=list('Block',graphics,model,init,'standard_block')
//  graphics=list([xo,yo],[l,h],orient,label)
//          xo          - x coordinate of block origin
//          yo          - y coordinate of block origin
//          l           - block width
//          h           - block height
//          orient      - boolean, specifies if block is tilded
//          label       - string block label
//  model=list(eqns,#input,#output,#clk_input,#clk_output,state,..
//             rpar,ipar,typ [,firing])
//          eqns        - function name (in string form if fortran routine)
//          #input      - vector of input port sizes
//          #output     - vector of ouput port sizes
//          #clk_input  - vector  of clock inputs port sizes
//          #clk_output - vector  of clock output port sizes
//          state       - vector (column) of initial condition
//          rpar        - vector (column) of real parameters
//          ipar        - vector (column) of integer parameters
//          typ         - string: 'c' if block is continuous, 'd' if discrete
//                        'z' if zero-crossing.
//          firing      - vector of initial ouput event firing times
//
// Copyright INRIA
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
    needcompile=0
    x=arg1
    model=arg1.model;graphics=arg1.graphics;
    exprs=graphics.exprs
    gv_title=['Set scifunc_block parameters';'only regular blocks supported'];
    gv_titles=['Input ports sizes';
	       'Output port sizes';
	       'Input event ports sizes';
	       'Output events ports sizes';
	       'Initial continuous state';
	       'Initial discrete state';
	       'System parameters vector';
	       'Initial firing vector (<0 for no firing)';
	       'Is block always active (0:no, 1:yes)'];
    gv_types=list('mat',[-1 2],'mat',[-2 2],'vec',-1,...
		  'vec',-1,'vec',-1,'vec',-1,'vec',-1,'vec',-1,'vec',1);
    
    while %t do
      [ok,i,o,ci,co,xx,z,rpar,auto0,deptime,lab]=getvalue(gv_title, ...
						  gv_titles,gv_types,exprs(1));
      if ~ok then break,end
      exprs(1)=lab
      xx=xx(:)
      z=z(:)
      rpar=rpar(:)
      it=ones(1,size(i,1))
      ot=ones(1,size(o,1))
      nrp=prod(size(rpar))
      // create simulator
      //i=int(i(:));
      ni=size(i,1);
      //o=int(o(:));
      no=size(o,1);
      ci=int(ci(:));nci=size(ci,1);
      co=int(co(:));nco=size(co,1);
      [ok,tt,dep_ut]=genfunc2(exprs(2),i,o,nci,nco,size(xx,1),size(z,1),..
			      nrp,'c')
      dep_ut(2)=(1==deptime)
      if ~ok then break,end
      //[model,graphics,ok]=check_io(model,graphics,i,o,ci,co)
      [model,graphics,ok]=set_io(model,graphics,list(i,it),list(o,ot),ci,co)
      if ok then
	auto=auto0
	model.state=xx
	model.dstate=z
	model.rpar=rpar
	if ~model.ipar.equal[tt] then needcompile=4,end
	model.ipar=tt
	model.firing=auto
	model.dep_ut=dep_ut
	x.model=model
	exprs(2)=tt
	graphics.exprs=exprs
	x.graphics=graphics
	break
      end
    end
    resume(needcompile)
   case 'define' then
    in=1
    out=1
    clkin=[]
    clkout=[]
    x0=[]
    z0=[]
    typ='c'
    auto=[]
    rpar=[]
    it=1
    model=scicos_model()
    model.sim=list('scifunc',3)
    model.in=in
    model.in2=in
    model.intyp=it
    model.out=out
    model.out2=out
    model.outtyp=it
    model.evtin=clkin
    model.evtout=clkout
    model.state=x0
    model.dstate=z0
    model.rpar=rpar
    model.ipar=0
    model.blocktype=typ
    model.firing=auto
    model.dep_ut=[%t %f]
    
    exprs=list([sci2exp([in in]);sci2exp([out out]);sci2exp(clkin);sci2exp(clkout);
		strcat(sci2exp(x0));strcat(sci2exp(z0));
		strcat(sci2exp(rpar));sci2exp(auto);sci2exp(0)],..
	       list('y1=sin(u1)',' ',' ','y1=sin(u1)',' ',' ',' '))
    gr_i=['xstringb(orig(1),orig(2),''Scifunc'',sz(1),sz(2),''fill'');']
    x=standard_define([2 2],model,exprs,gr_i,'scifunc_block_m');
  end
endfunction

function [ok,tt,dep_ut]=genfunc2(tt,inp,out,nci,nco,nx,nz,nrp,type_)
// manages dialog to get  definition (with scilab instruction) of a new scicos
// block
//!
// Copyright INRIA
  ni=size(inp,1)
  no=size(out,1)
  mac    = []
  ok     = %f
  dep_ut = []
  dep_u  = %f
  dep_t  = %f
  depp   = 't'
  deqq   = 't'

  if size(tt)<>7 then
    [txt1,txt0,txt2,txt3,txt4,txt5,txt6]=(' ',' ',' ',' ',' ',' ',' ')
  else
    [txt1,txt0,txt2,txt3,txt4,txt5,txt6]=tt(1:7)
  end
  u=catenate('u'+string(1:ni),sep=',')+',';
  dep=['t,','x,','z,',u,'n_evi,','rpar']

  if nx==0 then dep(2)=emptystr(),end
  if nz==0 then dep(3)=emptystr(),end
  //if nci==0 then dep(5)=emptystr(),end
  if nrp==0 then dep(6)=emptystr(),end
  //###### flag = 1 ######//
  if no>0 then
    depp=strcat(dep([1:5,6]))
    head=['Define function which computes the output of the block,';
	  'i.e. enter Scilab instructions defining:'];
    for k=1:no
      head.concatd['y'+string(k)+' (size: '+sci2exp(out(k,:))+')'];
    end
    head.concatd['as a function(s) of '+depp];
    
    ptxtedit=scicos_txtedit(clos = 0,...
			    typ  = "Scifunc-1",...
			    head = head)
    textmp=txt1
    while %t do
      [txt,Quit] = scstxtedit(textmp,ptxtedit)
      if ptxtedit.clos==1 then
	break
      end
      if ~isempty(txt) then
	txt1=txt
	// check if txt defines y from u
	ok1=execstr(['function []=mac()';txt;'endfunction'],errcatch=%t);
	if ok1 then
	  vars=macrovar(mac)
	  // vars(3): variables not local and no functions;
	  // vars(5): locals;
	  ucheck =vars.all.iskey[ 'u'+string(1:ni)];
	  if or(ucheck) then dep_u=%t;end
	  if vars.all.iskey['t'] then dep_t=%t; end
	  // check yi dependency 
	  w= vars.all.iskey[ 'y'+string(1:no)];
	  if ~and(w) then
	    k1=find(~w)
	    w=m2s([])
	    for k=1:size(k1,'*')
	      w=[w;'y'+string(k1(k))+' (size: '+sci2exp(out(k1(k),:))+')']
	    end
	    message('Error: You did not define '+strcat(w,',')+' !')
	  else
	    ptxtedit.clos=1
	  end
	end
	textmp=txt1
      end
      if Quit then
	// Quit means cancel in scstxtedit
	return
      end
    end
  else
    txt1=' '
  end
  //###### flag - 0 ######//
  if nx > 0 then
    depp=strcat(dep([1:4,6]))
    head=['Define continuous states evolution'
	  ''
	  'Enter Scilab instructions defining:'
	  'derivative of continuous state xd (size:'+string(nx)+')'
	  'as  function(s) of '+depp]

    ptxtedit=scicos_txtedit(clos = 0,...
			    typ  = "Scifunc-0",...
			    head = head)
    if isempty(txt0) then txt0=' '; end
    textmp=txt0
    while %t do
      [txt,Quit] = scstxtedit(textmp,ptxtedit)
      if ptxtedit.clos==1 then
	break
      end
      if ~isempty(txt) then
	txt0=txt
	ok1=execstr(['function []=mac()';txt;'endfunction'],errcatch=%t);
	if ok1 then
	  vars=macrovar(mac)
	  if vars.lhs.iskey['xd'] then
	    ptxtedit.clos=1;
	  else
	    message('You did not define xd !')
	  end
	end
      else
	txt0=' '
      end
      textmp=txt0
      if Quit then
	return
      end
    end
  else
    txt0='xd=[]'
  end
  //###### flag - 2 ######//
  if (nci>0 & (nx>0|nz>0)) | nz>0 then
    depp=strcat(dep([1:5,6]))
    head=['Define states evolution on discrete events'
	  ''
	  'You may define:']
    if nx>0 then
      head.concatd[ '-new continuous state x (size:'+string(nx)+')'];
    end
    if nz>0 then
      head.concatd[ '-new discrete state z (size:'+string(nz)+')']
    end
    head.concatd[ 'at event time, as functions of '+depp]
    ptxtedit=scicos_txtedit(clos = 0,...
			    typ  = "Scifunc-2",...
			    head = head)
    if isempty(txt2) then txt2=' ';end 
    textmp=txt2
    while %t do
      [txt,Quit] = scstxtedit(textmp,ptxtedit)
      if ptxtedit.clos==1 then
	break
      end
      if ~isempty(txt) then
	txt2=txt
	ok1=execstr(['function []=mac()';txt;'endfunction'],errcatch=%t);
	if ok1 then
	  vars=macrovar(mac)
	  if ~vars.lhs.iskey['x'] && nx > 0 then
	    txt2=[txt2;
		  'x=[]']
	  end
	  if ~vars.lhs.iskey['z'] && nz > 0 then
	    txt2=[txt2;
		  'z=[]']
	  end
	  ptxtedit.clos=1
	end
      else
	txt2=' '
      end
      textmp=txt2
      if Quit then;return;end 
    end
  else
    txt2=' '
  end
  //###### flag - 3 ######//
  if nci>0 & nco>0 then
    depp=strcat(dep)
    head=['Define output time events on discrete events'
	  ''
	  'Using '+depp+',you may set '
	  'vector of output time events t_evo (size:'+string(nco)+')'
	  'at event time. ']
    ptxtedit=scicos_txtedit(clos = 0,...
			    typ  = "Scifunc-3",...
			    head = head)
    if isempty(txt3) then      txt3=' '; end
    textmp=txt3
    while %t do
      [txt,Quit] = scstxtedit(textmp,ptxtedit)
      if ptxtedit.clos==1 then
	break
      end
      if ~isempty(txt) then
	txt3=txt
	ok1=execstr(['function []=mac()';txt;'endfunction'],errcatch=%t);
	if ok1 then
	  vars=macrovar(mac)
	  if ~vars.lhs.iskey['t_evo'] then
	    txt3=[txt3;
		  't_evo=[]']
	  end
	  ptxtedit.clos=1
	end
      else
	txt3=' '
      end
      textmp=txt3
      if Quit then;return;end ;
    end
  else
    txt3=' '
  end
  //###### flag - 4 ######//
  depp=strcat(dep([2 3 6]))
  head=['You may do whatever needed for initialization :'
	'File or graphic opening...,']
  t1=m2s([])
  if nx>0 then
    t1.concatd['- continuous state x (size:'+string(nx)+')'];
  end
  if nz>0 then
    t1.concatd['- discrete state z (size:'+string(nz)+')'];
  end
  if ~isempty(t1) then
    head.concatd[['You may also re-initialize:';t1]];
  end
  if depp<>'' then
    head.concatd[ 'as function(s) of '+depp]
  end
  ptxtedit=scicos_txtedit(clos = 0,...
			  typ  = "Scifunc-4",...
			  head = head)
  if isempty(txt4) then txt4=' '; end
  textmp=txt4
  while %t do
    [txt,Quit] = scstxtedit(textmp,ptxtedit);
    if ptxtedit.clos==1 then
      break
    end
    if ~isempty(txt) then
      txt4=txt;
      ok1=execstr(['function []=mac()';txt;'endfunction'],errcatch=%t);
      if ok1 then
	ptxtedit.clos=1
      end
    else
      txt4=' '
    end
    textmp=txt4
    if Quit then;return;end 
  end
  //###### flag - 5 ######//
  depp=strcat(dep([2 3 6]))
  head=['You may do whatever needed to finish :'
	'File or graphic closing...,']
  t1=m2s([]);
  if nx>0 then
    t1.concatd['- continuous state x (size:'+string(nx)+')']
  end
  if nz>0 then
    t1.concatd['- discrete state z (size:'+string(nz)+')'];
  end
  if ~isempty(t1) then
    head.concatd[['You may also change final value of:';t1]];
  end
  if depp<>'' then
    head.concatd[ 'as function(s) of '+depp];
  end
  ptxtedit=scicos_txtedit(clos = 0,...
			  typ  = "Scifunc-5",...
			  head = head)

  if isempty(txt5) then txt5=' ';end 
  textmp=txt5
  while %t do
    [txt,Quit] = scstxtedit(textmp,ptxtedit)
    if ptxtedit.clos==1 then
      break
    end
    if ~isempty(txt) then
      txt5=txt
      ok1=execstr(['function []=mac()';txt;'endfunction'],errcatch=%t);
      if ok1 then
	ptxtedit.clos=1
      end
    else
      txt5=' '
    end
    textmp=txt5
    if Quit then;return;end 
  end
  //###### flag - 6 ######//
  if nx>0 | nz>0 | no>0 then
    depp=strcat(dep([2:4,6]))
    head=['You may define here functions imposing contraints'
	  'on initial inputs, states and outputs.'
	  'Note: these functions may be called more than once.']
    t1=m2s([])
    if nx>0 then
      t1.concatd['- state x (size:'+string(nx)+')']
    end
    if nz>0 then
      t1.concatd['- state z (size:'+string(nz)+')']
    end
    for k=1:no
      t1.concatd['- output y'+string(k)+' (size : '+sci2exp(out(k,:))+')']
    end
    if ~isempty(t1) then
      head.concatd[['Enter Scilab instructions defining:';t1]];
    end
    if depp<>'' then
      head.concatd['as a function of '+depp];
    end

    if isempty(txt6) then txt6=' ',end
    ptxtedit=scicos_txtedit(clos = 0,...
			    typ  = "Scifunc-6",...
			    head = head)
    textmp=txt6
    while %t do
      [txt,Quit] = scstxtedit(textmp,ptxtedit)
      if ptxtedit.clos==1 then
	break
      end
      if ~isempty(txt) then
	txt6=txt;
	ok1=execstr(['function []=mac()';txt;'endfunction'],errcatch=%t);
	if ok1 then
	  vars=macrovar(mac)
	  ycheck = vars.lhs.iskey['y'+string(1:no)];
	  yy=(1:no)'; yy=yy(~ycheck);
	  txt6=[txt6;'y'+string(yy)+'=[]']
	  ptxtedit.clos=1
	end
      else
	txt6=' '
      end
      textmp=txt6
      if Quit then;return;end 
    end
  else
    txt6=' '
  end
  ok=%t
  tt=list(txt1,txt0,txt2,txt3,txt4,txt5,txt6)
  dep_ut=[dep_u dep_t]
endfunction
