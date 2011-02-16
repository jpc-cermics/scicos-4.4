function %zoom=restore(curwin,menus,%zoom)
  if ~set_cmap(scs_m.props.options('Cmap')) then // add colors if required
    scs_m.props.options('3D')(1)=%f //disable 3D block shape
  end
  xclear(curwin,gc_reset=%f);xselect()
  if size(scs_m.props.wpar,'*')>12 then
    printf("***Restore : window_read_size\n");
    winsize=scs_m.props.wpar(9:10)
    winpos=scs_m.props.wpar(11:12)

    //FIXME!!
    //if with_tk() then
    //  screensz=evstr(TCL_EvalStr('wm  maxsize .')) 
    //else
    //  screensz=400
    //end
    //if min(winsize)>0  then  // window is not iconified
    //  winpos=max(0,winpos-max(0,-screensz+winpos+winsize) )
    //  scs_m=scs_m;  // only used locally, does not affect the real scs_m
    //  scs_m.props.wpar(11:12)=winpos  // make sure window remains inside screen
    //end
	
    %zoom=scs_m.props.wpar(13)
    pwindow_read_size()
    //window_read_size()
    window_set_size()
  else
    printf("***Restore : window_set_size\n");
    pwindow_set_size()
    window_set_size()
  end
  menu_stuff(curwin,menus)
endfunction
