function [ok,%1,%2,%3,%4,%5,%6,%7,%8,%9,%10,%11,%12,%13,%14,%15,%16,%17,%18,%19,%20]=...
    setvalue(%desc,%labels,%typ,%ini)
  //  setvalues -  data acquisition, getvalue equivalent without dialog
  if exists('%scicos_prob') && %scicos_prob then 
    ok=%f
    [%1,%2,%3,%4,%5,%6,%7,%8,%9,%10,%11,%12,%13,%14,%15,%16,%17,%18]=(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
    return;
  end
  [ok,%1,%2,%3,%4,%5,%6,%7,%8,%9,%10,%11,%12,%13,%14,%15,%16,%17,%18,%19,%20]=...
      getvalue_internal(%desc,%labels,%typ,%ini,use_dialog=%f);
endfunction
