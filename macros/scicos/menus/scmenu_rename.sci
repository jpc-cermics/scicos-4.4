function Rename_()
  Cmenu=''
  inside_sblock=%f
  if size(Select,1)==1 then
    if Select(1,2)==curwin then
      if scs_m.objs(Select(1,1)).type=='Block' then
        if scs_m.objs(Select(1,1)).model.sim(1)=='super' | ...
           scs_m.objs(Select(1,1)).gui=='DSUPER' then
          inside_sblock=%t
        end
      end
    end
  end
  if inside_sblock then
    o=scs_m.objs(Select(1,1)).model.rpar
    [o,edited] = do_rename(o,%f,%f)
    scs_m.objs(Select(1,1)).model.rpar=o
  else
    [scs_m,edited] = do_rename(scs_m,%f,%t)
  end
endfunction

function [scs_m,edited]=do_rename(scs_m,pal_mode,dtitle)
  edited=edited;
  if pal_mode then
    mess='Enter the new palette name'
  else
    mess='Enter the new diagram name'
  end
  [ok,new]=getvalue(mess,"Name",list("str",[1,1]),scs_m.props.title(1))
  if ~ok then return;end
  if ~isempty(new) then
    if dtitle then
      scs_m.props.title(1)=new
      drawtitle(scs_m.props) //draw title
    else
      scs_m.props.title(1) = new
    end
    edited=%t
  end
endfunction
