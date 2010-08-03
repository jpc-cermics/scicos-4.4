function model=scicos_model(sim='',in=[],out=[],evtin=[],evtout=[],state= [],
  dstate=[],rpar=[],ipar=[],blocktype='c',firing=[],dep_ut=[%f,%f],label='',
  nzcross=0,nmode=0,equations=list())  
  // updated for nsp 
  model=tlist(['model','sim','in','out','evtin','evtout','state','dstate',...
	       'rpar','ipar','blocktype','firing','dep_ut','label',...
	       'nzcross','nmode','equations'],
               sim,in,out,evtin,evtout,state,dstate,
               rpar,ipar,blocktype,firing,dep_ut,label,nzcross,nmode,equations)
endfunction

