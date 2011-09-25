
function [ok,%1,%2,%3,%4,%5,%6,%7,%8,%9,%10,%11,%12,%13,%14,%15,%16,%17,%18,%19,%20]=...
    setvalue(%desc,%labels,%typ,%ini)
  
  //  setvalues -  data acquisition, getvalue equivalent without dialog
  [ok,%1,%2,%3,%4,%5,%6,%7,%8,%9,%10,%11,%12,%13,%14,%15,%16,%17,%18,%19,%20]=...
      getvalue_internal(%desc,%labels,%typ,%ini,use_dialog=%f);
  if ~ok && exists('%scicos_prob','global') then 
    // report error to eval 
    global %scicos_prob; %scicos_prob=%t;
  else
    // try to detect that we are inside an infinite loop 
    // If setvalue is called twice with same %init value 
    // we assume that we are looping in a non interactive 
    // set action.
    global %scicos_setvalue;
    if type(%scicos_setvalue,'short')=='s' && 
      %ini.equal[%scicos_setvalue] then 
      error("Loop in setvalue");
      // printf("Error detected in setvalue\n");
    else
      %scicos_setvalue=%ini;
    end
  end
endfunction
