function scmenu_new()
// action associated to button new 
// start a new diagram 
  global(%scicos_ext='.cos'); //default file extension
  %scicos_ext='cos' // force
  Cmenu=''
  %r=2
  if edited then
    %r=message(['Diagram has not been saved';
                'Are you sure you want to proceed'],['gtk-no';'gtk-yes'])
  end
  if %r==2 then
    // close things related to previous diagram 
    inactive_windows=close_inactive_windows(inactive_windows,super_path)
    global scicos_widgets
    for i=1:length(scicos_widgets)
      if scicos_widgets(i).what.equal['ModelicaInitialize'] then
        if scicos_widgets(i).open==%t then
          scicos_widgets(i).id.destroy[]
        end
      elseif scicos_widgets(i).what.equal['GetInfo'] then
        if scicos_widgets(i).open==%t then
          scicos_widgets(i).id.destroy[]
        end
      end
    end
    if alreadyran then do_terminate(),end  //terminate current simulation
    clear('%scicos_solver')
    alreadyran=%f
    // start a new diagram 
    scs_m=get_new_scs_m()
    //we preserve latest options
    if exists('options') then
      scs_m.props.options=options;
    end
    Cmenu='';
    Select=[];
    scs_m=scicos_diagram_show(scs_m,win=curwin,margins=%t,scicos_uim=%t,scicos_istop=slevel<=1,read=%f);
    edited=%t;
    xinfo('Start a new diagram');
  end
endfunction
