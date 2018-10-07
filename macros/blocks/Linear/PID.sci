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
     exprs= arg1.graphics.exprs;
     newpar=list();
     exprs1=m2s(zeros(3,1));
     xx1=arg1.model.rpar.objs(3)
     exprs1(1)=xx1.graphics.exprs(1)
     p_old=xx1.model.rpar;
     xx2=arg1.model.rpar.objs(5)
     exprs1(2)=xx2.graphics.exprs(1)
     i_old=xx2.model.rpar;
     xx3=arg1.model.rpar.objs(6)
     exprs1(3)=xx3.graphics.exprs(1)
     d_old=xx3.model.rpar;
     if isempty(exprs) then
       exprs = exprs1;
     end
     y=0;
    while %t do
      [ok,p,i,d,exprs0]=getvalue('Set PID parameters',..
				 ['Proportional';'Integral';'Derivation'],list('vec',-1,'vec',-1,'vec',-1),exprs)
      if ~ok then break,end;
      arg1.graphics.exprs=exprs;
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
    
    if ~(p_old==p & i_old==i & d_old==d) then
      newpar(size(newpar)+1)=3
      newpar(size(newpar)+1)=5
      newpar(size(newpar)+1)=6
      y=max(y,2);
    end
    x=arg1
    typ=newpar
   case 'define' then
     scs_m= PID_diagram("1","1","1");
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
     gr_i=['xstringb(orig(1),orig(2),[''PID''],sz(1),sz(2),''fill'');'];
     x=standard_define([2 2],model,[],gr_i,'PID');
   case 'exprs'
     // for do_api_save build and return exprs
     exprs= arg1.graphics.exprs;
     if isempty(exprs) then
       exprs=m2s(zeros(3,1));
       xx1=arg1.model.rpar.objs(3)
       exprs(1)=xx1.graphics.exprs(1)
       xx2=arg1.model.rpar.objs(5)
       exprs(2)=xx2.graphics.exprs(1)
       xx3=arg1.model.rpar.objs(6)
       exprs(3)=xx3.graphics.exprs(1)
     end
     x=exprs;
  end
endfunction

function scs_m= PID_diagram(pv,iv,dv)
  scs_m=scicos_diagram();

  blk = INTEGRAL_m('define');
  blk.graphics.orig=[318,183];
  blk.graphics.sz=[40,40];
  blk.graphics.exprs=["0";"0";"0";"1";"-1"];
  blk.graphics.pin=7;
  blk.graphics.pout=9;
  scs_m.objs(1)=blk;
  
  blk = SUMMATION('define');
  blk.graphics.orig=[398,182];
  blk.graphics.sz=[40,40];
  blk.graphics.exprs=["1";"[1;1;1]"];
  blk.graphics.pin=[10;9;11];
  blk.graphics.pout=19;
  blk.model.in=[-1;-1;-1];
  blk.model.in2=[-2;-2;-2];
  blk.model.intyp=[1;1;1];
  blk.model.out=-1;
  blk.model.out2=-2;
  blk.model.outtyp=1;
  blk.model.ipar=[1;1;1];
  scs_m.objs(2)=blk;

  blk = GAINBLK('define');
  blk.graphics.orig=[321,235];
  blk.graphics.sz=[40,40];
  blk.graphics.exprs=[pv;"0"]
  blk.graphics.pin=17;
  blk.graphics.pout=10;
  scs_m.objs(3)=blk;

  blk = DERIV('define');
  blk.graphics.orig=[319,135];
  blk.graphics.sz=[40,40];
  blk.graphics.exprs=[];
  blk.graphics.pin=8;
  blk.graphics.pout=11;
  scs_m.objs(4)=blk;
  
  blk = GAINBLK('define');
  blk.graphics.orig=[255,183];
  blk.graphics.sz=[40,40];
  blk.graphics.exprs=[iv;"0"];
  blk.graphics.pin=13;
  blk.graphics.pout=7;
  scs_m.objs(5)=blk;

  blk = GAINBLK('define');
  blk.graphics.orig=[255,135];
  blk.graphics.sz=[40,40];
  blk.graphics.exprs=[dv;"0"];
  blk.graphics.pin=14;
  blk.graphics.pout=8;
  scs_m.objs(6)=blk;
  
  scs_m.objs(7)=scicos_link(xx=[303.80876;309.73257], yy=[203.11733;203.11733], from=[5,1,0], to=[1,1,1])
  scs_m.objs(8)=scicos_link(xx=[303.80876;310.4659],yy=[155.45067;155.45067], from=[6,1,0], to=[4,1,1])

  scs_m.objs(9)=scicos_link(xx=[366.5714;382.5000;382.5000;398.4286],yy=[203;203;202;202], from=[1,1,0], to=[2,2,1])
  scs_m.objs(10)=scicos_link(xx=[369.5714;384.0000;384.0000;398.4286],yy=[255;255;212;212],from=[3,1,0],to=[2,1,1])
  scs_m.objs(11)=scicos_link(xx=[367.5714;383.0000;383.0000;398.4286],yy=[155;155;192;192], from=[4,1,0], to=[2,3,1])
  
  blk = SPLIT_f('define');
  blk.graphics.orig=[234.704;203.11733];
  blk.graphics.sz=[40,40];
  blk.graphics.pin=16;
  blk.graphics.pout=[13;14];
  scs_m.objs(12)=blk;

  scs_m.objs(13)=scicos_link(xx=[234.704;246.6659], yy=[203.11733;203.11733], from=[12,1,0], to=[5,1,1])
  scs_m.objs(14)=scicos_link(xx=[234.704;234.704;246.6659],yy=[203.11733;155.45067;155.45067],from=[12,2,0], to=[6,1,1])

  blk = SPLIT_f('define');
  blk.graphics.orig=[233.97067;203.11733];
  blk.graphics.sz=[40,40];
  blk.graphics.pin=21;
  blk.graphics.pout=[16;17];
  scs_m.objs(15)=blk;
  
  scs_m.objs(16)=scicos_link(xx=[233.97067;234.704],yy=[203.11733;203.11733], from=[15,1,0], to=[12,1,1])
  scs_m.objs(17)=scicos_link(xx=[233.97067;233.97067;312.6659],yy=[203.11733;255.91733;255.91733],from=[15,2,0], to=[3,1,1])

  blk = OUT_f('define');
  blk.graphics.orig=[456.5421,192.85067],...
  blk.graphics.sz=[20,20];
  blk.graphics.exprs="1",...
  blk.graphics.pin=19,...
  scs_m.objs(18) = blk;
    
  scs_m.objs(19)=scicos_link(xx=[436.5421;456.5421], yy=[202.85067;202.85067], from=[2,1,0], to=[18,1,1])

  blk = IN_f('define');
  blk.graphics.orig=[193.97067,193.11733];
  blk.graphics.sz=[20,20];
  blk.graphics.exprs="1";
  blk.graphics.pin=[];
  blk.graphics.pout=21;
  scs_m.objs(20) = blk;
  
  scs_m.objs(21)=scicos_link(xx=[213.97067;233.97067], yy=[203.11733;203.11733], from=[20,1,0], to=[15,1,1])
  
endfunction
