function Load_()
  Cmenu=''
  if edited & ~super_block then
    num=x_message(['Diagram has not been saved'],['gtk-ok','gtk-go-back'])
    if num==2 then return;end
    if alreadyran then do_terminate(),end  //terminate current simulation
    alreadyran=%f
  end
  [ok,scs_m,%cpr,edited]=do_load()
  if super_block then edited=%t;end
  if ~ok then
    return;
  end
  
  if ~set_cmap(scs_m.props.options('Cmap')) then 
    scs_m.props.options('3D')(1)=%f //disable 3D block shape 
  end
  options=scs_m.props.options
  
  if is(scs_m.props.context,%types.SMat) then
    // we have a context to evaluate. 
    %now_win=xget('window')
    // execute the context 
    if ~exists('%scicos_context') then 
      %scicos_context=hash_create(0);
    end
    [ok,H1]=execstr(scs_m.props.context,env=%scicos_context,errcatch=%t);
    xset('window',%now_win)
    if ~ok then 
      message(['Error occur when evaluating context:']); //   lasterror() ])
    else
      context_same = H1.equal[%scicos_context];
      %scicos_context = H1;
      //perform eval only if context contains functions which may give
      //different results from one execution to next
      //XXXX : we have to check here if context contains rand exec or load 
      if ~context_same then
	[scs_m,%cpr,needcompile,ok]=do_eval(scs_m,%cpr)
      end
    end
  else
    scs_m.props.context=' '
  end

  // draw the new diagram
  xclear();//xbasc();
  xselect();
  set_background()
  // If we already have a window it's maybe not usefull to change it
  // pwindow_set_size()
  window_set_size()
  // be sure that graphic objects are recreated 
  // in case they were in saved file.
  scs_m=do_replot(scs_m);

  // return values 
  if size(%cpr)==0 then
    needcompile=4
    alreadyran=%f
  else
    %state0=%cpr.state
    needcompile=0
    alreadyran=%f
  end
endfunction

