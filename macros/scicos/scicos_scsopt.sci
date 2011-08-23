function opts=scicos_scsopt(varargopt) 
// 
// last keys tlist=%t and type='scsopt' are added 
// to simulate a tlist of type diagram in nsp 
//
  opts=hash(6, Background=[8 1],...
	    Link=[1,5],...
	    ID=list([5 0],[4 0]),...
	    Cmap=[0.8 0.8 0.8], D3=list(%t,33),...
	    tlist=%t, type='scsopt');
  opts('3D')=list(%t,33);
       
  opts.merge[varargopt];
endfunction
