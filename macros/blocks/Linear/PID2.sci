function [x,y,typ]=PID2(job,arg1,arg2)
//Generated from PID on 5-Jan-2009
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
  y=needcompile
  typ=list()
  graphics=arg1.graphics;
  exprs=graphics.exprs
  Btitre=..
    "Set PID parameters"
  Exprs0=..
    ["p";"i";"d"]
  Bitems=..
    ["Proportional";"Integral";"Derivative"]
  Ss=..
    list("pol",-1,"pol",-1,"pol",-1)
  scicos_context=struct()
     x=arg1
  ok=%f
  while ~ok do
    [ok,scicos_context.p,scicos_context.i,scicos_context.d,exprs]=getvalue(Btitre,Bitems,Ss,exprs)
    if ~ok then return;end
     %scicos_context=scicos_context
     sblock=x.model.rpar
     [%scicos_context,ierr]=script2var(sblock.props.context,%scicos_context)
     if ierr==0 then
       [sblock,%w,needcompile2,ok]=do_eval(sblock,list(),%scicos_context)
	  if ok then
          y=max(2,needcompile,needcompile2)
          x.graphics.exprs=exprs
          x.model.rpar=sblock
          break
	  end
     else
       message(lasterror())
	  ok=%f
     end
  end
case 'define' then
scs_m_1=scicos_diagram(..
        version="scicos4.3",..
        props=scicos_params(..
              wpar=[118.03352,562.90781,42.710669,379.75791,607,463,0,0,624,480,655,52,1.4],..
              Title=["PID","C:/Documents and Settings/ramin/Bureau/"],..
              tol=[0.0001,0.000001,1.000D-10,100001,0,0],..
              tf=100000,..
              context=" ",..
              void1=[],..
              options=tlist(["scsopt","3D","Background","Link","ID","Cmap"],list(%t,33),[8,1],[1,5],..
              list([5,1,2,1],[4,1,10,1]),[0.8,0.8,0.8]),..
              void2=[],..
              void3=[],..
              doc=list()))
