function Save_()
  Cmenu='Open/Set'
  %pt=[]
  ok=do_save(scs_m) 
  if ok&~super_block then edited=%f,end
endfunction

function ok=do_save(scs_m)   
// saves scicos data structures scs_m and %cpr on a binary file
// Copyright INRIA
  if pal_mode then scs_m=do_purge(scs_m),end
  //file path
  if size(scs_m.props.title,'*')<2 then 
    path='./'
  else
    path=scs_m.props.title(2)
  end
  //open file
  if ~super_block & ~pal_mode then
    //update %cpr data structure to make it coherent with last changes
    if needcompile==4 then
      %cpr=list()
    else
      [%cpr,%state0,needcompile,ok]=do_update(%cpr,%state0,needcompile)
      if ~ok then return,end
      %cpr.state=%state0
    end
  else
    %cpr=list()
  end
  fname=path+scs_m.props.title(1)+'.cos'
  // jpc: test if directory is writable 
  if file('writable',path) == %f then 
    message(['Cannot create file '+fname]);  // ;lasterror()])
    ok=%f
    return 
  end
  // save current diagram 
  if ~execstr('save(fname,scicos_ver,scs_m,%cpr);',errcatch=%t) then 
    message(['Save error:']); // ;lasterror()])
    ok=%f
    return 
  end
  if pal_mode then update_scicos_pal(path,scs_m.props.title(1),fname),end
  ok=%t
endfunction
