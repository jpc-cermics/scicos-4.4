function window_set_size(win,viewport=[-1,-1],invalidate=%t,popup_dim=%t,read=%f,margins=%t)
// fix wdim adapted scs_m
// if viewport is [-1,-1] the view is centered 
//    else viewport gives the viewport position
// if invalidate is %t Figure is invalidated
// if read is %t values are read in scs_m 
// if popup_dim is %t the popup dimension is recomputed 
// if margin is %t margins are added if margin is %f 
//    we do not use margins around diagram 
  
  // printf("enter: window_set_size\n");
  
  function [wpdim]=scrolled_window_compute_size(rect,zoom)
  // utility to evaluate popup size knowing 
  // the data rectangle (given by dig_bound(scs_m));
  // printf("enter: scrolled_window_compute_size\n");
    if isempty(rect) then rect=[0,0,600,400];end
    wdim=zoom*[rect(3)-rect(1),rect(4)-rect(2)]+[50,100];
    D=gdk_display_get_default();
    S=D.get_default_screen[]
    wdim_max= [S.get_width[] S.get_height[]];
    wpdim = max(min(wdim,wdim_max),[0,0]);
    // printf("quit: scrolled_window_compute_size (%d,%d)\n",wpdim(1),wpdim(2));
  endfunction
  
  function [frect,wdim]=darea_window_compute_size(rect,zoom,margins=%t)
  // compute proper frect and wdim for drawing area
  // when data is contained in rect (rect can be computed with 
  // dig_bound(scs_m);
  // printf("enter: darea_compute_size\n");
    if isempty(rect) then rect=[0,0,600,400], end
    w = (rect(3)-rect(1));    h = (rect(4)-rect(2));
    // amplitute correction if the user resize the window
    j = min(1.5,max(1,1600/(zoom*w)),max(1,1200/(zoom*h)));
    if ~margins then j=1;end
    axy = j;
    bx = (1-1/axy)/2;  by = (1-1/axy)/2;
    // axy = max([axy, 600/(zoom*w),400/(zoom*h)]);
    wdim = zoom*[ w , h]*axy;
    // printf("wdim is: %d,%d\n",wdim(1),wdim(2));
    xmargins=[0.02 0.02 0.02 0.02]/2
    wp=w*(axy+xmargins(1)+xmargins(2))
    hp=h*(axy+xmargins(3)+xmargins(4))
    xmin=rect(3)-wp*(bx+(1/axy))+xmargins(1)*wp
    ymin=rect(4)-hp*(by+(1/axy))+xmargins(3)*hp
    xmax=xmin+wp; ymax=ymin+hp;
    frect=[xmin ymin xmax ymax];
    // printf("quit: darea_compute_size (%d,%d),zoom=%f\n",wdim(1),wdim(2),zoom);
  endfunction
  
  if ~exists('scs_m') then scs_m=hash(10,props=hash(zoom=1.4, options=hash(Grid=%f)));end
  if ~exists('curwin') then curwin=0;end
  if nargin < 1 then win=curwin;end
  // should be done at window creation not here
  xset('window',win)
  if xget('wresize') ~= 2 then xset('wresize',2);end
  
  zoom = scs_m.props.zoom;
  bounds=dig_bound(scs_m);
  if isempty(bounds) then bounds = [0,0,400,300];end
  if read then 
    // just read dimensions in scs_m 
    // wpar = [frect, wdim, viewport, wpdim, winpos];
    // mrect=scs_m.props.wpar(1:4);
    // we recompute mrect which is not properly coded in 
    // old diagrams
    [mrect,_wdim]=darea_window_compute_size(bounds,zoom,margins=margins);
    wdim=scs_m.props.wpar(5:6);
    viewport=scs_m.props.wpar(7:8);
    wpdim = scs_m.props.wpar(9:10);
    wpos =  scs_m.props.wpar(11:12);
  else
    // compute dimensions from scs_m contents
    if popup_dim then 
      [wpdim]=scrolled_window_compute_size(bounds);
    end
    [mrect,wdim]=darea_window_compute_size(bounds,zoom,margins=margins);
  end
  
  if ~isempty(bounds) then
    // printf("window_set_size: set wdim to (%d,%d)\n",wdim(1),wdim(2));  
    xset('wdim',wdim(1),wdim(2));
    if popup_dim then 
      // printf("window_set_size: set wpdim to (%d,%d)\n",wpdim(1),wpdim(2));  
      xset('wpdim',wpdim(1),wpdim(2));
    end
  end
  // wrect=[0,0,1,1];
  mrect=int(mrect);
  if scs_m.props.options.Grid then 
    xsetech(arect=zeros(1,4),frect=mrect,fixed=%t,clip=%f,axesflag=1,iso=%t)
    F=get_current_figure();
    A=F(1);
    x_grid=scs_m.props.options.Wgrid(1);
    y_grid=scs_m.props.options.Wgrid(2);
    xtics = int((mrect(3)-mrect(1))/x_grid)+1;
    ytics = int((mrect(4)-mrect(2))/y_grid)+1;
    A.nax=[1,xtics,1,ytics];A.auto_axis=%f;
    xgrid(scs_m.props.options.Wgrid(3));
  else
    xsetech(arect=zeros(1,4),frect=mrect,fixed=%t,clip=%f,axesflag=0,iso=%t)
  end
  xflush();
  // set viewport position 
  xset('viewport',viewport(1),viewport(2));
  if %f && invalidate then
    F=get_current_figure()
    F.invalidate[]
    F.process_updates[]
  end;
  // printf("quit: window_set_size\n");
endfunction

