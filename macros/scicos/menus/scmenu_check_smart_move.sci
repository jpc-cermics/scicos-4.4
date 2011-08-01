function scmenu_smart_move()
  if %win<>curwin then
    kc=find(%win==windows(:,2));
    if isempty(kc) then
      Cmenu='';%pt=[];return
    elseif windows(kc,1)<0 then
      kpal=-windows(kc,1)
      palette=palettes(kpal)
      %kk=getobj(palette,%pt)
    elseif slevel>1 then
      execstr('%kk=getobj(scs_m_'+string(windows(kc,1))+',%pt)')
    end
    if ~isempty(%kk) then
      Cmenu="Duplicate"
      Select=[%kk,%win]
    else
      Cmenu="SelectRegion"
      Select=[]
    end
  else
    %kk=getobj(scs_m,%pt)
    if ~isempty(%kk) then
      ObjSel=size(Select)
      ObjSel=ObjSel(1)
      if ObjSel<=1 then
        Cmenu=check_edge(scs_m.objs(%kk),"Move",%pt)
        if Cmenu=="Link" then
          Cmenu="Smart Link"
          Select=[]
        else
          Select=[%kk, %win]
          if Cmenu=="Move" then Cmenu="SMove", end
        end
      else
        SelectedObjs = Select(:,1)'
        if or(%kk==SelectedObjs) then
          Cmenu="SMove"
        else
          Select = [%kk, %win]
          Cmenu="SMove"
        end
      end
    else
      Cmenu="SelectRegion"
      Select=[];
      %ppt=%pt;
    end
  end
endfunction
