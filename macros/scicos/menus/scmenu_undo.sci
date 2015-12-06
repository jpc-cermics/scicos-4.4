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
  xinfo('Undo');
  scs_m = scs_m_save;
  scs_m=scicos_diagram_show(scs_m,win=curwin,margins=%t,scicos_uim=%t,scicos_istop=slevel<=1,read=%f);
  xinfo(' ')
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
