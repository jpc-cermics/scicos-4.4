function drawtitle(wpar)
// updates the title of a graphic window 
// 
  if ~exists('edited') then edited=%f;end
  mytitle=wpar.title(1);
  if exists('edited') && edited then 
    mytitle= mytitle +' [edited]'; 
  end 
  F=get_current_figure();
  if ~isequal(mytitle,F.fname) then
    xname(mytitle)
    F.fname=mytitle;
  end
endfunction
