function [Cmenu,Select]=Find_Next_Step(path_objective,path,Select)
  i=length(path_objective)
  j=length(path)
  m=min(i,j)
  if isequal(m,0) then
    k=[]
  else
    k=min(find(path_objective(1:m)<>path(1:m)))
  end
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
