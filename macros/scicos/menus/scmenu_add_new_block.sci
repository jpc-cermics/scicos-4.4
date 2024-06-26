function scmenu_add_new_block()
  Cmenu=''
  [scs_m,%fct,Select]=do_addnew(scs_m,Select)
  if %fct<>"" then 
    exec(%fct),
    newblocks=[newblocks;%fct]
  end
endfunction

function [scs_m,fct,Select]=do_addnew(scs_m,Select)
//add a new block (defined by its GUI function)
//adapted to nsp new_graphics (jpc Feb 2011).
// Copyright INRIA
  fct=""
  [ok,name]=getvalue('Get block GUI function name',...
		     ['Name'],list('str',1),"");
  if ~ok then return,end
  // check is name is already loaded.
  if execstr('tp=type('+name+',''string'')',errcatch=%t) && tp == 'PList' then 
    to_get=%f;
  else
    to_get=%t
  end
  
  if to_get then 
    // try to load the file with code for name 
    path=xgetfile(title='Code for '+name,open=%t)
    if length(path)<=0 then return,end
    if ~file('exists',path) then 
      message(path+' file, Not found')
      return
    end
    extension=file('extension',path);
    if extension == '.sci' then 
      if execstr('exec('''+path+''');',errcatch=%t)==%f then
	message([name+' erroneous function:'])
	lasterror();
	return
      end 
    elseif extension == '.bin' then 
      if execstr('load('''+path+''');',errcatch=%t)==%f then
	message([name+' erroneous function:']);
	lasterror();
	return
      end 
    end
    if ~execstr('tp=type('+name+',''string'')',errcatch=%t) then 
      message([name+' not found in file '+path]);
      lasterror();
      return 
    end
    fct=path
  end

  //define the block
  if execstr('blk='+name+'(''define'');',errcatch=%t)==%f then
    message([sprintf(['Error in define for block %s'],name);
	     catenate(lasterror())]);
    fct=""
    return
  end
  xinfo('Choose block position in the window')

  // Interactive position of the block 
  xcursor(52);
  // initial point is %pt;
  // XXX: ici Il faudrait demander ou est la souris 
  //      pour correctement initialiser %pt. 
  // il faut une fonction pour cela 
  pt=%pt;
  if isempty(pt) then pt=[0.5,0.2];end 
  blk.graphics.sz=20*blk.graphics.sz;
  orig=[pt-blk.graphics.sz/2];
  options=scs_m.props.options
  X_W = options('Wgrid')(1)
  Y_W = options('Wgrid')(2)
  if options('Snap') then
    [orig]=get_wgrid_alignment(orig,[X_W Y_W])
  end
  blk.graphics.orig=orig;
  // record the objects in graphics 
  F=get_current_figure();
  F.draw_latter[];
  [blk,ok]=drawobj(blk,F);
  if ~ok then 
    fct=""
    F.draw_now[];
    xcursor();
    return;
  end
  blk.gr.invalidate[];
  rep(3)=-1
  while rep(3)==-1 then 
    // get new position
    //printf("In Copy moving %d\n",curwin);
    F.draw_now[]
    rep=xgetmouse(clearq=%f,getrelease=%t,cursor=%f)
    F.draw_latter[];
    [delta_x,delta_y,pt(1),pt(2)]=get_scicos_delta(rep,pt(1),pt(2),options('Snap'),X_W,Y_W)
    blk.gr.translate[[delta_x , delta_y]];
    blk.graphics.orig=blk.graphics.orig + [delta_x , delta_y]
  end
  if rep(3)==2 then 
    // this is a cancel 
    F.draw_latter[];
    F.remove[blk.gr];
    F.draw_now[];
    xcursor();
    return;
  end
  xcursor();
  xinfo(' ')
  
  F.draw_now[];
  scs_m_save=scs_m
  nc_save=needcompile

  // update 
  scs_m.objs($+1)=blk
  Select = [length(scs_m.objs), F.id];

  resume(scs_m_save,nc_save,enable_undo=%t,edited=%t,needcompile=4)
endfunction




