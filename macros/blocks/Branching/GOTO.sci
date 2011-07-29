function [x,y,typ]=GOTO(job,arg1,arg2)
  x=[];y=[];typ=[]
  select job
   case 'plot' then
    pat=xget('pattern'); xset('pattern',default_color(0))
    orig=arg1.graphics.orig;
    sz=arg1.graphics.sz;
    orient=arg1.graphics.flip;
    tg=arg1.graphics.exprs(1);
    forma=['[','{','',']','}','']
    tg=forma(evstr(arg1.graphics.exprs(2)))+tg+forma(evstr(arg1.graphics.exprs(2))+3)
    if orient then
      xx=orig(1)+[0 1/8 1/4;1/4 1/2 1;1 1 1;1 1/2 1/4;1/4 1/8 0]'*sz(1);
      yy=orig(2)+[1/2 3/4 1 ;1 1 1;1 1/2 0;0 0 0;0 1/4 1/2]'*sz(2);
      x1=0
    else
      xx=orig(1)+[0 0 0;0 1/2 3/4;3/4 7/8 1;1 7/8 3/4;3/4 1/2 0]'*sz(1);
      yy=orig(2)+[0 1/2 1;1 1 1;1 3/4 1/2;1/2 1/4 0;0 0 0]'*sz(2);
      x1=1/4
    end
    xpolys(xx,yy)
    xstringb(orig(1)+x1*sz(1),orig(2),tg,(1-x1)*sz(1),sz(2));

    xf=60
    yf=40
    nin=1;nout=0
    if size(o.graphics.exprs,'*')==2 then
      BS='1'
    else
      BS=o.graphics.exprs(3)
    end
    col=evstr(BS)
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
	       out(:,2)+ones(4,1)*(orig(2)+sz(2)-dy*k),col)
      end

      dy=sz(2)/(nin+1)
      for k=1:nin
	xfpoly(in(:,1)+ones(4,1)*orig(1),..
	       in(:,2)+ones(4,1)*(orig(2)+sz(2)-dy*k),col)
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
	       out(:,2)+ones(4,1)*(orig(2)+sz(2)-dy*k),col)
      end
      dy=sz(2)/(nin+1)
      for k=1:nin
	xfpoly(in(:,1)+ones(4,1)*(orig(1)+sz(1))+1,..
	       in(:,2)+ones(4,1)*(orig(2)+sz(2)-dy*k),col)
      end
    end
    xset('pattern',pat)
    // ------- Identification ---------------------------
    ident = o.graphics.id
    // draw Identification
    if ~isempty(ident) & ident <> ''  then
      if ~exists('%zoom') then %zoom=1, end
      fz=2*%zoom*4
      xstring(orig(1)+sz(1)/2,orig(2),ident,posx='center',posy='up',size=fz);
    end
  //** ----- Identification End -----------------------------

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
    if size(exprs,'*')==2 then  //compatibility
      exprs(1)=sci2exp(exprs(1),0)
      exprs(3)='1';
    end 
    while %t do
      [ok,tag,tagvis,BS,exprs]=getvalue('Set parameters',..
		['Tag';'Tag Visibility(1=Local 2=scoped 3= global)';'Input Type (1=Signal 2=Bus)'],..
		    list('gen',-1,'vec',1,'vec',1),exprs)
      if ~ok then break,end
      tagvis=int(tagvis)
      if ((tagvis<1)|(tagvis>3)) then
	message('Tag Visibility must be between 1 and 3');ok=%f;
      end
      if BS==1 then graphics.in_implicit='E';
      elseif BS==2 then graphics.in_implicit='B';
      else message('Input Type must be 1 or 2');ok=%f;
      end	
      if ok then 
	 if ((model.ipar<>tagvis)|(model.opar<>list(tag))) then needcompile=4;y=needcompile,end
	 graphics.exprs=exprs;
	 model.opar=list(tag)
	 model.ipar=tagvis
	 x.model=model
	 x.graphics=graphics
	 arg1=x
	 break
      end
    end
    resume(needcompile)
   case 'define' then
    model=scicos_model()
    model.sim='goto'
    model.in=-1
    model.in2=-2
    model.intyp=-1
    model.out=[]
    model.out2=[]
    model.outtyp=1
    model.ipar=int(1)
    model.opar=list('A')
    model.blocktype='c'
    model.dep_ut=[%f %f]
    
    exprs=[sci2exp("A") ;sci2exp(1); sci2exp(1)]
    
    gr_i='';
    x=standard_define([1.5 1.5],model,exprs,gr_i,'GOTO');
    x.graphics.id="Goto"
  end
endfunction
