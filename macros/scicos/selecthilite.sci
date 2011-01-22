function selecthilite(Select, flag)
  if isempty(Select) then
    return
  end
  for i=1:size(Select,1)
    [junk, win, o]=get_selection(Select(i,:),0,0)
    if ~isempty(o) then
      if o.type=='Link' then
        ogr=o.gr.children(1)
      else
        ogr=o.gr
      end
      ogr.hilited=flag;
      ogr.invalidate[];
    end
  end
endfunction

function [%pt,%win,o] = get_selection(Select,%pt,%win)
  num = Select(1); win=Select(2)
  kc = find(win==windows(:,2))
  if isempty(kc) then
    o = []; return // window no longer active
  elseif windows(kc,1)<0 then //palette
    scs_m=palettes(-windows(kc,1))
  elseif win==curwin then //selected object in current window
    // scs_m is fine
  elseif slevel>1 then
    execstr('scs_m=scs_m_'+string(windows(kc,1)))
  end
  if num>size(scs_m.objs) then
     o = []; return
  end
  o = scs_m.objs(num)
  if o.type=='Block' then
    o = disconnect_ports(o)
    [orig,sz] = (o.graphics.orig,o.graphics.sz)
    %pt=orig(:)+sz(:)/2
  
  elseif o.type=='Text'  then  
    [orig,sz] = (o.graphics.orig,o.graphics.sz)
    %pt = orig(:)+sz(:)/2
  
  elseif o.type=='Link' then  
    %pt=[(o.xx(1)+o.xx(2))/2,(o.yy(1)+o.yy(2))/2] //middle of first
                                                  //segment
  else
    o=[]  // perhaps deleted
  end
  %win = win
endfunction
