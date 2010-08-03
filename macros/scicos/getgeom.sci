function g=getgeom()
// call within a simulation function of a scicos block this function 
// returns a vector g containing [win x,y,w,h] of the block. win is either 
// the number of main scicos window or -1 if the block is not in the main
// window.
  if ~exists('slevel') then slevel=0;end 
  path=%cpr.corinv(curblock())

  if exists('windows')==%f |slevel<>1|size(path,'*')<>1 then 
    g=[-1;zeros_new(4,1)],
    return,
  end
  orig=scs_m.objs(path).graphics.orig;sz=scs_m.objs(path).graphics.sz
  g=[windows(1,2);orig(:);sz(:)]
endfunction
