function CtrlSelect_()
  Cmenu=""
  if windows(find(%win==windows(:,2)),1)==100000 then
    %pt=[];return
  end
  kc=find(%win==windows(:,2))
  if isempty(kc) then
    message('This window is not an active scicos window')
    %pt=[];return
  elseif windows(kc,1)<0 then //click dans une palette
    kpal=-windows(kc,1)
    palette=palettes(kpal)
    k=getobj(palette,%pt)
    o=palette.objs(k)
  elseif %win==curwin then //click dans la fenetre courante
    k=getobj(scs_m,%pt)  
    o=scs_m.objs(k)
  elseif slevel>1 then
    execstr('k=getobj(scs_m_'+string(windows(kc,1))+',%pt)')
    execstr('o=scs_m_'+string(windows(kc,1))+'.objs(k)')
   else
    message('This window is not an active scicos window')
    %pt=[];return
  end   
 
  if ~isempty(k) then
    //pause
    if o.type=='Link' then
      gr=o.gr.children(1)
    else
      gr=o.gr
    end

    //ki=find(k==Select(:,1)&%win==Select(:,2))
    //FIXME
    //if ~isempty(Select) & Select(1,2)<>%win then
    //  Select=list()
    //end
    //if isempty(ki) then
    //  Select=[Select;[k,%win]];
    //  %pt=[];return
    //else 
    //  Select(ki,:)=[];
    //  %pt=[];return
    //end

    [i,j]=Select.has[gr]
    if i then
      Select.remove[j]
    else
      Select.add_last[gr]
    end
    %pt=[];return
  else
    %pt=[];return
  end
endfunction


