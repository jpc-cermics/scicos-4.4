function [blocks] = bplatform2(blocks,flag)
// this function is used in the Modelica demo
// Ball_Platform.

  win=20000+curblock();
  xold=blocks.z;
  rpar=blocks.rpar;
  plen=rpar(1);csiz=rpar(2);phi=rpar(3);
  xmin=rpar(4);xmax=rpar(5);ymin=rpar(6);ymax=rpar(7);
  rcirc=1;
  tplat=0.2;
  
  if flag==4 then 
    // initialization
    xset("window",win)
    xclear()
    xsetech(frect=rpar(4:7),iso=%t)
    x0=(xmin+xmax)/2;
    y0=(ymin+ymax)/2;
    XY1=[x0-3, x0+3,x0+3,x0-3,x0-3]
    XY2=[y0, y0,y0-2*tplat,y0-2*tplat,y0]
    xfpoly(XY1,XY2,fill_color=3,color=0)
    xfarc(x0-rcirc/2,y0+6,rcirc,rcirc,0,360*64,background=2,color=2)
    XY1=[xmin, xmax];
    XY2=[ymin, ymin];
    xpoly(XY1,XY2,type="lines",close=%f) //Ground
    ym=y0-2*tplat;
    d0=ym/9;
    XY1=[x0,x0-0.2,x0+0.2 ,x0-0.2 ,x0+0.2, x0-0.2 ,x0+0.2 ,x0-0.2 , x0+0.2,x0     ];
    XY2=[ym,ym-d0 ,ym-2*d0,ym-3*d0,ym-4*d0,ym-5*d0,ym-6*d0,ym-7*d0,ym-8*d0,ym-9*d0];
    xpoly(XY1,XY2,type="lines",close=%f,color=0);
  elseif flag==2 then
    // 
    F=get_figure(win);
    yplat=blocks.inptr(1)(1)
    yball=blocks.inptr(2)(1)
    Axe=F.children(1);
    x0=(xmin+xmax)/2;
    ym=yplat-2*tplat;
    d0=ym/9;
    XY2=[ym,ym-d0 ,ym-2*d0,ym-3*d0,ym-4*d0,ym-5*d0,ym-6*d0,ym-7*d0,ym-8*d0,ym-9*d0];  
    Axe.children(4).y=XY2;// Resort
    //Axe.children(3).data(2)=;// Ground
    Axe.children(2).y=yball+rcirc;// Ball
    Axe.children(1).y=[yplat, yplat,yplat-2*tplat,yplat-2*tplat,yplat];// platform
    Axe.invalidate[];
  end
endfunction


