function [x,y,typ]=GotoTagVisibility(job,arg1,arg2)
// Copyright INRIA

  function blk_draw(sz,orig,orient,label)
    xstringb(orig(1),orig(2),["{"+arg1.graphics.exprs(1)+"}"],sz(1),sz(2),"fill");
    txt=["Goto Tag";"Visibility" ];
    fz=1.5*acquire("%zoom",def=1)*4;
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
     y=acquire('needcompile',def=0);
    x=arg1
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;
    while %t do
      [ok,tag,exprs]=getvalue('Set parameters',..
			      ['GotoTag'],..
			      list('gen',-1),exprs); // gen ?
      if ~ok then break,end
      if ok then
	if model.opar<>list(tag) then y=4;end;
	graphics.exprs=exprs;
	model.opar=list(tag);
	x.graphics=graphics;x.model=model;
	break
      end
    end
   case 'define' then
    model=scicos_model()
    model.sim='gototagvisibility'
    model.in=[]
    model.in2=[]
    model.out=[]
    model.out2=[]
    model.evtin=[]
    model.intyp=1
    model.outtyp=1
    model.opar=list('""A""');
    model.blocktype='c'
    model.firing=%f
    model.dep_ut=[%f %f]
    exprs=sci2exp('A')
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2 2],model,exprs,gr_i,'GotoTagVisibility');
  end
endfunction
