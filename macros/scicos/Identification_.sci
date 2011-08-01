//XXXX Replaced by menus/scmenu_identification 

function Identification_()
  Cmenu='';
  sc=scs_m;
  [scs_m,changed]= do_identification(scs_m);
  if changed then 
    edited=%t;
    scs_m_save=sc;enable_undo=%t;
  end
endfunction
