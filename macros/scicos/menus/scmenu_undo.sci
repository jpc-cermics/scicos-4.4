function scmenu_undo()
  Cmenu='';
  %pt=[];
  
  if isequal(enable_undo,2) then 
    // need also to replot sub diagrams 
    %r=message(['Undo operation undoes changes in a subdiagram';
                'These changes will be lost for ever'],['Proceed';'Cancel'])
    if isequal(%r,1) then
      [scs_m]     = do_undo(scs_m);
      Select      = [];
      needcompile = nc_save;
      supers=findopenchildren(scs_m,super_path,list(super_path))
      Scicos_commands=[]
      for i=1:size(supers)
        Scicos_commands=[Scicos_commands;
			 '%diagram_path_objective='+sci2exp(supers(i))+';%scicos_navig=1';
			 'Cmenu='"Replot'"'];
      end
      enable_undo = %f;
    end
  elseif enable_undo then
    [scs_m]     = do_undo(scs_m);
    Select      = [];
    needcompile = nc_save;
    enable_undo = %f;
  else
    message('No more undo available.')
  end
endfunction

function [scs_m]=do_undo(scs_m)
// make a undo 
// 
  F=get_current_figure();
  F.draw_latter[];// drawobjs will do the draw_now 
  for i=1:length(scs_m.objs);
    if scs_m.objs(i).iskey['gr'] then 
      // we already have stuffs recorded 
      F.remove[scs_m.objs(i).gr];
      scs_m.objs(i).delete['gr'];
    end
  end
  // restore scs_m with saved version taking care 
  // of getting rid of graphics objects in the saved 
  // version. (Note that scs_m should be saved in scs_m_save
  // it is useless and take memory).
  scs_m=scs_m_save;
  for i=1:length(scs_m.objs); scs_m.objs(i).delete['gr'];end
  window_set_size();
  scs_m=drawobjs(scs_m);
endfunction

function supers=findopenchildren(scs_m,super_path,supers)
// find paths to all open (inactive) sub-diagrams
  if nargin<3 then supers=list(),end
  for k=1:length(scs_m.objs)
    o=scs_m.objs(k)
    if o.type=='Block' then
      model=o.model
      if model.sim.equal['super'] then
	n=size(inactive_windows(1))
	for i=1:n
	  path=inactive_windows(1)(i)
	  if isequal(path,[super_path,k]) && or(winsid()==inactive_windows(2)(i)) then
	    supers($+1)=[super_path,k]
	    break
	  end
	end
	supers=findopenchildren(model.rpar,[super_path,k],supers)
      end
    end
  end
endfunction
