function %zoom=restore(curwin,%zoom)
// sets up proper parameters for the 
// curwin graphic window. 
// If the window already exists its graphic contents are 
// cleared.
  if ~set_cmap(scs_m.props.options('Cmap')) then // add colors if required
    scs_m.props.options('3D')(1)=%f //disable 3D block shape
  end
  gr_on = length(scs_m.objs) > 0 && ~(scs_m.objs(1).iskey['gr']);
  if ~or(curwin==winsid()) || gr_on then 
    xclear(curwin,gc_reset=%f);
  end
  xset('window',curwin);
  xselect();

  if size(scs_m.props.wpar,'*')>12 then
    // we already have sizes recorded in scs_m
    gh=nsp_graphic_widget(curwin);
    winsize=scs_m.props.wpar(9:10)
    winpos=scs_m.props.wpar(11:12)
    screen=gh.get_screen[]
    screensz=[screen.get_width[] screen.get_height[]]

    if min(winsize)>0 then
      winpos=max(0,winpos-max(0,-screensz+winpos+winsize) )
      scs_m=scs_m;
      scs_m.props.wpar(11:12)=winpos //make sure window remains inside screen
    end
    %zoom=scs_m.props.wpar(13)
    pwindow_read_size()
    window_read_size()
  else
    pwindow_set_size()
    window_set_size()
  end
endfunction

function [frect,axsize,viewport,winsize,winpos,pagesize]=get_curwpar(win)
  frect=[];axsize=[];viewport=[]
  winsize=[];winpos=[];pagesize=[]

  F=get_current_figure()
  A=F.children(1)
  gh=nsp_graphic_widget(win)

  winsize=gh.get_size[];
  axsize=xget("wdim")
  frect=A.frect;
  winpos=gh.get_position[];

  Vbox=gh.get_children[]
  Vbox=Vbox(1)
  ScrolledWindow=Vbox.get_children[]
  ScrolledWindow=ScrolledWindow($)
  hscrollbar=ScrolledWindow.get_hadjustment[]
  vscrollbar=ScrolledWindow.get_vadjustment[]
  viewport=[hscrollbar.value vscrollbar.value]
  pagesize=[hscrollbar.page_size vscrollbar.page_size]
endfunction
