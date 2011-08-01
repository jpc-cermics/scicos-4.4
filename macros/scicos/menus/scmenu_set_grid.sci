function scmenu_set_grid()
  xinfo('Set grid')
  if exists('%scicos_with_grid') then
    [%scs_wgrid] = do_grid(%scs_wgrid)
  end
  xinfo(' ')
  Cmenu='';%pt=[];
endfunction

function [%scs_wgrid]=do_grid(%scs_wgrid)
  exprs=[string(%scs_wgrid(1)),string(%scs_wgrid(2)),string(%scs_wgrid(3))]
  %scs_help='Grid'
  while %t do
    [ok,b1,b2,colorr,exprs]=getvalue(['Set Grid'],..
           ['x','y','color'],list('vec',1,'vec',1,'vec',1),exprs)
    if ~ok then
      break
    else
      %scs_wgrid(1)=b1
      %scs_wgrid(2)=b2
      %scs_wgrid(3)=colorr
      //drawgrid();
      printf("drawgrid : TODO\n");
      break
    end
  end
endfunction
