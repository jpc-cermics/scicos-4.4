function Help_()
  Cmenu=''
  xinfo('Click on object or menu to get help')
  do_help()
  xinfo(' ')
  %pt=[]
endfunction

function do_help()
// Copyright INRIA
  
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
    k=getblock(scs_m,[xc;yc])
    if ~isempty(k) then break,end
  end
  o=scs_m.objs(k)
  name = o.gui;
  if ~execstr('mess=%scicos_help(name)',errcatch=%t) then
    mess=sprintf('No help available for %s !',name);
  end
  message(mess);
endfunction
