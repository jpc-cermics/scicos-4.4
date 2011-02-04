function Identification_()
  Cmenu=''
  xinfo('Click on an object to set or get identification')
  printf("go in do_ident_new ");// ZZ
  [%pt,scs_m ]= do_ident_new(%pt,scs_m)
  xinfo(' ')
endfunction

function [%pt,scs_m]=do_ident_new(%pt,scs_m)
// Copyright INRIA
  while %t
    if isempty(%pt) then
      [btn,%pt,win,Cmenu]=cosclick()
      if Cmenu<>"" then
	resume(%win=win,Cmenu=Cmenu,btn=btn)
        return;
      end
    else
      win=%win;
    end
    xc=%pt(1);yc=%pt(2);%pt=[];
    k=getblocklink(scs_m,[xc;yc])
    if ~isempty(k) then break,end
  end
  F = get_current_figure();
  numero_objet=k
  printf("In do_ident_new %d\n",k);// ZZ
  scs_m_save=scs_m
  objet = scs_m.objs(numero_objet)
  type_objet = objet.type
  if type_objet == 'Block' then
    identification = objet.graphics.id
    if size(identification,'*') == 0 then
      identification = emptystr()
    end
    //
    texte_1 = 'Set Block identification'
    texte_2 = 'ID'
    [ok, identification] = getvalue(texte_1, texte_2, list('str', 1), 
    identification)
    if ok then
      F.remove[scs_m.objs(numero_objet).gr];
      objet.graphics.id = stripblanks(identification)
      objet=drawobj(objet)
      scs_m.objs(numero_objet) = objet;
    end
  elseif type_objet == 'Link' then
    identification = objet.id
    if isempty(identification) then
      identification = emptystr()
    end
    texte_1 = 'Set link Identification'
    texte_2 = 'ID'
    [ok, identification] = getvalue(texte_1, texte_2, list('str', 1),identification);
    //
    if ok then
      identification = stripblanks(identification)
      c_links = connected_links(scs_m,numero_objet)
      //- set identification to all connected links
      //
      for numero = c_links
	objet = scs_m.objs(numero)
	objet.id = identification
	objet=drawobj(objet)
	scs_m.objs(numero_objet) = objet;
      end
    end				
  else
    x_message('It is impossible to set ID for this type of object')
  end
  //
  if pixmap then
    xset('wshow')
  end
  if ok then 
    resume(scs_m_save,enable_undo=%t,edited=%t);
  end
endfunction
