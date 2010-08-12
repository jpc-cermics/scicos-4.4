
function model=scicos_model(varargopt) 
// updated to 4.4b7 
// default value last keys tlist=%t,type='model' are added to simulate a tlist 
// ot type model.
  
  model=hash(sim='', in=zeros(0,0), in2=zeros(0,0), intyp=1, out=zeros(0,0),...
	     out2=zeros(0,0), outtyp=1, evtin=[], evtout=[], state=[], dstate=[], ...
	     odstate=  list(), opar=list(), rpar=[], ipar=[], blocktype='c',...
	     firing=[], dep_ut=[%f %f], label='', nzcross=0, nmode=0,...
	     equations=list(), tlist=%t, type='model');
  model.merge[varargopt];
endfunction

