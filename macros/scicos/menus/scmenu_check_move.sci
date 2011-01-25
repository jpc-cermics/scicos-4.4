function MoveLink_()
  if windows(find(%win==windows(:,2)),1)==100000 then //** Navigator window:
    Cmenu='';%pt=[];return;
  elseif %win<>curwin then //** the press is not in the current window 
    %kk=[]
    kc=find(%win==windows(:,2));
    if isempty(kc) then //** the press is not inside an scicos actiview window
      Cmenu="";%pt=[];return;
    elseif windows(kc,1)<0 then //** the press is inside a palette 
      kpal=-windows(kc,1); 
      palette=palettes(kpal);
      %kk=getobj(palette,%pt); //** get the obj inside the palette
    elseif slevel>1 then //** the press is over a block inside a superblock window
      execstr('%kk=getobj(scs_m_'+string(windows(kc,1))+',%pt)')
    end
    if ~isempty(%kk) then //** press over a valid block 
      Cmenu="Duplicate"
      //Select=[%kk,%win] //ALANDISABLEITFORTHATTIME
    else //** press in the void   
      //Cmenu="SelectRegion" //ALANDISABLEITFORTHATTIME
      //Select=[]
    end
  else //** the press is in the current window
    %kk=getobj(scs_m,%pt)
    if ~isempty(%kk) then
      ObjSel=size(Select);
      ObjSel=ObjSel(1);
      if ObjSel<=1 then //** with zero or one object already selected 
        Cmenu=check_edge(scs_m.objs(%kk),"Move",%pt);
        if Cmenu=="Link" then
          Select=[]
        else
	  Select=[%kk,%win];
        end 
      else //** more than one object is selected 
        SelectedObjs = Select(:,1)';
        if or(%kk==SelectedObjs) then //** check if the user want to move the aggregate
          Cmenu="Move";
        else
          Cmenu="Move";
	  Select=[%kk,%win];
        end 
      end    
    else //** if the press is in the void of the current window 
      Cmenu="SelectRegion";
      %ppt=%pt;Select=[];
    end
  end
endfunction
