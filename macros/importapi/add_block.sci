function [scs_m,obj_num] = add_block(scs_m,blk,identification)
  // add block to scs_m
  if nargin <= 2 then identification="";end
  blk.graphics.id = identification;
  scs_m.objs($+1) = blk ; // add the object to the data structure
  obj_num = string(length(scs_m.objs))
endfunction
