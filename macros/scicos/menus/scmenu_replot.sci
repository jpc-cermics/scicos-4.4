function Replot_()
  Cmenu=''
  %pt=[]
  Select=[]
  // we would need also a Replot without a resize 
  %wdm=scs_m.props.wpar
  window_set_size();
  scs_m=do_replot(scs_m);
endfunction

function scs_m=do_replot(scs_m)
// this function recreates all the 
// graphic objects. Note that scs_m 
// has to be changed by this operation.
  F=get_current_figure();
  for i=1:length(scs_m.objs);
    if scs_m.objs(i).iskey['gr'] then 
      F.remove[scs_m.objs(i).gr];
      scs_m.objs(i).delete['gr'];
    end
  end
  scs_m=drawobjs(scs_m);
endfunction
