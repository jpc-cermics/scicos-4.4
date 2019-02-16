function [blocks] = anim_pen(blocks,flag)
  // This function is used by the block PENDULUM_ANIM.sci
  // it is the simulation function which draws an animation of the
  // inverted pendulum 
  win=20000+curblock()
  
  xold=blocks.z
  rpar=blocks.rpar
  plen=rpar(1)*1.6;csiz=rpar(2)/4;phi=rpar(3);
  rcirc=csiz/3;

  if flag==4 then 
    x=0;theta=0;
    // initialization
    xset("window",win)
    xclear();
    xsetech(frect=[rpar(4),rpar(6),rpar(5),rpar(7)],iso=%t)
    // segments 
    S=[cos(phi),-sin(phi);sin(phi),cos(phi)]
    XY=S*[rpar(4),rpar(5);-csiz,-csiz]
    xsegs(XY(1,:),XY(2,:)-rcirc,style=3)
    // polyline 
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
    x=blocks.inptr(1)(1)
    theta=blocks.inptr(2)(1);
    xset("window",win)
    xclear();
    xsetech(frect=[rpar(4),rpar(6),rpar(5),rpar(7)],iso=%t)
    // segments 
    S=[cos(phi),-sin(phi);sin(phi),cos(phi)]
    XY=S*[rpar(4),rpar(5);-csiz,-csiz]
    xsegs(XY(1,:),XY(2,:)-rcirc,style=3)
    // polyline 
    // x=0;theta=0;
    x1=x-csiz;x2=x+csiz;y1=-csiz;y2=csiz
    XY=S*[x1 x2 x2 x1 x1;y1,y1,y2,y2,y1]
    xfpoly(XY(1,:),XY(2,:),color=1,fill_color=5);// cart
    // arc 
    xfarc(XY(1,1),XY(2,1),rcirc,rcirc,0,360*64,color=2); //wheel
    // arc 
    xfarc(XY(1,2),XY(2,2),rcirc,rcirc,0,360*64,color=2); //wheel
    // segments 
    XY=S*[x,x+plen*sin(theta);0,0+plen*cos(theta)];//pendulum
    xsegs(XY(1,:),XY(2,:),style=2);
    F=get_figure(win);
    F.invalidate[];
    F.process_updates[];
    xpause(10,%t);
  end
endfunction 


