function [ok,%1,%2,%3,%4,%5,%6,%7,%8,%9,%10,%11,%12,%13,%14,%15,%16,%17,%18,%19,%20]=...
	 gtk_getvalue(%desc,%labels,%typ,%ini)
  // getvalue is limited with respect to the number of outputs
  // use getvalue_list instead
  [ok,%L,%L2]= getvalue_internal_list(%desc,%labels,%typ,%ini,use_dialog=%t,ch_fun=gtk_scicos_x_choices);
  str = '['+ catenate('%'+m2s(1:length(%L))',sep=',')+']';
  for i=1:length(%L) do execstr( '%'+m2s(i,"%.0f")+ '=%L(i)'); end
  i =length(%L)+1; execstr( '%'+m2s(i,"%.0f")+ '=%L2;');
  if nargout > length(%L)+2 then
    for i=length(%L)+2:nargout-1 do execstr( '%'+m2s(i,"%.0f")+ '=[];'); end
  end
endfunction

function [ok,%L,%L2]= gtk_getvalue_list(%desc,%labels,%typ,%ini)
  // see getvalue
  [ok,%L,%L2]= getvalue_internal_list(%desc,%labels,%typ,%ini,use_dialog=%t,ch_fun=gtk_scicos_x_choices);
endfunction
