function pwindow_set_size()
  rect=dig_bound(scs_m);
  if ~isempty(rect) then 
    %diag_size=[rect(3)-rect(1),rect(4)-rect(2)];
    %wsiz=[max(400,%diag_size(1)),max(300, %diag_size(2))];
  else
    %wsiz=[600/%zoom,400/%zoom]
  end
  %wdd=min(933, %zoom*%wsiz(1))+30;
  %hdd=min(700, %zoom*%wsiz(2))+30
  %hdd=%hdd+50

//   xset("wresize",0);

  xset('wdim',int(max(400,%wdd)),int(max(300,%hdd)))
  xset('wpdim',int(max(400,%wdd)),int(max(300,%hdd)))
endfunction
