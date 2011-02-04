function scs_m=update_redraw_obj(scs_m,path,o)
// Copyright INRIA/Enpc 
// 
  if or(curwin==winsid()) then
    F=get_current_figure();
    F.draw_latter[];
  end
  if size(path,'*')==2 then
    if o.type =='Link'| o.type =='Text' then
      if or(curwin==winsid()) then
        F.remove[scs_m(path).gr];
        o=drawobj(o)
      end
      scs_m(path)=o;
    else
      scs_m=changeports(scs_m,path,o)
    end
  else // change a block in a sub-level
    if or(curwin==winsid()) then
      F.remove[scs_m(path).gr];
      o=drawobj(o)
    end
    scs_m(path)=o;
  end
  if or(curwin==winsid()) then
    F.draw_now[];
  end
endfunction
