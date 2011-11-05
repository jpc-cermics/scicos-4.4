function [x,y,typ]=CLKGOTO(job,arg1,arg2)
// Copyright INRIA

  function blk_draw(sz,orig,orient,label)
    orig=arg1.graphics.orig;sz=arg1.graphics.sz;orient=arg1.graphics.flip;
    rul=['[','{','',']','}','']
    prt=rul(evstr(arg1.graphics.exprs(2)))+arg1.graphics.exprs(1)+rul(evstr(arg1.graphics.exprs(2))+3)
    pat=xget('pattern');xset('pattern',default_color(-1))
    thick=xget('thickness');xset('thickness',2)
    if ~orient then
      y=orig(2)+sz(2)*[1/4 1/2 1;1 1 1;1 1/2 1/4;1/4 1/8 0;0 1/8 1/4]'
      x=orig(1)+sz(1)*[0 0 0;0 1/2 1;1 1 1;1 3/4 1/2;1/2 1/4 0]'
      x1=0
    else
      y=orig(2)+sz(2)*[0 1/2 3/4;3/4 7/8 1;1 7/8 3/4;3/4 1/2 0;0 0 0]'
      x=orig(1)+sz(1)*[0 0 0;0 1/4 1/2;1/2 3/4 1;1 1 1;1 1/2 0]'
      x1=0
    end
    xpolys(x,y,5*ones(1,5),color=default_color(-1),thickness=2);
    xstringb(orig(1)+x1*sz(1),orig(2),prt,(1-x1)*sz(1),sz(2))
  endfunction
  
  x=[];y=[];typ=[]
  select job
   case 'plot' then
    // do not draw the frame, do not draw the ports
    function noports(o) ;endfunction
    standard_draw(arg1,%f,noports,%f,~arg1.graphics.flip);
   case 'getinputs' then
    orig=arg1.graphics.orig;
    sz=arg1.graphics.sz;
    if arg1.graphics.flip then
      x=orig(1)+sz(1)/2
      y=orig(2)+sz(2)
    else
      x=orig(1)+sz(1)/2
      y=orig(2)
    end
    typ=-ones_deprecated(x) //undefined type
   case 'getoutputs' then
    x=[];y=[];typ=[]
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
    graphics=arg1.graphics;
    model=arg1.model;
    exprs=graphics.exprs
    while %t do
      [ok,tag,tagvis,exprs]=getvalue('Set block parameters',..
				     ['Tag';'Tag Visibility (1=Local 2=Scoped 3=Global)'],list('str',-1,'vec',1),exprs)
      if ~ok then break,end
      if ((tagvis<1)|(tagvis>3)) then
	message('Tag Visibility must be between 1 and 3');ok=%f;
      end
      tagvis=int(tagvis);
      if ok then
	if ((model.opar<>list(tag))| (model.ipar<>tagvis)) then
          needcompile=4;y=needcompile
	end
	model.opar=list(tag)
	model.ipar=tagvis
	graphics.exprs=exprs
	x.graphics=graphics
	x.model=model
	break
      end
    end
    resume(needcompile)
   case 'define' then
    model=scicos_model()
    model.sim='clkgoto'
    model.evtin=1
    model.opar=list('A')
    model.ipar=int(1)
    model.blocktype='d'
    model.firing=[]
    model.dep_ut=[%f %f]
    exprs=['A',sci2exp(1)]
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([1.5 1.5],model,exprs,gr_i,'CLKGOTO');
    x.graphics.id="Goto"
  end
endfunction
