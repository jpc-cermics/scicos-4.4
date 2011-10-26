function Popup_()
// activated by button events in scicos window %win 
// state_var = 1 : right click over a valid object inside the CURRENT Scicos Window
// state_var = 2 : right click in the void of the CURRENT Scicos Window
// state_var = 3 : right click over a valid object inside a PALETTE or NOT a CURRENT Scicos Window
// XXX some hilight selections through popup are performed here 
    
  state_var=0
  state_pal=0
  kc=find(%win==windows(:,2))
  
  sel_items=size(Select)
  obj_selected=sel_items(1)
  if obj_selected > 1 then
    if isempty(kc) then
      // not an active scicos window 
      message("This window is not an active scicos window")
      Cmenu='';%pt=[];%ppt=[];Select=[];
      return
    elseif windows(kc,1)<0 then
      // Palette -----------------------------------
      state_var=3
      state_pal=1
    elseif isequal(%win,curwin) then
      k = getobj(scs_m,%pt)
      // popup in the CURRENT Scicos window : Main Scicos Window (not inside a superblock) ----------
      if ~isempty(k) then
        //check if popup is on a selected objects
        if ~isempty(find(Select(:,1)==k)) then
          state_var=1
        else
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
          selecthilite(Select,%f);
          Select=[k %win]
          selecthilite(Select,%t)
        end
      else
        //** popup in the void
        state_var=2
        %ppt=%pt
        if ~isempty(Select) then
          selecthilite(Select,%f);
          Select=[]
        end
      end
    elseif slevel>1 then
      //** popup in a SuperBlock Scicos Window that is NOT the current window ----------
      state_var=3
    else 
      //** in any other case -------------------------------  
      message("This window is not an active scicos window")
      Cmenu='';%pt=[];%ppt=[];Select=[];
      return
    end
  else
    //** Zero or one single object selected by pop up ------------
    if isempty(kc) then
      // not a scicos window -------------------
      message("This window is not an active scicos window")
      Cmenu='';%pt=[];%ppt=[];Select=[];
      return
    elseif windows(kc,1)<0 then
      //** Palette -----------------------------------
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
    elseif isequal(%win,curwin) then
      // popup in the CURRENT Scicos window : Main Scicos Window (not inside a superblock) ----------
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
        selecthilite(Select,%f);
        Select=[k,%win]
        selecthilite(Select,%t);
      else
        //** popup in the void
        state_var=2
        %ppt=%pt
        if ~isempty(Select) then
          selecthilite(Select,%f);
          Select=[]
        end
      end
    elseif slevel>1 then
      // popup in a SuperBlock Scicos Window that is NOT the current window ----------
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
  // activate the popup.
  [Cmenu,args]=mpopup(%scicos_lhb_list(state_var))
  if type(args,'short')=='h' then 
    // XXX this is ugly but we need a way to transmit args
    btn=args;
  end
  if Cmenu=='' then
    %pt=[];%ppt=[];
    selecthilite(Select,%f);
    Select=[];
  end
endfunction
