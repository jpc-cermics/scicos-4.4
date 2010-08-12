function [ierr,scicos_ver,scs_m_out]=update_version(scs_m_in)
//## contrib update
//## scicos update
  current_version = get_scicos_version()
  scicos_ver = find_scicos_version(scs_m_in)
  ierr=0
  if scicos_ver<>current_version then
    txt_to_run = 'scs_m_out=do_version(scs_m_in,scicos_ver)'
    ok=execstr(txt_to_run,errcatch=%t)
    if ~ok then
      ierr=1;
      scs_m_out=scs_m_in
    end
  else
    scs_m_out=scs_m_in
  end
endfunction
