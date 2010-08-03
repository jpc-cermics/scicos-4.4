function cpr=scicos_cpr(state=scicos_state(),sim=scicos_sim(),cor=list(),corinv=list())
  cpr=tlist(['cpr','state','sim','cor','corinv'],state,sim,cor,corinv)
endfunction
