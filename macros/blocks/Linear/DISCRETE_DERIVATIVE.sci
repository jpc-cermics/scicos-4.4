function [x,y,typ]=DISCRETE_DERIVATIVE(job,arg1,arg2)
  
  x=[]
  y=[]
  typ=[]
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
    graphics=arg1.graphics
    exprs=graphics.exprs
    model=arg1.model
    while %t do
      [ok,K,init,satur,maxp,minp,inh,exprs]=getvalue('Set Discrete Derivative block parameters',..
         ['Gain (K)';
          'Initial Condition (K*u/T)';
          'With saturation (1:yes, 0:no)';
          'Upper limit';
          'Lower limit';
          'Inherit (no:0, yes:1)'],..
          list('vec',1,'mat',[-1 -1],'vec',1,'vec',1,'vec',1,'vec',1),exprs)
      if ~ok then break,end
      
      [xt,str]=do_get_type(init)
      //if (xt==2 || xt==9) then
      if (xt~=1) then
        message("type "+str+" ("+string(xt)+") not allowed for Initial Condition.")
        ok=%f;
      end
      
      if ok then
        select xt
          case 1
            K=double(K)
            maxp=double(maxp)
            minp=double(minp)
          case 3
            K=int32(K)
            maxp=int32(maxp)
            minp=int32(minp)
          case 4
            K=int16(K)
            maxp=int16(maxp)
            minp=int16(minp)
          case 5
            K=int8(K)
            maxp=int8(maxp)
            minp=int8(minp)
          case 6
            K=uint32(K)
            maxp=uint32(maxp)
            minp=uint32(minp)
          case 7
            K=uint16(K)
            maxp=uint16(maxp)
            minp=uint16(minp)
          case 8
            K=uint8(K)
            maxp=uint8(maxp)
            minp=uint8(minp)
        end
      
        if size(init,"*")==1 then 
          out=[-1,-2]
        else
          out=[size(init,1) size(init,2)]
        end
        in=out
      
        if satur<>0 then satur=1, end
      
        [model,graphics,ok]=set_io(model,graphics,list(in,xt),list(out,xt),ones(1-inh,1),[])
      end
      
      if ok then
        model.odstate=list(init)
        model.ipar=[satur]
        model.opar=list(K,maxp,minp)
        graphics.exprs=exprs
        x.graphics=graphics;x.model=model
        break
      end
    end
      
   case 'compile' then
    model=arg1
    if size(model.odstate(1),'*')==1 then
      if model.in*model.in2>1 then
        odstate=model.odstate(1)
        model.odstate=list(ones(model.in,model.in2)*model.odstate(1))
      end
    end
    //model.sim(1)="derivz_"+getNameExt(model.intyp)
    x=model
    
   case 'define' then
    t1=0
    K=1
    init=0
    satur=0
    maxp=1
    minp=-1
    inh=0
    exprs=string([K;init;satur;maxp;minp;inh])
    model=scicos_model()
    model.sim=list('derivz_'+getNameExt(1),4)
    model.in=-1
    model.in2=-2
    model.intyp=1
    model.out=-1
    model.out2=-2
    model.outtyp=1
    model.evtin=1-inh
    model.dstate=t1
    model.odstate=list(init)
    model.ipar=[satur]
    model.opar=list(K,maxp,minp)
    model.blocktype='d'
    model.dep_ut=[%t %f]
    gr_i=['xstringb(orig(1),orig(2),[''K(z-1)'';''   Tz''],sz(1),sz(2),''fill'')';
          'xpoly([orig(1)+.1*sz(1),orig(1)+.9*sz(1)],[1,1]*(orig(2)+sz(2)/2))']  
    x=standard_define([2 2],model,exprs,gr_i,'DISCRETE_DERIVATIVE')
  end 
endfunction

