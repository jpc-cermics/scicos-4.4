function SelectRegion_()
// handler activated when selecting
// a region in a window 
// %win is the window 
  Cmenu='';
  Select=do_select_region(%win);
endfunction

function Select=do_select_region(win);
// select a region in window win 
// and when win==curwin update the menus 
// accordingly
  Select=[];
  if win<>curwin then xset('window',win);end     
  G=get_current_figure()
  G.draw_now[]
  [rect,button]=rubberbox([%pt(1);%pt(2);0;0],%t)
  if button==2 then 
    // right button exit OR active window has been closed
    return
  end
  ox=rect(1),oy=rect(2),w=rect(3),h=rect(4);
  if win<>curwin then xset('window',curwin);end 
  // now region is selected 
  kc = find(win==windows(:,2))
  if isempty(kc) then
    message('This window is not an active palette');
    return
  elseif windows(kc,1)<0 then 
    //click inside a palette window
    kpal=-windows(kc,1)
    [in,out]=get_objs_in_rect(palettes(kpal),ox,oy,w,h)
  elseif win==curwin then 
    //click inside the current window
    [in,out]=get_objs_in_rect(scs_m,ox,oy,w,h)
    scicos_menus_select_set_sensitivity(in,win) 
  elseif slevel>1 then
    //CESTFAUXICI
    execstr('[in,out]=get_objs_in_rect(scs_m_'+string(windows(kc,1))',ox,oy,w,h)
  else
    return;
  end
  if ~isempty(in) then
    Select=[in',win*ones(size(in,2),1)]
  end
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

function [rect,btn]=rubberbox(rect,edit_mode)
  select nargin
    case 0 then
      edit_mode=%f
      initial_rect=%f
    case 1 then
      initial_rect=type(rect,'short')=='m'
      if ~initial_rect then edit_mode=rect,end
    case 2 then
      initial_rect=%t
  end
  if edit_mode then 
    sel=0:2,//only button press requested
  else 
    sel=0:5,//press and click
  end
  opt=[%t edit_mode]
  first=%t
  if ~initial_rect
    while %t
      [btn,xc,yc]=xclick(0)
      if or(btn==sel) then break,end
    end
    rect(1)=xc;rect(2)=yc
  end
  if size(rect,'*')==2 then rect(3)=0;rect(4)=0,end
  rep(3)=-1;
  xc=rect(1);
  yc=rect(2);
  F=get_current_figure();
  F.start_compound[];
  xrect(xc,yc,1,1,color=default_color(0),thickness=0);
  C=F.end_compound[];
  R=C.children(1);
  R.invalidate[];
  in=[];
  while rep(3)<>-5 do
    F.process_updates[];
    rep=xgetmouse(clearq=%f,cursor=%f,getrelease=edit_mode,getmotion=%t);
    R.invalidate[];
    xc1=rep(1);yc1=rep(2)
    R.x=min(xc,xc1)
    R.y=max(yc,yc1)
    R.w=abs(xc-xc1)
    R.h=abs(yc-yc1)
    //Alan : Next lignes toberemoved if too slow
    //####
    [in_n,out] = get_objs_in_rect(scs_m,R.x,R.y,R.w,R.h)
    if ~isempty(in_n) then
      if ~isempty(in) then
        unhilite_obj(in)
      end
      hilite_obj(in_n)
      in=in_n
    else
      if ~isempty(in) then
        unhilite_obj(in)
        in=[]
      end
    end
    //####
    R.invalidate[];
  end
  F.remove[C];
  rect=[R.x,R.y,R.w,R.h]
  btn=rep(3)
endfunction
