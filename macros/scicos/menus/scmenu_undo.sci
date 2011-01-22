function Undo_()
// jpc April 13 2009 
  Cmenu='Open/Set'
  %pt=[]
  if enable_undo then
    if new_graphics() then
      // new graphics version.
      // we first need to erase graphic objects.
      F=get_current_figure();
      F.draw_latter[];
      for i=1:length(scs_m.objs);
	if scs_m.objs(i).iskey['gr'] then 
	  // we already have stuffs recorded 
	  F.remove[scs_m.objs(i).gr];
	  scs_m.objs(i).delete['gr'];
	end
      end
      scs_m=scs_m_save;
      needcompile=nc_save
      // take care that scs_m_save shares 
      // graphics with previous scs_m;
      scs_m.props.wpar=scs_m.props
      %wdm=scs_m.props.wpar
      for i=1:length(scs_m.objs); scs_m.objs(i).delete['gr'];end
      //window_set_size();
      scs_m=drawobjs(scs_m);
    else
      scs_m=scs_m_save;needcompile=nc_save
      scs_m.props.wpar=scs_m.props
      %wdm=scs_m.props.wpar
      xclear();// XX xbasc()
      window_set_size()
      drawobjs(scs_m),
      if pixmap then xset('wshow'),end
    end
    enable_undo=%f
  end
endfunction
