function GetInfo_()
  Cmenu='Open/Set'
  xinfo('Click on object  to get information on it')
  %pt=do_block_info(%pt,scs_m)
  xinfo(' ')
endfunction

function %pt=do_block_info(%pt,scs_m)
// Copyright INRIA
  L=list();
  while %t
    if isempty(%pt) then
      [btn,%pt,win,Cmenu]=cosclick()
      if Cmenu<>"" then
	resume(%win=win,Cmenu=Cmenu,btn=btn);
	return;
      end
    else
      win=%win;
    end
    xc=%pt(1);yc=%pt(2);%pt=[]
    kc=find(win==windows(:,2))
    if isempty(kc) then
      message('This window is not an active palette')
      k=[];break
    elseif windows(kc,1)<0 then //click dans une palette
      kpal=-windows(kc,1)
      palette=palettes(kpal)
      k=getobj(palette,[xc;yc])
      if ~isempty(k) then [txt,L]=get_block_info(palette,k),break,end
    elseif win==curwin then //click dans la fenetre courante
      k=getobj(scs_m,[xc;yc])
      if ~isempty(k) then [txt,L]=get_block_info(scs_m,k),break,end
    end
  end
  if length(L)<> 0 then scicos_show_info_notebook(L);end 
  //x_message_modeless(txt)
endfunction


