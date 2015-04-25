function scmenu_activate_scicoslab_window()
  Cmenu=''
  %pt=''
  if super_block then
    Scicos_commands=['%diagram_path_objective=[];%scicos_navig=1';
                     'Cmenu='"Activate Nsp Window'";%scicos_navig=[]']
  else
    Cmenu = 'Leave'
  end
endfunction
