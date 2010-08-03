function window_set_size(rect=0,a=0)
  if rect== 0 then 
    rect=dig_bound(scs_m);
    //printf('[%f,%f,%f,%f]\n',rect);
  end
  if ~isempty(rect) then
    w=rect(3)-rect(1);
    h=rect(4)-rect(2);
    if a==0 then j=1.5;a=max(600/(j*w),400/(j*h),j); end
  else
    w=600;h=400;rect=[0,0,w,h];a=1.5;
  end
  //printf('w,h,a [%f,%f,%f]\n',w,h,a);
  if new_graphics() then 
    xset("wresize",0);
    width=%zoom*w*a;height=%zoom*h*a
    printf('width,height [%f,%f]\n',width,height);
    xset('wdim',width,height);
    b=(1-1/a)/2;
    F=get_current_figure();
    if length(F.children) == 0 then  
      // first time we create an axes 
      //xsetech(wrect=[b,b,1/a,1/a],frect=rect,fixed=%t,clip=%f,axesflag=1)
      xsetech(arect=ones(1,4)*b,frect=rect,fixed=%t,clip=%f,axesflag=0,iso=%t)
    else
      A=F.children(1);
      A.arect=ones(1,4)*b
      //A.wrect = [b,b,1/a,1/a];
      A.frect = rect;
      A.fixed = %t;
      A.clip = %f;
      // rect is hidden but can be accessed 
      // through set and get 
      A.set[rect=rect]; 
    end
    // center the graphic viewport inside the graphic window.
    r=xget('wpdim');
    %XSHIFT=max((width-r(1))/2,0)
    %YSHIFT=max((height-r(2))/2,0)
    xset('viewport',%XSHIFT,%YSHIFT)
    F.invalidate[];
    F.process_updates[];
  else
    xclear();
    xset("wresize",0);
    width=%zoom*w*a;height=%zoom*h*a
    xset('wdim',width,height);
    b=(1-1/a)/2;
    xsetech([b,b,1/a,1/a],rect)
    // center the graphic viewport inside the graphic window.
    r=xget('wpdim');
    %XSHIFT=max((width-r(1))/2,0)
    %YSHIFT=max((height-r(2))/2,0)
    xset('viewport',%XSHIFT,%YSHIFT)
  end
endfunction
