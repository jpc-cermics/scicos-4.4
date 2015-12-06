function scmenu_replot()
  Cmenu=''
  %pt=[]
  Select=[]
  scs_m=scicos_diagram_show(scs_m,win=curwin,margins=%t,scicos_uim=%t,scicos_istop=slevel<=1,read=%f);
  edited=%t;
  xinfo(' ')
endfunction

function scs_m=do_replot(scs_m)
// this function recreates all the graphic objects.
// If objects of scs_m already have graphic objects 
// they will be removed from the figure.
// But note that other objects present in figure 
// will not be deleted.
  scs_m=drawobjs(scs_m);
endfunction
