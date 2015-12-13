function [txt,L]=get_block_info(scs_m,k,ksave)
// Copyright INRIA
  if nargin>2 then
    super_path;
    super_path($+1) = ksave
  end
  txt=[];
  L=list();
  o=scs_m.objs(k)
  ksave = k // pour creer super_path
  //select o(1)
  select o.type 
   case 'Block' then
    [txt,L] = standard_document(o,k)
    txt=[txt;' '];
    if o.model.sim(1)=='super' | o.model.sim(1)=='csuper' then
      L_b=L;L=list();
      objet=o.model.rpar
      infos = o.model.rpar.props
      if size(infos.title,'*')==2 then 
	txt = [txt;
	       'Super Block Documentation: '+infos.title(2)+'/'+
	       infos.title(1)]
      else
	txt = [txt;'Super Block Documentation: '+infos.title(1)]
      end
      txt=[txt;get_info(infos.doc)],

      // information on components
      boutons = ['Yes', 'No']
      ligne_1 = list('combo','Blocks', 2, boutons)
      ligne_2 = list('combo','Links', 2, boutons)
      ligne_3 = list('combo','Nodes', 2, boutons)
      ligne_4 = list('combo','Others', 2, boutons)
      ligne_5 = list('combo','Super Blocks', 2, boutons)
      ligne_6 = list('combo','Block itself', 2, boutons)
      //
      titre = ['This is a super block, Select additional '
	       'informations you want to get on it''s'
	       'components']
      [lrep,lres,reponse]= x_choices(titre, list(ligne_1, ligne_2, ligne_3, ligne_4, ligne_5,ligne_6))
      if ~isempty(reponse) then
	filtre = (reponse == 1)
	if or(filtre) then
	  txt=[txt;
	       'Informations on selected components'
	       '----------------------------------';' ']
	end
	if filtre(6) then 
	  if length(L_b)<> 0 then scicos_show_info_notebook(L_b); end
	end
	for k = 1 : length(objet.objs)
	  o1=objet.objs(k)
	  ok=%f
	  if o1.type =='Block' then
	    ok=filtre(1)|
	    filtre(5)&(o1.model.sim(1)=='super'|o1.model.sim(1)=='csuper')|
	    filtre(4)&is_split(o1)
	  else  
	    ok=((o1.type =='Link')&filtre(2))|((o1.type =='Text')&filtre(4))
	  end
	  if ok then
	    [txt_k,L_k]=get_block_info(objet,k,ksave);
	    if length(L_k)<> 0 then scicos_show_info_notebook(L_k);
            end
	    txt=[txt;' '+txt_k];
	  end
	end
      end
    else
      execstr('texte_2 = '+o.gui+'(''show'', o)')
      if isempty(texte_2) then
	texte_2='No  documentation available for the parameters of this block'
      end
      txt=[txt;
	   ' '
	   'Block Parameters';
	   '----------------'
	   ' '
	   texte_2]
    end
   case 'Link' then
    [txt,L] = standard_document(o,k)
   case 'Text' then
    [txt,L] = standard_document(o,k)
   case 'Deleted' then
    txt=[];L=list();
  end
endfunction
