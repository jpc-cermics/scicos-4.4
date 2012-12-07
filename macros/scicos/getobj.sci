function [k,wh]=getobj(scs_m,pt)

  // we use C version of getobj.
  // For debugging and improvement
  // use the macro version below

  [k,wh]=scicos_getobj(scs_m,pt)
  return

  k  = []
  wh = []
  n  = length(scs_m.objs)

  for i=n:-1:1
    o=scs_m.objs(i)
    if o.type=="Block" then
      [data]=get_data_block(o,pt)
      if data(1)<0 & data(2)<0 then
        k=i;
        //second pass to detect crossing link
        if ~(o.gui=="IMPSPLIT_f" || o.gui=="SPLIT_f" ||...
             o.gui=="BUSSPLIT"   || o.gui=="CLKSPLIT_f") then
          for j=(i+1):n
            o=scs_m.objs(j);
            if o.type=="Link" then
              [data,wh]=get_data_link(o,pt)
              if data<0 then 
                k=j;
                return 
              end
            end
          end
        end
        return;
      end
    end
  end

  for i=n:-1:1
    o=scs_m.objs(i);
    select o.type
      case "Text" then
        [data]=get_data_text(o,pt)
        if data(1)<0 & data(2)<0 then
          k=i;
          return;
        end

      case "Link" then
        [data,wh]=get_data_link(o,pt)
        if data<0 then
          k=i;
          return 
        end
    end
  end
endfunction

function [k]=getblock(scs_m,pt)

  // we use C version of getblock.
  // For debugging and improvement
  // use the macro version below

  [k]=scicos_getblock(scs_m,pt)
  return

  k = []
  n = length(scs_m.objs)

  for i=n:-1:1
    o=scs_m.objs(i)
    if o.type =='Block' then
      [data]=get_data_block(o,pt)
      if data(1)<0 & data(2)<0 then
        k=i;
        return
      end
    end
  end
endfunction

function [k,wh]=getblocklink(scs_m,pt)

  // we use C version of getblocklink.
  // For debugging and improvement
  // use the macro version below

  [k,wh]=scicos_getblocklink(scs_m,pt)
  return

  k  = []
  wh = []
  n  = length(scs_m.objs)

  for i=n:-1:1
    o=scs_m.objs(i)
    if o.type =='Block' then
      [data]=get_data_block(o,pt)
      if data(1)<0 & data(2)<0 then
        k=i;
        return
      end

    elseif o.type =='Link' then
      [data,wh]=get_data_link(o,pt)
      if data<0 then
        k=i;
        return
      end
    end
  end
endfunction

function [in,out] = getobjs_in_rect(scs_m,ox,oy,w,h)

  // we use C version of getobjs_in_rect.
  // For debugging and improvement
  // use the macro version below

  [in,out]=scicos_getobjs_in_rect(scs_m,ox,oy,w,h)
  return

  in  = []
  out = []
  ok  = %f

  for i=1:size(scs_m.objs)
    ok = %f;
    o=scs_m.objs(i)
    if o.type=='Block' || o.type=='Text' then
      rect = o.gr.get_bounds[]
      orig = [rect(1) rect(2)]
      sz   = [rect(3)-rect(1) rect(4)-rect(2)]
      if (ox <= orig(1)) & ...
         (oy >= orig(2)+sz(2)) & ...
         ((ox+w) >= (orig(1)+sz(1))) & ...
         ((oy-h) <= orig(2)) then
           ok=%t
           in=[in i]
      end
    elseif o.type=='Link' then
      if (ox <= min(o.xx)) & ...
         (oy >= max(o.yy)) & ...
         ((ox+w) >= max(o.xx)) & ...
         ((oy-h) <= min(o.yy)) then
           ok=%t
           in=[in i]
      end
    end
    if ~ok then out=[out i],end
  end
endfunction

function [data]=get_data_block(o,pt)
  eps_blk = 3;

  rect = o.gr.get_bounds[];

  orig = [rect(1) rect(2)]-eps_blk;
  sz   = [rect(3)-rect(1) rect(4)-rect(2)]+2*eps_blk;

  data = [(orig(1)-pt(1))*(orig(1)+sz(1)-pt(1)),..
          (orig(2)-pt(2))*(orig(2)+sz(2)-pt(2))];
endfunction

function [data]=get_data_text(o,pt)
  // returns the enclosing rectangle of the string 
  // taking care of angles
  [orig,sz] = (o.graphics.orig,o.graphics.sz);

  xxx = rotate([pt(1);pt(2)],..
               -o.graphics.theta * %pi/180,...
               [orig(1)+sz(1)/2;orig(2)+sz(2)/2]);
  x = xxx(1);
  y = xxx(2);

  data = [(orig(1)-x)*(orig(1)+sz(1)-x),..
          (orig(2)-y)*(orig(2)+sz(2)-y)];
endfunction

function [data,ind]=get_data_link(o,pt)
  eps_lnk = 4;

  [data,ptp,ind] = dist2polyline(o.xx,o.yy,pt);

  data = data-eps_lnk;
endfunction
