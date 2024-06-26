function scmenu_context()
// edit the context 
// 
  Cmenu='';
  // be sure that the local %scicos_context is out 
  %sc_keep=hash(1);
  if exists('%scicos_context','local') then
    %sc_keep=%scicos_context;
    clear('%scicos_context');
  end
  [ok,context]=do_context(scs_m);
  if ~ok then 
    %scicos_context=%sc_keep;
    clear %sc_keep;
  else
    // here context can be properly evaluated. 
    [%scicos_context,ierr]=script2var(context);
    // we can change scs_m
    edited=%t; alreadyran=%f; 
    scs_m.props.context=context;
    [scs_m,%cpr,needcompile,ok]=do_eval(scs_m,%cpr,%scicos_context);
    if needcompile<>4 && size(%cpr)>0 then %state0=%cpr.state,end;
  end
endfunction

function [ok,new_context]=do_context(scs_m)
  // check that context can be evaluated.
  // using herited %scicos_context as environment.
  // and then checks that scs_m evaluation works with the 
  // new context.
  //
  // inherits %scicos_context from above
  if exists('%scicos_context') then
    env_context=%scicos_context;
  else
    env_context=hash(1);
  end
  new_context='';
  context=scs_m.props.context;
  [sc,ok1]=do_silent_eval(scs_m,env_context);
  eval_fails= %f;
  if ~ok1 then
    eval_fails=%t
    message(['Warning: evaluation of scicos schema fails';
	     'maybe you have a broken context';
	     catenate(lasterror())]);
  end
  
  if type(context,'string')<>'SMat' then context='',end
  comment = ['You may enter here nsp code to define ';
	     'symbolic parameters which can be used in block parameters definitions';
	     ' ';
	     'These instructions are evaluated once confirmed, i.e.,you';
	     'click on OK, by Eval and every time diagram is loaded.'];
  // loop until we have a context without error
  while %t do
    // edit context 
    new_context=editsmat('Context Edition',context,comment=catenate(comment,sep='\n'));
    nsp_clear_queue();
    if isempty(new_context) then
      // cancel context edition.
      ok=%f;
      return;
    end
    // evaluates new_context in an environment given herited 
    // %scicos_context from callers
    [H1,ierr]=script2var(new_context,env_context);
    if ierr<>0 then
      message(['Error occured when evaluating context:';
	       catenate(lasterror())]);
      context= new_context;
      continue;
    end
    // check now that evaluation still works.
    scs_m.props.context=new_context;
    if eval_fails then
      // do_eval was already broken on entry
      // we accept changes which leads to correct evaluation of context
      ok=%t;
      return;
    end
    [sc,ok]=do_silent_eval(scs_m,env_context);
    // [sc,cpr,nc,ok]=do_eval(scs_m,%cpr,env_context);
    if ok then
      break;// we can quit !
    else
      context=scs_m.props.context;
    end
  end
endfunction

