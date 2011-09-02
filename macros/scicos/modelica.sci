function mo=modelica()
  mo=tlist(['modelica','model','inputs','outputs','parameters'],[],[],[],[],list([],list()))
endfunction

function mo=scicos_modelica(varargopt)
// creates or updates a modelica tlist.
  mo=hash(model=[],inputs=[],outputs=[],parameters=list([],list()),...
	  type='modelica',tlist=%t);
  mo.merge[varargopt];
endfunction


