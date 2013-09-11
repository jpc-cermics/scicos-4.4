function scmenu_set_default_action()
  xinfo('Set Default Actions')
  options=scs_m.props.options
  if ~options('Action') then repp1=2, else repp1=1, end
  if ~options('Snap') then repp2=2, else repp2=1, end
  l1=list('combo','Type',repp1,["Free","Smart"])
  l2=list('combo','Snap',repp2,["Yes","No"])
  rep=x_choices('Set Default Action',list(l1,l2))
  if ~isempty(rep) then
    if rep(1)==2 then options('Action')=%f, else options('Action')=%t, end
    if rep(2)==2 then options('Snap')=%f, else options('Snap')=%t, end
    if rep(1)~=repp1 || rep(2)~=repp2 then
      edited=%t
      scs_m.props.options=options
    end
  end
  xinfo(' ')
  Cmenu='';%pt=[];
endfunction
