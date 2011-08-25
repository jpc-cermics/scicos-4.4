// scstxtedit : opens a dialog window to edit text 
// str_in : the input text to edit
// ptxtedit.clos: if equal to 0 edition is aborted and we quit 
//                with Quit==%t and str_out=[];
// Note that if the button Cancel is pressed during edition 
// then returned values are also  Quit==%t and str_out=[];
// ptxtedit.head: message on top of dialog window 
// ptxtedit.typ: is unused.

function [str_out,Quit] = scstxtedit(str_in,ptxtedit)
  clos = ptxtedit.clos
  typ  = ptxtedit.typ
  head = ptxtedit.head
  if clos<>1 then
    if isempty(head) then
      str_out = dialog(['DIALOG'], str_in) ;
    else
      str_out = dialog([head], str_in) ;
    end
  else
    str_out=[];
  end
  if isempty(str_out) then
    Quit = %t
  else
    Quit = %f 
  end
endfunction
