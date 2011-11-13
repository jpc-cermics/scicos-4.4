function [x,y,typ]=CLKGotoTagVisibility(job,arg1,arg2)
// Copyright INRIA
  
  function blk_draw(sz,orig,orient,label)
    xstringb(orig(1),orig(2),["{"+arg1.graphics.exprs(1)+"}"],sz(1),sz(2),"fill");
    wd=xget("wdim").*[1.016,1.12];
    p=wd(2)/wd(1);p=1;
    xarc(orig(1)+0.05*sz(1), orig(2)+0.95*sz(2),0.9*sz(1)*p,0.9*sz(2),0,360*64,...
	 color=scs_color(5),thickness=2);
    txt=["Goto Tag";"Visibility"];
    if ~exists("%zoom") then %zoom=1, end;
    fz=1.5*%zoom*4;
    xstring(orig(1)+sz(1)/2,orig(2)+sz(2),txt,posx="center",posy="bottom",size=fz);
  endfunction
  
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
    x=arg1
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    while %t do
      [ok,tag,exprs]=getvalue('Set parameters',..
			      ['GotoTag'],..
			      list('str',-1),exprs)
      if ~ok then break,end
      if ok then
	if model.opar<>list(tag) then needcompile=4;y=needcompile,end
	graphics.exprs=exprs;
	model.opar=list(tag);
	x.graphics=graphics;x.model=model;
	break
      end
    end
    resume(needcompile)
   case 'define' then
    model=scicos_model()
    model.sim='clkgototagvisibility'
    model.in=[]
    model.in2=[]
    model.out=[]
    model.out2=[]
    model.evtin=[]
    model.intyp=1
    model.outtyp=1
    model.opar=list('A');
    model.blocktype='c'
    model.firing=%f
    model.dep_ut=[%f %f]
    exprs='A';
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2 2],model,exprs,gr_i,'CLKGotoTagVisibility');
  end
endfunction
