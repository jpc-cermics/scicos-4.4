function g=getgeom(bl)
// call within a simulation function of a scicos block this function 
// returns a vector g containing [win x,y,w,h] of the block. win is either 
// the number of main scicos window or -1 if the block is not in the main
// window.
  if nargin <= 0 then bl=curblock() ;end 
  if ~exists('slevel') then slevel=0;end 
  path=%cpr.corinv(bl)
  if exists('windows')==%f |slevel<>1|size(path,'*')<>1 then 
    g=[-1;zeros_new(4,1)],
  else 
    orig=scs_m.objs(path).graphics.orig;
    sz=scs_m.objs(path).graphics.sz
    g=[windows(1,2);orig(:);sz(:)]
  end
endfunction

