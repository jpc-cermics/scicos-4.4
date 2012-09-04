function scmenu_identification()
  Cmenu='';
  sc=scs_m;
  [scs_m,changed]= do_identification(scs_m);
  if changed then 
    edited=%t;
    scs_m_save=sc;enable_undo=%t;
  end
endfunction

function [scs_m,changed]=do_identification(scs_m)
// Copyright INRIA
  changed=%f;
  if isempty(Select) || isempty(find(Select(:,2)==curwin)) then
    message('Make a selection first');
    return;
  end
  // K contains selected indices restricted to curwin 
  K=Select(find(Select(:,2)==curwin),1);
  if length(K)<> 1 then 
    message('Select only one block or one link for identification !');
    return;
  end
  
  F = get_current_figure();
  numero_objet=K;
  objet = scs_m.objs(numero_objet)
  type_objet = objet.type
  if type_objet == 'Block' then
    identification = objet.graphics.id
    if isempty(identification) then 
      identification = emptystr();
    end
    //
    texte_1 = 'Set Block identification';
    %scs_help='Ident_block'
    [ok,newid] = getvalue(texte_1,'ID',list('str',1),identification)
    if ok then
      newid = stripblanks(newid);
      if newid==identification;return;end 
      objet.graphics.id = newid;
      objet=drawobj(objet,F);
      objet.gr.invalidate[];
      //pause xxx
      changed=%t;
      scs_m.objs(numero_objet) = objet;
    end
  elseif type_objet == 'Link' then
    identification = objet.id
    if isempty(identification) then
      identification = emptystr()
    end
    texte_1 = 'Set link Identification'
    %scs_help='Ident_link'
    [ok, newid] = getvalue(texte_1,'ID',list('str',1), identification);
    //
    if ok then
      newid = stripblanks(newid);
      if newid==identification;return;end 
      c_links = connected_links(scs_m,numero_objet)
      //- set identification to all connected links
      for numero = c_links
        objet = scs_m.objs(numero)
        objet.id = newid
        objet=drawobj(objet,F);
        objet.gr.invalidate[];
        changed=%t;
        scs_m.objs(numero) = objet;
      end
    end				
  else
    x_message('It is impossible to set ID for this type of object')
  end
endfunction
