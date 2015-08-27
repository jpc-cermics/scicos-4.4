function [x,y,typ]=GAINBLK(job,arg1,arg2)
// Copyright INRIA
//

  function blk_draw(sz,orig,orient,label)
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
  endfunction

  x=[];y=[];typ=[];
  select job
   case 'plot' then
    // no frame
    standard_draw(arg1,%f);
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
    if size(exprs,'*') <= 1 then exprs=[exprs;sci2exp(0)];end // compatibility
    if size(exprs,'*') <= 2 then exprs=[exprs;sci2exp(0);sci2exp(0)];end // compatibility
    title= 'Set gain block parameters';
    values_description=	['Gain';
		    'Do On Overflow:\n 0=Nothing\n 1=Saturate\n 2=Error';
		    'Mutliply:\n 0= *\n 1= .*'];
    while %t do
      [ok,gain,over,mtype,exprs]=getvalue(title,values_description,...
					  list('mat',[-1,-1],'vec',1,'vec',1),exprs);
      if ~ok then break,end
      if isempty(gain) then
	message('Gain must have at least one element')
      else
	mtype = min(max(int(mtype),mtype,0),1);
        model.ipar(1)=over // temporary storage removed in job compile
	model.ipar(2)=mtype // temporary storage removed in job compile
        model.opar(1)=gain
        ot=do_get_type(gain)
        if ot==1 then
          ot=-1
        elseif ot==2 then
	  message("Complex type is not supported");
	  ok=%f;
        end
        if ok then
	  if mtype == 0 then
	    // *
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
	  else
	    // .*
	    [out,in]=size(gain)
	    if out*in<>1 then
	      [model,graphics,ok]=set_io(model,graphics,...
					 list([out,in],ot),...
					 list([out,in],ot),[],[])
	    else
	      [model,graphics,ok]=set_io(model,graphics,...
					 list([-1,-2],ot),...
					 list([-1,-2],ot),[],[])
	    end

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
    over=model.ipar(1);
    mtype=model.ipar(2);
    model.ipar=[];
    if ot==1 then
      model.rpar=double(gain(:));
      model.opar=list();
      select mtype
       case 0 then supp3=''
       case 1 then supp3='_tt'
      else supp3=''
      end
      model.sim=list('gainblk'+supp3,4);
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
	 case 0 then supp2='n'
	 case 1 then supp2='s'
	 case 2 then supp2='e'
	else supp2='n'
	end
	select mtype
	 case 0 then supp3=''
	 case 1 then supp3=''; // to be implemented '_tt'
	else supp3=''
	end
      end
      model.sim=list('gainblk_'+supp1+supp2+supp3,4);
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
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2 2],model,exprs,gr_i,'GAINBLK');
  end
endfunction
