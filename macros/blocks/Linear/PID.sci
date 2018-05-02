function [x,y,typ]=PID(job,arg1,arg2)
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
     y=acquire('needcompile',def=0);
    newpar=list();
    exprs=m2s(zeros(3,1));
    xx1=arg1.model.rpar.objs(3)
    exprs(1)=xx1.graphics.exprs(1)
    p_old=xx1.model.rpar
    xx2=arg1.model.rpar.objs(5)
    exprs(2)=xx2.graphics.exprs(1)
    i_old=xx2.model.rpar
    xx3=arg1.model.rpar.objs(6)
    exprs(3)=xx3.graphics.exprs(1)
    d_old=xx3.model.rpar
    y=0
    while %t do
      [ok,p,i,d,exprs0]=getvalue('Set PID parameters',..
				 ['Proportional';'Integral';'Derivation'],list('vec',-1,'vec',-1,'vec',-1),exprs)
      if ~ok then break,end
      if ok then
	xx1.graphics.exprs=exprs0(1)
	xx1.model.rpar=p
	xx2.graphics.exprs=exprs0(2)
	xx2.model.rpar=i
	xx3.graphics.exprs=exprs0(3)
	xx3.model.rpar=d
	arg1.model.rpar.objs(3)=xx1
	arg1.model.rpar.objs(5)=xx2
	arg1.model.rpar.objs(6)=xx3	
	break
      end
    end

    if ~(p_old==p & i_old==i & d_old==d) then
      newpar(size(newpar)+1)=3
      newpar(size(newpar)+1)=5
      newpar(size(newpar)+1)=6
      y=max(y,2);
    end
    x=arg1
    typ=newpar
   case 'define' then
    scs_m=scicos_diagram(..
			 version="scicos4.2",..
			 props=scicos_params(..
					     wpar=[600,450,0,0,600,450],..
					     Title=["PID"],..
					     tol=[0.0001,0.000001,1.000E-10,100001,0,0],..
					     tf=100000,..
					     context=" ",..
					     void1=[],..
					     options=scicos_options(),..
					     void2=[],..
					     void3=[],..
					     doc=list()))
    scs_m.objs(1)=scicos_block(..
			       gui="INTEGRAL_m",..
			       graphics=scicos_graphics(..
						  orig=[318.304,183.11733],..
						  sz=[40,40],..
						  flip=%t,..
						  theta=0,..
						  exprs=["0";"0";"0";"1";"-1"],..
						  pin=7,..
						  pout=9,..
						  pein=[],..
						  peout=[],..
						  gr_i=list(..
						  ["thick=xget(''thickness'')";
		    "pat=xget(''pattern'')";
		    "fnt=xget(''font'')";
		    "xpoly(orig(1)+[0.7;0.62;0.549;0.44;0.364;0.291]*sz(1),orig(2)+[0.947;0.947;0.884;0.321;0.255;0.255]*sz(2),type=''lines'')";
		    "xset(''thickness'',thick)";
		    "xset(''pattern'',pat)";
		    "xset(''font'',fnt(1),fnt(2))"],8),..
						  id="1/s",..
						  in_implicit="E",..
						  out_implicit="E"),..
			       model=scicos_model(..
						  sim=list("integral_func",4),..
						  in=1,..
						  in2=1,..
						  intyp=1,..
						  out=1,..
						  out2=1,..
						  outtyp=1,..
						  evtin=[],..
						  evtout=[],..
						  state=0,..
						  dstate=[],..
						  odstate=list(),..
						  rpar=[],..
						  ipar=[],..
						  opar=list(),..
						  blocktype="c",..
						  firing=[],..
						  dep_ut=[%f,%t],..
						  label="",..
						  nzcross=0,..
						  nmode=0,..
						  equations=list()),..
			       doc=list())
    scs_m.objs(2)=scicos_block(..
			       gui="SUMMATION",..
			       graphics=scicos_graphics(..
						  orig=[387.97067,172.85067],..
						  sz=[40,60],..
						  flip=%t,..
						  theta=0,..
						  exprs=["1";"[1;1;1]"],..
						  pin=[10;9;11],..
						  pout=19,..
						  pein=[],..
						  peout=[],..
						  gr_i=list(..
						  ["[x,y,typ]=standard_inputs(o) ";
		    "dd=sz(1)/8,de=0,";
		    "if ~arg1.graphics.flip then dd=6*sz(1)/8,de=-sz(1)/8,end";
		    "for k=1:size(x,''*'')";
		    "if size(sgn,1)>1 then";
		    "  if sgn(k)>0 then";
		    "    xstring(orig(1)+dd,y(k)-4,''+'')";
		    "  else";
		    "    xstring(orig(1)+dd,y(k)-4,''-'')";
		    "  end";
		    "end";
		    "end";
		    "xx=sz(1)*[.8 .4 0.75 .4 .8]+orig(1)+de";
		    "yy=sz(2)*[.8 .8 .5 .2 .2]+orig(2)";
		    "xpoly(xx,yy,type=''lines'')"],8),..
						  id="",..
						  in_implicit=["E";"E";"E"],..
						  out_implicit="E"),..
			       model=scicos_model(..
						  sim=list("summation",4),..
						  in=[-1;-1;-1],..
						  in2=[-2;-2;-2],..
						  intyp=[1;1;1],..
						  out=-1,..
						  out2=-2,..
						  outtyp=1,..
						  evtin=[],..
						  evtout=[],..
						  state=[],..
						  dstate=[],..
						  odstate=list(),..
						  rpar=[],..
						  ipar=[1;1;1],..
						  opar=list(),..
						  blocktype="c",..
						  firing=[],..
						  dep_ut=[%t,%f],..
						  label="",..
						  nzcross=0,..
						  nmode=0,..
						  equations=list()),..
			       doc=list())
    scs_m.objs(3)=scicos_block(..
			       gui="GAINBLK",..
			       graphics=scicos_graphics(..
						  orig=[321.23733,235.91733],..
						  sz=[40,40],..
						  flip=%t,..
						  theta=0,..
						  exprs="1",..
						  pin=17,..
						  pout=10,..
						  pein=[],..
						  peout=[],..
						  gr_i=list("",8),..
						  id="",..
						  in_implicit="E",..
						  out_implicit="E"),..
			       model=scicos_model(..
						  sim=list("gainblk",4),..
						  in=-1,..
						  in2=-2,..
						  intyp=1,..
						  out=-1,..
						  out2=-2,..
						  outtyp=1,..
						  evtin=[],..
						  evtout=[],..
						  state=[],..
						  dstate=[],..
						  odstate=list(),..
						  rpar=1,..
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
    scs_m.objs(4)=scicos_block(..
			       gui="DERIV",..
			       graphics=scicos_graphics(..
						  orig=[319.03733,135.45067],..
						  sz=[40,40],..
						  flip=%t,..
						  theta=0,..
						  exprs=[],..
						  pin=8,..
						  pout=11,..
						  pein=[],..
						  peout=[],..
						  gr_i=list("xstringb(orig(1),orig(2),''  du/dt  '',sz(1),sz(2),''fill'');",8),..
						  id="s",..
						  in_implicit="E",..
						  out_implicit="E"),..
			       model=scicos_model(..
						  sim=list("deriv",4),..
						  in=-1,..
						  in2=-2,..
						  intyp=1,..
						  out=-1,..
						  out2=-2,..
						  outtyp=1,..
						  evtin=[],..
						  evtout=[],..
						  state=[],..
						  dstate=[],..
						  odstate=list(),..
						  rpar=[],..
						  ipar=[],..
						  opar=list(),..
						  blocktype="x",..
						  firing=[],..
						  dep_ut=[%t,%f],..
						  label="",..
						  nzcross=0,..
						  nmode=0,..
						  equations=list()),..
			       doc=list())
    scs_m.objs(5)=scicos_block(..
			       gui="GAINBLK",..
			       graphics=scicos_graphics(..
						  orig=[255.23733,183.11733],..
						  sz=[40,40],..
						  flip=%t,..
						  theta=0,..
						  exprs="1",..
						  pin=13,..
						  pout=7,..
						  pein=[],..
						  peout=[],..
						  gr_i=list("",8),..
						  id="",..
						  in_implicit="E",..
						  out_implicit="E"),..
			       model=scicos_model(..
						  sim=list("gainblk",4),..
						  in=-1,..
						  in2=-2,..
						  intyp=1,..
						  out=-1,..
						  out2=-2,..
						  outtyp=1,..
						  evtin=[],..
						  evtout=[],..
						  state=[],..
						  dstate=[],..
						  odstate=list(),..
						  rpar=1,..
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
    scs_m.objs(6)=scicos_block(..
			       gui="GAINBLK",..
			       graphics=scicos_graphics(..
						  orig=[255.23733,135.45067],..
						  sz=[40,40],..
						  flip=%t,..
						  theta=0,..
						  exprs="1",..
						  pin=14,..
						  pout=8,..
						  pein=[],..
						  peout=[],..
						  gr_i=list("",8),..
						  id="",..
						  in_implicit="E",..
						  out_implicit="E"),..
			       model=scicos_model(..
						  sim=list("gainblk",4),..
						  in=-1,..
						  in2=-2,..
						  intyp=1,..
						  out=-1,..
						  out2=-2,..
						  outtyp=1,..
						  evtin=[],..
						  evtout=[],..
						  state=[],..
						  dstate=[],..
						  odstate=list(),..
						  rpar=1,..
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
			      xx=[303.80876;309.73257],..
			      yy=[203.11733;203.11733],..
			      id="drawlink",..
			      thick=[0,0],..
			      ct=[1,1],..
			      from=[5,1,0],..
			      to=[1,1,1])
    scs_m.objs(8)=scicos_link(..
			      xx=[303.80876;310.4659],..
			      yy=[155.45067;155.45067],..
			      id="drawlink",..
			      thick=[0,0],..
			      ct=[1,1],..
			      from=[6,1,0],..
			      to=[4,1,1])
    scs_m.objs(9)=scicos_link(..
			      xx=[366.87543;379.39924],..
			      yy=[203.11733;202.85067],..
			      id="drawlink",..
			      thick=[0,0],..
			      ct=[1,1],..
			      from=[1,1,0],..
			      to=[2,2,1])
    scs_m.objs(10)=scicos_link(..
			       xx=[369.80876;379.39924;379.39924],..
			       yy=[255.91733;255.91733;217.85067],..
			       id="drawlink",..
			       thick=[0,0],..
			       ct=[1,1],..
			       from=[3,1,0],..
			       to=[2,1,1])
    scs_m.objs(11)=scicos_link(..
			       xx=[367.60876;379.39924;379.39924],..
			       yy=[155.45067;155.45067;187.85067],..
			       id="drawlink",..
			       thick=[0,0],..
			       ct=[1,1],..
			       from=[4,1,0],..
			       to=[2,3,1])
    scs_m.objs(12)=scicos_block(..
				gui="SPLIT_f",..
				graphics=scicos_graphics(..
						  orig=[234.704;203.11733],..
						  sz=[0.3333333,0.3333333],..
						  flip=%t,..
						  theta=0,..
						  exprs=[],..
						  pin=16,..
						  pout=[13;14],..
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
    scs_m.objs(13)=scicos_link(..
			       xx=[234.704;246.6659],..
			       yy=[203.11733;203.11733],..
			       id="drawlink",..
			       thick=[0,0],..
			       ct=[1,1],..
			       from=[12,1,0],..
			       to=[5,1,1])
    scs_m.objs(14)=scicos_link(..
			       xx=[234.704;234.704;246.6659],..
			       yy=[203.11733;155.45067;155.45067],..
			       id="drawlink",..
			       thick=[0,0],..
			       ct=[1,1],..
			       from=[12,2,0],..
			       to=[6,1,1])
    scs_m.objs(15)=scicos_block(..
				gui="SPLIT_f",..
				graphics=scicos_graphics(..
						  orig=[233.97067;203.11733],..
						  sz=[0.3333333,0.3333333],..
						  flip=%t,..
						  theta=0,..
						  exprs=[],..
						  pin=21,..
						  pout=[16;17],..
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
    scs_m.objs(16)=scicos_link(..
			       xx=[233.97067;234.704],..
			       yy=[203.11733;203.11733],..
			       id="drawlink",..
			       thick=[0,0],..
			       ct=[1,1],..
			       from=[15,1,0],..
			       to=[12,1,1])
    scs_m.objs(17)=scicos_link(..
			       xx=[233.97067;233.97067;312.6659],..
			       yy=[203.11733;255.91733;255.91733],..
			       id="drawlink",..
			       thick=[0,0],..
			       ct=[1,1],..
			       from=[15,2,0],..
			       to=[3,1,1])
    scs_m.objs(18)=scicos_block(..
				gui="OUT_f",..
				graphics=scicos_graphics(..
						  orig=[456.5421,192.85067],..
						  sz=[20,20],..
						  flip=%t,..
						  theta=0,..
						  exprs="1",..
						  pin=19,..
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
    scs_m.objs(19)=scicos_link(..
			       xx=[436.5421;456.5421],..
			       yy=[202.85067;202.85067],..
			       id="drawlink",..
			       thick=[0,0],..
			       ct=[1,1],..
			       from=[2,1,0],..
			       to=[18,1,1])
    scs_m.objs(20)=scicos_block(..
				gui="IN_f",..
				graphics=scicos_graphics(..
						  orig=[193.97067,193.11733],..
						  sz=[20,20],..
						  flip=%t,..
						  theta=0,..
						  exprs="1",..
						  pin=[],..
						  pout=21,..
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
    scs_m.objs(21)=scicos_link(..
			       xx=[213.97067;233.97067],..
			       yy=[203.11733;203.11733],..
			       id="drawlink",..
			       thick=[0,0],..
			       ct=[1,1],..
			       from=[20,1,0],..
			       to=[15,1,1])
    
    model=scicos_model()
    model.sim='csuper'
    model.in=-1
    model.in2=-2
    model.out=-1
    model.out2=-2
    model.intyp=1
    model.outtyp=1
    model.blocktype='h'
    model.firing=%f
    model.dep_ut=[%f %f]
    model.rpar=scs_m

    gr_i=['xstringb(orig(1),orig(2),[''PID''],sz(1),sz(2),''fill'');']
    x=standard_define([2 2],model,[],gr_i,'PID');
  end
endfunction
