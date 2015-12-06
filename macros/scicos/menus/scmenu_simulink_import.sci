function scmenu_simulink_import()
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
  [ok,sc,cpr,ed,context]=do_import_mdl()
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

function [ok,scs_m,%cpr,edited,context]=do_import_mdl()
// this function can be used ouside of scicos
// it should be unified with functions in do_open
  ok = %t;
  context=hash(0);
  edited=%t;
  %cpr=list();
  scs_m = do_load_mdl(fname=[],warnings=%f);
  if scs_m.equal[[]] then ok=%f;return;end
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
  if type(scs_m.props.context,'short')<>'s' then
    scs_m.props.context='';
  end
  // we have a context to evaluate. take care
  // that evaluation of the context can change the current
  // window.
  if ~isempty(winsid()) then %now_win=xget('window'); end;
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
  // draw the new diagram 
  curwin = acquire('curwin',def=1000);
  read = size(scs_m.props.wpar,'*') > 12;
  scs_m=scicos_diagram_show(scs_m,win=curwin,margins=%t,scicos_uim=%t,scicos_istop=slevel<=1,read=read);
  // protect the window against delete 
  // we first have to unconnect the default delete_event.
  gh=nsp_graphic_widget(curwin);
  gh.connect_after["delete_event", scicos_delete];
  gh.connect_after["destroy",scicos_destroy];
endfunction

function scs_m = do_load_mdl(fname=[],warnings=%f,check_companion=%t)
// load a mdl diagram or a slx
// can be used outside of scicos function
// Reste a faire les companion files
  scs_m=[];
  global %scicos_demo_mode ;
  global %scicos_open_saveas_path ;
  global(%scicos_ext='.cos'); //default file extension
  if isempty(%scicos_open_saveas_path) then %scicos_open_saveas_path='', end
  if ~exists('alreadyran') then alreadyran = %f;end
  //end current simulation if necessary
  if alreadyran then do_terminate(); end
  scicos_debug(0); //set debug level to 0 for new diagram loaded
  current_version = get_scicos_version();
  // not sure that next hack is still necessary on nsp !
  if ~isempty(winsid) then
    xpause(1000,%t)  // quick and dirty fix for windows bug on fast computers
  end
  masks=['Mdl','Slx';'*.mdl','*.slx'];
  if isempty(fname) then
    if ~isempty(%scicos_demo_mode) then
      path=file('join',[get_scicospath();"demos"]);
    else
      path=%scicos_open_saveas_path;
    end
    fname=xgetfile(masks=masks,open=%t,dir=path)
    if fname == "" then return;end // a Cancel was executed
  end
  %scicos_demo_mode = []; //** clear the variable
  fname = stripblanks(fname)
  if fname.equal[""] then
    // We have canceled the open
    return
  end
  nsp= getenv('NSP');
  simport= file('join',[file('split',getenv('NSP'));'bin';'simport.exe']);
  pervasive= file('join',[file('split',getenv('NSP'));'libs']);
  target_fname = file('tail',fname);
  target_fname = strsubst(target_fname,file('extension',fname),'.nsp');
  target = file('join',[file('split',getenv('NSP_TMPDIR'));target_fname]);
  cmd = [simport,"-I",pervasive,"-no-warnings","-tl","nsp",fname,"-o",target];
  // check if we have a companion file
  // i.e a file with same name and .m suffix
  // then we automatically add the companion
  companion = strsubst(fname,file('extension',fname),'.m');
  if file('exists',companion) then
    cmd.concatr[['-ccf',companion]];
  else
    if check_companion then 
      l1=list('combo','Answer',1,['Yes','No']);
      title = ['Is there a Matlab companion file ';
	       sprintf('to file %s',fname)];
      [Lres,L]=x_choices(title,list(l1),%t);
      if ~isempty(Lres) && Lres(1)==1 then
	companion=xgetfile(masks=['Matlab';'m'],open=%t);
	if companion <> "" then
	  cmd.concatr[['-ccf',companion]];
	end
      end
    end
  end
  xpause(10000,%t);// give time to events to close the widgets
  if warnings then cmd(4)=[];end;
  [ok,stdout,stderr,msgerr,exitst]=spawn_sync(cmd);
  if ~ok then
    message(['Failed to import file';stderr]);
    return
  else
    if warnings && length(stdout)<>0 then message(stdout);end
  end
  if ~file('exists',target) then
    message(sprintf('output file (%s) of simport is not found',target));
    return;
  end
  wins=winsid();
  xpause(10000,%t);// give time to events
  ok=exec(target,errcatch=%t);
  wins_n=winsid();
  if size(wins_n) > size( wins) then xdel(wins_n($));end
  if ~ok then
    message(['Error occured during execution of simport output file';
	     catenate(lasterror())]);
    return
  end
  scs_m = scsm;
endfunction
