function scmenu_show_csuper_internal()
  Cmenu='';%pt=[];
  if size(Select,1)<>1 | curwin<>Select(1,2) then
    return
  end
  do_show_csuper_internal(scs_m.objs(Select(1)));
endfunction

function do_show_csuper_internal(o)
  ok=%t
  if o.type =='Block' && o.model.sim(1)=='csuper' then 
    scs_m= o.model.rpar;
    // draw the new diagram
    curwin = acquire('curwin',def=1000);
    scs_m=scicos_diagram_show(scs_m,win=curwin+1,margins=%t,scicos_uim=%f,scicos_istop=%f,read=%f);
  else
    message("No diagram inside to be shown");
  end
endfunction

function scmenu_show_compiled_sizes()
  Cmenu='';%pt=[];
  if exists('scs_m') then
    do_show_compiled_sizes(scs_m);
  end
endfunction

function do_show_compiled_sizes(scsm)
  curwin = acquire('curwin',def=1000)+1;
  scs_m=scicos_port_size_propagate(scs_m);
  scicos(scs_m);
  // scs_m=scicos_diagram_show(scs_m,win=curwin+1,margins=%t,scicos_uim=%t,scicos_istop=%t,read=%f);
endfunction
