function [x,y,typ]=MISSING_BLOCK(job,arg1,arg2)
//
// Copyright INRIA
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
    x = arg1 ;
    graphics = arg1.graphics ;
    model = arg1.model ;
    orig  = graphics.orig  ;
    exprs = graphics.exprs ;
    
    non_interactive = scicos_non_interactive();					      
    if ~non_interactive then 
      x_message(['This block should be a '+exprs+'block';
		 'but function definition is missing']);
      return;
    end
    
    while %t do
      [ok,txt] = getvalue('Set block parameters',['Text'], list('str',-1),exprs);
      if ~ok then break,end 
      if ok then
	graphics.exprs = exprs
	x.graphics     = graphics
	model.rpar     = txt
	x.model        = model
	break
      end
    end 
   case 'define' then
    if nargin <= 1 then arg1='Missing';end
    model=scicos_model()
    junction_name='missing';
    funtyp=4;
    model.sim=list(junction_name,funtyp)
    model.in=-1
    model.in2=-2
    model.intyp=1
    model.out=-1
    model.out2=-2
    model.outtyp=1
    model.evtin=[]
    model.evtout=[]
    model.state=[]
    model.dstate=[]
    model.rpar= arg1;
    model.blocktype='c' 
    model.firing=[]
    model.dep_ut=[%t %f]
    label=[sci2exp(arg1)];
    gr_i=[sprintf('xstringb(orig(1),orig(2),''%s'',sz(1),sz(2),''fill'');',arg1)];
    x=standard_define([2 2],model,label,gr_i,'MISSING_BLOCK');
  end
endfunction

