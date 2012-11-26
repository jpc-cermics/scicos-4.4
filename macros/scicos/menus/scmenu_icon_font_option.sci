function scmenu_icon_font_option()
  global %scicos_fix_font
  global inactive_windows
  Cmenu=''
   r = x_choose(['Variable size';'Fix size'],..
	         ['Font style used in block icons.'],'Cancel')
   if r==1 then
     %scicos_fix_font=[]
   elseif r==2 then
     %scicos_fix_font=1
   else
     return
   end

  Scicos_commands=[]

  for ssuper=inactive_windows(1)
   if ~isempty(ssuper) then
    Scicos_commands=['%diagram_path_objective='+sci2exp(ssuper)+';%scicos_navig=1';
                     'Cmenu='"Replot'";%scicos_navig=[]';
                     Scicos_commands]
   end
  end

  if r==2 then
    Scicos_commands=['%diagram_path_objective=[];%scicos_navig=1';
                     'xstringb=xstringb_fix_font;Cmenu='"Replot'";%scicos_navig=[]';
                     Scicos_commands
                     '%diagram_path_objective='+sci2exp(super_path)+';%scicos_navig=1';
                     'Cmenu='"Replot'";%scicos_navig=[]']
  else
    Scicos_commands=['%diagram_path_objective=[];%scicos_navig=1';
                     'clear xstringb;Cmenu='"Replot'";%scicos_navig=[]';
                     Scicos_commands
                     '%diagram_path_objective='+sci2exp(super_path)+';%scicos_navig=1';
                     'Cmenu='"Replot'";%scicos_navig=[]']
  end


endfunction
