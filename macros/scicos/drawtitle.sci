function drawtitle(wpar)
  //draw window title
  if edited then
    mytitle=wpar.title(1)+' [edited]'
  else
    mytitle=wpar.title(1)
  end
  F=get_current_figure();
  if ~isequal(mytitle,F.fname) then
    xname(mytitle)
    F.fname=mytitle;
  end
endfunction
