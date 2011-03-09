function drawtitle(wpar,win)
// updates the title of a graphic window 
// 
  if nargin < 2 then 
    win = xget('window');
  end
  mytitle=wpar.title(1);
  if exists('edited') && edited then 
    mytitle= mytitle +' [edited]'; 
  end 
  F=get_figure(win);
  if F.equal[[]] then return;end 
  if ~isequal(mytitle,F.fname) then
    // 
    xname(mytitle)
    F.fname=mytitle;
  end
endfunction
