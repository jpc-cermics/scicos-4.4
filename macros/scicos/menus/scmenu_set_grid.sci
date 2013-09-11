function scmenu_set_grid()
  xinfo('Set grid')
  [edited,options]=do_grid(scs_m.props.options,edited)
  scs_m.props.options=options
  xinfo(' ')
  if options('Grid') && edited then
    scs_m=do_replot(scs_m)
  end
  Cmenu='';%pt=[];
endfunction

function [edited,options]=do_grid(options,edited)
  exprs=[string(options('Wgrid')(1)),...
         string(options('Wgrid')(2)),...
         string(options('Wgrid')(3))]
  //edited=%f
  %scs_help='Grid'
  while %t do
    [ok,b1,b2,colorr,exprs]=getvalue(['Set Grid'],..
           ['x','y','color'],list('vec',1,'vec',1,'vec',1),exprs)
    if ~ok then
      break
    else
      if options('Wgrid')(1)~=b1 || ...
         options('Wgrid')(2)~=b2 || ...
         options('Wgrid')(3)~=colorr then
        options('Wgrid')(1)=b1
        options('Wgrid')(2)=b2
        options('Wgrid')(3)=colorr
        edited=%t
      end
      //drawgrid();
      //printf("drawgrid : TODO\n");
      break
    end
  end
endfunction
