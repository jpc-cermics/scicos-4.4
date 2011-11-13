function [blocks] = anim_pen(blocks,flag)
// this function is used by the block 
// PENDULUM_ANIM.sci for animation of the 
// inverted pendulum 
  win=20000+curblock()

  xold=blocks.z
  rpar=blocks.rpar
  plen=rpar(1)*1.6;csiz=rpar(2)/4;phi=rpar(3);
  rcirc=csiz/3;

  if flag==4 then 
    // initialization 
    xset("window",win)
    xclear();
    xsetech(frect=[rpar(4),rpar(6),rpar(5),rpar(7)],iso=%t)
    // segments 
    S=[cos(phi),-sin(phi);sin(phi),cos(phi)]
    XY=S*[rpar(4),rpar(5);-csiz,-csiz]
    xsegs(XY(1,:),XY(2,:)-rcirc,style=3)
    // polyline 
    x=0;theta=0;
    x1=x-csiz;x2=x+csiz;y1=-csiz;y2=csiz
    XY=S*[x1 x2 x2 x1 x1;y1,y1,y2,y2,y1]
    xfpoly(XY(1,:),XY(2,:),color=1,fill_color=5)// cart
    // arc 
    xfarc(XY(1,1),XY(2,1),rcirc,rcirc,0,360*64,color=2) //wheel
    // arc 
    xfarc(XY(1,2),XY(2,2),rcirc,rcirc,0,360*64,color=2) //wheel
    // segments 
    XY=S*[x,x+plen*sin(theta);0,0+plen*cos(theta)]//pendulum
    xsegs(XY(1,:),XY(2,:),style=2)
    
  elseif flag==2 then
    F=get_figure(win);
    Axe=F.children(1);
    x=blocks.inptr(1)(1)
    theta=blocks.inptr(2)(1);
    // polyline 
    XY=[Axe.children(2).x;Axe.children(2).y]+...
       [cos(phi)*(x-xold);sin(phi)*(x-xold)]*ones(1,5);
    Axe.children(2).x=XY(1,:);
    Axe.children(2).x=XY(2,:);
    // arc 
    Axe.children(3).x=XY(1,1);
    Axe.children(3).y=XY(2,1);
    XY=[Axe.children(2).x;Axe.children(2).y]+...
       [cos(phi)*(x-xold-rcirc);sin(phi)*(x-xold-rcirc)]*ones(1,5);
    Axe.children(4).x=XY(1,2);
    Axe.children(4).y=XY(2,2);
    // segments 
    x1=x*cos(phi);y1=x*sin(phi)
    XY=[x1,x1+plen*sin(theta);y1,y1+plen*cos(theta)]
    Axe.children(5).x=XY(1,:);
    Axe.children(5).y=XY(2,:);
    // blocks.z=x
    Axe.invalidate[];
    // xpause(0,%t);
  end
endfunction 


