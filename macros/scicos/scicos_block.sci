
function blk=scicos_block(varargopt)
// updated to 4.4b7 
// default value last keys tlist=%t,type='Block' are added to simulate a tlist 
// ot type Block
  blk=hash(graphics=scicos_graphics(),model=scicos_model(),gui='',doc= list(),...
	   type='Block',tlist=%t);
  // merge with arguments 
  blk.merge[varargopt];
endfunction

function blk=scicos_text(varargopt)
//Block data structure initialization
  blk=hash(graphics=scicos_graphics(),model=scicos_model(),void='',gui='',...
	   type='Text',mlist=%t);
  // merge with arguments 
  blk.merge[varargopt];
endfunction
