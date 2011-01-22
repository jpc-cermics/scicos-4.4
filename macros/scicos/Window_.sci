function Window_()
  Cmenu=''

  params=scs_m.props;
  params=do_window(params)
  edited=or(params<>scs_m.props)
  
  if or(scs_m.props.wpar<>params.wpar) then
    xset('alufunction',3);
    xclear();//xbasc();
    xselect();
    //xset('alufunction',6);
    window_set_size()

    scs_m.props.wpar=params.wpar
    %wdm=scs_m.props.wpar
    %wdm(5:6)=(params.wpar(1:2)./scs_m.props.wpar(1:2)).*%wdm(5:6)
    scs_m.props.wpar(5)=%wdm(5);scs_m.props.wpar(6)=%wdm(6);

    drawobjs(scs_m),
    if pixmap then xset('wshow'),end
  end
endfunction

function wpar=do_window(wpar)
  wd=wpar.wpar;w=wd(1);h=wd(2);

  while %t do
    [ok,h,w]=getvalue('Set parameters',
    ['Window height';
     'Window width'],list('vec',1,'vec',1),string([h;w]))
    if ~ok then break,end
    if or([h,w]<=0) then
      message('Parameters must be positive')
    else
      drawtitle(wpar)
      wpar.wpar(1)=w
      wpar.wpar(2)=h
      break
    end
  end
endfunction
