function window_set_size(win,viewport,invalidate=%t,popup_dim=%t)
// fix wdim adapted scs_m and %zoom 
// if viewport is %t the view is centered 
// if invalidate is %t Figure is invalidated
// this function can be tested with:
  printf("enter: window_set_size\n");
  
  function [wpdim]=scrolled_window_compute_size(rect)
  // utility to evaluate popup size knowing 
  // the data rectangle (given by dig_bound(scs_m));
    printf("enter: scrolled_window_compute_size\n");
    if isempty(rect) then rect=[0,0,600,400];end
    wdim=%zoom*[rect(3)-rect(1),rect(4)-rect(2)]+[50,100];
    D=gdk_display_get_default();
    S=D.get_default_screen[]
    wdim_max= [S.get_width[] S.get_height[]];
    wpdim = max(min(wdim,wdim_max),[400,300]);
    printf("quit: scrolled_window_compute_size (%d,%d)\n",wpdim(1),wpdim(2));
  endfunction
  
  if ~exists('scs_m') then scs_m=hash(10);end
  if ~exists('curwin') then curwin=0;end
  if ~exists('%zoom') then %zoom=1;end

  if nargin < 1 then win=curwin;end
  if nargin < 2 then viewport=%f;end

  // should be done at window creation not here
  xset('window',win)
  if xget('wresize') ~= 2 then xset('wresize',2);end
  
  bounds=dig_bound(scs_m);
  if popup_dim then 
    [wpdim]=scrolled_window_compute_size(bounds);
  else
    wpdim = xget('wpdim');
  end
  [mrect,wdim]=darea_window_compute_size(bounds);
  if ~isempty(bounds) then
    printf("window_set_size: set wdim to (%d,%d)\n",wdim(1),wdim(2));  
    xset('wdim',wdim(1),wdim(2));
    if popup_dim then 
      printf("window_set_size: set wpdim to (%d,%d)\n",wpdim(1),wpdim(2));  
      xset('wpdim',wpdim(1),wpdim(2));
    end
  end
  // wrect=[0,0,1,1];
  xsetech(arect=zeros(1,4),frect=mrect,fixed=%t,clip=%f,axesflag=0,iso=%t)
  xflush();
  if isequal(viewport,%f) then
    // center the graphic viewport inside the graphic window
    xset('viewport',-1,-1);
  else
    // use given values 
    xset('viewport',viewport(1),viewport(2));
  end
  if invalidate then
    F=get_current_figure()
    F.invalidate[]
    F.process_updates[]
  end;
  xflush();
  printf("quit: window_set_size\n");
endfunction

function test_window_set_size()
// load_toolbox('scicos');
  load('NSP/toolboxes/scicos-4.4/demos/absvalue.cos');
  %zoom=1.4;
  window_set_size()
  scs_m=drawobjs(scs_m);
endfunction

function [frect,wdim]=darea_window_compute_size(rect)
// compute proper frect and proper wdim for drawing area
// from scs_m
  printf("enter: darea_compute_size\n");
  if isempty(rect) then rect=[0,0,600,400], end
  w = (rect(3)-rect(1));
  h = (rect(4)-rect(2));
  j = min(1.5,max(1,1600/(%zoom*w)),max(1,1200/(%zoom*h)))  ;
  // amplitute correction if the user resize the window
  ax = j;// (max(wpdim(1)/(%zoom*w),j));
  ay = j;// (max(wpdim(2)/(%zoom*h),j));
  bx = (1-1/ax)/2;
  by = (1-1/ay)/2;
  wdim = %zoom*[ w * ax, h * ay];
  margins=[0.02 0.02 0.02 0.02]
  wp=w*(ax+margins(1)+margins(2))
  hp=h*(ay+margins(3)+margins(4))
  xmin=rect(3)-wp*(bx+(1/ax))+margins(1)*wp
  ymin=rect(4)-hp*(by+(1/ay))+margins(3)*hp
  xmax=xmin+wp; ymax=ymin+hp;
  frect=[xmin ymin xmax ymax];
  printf("quit: darea_compute_size (%d,%d),zoom=%f\n",wdim(1),wdim(2),%zoom);
endfunction
