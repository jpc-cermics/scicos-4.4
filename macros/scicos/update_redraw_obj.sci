function scs_m=update_redraw_obj(scs_m,path,o)
// Copyright INRIA/Enpc
// performs scs_m(path)=o
// or transfert control to changeports
// Moreover if curwin is active then 
// addition and removal of associated graphic objects 
// is performed.
// i.e a graphic object is associated to o 
// and graphic object associated to scs_m(path)
// is removed from current figure.
  
  lt = o.type =='Link'| o.type =='Text';
  if size(path,'*')==2 && ~lt then 
    scs_m=changeports(scs_m,path,o)
    return;
  end;
  
  if or(curwin==winsid()) then
    F=get_current_figure();
    F.remove[scs_m(path).gr];
    o=drawobj(o,F)    
  end
  scs_m(path)=o;
endfunction
