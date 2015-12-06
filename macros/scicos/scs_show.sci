function scs_m=scs_show(scs_m,win)
// this function is used to display a diagram 
// in a new graphic window win.
// It is mainly used for error message to show 
// faulty blocks or links 
// Copyright INRIA/Enpc
  if nargin <= 1 then win=1;end
  scs_m.props.title(1)='Scilab Graphics of '+scs_m.props.title(1);
  scs_m=scicos_diagram_show(scs_m,win=win,margins=%t,scicos_uim=%f,read=%f);
  xselect();
endfunction

function scs_m=scs_show_all(scs_m)
// this function is used to display a diagram 
// and all the superblocks 
  win=max(winsid());if isempty(win) then win=0;else win=win+1;end;
  scs_show(scs_m,win);
  for i=1:size( scs_m.objs,'*') 
    o = scs_m.objs(i);
    if o.type=='Block' && or(o.model.sim(1)==['super','csuper','asuper']) then 
      scs_show_all(o.model.rpar);
    end
  end
endfunction