scs_m_1.objs(1)=scicos_block(..
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
                         "txt=''1/s'';";
                         "style=5;";
                         "rectstr=stringbox(txt,orig(1),orig(2),0,style,1);";
                         "if ~exists(''%zoom'') then %zoom=1, end;";
                         "w=(rectstr(1,3)-rectstr(1,2))*%zoom;";
                         "h=(rectstr(2,2)-rectstr(2,4))*%zoom;";
                         "xstringb(orig(1)+sz(1)/2-w/2,orig(2)-h-4,txt,w,h,''fill'');";
                         "//e=gce();";
                         "//e.font_style=style;";
                         "xset(''thickness'',thick)";
                         "xset(''pattern'',pat)";
                         "xset(''font'',fnt(1),fnt(2))"],8),..
                         id="",..
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
scs_m_1.objs(2)=scicos_block(..
                gui="SUMMATION",..
                graphics=scicos_graphics(..
                         orig=[387.97067,172.85067],..
                         sz=[40,60],..
                         flip=%t,..
                         theta=0,..
                         exprs=["1";"[1;1;1]";"0"],..
                         pin=[10;9;11],..
                         pout=21,..
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
                         rpar=0,..
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
scs_m_1.objs(3)=scicos_block(..
                gui="GAINBLK",..
                graphics=scicos_graphics(..
                         orig=[321.23733,235.91733],..
                         sz=[40,40],..
                         flip=%t,..
                         theta=0,..
                         exprs=["p";"0"],..
                         pin=15,..
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
scs_m_1.objs(4)=scicos_block(..
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
                         gr_i=list(..
                         ["xstringb(orig(1),orig(2),'' du/dt   '',sz(1),sz(2),''fill'');";
                         "txt=''s'';";
                         "style=5;";
                         "rectstr=stringbox(txt,orig(1),orig(2),0,style,1);";
                         "if ~exists(''%zoom'') then %zoom=1, end;";
                         "w=(rectstr(1,3)-rectstr(1,2))*%zoom;";
                         "h=(rectstr(2,2)-rectstr(2,4))*%zoom;";
                         "xstringb(orig(1)+sz(1)/2-w/2,orig(2)-h-4,txt,w,h,''fill'');";
                         "//e=gce();";
                         "//e.font_style=style;"],8),..
                         id="",..
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
scs_m_1.objs(5)=scicos_block(..
                gui="GAINBLK",..
                graphics=scicos_graphics(..
                         orig=[255.23733,183.11733],..
                         sz=[40,40],..
                         flip=%t,..
                         theta=0,..
                         exprs=["i";"0"],..
                         pin=16,..
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
scs_m_1.objs(6)=scicos_block(..
                gui="GAINBLK",..
                graphics=scicos_graphics(..
                         orig=[255.23733,135.45067],..
                         sz=[40,40],..
                         flip=%t,..
                         theta=0,..
                         exprs=["d";"0"],..
                         pin=19,..
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
scs_m_1.objs(7)=scicos_link(..
                  xx=[303.80876;309.73257],..
                  yy=[203.11733;203.11733],..
                  id="drawlink",..
                  thick=[0,0],..
                  ct=[1,1],..
                  from=[5,1,0],..
                  to=[1,1,1])
scs_m_1.objs(8)=scicos_link(..
                  xx=[303.80876;310.4659],..
                  yy=[155.45067;155.45067],..
                  id="drawlink",..
                  thick=[0,0],..
                  ct=[1,1],..
                  from=[6,1,0],..
                  to=[4,1,1])
scs_m_1.objs(9)=scicos_link(..
                  xx=[366.87543;379.39924],..
                  yy=[203.11733;202.85067],..
                  id="drawlink",..
                  thick=[0,0],..
                  ct=[1,1],..
                  from=[1,1,0],..
                  to=[2,2,1])
scs_m_1.objs(10)=scicos_link(..
                   xx=[369.80876;379.39924;379.39924],..
                   yy=[255.91733;255.91733;217.85067],..
                   id="drawlink",..
                   thick=[0,0],..
                   ct=[1,1],..
                   from=[3,1,0],..
                   to=[2,1,1])
scs_m_1.objs(11)=scicos_link(..
                   xx=[367.60876;379.39924;379.39924],..
                   yy=[155.45067;155.45067;187.85067],..
                   id="drawlink",..
                   thick=[0,0],..
                   ct=[1,1],..
                   from=[4,1,0],..
                   to=[2,3,1])
scs_m_1.objs(12)=scicos_block(..
                 gui="IN_f",..
                 graphics=scicos_graphics(..
                          orig=[163.47373,182.47972],..
                          sz=[20,20],..
                          flip=%t,..
                          theta=0,..
                          exprs="1",..
                          pin=[],..
                          pout=13,..
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
                          out2=-2,..
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
scs_m_1.objs(13)=scicos_link(..
                   xx=[183.47373;213.31138;213.31138],..
                   yy=[192.47972;192.47972;192.67121],..
                   id="drawlink",..
                   thick=[0,0],..
                   ct=[1,1],..
                   from=[12,1,0],..
                   to=[17,1,1])
scs_m_1.objs(14)=scicos_block(..
                 gui="SPLIT_f",..
                 graphics=scicos_graphics(..
                          orig=[213.31138,203.11733],..
                          sz=[0.3333333,0.3333333],..
                          flip=%t,..
                          theta=0,..
                          exprs=[],..
                          pin=18,..
                          pout=[15;16],..
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
scs_m_1.objs(15)=scicos_link(..
                   xx=[213.31138;213.31138;312.6659],..
                   yy=[203.11733;255.91733;255.91733],..
                   id="drawlink",..
                   thick=[0,0],..
                   ct=[1,1],..
                   from=[14,1,0],..
                   to=[3,1,1])
scs_m_1.objs(16)=scicos_link(..
                   xx=[213.31138;246.6659],..
                   yy=[203.11733;203.11733],..
                   id="drawlink",..
                   thick=[0,0],..
                   ct=[1,1],..
                   from=[14,2,0],..
                   to=[5,1,1])
scs_m_1.objs(17)=scicos_block(..
                 gui="SPLIT_f",..
                 graphics=scicos_graphics(..
                          orig=[213.31138;192.67121],..
                          sz=[0.3333333,0.3333333],..
                          flip=%t,..
                          theta=0,..
                          exprs=[],..
                          pin=13,..
                          pout=[18;19],..
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
scs_m_1.objs(18)=scicos_link(..
                   xx=[213.31138;213.31138],..
                   yy=[192.67121;203.11733],..
                   id="drawlink",..
                   thick=[0,0],..
                   ct=[1,1],..
                   from=[17,1,0],..
                   to=[14,1,1])
scs_m_1.objs(19)=scicos_link(..
                   xx=[213.31138;213.31138;246.6659],..
                   yy=[192.67121;155.45067;155.45067],..
                   id="drawlink",..
                   thick=[0,0],..
                   ct=[1,1],..
                   from=[17,2,0],..
                   to=[6,1,1])
scs_m_1.objs(20)=scicos_block(..
                 gui="OUT_f",..
                 graphics=scicos_graphics(..
                          orig=[485.95262,192.67121],..
                          sz=[20,20],..
                          flip=%t,..
                          theta=0,..
                          exprs="1",..
                          pin=21,..
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
scs_m_1.objs(21)=scicos_link(..
                   xx=[436.5421;485.95262],..
                   yy=[202.85067;202.67121],..
                   id="drawlink",..
                   thick=[0,0],..
                   ct=[1,1],..
                   from=[2,1,0],..
                   to=[20,1,1])
  model=scicos_model()
  model.sim="csuper"
  model.in=-1
  model.in2=-2
  model.intyp=-1
  model.out=-1
  model.out2=-2
  model.outtyp=-1
  model.evtin=[]
  model.evtout=[]
  model.state=[]
  model.dstate=[]
  model.odstate=list()
  model.rpar=scs_m_1
  model.ipar=1
  model.opar=list()
  model.blocktype="h"
  model.firing=[]
  model.dep_ut=[%f,%f]
  model.label=""
  model.nzcross=0
  model.nmode=0
  model.equations=list()
  p=1
  i=2
  d=1
  exprs=[sci2exp(p,0)
	 sci2exp(i,0)
	 sci2exp(d,0) ]
  gr_i=list("xstringb(orig(1),orig(2),""PID"",sz(1),sz(2),''fill'');",8)
  x=standard_define([2,2],model,exprs,gr_i,'PID2');
end
endfunction
