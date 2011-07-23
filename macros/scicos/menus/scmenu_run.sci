function Run_()
  nc_save=4
  Cmenu=''
  ok=%t
  [ok,%tcur,%cpr,alreadyran,needcompile,%state0,%scicos_solver]=do_run(%cpr);
  scs_m.props.tol(6)=%scicos_solver;
  if ok then newparameters=list(),end
endfunction

function [ok,%tcur,%cpr,alreadyran,needcompile,%state0,solver]=do_run(%cpr)
// realize action associated to the run button
// performs necessary diagram (re-)compilation
// performs simulation initialisation
// performs simulation error recovery
//
// state  : is current state
// %state0 : is initial state value
//
// define user possible choices

// Copyright INRIA
  
// be sure that returned values exists in the local frame
  if exists('%tcur','all'); %tcur=%tcur;else %tcur=0;end 
  if exists('alreadyran','all');alreadyran=alreadyran ;else alreadyran=%f;end;
  if exists('needcompile','all');needcompile=needcompile;else needcompile=4;end
  if exists('%state0','all');%state0=%state0;else %state0=list(); end 
  
  tolerances=scs_m.props.tol
  solver=tolerances(6)
  // update parameters or compilation results
  [%cpr,%state0_n,needcompile,alreadyran,ok]=do_update(%cpr,%state0,needcompile)
  if ~ok then %tcur=[],alreadyran=%f,return,end

  if alreadyran then
    choix=['Continue';'Restart';'End']
  else
    choix=[]
  end

  if ~%state0_n.equal[%state0] then //initial state has been changed
    %state0=%state0_n
    [alreadyran,%cpr]=do_terminate()
    choix=[]
  end

  if %cpr.sim.xptr($)-1<size(%cpr.state.x,'*') & solver<100 then
    message(['Diagram has been compiled for implicit solver'
	     'switching to implicit Solver'])
    solver=100
    tolerances(6)=solver
  elseif (%cpr.sim.xptr($)-1==size(%cpr.state.x,'*')) & 
    ( solver==100 & size(%cpr.state.x,'*')<>0) then
    message(['Diagram has been compiled for explicit solver'
	     'switching to explicit Solver'])
    solver=0
    tolerances(6)=solver
  end
  
  // ask user what to do
  if ~isempty(choix) then
    to_do=x_choose(choix,'What do you want to do')
    if to_do==0 then ok=%f,return,end
    select choix(to_do)
     case 'Continue' then 
      needstart=%f
      state=%cpr.state
     case 'Restart' then 
      needstart=%t
      state=%state0
     case 'End' then 
      state=%cpr.state
      needstart=%t
      tf=scs_m.props.tf;
      // keep track of graphic objects 
      grs=scicos_graphic_array(%cpr,scs_m);
      execok=execstr('[state,t,kfun]=scicosim(%cpr.state,%tcur,tf,%"+...
		     "cpr.sim,''finish'',tolerances,grs)',errcatch=%t)
      %cpr.state=state
      alreadyran=%f
      if ~execok  then
	kfun=curblock()
	corinv=%cpr.corinv
	if kfun<>0 then
	  path=corinv(kfun)
	  xset('window',curwin)
	  bad_connection(path,
	  ['End problem with hilited block';lasterror()],0,0,-1,0)
	else
	  message(['End problem:';lasterror()])
	end
	ok=%f
	return
      end
      xset('window',curwin)
      return
    end
  else
    needstart=%t
    state=%state0
  end

  win=xget('window')

  if needstart then //scicos initialisation
    if alreadyran then
      [alreadyran,%cpr]=do_terminate()
      alreadyran=%f
    end
    %tcur=0
    %cpr.state=%state0
    tf=scs_m.props.tf;
    if isempty(tf*tolerances) then 
      x_message(['Simulation parameters not set';'use setup button']);
      return;
    end

    //** run scicosim via 'start' flag

    TMPDIR=getenv('NSP_TMPDIR')
    XML=file('join',[TMPDIR,stripblanks(scs_m.props.title(1))+'_imf_init.xml']);
    XMLTMP=file('join',[TMPDIR,stripblanks(scs_m.props.title(1))+'_imSim.xml']);
    
    if file("exists",XML) then
      isok=execstr("file(""copy"",[XML,XMLTMP])",errcatch=%t)
      if ~isok then
        x_message(['Unable to copy XML files']);
      end

      //x_message(['Scicos cannot find the XML data file required for the simulation';..
      //	 'please either compile the diagram, in this case Sccios uses'; 
      //	 'parameters defined in Scicos blocks and the Scicos context';
      //	 'or you can save the XML file defined in the initialization GUI']);
      //return;
    end

    grs=scicos_graphic_array(%cpr,scs_m);
    execok=execstr('[state,t,kfun]=scicosim(%cpr.state,%tcur,tf,%cpr.sim,''start'',tolerances,grs)',errcatch=%t)
    %cpr.state=state
    if ~execok then
      kfun=curblock()
      corinv=%cpr.corinv
      if kfun<>0 then
	xset('window',curwin)
	path=corinv(kfun)
	bad_connection(path,
	['Initialisation problem with hilited block:';lasterror()],0,0,-1,0)
      else
	message(['Initialisation problem:';lasterror()])
      end
      ok=%f
      xset('window',curwin)
      unsetmenu(curwin,'stop')
      return
    end
    xset('window',win);
  end  
  needreplay=%t
  
  // simulation

  tf=scs_m.props.tf;
  setmenu(curwin,'stop')
  timer()
  needreplay=%t
  grs=scicos_graphic_array(%cpr,scs_m);
  execok=execstr('[state,t,kfun]=scicosim(%cpr.state,%tcur,tf,%cpr.sim,''run'',tolerances,grs)',errcatch=%t)
  
  %cpr.state=state
  if execok then
    alreadyran=%t
    if tf-t<tolerances(3) then
      needstart=%t
      [alreadyran,%cpr]=do_terminate()
      alreadyran=%f
    else
      %tcur=t
    end
  else
    kfun=curblock()
    corinv=%cpr.corinv
    if kfun<>0 then
      path=corinv(kfun)
      xset('window',curwin)
      bad_connection(path,
      ['Simulation problem with hilited block:';lasterror()],0,0,-1,0)
    else
      message(['Simulation problem:';lasterror()])
    end
    ok=%f
  end
  
  xset('window',curwin)
  //printf("XXX %f\n",timer())
  unsetmenu(curwin,'stop')
  resume(needreplay);
endfunction

function grs=scicos_graphic_array(%cpr,scs_m)
// create an array containing the graphic objects 
// of the blocks which are on the main window 
// The array is indexed using corinv 
// This array is used internally for block which need 
// to perform graphics in their icons. 
// We first limit the usage to main window 
// jpc: 2011
  if ~exists('slevel') then slevel=0;end 
  grs={};
  for i=1:size(%cpr.corinv,'*')
    path=%cpr.corinv(i)
    if exists('windows')==%f || slevel<>1 || size(path,'*')<>1 then 
      grs{i}=%f ;
    else
      grs{i}= scs_m.objs(path).gr;
    end
  end
endfunction


  
