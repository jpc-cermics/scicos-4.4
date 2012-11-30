function [k,wh]=getobj(scs_m,pt)
  k  = []
  wh = []
  n  = length(scs_m.objs)

  a=tic();

  for i=n:-1:1
    o=scs_m.objs(i)
    if o.type=="Block" then
      [data]=get_data_block(o,pt)
      if data(1)<0 & data(2)<0 then
        k=i;
        //second pass to detect crossing link
        if ~(o.gui=="IMPSPLIT_f" || o.gui=="SPLIT_f" ||...
             o.gui=="BUSSPLIT"   || o.gui=="CLKSPLIT_f") then
          for j=i:n
            o=scs_m.objs(j);
            if o.type=="Link" then
              [data,wh]=get_data_link(o,pt)
              if data<0 then 
                k=j;
                printf("getobj in blk %s (find a lnk) : %f\n",scs_m.objs(i).gui,toc()-a);
                return 
              end
            end
          end
        end
        printf("getobj in blk %s : %f\n",scs_m.objs(i).gui,toc()-a);
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
          printf("getobj in txt : %f\n",toc()-a);
          return;
        end

      case "Link" then
        [data,wh]=get_data_link(o,pt)
        if data<0 then
          k=i;
          printf("getobj in lnk : %f\n",toc()-a);
          return 
        end
    end
  end
  printf("getobj in void : %f\n",toc()-a);
endfunction

function [k]=getblock(scs_m,pt)
  k = []
  n = length(scs_m.objs)

  a=tic();

  for i=n:-1:1
    o=scs_m.objs(i)
    if o.type =='Block' then
      [data]=get_data_block(o,pt)
      if data(1)<0 & data(2)<0 then
        k=i;
        printf("getblock : %f\n",toc()-a);
        return
      end
    end
  end
  printf("getblock in void : %f\n",toc()-a);
endfunction

function [k,wh]=getblocklink(scs_m,pt)
  k  = []
  wh = []
  n  = length(scs_m.objs)

  a=tic();

  for i=n:-1:1
    o=scs_m.objs(i)
    if o.type =='Block' then
      [data]=get_data_block(o,pt)
      if data(1)<0 & data(2)<0 then
        k=i;
        printf("getblocklink in blk : %f\n",toc()-a);
        return
      end

    elseif o.type =='Link' then
      [data,wh]=get_data_link(o,pt)
      if data<0 then
        k=i;
        printf("getblocklink in lnk : %f\n",toc()-a);
        return
      end
    end
  end
  printf("getblocklink in void : %f\n",toc()-a);
endfunction

function [in,out] = getobjs_in_rect(scs_m,ox,oy,w,h)
  in  = []
  out = []
  ok  = %f

  a=tic();

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
  printf("getobjs_in_rect : %f\n",toc()-a);
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

  xx = o.xx;
  yy = o.yy;

  [data,ptp,ind] = dist2polyline(xx,yy,pt);

  data = data-eps_lnk;
endfunction

// function rect=get_gr_bounds(o)
//   rect=o.gr.get_bounds[];
//   if o.graphics.theta<>0 then
//     if o.type.equal['Text'] then
//       orig = [rect(1) rect(2)];
//       sz   = [rect(3)-rect(1) rect(4)-rect(2)];
//     else
//       [orig,sz]=(o.graphics.orig,o.graphics.sz);
//     end
// 
//     F=get_current_figure();
//     drawnow=F.draw_status[]
//     if drawnow then F.draw_latter[], end
// 
//     //replace block at rotation 0
//     tr=[orig(1)+sz(1)/2,orig(2)+sz(2)/2];
//     theta=o.graphics.theta;
//     o.gr.translate[-tr];
//     o.gr.rotate[[cos(theta*%pi/180),sin(theta*%pi/180)]];
//     o.gr.translate[tr];
//   
//     //get gr bounds wihtout rotation
//     rect=o.gr.get_bounds[];
// 
//     //restore block rotation
//     tr=[orig(1)+sz(1)/2,orig(2)+sz(2)/2];
//     theta=-o.graphics.theta;
//     o.gr.translate[-tr];
//     o.gr.rotate[[cos(theta*%pi/180),sin(theta*%pi/180)]];
//     o.gr.translate[tr];
// 
//     if drawnow then F.draw_now[], end
//   end
// endfunction
