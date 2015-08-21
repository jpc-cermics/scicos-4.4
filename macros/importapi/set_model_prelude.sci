function scs_m=set_model_prelude(scs_m,script)
  S=split(script,sep='\n')';
  scs_m.props.context.concatd[S]
endfunction
