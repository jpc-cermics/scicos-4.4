function scmenu_force_open()
// 
  Cmenu="";%pt=[];
  if size(Select,1)<>1 || curwin<>Select(1,2) then
    return
  end
  o=scs_m.objs(Select(1));
  if ~(o.type=='Block' && o.model.sim(1) =='csuper') then
    message('Force open only works for csuper blocks');
    return;
  end
  sc=scicos(o.model.rpar);
endfunction
