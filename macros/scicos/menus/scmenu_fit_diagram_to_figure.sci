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

   r=[hrect.width vrect.height]

   newzoom_w=r(1)/(w*(1+margins(1)+margins(2)))
   //suppose for that time that menu bar & status bar have the same height
   //like the scroolbar
   newzoom_h=r(2)/(h*(1+margins(3)+margins(4)))
   newzoom=min(newzoom_w,newzoom_h);

   if newzoom~=%zoom then
     %zoom=newzoom
     for i=1:length(scs_m.objs)
       if scs_m.objs(i).iskey['gr'] then
         scs_m.objs(i).gr.show=%f
       end
     end

     window_set_size(curwin,%f);
     //we need redraw text and some blocks
     //with not filled text
     [scs_m]=redrawifnecessary(scs_m,F)
  
     for i=1:length(scs_m.objs)
       if scs_m.objs(i).iskey['gr'] then
         scs_m.objs(i).gr.show=%t
       end
     end

     F.invalidate[]
   end

   xinfo(' ');
endfunction
