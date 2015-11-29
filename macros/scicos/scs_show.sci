function scs_m=scs_show(scs_m,win)
// this function is used to display a diagram 
// in a new graphic window win.
// It is mainly used for error message to show 
// faulty blocks or links 
// Copyright INRIA/Enpc
  
  %zoom=acquire('%zoom',def=1);
  if nargin <= 1 then win=1;end
  scs_m=scs_m_remove_gr(scs_m);
  scs_m.props.title(1)='Scilab Graphics of '+scs_m.props.title(1);
  xclear(win,gc_reset=%f);// just in case 
  xset('window',win);
  xselect();
  if ~set_cmap(scs_m.props.options('Cmap')) then // add colors if required
    scs_m.props.options('3D')(1)=%f //disable 3D block shape
  end
  window_set_size(win,%f,read=%f);
  options=scs_m.props.options; // because drawobjs uses the caller options
  scs_m=drawobjs(scs_m);
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
