function Popup_()
  //** state_var = 1 : right click over a valid object inside the CURRENT Scicos Window
  //** state_var = 2 : right click in the void of the CURRENT Scicos Window
  //** state_var = 3 : right click over a valid object inside a PALETTE or NOT a CURRENT Scicos Window
  state_var=0
  state_pal=0

  kc=find(%win==windows(:,2))
  sel_items=size(Select)
  obj_selected=sel_items(1)

  //** Multiple object selected ---------------
  if obj_selected > 1 then
    //** It's NOT a Scicos window -------------------
    if isempty(kc) then
      message("This window is not an active scicos window")
      Cmenu='';%pt=[];%ppt=[];Select=[];
      return
    //** Palette -----------------------------------
    elseif windows(kc,1)<0 then
      state_var=3
      state_pal=1	      
    //** popup in the CURRENT Scicos window : Main Scicos Window (not inside a superblock) ----------
    elseif %win==curwin then
      state_var=1
    //** popup in a SuperBlock Scicos Window that is NOT the current window ----------
    elseif slevel>1 then
      state_var=3
    //** in any other case -------------------------------  
    else 
      message("This window is not an active scicos window")
      Cmenu='';%pt=[];%ppt=[];Select=[];
      return
    end
  //** Zero or one single object selected by pop up ------------
  else
    //** It's NOT a Scicos window -------------------
    if isempty(kc) then
      message("This window is not an active scicos window")
      Cmenu='';%pt=[];%ppt=[];Select=[];
      return
    //** Palette -----------------------------------
    elseif windows(kc,1)<0 then
      kpal=-windows(kc,1)
      palette=palettes(kpal)
      k=getobj(palette,%pt)
      if ~isempty(k) then
        state_var=3
        state_pal=1 
        Select=[k %win]
        selecthilite(Select,%t)
      else
        //** in the void of a palette 
        Cmenu='';%pt=[];%ppt=[];Select=[];
        return
      end
    //** popup in the CURRENT Scicos window : Main Scicos Window (not inside a superblock) ----------
    elseif isequal(%win,curwin) then
      k = getobj(scs_m,%pt)
      if ~isempty(k) then
        //** popup over a valid object in the current Scicos window
        if scs_m.objs(k).type=='Block' then
          if scs_m.objs(k).model.sim(1)=='super' | scs_m.objs(k).gui=='DSUPER' then
            state_var=7
          else
            state_var=4
          end
        elseif scs_m.objs(k).type=='Link' then
          state_var=5
        elseif scs_m.objs(k).type=='Text' then
          state_var=6
        end
        Select=[k,%win]
        selecthilite(Select,%t)
      else
        //** popup in the void
        state_var=2
        %ppt=%pt
      end
    //** popup in a SuperBlock Scicos Window that is NOT the current window ----------
    elseif slevel>1 then
      execstr('k = getobj(scs_m_'+string(windows(kc,1))+',%pt)')
      if ~isempty(k) then
        Select=[k,%win];
        selecthilite(Select,%t)
        state_var=3
      else
        //** in the void 
        Cmenu='';%pt=[];%ppt=[];Select=[];
        return
      end
    else
    //** in any other case -------------------------------  
      message("This window is not an active scicos window")
      Cmenu='';%pt=[];%ppt=[];Select=[];
      return
    end
  end
  [Cmenu,args]=mpopup(%scicos_lhb_list(state_var))
  if type(args,'short')=='h' then 
    //this is ugly but we need a way to transmit args
    btn=args;
  end
  if Cmenu=='' then
    %pt=[];%ppt=[];
    selecthilite(Select,%f);
    Select=[];
  end
endfunction
