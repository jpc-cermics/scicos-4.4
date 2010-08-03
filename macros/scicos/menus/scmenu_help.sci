function Help_()
  Cmenu='Open/Set'
  xinfo('Click on object or menu to get help')
  do_help()
  xinfo(' ')
endfunction

function do_help()
// Copyright INRIA
  while %t do
    [btn,%pt,cwin,Cmenu]=cosclick(%f)
    if Cmenu<>"" then
      name=Cmenu
      nm=1
      break
    elseif cwin==curwin then 
      xc=%pt(1);yc=%pt(2);%pt=[]
      k=getobj(scs_m,[xc;yc])
      if ~isempty(k) then
	o=scs_m.objs(k)
	name=o.gui
	nm=0
	break
      end
    elseif or(windows(find(windows(:,1)<0),2)==cwin) then
      kwin=find(windows(:,2)==cwin)
      pal=palettes(-windows(kwin,1))
      xc=%pt(1);yc=%pt(2);%pt=[]
      k=getobj(pal,[xc;yc])
      if ~isempty(k) then
	o=pal(k)
	name=o.gui
	nm=0
	break
      end
    end
  end

  if nm==0 then
    xhelp(name) // XXXXX
    return
  end

  if execstr('mess=%scicos_help(name)',errcatch=%t)==%f then
    mess='No help available on this topic. Sorry.';
  end
  message(mess)  
endfunction
