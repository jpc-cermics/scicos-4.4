function rotate_compound(sel_x, sel_y, sel_w, sel_h, blk, theta, C)
//** rotate compound : do a rotation of graphics elements
//** in a compound
//**
//** input : -sel_x, sel_y, sel_w, sel_h : give the coordinate
//**          of the box surrounding the compound
//**          (lower point,width, height).
//**          The rotation will be done from the center
//**          [sel_x+sel_w/2;sel_y-sel_h/2]
//**
//**         - blk the index of the compound (the i child of axe)
//**
//**         - theta : angle of rotation given in degree
//**                   in trigonometric wise
//**
//** output : nothing. This function directly work in the figure handle
//**          gcf()
  printf('rotate_compound\n');
  //C=hdl.children(blk)
  for i=1:size(C.children)
    select type(C.children(i),'string')
     case "GrRect" then
      printf("GrRect\n");
      x=C.children(i).x;
      y=C.children(i).y;
      w=C.children(i).w;
      h=C.children(i).h;
      C.children(i).show=%f
      xxx = rotate([x, x  , x+w, x+w;...
		    y, y-h, y-h, y],theta*%pi/180,...
		   [sel_x+sel_w/2;sel_y-sel_h/2])
      xpoly(xxx(1,:),xxx(2,:),type="lines",close=%t);
      
      case "Grstring" then
        printf("Grstring\n");
//pause

//         rect=stringbox(C.children(i).text,C.children(i).x,C.children(i).y)
//         x=rect(1,2);
//         y=rect(2,2);
//         w=rect(1,3)-rect(1,2);
//         h=rect(2,2)-rect(2,4);
// 
//         xxx=rotate([x,x,x+w,x+w;...
//                     y,y-h,y-h, y],theta*%pi/180,...
//                     [sel_x+sel_w/2;sel_y-sel_h/2])

        //rect=stringbox(C.children(i).text,C.children(i).x,C.children(i).y)
        //x=C.children(i).x
        //y=C.children(i).y

        //xxx=rotate([x;y],theta*%pi/180,...
        //            [sel_x+sel_w/2;sel_y-sel_h/2])

        //C.children(i).x=xxx(1)
        //C.children(i).y=xxx(2)
        C.children(i).angle=theta

      case "Polyline" then
        printf("Polyline\n");
        xxx=rotate([C.children(i).x(:)';C.children(i).y(:)'],...
                    theta*%pi/180,...
                    [sel_x+sel_w/2;sel_y-sel_h/2])
        C.children(i).x=xxx(1,:)'
        C.children(i).y=xxx(2,:)'

      case "Compound" then
        printf("Compound\n");
        rotate_compound(sel_x, sel_y, sel_w, sel_h,i,theta,C.children(i))

      case "Segments" then
        printf("Segments\n");
        xxx=rotate([C.children(i).x(:)';C.children(i).y(:)'],...
                    theta*%pi/180,...
                    [sel_x+sel_w/2;sel_y-sel_h/2])
        C.children(i).x=xxx(1,:)'
        C.children(i).y=xxx(2,:)'

      case "Arrows" then
        printf("Arrows\n");
        for j=1:size(C.children(i).x,1)
          xxx=rotate([C.children(i).x(j,:);C.children(i).y(j,:)],...
                      theta*%pi/180,...
                      [sel_x+sel_w/2;sel_y-sel_h/2])
          C.children(i).x(j,:)=xxx(1,:)
          C.children(i).y(j,:)=xxx(2,:)
        end

      case "GrArc" then
        printf("GrArc\n");
        x=C.children(i).x;
        y=C.children(i).y;
        w=C.children(i).w;
        h=C.children(i).h;
        xxx = rotate([x+w/2; y-h/2],theta*%pi/180,...
                     [sel_x+sel_w/2;sel_y-sel_h/2])
        C.children(i).x=xxx(1,1)-w/2
        C.children(i).y=xxx(2,1)+h/2
      else
        printf("TODO : %s\n",type(C.children(i),'string'));
    end
  end
endfunction
