function do_exit()
  // Copyright INRIA
  scs_m = acquire('scs_m',def=[]);
  if isempty(scs_m) then return;end
  r=-1;
  if edited then
    if ~super_block then
      r=x_message(['The diagram has not been saved.';
                   'Save changes now ?'],...
                   ['Discard Changes';'gtk-save';'gtk-save-as']);
    end
  end
  select r 
   case 2 then ok=do_save(scs_m); if ~ok then do_SaveAs(scs_m),end
   case 3 then do_SaveAs(scs_m);
  end
  
  if ~super_block then
    if alreadyran then do_terminate(),end
  end

  winrem=[size(windows,1):-1:noldwin+1]
  
  global %scicos_navig
  global inactive_windows
  
  if ~isempty(%scicos_navig) then
    ii=winrem(find(windows(winrem,1)>0)) //find super block (not palette)
    if size(ii,'*')<>1 then printf('non e possibile\n'),pause,end
    winkeep=windows(ii(1),2)
    inactive_windows(1)($+1)=super_path
    inactive_windows(2)($+1)=winkeep  // (1) is for security
    if or(winkeep==winsid()) then  // in case the current window is open and
                            // remains open by becoming inactive
      ww=get_current_figure();
      //scf(winkeep)
      xset('window',winkeep)
      ha=get_current_figure();
      ha=nsp_graphic_widget(ha.id)
      if enable_undo then
        ha.user_data=list(scs_m,Select,enable_undo,scs_m_save,nc_save);
      else
        ha.user_data=list(scs_m,Select,enable_undo,[],[]);  // no undo information
      end
      //scf(ww)
      xset('window',ww.id)
    end
  else
    ii=-1
  end

  for i=winrem
    if i<>ii then
      win=windows(i,2)
      if or(win==winsid()) then
        xbasc(win),xdel(win); 
      end
    end
  end
endfunction
