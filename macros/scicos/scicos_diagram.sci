
function diagram=scicos_diagram(varargopt) 
// updated to 4.4b7 
// default value last keys tlist=%t,type='diagram' are added to simulate a tlist 
// ot type diagram.
    
  diagram=hash(objs=list(),props=scicos_params(),version='',...
	       contrib=list(), codegen=scicos_codegen(),...
	       tlist=%t, type='diagram');
  diagram.merge[varargopt];
endfunction

