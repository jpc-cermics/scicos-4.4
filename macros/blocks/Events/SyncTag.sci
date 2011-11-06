function [x,y,typ]=SyncTag(job,arg1,arg2)
// Copyright INRIA
  
  function blk_draw(sz,orig,orient,label)
    col=default_color(-1)
    orig=arg1.graphics.orig;
    sz=arg1.graphics.sz;
    orient=arg1.graphics.flip;
    // a circle with n points 
    n=100;
    xx=linspace(0,1,n);
    yy=(1/4-(xx-1/2).^2).^(1/2);
    x=orig(1)+sz(1)*[xx,xx($:-1:1)];
    y=orig(2)+sz(2)*[yy+1/2,-yy($:-1:1)+1/2];
    xpoly(x,y,color=col,thickness=2);
    xstringb(orig(1),orig(2),' SyncTag ',sz(1),sz(2),"fill")
  endfunction
  
  x=[];y=[],typ=[]
  select job
   case 'plot' then
    // do not draw the frame, do not draw the ports
    function noports(o) ;endfunction
    standard_draw(arg1,%f,noports,%f,arg1.graphics.flip);
   case 'getinputs' then
    [x,y,typ]=standard_inputs(arg1)
   case 'getoutputs' then
    [x,y,typ]=standard_outputs(arg1)
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1
   case 'define' then
    model=scicos_model()
    model.sim='synctag';
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2 2],model,'',gr_i,'SyncTag');
  end
endfunction
