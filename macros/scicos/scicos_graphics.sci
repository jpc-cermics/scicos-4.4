
function graphics=scicos_graphics(varargopt)
// updated to 4.4b7 
// default value last keys tlist=%t,type='graphics' are added to simulate a tlist 
// ot type graphics 
  graphics=hash( orig=[0 0], sz=[20 20], flip=%t,theta=0,  exprs=[],...
		 pin=[], pout=[], pein=[], peout=[], gr_i=[],...
		 id='',in_implicit=m2s([]),  out_implicit=m2s([]),...
		 tlist=%t,type='graphics');
  // merge with arguments 
  if varargopt.iskey['in_implicit'] then 
    if isempty(varargopt.in_implicit)
      I='E';
      varargopt.in_implicit = I(ones(size(varargopt.pin(:))));      
    end
  end
  if varargopt.iskey['out_implicit'] then 
    if isempty(varargopt.out_implicit) then 
      I='E';
      varargopt.out_implicit=I(ones(size(varargopt.pout(:))));
    end
  end
  graphics.merge[varargopt];
endfunction
