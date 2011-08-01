function scmenu_undo()
// jpc April 13 2009 
  Cmenu=''
  %pt=[]
  if isequal(enable_undo,2) then //open SB's may have been affected
    %r=2
    %r=message(['Undo operation undoes changes in a subdiagram';
                'These changes will be lost for ever'],['Proceed'; ...
                'Cancel'])
    if %r==2 then 
       return,
    else
      F=get_current_figure();
      F.draw_latter[];
      for i=1:length(scs_m.objs);
        if scs_m.objs(i).iskey['gr'] then 
          // we already have stuffs recorded 
          F.remove[scs_m.objs(i).gr];
          scs_m.objs(i).delete['gr'];
        end
      end
      scs_m=scs_m_save;
      Select=[];
      needcompile=nc_save;
      for i=1:length(scs_m.objs); scs_m.objs(i).delete['gr'];end
      scs_m=drawobjs(scs_m);
      supers=findopenchildren(scs_m,super_path,list(super_path))
      Scicos_commands=[]
      for i=1:size(supers)
        Scicos_commands=[Scicos_commands;
                 '%diagram_path_objective='+sci2exp(supers(i))+';%scicos_navig=1';
                 'Cmenu='"Replot'"']
       end
       enable_undo=%f;
    end
  elseif enable_undo then
    // new graphics version.
    // we first need to erase graphic objects.
    F=get_current_figure();
    F.draw_latter[];
    for i=1:length(scs_m.objs);
      if scs_m.objs(i).iskey['gr'] then 
        // we already have stuffs recorded 
        F.remove[scs_m.objs(i).gr];
        scs_m.objs(i).delete['gr'];
      end
    end
    scs_m=scs_m_save;
    Select=[];
    needcompile=nc_save
    // take care that scs_m_save shares 
    // graphics with previous scs_m;
    scs_m.props.wpar=scs_m.props
    %wdm=scs_m.props.wpar
    for i=1:length(scs_m.objs); scs_m.objs(i).delete['gr'];end
    //window_set_size();
    scs_m=drawobjs(scs_m);
    enable_undo=%f
  else
    message('No more undo available.')
  end
endfunction

function supers=findopenchildren(scs_m,super_path,supers)
// Copyright INRIA
//find paths to all open (inactive) sub-diagrams
  if nargin<3 then supers=list(),end
  for k=1:length(scs_m.objs)
    o=scs_m.objs(k)
    if o.type=='Block' then
      model=o.model
      if model.sim.equal['super'] then
        n=size(inactive_windows(1))
        for i=1:n
          path=inactive_windows(1)(i)
          if isequal(path,[super_path,k]) & or(winsid()==inactive_windows(2)(i)) then
             supers($+1)=[super_path,k]
             break
          end
        end
        supers=findopenchildren(model.rpar,[super_path,k],supers)
      end
    end
  end
endfunction
