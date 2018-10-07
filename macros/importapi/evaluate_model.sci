function [scs_m,ok]=evaluate_model(scs_m,context)
  ok=%t
  scs_m=set_model_finalize_context(scs_m);
  if nargin < 2 then context=hash(5);end
  [scs_m,ok] = do_silent_eval(scs_m, context);
  if ~ok then
    printf("warning: do_silent_eval_failed for the diagram\n");
  end
endfunction

function scs_m=set_model_finalize_context(scs_m)
  scs_m = scs_m;
  if scs_m.props.iskey['context'] then
    context=scs_m.props.context;
  else
    context = m2s([]);
  end
  context.concatd[sprintf('_final_simulation_time =%f',scs_m.props.tf)];
  if scs_m.props.iskey['data'] then 
    fields=['prelude','workspace','preload_fcn','postload_fcn','init_fcn'];
    for i=1:size(fields,'*')
      name = fields(i);
      if scs_m.props.data.iskey[name] then
	context.concatd[scs_m.props.data(name)];
      end
    end
  end
  scs_m.props.context= context;
  scs_m.props.remove['data'];
  // recursively propagate
  for k=1:length(scs_m.objs)
    o=scs_m.objs(k)
    if o.type == 'Block' &&  o.gui == 'SUPER_f' then
      diagram=set_model_finalize_context(o.model.rpar)
      o.model.rpar = diagram;
      scs_m.objs(k)=o;
    end
  end
endfunction

function scs_m=set_model_context_data(scs_m,name,script)
  if isempty(script) then return;end
  // if S is a string we assume that it can contain \n
  if size(script,'*') == 1 then 
    S=split(script,sep='\n')';
  else
    S=script;
  end
  if ~scs_m.props.iskey['data'] then
    scs_m.props.data = hash(10);
  end
  scs_m.props.data(name) = S;
endfunction

