function drawtitle(title,win)
// updates the title of a graphic window 
// 
  if nargin < 2 then 
    win = xget('window');
  end
  if exists('edited') && edited then 
    title= title +' [edited]'; 
  end 
  F=get_figure(win);
  if F.equal[[]] then return;end 
  if ~isequal(title,F.fname) then
    xname(title)
    F.fname=title;
  end
endfunction
