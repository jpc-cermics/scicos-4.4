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
    xx=arg1.model.rpar.objs(1)// get the 1/z  block
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
	arg1.model.rpar.objs(1)=xx// Update
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
    if %t then 
      // using the new saved diagram obtained by 
      diagram=jklflipflop_diagram_new();
      diagram=do_eval(diagram);
      model.rpar=diagram;
    else
      model.rpar=jklflipflop_diagram()
    end
    gr_i=['draw_jkflipflop(orig,sz,o);'];
    x=standard_define([2 3],model,[],gr_i,'JKFLIPFLOP');
  end
endfunction
  
function scs_m=jklflipflop_diagram()
  scs_m=scicos_diagram(..
		       version="scicos4.2",..
		       props=scicos_params(..
					   wpar=[600,450,0,0,600,450],..
					   Title=["JKFLIPFLOP"],..
					   tol=[0.0001;0.000001;1.000E-10;100001;0;0;0],..
					   tf=60,..
					   context=" ",..
					   void1=[],..
					   options=scicos_options(),..
					   void2=[],..
					   void3=[],..
					   doc=list()))
  scs_m.objs(1)=scicos_block(..
			     gui="DOLLAR_m",..
			     graphics=scicos_graphics(..
						  orig=[299.96961,261.584],..
						  sz=[40,40],..
						  flip=%f,..
						  theta=0,..
						  exprs=["m2i(0,''int8'')";"1"],..
						  pin=7,..
						  pout=5,..
						  pein=[],..
						  peout=[],..
						  gr_i=list("xstringb(orig(1),orig(2),''1/z'',sz(1),sz(2),''fill'')",8),..
						  id="",..
						  in_implicit="E",..
						  out_implicit="E"),..
			       model=scicos_model(..
						  sim=list("dollar4_m",4),..
						  in=1,..
						  in2=1,..
						  intyp=5,..
						  out=1,..
						  out2=1,..
						  outtyp=5,..
						  evtin=[],..
						  evtout=[],..
						  state=[],..
						  dstate=[],..
						  odstate=list(m2i(0,'int8')),..
						  rpar=[],..
						  ipar=[],..
						  opar=list(),..
						  blocktype="d",..
						  firing=[],..
						  dep_ut=[%f,%f],..
						  label="",..
						  nzcross=0,..
						  nmode=0,..
						  equations=list()),..
			       doc=list())
    scs_m_1=scicos_diagram(..
			   version="scicos4.2",..
			   props=scicos_params(..
					       wpar=[600,450,0,0,600,450],..
					       Title=["EDGE_TRIGGER","./"],..
					       tol=[0.0001;0.000001;1.000E-10;100001;0;0;0],..
					       tf=30,..
					       context=" ",..
					       void1=[],..
					       options=scicos_options(),..
					       void2=[],..
					       void3=[],..
					       doc=list()))
    scs_m_1.objs(1)=scicos_block(..
				 gui="EDGETRIGGER",..
				 graphics=scicos_graphics(..
						  orig=[288.58631,257.1131],..
						  sz=[60,40],..
						  flip=%t,..
						  theta=0,..
						  exprs="-1",..
						  pin=5,..
						  pout=3,..
						  pein=[],..
						  peout=[],..
						  gr_i=list("xstringb(orig(1),orig(2),[''Edge'';''trigger''],sz(1),sz(2),''fill'');",8),..
						  id="",..
						  in_implicit="E",..
						  out_implicit="E"),..
				 model=scicos_model(..
						    sim=list("edgetrig",4),..
						    in=1,..
						    in2=[],..
						    intyp=1,..
						    out=1,..
						    out2=[],..
						    outtyp=1,..
						    evtin=[],..
						    evtout=[],..
						    state=[],..
						    dstate=0,..
						    odstate=list(),..
						    rpar=[],..
						    ipar=-1,..
						    opar=list(),..
						    blocktype="c",..
						    firing=[],..
						    dep_ut=[%t,%f],..
						    label="",..
						    nzcross=1,..
						    nmode=0,..
						    equations=list()),..
				 doc=list())
    scs_m_1.objs(2)=scicos_block(..
				 gui="IFTHEL_f",..
				 graphics=scicos_graphics(..
						  orig=[388.28869,247.1131],..
						  sz=[60,60],..
						  flip=%t,..
						  theta=0,..
						  exprs=["0";"0"],..
						  pin=3,..
						  pout=[],..
						  pein=[],..
						  peout=[7;0],..
						  gr_i=list(..
						  ["txt=[''If in>0'';'' '';'' then    else''];";
		    "xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'');"],8),..
						  id="",..
						  in_implicit="E",..
						  out_implicit=[]),..
				 model=scicos_model(..
						    sim=list("ifthel",-1),..
						    in=1,..
						    in2=[],..
						    intyp=1,..
						    out=[],..
						    out2=1,..
						    outtyp=[],..
						    evtin=[],..
						    evtout=[1;1],..
						    state=[],..
						    dstate=[],..
						    odstate=list(),..
						    rpar=[],..
						    ipar=[],..
						    opar=list(),..
						    blocktype="l",..
						    firing=[-1,-1],..
						    dep_ut=[%t,%f],..
						    label="",..
						    nzcross=0,..
						    nmode=0,..
						    equations=list()),..
				 doc=list())
    scs_m_1.objs(3)=scicos_link(..
				xx=[357.15774;362.99107;379.71726],..
				yy=[277.1131;277.1131;277.1131],..
				id="drawlink",..
				thick=[0,0],..
				ct=[1,1],..
				from=[1,1,0],..
				to=[2,1,1])
    scs_m_1.objs(4)=scicos_block(..
				 gui="IN_f",..
				 graphics=scicos_graphics(..
						  orig=[240.01488,267.1131],..
						  sz=[20,20],..
						  flip=%t,..
						  theta=0,..
						  exprs="1",..
						  pin=[],..
						  pout=5,..
						  pein=[],..
						  peout=[],..
						  gr_i=list(" ",8),..
						  id="",..
						  in_implicit=[],..
						  out_implicit="E"),..
				 model=scicos_model(..
						    sim="input",..
						    in=[],..
						    in2=[],..
						    intyp=1,..
						    out=-1,..
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
    scs_m_1.objs(5)=scicos_link(..
				xx=[260.01488;280.01488],..
				yy=[277.1131;277.1131],..
				id="drawlink",..
				thick=[0,0],..
				ct=[1,1],..
				from=[4,1,0],..
				to=[1,1,1])
    scs_m_1.objs(6)=scicos_block(..
				 gui="CLKOUTV_f",..
				 graphics=scicos_graphics(..
						  orig=[398.28869,181.39881],..
						  sz=[20,30],..
						  flip=%t,..
						  theta=0,..
						  exprs="1",..
						  pin=[],..
						  pout=[],..
						  pein=7,..
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
    scs_m_1.objs(7)=scicos_link(..
				xx=[408.28869;408.28869],..
				yy=[241.39881;211.39881],..
				id="drawlink",..
				thick=[0,0],..
				ct=[5,-1],..
				from=[2,1,0],..
				to=[6,1,1])
    scs_m.objs(2)=scicos_block(..
			       gui="EDGE_TRIGGER",..
			       graphics=scicos_graphics(..
						  orig=[292.52452,323.54888],..
						  sz=[60,40],..
						  flip=%t,..
						  theta=0,..
						  exprs=[],..
						  pin=14,..
						  pout=[],..
						  pein=[],..
						  peout=8,..
						  gr_i=list("xstringb(orig(1),orig(2),[''EDGE'';''TRIGGER''],sz(1),sz(2),''fill'')",8),..
						  id="",..
						  in_implicit="E",..
						  out_implicit=[]),..
			       model=scicos_model(..
						  sim="csuper",..
						  in=-1,..
						  in2=[],..
						  intyp=1,..
						  out=[],..
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
						  equations=list()),..
			       doc=list())
    scs_m.objs(3)=scicos_block(..
			       gui="LOGIC",..
			       graphics=scicos_graphics(..
						  orig=[302.79613,202.52782],..
						  sz=[40,40],..
						  flip=%t,..
						  theta=0,..
						  exprs=["[0;1;1;1;0;0;1;0]";"0"],..
						  pin=[5;16;18],..
						  pout=4,..
						  pein=8,..
						  peout=[],..
						  gr_i=list("xstringb(orig(1),orig(2),[''Logic''],sz(1),sz(2),''fill'');",8),..
						  id="",..
						  in_implicit=["E";"E";"E"],..
						  out_implicit="E"),..
			       model=scicos_model(..
						  sim=list("logic",4),..
						  in=[1;1;1],..
			in2=[1;1;1],..
			intyp=[5;5;5],..
			out=1,..
			out2=1,..
			outtyp=5,..
			evtin=1,..
			evtout=[],..
			state=[],..
			dstate=[],..
			odstate=list(),..
			rpar=[],..
			ipar=[],..
			opar=list(m2i([0;1;1;1;0;0;1;0],'int8')),..
			blocktype="c",..
			firing=%f,..
			dep_ut=[%t,%f],..
			label="",..
			nzcross=0,..
			nmode=0,..
			equations=list()),..
		doc=list())
	scs_m.objs(4)=scicos_link(..
			xx=[351.36756;368.82793;368.82793],..
			yy=[222.52782;222.52782;223.06473],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[3,1,0],..
			to=[10,1,1])
	scs_m.objs(5)=scicos_link(..
			xx=[291.39818;274.18235;274.18235;294.2247],..
			yy=[281.584;281.584;232.52782;232.52782],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[1,1,0],..
			to=[3,1,1])
	scs_m.objs(6)=scicos_block(..
		gui="SPLIT_f",..
		graphics=scicos_graphics(..
			orig=[368.82793,243.45067],..
			sz=[0.3333333,0.3333333],..
			flip=%t,..
			theta=0,..
			exprs=[],..
			pin=11,..
			pout=[7;20],..
			pein=[],..
			peout=[],..
			gr_i=list([],8),..
			id="",..
			in_implicit="E",..
			out_implicit=["E";"E";"E"]),..
		model=scicos_model(..
			sim="lsplit",..
			in=-1,..
			in2=[],..
			intyp=1,..
			out=[-1;-1;-1],..
			out2=[],..
			outtyp=1,..
			evtin=[],..
			evtout=[],..
			state=[],..
			dstate=[],..
			odstate=list(),..
			rpar=[],..
			ipar=[],..
			opar=list(),..
			blocktype="c",..
			firing=[],..
			dep_ut=[%t,%f],..
			label="",..
			nzcross=0,..
			nmode=0,..
			equations=list()),..
		doc=list())
	scs_m.objs(7)=scicos_link(..
			xx=[368.82793;368.82793;345.68389],..
			yy=[243.45067;281.584;281.584],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[6,1,0],..
			to=[1,1,1])
	scs_m.objs(8)=scicos_link(..
			xx=[322.52452;374.69743;374.69743;322.79613],..
			yy=[317.8346;317.8346;248.24211;248.24211],..
			id="drawlink",..
			thick=[0,0],..
			ct=[5,-1],..
			from=[2,1,0],..
			to=[3,1,1])
	scs_m.objs(9)=scicos_block(..
		gui="LOGICAL_OP",..
		graphics=scicos_graphics(..
			orig=[377.63217,159.25363],..
			sz=[60,40],..
			flip=%t,..
			theta=0,..
			exprs=["1";"5";"5";"0"],..
			pin=12,..
			pout=22,..
			pein=[],..
			peout=[],..
			gr_i=list(..
			"xstringb(orig(1),orig(2),[''Logical Op '';OPER],sz(1),sz(2),''fill'');",8),..
			id="",..
			in_implicit="E",..
			out_implicit="E"),..
		model=scicos_model(..
			sim=list("logicalop_i8",4),..
			in=-1,..
			in2=-2,..
			intyp=5,..
			out=-1,..
			out2=-2,..
			outtyp=5,..
			evtin=[],..
			evtout=[],..
			state=[],..
			dstate=[],..
			odstate=list(),..
			rpar=[],..
			ipar=[5;0],..
			opar=list(),..
			blocktype="c",..
			firing=[],..
			dep_ut=[%t,%f],..
			label="",..
			nzcross=0,..
			nmode=0,..
			equations=list()),..
		doc=list())
	scs_m.objs(10)=scicos_block(..
		gui="SPLIT_f",..
		graphics=scicos_graphics(..
				orig=[368.82793;223.06473],..
				sz=[0.3333333,0.3333333],..
				flip=%t,..
				theta=0,..
				exprs=[],..
				pin=4,..
				pout=[11;12],..
				pein=[],..
				peout=[],..
				gr_i=list([],8),..
				id="",..
				in_implicit="E",..
				out_implicit=["E";"E";"E"]),..
		model=scicos_model(..
				sim="lsplit",..
				in=-1,..
				in2=[],..
				intyp=1,..
				out=[-1;-1;-1],..
				out2=[],..
				outtyp=1,..
				evtin=[],..
				evtout=[],..
				state=[],..
				dstate=[],..
				odstate=list(),..
				rpar=[],..
				ipar=[],..
				opar=list(),..
				blocktype="c",..
				firing=[],..
				dep_ut=[%t,%f],..
				label="",..
				nzcross=0,..
				nmode=0,..
				equations=list()),..
		doc=list())
	scs_m.objs(11)=scicos_link(..
			xx=[368.82793;368.82793],..
			yy=[223.06473;243.45067],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[10,1,0],..
			to=[6,1,1])
	scs_m.objs(12)=scicos_link(..
			xx=[368.82793;368.82793;369.06074],..
			yy=[223.06473;177.7867;179.25363],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[10,2,0],..
			to=[9,1,1])
	scs_m.objs(13)=scicos_block(..
		gui="IN_f",..
		graphics=scicos_graphics(..
				orig=[243.95309,333.54888],..
				sz=[20,20],..
				flip=%t,..
				theta=0,..
				exprs="2",..
				pin=[],..
				pout=14,..
				pein=[],..
				peout=[],..
				gr_i=list(" ",8),..
				id="",..
				in_implicit=[],..
				out_implicit="E"),..
		model=scicos_model(..
				sim="input",..
				in=[],..
				in2=[],..
				intyp=1,..
				out=-1,..
				out2=[],..
				outtyp=-1,..
				evtin=[],..
				evtout=[],..
				state=[],..
				dstate=[],..
				odstate=list(),..
				rpar=[],..
				ipar=2,..
				opar=list(),..
				blocktype="c",..
				firing=[],..
				dep_ut=[%f,%f],..
				label="",..
				nzcross=0,..
				nmode=0,..
				equations=list()),..
		doc=list())
	scs_m.objs(14)=scicos_link(..
			xx=[263.95309;283.95309],..
			yy=[343.54888;343.54888],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[13,1,0],..
			to=[2,1,1])
	scs_m.objs(15)=scicos_block(..
		gui="IN_f",..
		graphics=scicos_graphics(..
				orig=[254.2247,212.52782],..
				sz=[20,20],..
				flip=%t,..
				theta=0,..
				exprs="1",..
				pin=[],..
				pout=16,..
				pein=[],..
				peout=[],..
				gr_i=list(" ",8),..
				id="",..
				in_implicit=[],..
				out_implicit="E"),..
		model=scicos_model(..
				sim="input",..
				in=[],..
				in2=[],..
				intyp=1,..
				out=-1,..
				out2=[],..
				outtyp=-1,..
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
	scs_m.objs(16)=scicos_link(..
			xx=[274.2247;294.2247],..
			yy=[222.52782;222.52782],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[15,1,0],..
			to=[3,2,1])
	scs_m.objs(17)=scicos_block(..
		gui="IN_f",..
		graphics=scicos_graphics(..
				orig=[254.2247,202.52782],..
				sz=[20,20],..
				flip=%t,..
				theta=0,..
				exprs="3",..
				pin=[],..
				pout=18,..
				pein=[],..
				peout=[],..
				gr_i=list(" ",8),..
				id="",..
				in_implicit=[],..
				out_implicit="E"),..
		model=scicos_model(..
				sim="input",..
				in=[],..
				in2=[],..
				intyp=1,..
				out=-1,..
				out2=[],..
				outtyp=-1,..
				evtin=[],..
				evtout=[],..
				state=[],..
				dstate=[],..
				odstate=list(),..
				rpar=[],..
				ipar=3,..
				opar=list(),..
				blocktype="c",..
				firing=[],..
				dep_ut=[%f,%f],..
				label="",..
				nzcross=0,..
				nmode=0,..
				equations=list()),..
		doc=list())
	scs_m.objs(18)=scicos_link(..
			xx=[274.2247;294.2247],..
			yy=[212.52782;212.52782],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[17,1,0],..
			to=[3,3,1])
	scs_m.objs(19)=scicos_block(..
		gui="OUT_f",..
		graphics=scicos_graphics(..
				orig=[388.82793,233.45067],..
				sz=[20,20],..
				flip=%t,..
				theta=0,..
				exprs="1",..
				pin=20,..
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
				in2=[],..
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
	scs_m.objs(20)=scicos_link(..
			xx=[368.82793;388.82793],..
			yy=[243.45067;243.45067],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[6,2,0],..
			to=[19,1,1])
	scs_m.objs(21)=scicos_block(..
		gui="OUT_f",..
		graphics=scicos_graphics(..
				orig=[466.2036,169.25363],..
				sz=[20,20],..
				flip=%t,..
				theta=0,..
				exprs="2",..
				pin=22,..
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
				in2=[],..
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
				ipar=2,..
				opar=list(),..
				blocktype="c",..
				firing=[],..
				dep_ut=[%f,%f],..
				label="",..
				nzcross=0,..
				nmode=0,..
				equations=list()),..
		doc=list())
	scs_m.objs(22)=scicos_link(..
			xx=[446.2036;466.2036],..
			yy=[179.25363;179.25363],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[9,1,0],..
			to=[21,1,1])
endfunction


function scs_m=jklflipflop_diagram_new()
// internal diagram of block poo
  x_0=scicos_diagram();
  x_1=scicos_params();
  x_1.wpar=      [   182.7768,   107.6623,   555.8425,   422.2770,   608.0000,   429.0000 ,...
		     0,    29.5000,   523.0000,   454.0000,   503.0000,    99.0000 ,...
		     1.4000,   521.0000,   370.0000 ]
  x_1.context=      [ " " ]
  x_2=scicos_options();
  x_3=list();
  x_3(1)=        [   5,   1 ]
  x_3(2)=        [   4,   1 ]
  x_2.ID=x_3;clear('x_3');
  x_1.options=x_2;clear('x_2');
  x_1.title=      [ "SuperBlock" ]
  x_1.tf=      [   60 ]
  x_1.Title=      [ "JKFLIPFLOP" ]
  x_1.tol=      [   1.000e-04;
		    1.000e-06;
		    1.000e-10;
		    1.000e+05;
		    0;
		    0;
		    0 ]
  x_0.props=x_1;clear('x_1');
  x_1=list();
  x_2=DOLLAR_m('define');
  x_2.graphics.peout= []
  x_2.graphics.exprs=       [ "m2i(0,''int8'')";
		    "1" ]
  x_2.graphics.pin=       [   7 ]
  x_2.graphics.pout=       [   5 ]
  x_2.graphics.in_implicit=       [ "E" ]
  x_2.graphics.out_implicit=       [ "E" ]
  x_2.graphics.sz=       [   40,   40 ]
  x_2.graphics.flip=       [  %f ]
  x_2.graphics.pein= []
  x_2.graphics.orig=       [   299.9696,   261.5840 ]
  x_1(1)=x_2;clear('x_2');
  x_2=EDGE_TRIGGER('define');
  x_2.graphics.peout=       [   8 ]
  x_2.graphics.pin=       [   14 ]
  x_2.graphics.in_implicit=       [ "E" ]
  x_2.graphics.sz=       [   60,   40 ]
  x_2.graphics.orig=       [   292.5245,   323.5489 ]
  x_1(2)=x_2;clear('x_2');
  x_2=LOGIC('define');
  x_2.graphics.peout= []
  x_2.graphics.exprs=       [ "[0;1;1;1;0;0;1;0]";
		    "0" ]
  x_2.graphics.pin=       [    5;
		    16;
		    18 ]
  x_2.graphics.pout=       [   4 ]
  x_2.graphics.in_implicit=       [ "E";
		    "E";
		    "E" ]
  x_2.graphics.out_implicit=       [ "E" ]
  x_2.graphics.sz=       [   40,   40 ]
  x_2.graphics.pein=       [   8 ]
  x_2.graphics.orig=       [   302.7961,   202.5278 ]
  x_1(3)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.xx=       [   351.3676;
		    368.8279;
		    368.8279 ]
  x_2.yy=       [   222.5278;
		    222.5278;
		    223.0647 ]
  x_2.from=       [   3,   1,   0 ]
  x_2.to=       [   10,    1,    1 ]
  x_1(4)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.xx=       [   291.3982;
		    274.1823;
		    274.1823;
		    294.2247 ]
  x_2.yy=       [   281.5840;
		    281.5840;
		    232.5278;
		    232.5278 ]
  x_2.from=       [   1,   1,   0 ]
  x_2.to=       [   3,   1,   1 ]
  x_1(5)=x_2;clear('x_2');
  x_2=SPLIT_f('define');
  x_2.graphics.pin=       [   11 ]
  x_2.graphics.pout=       [    7;
		    20 ]
  x_2.graphics.in_implicit=       [ "E" ]
  x_2.graphics.out_implicit=       [ "E";
		    "E";
		    "E" ]
  x_2.graphics.sz=       [   0.3333,   0.3333 ]
  x_2.graphics.orig=       [   368.8279,   243.4507 ]
  x_1(6)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.xx=       [   368.8279;
		    368.8279;
		    345.6839 ]
  x_2.yy=       [   243.4507;
		    281.5840;
		    281.5840 ]
  x_2.from=       [   6,   1,   0 ]
  x_2.to=       [   1,   1,   1 ]
  x_1(7)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.xx=       [   322.5245;
		    374.6974;
		    374.6974;
		    322.7961 ]
  x_2.yy=       [   317.8346;
		    317.8346;
		    248.2421;
		    248.2421 ]
  x_2.from=       [   2,   1,   0 ]
  x_2.ct=       [    5,   -1 ]
  x_2.to=       [   3,   1,   1 ]
  x_1(8)=x_2;clear('x_2');
  x_2=LOGICAL_OP('define');
  x_2.graphics.peout= []
  x_2.graphics.exprs=       [ "1";
		    "5";
		    "5";
		    "0" ]
  x_2.graphics.pin=       [   12 ]
  x_2.graphics.pout=       [   22 ]
  x_2.graphics.in_implicit=       [ "E" ]
  x_2.graphics.out_implicit=       [ "E" ]
  x_2.graphics.sz=       [   60,   40 ]
  x_3=list();
  x_3(1)=        [ "xstringb(orig(1),orig(2),[''Logical Op '';OPER],sz(1),sz(2),''fill'');" ]
  x_3(2)=        [   8 ]
  x_2.graphics.gr_i=x_3;clear('x_3');
  x_2.graphics.pein= []
  x_2.graphics.orig=       [   377.6322,   159.2536 ]
  x_1(9)=x_2;clear('x_2');
  x_2=SPLIT_f('define');
  x_2.graphics.pin=       [   4 ]
  x_2.graphics.pout=       [   11;
		    12 ]
  x_2.graphics.in_implicit=       [ "E" ]
  x_2.graphics.out_implicit=       [ "E";
		    "E";
		    "E" ]
  x_2.graphics.sz=       [   0.3333,   0.3333 ]
  x_2.graphics.orig=       [   368.8279;
		    223.0647 ]
  x_1(10)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.xx=       [   368.8279;
		    368.8279 ]
  x_2.yy=       [   223.0647;
		    243.4507 ]
  x_2.from=       [   10,    1,    0 ]
  x_2.to=       [   6,   1,   1 ]
  x_1(11)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.xx=       [   368.8279;
		    368.8279;
		    369.0607 ]
  x_2.yy=       [   223.0647;
		    177.7867;
		    179.2536 ]
  x_2.from=       [   10,    2,    0 ]
  x_2.to=       [   9,   1,   1 ]
  x_1(12)=x_2;clear('x_2');
  x_2=IN_f('define');
  x_2.graphics.exprs=       [ "2";
		    "-1";
		    "-1" ]
  x_2.graphics.pout=       [   14 ]
  x_2.graphics.sz=       [   20,   20 ]
  x_2.graphics.orig=       [   205.8180,   333.5489 ]
  x_1(13)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.from=       [   13,    1,    0 ]
  x_2.xx=       [   225.8180;
		    273.9531;
		    283.9531 ]
  x_2.yy=       [   343.5489;
		    343.5489;
		    343.5489 ]
  x_2.to=       [   2,   1,   1 ]
  x_1(14)=x_2;clear('x_2');
  x_2=IN_f('define');
  x_2.graphics.pout=       [   16 ]
  x_2.graphics.sz=       [   20,   20 ]
  x_2.graphics.orig=       [   212.4228,   213.2612 ]
  x_1(15)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.from=       [   15,    1,    0 ]
  x_2.xx=       [   232.4228;
		    284.2247;
		    284.2247;
		    294.2247 ]
  x_2.yy=       [   223.2612;
		    223.2612;
		    222.5278;
		    222.5278 ]
  x_2.to=       [   3,   2,   1 ]
  x_1(16)=x_2;clear('x_2');
  x_2=IN_f('define');
  x_2.graphics.exprs=       [ "3";
		    "-1";
		    "-1" ]
  x_2.graphics.pout=       [   18 ]
  x_2.graphics.sz=       [   20,   20 ]
  x_2.graphics.orig=       [   213.8895,   175.3932 ]
  x_1(17)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.from=       [   17,    1,    0 ]
  x_2.xx=       [   233.8895;
		    284.2247;
		    284.2247;
		    294.2247 ]
  x_2.yy=       [   185.3932;
		    185.3932;
		    212.5278;
		    212.5278 ]
  x_2.to=       [   3,   3,   1 ]
  x_1(18)=x_2;clear('x_2');
  x_2=OUT_f('define');
  x_2.graphics.sz=       [   20,   20 ]
  x_2.graphics.orig=       [   388.8279,   233.4507 ]
  x_2.graphics.pin=       [   20 ]
  x_1(19)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.from=       [   6,   2,   0 ]
  x_2.xx=       [   368.8279;
		    388.8279 ]
  x_2.yy=       [   243.4507;
		    243.4507 ]
  x_2.to=       [   19,    1,    1 ]
  x_1(20)=x_2;clear('x_2');
  x_2=OUT_f('define');
  x_2.graphics.exprs=       [ "2" ]
  x_2.graphics.sz=       [   20,   20 ]
  x_2.graphics.orig=       [   466.2036,   169.2536 ]
  x_2.graphics.pin=       [   22 ]
  x_1(21)=x_2;clear('x_2');
  x_2=scicos_link();
  x_2.from=       [   9,   1,   0 ]
  x_2.xx=       [   446.2036;
		    466.2036 ]
  x_2.yy=       [   179.2536;
		    179.2536 ]
  x_2.to=       [   21,    1,    1 ]
  x_1(22)=x_2;clear('x_2');
  x_0.objs=x_1;clear('x_1');
  scs_m=x_0;clear('x_0');
endfunction
