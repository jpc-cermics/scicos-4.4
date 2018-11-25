function [x,y,typ]=PID(job,arg1,arg2)
  // Copyright INRIA
  // contains a diagram inside

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
     // be sure that exprs is now in block
     [x,changed]= PID('upgrade',arg1);
     if changed then y = max(y,2);end
     exprs= x.graphics.exprs;
     newpar=list();
     x.model.rpar.objs(3).exprs=exprs(1)
     x.model.rpar.objs(5).exprs=exprs(2)
     x.model.rpar.objs(6).exprs=exprs(3)

     p_old=x.model.rpar.objs(3).model.rpar;
     i_old=x.model.rpar.objs(5).model.rpar;
     d_old=x.model.rpar.objs(6).model.rpar;
     
     while %t do
      [ok,p,i,d,exprs0]=getvalue('Set PID parameters',
				 ['Proportional';'Integral';'Derivation'],
				 list('vec',-1,'vec',-1,'vec',-1),exprs)
      if ~ok then break,end;
      x.graphics.exprs=exprs0;
      x.model.rpar.objs(3).exprs=exprs0(1)
      x.model.rpar.objs(5).exprs=exprs0(2)
      x.model.rpar.objs(6).exprs=exprs0(3)
      x.model.rpar.objs(3).model.rpar=p;
      x.model.rpar.objs(5).model.rpar=i;
      x.model.rpar.objs(6).model.rpar=d;
      break
    end
    
    if ~(p_old==p & i_old==i & d_old==d) then
      newpar(size(newpar)+1)=3
      newpar(size(newpar)+1)=5
      newpar(size(newpar)+1)=6
      y=max(y,2);
    end
    typ=newpar
    resume(needcompile=y);
   case 'define' then
     // define the block 
     scs_m= PID_diagram("1","1","1");
     model=scicos_model(sim='csuper', in=-1, in2=-2, out=-1,
			out2=-2, intyp=1, outtyp=1, blocktype='h', firing=%f,
			dep_ut=[%f %f], ipar=1, rpar=scs_m);
     gr_i=['xstringb(orig(1),orig(2),[''PID''],sz(1),sz(2),''fill'');'];
     x=standard_define([2 2],model,[],gr_i,'PID');
     exprs =[x.model.rpar.objs(3).graphics.exprs(1);
	     x.model.rpar.objs(5).graphics.exprs(1);
	     x.model.rpar.objs(6).graphics.exprs(1)];
     x.graphics.exprs = exprs;
     
   case 'upgrade' then
     // upgrade if necessary
     x = arg1;
     exprs =[x.model.rpar.objs(3).graphics.exprs(1);
	     x.model.rpar.objs(5).graphics.exprs(1);
	     x.model.rpar.objs(6).graphics.exprs(1)];
     if ~arg1.graphics.iskey['exprs'] || isempty(arg1.graphics.exprs) then
       y=%t;
       x.graphics.exprs = exprs;
     else 
       y=%f;
     end
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
  
  scs_m.objs(7)=scicos_link(xx=[303.80;309.73],yy=[203.11;203.11], from=[5,1,0], to=[1,1,1])
  scs_m.objs(8)=scicos_link(xx=[303.80;310.46],yy=[155.45;155.45], from=[6,1,0], to=[4,1,1])

  scs_m.objs(9)=scicos_link(xx=[366.57;382.50;382.50;398.42],yy=[203;203;202;202], from=[1,1,0], to=[2,2,1])
  scs_m.objs(10)=scicos_link(xx=[369.57;384.00;384.00;398.42],yy=[255;255;212;212],from=[3,1,0],to=[2,1,1])
  scs_m.objs(11)=scicos_link(xx=[367.57;383.00;383.00;398.42],yy=[155;155;192;192], from=[4,1,0], to=[2,3,1])
  
  blk = SPLIT_f('define');
  blk.graphics.orig=[234.704;203.11733];
  blk.graphics.sz=[40,40];
  blk.graphics.pin=16;
  blk.graphics.pout=[13;14];
  scs_m.objs(12)=blk;

  scs_m.objs(13)=scicos_link(xx=[234.70;246.66], yy=[203.11;203.11], from=[12,1,0], to=[5,1,1])
  scs_m.objs(14)=scicos_link(xx=[234.70;234.70;246.66],yy=[203.11;155.45;155.45],from=[12,2,0], to=[6,1,1])

  blk = SPLIT_f('define');
  blk.graphics.orig=[233.97067;203.11733];
  blk.graphics.sz=[40,40];
  blk.graphics.pin=21;
  blk.graphics.pout=[16;17];
  scs_m.objs(15)=blk;
  
  scs_m.objs(16)=scicos_link(xx=[233.97;234.70],yy=[203.11;203.11], from=[15,1,0], to=[12,1,1])
  scs_m.objs(17)=scicos_link(xx=[233.97;233.97;312.66],yy=[203.11;255.91;255.91],from=[15,2,0], to=[3,1,1])

  blk = OUT_f('define');
  blk.graphics.orig=[456.5421,192.85067],...
  blk.graphics.sz=[20,20];
  blk.graphics.exprs="1",...
  blk.graphics.pin=19,...
  scs_m.objs(18) = blk;
    
  scs_m.objs(19)=scicos_link(xx=[436.54;456.54], yy=[202.85;202.85], from=[2,1,0], to=[18,1,1])

  blk = IN_f('define');
  blk.graphics.orig=[193.97,193.11];
  blk.graphics.sz=[20,20];
  blk.graphics.exprs="1";
  blk.graphics.pin=[];
  blk.graphics.pout=21;
  scs_m.objs(20) = blk;
  
  scs_m.objs(21)=scicos_link(xx=[213.97;233.97], yy=[203.11;203.11], from=[20,1,0], to=[15,1,1])
  
endfunction
