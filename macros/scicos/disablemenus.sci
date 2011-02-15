function disablemenus(men)
  %ws=intersect(winsid(),[inactive_windows(2)(:);curwin]')
  if nargin<1 then men=menus.items,end
  for %w=%ws
    for k=1:size(men,'*')
      unsetmenu(%w,men(k))
    end
  end
endfunction
