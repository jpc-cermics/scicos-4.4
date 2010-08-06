
function lnk=scicos_link(varargopt)
// updated to 4.4b7 
// default value last keys tlist=%t,type='Link' are added to simulate a tlist 
// ot type Link
  lnk=hash(xx=[],yy=[],id='drawlink',thick=[0,0],ct=[1,1],from=[],to=[],...
		tlist=%t,type='Link');
  // merge with arguments 
  lnk.merge[varargopt];
endfunction
