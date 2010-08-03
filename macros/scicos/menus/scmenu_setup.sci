function Setup_()
  Cmenu='Open/Set'
  %wpar=do_setup(scs_m.props)
  %scicos_solver=%wpar.tol(6)
  if or(scs_m.props<>%wpar) then
    scs_m.props=%wpar
    edited=%t
  end
endfunction

function wpar=do_setup(wpar)
// set integration parameters
// Copyright INRIA
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

  while %t do
    [ok,tf,scale,atol,rtol,ttol,deltat,solver,hmax]=getvalue('Set parameters',
    ['Final integration time';
     'Realtime scaling';
     'Integrator absolute tolerance';
     'Integrator relative tolerance';
     'Tolerance on time';
     'max integration time interval'
     'solver 0(lsodar)/100(dasrt)'
     'maximum step size (0 means no limit)'],...
	list('vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1),...
	[string(tf);string(scale);string(atol);string(rtol);...
	 string(ttol);string(deltat);string(solver);string(hmax)])
    if ~ok then break,end
    if or([tf,atol,rtol,ttol,deltat]<=0) then
      message('Parameter must  be positive')
    else
      wpar.tol=[atol;rtol;ttol;deltat;scale;solver;hmax]
      wpar.tf=tf
      break
    end
  end
endfunction


