function scmenu_calc()
  Cmenu=''
  xinfo('You may enter any Scilab instruction. enter abort or quit to terminate')
  scs_gc=save_scs_gc();
  printf("scicos calc mode, enter abort or quit to return to scicos\n");
  execstr('pause',errcatch=%t);
  xinfo(' ');
  restore_scs_gc(scs_gc);
  clear('scs_gc');
  //scs_gc=null();
  nsp_clear_queue()
  Cmenu='Replot'
endfunction

