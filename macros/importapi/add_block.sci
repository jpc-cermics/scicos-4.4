function [scs_m,obj_num] = add_block(scs_m,blk,identification)
  blk.graphics.id = identification;
  scs_m.objs($+1) = blk ; // add the object to the data structure
  obj_num = string(length(scs_m.objs))
endfunction
