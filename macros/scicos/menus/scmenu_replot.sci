function scmenu_replot()
  Cmenu=''
  %pt=[]
  Select=[]
  scs_m=scicos_diagram_show(scs_m,win=curwin,margins=%t,scicos_uim=%t,scicos_istop=slevel<=1,read=%f);
  edited=%t;
  xinfo(' ')
endfunction
