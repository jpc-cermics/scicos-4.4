function Context_()
  Cmenu='Replot'
  // note that context is not executed in his own frame
  // but in the caller frame.
  while %t do
    %now_win=xget('window')
    [context,ok]=do_context(scs_m.props.context)
    xset('window',%now_win)
    if ~ok then break,end
    // get rid of a local context if it exists
    if exists('%scicos_context','local') then
      clear('%scicos_context');
    end
    // now %scicos_context is the context from caller env
    if ~exists('%scicos_context') then
      %scicos_context= hash_create(10);
    end
    [ok,H1]=execstr(context,env=%scicos_context,errcatch=%t);
    if ~ok then
      message(['Error occured when evaluating context:'; lasterror()]);
      continue;
    end
    // now the local %scicos_context contains a merge of the
    // herited and local context
    %scicos_context = H1;
    scs_m.props.context=context;
    //do_terminate() Alan!!
    [scs_m,%cpr,needcompile,ok]=do_eval(scs_m,%cpr)
    if needcompile<>4&size(%cpr)>0 then %state0=%cpr.state,end
    edited=%t
    alreadyran=%f
    break,
  end
endfunction

function [context,ok]=do_context(context)
// Copyright INRIA
  if type(context,'string')<>'SMat' then context='',end
  comment = ['You may enter here nsp code to define ';
	      'symbolic parameters which can be used in block parameters definitions';
	      ' ';
	     'These instructions are evaluated once confirmed, i.e.,you';
	     'click on OK, by Eval and every time diagram is loaded.'];
  if %t then 
    // new version with editsmat 
    R= editsmat('Context Edition',context,comment=catenate(comment,sep='\n'));
  else
    R=dialog(comment, context);
  end
  if isempty(R) then
    ok=%f
  else
    context=R;
    ok=%t
  end
endfunction
