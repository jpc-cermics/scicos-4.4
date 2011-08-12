function [ok,%1,%2,%3,%4,%5,%6,%7,%8,%9,%10,%11,%12,%13,%14,%15,%16,%17,%18,%19,%20]=...
    setvalue(%desc,%labels,%typ,%ini)
  //  setvalues -  data acquisition, getvalue equivalent without dialog
  [ok,%1,%2,%3,%4,%5,%6,%7,%8,%9,%10,%11,%12,%13,%14,%15,%16,%17,%18,%19,%20]=...
      getvalue_internal(%desc,%labels,%typ,%ini,use_dialog=%f);
  if ~ok && exists('%scicos_prob','global') then 
    // report error to eval
    global %scicos_prob; %scicos_prob=%t;
  end
endfunction
