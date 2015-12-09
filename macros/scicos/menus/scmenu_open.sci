function scmenu_open()
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
  [ok,sc,cpr,ed,context]=do_open(%f)
  if ok then 
    %scicos_context=context;
    scs_m=sc; %cpr=cpr; edited=ed;
    options=scs_m.props.options;
    alreadyran=%f;
    if size(%cpr)==0 then
      needcompile=4;
    else
      %state0=%cpr.state;
      needcompile=0;
    end
  end
endfunction

function [ok,scs_m,%cpr,edited,context]=do_open(flag)
// this function can be used ouside of scicos 
// 
  
  if nargin <= 0 then flag=%f;end
  context=hash(0);
  if flag then 
    // import from scicoslab 
    [ok,scs_m,%cpr,edited]=do_load([],'diagram',%t);
  else
    [ok,scs_m,%cpr,edited]=do_load();
  end
  if ~ok then return;end 
  if ok then
    if exists('inactive_windows','global') then
      global inactive_windows;
      inactive_windows=close_inactive_windows(inactive_windows,super_path)
    end
    //closing the initialization GUI before opening another diagram
    global scicos_widgets
    for i=1:length(scicos_widgets)
      if scicos_widgets(i).what.equal['ModelicaInitialize'] then
        if scicos_widgets(i).open==%t then
          scicos_widgets(i).id.destroy[]
        end
      elseif scicos_widgets(i).what.equal['GetInfo'] then
        if scicos_widgets(i).open==%t then
          scicos_widgets(i).id.destroy[]
        end
      end
    end
  end
  if exists('super_block') && super_block then edited=%t;end
  if type(scs_m.props.context,'short')<>'s' then 
    scs_m.props.context='';
  end
  // we have a context to evaluate. take care 
  // that evaluation of the context can change the current 
  // window.
  if ~isempty(winsid()) then 
    %now_win=xget('window')
  end
  // execute the context 
  [H1,ierr] = script2var(scs_m.props.context);
  if ierr<>0 then 
    message(['Error occured during context evaluation:';...
	     catenate(lasterror())]); 
  else
    // make a do_eval 
    [scs_m,%cpr,needcompile,evok]=do_eval(scs_m,%cpr);
  end
  // value to return;
  context = H1;
  // draw the new diagram 
  curwin = acquire('curwin',def=1000);
  read = size(scs_m.props.wpar,'*') >= 12;
  scs_m=scicos_diagram_show(scs_m,win=curwin,margins=%t,scicos_uim=%t,scicos_istop=slevel<=1,read=read);
  // protect the window against delete 
  // we first have to unconnect the default delete_event.
  gh=nsp_graphic_widget(curwin);
  gh.connect_after["delete_event", scicos_delete];
  gh.connect_after["destroy",scicos_destroy];
endfunction

function [y]=scicos_delete(win, event) 
// used when trying to delete a scicos window.
  y=%t; // if false then destroy is performed 
  // if true then destroy is not done 
  if y==%t then 
    printf("in delete returning true (no destroy)\n");
  else
    printf("in delete returning false (destroy)\n");
  end
endfunction

function scicos_destroy(win, event) 
// called when window is destroyed 
//   printf("in destroy \n");
endfunction
