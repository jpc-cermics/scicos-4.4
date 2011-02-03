function New_()
  Cmenu=''
  %r=2
  if edited then
    %r=message(['Diagram has not been saved';
		'Are you sure you want to proceed'],['gtk-no';'gtk-yes'])
  end
  if %r==2 then
    if alreadyran then do_terminate(),end  //terminate current simulation
    alreadyran=%f
    F=get_current_figure()
    for k=1:length(scs_m.objs)
      if scs_m.objs(k).iskey['gr'] then 
	F.remove[scs_m.objs(k).gr];
	scs_m.objs(k).remove['gr'];
      end
    end
    scs_m=scicos_diagram()
    %wpar=scs_m.props; 
    window_set_size()
    Cmenu='Replot'
    edited=%f
  end
endfunction
