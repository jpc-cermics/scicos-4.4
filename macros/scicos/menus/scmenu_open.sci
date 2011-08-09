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
  context=[];
  if flag then 
    [ok,scs_m,%cpr,edited]=do_scicoslab_import();
  else
    [ok,scs_m,%cpr,edited]=do_load();
  end
  if ~ok then return;end 
  if ok then
    //TODO Alan
    //closing the initialization GUI before opening another diagram
    inactive_windows=close_inactive_windows(inactive_windows,super_path)
  end
  if super_block then edited=%t;end
  if ~set_cmap(scs_m.props.options('Cmap')) then 
    scs_m.props.options('3D')(1)=%f; 
  end
  options=scs_m.props.options
  
  if is(scs_m.props.context,%types.SMat) then
    // we have a context to evaluate. 
    %now_win=xget('window')
    // execute the context 
    if ~exists('%scicos_context') then 
      %scicos_context=hash_create(0);
    end
    [ok,H1]=execstr(scs_m.props.context,env=%scicos_context,errcatch=%t);
    xset('window',%now_win)
    if ~ok then 
      message(['Error occur when evaluating context:']); //   lasterror() ])
    else
      context_same = H1.equal[%scicos_context];
      %scicos_context = H1;
      // make a do_eval 
      [scs_m,%cpr,needcompile,ok]=do_eval(scs_m,%cpr)
    end
  else
    scs_m.props.context=' '
  end
  // value to return;
  context = H1;
  // draw the new diagram
  xclear(curwin,gc_reset=%f);xselect()
  set_background()
  if size(scs_m.props.wpar,'*')>12 then
    //Alan : seems to be not needed
    F=get_current_figure()
    gh=nsp_graphic_widget(curwin)
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
    pwindow_read_size();
    window_read_size();
  else
    // If we already have a window it's maybe not usefull to change it
    // Alan : si de temps en temps
    //pwindow_set_size()
    window_set_size()
  end
  // be sure that graphic objects are recreated 
  // in case they were in saved file.
  scs_m=do_replot(scs_m);
  // return values 
endfunction

