function window_set_size(win,viewport)
  
  if ~exists('scs_m') then scs_m=hash();end 
  if ~exists('curwin') then curwin=0;end
  if ~exists('%zoom') then %zoom=1;end 
  
  if nargin < 1 then win=curwin;end 
  if nargin < 2 then viewport=%f;end 
  
  xset('window',win)
  F=get_current_figure()
  gh=nsp_graphic_widget(win)

  [mrect,wdim]=windows_compute_size();
  xset("wresize",0);
  xset('wdim',wdim(1),wdim(2));
  
  arect=[0 0 0 0]
  wrect=[0,0,1,1];
  
  if length(F.children)==0 then
    xsetech(arect=arect,frect=mrect,fixed=%t,clip=%f,axesflag=0,iso=%t)
  else
    A=F.children(1)
    A.arect=arect
    A.frect=mrect
    A.fixed=%t
    A.clip=%f
    // rect is hidden but can be accessed through set and get
    A.set[rect=mrect];
  end
  xflush()
  // center the graphic viewport inside the graphic window
  if isequal(viewport,%f) then
    Vbox=gh.get_children[]
    Vbox=Vbox(1)
    ScrolledWindow=Vbox.get_children[]
    ScrolledWindow=ScrolledWindow(3)
    hscrollbar=ScrolledWindow.get_hadjustment[]
    vscrollbar=ScrolledWindow.get_vadjustment[]
    %XSHIFT=(hscrollbar.upper-hscrollbar.page_size)/2
    %YSHIFT=(vscrollbar.upper-vscrollbar.page_size)/2
  else
    %XSHIFT=viewport(1)
    %YSHIFT=viewport(2)
  end
  xset('viewport',%XSHIFT,%YSHIFT)
  xflush()
endfunction

function [frect,wdim]=windows_compute_size()
// compute proper frect and proper wdim 
// from scs_m 
  r=xget('wpdim');
  rect=dig_bound(scs_m);
  if isempty(rect) then rect=[0,0,r(1),r(2)], end
  w = (rect(3)-rect(1));
  h = (rect(4)-rect(2));
  j = min(1.5,max(1,1600/(%zoom*w)),max(1,1200/(%zoom*h)))  ;
  // amplitute correction if the user resize the window
  ax = (max(r(1)/(%zoom*w),j));
  ay = (max(r(2)/(%zoom*h),j));
  bx = (1-1/ax)/2; 
  by = (1-1/ay)/2; 
  // window dim 
  wdim = %zoom*[ w * ax, h * ay];
  // 
  margins=[0.02 0.02 0.02 0.02]
  wp=w*(ax+margins(1)+margins(2))
  hp=h*(ay+margins(3)+margins(4))
  xmin=rect(3)-wp*(bx+(1/ax))+margins(1)*wp
  ymin=rect(4)-hp*(by+(1/ay))+margins(3)*hp
  xmax=xmin+wp; ymax=ymin+hp;
  frect=[xmin ymin xmax ymax];
endfunction

