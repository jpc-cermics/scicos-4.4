function [ok,%1,%2,%3,%4,%5,%6,%7,%8,%9,%10,%11,%12,%13,%14,%15,%16,%17,%18,%19,%20]=...
    gtk_getvalue(%desc,%labels,%typ,%ini)
  // see getvalue
  [ok,%1,%2,%3,%4,%5,%6,%7,%8,%9,%10,%11,%12,%13,%14,%15,%16,%17,%18,%19,%20]=...
      getvalue_internal(%desc,%labels,%typ,%ini,use_dialog=%t,ch_fun=gtk_scicos_x_choices);
endfunction
