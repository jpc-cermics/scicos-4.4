function scs_m = set_link_properties(scs_m,k,col,thick)
// nargin=argn(2)
  if scs_m.type <> "diagram" then error("Error: 1st argument must be a diagram.");end
  if scs_m.objs(k).type <>"Link" then error("Error: not a link.");end
  scs_m.objs(k).ct(1)=col;
  if nargin>3 then scs_m.objs(k).thick=[thick thick] end
endfunction

