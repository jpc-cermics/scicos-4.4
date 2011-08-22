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
  [ok,context]=do_context(scs_m,%scicos_context);
  if ~ok then 
    %scicos_context=%sc_keep;
    clear %sc_keep;
    return;
  end
  // here context can be properly evaluated. 
  [%scicos_context,ierr]=script2var(context);
  // we can change scs_m
  edited=%t; alreadyran=%f; 
  scs_m.props.context=context;
  [scs_m,%cpr,needcompile,ok]=do_eval(scs_m,%cpr,%scicos_context);
  if needcompile<>4 && size(%cpr)>0 then %state0=%cpr.state,end;
endfunction

function [ok,new_context]=do_context(scs_m,env_context)
// check that context can be evaluated.
// using herited %scicos_context as environment.
// and then checks that scs_m evaluation works with the 
// new context.
// 
  if nargin < 2 then env_context=hash(1);end 
  new_context='';
  context=scs_m.props.context;
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
    if isempty(new_context) then
      // cancel context edition.
      ok=%f;
      return;
    end
    // evaluates context in env given by %scicos_context
    // herited from callers
    [H1,ierr]=script2var(new_context);
    if ierr<>0 then
      message(['Error occured when evaluating context:';
	       catenate(lasterror())]);
      continue;
    end
    // check now that evaluation still works.
    scs_m.props.context=new_context;
    [sc,cpr,nc,ok]=do_eval(scs_m,%cpr,env_context);
    if ok then
      break;// we can quit !
    end
  end
endfunction

