function scmenu_new()
  Cmenu=''
  %r=2
  if edited then
    %r=message(['Diagram has not been saved';
                'Are you sure you want to proceed'],['gtk-no';'gtk-yes'])
  end
  if %r==2 then
    inactive_windows=close_inactive_windows(inactive_windows,super_path)
    //closing the initialization GUI before opening another diagram
    global scicos_widgets
    for i=1:length(scicos_widgets)
      if scicos_widgets(i).what.equal['ModelicaInitialize'] then
        if scicos_widgets(i).open==%t then
          scicos_widgets(i).id.destroy[]
          break 
        end
      end
    end
    if alreadyran then do_terminate(),end  //terminate current simulation
    clear('%scicos_solver')
    alreadyran=%f
    F=get_current_figure()
    for k=1:length(scs_m.objs)
      if scs_m.objs(k).iskey['gr'] then 
        F.remove[scs_m.objs(k).gr];
        scs_m.objs(k).remove['gr'];
      end
    end
    scs_m=get_new_scs_m()
    %wpar=scs_m.props;  ; 
    %zoom=1.4
    window_set_size()
    Cmenu='Replot'
    edited=%f
    Select=[]
  end
endfunction
