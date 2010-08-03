function enablemenus(men)
// Copyright INRIA
  if ~exists('curwin') then return,end;
  if ~or(curwin==winsid()) then return,end
  //curwin=xget('window')
  if nargin<1 then men=menus.items,end
  for k=1:size(men,'*')
    setmenu(curwin,men(k))
  end
  if super_block then
    unsetmenu(curwin,'Simulate')
  end
  xinfo(' ')
endfunction
