
function params=scicos_params(varargopt)
// updated to 4.4b7 
// default value last keys tlist=%t,type='params' are added to simulate a tlist 
// ot type params
  tf=100000;
  tol=[1.d-4,1.d-6,1.d-10,tf+1,0,0];
  params=hash(wpar=[600,450,0,0,600,450],title= 'Untitled',...
	      tf=tf,tol=tol,context='', void1=[],options=default_options(),...
	      void2=[], void3=[],doc=list(),...
	      params=%t, type='params',mlist=%f);
  params.merge[varargopt];
endfunction

