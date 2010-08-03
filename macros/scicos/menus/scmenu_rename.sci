function Rename_()
  Cmenu='Open/Set'
  [scs_m,edited]=do_rename(scs_m) 
endfunction

function [scs_m,edited]=do_rename(scs_m)
// Copyright INRIA
  edited=edited;
  if pal_mode then
    mess='Enter the new palette name'
  else
    mess='Enter the new diagram name'
  end
  // XXX 
  new=dialog(mess,scs_m.props.title(1))
  new=new(1)
  if ~isempty(new) then
    drawtitle(scs_m.props)  //erase title
    scs_m.props.title(1)=new,
    drawtitle(scs_m.props)  //draw title
    edited=%t
  end
endfunction
