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
        rect=xstringbox(scs_m.objs(i).gr)
        // check that (x,y) is inside the enclosing rectangle
        xx=(rect(1,1)-pt(1))*(rect(1,1)+(rect(1,3)-rect(1,2))-pt(1));
        yy=(rect(2,1)-pt(2))*(rect(2,1)+(rect(2,2)-rect(2,4))-pt(2));
        if  xx<0 & yy<0 then
          k=i;
          return
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

function rect=get_gr_bounds(o)
  if o.graphics.theta==0 then
    rect=o.gr.get_bounds[];
  else
    [orig,sz]=(o.graphics.orig,o.graphics.sz);

    F=get_current_figure();
    drawnow=F.draw_status[]
    if drawnow then F.draw_latter[], end

    //replace block at rotation 0
    tr=[orig(1)+sz(1)/2,orig(2)+sz(2)/2];
    theta= o.graphics.theta;
    o.gr.translate[-tr];
    o.gr.rotate[[cos(theta*%pi/180),sin(theta*%pi/180)]];
    o.gr.translate[tr];
  
    //get gr bounds wihtout rotation
    rect=o.gr.get_bounds[];

    //restore block rotation
    tr=[orig(1)+sz(1)/2,orig(2)+sz(2)/2];
    theta= -o.graphics.theta;
    o.gr.translate[-tr];
    o.gr.rotate[[cos(theta*%pi/180),sin(theta*%pi/180)]];
    o.gr.translate[tr];

    if drawnow then F.draw_now[], end
  end
endfunction
