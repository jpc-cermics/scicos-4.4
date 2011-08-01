function scmenu_available_parameters()
  Cmenu=''
  if ~exists('%scicos_context') then
    message('No available parameters.')
  else
    in=%scicos_context
    editvar('in',title='Available parameters')
    if ~in.equal[%scicos_context] then
      message('No change accepted')
    end
  end
endfunction
