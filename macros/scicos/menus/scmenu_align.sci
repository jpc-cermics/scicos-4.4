function scmenu_align()
  Cmenu='';
  sc=scs_m;
  [scs_m,changed]=do_align(scs_m);
  if changed then 
    edited=%t; scs_m_save=sc;enable_undo=%t;
  end
endfunction

function [scs_m,changed]=do_align(%pt,scs_m)
// Copyright INRIA

  //return;// XXXXX
  
  function pt=select_port(obj,x,y)
    [xout,yout,typout]=getoutputs(obj)
    [xin,yin,typin]=getinputs(obj)
    x1=[xout,xin]
    y1=[yout,yin]
    if ~isempty(x1) then
      xxx=rotate([x1;y1],...
		 obj.graphics.theta*%pi/180,...
		 [obj.graphics.orig(1)+obj.graphics.sz(1)/2;...
		  obj.graphics.orig(2)+obj.graphics.sz(2)/2]);
      x1=xxx(1,:);
      y1=xxx(2,:);
      [m,kp1]=min((y-y1).^2+(x-x1).^2)
      pt=[x1(kp1);y1(kp1)];
    else
      pt=[];
    end
  endfunction

  changed=%f;
  scs_m=scs_m;

  if isempty(Select) || isempty(find(Select(:,2)==curwin)) then
    message('Make a selection first');
    return;
  end

  // K contains selected indices restricted to curwin 
  K=Select(find(Select(:,2)==curwin),1);
  if length(K)<> 1 then 
    message('Select first only one block for alignement !');
    return;
  end
  
  o1=scs_m.objs(K);
  if o1.type<> 'Block' then
    return;
  end

  xinfo("Click on an a port of selected object") 
  // select a port of current block 
  while %t
    [btn,pt1,win,Cmenu]=cosclick()
    if win.equal[curwin] 
      k=getblock(scs_m,pt1(:));
      if k==K then 
	port1=select_port(o1,pt1(1),pt1(2))
	break;
      end 
    end
  end

  // select a port of current moving block 
  while %t
    xinfo("Click on a port of object to be moved");
    [btn,pt2,win,Cmenu]=cosclick()
    if win.equal[curwin] 
      k2=getblock(scs_m,pt2(:));
      if ~isempty(k2) && k2<>K then o2=scs_m.objs(k2);break,end
    end
  end

  // 
  if ~isempty(get_connected(scs_m,k2)) then
    hilite_obj(k2)
    message('You can only align unconnected blocks')
    unhilite_obj(k2)
    return;
  end
  // ports of o2 
  port2=select_port(o2,pt2(1),pt2(2))
  //
  if isempty(port2)|| isempty(port1) then 
    // block has no port
    graphics2=o2.graphics;orig2=graphics2.orig
    graphics1=o1.graphics;orig1=graphics1.orig
    if abs(pt1(1)- pt2(1)) < abs( pt2(1)- pt2(2)) then 
      //align vertically
      orig2(1)=orig1(1)
    else
      orig2(2)=orig1(2)
    end
  else
    graphics2=o2.graphics;orig2=graphics2.orig
    if abs(port1(1)- port2(1)) < abs(port1(2)- port2(2)) then 
      //align vertically
      orig2(1)=orig2(1)- pt2(1) + pt1(1);
    else
      //align horizontally
      orig2(2)=orig2(2)- pt2(2) + pt1(2);
    end
  end

  tr=orig2-graphics2.orig; 
  //scs_m.objs(k2).graphics.orig=orig2;
  o2.graphics.orig=orig2
  scs_m.objs(k2)=o2

  changed=%t;

  // translate object 
  o2.gr.translate[tr];
  // this should be useless 
  F=get_current_figure();
  F.draw_now[];
endfunction
