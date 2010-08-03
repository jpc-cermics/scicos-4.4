function scs_m=scicos_diagram(objs=list(),props=scicos_params())
// jpc nsp   
  scs_m=tlist(['diagram','props','objs'],props,objs)
  // scs_m=hcreate(diagram=%t, props=props,objs=objs);
endfunction
