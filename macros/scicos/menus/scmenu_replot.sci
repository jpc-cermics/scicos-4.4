function scmenu_replot()
  Cmenu=''
  %pt=[]
  Select=[]
  // we would need also a Replot without a resize

 for i=1:length(scs_m.objs)
   if scs_m.objs(i).iskey['gr'] then
     scs_m.objs(i).gr.show=%f
   end
 end

  window_set_size();
  scs_m=do_replot(scs_m);
endfunction

function scs_m=do_replot(scs_m)
// this function recreates all the graphic objects.
// If objects of scs_m already have graphic objects 
// they will be removed from the figure.
// But note that other objects present in figure 
// will not be deleted.
  scs_m=drawobjs(scs_m);
endfunction
