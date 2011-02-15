function enablemenus(men)
  %ws=intersect(winsid(),[inactive_windows(2)(:);curwin]')
  if nargin<1 then men=menus.items,end
  for %w=%ws
    for k=1:size(men,'*')
      setmenu(%w,men(k))
      if Main_Scicos_window<>%w & men(k)=='Simulate' then
        unsetmenu(%w,'Simulate')
      end
    end
  end
endfunction
