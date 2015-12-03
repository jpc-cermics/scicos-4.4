function scmenu_grid()
  Cmenu='Replot';
  scs_m.props.options.Grid = %t;
  edited=%t;
  F=get_current_figure();
  F.invalidate[];
  xinfo(' ')
endfunction

