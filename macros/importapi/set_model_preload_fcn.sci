function scs_m = set_model_preload_fcn(scs_m,script)
  S=split(script,sep='\n');
  scs_m.props.context.concatd[S]
endfunction
