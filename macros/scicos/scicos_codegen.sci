
function codegen=scicos_codegen(varargopt) 
// updated to 4.4b7 
// default value last keys tlist=%t,type='codegen' are added to 
// simulate a tlist of type codegen.

  codegen=hash( silent=0, cblock=0, rdnom=[], rpat=[], libs=[], opt=1, ...
		enable_debug=0, scopes=[], remove=[], replace=[],...
		tlist=%t, type='codegeneration');
  codegen.merge[varargopt];
endfunction

