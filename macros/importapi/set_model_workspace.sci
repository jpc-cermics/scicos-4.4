function scs_m = set_model_workspace(scs_m,context)
  if ~isempty(context) then 
    scs_m.props.context.concatd[context(:)]
  end
endfunction
