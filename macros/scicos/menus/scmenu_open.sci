function scmenu_open()
//
  Cmenu='';Select=[]
  if edited & ~super_block then
    num=x_message(['Diagram has not been saved'],['gtk-ok','gtk-go-back'])
    if num==2 then return;end
    if alreadyran then do_terminate(),end  //terminate current simulation
    clear('%scicos_solver')
    alreadyran=%f
  end
  //xselect();
  [ok,sc,cpr,ed,context]=do_open(%f)
  if ok then 
    %scicos_context=context;
    scs_m=sc; %cpr=cpr; edited=ed;
    alreadyran=%f;
    if size(%cpr)==0 then
      needcompile=4;
    else
      %state0=%cpr.state;
      needcompile=0;
    end
  end
endfunction

function [ok,scs_m,%cpr,edited,context]=do_open(flag)
// this function can be used ouside of scicos 
// 
  if nargin <= 0 then flag=%f;end
  context=[];
  if flag then 
    [ok,scs_m,%cpr,edited]=do_scicoslab_import();
  else
    [ok,scs_m,%cpr,edited]=do_load();
  end
  if ~ok then return;end 
  if ok && exists('inactive_windows','global') then
    //closing the initialization GUI before opening another diagram
    global inactive_windows;
    inactive_windows=close_inactive_windows(inactive_windows,super_path)
  end
  if exists('super_block') && super_block then edited=%t;end
  
  if is(scs_m.props.context,%types.SMat) then
    // we have a context to evaluate. take care 
    // that evaluation of the context can change the current 
    // window.
    if ~isempty(winsid()) then 
      %now_win=xget('window')
    end
    // execute the context 
    if ~exists('%scicos_context') then 
      %scicos_context=hash_create(0);
    end
    [eok,H1]=execstr(scs_m.props.context,env=%scicos_context,errcatch=%t);
    if ~isempty(winsid()) then xset('window',%now_win);end 
    if ~eok then 
      message(['Error occured during context evaluation:';...
	       catenate(lasterror())]); 
    else
      context_same = H1.equal[%scicos_context];
      %scicos_context = H1;
      // make a do_eval 
      [scs_m,%cpr,needcompile,evok]=do_eval(scs_m,%cpr);
    end
  else
    scs_m.props.context=' '
  end
  // value to return;
  context = H1;
  // draw the new diagram 
  if ~exists('curwin')
    // we want this function to work outside main scicos
    curwin=1000; %zoom=1.4;
  end
  if isempty(winsid()==curwin) then 
    xset('window',curwin);
  else
    xclear(curwin,gc_reset=%f);
    xselect()
  end;
  if size(scs_m.props.wpar,'*')>12 then
    printf('open: wpar contains the window size and position');
    //Alan : seems to be not needed
    // get screen size (do not suppose that we have a graphic window)
    screensz=[gdk_screen_width(), gdk_screen_height()];
    // 
    winsize=scs_m.props.wpar(9:10)
    winpos=scs_m.props.wpar(11:12)
    if min(winsize)>0 then
      winpos=max(0,winpos-max(0,-screensz+winpos+winsize) )
      scs_m=scs_m;
      scs_m.props.wpar(11:12)=winpos //make sure window remains inside screen
    end
    %zoom=scs_m.props.wpar(13)
    pwindow_read_size();
    window_read_size();
  else
    // If we already have a window it's maybe not usefull to change it
    // Alan : si de temps en temps
    // pwindow_set_size()
    window_set_size()
  end
  // be sure that colormap is updated adding diagram colors
  if ~set_cmap(scs_m.props.options('Cmap')) then 
    // if failed to add colors and 3D exists. set 3d color to gray.
    if scs_m.props.options('3D')(1) then 
      scs_m.props.options('3D')=list(%t,xget('lastpattern')+3);
    end
  end
  options=scs_m.props.options
  set_background()
  // be sure that graphic objects are recreated 
  // in case they were in saved file.
  scs_m=do_replot(scs_m);
  // return values 
endfunction

