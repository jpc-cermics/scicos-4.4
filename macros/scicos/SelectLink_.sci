function SelectLink_()
  Select=[]; SelectRegion=list()
  if windows( find(%win==windows(:,2)), 1 )==100000 then
    Cmenu='';%pt=[]
    return
  end
  kc=find(%win==windows(:,2))
  if isempty(kc) then
    Cmenu='';%pt=[];
    return
  elseif windows(kc,1) < 0 then //click dans une palette
    kpal=-windows(kc,1)
    palette=palettes(kpal)
    k=getobj(palette,%pt)
    if ~isempty(k) then 
      Select=[k,%win];
      Cmenu='';%pt=[];
      return
    else
      Cmenu='';%pt=[];
      return
    end
  elseif %win==curwin then // click dans la fenetre courante
    k=getobj(scs_m,%pt)
    if ~isempty(k) then
      Cmenu=check_edge(scs_m.objs(k),'',%pt);
      if Cmenu=='' then //** if is NOT over a port 
        Select=[k,%win];
        Cmenu='';%pt=[];
        return
      end       
    else //** click in the void 
      Cmenu=''; %ppt=%pt; %pt=[];
      return
    end
  elseif slevel>1 then
    execstr('k=getobj(scs_m_'+string(windows(kc,1))+',%pt)');
    if ~isempty(k) then
      Select=[k,%win];
      Cmenu='';
      return
    else  //** if the click in in the void 
      Cmenu='';%pt=[];
      return
    end
  else 
    message('2 - This window is not an active scicos window')
    Cmenu='';%pt=[];
    return
  end
endfunction
