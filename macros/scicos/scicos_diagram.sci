function diagram=scicos_diagram(varargopt) 
// 
// last keys tlist=%t and type='diagram' are added 
// to simulate a tlist of type diagram in nsp 
//
  diagram=hash(objs=list(),props=scicos_params(),...
	       version=get_scicos_version(),...
	       contrib=list(), codegen=scicos_codegen(),...
	       tlist=%t, type='diagram');
  diagram.merge[varargopt];
endfunction

