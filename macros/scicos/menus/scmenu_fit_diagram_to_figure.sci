function scmenu_fit_diagram_to_figure()
  printf("enter: scmenu_fit_diagram_to_figure\n");
   Cmenu='';
   xinfo('Fit diagram to figure');
   F=get_current_figure()
   gh=nsp_graphic_widget(curwin) // get widget associated to the current graphics window
   r=gh.get_size[];              // get widget size
   rect=dig_bound(scs_m);        // Scicos diagram size
   if isempty(rect) then         // if the schematics is not defined we return;
     return;
   end
   w=(rect(3)-rect(1));
   h=(rect(4)-rect(2));
   margins = [0.02 0.02 0.02 0.02]

   //Alan, 19/02/2011
   Vbox=gh.get_children[]
   Vbox=Vbox(1)
   ScrolledWindow=Vbox.get_children[]
   ScrolledWindow=ScrolledWindow($)
   hscrollbar=ScrolledWindow.get_hscrollbar[]
   vscrollbar=ScrolledWindow.get_vscrollbar[]
   if exists('gtk_get_major_version','function') then
     hrect=hscrollbar.get_allocation[];
     vrect=vscrollbar.get_allocation[];
     r=[hrect.width vrect.height]
   else
     hrect=hscrollbar.allocation
     vrect=vscrollbar.allocation
     r=[hrect.width vrect.height]
   end

   newzoom_w=r(1)/(w*(1+margins(1)+margins(2)))
   //suppose for that time that menu bar & status bar have the same height
   //like the scroolbar
   newzoom_h=r(2)/(h*(1+margins(3)+margins(4)))
   newzoom=min(newzoom_w,newzoom_h);

   if newzoom <> scs_m.props.zoom then
     scs_m.props.zoom=newzoom;
     for i=1:length(scs_m.objs)
       if scs_m.objs(i).iskey['gr'] then 
	 F.remove[scs_m.objs(i).gr];
       end
     end
     window_set_size(curwin,%f,invalidate=%f,popup_dim=%f);
     scs_m=scs_m_remove_gr(scs_m); 
     scs_m=drawobjs(scs_m,curwin);
     edited=%t;
   end
   xinfo(' ');
endfunction
