function do_exit()
// Copyright INRIA
  r=-1;
  if edited then
    if ~super_block then
      r=x_message(['The diagram has not been saved.';
                   'Save changes now ?'],...
                   ['Discard Changes';'gtk-save';'gtk-save-as']);
    end
  end
  select r 
   case 2 then ok=do_save(); if ~ok then do_SaveAs(),end
   case 3 then do_SaveAs();
  end
  
  if ~super_block & ~pal_mode  then
    if alreadyran then do_terminate(),end
  end

  ok=%t
  if or(winsid()==curwin) then
    xset('window',curwin)
    xclear();// XX xbasc()
    xset('alufunction',3)
    if ~super_block then
      delmenu(curwin,'stop'),
      xset('window',curwin),xsetech([0 0 1 1])
      clearglobal('%tableau');clear('%tableau');
    end
  end
  
  for win=windows(size(windows,1):-1:noldwin+1,2)'
    if or(win==winsid()) then
      xbasc(win),xdel(win);
    end
  end
endfunction
