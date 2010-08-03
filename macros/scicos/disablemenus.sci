function disablemenus(men)
// Copyright INRIA
  if ~exists('curwin') then return;end
  xinfo('Please be patient')
  //curwin=xget('window')
  if nargin < 1 then men=menus.items,end
  for k=1:size(men,'*')
    unsetmenu(curwin,men(k))
  end
endfunction
