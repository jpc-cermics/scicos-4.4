function window_read_size()
  axsize=scs_m.props.wpar(5:6)
  xset("wdim",axsize(1),axsize(2))
  data_bounds=scs_m.props.wpar(1:4)
  xsetech(frect=data_bounds,fixed=%t,clip=%f,axesflag=0,iso=%t)
  //FIXME!!
  //winsize=xget("wpdim")
  //dxy=min(scs_m.props.wpar(7:8),-winsize+axsize)
  //xset('viewport',dxy(1),dxy(2))
  //xset('viewport',scs_m.props.wpar(7),scs_m.props.wpar(8))
endfunction
