function [scs_m,obj_num] = add_block(scs_m,blk,identification)

  global(simport_target_modeler="scicos");
  
  if simport_target_modeler=="modelicos" then
    [scs_m,obj_num] = add_modelicos_block(scs_m,blk,identification)
    return;
  end
  
  blk.graphics.id = identification;
  scs_m.objs($+1) = blk ; // add the object to the data structure
  obj_num = string(length(scs_m.objs))
endfunction
