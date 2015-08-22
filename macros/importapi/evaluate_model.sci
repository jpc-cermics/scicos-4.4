function [scs_m,ok]=evaluate_model(scs_m,context)
  ok=%t
  scs_m=set_model_finalize_context(scs_m);
  if nargin < 2 then context=hash(5);end
  [scs_m,ok] = do_silent_eval(scs_m, context)
endfunction

function scs_m=set_model_finalize_context(scs_m)
  scs_m = scs_m;
  if ~scs_m.props.iskey['data'] then return;end
  fields=['prelude','workspace','preload_fcn','postload_fcn','init_fcn'];
  context = m2s([]);
  context.concatd[sprintf('_final_simulation_time =%f',scs_m.props.tf)];
  for i=1:size(fields,'*')
    name = fields(i);
    if scs_m.props.data.iskey[name] then
      context.concatd[scs_m.props.data(name)];
    end
  end
  scs_m.props.context= context;
  scs_m.props.remove['data'];
endfunction

function scs_m=set_model_context_data(scs_m,name,script)
  if isempty(script) then return;end
  S=split(script,sep='\n')';
  if ~scs_m.props.iskey['data'] then
    scs_m.props.data = hash(10);
  end
  scs_m.props.data(name) = S;
endfunction
