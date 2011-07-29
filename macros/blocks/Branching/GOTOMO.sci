function [x,y,typ]=GOTOMO(job,arg1,arg2)
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
      x1=0
    end
    xpolys(xx,yy)
    xstringb(orig(1)+x1*sz(1),orig(2),tg,(1-x1)*sz(1),sz(2));

    xf=60
    yf=40
    nin=1;nout=0
		    
      // set port shape
      out=[0   -1/14
	   1/7 -1/14
	   1/7 1/14
	   0   1/14
	   0   -1/14]*diag([xf,yf])
      in= [-1/7  -1/14
	   0     -1/14
	   0      1/14
	   -1/7   1/14
	   -1/7  -1/14]*diag([xf,yf])
      dy=sz(2)/(nin+1)
      xset('pattern',default_color(1))
   if orient then  //standard orientation
      for k=1:nin
	xfpoly(in(:,1)+ones(5,1)*orig(1),..
	       in(:,2)+ones(5,1)*(orig(2)+sz(2)-dy*k),1)
      end
    else //tilded orientation
      for k=1:nin
	xfpoly(in(:,1)+ones(5,1)*(orig(1)+sz(1)+1/7*xf),..
	       in(:,2)+ones(5,1)*(orig(2)+sz(2)-dy*k),1)
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
      [ok,tag,tagvis,exprs]=getvalue('Set parameters',..
		['Tag';'Tag Visibility(1=Local 2=scoped 3= global)'],..
		    list('str',-1,'vec',1),exprs)
      if ~ok then break,end
      tagvis=int(tagvis)
      if ((tagvis<1)|(tagvis>3)) then
          message('Tag Visibility must be between 1 and 3');ok=%f;
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
    model.sim='gotomo'
    model.in=-1
    model.in2=-2
    model.intyp=[]
    model.out=[]
    model.out2=[]
    model.outtyp=1
    model.ipar=int(1)
    model.opar=list('A')
    model.blocktype='c'
    model.dep_ut=[%f %f]
    mo=modelica()
    mo.model='gotomo'
    mo.inputs='p'
    exprs=['A';sci2exp(1)]
    
    gr_i='';
    x=standard_define([1.5 1.5],model,exprs,gr_i,'GOTOMO');
    x.graphics.in_implicit=['I']
  end
endfunction
