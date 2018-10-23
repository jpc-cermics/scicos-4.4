
function scs_m = set_model_workspace(scs_m,script)
  if isempty(script) then return;end
  scs_m=set_model_context_data(scs_m,'workspace',script);
  Hin = acquire('%api_context',def=hash(1));
  [ok,H]=execstr(script,env=Hin, errcatch=%t);
  if ok then resume(%api_context=H);end
endfunction

