function blk = instantiate_block(name)

  names = ['INTEGRAL_m','SPLIT_f'];
  modelicos_names =['MBC_Integrator','IMPSPLIT_f'];
  
  global(simport_target_modeler="scicos");
  
  if simport_target_modeler=="modelicos" then
    I=find(name == names);
    if ~isempty(I) then name = modelicos_names(I);end
  end
  
  execstr('blk='+name+'(''define'')')
  blk.graphics.sz=20*blk.graphics.sz
endfunction


