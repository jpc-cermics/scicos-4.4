function [params,ok]=GetLitParam(str,flg)
 // flg=%t when the function is called by FindSBParams
 if nargin <= 1 then flg=%f;end
 ok=%t;
 // macrovar doit renvoyer 
 // in : input variables (vars(1)) 
 // out : output variables (vars(2)) 
 // globals : global (not local) variables (vars(3)) 
 // called : names of functions called (vars(4)) 
 // locals : local variables (vars(5)) 
 execstr(['function get_lit_param();';str(:);'endfuntion']);
 xx=macrovar(get_lit_param)
 params=xx(3)
 if flg then
   if or(xx(4)=='exec') then fnct='exec',ok=%f
   elseif or(xx(4)=='load') then fnct='load'; ok=%f
   end
   if ~ok then
     message('The context of a masked or atomic subsystem cannot contains the function ""'+fnct+'""');
     return
   end
 end
 if params<>[] then
    params(find(part(params,1)=="%"))=[] 
 end
endfunction
