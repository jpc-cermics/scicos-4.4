function [x,y,typ]=GAINBLK(job,arg1,arg2)
// Copyright INRIA
  x=[];y=[];typ=[];
  select job
   case 'plot' then //** ----------- PLOT -------------------
    pat=xget('pattern'); xset('pattern',default_color(0))
    orig=arg1.graphics.orig;
    sz=arg1.graphics.sz;
    orient=arg1.graphics.flip;
    if length(arg1.graphics.exprs(1))>6 then
      gain=part(arg1.graphics.exprs(1),1:4)+'..'
    else 
      gain=arg1.graphics.exprs(1);
    end
    ll=length(arg1.graphics.exprs(1))
    a=ll/(1+ll)/2
    if orient then
      xx=orig(1)+[0 1 0 0]*sz(1);
      yy=orig(2)+[0 1/2 1 0]*sz(2);
      x1=0
    else
      xx=orig(1)+[0   1 1 0]*sz(1);
      yy=orig(2)+[1/2 0 1 1/2]*sz(2);
      x1=1-2*a
    end
    gr_i=arg1.graphics.gr_i;
    if type(gr_i,'short')=='l' then
      coli=gr_i(2);
      if ~isempty(coli) then
	xfpolys(xx',yy',coli);
      else
	xpoly(xx,yy,type='lines');
      end
    else
      xpoly(xx,yy,type='lines');
    end
    w=sz(1)*(4/5);
    hf=(1/3);
    //xrect(orig(1),orig(2)+sz(2)*(1-hf)/2+sz(2)*hf,w,hf*sz(2));
    xstringb(orig(1),orig(2)+sz(2)*(1-hf)/2,gain,w,hf*sz(2),'fill');
    xf=60
    yf=40
    nin=1;nout=1

    if orient then  //standard orientation
      
      // set port shape
      out=[0  -1/14
	   1/7 0
	   0   1/14
	   0  -1/14]*diag([xf,yf])
      in= [-1/7  -1/14
	   0    0
	   -1/7   1/14
	   -1/7  -1/14]*diag([xf,yf])
      dy=sz(2)/(nout+1)
      xset('pattern',default_color(1))
      for k=1:nout
	xfpoly(out(:,1)+ones(4,1)*(orig(1)+sz(1)),..
	       out(:,2)+ones(4,1)*(orig(2)+sz(2)-dy*k),1)
      end

      dy=sz(2)/(nin+1)
      for k=1:nin
	xfpoly(in(:,1)+ones(4,1)*orig(1),..
	       in(:,2)+ones(4,1)*(orig(2)+sz(2)-dy*k),1)
      end
    else //tilded orientation
      out=[0  -1/14
	   -1/7 0
	   0   1/14
	   0  -1/14]*diag([xf,yf])
      in= [1/7  -1/14
	   0    0
	   1/7   1/14
	   1/7  -1/14]*diag([xf,yf])
      dy=sz(2)/(nout+1)
      xset('pattern',default_color(1))
      for k=1:nout
	xfpoly(out(:,1)+ones(4,1)*orig(1)-1,..
	       out(:,2)+ones(4,1)*(orig(2)+sz(2)-dy*k),1)
      end
      dy=sz(2)/(nin+1)
      for k=1:nin
	xfpoly(in(:,1)+ones(4,1)*(orig(1)+sz(1))+1,..
	       in(:,2)+ones(4,1)*(orig(2)+sz(2)-dy*k),1)
      end
    end
    xset('pattern',pat)
    
    //** ------- Identification ---------------------------
    ident = o.graphics.id
    // draw Identification
    if ~isempty(ident) & ident <> ''  then
      if ~exists('%zoom') then %zoom=1, end
      fz=2*%zoom*4
      xstring(orig(1)+sz(1)/2,orig(2),ident,posx='center',posy='up',size=fz);
    end
    //** ----- Identification End -----------------------------
   case 'getinputs' then //** GET INPUTS 
    [x,y,typ]=standard_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=standard_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    if size(exprs,'*')==1 then exprs=[exprs;sci2exp(0)];end // compatibility
    while %t do
      [ok,gain,over,exprs]=getvalue('Set gain block parameters',..
				    ['Gain';..
		    'Do On Overflow(0=Nothing 1=Saturate 2=Error)'],..
				    list('mat',[-1,-1],'vec',1),exprs)
      if ~ok then break,end
      if isempty(gain) then
	message('Gain must have at least one element')
      else
        model.ipar=over // temporary storage removed in job compile
        model.opar(1)=gain
        ot=do_get_type(gain)
        if ot==1 then
          ot=-1
        elseif ot==2 then
	  message("Complex type is not supported");
	  ok=%f;
        end
        if ok then
	  [out,in]=size(gain)
	  if out*in<>1 then
	    [model,graphics,ok]=set_io(model,graphics,...
				       list([in,-1],ot),...
				       list([out,-1],ot),[],[])
	  else
	    [model,graphics,ok]=set_io(model,graphics,...
				       list([-1,-2],ot),...
				       list([-1,-2],ot),[],[])
	  end
        end
	if ok then
	  graphics.exprs=exprs
	  x.graphics=graphics;x.model=model
	  break
	end
      end
    end
    
   case 'compile' then
    model=arg1
    ot=model.intyp
    if isequal(model.opar,list()) then
      gain=model.rpar(1)  
    else
      gain=model.opar(1)
    end
    over=model.ipar
    model.ipar=[];
    if ot==1 then 
      model.rpar=double(gain(:));
      model.opar=list();
      model.sim=list('gainblk',4);
    else
      if ot==2 then
        error("Complex type is not supported");
      else
        select ot
	 case 3
          model.opar(1)=int32(model.opar(1))
          supp1='i32'
	 case 4
          model.opar(1)=int16(model.opar(1))
          supp1='i16'
	 case 5
          model.opar(1)=int8(model.opar(1))
          supp1='i8'
	 case 6
          model.opar(1)=uint32(model.opar(1))
          supp1='ui32'
	 case 7
          model.opar(1)=uint16(model.opar(1))
          supp1='ui16'
	 case 8
          model.opar(1)=uint8(model.opar(1))
          supp1='ui8'
        else
          error("Type "+string(ot)+" not supported.")
        end
        select over
	 case 0
          supp2='n'
	 case 1
          supp2='s'
	 case 2
          supp2='e'
        end
      end
      model.sim=list('gainblk_'+supp1+supp2,4)
    end
    x=model    

   case 'define' then
    gain=1
    in=-1;out=-1
    in2=-2;out2=-2
    model=scicos_model()
    model.sim=list('gainblk',4)
    model.in=in
    model.out=out
    model.in2=in2
    model.out2=out2
    model.rpar=gain
    model.blocktype='c'
    model.dep_ut=[%t %f]

    exprs=[strcat(sci2exp(gain))]
    gr_i=''
    x=standard_define([2 2],model,exprs,gr_i,'GAINBLK');
  end
endfunction
