function [k,wh]=getobj(scs_m,pt)
  k   = []
  wh  = []
  data =[]
  n    = length(scs_m.objs)

  eps_blk = 3
  eps_lnk = 4

  for i=n:-1:1
    o=scs_m.objs(i)
    if o.type=="Block" then
      [orig,sz]=(o.graphics.orig, o.graphics.sz);

      xxx=rotate([pt(1);pt(2)],..
                  -o.graphics.theta * %pi/180,...
                 [orig(1)+sz(1)/2;orig(2)+sz(2)/2]);
      x=xxx(1);
      y=xxx(2);

      rect = get_gr_bounds(o)
      orig = [rect(1) rect(2)]-eps_blk;
      sz   = [rect(3)-rect(1) rect(4)-rect(2)]+2*eps_blk;

      data = [(orig(1)-x)*(orig(1)+sz(1)-x),..
              (orig(2)-y)*(orig(2)+sz(2)-y)]

      if data(1)<0 & data(2)<0 then
        k=i;
        return;
      end
    end
  end

  for i=n:-1:1
    o=scs_m.objs(i);
    select o.type
      case "Text" then
        // returns the enclosing rectangle of the string 
        // taking care of angles
        rect = o.gr.get_bounds[];
        orig = [rect(1) rect(2)];
        sz   = [rect(3)-rect(1) rect(4)-rect(2)];

        xxx=rotate([pt(1);pt(2)],..
                    -o.graphics.theta * %pi/180,...
                   [orig(1)+sz(1)/2;orig(2)+sz(2)/2]);
        x=xxx(1);
        y=xxx(2);

        rect = get_gr_bounds(o)
        orig = [rect(1) rect(2)];
        sz   = [rect(3)-rect(1) rect(4)-rect(2)];

        data = [(orig(1)-x)*(orig(1)+sz(1)-x),..
                (orig(2)-y)*(orig(2)+sz(2)-y)]

        if data(1)<0 & data(2)<0 then
          k=i;
          return;
        end

      case "Link" then
        xx=o.xx;
        yy=o.yy;
        [d,ptp,ind]=dist2polyline(xx,yy,pt);
        if d<eps_lnk then
          k=i;wh=ind;
          return 
        end
    end
  end
endfunction

function k=getblock(scs_m,pt)
  k    = []
  data = []
  n    = length(scs_m.objs)

  eps_blk = 3

  for i=n:-1:1
    o=scs_m.objs(i)
    if o.type =='Block' then
      [orig,sz]=(o.graphics.orig,o.graphics.sz);

      xxx=rotate([pt(1);pt(2)],...
                 -o.graphics.theta*%pi/180,...
                 [orig(1)+sz(1)/2;orig(2)+sz(2)/2]);
      x=xxx(1);
      y=xxx(2);

      rect = get_gr_bounds(o)
      orig = [rect(1) rect(2)]-eps_blk;
      sz   = [rect(3)-rect(1) rect(4)-rect(2)]+2*eps_blk;

      data = [(orig(1)-x)*(orig(1)+sz(1)-x),..
              (orig(2)-y)*(orig(2)+sz(2)-y)]

      if data(1)<0 & data(2)<0 then
        k=i;
        return
      end
    end
  end
endfunction

function [k,wh]=getblocklink(scs_m,pt)
  k   = []
  wh  = []
  data =[]
  n    = length(scs_m.objs)

  eps_blk = 3
  eps_lnk = 4

  for i=n:-1:1
    o=scs_m.objs(i)
    if o.type =='Block' then
      [orig,sz]=(o.graphics.orig,o.graphics.sz);

      xxx = rotate([pt(1);pt(2)],...
                    -o.graphics.theta*%pi/180,...
                   [orig(1)+sz(1)/2;orig(2)+sz(2)/2])
      x=xxx(1);
      y=xxx(2);

      rect = get_gr_bounds(o)
      orig = [rect(1) rect(2)]-eps_blk;
      sz   = [rect(3)-rect(1) rect(4)-rect(2)]+2*eps_blk;

      data = [(orig(1)-x)*(orig(1)+sz(1)-x),..
              (orig(2)-y)*(orig(2)+sz(2)-y)]

      if data(1)<0 & data(2)<0 then
        k=i
        return
      end

    elseif o.type =='Link' then
      xx=o.xx;yy=o.yy;
      [d,ptp,ind]=dist2polyline(xx,yy,pt)
      if d<eps_lnk then
        k=i;wh=ind;
        return
      end
    end
  end
endfunction

function [in,out] = get_objs_in_rect(scs_m,ox,oy,w,h)
  in=[];out=[];ok=%f;
  for k=1:size(scs_m.objs)
    ok = %f;
    o=scs_m.objs(k)
    if o.type=='Block' || o.type=='Text' then
      rect = o.gr.get_bounds[]
      orig = [rect(1) rect(2)]
      sz   = [rect(3)-rect(1) rect(4)-rect(2)]
      if (ox <= orig(1)) & ...
         (oy >= orig(2)+sz(2)) & ...
         ((ox+w) >= (orig(1)+sz(1))) & ...
         ((oy-h) <= orig(2)) then
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

function rect=get_gr_bounds(o)
  rect=o.gr.get_bounds[];
  if o.graphics.theta<>0 then
    if o.type.equal['Text'] then
      orig = [rect(1) rect(2)];
      sz   = [rect(3)-rect(1) rect(4)-rect(2)];
    else
      [orig,sz]=(o.graphics.orig,o.graphics.sz);
    end

    F=get_current_figure();
    drawnow=F.draw_status[]
    if drawnow then F.draw_latter[], end

    //replace block at rotation 0
    tr=[orig(1)+sz(1)/2,orig(2)+sz(2)/2];
    theta=o.graphics.theta;
    o.gr.translate[-tr];
    o.gr.rotate[[cos(theta*%pi/180),sin(theta*%pi/180)]];
    o.gr.translate[tr];
  
    //get gr bounds wihtout rotation
    rect=o.gr.get_bounds[];

    //restore block rotation
    tr=[orig(1)+sz(1)/2,orig(2)+sz(2)/2];
    theta=-o.graphics.theta;
    o.gr.translate[-tr];
    o.gr.rotate[[cos(theta*%pi/180),sin(theta*%pi/180)]];
    o.gr.translate[tr];

    if drawnow then F.draw_now[], end
  end
endfunction
