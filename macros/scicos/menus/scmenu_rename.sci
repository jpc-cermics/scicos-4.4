function scmenu_rename()
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
    title=scs_m.objs(Select(1,1)).model.rpar.props.title(1);
    [title,edited] = do_rename(title,%f)
    if edited then 
      scs_m.objs(Select(1,1)).model.rpar.props.title(1)=title;
    end
  else
    [title,edited] = do_rename(scs_m.props.title(1),%t);
    if edited then scs_m.props.title(1)=title;end;
  end
endfunction

function [new,edited]=do_rename(title,draw_title)
  edited= %f;
  mess='Enter the new diagram name'
  %scs_help='Rename'
  [ok,new]=getvalue(mess,"Name",list("str",[1,1]),title);
  if ~ok then return;end
  if ~isempty(new) then
    if draw_title then drawtitle(new);end 
    edited=%t
  end
endfunction
