function scmenu_fit_diagram_to_figure()
   Cmenu='';
   xinfo('Fit diagram to figure');
   F=get_current_figure()
   gh=nsp_graphic_widget(curwin) //** get the handle of the current graphics window
   r=gh.get_size[];              //** acquire the current figure physical size
   rect=dig_bound(scs_m);        //** Scicos diagram size
   if isempty(rect) then         //** if the schematics is not defined
     return;                     //**   then return
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
   hrect=hscrollbar.allocation
   vrect=vscrollbar.allocation

   %zoom_w=(r(1)-vrect.width)/(w*(1+margins(1)+margins(2)))
   //suppose for that time that menu bar & status bar have the same height
   //like the scroolbar
   %zoom_h=(r(2)-hrect.height*3)/(h*(1+margins(3)+margins(4)))
   %zoom=min(%zoom_w,%zoom_h);
   window_set_size();
   xinfo(' ');
endfunction
