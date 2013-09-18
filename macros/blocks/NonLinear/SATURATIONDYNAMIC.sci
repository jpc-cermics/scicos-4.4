function [x,y,typ]=SATURATIONDYNAMIC(job,arg1,arg2)

  function blk_draw(o,sz,orig,orient,label)
    [x,y,typ]=standard_inputs(o)
    dd=sz(1)*0.05;dd1=dd;dd2=6*sz(1)/8
    if ~arg1.graphics.flip then
      dd=6*sz(1)/8,dd1=-dd1,dd2=sz(1)*0.05
    end
    xstringb(orig(1)+dd,y(1)-sz(2)/16,'up',sz(1)/6,sz(2)/8,'fill');
    xstringb(orig(1)+dd2,y(2)-sz(2)/20,'y',sz(1)/6,sz(2)/10,'fill');
    xstringb(orig(1)+dd,y(2)-sz(2)/20,'u',sz(1)/6,sz(2)/10,'fill');
    xstringb(orig(1)+dd,y(3)-sz(2)/18,'lo',sz(1)/6,sz(2)/9,'fill');
    if ~arg1.graphics.flip then
      xx=orig(1)+dd1+[1/5;1/2-1/5;1/2+1/5;4/5]*sz(1);
    else
      xx=orig(1)+dd1+[4/5;1/2+1/5;1/2-1/5;1/5]*sz(1);
    end
    yy=[y(1);y(1);y(3);y(3)];
    xpoly(xx,yy,type='lines',thickness=2);
  endfunction

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
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    while %t do
      [ok,ot,zeroc,exprs]=getvalue('Set Saturation Dynamic parameters',..
                                   ['Output type (-1=inherit 1=double 3=int32 4=int16 ...)';..
                                    'Zero crossing (0:no, 1:yes)'],list('vec',1,'vec',1),exprs)
      if ~ok then break,end
      if ot==2 then ot=1;end
      if (ot>9|ot==0|ot<-1) then
        message("Output type "+string(ot)+" is not supported.");
        ok=%f;
      end
      if ok then
        [model,graphics,ok]=set_io(model,graphics,...
                                   list([model.in model.in2],model.intyp),...
                                   list([model.out model.out2],ot),...
                                   [],[])
        if ok then
          if zeroc<>0 then 
            model.nzcross=2
            model.nmode=1
          else
            model.nzcross=0
            model.nmode=0
          end
          graphics.exprs=exprs;
          x.graphics=graphics;x.model=model
          break
        end
      end
    end
   case 'compile'
    model=arg1;
    if model.intyp==2 then
      error("Complex data type not implemented.");
    else
      model.sim(1)="satur_dyn_"+getNameExt(model.intyp(1))+"_"+getNameExt(model.outtyp)
    end
    x=model;
   case 'define' then
    model=scicos_model()
    model.sim=list('satur_dyn',4)
    model.in=[1;1;1]
    model.in2=[1;1;1]
    model.intyp=[-1;-1;-1]
    model.nzcross=2
    model.nmode=1
    model.out=1
    model.out2=1
    model.outtyp=-1
    model.blocktype='c'
    model.dep_ut=[%t %f]
    exprs=[string(model.outtyp);string(model.nmode)]
    gr_i="blk_draw(o,sz,orig,orient,model.label)";
    x=standard_define([2 3],model,exprs,gr_i,'SATURATIONDYNAMIC');
  end
endfunction
