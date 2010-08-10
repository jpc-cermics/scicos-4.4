function [x,y,typ]=DFLIPFLOP(job,arg1,arg2)
// Copyright INRIA
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
    x=arg1
   case 'define' then
	scs_m=scicos_diagram(..
      version="scicos4.2",..
      props=scicos_params(..
            wpar=[600,450,0,0,600,450],..
            Title=["DFLIPFLOP"],..
            tol=[0.0001,0.000001,1.000E-10,100001,0,0],..
            tf=100000,..
            context=" ",..
            void1=[],..
            options=tlist(["scsopt","3D","Background","Link","ID","Cmap"],list(%t,33),[8,1],[1,5],..
            list([5,1],[4,1]),[0.8,0.8,0.8]),..
            void2=[],..
            void3=[],..
            doc=list()))
	scs_m.objs(1)=scicos_block(..
		gui="CONST_m",..
		graphics=scicos_graphics(..
			orig=[109.62561,263.44465],..
			sz=[20;20],..
			flip=%t,..
			theta=0,..
			exprs="m2i(0,''int8'');",..
			pin=[],..
			pout=6,..
			pein=[],..
			peout=[],..
			gr_i=list(..
			["dx=sz(1)/5;dy=sz(2)/10;";
			"w=sz(1)-2*dx;h=sz(2)-2*dy;";
			"txt=C;";
			"xstringb(orig(1)+dx,orig(2)+dy,txt,w,h,''fill'');"],8),..
			id="",..
			in_implicit=[],..
			out_implicit="E"),..
		model=scicos_model(..
			sim=list("cstblk4_m",4),..
			in=[],..
			in2=[],..
			intyp=1,..
			out=1,..
			out2=1,..
			outtyp=5,..
			evtin=[],..
			evtout=[],..
			state=[],..
			dstate=[],..
			odstate=list(),..
			rpar=[],..
			ipar=[],..
			opar=list(m2i(0,'int8')),..
			blocktype="d",..
			firing=[],..
			dep_ut=[%f,%f],..
			label="",..
			nzcross=0,..
			nmode=0,..
			equations=list()),..
		doc=list())
	scs_m.objs(2)=scicos_block(..
		gui="IFTHEL_f",..
		graphics=scicos_graphics(..
			orig=[239.98293,378.2166],..
			sz=[60,60],..
			flip=%t,..
			theta=0,..
			exprs=["1";"1"],..
			pin=29,..
			pout=[],..
			pein=22,..
			peout=[16;44],..
			gr_i=list(..
			["txt=[''If in>0'';'' '';'' then    else''];";
			"xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'');"],8),..
			id="",..
			in_implicit="E",..
			out_implicit=[]),..
		model=scicos_model(..
			sim=list("ifthel",-1),..
			in=1,..
			in2=1,..
			intyp=-1,..
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
			blocktype="l",..
			firing=[-1,-1],..
			dep_ut=[%t,%f],..
			label="",..
			nzcross=1,..
			nmode=1,..
			equations=list()),..
		doc=list())
	scs_m.objs(3)=scicos_block(..
		gui="LOGICAL_OP",..
		graphics=scicos_graphics(..
			orig=[152.88902,260.24498],..
			sz=[60,40],..
			flip=%t,..
			theta=0,..
			exprs=["2";"1";"5";"0"],..
			pin=[11;39],..
			pout=5,..
			pein=[],..
			peout=[],..
			gr_i=list(..
			"xstringb(orig(1),orig(2),['' Logical Op '';OPER],sz(1),sz(2),''fill'');",8),..
			id="",..
			in_implicit=["E";"E"],..
			out_implicit="E"),..
		model=scicos_model(..
			sim=list("logicalop_i8",4),..
			in=[-1;-1],..
			in2=[-2;-2],..
			intyp=[5;5],..
			out=-1,..
			out2=-2,..
			outtyp=5,..
			evtin=[],..
			evtout=[],..
			state=[],..
			dstate=[],..
			odstate=list(),..
			rpar=[],..
			ipar=[1;0],..
			opar=list(),..
			blocktype="c",..
			firing=[],..
			dep_ut=[%t,%f],..
			label="",..
			nzcross=0,..
			nmode=0,..
			equations=list()),..
		doc=list())
	scs_m.objs(4)=scicos_block(..
		gui="SAMPHOLD_m",..
		graphics=scicos_graphics(..
			orig=[233.72156,260.24498],..
			sz=[40,40],..
			flip=%t,..
			theta=0,..
			exprs="5",..
			pin=5,..
			pout=33,..
			pein=42,..
			peout=[],..
			gr_i=list("xstringb(orig(1),orig(2),''S/H'',sz(1),sz(2),''fill'')",8),..
			id="",..
			in_implicit="E",..
			out_implicit="E"),..
		model=scicos_model(..
			sim=list("samphold4_m",4),..
			in=-1,..
			in2=-2,..
			intyp=5,..
			out=-1,..
			out2=-2,..
			outtyp=5,..
			evtin=1,..
			evtout=[],..
			state=[],..
			dstate=[],..
			odstate=list(),..
			rpar=[],..
			ipar=[],..
			opar=list(),..
			blocktype="d",..
			firing=[],..
			dep_ut=[%t,%f],..
			label="",..
			nzcross=0,..
			nmode=0,..
			equations=list()),..
		doc=list())
	scs_m.objs(5)=scicos_link(..
			xx=[221.46044;225.15013],..
			yy=[280.24498;280.24498],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[3,1,0],..
			to=[4,1,1])
	scs_m.objs(6)=scicos_link(..
			xx=[138.19704;140.34523],..
			yy=[273.44465;273.49157],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[1,1,0],..
			to=[38,1,1])
	scs_m.objs(7)=scicos_block(..
		gui="LOGICAL_OP",..
		graphics=scicos_graphics(..
			orig=[373.24106,309.46812],..
			sz=[60,40],..
			flip=%t,..
			theta=0,..
			exprs=["1";"5";"5";"0"],..
			pin=36,..
			pout=13,..
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
	scs_m.objs(8)=scicos_block(..
		gui="IN_f",..
		graphics=scicos_graphics(..
			orig=[199.48466,398.2166],..
			sz=[20,20],..
			flip=%t,..
			theta=0,..
			exprs="3",..
			pin=[],..
			pout=9,..
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
	scs_m.objs(9)=scicos_link(..
			xx=[219.48466;222.54128],..
			yy=[408.2166;408.2166],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[8,1,0],..
			to=[28,1,1])
	scs_m.objs(10)=scicos_block(..
		gui="IN_f",..
		graphics=scicos_graphics(..
				orig=[104.31759,276.91165],..
				sz=[20,20],..
				flip=%t,..
				theta=0,..
				exprs="1",..
				pin=[],..
				pout=11,..
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
	scs_m.objs(11)=scicos_link(..
			xx=[124.31759;144.31759],..
			yy=[286.91165;286.91165],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[10,1,0],..
			to=[3,1,1])
	scs_m.objs(12)=scicos_block(..
		gui="OUT_f",..
		graphics=scicos_graphics(..
				orig=[457.40928,320.20131],..
				sz=[20,20],..
				flip=%t,..
				theta=0,..
				exprs="2",..
				pin=13,..
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
	scs_m.objs(13)=scicos_link(..
			xx=[441.81249;457.40928],..
			yy=[329.46812;330.20131],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[7,1,0],..
			to=[12,1,1])
	scs_m.objs(14)=scicos_block(..
		gui="OUT_f",..
		graphics=scicos_graphics(..
				orig=[376.4669,270.83282],..
				sz=[20,20],..
				flip=%t,..
				theta=0,..
				exprs="1",..
				pin=37,..
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
	scs_m_1=scicos_diagram(..
		version="scicos4.2",..
		props=scicos_params(..
		wpar=[600,450,0,0,600,450],..
		Title="Untitled",..
		tol=[0.0001,0.000001,1.000E-10,100001,0,0],..
		tf=100000,..
		context=[],..
		void1=[],..
		options=tlist(["scsopt","3D","Background","Link","ID","Cmap"],list(%t,33),[8,1],[1,5],..
		list([5,1],[4,1]),[0.8,0.8,0.8]),..
		void2=[],..
		void3=[],..
		doc=list()))
	scs_m_1.objs(1)=scicos_block(..
			gui="ANDLOG_f",..
			graphics=scicos_graphics(..
				orig=[194,133],..
				sz=[60,60],..
				flip=%t,..
				theta=0,..
				exprs=[],..
				pin=[],..
				pout=9,..
				pein=[4;11],..
				peout=[],..
				gr_i=list(..
				["txt=[''LOGICAL'';'' '';'' AND ''];";
				"xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'');"],8),..
				id="",..
				in_implicit=[],..
				out_implicit="E"),..
			model=scicos_model(..
				sim="andlog",..
				in=[],..
				in2=[],..
				intyp=1,..
				out=1,..
				out2=[],..
				outtyp=1,..
				evtin=[1;1],..
				evtout=[],..
				state=[],..
				dstate=[],..
				odstate=list(),..
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
	scs_m_1.objs(2)=scicos_block(..
			gui="CLKIN_f",..
			graphics=scicos_graphics(..
				orig=[149,287],..
				sz=[20,20],..
				flip=%t,..
				theta=0,..
				exprs="1",..
				pin=[],..
				pout=[],..
				pein=[],..
				peout=4,..
				gr_i=list(" ",8),..
				id="",..
				in_implicit=[],..
				out_implicit=[]),..
			model=scicos_model(..
				sim="input",..
				in=[],..
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
				rpar=[],..
				ipar=1,..
				opar=list(),..
				blocktype="d",..
				firing=-1,..
				dep_ut=[%f,%f],..
				label="",..
				nzcross=0,..
				nmode=0,..
				equations=list()),..
			doc=list())
	scs_m_1.objs(3)=scicos_block(..
			gui="CLKOUT_f",..
			graphics=scicos_graphics(..
				orig=[450,83],..
				sz=[20,20],..
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
	scs_m_1.objs(4)=scicos_link(..
			xx=[169;214;214],..
			yy=[297;297;198.71],..
			id="drawlink",..
			thick=[0,0],..
			ct=[5,-1],..
			from=[2,1],..
			to=[1,1])
	scs_m_1.objs(5)=scicos_block(..
			gui="CLKIN_f",..
			graphics=scicos_graphics(..
				orig=[141,330],..
				sz=[20,20],..
				flip=%t,..
				theta=0,..
				exprs="2",..
				pin=[],..
				pout=[],..
				pein=[],..
				peout=6,..
				gr_i=list(" ",8),..
				id="",..
				in_implicit=[],..
				out_implicit=[]),..
			model=scicos_model(..
				sim="input",..
				in=[],..
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
				rpar=[],..
				ipar=2,..
				opar=list(),..
				blocktype="d",..
				firing=-1,..
				dep_ut=[%f,%f],..
				label="",..
				nzcross=0,..
				nmode=0,..
				equations=list()),..
			doc=list())
	scs_m_1.objs(6)=scicos_link(..
			xx=[161;234;234],..
			yy=[340;340;275.78],..
			id="drawlink",..
			thick=[0,0],..
			ct=[5,-1],..
			from=[5,1],..
			to=[10,1])
	scs_m_1.objs(7)=scicos_block(..
			gui="IFTHEL_f",..
			graphics=scicos_graphics(..
				orig=[331,137],..
				sz=[60,60],..
				flip=%t,..
				theta=0,..
				exprs=["1";"1"],..
				pin=9,..
				pout=[],..
				pein=12,..
				peout=[8;0],..
				gr_i=list(..
				["txt=[''If in>0'';'' '';'' then    else''];";
				"xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'');"],8),..
				id="",..
				in_implicit="E",..
				out_implicit=[]),..
			model=scicos_model(..
				sim=list("ifthel",-1),..
				in=1,..
				in2=1,..
				intyp=-1,..
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
				blocktype="l",..
				firing=[-1,-1],..
				dep_ut=[%t,%f],..
				label="",..
				nzcross=1,..
				nmode=1,..
				equations=list()),..
			doc=list())
	scs_m_1.objs(8)=scicos_link(..
			xx=[351;351;450],..
			yy=[131.29;93;93],..
			id="drawlink",..
			thick=[0,0],..
			ct=[5,-1],..
			from=[7,1],..
			to=[3,1])
	scs_m_1.objs(9)=scicos_link(..
			xx=[262.57;322.43],..
			yy=[163;167],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[1,1],..
			to=[7,1])
	scs_m_1.objs(10)=scicos_block(..
			gui="CLKSPLIT_f",..
			graphics=scicos_graphics(..
				orig=[234;275.78348],..
				sz=[0.3333333,0.3333333],..
				flip=%t,..
				theta=0,..
				exprs=[],..
				pin=[],..
				pout=[],..
				pein=6,..
				peout=[11;12],..
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
	scs_m_1.objs(11)=scicos_link(..
			xx=[234;234],..
			yy=[275.78;198.71],..
			id="drawlink",..
			thick=[0,0],..
			ct=[5,-1],..
			from=[10,1],..
			to=[1,2])
	scs_m_1.objs(12)=scicos_link(..
			xx=[234;361;361],..
			yy=[275.78;275.78;202.71],..
			id="drawlink",..
			thick=[0,0],..
			ct=[5,-1],..
			from=[10,2],..
			to=[7,1])
	scs_m.objs(15)=scicos_block(..
		gui="ANDBLK",..
		graphics=scicos_graphics(..
				orig=[233.73039,318.74407],..
				sz=[40,40],..
				flip=%t,..
				theta=0,..
				exprs=[],..
				pin=[],..
				pout=[],..
				pein=[19;16],..
				peout=17,..
				gr_i=list("xstringb(orig(1),orig(2),''ANDBLK'',sz(1),sz(2),''fill'')",8),..
				id="",..
				in_implicit=[],..
				out_implicit=[]),..
		model=scicos_model(..
				sim="csuper",..
				in=[],..
				in2=[],..
				intyp=1,..
				out=[],..
				out2=[],..
				outtyp=1,..
				evtin=[1;1],..
				evtout=1,..
				state=[],..
				dstate=[],..
				odstate=list(),..
				rpar=scs_m_1,..
				ipar=[],..
				opar=list(),..
				blocktype="h",..
				firing=%f,..
				dep_ut=[%f,%f],..
				label="",..
				nzcross=0,..
				nmode=0,..
				equations=list()),..
		doc=list())
	scs_m.objs(16)=scicos_link(..
			xx=[259.98293;260.39705],..
			yy=[372.50232;364.45835],..
			id="drawlink",..
			thick=[0,0],..
			ct=[5,-1],..
			from=[2,1,0],..
			to=[15,2,1])
	scs_m.objs(17)=scicos_link(..
			xx=[253.73039;253.72572],..
			yy=[313.02978;309.29537],..
			id="drawlink",..
			thick=[0,0],..
			ct=[5,-1],..
			from=[15,1,0],..
			to=[41,1,1])
	scs_m_1=scicos_diagram(..
		version="scicos4.2",..
		props=scicos_params(..
		wpar=[600,450,0,0,600,450],..
		Title=["EDGE_TRIGGER","./"],..
		tol=[0.0001;0.000001;1.000E-10;100001;0;0;0],..
		tf=30,..
		context=" ",..
		void1=[],..
		options=tlist(["scsopt","3D","Background","Link","ID","Cmap"],list(%t,33),[8,1],[1,5],..
		list([5,1],[4,1]),[0.8,0.8,0.8]),..
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
				exprs="1",..
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
				ipar=1,..
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
				intyp=-1,..
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
	scs_m.objs(18)=scicos_block(..
		gui="EDGE_TRIGGER",..
		graphics=scicos_graphics(..
				orig=[133.90637,385.342],..
				sz=[60,40],..
				flip=%t,..
				theta=0,..
				exprs=[],..
				pin=26,..
				pout=[],..
				pein=[],..
				peout=19,..
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
	scs_m.objs(19)=scicos_link(..
			xx=[163.90637;163.90637;247.06372],..
			yy=[379.62771;364.45835;364.45835],..
			id="drawlink",..
			thick=[0,0],..
			ct=[5,-1],..
			from=[18,1,0],..
			to=[15,1,1])
	scs_m.objs(20)=scicos_block(..
		gui="IN_f",..
		graphics=scicos_graphics(..
				orig=[79.594811,395.47647],..
				sz=[20,20],..
				flip=%t,..
				theta=0,..
				exprs="2",..
				pin=[],..
				pout=23,..
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
	scs_m_1=scicos_diagram(..
		version="scicos4.2",..
		props=scicos_params(..
		wpar=[600,450,0,0,600,450],..
		Title=["Extract_Activation","./"],..
		tol=[0.0001;0.000001;1.000E-10;100001;0;0;0],..
		tf=30,..
		context=" ",..
		void1=[],..
		options=tlist(["scsopt","3D","Background","Link","ID","Cmap"],list(%t,33),[8,1],[1,5],..
		list([5,1],[4,1]),[0.8,0.8,0.8]),..
		void2=[],..
		void3=[],..
		doc=list()))
	scs_m_1.objs(1)=scicos_block(..
			gui="IFTHEL_f",..
			graphics=scicos_graphics(..
				orig=[150.65045,143.82208],..
				sz=[60,60],..
				flip=%t,..
				theta=0,..
				exprs=["0";"0"],..
				pin=6,..
				pout=[],..
				pein=[],..
				peout=[3;4],..
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
				out2=[],..
				outtyp=1,..
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
	scs_m_1.objs(2)=scicos_block(..
			gui="CLKSOMV_f",..
			graphics=scicos_graphics(..
				orig=[169.82143,96.146231],..
				sz=[16.666667,16.666667],..
				flip=%t,..
				theta=0,..
				exprs=[],..
				pin=[],..
				pout=[],..
				pein=[3;4;0],..
				peout=8,..
				gr_i=list(..
				["rx=sz(1)*p/2;ry=sz(2)/2";
				"xsegs(orig(1)+rx*[1/2.3 1;2-1/2.3 1],orig(2)+ry*[1 2-1/2.3;1,1/2.3],style=0)"],8),..
				id="",..
				in_implicit=[],..
				out_implicit=[]),..
			model=scicos_model(..
				sim="sum",..
				in=[],..
				in2=[],..
				intyp=1,..
				out=[],..
				out2=[],..
				outtyp=1,..
				evtin=[1;1;1],..
				evtout=1,..
				state=[],..
				dstate=[],..
				odstate=list(),..
				rpar=[],..
				ipar=[],..
				opar=list(),..
				blocktype="d",..
				firing=-1,..
				dep_ut=[%f,%f],..
				label="",..
				nzcross=0,..
				nmode=0,..
				equations=list()),..
			doc=list())
	scs_m_1.objs(3)=scicos_link(..
			xx=[170.65045;170.65045;150.04302;150.04302;169.82143],..
			yy=[138.10779;128.235;128.235;104.47956;104.47956],..
			id="drawlink",..
			thick=[0,0],..
			ct=[5,-1],..
			from=[1,1,0],..
			to=[2,1,1])
	scs_m_1.objs(4)=scicos_link(..
			xx=[190.65045;190.65045;178.15476],..
			yy=[138.10779;111.55729;112.8129],..
			id="drawlink",..
			thick=[0,0],..
			ct=[5,-1],..
			from=[1,2,0],..
			to=[2,2,1])
	scs_m_1.objs(5)=scicos_block(..
			gui="IN_f",..
			graphics=scicos_graphics(..
				orig=[102.07902,163.82208],..
				sz=[20,20],..
				flip=%t,..
				theta=0,..
				exprs="1",..
				pin=[],..
				pout=6,..
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
				intyp=-1,..
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
	scs_m_1.objs(6)=scicos_link(..
			xx=[122.07902;142.07902],..
			yy=[173.82208;173.82208],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[5,1,0],..
			to=[1,1,1])
	scs_m_1.objs(7)=scicos_block(..
			gui="CLKOUTV_f",..
			graphics=scicos_graphics(..
				orig=[168.15476,38.527183],..
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
			xx=[178.15476;178.15476],..
			yy=[98.527183;68.527183],..
			id="drawlink",..
			thick=[0,0],..
			ct=[5,-1],..
			from=[2,1,0],..
			to=[7,1,1])
	scs_m.objs(21)=scicos_block(..
		gui="Extract_Activation",..
		graphics=scicos_graphics(..
				orig=[239.82193,456.57677],..
				sz=[60,40],..
				flip=%t,..
				theta=0,..
				exprs=[],..
				pin=31,..
				pout=[],..
				pein=[],..
				peout=22,..
				gr_i=list(..
				"xstringb(orig(1),orig(2),[''Extract'';''Activation''],sz(1),sz(2),''fill'')",8),..
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
	scs_m.objs(22)=scicos_link(..
			xx=[269.82193;269.98293],..
			yy=[450.86248;443.93089],..
			id="drawlink",..
			thick=[0,0],..
			ct=[5,-1],..
			from=[21,1,0],..
			to=[2,1,1])
	scs_m.objs(23)=scicos_link(..
			xx=[99.594811;110.25582],..
			yy=[405.47647;405.42077],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[20,1,0],..
			to=[25,1,1])
	scs_m.objs(24)=scicos_block(..
		gui="SUM_f",..
		graphics=scicos_graphics(..
				orig=[200.5252,469.13173],..
				sz=[16.666667,16.666667],..
				flip=%t,..
				theta=0,..
				exprs=[],..
				pin=[27;0;30],..
				pout=31,..
				pein=[],..
				peout=[],..
				gr_i=list(..
				["rx=sz(1)*p/2;ry=sz(2)/2";
				"xsegs(orig(1)+rx*[1/2.3 1;2-1/2.3 1],orig(2)+ry*[1 2-1/2.3;1,1/2 .3],style=0)"],8),..
				id="",..
				in_implicit=["E";"E";"E"],..
				out_implicit="E"),..
		model=scicos_model(..
				sim=list("plusblk",2),..
				in=[-1;-1;-1],..
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
	scs_m.objs(25)=scicos_block(..
		gui="SPLIT_f",..
		graphics=scicos_graphics(..
				orig=[110.25582;405.42077],..
				sz=[0.3333333,0.3333333],..
				flip=%t,..
				theta=0,..
				exprs=[],..
				pin=23,..
				pout=[26;27],..
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
	scs_m.objs(26)=scicos_link(..
			xx=[110.25582;114.33667;125.33494],..
			yy=[405.42077;405.39945;405.342],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[25,1,0],..
			to=[18,1,1])
	scs_m.objs(27)=scicos_link(..
			xx=[110.25582;110.25582;208.85853],..
			yy=[405.42077;469.13173;469.13173],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[25,2,0],..
			to=[24,1,1])
	scs_m.objs(28)=scicos_block(..
		gui="SPLIT_f",..
		graphics=scicos_graphics(..
				orig=[222.54128;408.2166],..
				sz=[0.3333333,0.3333333],..
				flip=%t,..
				theta=0,..
				exprs=[],..
				pin=9,..
				pout=[29;30],..
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
	scs_m.objs(29)=scicos_link(..
			xx=[222.54128;231.4115],..
			yy=[408.2166;408.2166],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[28,1,0],..
			to=[2,1,1])
	scs_m.objs(30)=scicos_link(..
			xx=[222.54128;222.54128;208.85853;208.85853],..
			yy=[408.2166;453.0015;453.0015;485.7984],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[28,2,0],..
			to=[24,3,1])
	scs_m.objs(31)=scicos_link(..
			xx=[219.57282;231.2505],..
			yy=[477.46506;476.57677],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[24,1,0],..
			to=[21,1,1])
	scs_m.objs(32)=scicos_block(..
		gui="SELECT_m",..
		graphics=scicos_graphics(..
				orig=[298.86371,253.57321],..
				sz=[40,40],..
				flip=%t,..
				theta=0,..
				exprs=["5";"2";"1"],..
				pin=[33;40],..
				pout=34,..
				pein=[43;44],..
				peout=[],..
				gr_i=list("xstringb(orig(1),orig(2),''Selector'',sz(1),sz(2),''fill'');",8),..
				id="",..
				in_implicit=["E";"E"],..
				out_implicit="E"),..
		model=scicos_model(..
				sim=list("selector_m",4),..
				in=[-1;-1],..
				in2=[-2;-2],..
				intyp=[5;5],..
				out=-1,..
				out2=-2,..
				outtyp=5,..
				evtin=[1;1],..
				evtout=[],..
				state=[],..
				dstate=1,..
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
	scs_m.objs(33)=scicos_link(..
			xx=[282.29299;290.29229],..
			yy=[280.24498;280.23987],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[4,1,0],..
			to=[32,1,1])
	scs_m.objs(34)=scicos_link(..
			xx=[347.43514;357.57328;357.57328],..
			yy=[273.57321;273.57321;280.83282],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[32,1,0],..
			to=[35,1,1])
	scs_m.objs(35)=scicos_block(..
		gui="SPLIT_f",..
		graphics=scicos_graphics(..
				orig=[357.57328,280.83282],..
				sz=[0.3333333,0.3333333],..
				flip=%t,..
				theta=0,..
				exprs=[],..
				pin=34,..
				pout=[36;37],..
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
	scs_m.objs(36)=scicos_link(..
			xx=[357.57328;357.57328;364.66964],..
			yy=[280.83282;329.46812;329.46812],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[35,1,0],..
			to=[7,1,1])
	scs_m.objs(37)=scicos_link(..
			xx=[357.57328;376.4669],..
			yy=[280.83282;280.83282],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[35,2,0],..
			to=[14,1,1])
	scs_m.objs(38)=scicos_block(..
		gui="SPLIT_f",..
		graphics=scicos_graphics(..
				orig=[140.34523;273.49157],..
				sz=[0.3333333,0.3333333],..
				flip=%t,..
				theta=0,..
				exprs=[],..
				pin=6,..
				pout=[39;40],..
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
	scs_m.objs(39)=scicos_link(..
			xx=[140.34523;144.31759],..
			yy=[273.49157;273.57832],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[38,1,0],..
			to=[3,2,1])
	scs_m.objs(40)=scicos_link(..
			xx=[140.34523;140.34523;290.29229;290.29229],..
			yy=[273.49157;247.70767;247.70767;266.90654],..
			id="drawlink",..
			thick=[0,0],..
			ct=[1,1],..
			from=[38,2,0],..
			to=[32,2,1])
	scs_m.objs(41)=scicos_block(..
		gui="CLKSPLIT_f",..
		graphics=scicos_graphics(..
				orig=[253.72572;309.29537],..
				sz=[0.3333333,0.3333333],..
				flip=%t,..
				theta=0,..
				exprs=[],..
				pin=[],..
				pout=[],..
				pein=17,..
				peout=[42;43],..
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
	scs_m.objs(42)=scicos_link(..
			xx=[253.72572;253.72156],..
			yy=[309.29537;305.95927],..
			id="drawlink",..
			thick=[0,0],..
			ct=[5,-1],..
			from=[41,1,0],..
			to=[4,1,1])
	scs_m.objs(43)=scicos_link(..
			xx=[253.72572;312.19705;312.19705],..
			yy=[309.29537;309.29537;299.28749],..
			id="drawlink",..
			thick=[0,0],..
			ct=[5,-1],..
			from=[41,2,0],..
			to=[32,1,1])
	scs_m.objs(44)=scicos_link(..
			xx=[279.98293;279.98293;325.53038;325.53038],..
			yy=[372.50232;315.89455;315.89455;299.28749],..
			id="drawlink",..
			thick=[0,0],..
			ct=[5,-1],..
			from=[2,2,0],..
			to=[32,2,1])
	model=scicos_model()
    	model.sim='csuper'
   	model.in=[1;1;1]
   	model.in2=[1;1;1]
   	model.out=[1;1]
   	model.out2=[1;1]
   	model.intyp=[5 1 1]
    	model.outtyp=[5 5]
    	model.blocktype='h'
    	model.firing=%f
    	model.dep_ut=[%t %f]
    	model.rpar=scs_m
        gr_i=['[x,y,typ]=standard_inputs(o) ';
              'dd=sz(1)/8,de=5.5*sz(1)/8';
              'if ~exists(''%zoom'') then %zoom=1, end;'
              'txt=''D'';'
              'rectstr=stringbox(txt,orig(1)+dd,y(1)-4,0,1,1);'
              'w=(rectstr(1,3)-rectstr(1,2))*%zoom;'
              'h=(rectstr(2,2)-rectstr(2,4))*%zoom;'
              'xstringb(orig(1)+dd,y(1)-4,txt,w,h,''fill'')';
              'txt=''clk'';'
              'rectstr=stringbox(txt,orig(1)+dd,y(2)-4,0,1,1);'
              'w=(rectstr(1,3)-rectstr(1,2))*%zoom;'
              'h=(rectstr(2,2)-rectstr(2,4))*%zoom;'
              'xstringb(orig(1)+dd,y(2)-4,txt,w,h,''fill'')';
              'txt=''en'';'
              'rectstr=stringbox(txt,orig(1)+dd,y(3)-4,0,1,1);'
              'w=(rectstr(1,3)-rectstr(1,2))*%zoom;'
              'h=(rectstr(2,2)-rectstr(2,4))*%zoom;'
              'xstringb(orig(1)+dd,y(3)-4,txt,w,h,''fill'')';
              '[x,y,typ]=standard_outputs(o) ';
              'txt=''Q'';'
              'rectstr=stringbox(txt,orig(1)+de,y(1)-4,0,1,1);'
              'w=(rectstr(1,3)-rectstr(1,2))*%zoom;'
              'h=(rectstr(2,2)-rectstr(2,4))*%zoom;'
              'xstringb(orig(1)+de,y(1)-4,txt,w,h,''fill'')';
              'txt=''!Q'';'
              'rectstr=stringbox(txt,orig(1)+4.5*dd,y(2)-4,0,1,1);'
              'w=(rectstr(1,3)-rectstr(1,2))*%zoom;'
              'h=(rectstr(2,2)-rectstr(2,4))*%zoom;'
              'xstringb(orig(1)+4.5*dd,y(2)-4,txt,w,h,''fill'')';
              'txt=''D FLIP-FLOP'';'
              'style=5;'
              'rectstr=stringbox(txt,orig(1),orig(2),0,style,1);'
              'w=(rectstr(1,3)-rectstr(1,2))*%zoom;'
              'h=(rectstr(2,2)-rectstr(2,4))*%zoom;'
              'xstringb(orig(1)+sz(1)/2-w/2,orig(2)-h-4,txt,w,h,''fill'');'
              '//e=gce();'
              '//e.font_style=style;']
    	x=standard_define([2 3],model,[],gr_i,'DFLIPFLOP');
  end
endfunction

