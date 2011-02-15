function win=get_new_window(windows)
  global inactive_windows
  win=max(windows(:,2))+1
  if ~isempty(inactive_windows(2)) then
    win=max(win,max(inactive_windows(2))+1)
  end
endfunction
