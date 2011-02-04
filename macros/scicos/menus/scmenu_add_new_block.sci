function Addnewblock_()
  Cmenu=''
  [scs_m,%fct]=do_addnew(scs_m)
  if %fct<>"" then 
    exec(%fct),
    newblocks=[newblocks;%fct]
  end
endfunction

function [scs_m,fct]=do_addnew(scs_m)
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
    message(['Error in GUI function']);
    lasterror();
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
  if isempty(pt) then pt=[0,0];end 
  blk.graphics.sz=20*blk.graphics.sz;
  blk.graphics.orig=[pt-blk.graphics.sz/2];
  // record the objects in graphics 
  F=get_current_figure();
  F.draw_latter[];
  F.start_compound[];
  drawobj(blk)
  C=F.end_compound[];
  blk.gr = C;
  F.draw_now[];
  C.invalidate[];
  rep(3)=-1
  while rep(3)==-1 then 
    // get new position
    //printf("In Copy moving %d\n",curwin);
    rep=xgetmouse(clearq=%f,getrelease=%t,cursor=%f)
    tr = rep(1:2) - pt;
    pt = rep(1:2)
    F.draw_latter[];
    blk.gr.translate[tr];
    blk.graphics.orig=blk.graphics.orig + tr;
    F.draw_now[];
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
  // update 
  scs_m.objs($+1)=blk
endfunction




