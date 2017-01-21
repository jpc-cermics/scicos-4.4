function [x,y,typ]=LOOKUP_f(job,arg1,arg2)
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
    //pause xxx
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs
    model=arg1.model;rpar=model.rpar;
    n=size(rpar,'*')/2
    xx=rpar(1:n);yy=rpar(n+1:2*n);
    
    non_interactive = exists('getvalue') && ...
	( getvalue.get_fname[] == 'setvalue' || getvalue.get_fname[] == 'getvalue_doc');
    while %t do
      if non_interactive then 
	ok=%t
      else
	[xx,yy,ok]=edit_curv(xx,yy,'axy')
      end  // no need anymore to overload edit_curv in do_eval
      if ~ok then break,end
      n=size(xx,'*')
      if or(xx(2:n)-xx(1:n-1)<=0) then
	message('You have not defined a function')
	ok=%f
      end
      if ok then
	model.rpar=[xx(:);yy(:)]
	x.graphics=graphics;x.model=model
	break
      end
    end
   case 'define' then
    model=scicos_model()
    model.sim='lookup'
    model.in=1
    model.out=1
    model.rpar=[-2;-1;1;2;-1;1;-1;1]
    model.blocktype='c'
    model.dep_ut=[%t %f]

    gr_i=['rpar=model.rpar;n=size(rpar,''*'')/2;';
	  'thick=xget(''thickness'');xset(''thickness'',2);';
	  'xx=rpar(1:n);yy=rpar(n+1:2*n);';
	  'mnx=min(xx);xx=xx-mnx*ones(size(xx));mxx=max(xx);';
	  'xx=orig(1)+sz(1)*(1/10+(4/5)*xx/mxx);';
	  'mnx=min(yy);yy=yy-mnx*ones(size(yy));mxx=max(yy);';
	  'yy=orig(2)+sz(2)*(1/10+(4/5)*yy/mxx);';
	  'xpoly(xx,yy,type=''lines'');';
	  'xset(''thickness'',thick);']
    x=standard_define([2 2],model,[],gr_i,'LOOKUP_f');
  end
endfunction
