function [scs_m,ok]=evaluate_model(scs_m,%scicos_context)
  ok=%t
  // nargin=argn(2)
  if nargin < 2 then
    %scicos_context=hash(5);
  end
  context=scs_m.props.context
  [%scicos_context, ierr] = script2var(context, %scicos_context)
  //for backward compatibility for scifunc
  //end of for backward compatibility for scifunc
  if ierr <>0 then
    ok=%f
    message(['Error occur when evaluating context:'
	     lasterror() ]);
  end
  needcompile=4
  [scs_m,%cpr,needcompile,ok] = do_eval(scs_m, list(),%scicos_context,'NONXML',%f);
  if ~ok then message(["Error during evaluation.";lasterror()]),end
endfunction
