function Align_()
  Cmenu=''
  scs_m_save=scs_m;nc_save=needcompile;
  [%pt,scs_m]=prt_align(%pt,scs_m)
endfunction

function [%pt,scs_m]=prt_align(%pt,scs_m)
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
    xc1=%pt(1);yc1=%pt(2);%pt=[];
    k1=getblock(scs_m,[xc1;yc1])
    if ~isempty(k1) then o1=scs_m.objs(k1);break,end
  end
  //
  xinfo('click on a second port to be aligned with first one');
  
  while %t
    [btn,%pt2,win,Cmenu]=cosclick()
    if Cmenu<>"" then
      resume(%win=win,Cmenu=Cmenu,btn=btn);
      return;
    end
    xc2=%pt2(1);yc2=%pt2(2);
    k2=getblock(scs_m,[xc2;yc2])
    if ~isempty(k2) then o2=scs_m.objs(k2);break,end
  end
  if ~isempty(get_connected(scs_m,k2)) then
    message('Connected block can''t be aligned')
    return
  end
  //

  [xout,yout,typout]=getoutputs(o1)
  [xin,yin,typin]=getinputs(o1)
  xx1=[xout xin]
  yy1=[yout,yin]

  //
  [xout,yout,typout]=getoutputs(o2)
  [xin,yin,typin]=getinputs(o2)
  xx2=[xout xin]
  yy2=[yout,yin]
  if isempty(xx2)| isempty(yy2) then //one block has no port
    
    graphics2=o2.graphics;orig2=graphics2.orig
    graphics1=o1.graphics;orig1=graphics1.orig
    if abs(xc1-xc2)<abs(yc1-yc2) then //align vertically
      orig2(1)=orig1(1)
    else
      orig2(2)=orig1(2)
    end
  else

    [m,kp1]=min((yc1-yy1).^2+(xc1-xx1).^2)
    [m,kp2]=min((yc2-yy2).^2+(xc2-xx2).^2)
    //
    xx1=xx1(kp1);yy1=yy1(kp1)
    xx2=xx2(kp2);yy2=yy2(kp2)


    graphics2=o2.graphics;orig2=graphics2.orig
    if abs(xx1-xx2)<abs(yy1-yy2) then //align vertically
      orig2(1)=orig2(1)-xx2+xx1
    else //align horizontally
      orig2(2)=orig2(2)-yy2+yy1
    end
  end
  tr =orig2-graphics2.orig; 
  graphics2.orig=orig2
  o2.graphics=graphics2
  scs_m_save=scs_m
  scs_m.objs(k2)=o2
  // translate object 
  o2.gr.translate[tr];
  // XXX this should be useless 
  F=get_current_figure();
  F.draw_now[];
  resume(scs_m_save,enable_undo=%t,edited=%t);
endfunction
