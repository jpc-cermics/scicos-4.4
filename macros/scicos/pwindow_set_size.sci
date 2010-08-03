function pwindow_set_size()
// Copyright INRIA
  rect=dig_bound(scs_m);
  
  if ~isempty(rect) then 
    %wsiz=[rect(3)-rect(1),rect(4)-rect(2)];
  else
    %wsiz=[600/%zoom,400/%zoom]
  end
  %wdd=min(1200,%zoom*%wsiz(1))+30;
  %hdd=min(1000,%zoom*%wsiz(2))+30
  
  xset('wpdim',min(1200,%wdd),min(1000,%hdd))
endfunction
