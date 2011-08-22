function scmenu_up_to_main_diagram()
// raise graphic window of main diagram 
  Cmenu=''
  if super_block then
    Scicos_commands=['%diagram_path_objective=[];%scicos_navig=1';
                     'Cmenu='''';%scicos_navig=[];xselect()'];
  else
    message('This is already the main diagram;')
  end
endfunction


function scmenu_up()
// raise graphic window of parent 
// 
  Cmenu='';
  if ~super_block then
    message('This is already the main diagram;');
    return;
  end
  up_path=super_path(1:$-1);
  // is the window active ? 
  ok=%f;
  n=size(inactive_windows(1))
  for i=1:n
    path=inactive_windows(1)(i)
    if isequal(path,up_path) && or(winsid()==inactive_windows(2)(i)) then
      ok= %t;
      break;
    end
  end
  if ~ok then 
    // parent is inactive a Replot will activate it 
    Scicos_commands=['%diagram_path_objective='+sci2exp(up_path)+';%scicos_navig=1';
		     'Cmenu=''Replot'';%scicos_navig=[];xselect()'];
  else
    Scicos_commands=['%diagram_path_objective='+sci2exp(up_path)+';%scicos_navig=1';
		     'Cmenu='''';%scicos_navig=[];xselect()'];
  end
endfunction
