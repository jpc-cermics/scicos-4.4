function [x,y,typ]=Sigbuilder(job,arg1,arg2)
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
    //paths to updatable parameters or states
    ppath = list(1,3)
    newpar=list();
    y=0;
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
	message(['Error: failed to set parameter block in Sigbuilder';
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
    scs_m_1=scicos_diagram(..
			   version="scicos4.2",..
			   props=scicos_params(..
					       wpar=[600,450,0,0,600,450],..
					       Title=["Sigbuilder","./"],..
					       tol=[0.0001;0.000001;1.000D-10;100001;0;0;0],..
					       tf=100,..
					       context=" ",..
					       void1=[],..
					       options=scicos_options(),..
					       void2=[],..
					       void3=[],..
					       doc=list()))
    scs_m_1.objs(1)=scicos_block(..
				 gui="CURVE_c",..
				 graphics=scicos_graphics(..
						  orig=[329.63473,606.18517],..
						  sz=[40,40],..
						  flip=%t,..
						  theta=0,..
						  exprs=["3";"[0,1,2]";"[10,20,-30]";"y";"n"],..
						  pin=[],..
						  pout=6,..
						  pein=4,..
						  peout=2,..
						  gr_i=list(..
						  ["rpar=arg1.model.rpar;n=model.ipar(1);order=model.ipar(2);";
		    "xx=rpar(1:n);yy=rpar(n+1:2*n);";
		    "[XX,YY,rpardummy]=Do_Spline(n,order,xx,yy)";
		    "xmx=max(XX);xmn=min(XX);";
		    "ymx=max(YY);ymn=min(YY);";
		    "dx=xmx-xmn;if dx==0 then dx=max(xmx/2,1);end";
		    "xmn=xmn-dx/20;xmx=xmx+dx/20;";
		    "dy=ymx-ymn;if dy==0 then dy=max(ymx/2,1);end;";
		    "ymn=ymn-dy/20;ymx=ymx+dy/20;";
		    "xx2=orig(1)+sz(1)*((XX-xmn)/(xmx-xmn));";
		    "yy2=orig(2)+sz(2)*((YY-ymn)/(ymx-ymn));";
		    "xset(''color'',2)";
		    "xpoly(xx2,yy2,type=''lines'');"],8),..
						  id="",..
						  in_implicit=[],..
						  out_implicit="E"),..
				 model=scicos_model(..
						    sim=list("curve_c",4),..
						    in=[],..
						    in2=[],..
						    intyp=1,..
						    out=1,..
						    out2=[],..
						    outtyp=1,..
						    evtin=1,..
						    evtout=1,..
						    state=[],..
						    dstate=[],..
						    odstate=list(),..
						    rpar=[0;1;2;10;20;-30],..
						    ipar=[3;3;1],..
						    opar=list(),..
						    blocktype="c",..
						    firing=0,..
						    dep_ut=[%f,%t],..
						    label="",..
						    nzcross=0,..
						    nmode=0,..
						    equations=list()),..
				 doc=list())
    scs_m_1.objs(2)=scicos_link(..
				xx=[349.63473;349.49528],..
				yy=[600.47089;565.10704],..
				id="drawlink",..
				thick=[0,0],..
				ct=[5,-1],..
				from=[1,1,0],..
				to=[3,1,1])
    scs_m_1.objs(3)=scicos_block(..
				 gui="CLKSPLIT_f",..
				 graphics=scicos_graphics(..
						  orig=[349.49528;565.10704],..
						  sz=[0.3333333,0.3333333],..
						  flip=%t,..
						  theta=0,..
						  exprs=[],..
						  pin=[],..
						  pout=[],..
						  pein=2,..
						  peout=[8;4],..
						  gr_i=list([],8),..
						  id="",..
						  in_implicit=[],..
						  out_implicit=[]),..
				 model=scicos_model(..
						    sim="split",..
						    in=[],..
						    in2=[],..
						    intyp=1,..
						    out=[],..
						    out2=[],..
						    outtyp=1,..
						    evtin=1,..
						    evtout=[1;1],..
						    state=[],..
						    dstate=[],..
						    odstate=list(),..
						    rpar=[],..
						    ipar=[],..
						    opar=list(),..
						    blocktype="d",..
						    firing=[%f,%f,%f],..
						    dep_ut=[%f,%f],..
						    label="",..
						    nzcross=0,..
						    nmode=0,..
						    equations=list()),..
				 doc=list())
    scs_m_1.objs(4)=scicos_link(..
				xx=[349.49528;266.69602;266.69602;270.35525;342.80795;342.80795;349.63473],..
				yy=[565.10704;565.10704;680.99483;680.99483;680.99483;651.89946;651.89946],..
				id="drawlink",..
				thick=[0,0],..
				ct=[5,-1],..
				from=[3,2,0],..
				to=[1,1,1])
    scs_m_1.objs(5)=scicos_block(..
				 gui="OUT_f",..
				 graphics=scicos_graphics(..
						  orig=[398.20616,616.18517],..
						  sz=[20,20],..
						  flip=%t,..
						  theta=0,..
						  exprs="1",..
						  pin=6,..
						  pout=[],..
						  pein=[],..
						  peout=[],..
						  gr_i=list(" ",8),..
						  id="",..
						  in_implicit="E",..
						  out_implicit=[]),..
				 model=scicos_model(..
						    sim="output",..
						    in=-1,..
						    in2=-2,..
						    intyp=-1,..
						    out=[],..
						    out2=[],..
						    outtyp=1,..
						    evtin=[],..
						    evtout=[],..
						    state=[],..
						    dstate=[],..
						    odstate=list(),..
						    rpar=[],..
						    ipar=1,..
						    opar=list(),..
						    blocktype="c",..
						    firing=[],..
						    dep_ut=[%f,%f],..
						    label="",..
						    nzcross=0,..
						    nmode=0,..
						    equations=list()),..
				 doc=list())
    scs_m_1.objs(6)=scicos_link(..
				xx=[378.20616;398.20616],..
				yy=[626.18517;626.18517],..
				id="drawlink",..
				thick=[0,0],..
				ct=[1,1],..
				from=[1,1,0],..
				to=[5,1,1])
    scs_m_1.objs(7)=scicos_block(..
				 gui="CLKOUTV_f",..
				 graphics=scicos_graphics(..
						  orig=[339.49528,505.10704],..
						  sz=[20,30],..
						  flip=%t,..
						  theta=0,..
						  exprs="1",..
						  pin=[],..
						  pout=[],..
						  pein=8,..
						  peout=[],..
						  gr_i=list(" ",8),..
						  id="",..
						  in_implicit=[],..
						  out_implicit=[]),..
				 model=scicos_model(..
						    sim="output",..
						    in=[],..
						    in2=[],..
						    intyp=1,..
						    out=[],..
						    out2=[],..
						    outtyp=1,..
						    evtin=1,..
						    evtout=[],..
						    state=[],..
						    dstate=[],..
						    odstate=list(),..
						    rpar=[],..
						    ipar=1,..
						    opar=list(),..
						    blocktype="d",..
						    firing=[],..
						    dep_ut=[%f,%f],..
						    label="",..
						    nzcross=0,..
						    nmode=0,..
						    equations=list()),..
				 doc=list())
    scs_m_1.objs(8)=scicos_link(..
				xx=[349.49528;349.49528],..
				yy=[565.10704;535.10704],..
				id="drawlink",..
				thick=[0,0],..
				ct=[5,-1],..
				from=[3,1,0],..
				to=[7,1,1])
    model=scicos_model(..
		       sim="csuper",..
		       in=[],..
		       in2=[],..
		       intyp=1,..
		       out=-1,..
		       out2=[],..
		       outtyp=1,..
		       evtin=[],..
		       evtout=1,..
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

    // we use the gr_i of the internal curve 
    gr_i = ['arg1=arg1.model.rpar.objs(1);'
	    'model=arg1.model;';
	    model.rpar.objs(1).graphics.gr_i(1)];
    
    x=standard_define([2 2],model,[],gr_i,'Sigbuilder');
  end
endfunction

// just in case for compatibility 
//
function [X,Y,orpar]=Do_Spline2(N,order,x,y)
  [X,Y,orpar]=Do_Spline(N,order,x,y);
endfunction


