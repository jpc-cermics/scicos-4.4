function options=scicos_options(varargopt)
// using a hash table
//
// change default_options to scicos_options
// Add Grid,Wgrid,Action,Snap and type
// A.L : 11/09/13
  col3d=[0.8 0.8 0.8]
  options=hash_create(6, Background=[8 1],...
		      Link=[1,5,2],...
		      ID=list([4 1 10 1],[4 1 2 1]),...
		      Cmap=col3d,...
		      D3=list(%t,33) ); 
  options('3D')=list(%t,33);
  options('Grid')=%f;
  options('Wgrid')=[10;10;12];
  options('Action')=%t;
  options('Snap')=%f;
  options('type')='options';
  options.merge[varargopt];
endfunction
