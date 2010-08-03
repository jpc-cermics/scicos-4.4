function win=get_new_window(windows)
  wfree=find(windows(:,1)==0)
  // Copyright INRIA
  if ~isempty(wfree) then
    win=wfree(1)
  else
    win=max(windows(:,2))+1
  end
endfunction
