function Addnewblock_()
  Cmenu=''
  [scs_m,%fct]=do_addnew(scs_m)
  if %fct<>"" then 
    exec(%fct),
    newblocks=[newblocks;%fct]
  end
endfunction

function [scs_m,fct]=do_addnew(scs_m)
//add a new block (defined by its GUI function to a palette
//!
// Copyright INRIA
  fct=""
  [ok,name]=getvalue('Get block GUI function name',...
		     ['Name'],list('str',1),"");
  if ~ok then return,end

  // check is name is already loaded.
  if execstr('tp=type('+name+',''string'')',errcatch=%t) && tp == 'PList' then 
    to_get = %f;
  else
    to_get=%t
  end

  if to_get then // try to get it
    path=xgetfile(title='Code for '+name,open=%t)
    if length(path)<=0 then return,end
    if ~file('exists',path) then 
      message(path+' file, Not found')
      return
    end
    extension=file('extension',path);
    if extension == '.sci' then 
      if execstr('exec('''+path+''');',errcatch=%t)==%f then
	message([name+' erroneous function:'])// ;lasterror()])
	return
      end 
    elseif extension == '.bin' then 
      if execstr('load('''+path+''');',errcatch=%t)==%f then
	message([name+' erroneous function:'])// ;lasterror()])
	return
      end 
    end
    if ~execstr('tp=type('+name+',''string'')',errcatch=%t) then 
      message([name+' not found in file '+path])// ;lasterror()])
      return 
    end
    fct=path
  end

  //define the block
  if execstr('blk='+name+'(''define'');',errcatch=%t)==%f then
    message(['Error in GUI function'])//;lasterror()] )
    fct=""
    return
  end
  xinfo('Choose block position in the window')
  rep(3)=-1
  // redraw with recoding 
  scicos_redraw_scene(scs_m,[],1)
      
  blk.graphics.sz=20*blk.graphics.sz;
  [xy,sz]=(blk.graphics.orig,blk.graphics.sz)
  
  xtape_status=xget('recording');
  xset('recording',0);
  while rep(3)==-1 , 
    // redraw the non moving objects using recorded 
    // graphics.
    xset("recording",1);
    xclear(curwin,%f);
    xtape('replay',curwin);
    xset("recording",0);
    // draw block shape
    xrect(%xc,%yc+sz(2),sz(1),sz(2))
    xset('wshow');
    // get new position
    rep=xgetmouse(clearq=%f)
    %xc=rep(1);%yc=rep(2)
    xy=[%xc,%yc];
  end
  xinfo(' ')
  // update 
  blk.graphics.orig=xy
  // now redraw 
  xset("recording",1);
  xclear(curwin,%f);
  xtape('replay',curwin);
  drawobj(blk)
  if pixmap then xset('wshow'),end    
  xset("recording",xtape_status);  
  scs_m.objs($+1)=blk
endfunction
