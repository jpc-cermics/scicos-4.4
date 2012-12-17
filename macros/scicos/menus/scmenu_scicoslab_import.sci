function scmenu_scicoslab_import()
// similar to open 
// but the flag %t in do_open will change do_load to do_scicoslab_import.
// 
  Cmenu='';Select=[]
  if edited & ~super_block then
    num=x_message(['Diagram has not been saved'],['gtk-ok','gtk-go-back'])
    if num==2 then return;end
    if alreadyran then do_terminate(),end  //terminate current simulation
    clear('%scicos_solver')
    alreadyran=%f
  end
  //xselect();
  [ok,sc,cpr,ed,context]=do_open(%t)
  if ok then 
    %scicos_context=context;
    scs_m=sc; %cpr=cpr; edited=ed;
    options=scs_m.props.options;
    if size(scs_m.props.wpar,'*')>12 then
      %zoom=scs_m.props.wpar(13)
    else
      %zoom=1.4
    end
    alreadyran=%f;
    if size(%cpr)==0 then
      needcompile=4;
    else
      %state0=%cpr.state;
      needcompile=0;
    end
  end
endfunction


 


  
