// scstxtedit : Input function of the text editor
//    We exit from that function if Quit or use
//    the commit button.
//
// Inputs : str_in : the input text to edit
//          clos : a flag to close the window
//                 0 : No
//                 1 : close
//
//          str_out : the edited output text
//                   can be [] if abort
//          Quit : a flag to say if the buffer has been
//                 closed
//                 0 : No
//                 1 : Quit
//

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
