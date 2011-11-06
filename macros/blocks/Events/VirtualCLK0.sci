function [x,y,typ]=VirtualCLK0(job,arg1,arg2)
// Copyright INRIA
  
    function blk_draw(sz,orig,orient,label)
      orig=arg1.graphics.orig;sz=arg1.graphics.sz;orient=arg1.graphics.flip;
      col=default_color(-1);
      // a circle with n points 
      n=100;
      xx=linspace(0,1,n);
      yy=(1/4-(xx-1/2).^2).^(1/2);
      x=orig(1)+sz(1)*[xx,xx($:-1:1)];
      y=orig(2)+sz(2)*[yy+1/2,-yy($:-1:1)+1/2];
      xpoly(x,y,color=col,thickness=2);
      w=sz(1);
      xstringb(orig(1)+w/8,orig(2)+1/2,'CLK0',sz(1)*(1-1/4),sz(2)/2,"fill")
      // clock 
      x=orig(1)*ones(1,2)+sz(1)*[1/2 1/2];
      y=(orig(2))*ones(1,2)+sz(2)*[1/2 15/16];
      xpolys(x',y',color=xget('color','blue'),thickness=2);
      x=(orig(1))*ones(1,2)+sz(1)*[1/2 1/2+(3*2^(1/2))/16];
      y=(orig(2))*ones(1,2)+sz(2)*[1/2 1/2+(3*2^(1/2))/16];
      xpolys(x',y',color=xget('color','blue'),thickness=2);
      // ports 
      xf=40
      yf=60
      nin=1;
      if ~orient then
	in=[-1/14   0
	    0       1/7
	    1/14    0
	    -1/14   0]*diag([xf,yf])
	dy=sz(1)/(nin+1)
	k=1
	xfpoly(in(:,1)+ones(4,1)*(orig(1)+sz(1)-dy*k),..
	       in(:,2)+ones(4,1)*(orig(2)-yf/7),color=col,fill_color=col)
      else
	in=[-1/14   0
	    0       -1/7
	    1/14    0
	    -1/14   0]*diag([xf,yf])
	dy=sz(1)/(nin+1)
	k=1;
	xfpoly(in(:,1)+ones(4,1)*(orig(1)+sz(1)-dy*k),..
	       in(:,2)+ones(4,1)*(orig(2)+sz(2)+yf/7),color=col,fill_color=col)
      end
    endfunction
      
  x=[];y=[];typ=[]

  select job
   case 'plot' then
    function noports(o) ;endfunction
    standard_draw(arg1,%f,noports);
   case 'getinputs' then
    orig=arg1.graphics.orig;
    sz=arg1.graphics.sz;
    if arg1.graphics.flip then
      x=orig(1)+sz(1)/2
      y=orig(2)+sz(2)
    else
      x=orig(1)+sz(1)/2
      y=orig(2)
    end
    typ=-ones_deprecated(x) //undefined type
   case 'getoutputs' then
    x=[];y=[];typ=[]
   case 'getorigin' then
    [x,y]=standard_origin(arg1)
   case 'set' then
    x=arg1;
   case 'define' then
    model=scicos_model()
    model.sim='vrtclk0'
    model.evtin=1
    model.opar=list()
    model.ipar=[]
    model.blocktype='d'
    model.firing=-1
    model.dep_ut=[%f %f]
    exprs=[]
    gr_i="blk_draw(sz,orig,orient,model.label)";
    x=standard_define([2 2],model,exprs,gr_i,'VirtualCLK0');
  end
endfunction
