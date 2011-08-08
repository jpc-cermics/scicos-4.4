function CtrlSelect_()
// In fact this is activated by shift-press
//
  Cmenu=''
  if windows(find(%win==windows(:,2)),1)==100000 then
    %pt=[];return
  end
  kc=find(%win==windows(:,2))
  if isempty(kc) then
    message('This window is not an active scicos window')
    %pt=[];return
  elseif %win==curwin then //click dans la fenetre courante
    k=getobj(scs_m,%pt)
  elseif slevel>1 then
    execstr('k=getobj(scs_m_'+string(windows(kc,1))+',%pt)')
  else
    message('This window is not an active scicos window')
    %pt=[];return
  end   
  if ~isempty(k) then
    if ~isempty(Select) then
      ki=find(k==Select(:,1)&%win==Select(:,2))
    else
      Select=[Select;[k,%win]];
      %pt=[];return
    end
    if ~isempty(Select) & Select(1,2)<>%win then
      Select=[]
    end
    if isempty(ki) then
      Select=[Select;[k,%win]];
      %pt=[];return
    else 
      Select(ki,:)=[];
      %pt=[];return
    end
  else
    %pt=[];return
  end
endfunction
