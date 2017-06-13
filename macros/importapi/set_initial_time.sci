function scs_m = set_initial_time(scs_m,ti)
  [ti,err]=evstr(ti);
  if err || ti<>0 then 
    printf("Initial time is other than zero. This is not supported.\n")
  end
endfunction
