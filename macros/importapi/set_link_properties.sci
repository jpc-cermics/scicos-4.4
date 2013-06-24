function scs_m = set_link_properties(scs_m,k,col,thick)
  // nargin=argn(2)
  if typeof(scs_m)<>"diagram" then error("1st argument must be a diagram."),end
  if typeof(scs_m.objs(k))<>"Link" then error ("Not a link."),end
  scs_m.objs(k).ct(1)=col
  if nargin>3 then
    scs_m.objs(k).thick=[thick thick]
  end
endfunction

