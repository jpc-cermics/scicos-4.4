function scmenu_compile()
  nc_save=4
  Cmenu=''
  if ~execstr('[%cpr,ok]=do_compile(scs_m)',errcatch=%t) then
    message(['Error in compile';lasterror()] )
    return;
  end
  if ok then
    newparameters=list()
    %tcur=0 //temps courant de la simulation
    alreadyran=%f
    %state0=%cpr.state;
    needcompile=0;
  else
    needcompile=4,
  end
endfunction
