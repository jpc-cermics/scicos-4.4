function [x,y,typ]=PAL_f(job,arg1,arg2)
// Copyright INRIA

  function blk_draw(sz,orig,orient,label)
    xx=orig(1)+      [1 3 5 1 3 5 1 3 5]*(sz(1)/7);
    yy=orig(2)+sz(2)-[1 1 1 4 4 4 7 7 7]*(sz(2)/10);
    z=ones(1,size(xx,2));
    g=xget('color','gray');
    xrects([xx;yy;[sz(1)/7;sz(2)/5]*ones(1,9)],color=z,background=g*z)
  endfunction
  
  x=[];y=[],typ=[]
  select job
   case 'plot' then
    standard_draw(arg1)
   case 'getinputs' then
    x=[];y=[];typ=[];
   case 'getoutputs' then
    x=[];y=[];typ=[];
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    standard = ~(exists('getvalue') && getvalue.get_fname[]== 'getvalue_doc');
    if standard then
      [x,newparameters,needcompile,edited]=scicos(arg1.model.rpar)
    else
      [x,newparameters,needcompile,edited]=(arg1.model.rpar,[],-2,%f)
    end
    id=arg1.graphics.id
    if id=='' then
      arg1.graphics.id=x.props.title(1);
    end
    arg1.model.rpar=x;
    x=arg1
    y=[]
    typ=[]
    resume(%exit=%f);
   case 'define' then
    scs=scicos_diagram();
    scs.props.title='Palette';
    model=scicos_model();
    model.sim='palette';
    model.in=[];
    model.out=[];
    model.rpar=scs;
    model.blocktype='h';
    model.dep_ut=[%f %f];
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2 2],model,[],gr_i,'PAL_f');
    x.graphics.id=scs.props.title(1);
  end
endfunction
