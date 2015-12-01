function window_set_size(win,viewport,invalidate=%t,popup_dim=%t,read=%f)
// fix wdim adapted scs_m
// if viewport is %t the view is centered 
// if invalidate is %t Figure is invalidated
// if read is %t values are read in scs_m 

  printf("enter: window_set_size\n");
  
  function [wpdim]=scrolled_window_compute_size(rect,zoom)
  // utility to evaluate popup size knowing 
  // the data rectangle (given by dig_bound(scs_m));
  // printf("enter: scrolled_window_compute_size\n");
    if isempty(rect) then rect=[0,0,600,400];end
    wdim=zoom*[rect(3)-rect(1),rect(4)-rect(2)]+[50,100];
    D=gdk_display_get_default();
    S=D.get_default_screen[]
    wdim_max= [S.get_width[] S.get_height[]];
    wpdim = max(min(wdim,wdim_max),[400,300]);
    // printf("quit: scrolled_window_compute_size (%d,%d)\n",wpdim(1),wpdim(2));
  endfunction
  
  function [frect,wdim]=darea_window_compute_size(rect,zoom)
  // compute proper frect and wdim for drawing area
  // when data is contained in rect (rect can be computed with 
  // dig_bound(scs_m);
    // printf("enter: darea_compute_size\n");
    if isempty(rect) then rect=[0,0,600,400], end
    w = (rect(3)-rect(1));
    h = (rect(4)-rect(2));
    j = min(1.5,max(1,1600/(zoom*w)),max(1,1200/(zoom*h)))  ;
    // amplitute correction if the user resize the window
    ax = j;// (max(wpdim(1)/(zoom*w),j));
    ay = j;// (max(wpdim(2)/(zoom*h),j));
    bx = (1-1/ax)/2;
    by = (1-1/ay)/2;
    wdim = zoom*[ w * ax, h * ay];
    margins=[0.02 0.02 0.02 0.02]
    wp=w*(ax+margins(1)+margins(2))
    hp=h*(ay+margins(3)+margins(4))
    xmin=rect(3)-wp*(bx+(1/ax))+margins(1)*wp
    ymin=rect(4)-hp*(by+(1/ay))+margins(3)*hp
    xmax=xmin+wp; ymax=ymin+hp;
    frect=[xmin ymin xmax ymax];
    // printf("quit: darea_compute_size (%d,%d),zoom=%f\n",wdim(1),wdim(2),zoom);
  endfunction
  
  if ~exists('scs_m') then scs_m=hash(10,zoom=1.4);end
  if ~exists('curwin') then curwin=0;end
  if nargin < 1 then win=curwin;end
  if nargin < 2 then viewport=%f;end
  
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
    [mrect,_wdim]=darea_window_compute_size(bounds);
    wdim=scs_m.props.wpar(5:6);
    viewport=scs_m.props.wpar(7:8);
    wpdim = scs_m.props.wpar(9:10);
    wpos =  scs_m.props.wpar(11:12);
  else
    // compute dimensions from scs_m contents
    if popup_dim then 
      [wpdim]=scrolled_window_compute_size(bounds);
    end
    [mrect,wdim]=darea_window_compute_size(bounds);
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
  xsetech(arect=zeros(1,4),frect=mrect,fixed=%t,clip=%f,axesflag=1,iso=%t)
  if %t then 
    F=get_current_figure();
    A=F(1);
    A.nax=[1,50,1,50];A.auto_axis=%f;
    xgrid();
  end
  xflush();
  if isequal(viewport,%f) then
    // center the graphic viewport inside the graphic window
    xset('viewport',-1,-1);
  else
    // use given values 
    xset('viewport',viewport(1),viewport(2));
  end
  if %f && invalidate then
    F=get_current_figure()
    F.invalidate[]
    F.process_updates[]
  end;
  printf("quit: window_set_size\n");
endfunction

function test_window_set_size()
// load_toolbox('scicos');
  load('NSP/toolboxes/scicos-4.4/demos/absvalue.cos');
  window_set_size()
  scs_m=drawobjs(scs_m);
endfunction

