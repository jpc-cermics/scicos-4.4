function [Cmenu,Select]=Find_Next_Step(path_objective,path)
  i=length(path_objective)
  j=length(path)
  m=min(i,j)
  k=min(find(path_objective(1:m)<>path(1:m)))
  if isempty(k) then
    if i<j then 
      Cmenu='Quit'
    elseif j<i then
      Cmenu='OpenSet'
      Select=[path_objective(j+1),curwin]
    else
      printf('pas possible')
      pause
    end
  else
    Cmenu='Quit'
  end
endfunction
