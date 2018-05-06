function clr=default_color(typ)
  // Copyright INRIA
  if ~exists('options') then
    if exists('scs_m') then
      options=scs_m.props.options;
    else
      options = scicos_options()
    end
  end
  if typ==-1 then; //event links
    clr=options('Link')(2),
  elseif typ==0 then; //text, block shape,
    if size(options('Background'),'*')>=2 then 
      //compatibility
      clr=options('Background')(2), 
    else
      clr=1;
    end
  elseif typ==1 | typ==2 then //regular links
    clr=options('Link')(1)
  elseif typ==3 then //BUS
    if size(options('Link'),'*')>=3 then //compatibility
      clr=options('Link')(3), 
    else
      clr=2;
    end
  end
endfunction
