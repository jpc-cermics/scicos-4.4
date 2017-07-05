function scmenu_setup()
  Cmenu=''
  %pt = []   ;
  if ~super_block then
    %wpar=do_setup(scs_m.props)
    %scicos_solver=%wpar.tol(6)
    if or(scs_m.props<>%wpar) then
      scs_m.props=%wpar
      edited=%t
    end
  else
    Scicos_commands=['%diagram_path_objective=[];%scicos_navig=1';
                     'Cmenu='"Setup'";%scicos_navig=[]';
                     '%diagram_path_objective='+sci2exp(super_path)+';%scicos_navig=1']
  end
endfunction

function wpar=do_setup(wpar)
// set integration parameters
// Copyright INRIA

  function a=stringcos(s)
    a=''
    for i=1:size(s,1)
      a(i)=sci2exp(s(i));
    end
  endfunction
  
  tolerances=wpar.tol;
  tf=wpar.tf
  atol=tolerances(1);rtol=tolerances(2);ttol=tolerances(3);
  deltat=tolerances(4)
  scale=tolerances(5);
  solver=tolerances(6)
  if length(tolerances)<7 then
    hmax=0
  else
    hmax=tolerances(7)
  end
  %scs_help='Setup_Scicos';
  labels = ['Final integration time';
	    'Realtime scaling';
	    'Integrator absolute tolerance';
	    'Integrator relative tolerance';
	    'Tolerance on time';
	    'Maximum integration time interval'
	    'Solver 0-5(ODE) / 100(DAE)'
	    'Maximum step size (0 means auto)'];
  types=list('vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1);
  exprs=stringcos([tf;scale;atol;rtol;ttol;deltat;solver;hmax]);
  while %t do
    [ok,tf,scale,atol,rtol,ttol,deltat,solver,hmax]=getvalue('Set simulator parameters',...
						  labels, types, exprs);
    if ~ok then break,end;
    if or([tf,atol,rtol,ttol,deltat]<=0) then
      message('Parameter must be positive')
    else
      wpar.tol=[atol;rtol;ttol;deltat;scale;solver;hmax]
      wpar.tf=tf
      break
    end
  end
endfunction



