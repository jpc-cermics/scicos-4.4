function [x,y,typ]=ASSERT(job,arg1,arg2)
//Generated from SuperBlock on 25 octobre 2013
//Modified by hand, Alan, Enpc 2013

  function blk_draw(sz,orig,orient,label)
    orig=arg1.graphics.orig;
    sz=arg1.graphics.sz;
    orient=arg1.graphics.flip;
    
    xrect(orig(1),orig(2)+sz(2),sz(1),sz(2));
    rx=sz(1)*0.65;
    ry=sz(2)*0.3;
    r=0.5
    xarc(orig(1)+0.5*sz(1),
         orig(2)+0.8*sz(2),
         0.3*sz(1),
         0.6*sz(2),
         0,
         360*64,thickness=2);
    xx=[orig(1)+rx orig(1)+rx;
        orig(1)+0.55*sz(1) orig(1)+0.75*sz(1)];
    yy=[orig(2)+ry orig(2)+ry ;
        orig(2)+sz(2)/2 orig(2)+0.6*sz(2)];
    xpoly(xx,yy,thickness=1);
    xpoly([orig(1);orig(1)+sz(1)*0.5],[orig(2)+sz(2)/2;orig(2)+sz(2)/2],thickness=1)
  endfunction
  
  x=[];y=[];typ=[];
  select job
   case 'plot' then
     standard_draw(arg1,%f);
   case 'getinputs' then
     [x,y,typ]=standard_inputs(arg1)
   case 'getoutputs' then
     x=[];y=[];typ=[]
   case 'getorigin' then
     [x,y]=standard_origin(arg1)
   case 'set' then
     y=needcompile
     typ=list()
     graphics=arg1.graphics;
     exprs=graphics.exprs
     Btitre="Set Assertion block parameters"
     Exprs0=["opar";"ipar";"zc"]
     Bitems=["Callback expression when assertion fails(if any)";
             "Behavior when assertion fails(0:print message, 1: stop, 2: end, 3: block error)";
             "Use zero crossing(0:no, 1:yes)" ]
     ss=list("str",1,"mat",1,"mat",1)
     scicos_context=hash(10)
     x=arg1
     ok=%f
  while ~ok do
    [ok,scicos_context.opar,scicos_context.ipar,scicos_context.zc,exprs]=getvalue(Btitre,Bitems,ss,exprs)
    scicos_context.ip2=1
    if scicos_context.opar.equal[emptystr()] || isempty(scicos_context.opar) then
      scicos_context.opar=[]
    else
      scicos_context.opar=int8([ascii(scicos_context.opar),0])
    end
    if ~ok then return;end
     %scicos_context=scicos_context
     sblock=x.model.rpar
     [%scicos_context,ierr]=script2var(sblock.props.context,%scicos_context)
     if ierr<>0 then
       message(catenate(lasterror()));
       ok=%f
     else
       [sblock,%w,needcompile2,ok]=do_eval(sblock,list(),%scicos_context);
       if ok then
          y=max(2,needcompile,needcompile2)
          x.graphics.exprs=exprs
          x.model.rpar=sblock
          break
       else
         message(catenate(lasterror()));
       end
     end
  end
  case 'define' then
    x_0=scicos_model();
    x_0.in2=     [   -2 ]
    x_0.evtout= []
    x_0.evtin= []
    x_0.intyp=     [   -1 ]
    x_0.sim=     [ "csuper" ]
    x_0.in=     [   -1 ]
    x_0.out2= []
    x_0.out= []
    x_0.blocktype=     [ "h" ]
    x_0.ipar=     [   1 ]
    model=x_0;clear('x_0');
    model.rpar=ASSERT_diagram();
    zc=0
    opar=emptystr()
    ipar=2
    ip2=1
    exprs=[opar;sci2exp(ipar,0);sci2exp(zc,0)]
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2,1],model,exprs,gr_i,'ASSERT')
  end
endfunction

