function SelectRegion_()
  Cmenu=''
  Select=[]
  F=get_current_figure()
  F.draw_now[]
  [rect,button]=rubberbox([%pt(1);%pt(2);0;0])
  if button==2 then // right button exit OR active window has been closed
    return
  end
  ox=rect(1),oy=rect(2),w=rect(3),h=rect(4);
  clear rect
  kc = find(%win==windows(:,2))
  if isempty(kc) then
    message('This window is not an active palette');
    return
  elseif windows(kc,1)<0 then //click inside a palette window
    kpal=-windows(kc,1)
    [in,out]=get_objs_in_rect(palettes(kpal),ox,oy,w,h)
  elseif %win==curwin then //click inside the current window
    [in,out]=get_objs_in_rect(scs_m,ox,oy,w,h)
  elseif slevel>1 then
    execstr('[in,out]=get_objs_in_rect(scs_m_'+string(windows(kc,1))',ox,oy,w,h)
  else
    return
  end
  clear ox;clear oy;clear w;clear h;
  if ~isempty(in) then
    Select=[in',%win*ones(size(in,2),1)]
  end
  clear in; clear out;
endfunction

function [in,out] = get_objs_in_rect(scs_m,ox,oy,w,h)
  in=[];out=[];ok=%f;
  for k=1:size(scs_m.objs)
    ok = %f;
    o=scs_m.objs(k)
    if o.type=='Block'|o.type=='Text' then
      if (ox <= o.graphics.orig(1)) & ...
         (oy >= o.graphics.orig(2)+o.graphics.sz(2)) & ...
         ((ox+w) >= (o.graphics.orig(1)+o.graphics.sz(1))) & ...
         ((oy-h) <= o.graphics.orig(2)) then
           ok=%t
           in=[in k]
      end
    elseif o.type=='Link' then
      if (ox <= max(o.xx)) & ...
         (oy >= max(o.yy)) & ...
         ((ox+w) >= max(o.xx)) & ...
         ((oy-h) <= min(o.yy)) then
           ok=%t
           in=[in k]
      end
    end
    if ~ok then out=[out k],end
  end
endfunction

function [rect,btn]=rubberbox(rect)
  rep(3)=-1;
  xc=rect(1);
  yc=rect(2);
  F=get_current_figure();
  F.start_compound[];
  xrect(xc,yc,1,1,color=default_color(0),thickness=0);
  C=F.end_compound[];
  R=C.children(1);
  R.invalidate[];
  while rep(3)==-1 do
    F.process_updates[];
    rep=xgetmouse(clearq=%f,cursor=%f,getrelease=%t);
    R.invalidate[];
    xc1=rep(1);yc1=rep(2)
    R.x=min(xc,xc1)
    R.y=max(yc,yc1)
    R.w=abs(xc-xc1)
    R.h=abs(yc-yc1)
    R.invalidate[];
  end
  F.remove[C];
  rect=[R.x,R.y,R.w,R.h]
  btn=rep(3)
endfunction
