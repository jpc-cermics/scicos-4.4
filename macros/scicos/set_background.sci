function set_background()
// xset('background',options.Background(1));
  F=get_current_figure();
  if length(F.children) > 0 then 
    A=F.children(1);
    A.background=options.Background(1);
  end
endfunction