function scs_m= ASSERT_diagram()
// internal diagram of block ASSERT
    x_0=scicos_diagram();
     x_1=scicos_params();
      x_1.wpar=      [    56.7782,   156.5762,   517.1211,   504.7190,   630.0000 ,...
    478.0000,    10.0000,    56.5000,   630.0000,   479.0000 ,...
    465.0000,   191.0000,     1.4000,   610.0000,   365.0000 ]
      x_1.title=      [ "ASSERT" ]
     x_0.props=x_1;clear('x_1');
     x_1=list();
      x_2=IN_f('define');
       x_2.graphics.pout=       [   3 ]
       x_2.graphics.sz=       [   20,   20 ]
       x_2.graphics.orig=       [   151.4286,   380.0000 ]
      x_1(1)=x_2;clear('x_2');
      x_2=ABS_VALUEi('define');
       x_2.graphics.exprs=       [ "zc" ]
       x_2.graphics.pout=       [   6 ]
       x_2.graphics.sz=       [   40,   40 ]
       x_2.graphics.pein= []
       x_2.graphics.in_implicit=       [ "E" ]
       x_2.graphics.orig=       [   230,   340 ]
       x_2.graphics.pin=       [   3 ]
       x_2.graphics.out_implicit=       [ "E" ]
       x_2.graphics.peout= []
      x_1(2)=x_2;clear('x_2');
      x_2=scicos_link();
       x_2.from=       [   1,   1,   0 ]
       x_2.xx=       [   171.4286;
           201.4286;
           201.4286;
           221.4286 ]
       x_2.yy=       [   390;
           390;
           360;
           360 ]
       x_2.to=       [   2,   1,   1 ]
      x_1(3)=x_2;clear('x_2');
      x_2=generic_block3('define');
       x_2.graphics.exprs=       [ "assertion";
         "4";
         "mat_create(0,2)";
         "1";
         "mat_create(0,2)";
         "1";
         "1";
         "mat_create(0,0)";
         "mat_create(0,0)";
         "mat_create(0,0)";
         "list()";
         "mat_create(0,0)";
         "[ipar ip2]";
         "list(opar)";
         "0";
         "0";
         "mat_create(0,0)";
         "n";
         "n" ]
       x_2.graphics.pout= []
       x_2.graphics.sz=       [   40,   40 ]
       x_2.graphics.pein=       [   7 ]
       x_2.graphics.orig=       [   370,   250 ]
       x_2.graphics.pin= []
       x_2.graphics.peout= []
       x_2.graphics.gr_i(1)="xstringb(orig(1),orig(2),''ASSERTION'',sz(1),sz(2),''fill'');"
      x_1(4)=x_2;clear('x_2');
      x_2=IFTHEL_f('define');
       x_2.graphics.exprs=       [ "0";
         "zc" ]
       x_2.graphics.pout= []
       x_2.graphics.sz=       [   60,   60 ]
       x_2.graphics.pein= []
       x_2.graphics.in_implicit=       [ "E" ]
       x_2.graphics.orig=       [   330,   330 ]
       x_2.graphics.pin=       [   6 ]
       x_2.graphics.peout=       [   0;
           7 ]
      x_1(5)=x_2;clear('x_2');
      x_2=scicos_link();
       x_2.from=       [   2,   1,   0 ]
       x_2.xx=       [   278.5714;
           321.4286 ]
       x_2.yy=       [   360;
           360 ]
       x_2.to=       [   5,   1,   1 ]
      x_1(6)=x_2;clear('x_2');
      x_2=scicos_link();
       x_2.from=       [   5,   2,   0 ]
       x_2.xx=       [   370;
           370;
           390;
           390 ]
       x_2.yy=       [   324.2857;
           310.0000;
           310.0000;
           295.7143 ]
       x_2.ct=       [    5,   -1 ]
       x_2.to=       [   4,   1,   1 ]
      x_1(7)=x_2;clear('x_2');
     x_0.objs=x_1;clear('x_1');
    scs_m=x_0;clear('x_0');
endfunction
