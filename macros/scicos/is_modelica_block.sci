function r=is_modelica_block(o)
//checks if the block o is a modelica block
  if o.model.iskey['equations'] then
    r=~ o.model.equations.equal[list()];
  else
    r=%f
  end
endfunction

