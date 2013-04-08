function [ierreport]=scicos_test(fname,import=%f)
// make a full step test for diagram stored 
// in fname. Simulation results are stored in a repository 
// comparison.

  function [alreadyran,%cpr,ierreport]=do_terminate2(scs_m,%cpr)
  // Copyright INRIA
    if ~exists('alreadyran') then 
      alreadyran=%f;
    else
      alreadyran=alreadyran;
    end
    ierreport='';
    if prod(size(%cpr))<2 then   alreadyran=%f,return,end
    par=scs_m.props;
    if alreadyran then
      alreadyran=%f
      //terminate current simulation
      ierr=execstr('[state,t]=scicosim(%cpr.state,par.tf,par.tf,'+..
		   '%cpr.sim,''finish'',par.tol)',errcatch=%t);
      %cpr.state=state;
      curdir=getcwd();
      path=file('join',[scicos_test_path;'data_file']);
      state_var_=state;
      sv = file('join',[path;scs_m.props.title(1)+'_s.data']);
      save(sv,state_var_);
      sref = file('join',[path;scs_m.props.title(1)+'_s.ref']);
      if ~file('exists',sref) then 
	save(sref,state_var_);
	printf('Create the state reference file in'+path+'\n');
      end
    end
  endfunction

  function [scs_m,counter]=change_scs_m(scs_m,counter)
  // list of scopes to change
  // these blocks will be substituted by the write to file block.
    Changeb=['bouncexy',...
	     'cscope',...
	     'cmscope',...
	     'canimxy',...
	     'canimxy3d',...
	     'cevscpe',...
	     'cfscope',...
	     'cscopexy',...
	     'cscopxy',..
	     'cscopexy3d',...
	     'cscopxy3d',...
	     'cmatview',...
	     'cmat3d',..
	     'affich',...
	     'affich2',..
	     'writec',..
	     'writef',..
	     'writeau',..
	     'tows_c',..
	     'bplatform2']
    if nargin <2 then  counter=0;end;
    for i=1:length(scs_m.objs)
      o = scs_m.objs(i);
      if o.type == 'Block' then
	if or(scs_m.objs(i).model.sim(1)==['super','csuper','asuper']) then
	  [scs_m.objs(i).model.rpar,counter]=change_scs_m(o.model.rpar,counter);
	elseif or(o.model.sim(1)==Changeb) then
	  counter=counter+1;
	  scs_m.objs(i).model.sim=list('write_to_var',5);
	  scs_m.objs(i).model.label=string(counter);
	end
      end
    end
  endfunction


  function block=write_to_var(block,flag)
  // 
    nbr_block=block.label;
    execstr('global  var_name_'+nbr_block);
    execstr('global  counter_'+nbr_block);
    if flag==4 then
      execstr('global  var_name_'+nbr_block);  
      execstr(..
	      'var_name_'+nbr_block+'=list();'+..
	      'counter_'+nbr_block+'=0;'+..
	      'n=block.nin ;'+..
	      'for i=1:n+1; '+..
	      '  var_name_'+nbr_block+'(i)=list();'+..
	      'end')
    elseif flag==1 then
      cmd =  't=scicos_time();'+...
	     'counter_'+nbr_block+'=counter_'+nbr_block+'+1;'+..
	     'n=block.nin;'+..
	     'var_name_'+nbr_block+'(1)($+1)= t;'+..
	     'for i=2:n+1 ;'+..
	     '  var_name_'+nbr_block+'(i)($+1)=block.inptr(i-1);'+..
	     'end';
      ok =execstr(cmd,errcatch=%t);
    elseif flag==5 then
      path= file('join',[scicos_test_path;'data_file']);
      fname= file('join',[path;scs_m.props.title(1)+'_'+nbr_block+'.data']);
      execstr('save(fname,var_name_'+nbr_block+')');
      fref = file('join',[path;scs_m.props.title(1)+'_'+nbr_block+'.ref']);
      if ~file('exists',fref) then 
	file('copy',[fname,fref]);
	printf('The referenced file didn''t exist. I created it.\n');
      end
      execstr('clearglobal var_name_'+nbr_block+' counter_'+nbr_block)
    end
  endfunction  

  
  
  
  scicos_test_path='/tmp';
  dd=file('join',[scicos_test_path;"data_file"]);
  if ~exists(dd) then file("mkdir",dd);end
  do_terminate=do_terminate2;
  // load the diagram and update 
  if import then 
    [ok,scs_m,%cpr]=do_load(fname,'diagram',%t);
    // [ok,scs_m,%cpr]=do_scicoslab_import(fname);
  else
    [ok,scs_m,%cpr]=do_load(fname);
  end
  if ~ok then
    ierreport='Cannot load the diagram '+fname;
    return
  end
  //compatibility solver
  if scs_m.props.tol(6)==0 then
    scs_m.props.tol(6)=1;
  end
  %tcur=0;%cpr=list();alreadyran=%f;needstart=%t;needcompile=4;%state0=list();
  tolerances=scs_m.props.tol;
  solver=tolerances(6);
  %scicos_solver=solver;
  grand('setsd',23);
  // make an eval 
  [scs_m,%cpr,needcompile,ok]=do_eval(scs_m,%cpr);
  // transform the diagram for test 
  if ~ok then 
    ierreport='Cannot evaluate the diagram '+fname;
    return
  end
  // 
  scs_m=change_scs_m(scs_m);
  if needcompile<>4&size(%cpr)>0 then %state0=%cpr.state,end
  alreadyran=%f;
  [%cpr,%state0_n,needcompile,alreadyran,ok]=do_update(%cpr,%state0,4);
  if ~ok then 
    ierreport='Error updating parameters.';
    return;
  end
  if ~%state0_n.equal[%state0] then //initial state has been changed
    %state0=%state0_n;
    [alreadyran,%cpr,ierreport]=do_terminate2(scs_m,%cpr);
    if ierreport <> '' then return;end
    choix=[];
  end
  if %cpr.sim.xptr($)-1<size(%cpr.state.x,'*') & solver<100 then
    printf('Diagram has been compiled for implicit solver\n');
    printf('switching to implicit Solver\n');
    solver=100;
    tolerances(6)=solver;
  elseif (%cpr.sim.xptr($)-1==size(%cpr.state.x,'*')) & ..
	( solver==100 & size(%cpr.state.x,'*')<>0) then
    printf('Diagram has been compiled for explicit solver\n')
    printf('switching to explicit Solver\n');
    solver=0
    tolerances(6)=solver
  end
  if alreadyran then
    [alreadyran,%cpr,ierreport]=do_terminate2(scs_m,%cpr)
    if ierreport <> '' then return;end
    alreadyran=%f
  end
  %tcur=0;
  %cpr.state=%state0;
  tf=scs_m.props.tf;
  if tf*tolerances==[] then 
    ierreport='Simulation parameters not set';
    return;
  end
  xml=[getenv('NSP_TMPDIR');stripblanks(scs_m.props.title(1))+'_im.xml'];
  xml=file('join',xml);
  xmltmp=[getenv('NSP_TMPDIR');stripblanks(scs_m.props.title(1))+'_imTMP.xml'];
  xmltmp=file('join',xmltmp);
  if file('exists',xmltmp) then 
    file("copy",[xml,xmltmp]);
  end
  ok=execstr('[state,t]=scicosim(%cpr.state,%tcur,tf,%cpr.sim,'+..
	       '''start'',tolerances)',errcatch=%t)
  if ~ok then
    ierreport='Initialisation problem:'+catenate(lasterror());
    return;
  end
  %cpr.state=state;
  printf('The Simulation is now running ..... Please Wait!\n');
  ok =execstr('[state,t]=scicosim(%cpr.state,%tcur,tf,%cpr.sim,'+..
	      '''run'',tolerances)',errcatch=%t)
  if ok then
    %cpr.state=state;
    alreadyran=%t;
    if tf-t<tolerances(3) then
      needstart=%t;
      [alreadyran,%cpr,ierreport]=do_terminate2(scs_m,%cpr);
      if ierreport<>'' then
	return;
      end;
    else
      %tcur=t
    end
    printf('The data files are created/updated in the ""data_file"" folder\n');
  else
    ierreport='Execution problem:'+catenate(lasterror());
  end
endfunction


