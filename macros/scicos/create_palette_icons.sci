function create_palette_icons(palette='all')
// This function will populate the current 
// directory with svg files, one for each 
// palette element.
// jpc: April 2009 
// 
  path=getenv('NSP')+'/macros/blocks'
  if palette=='all' then
    palette=scicos_get_palette_content('all');
  else
    palette=palette(:)'
  end
  for i=1:size(palette,'*') 
    txt = palette(i);
    printf('Constructing %s\n',txt)
    lisf=scicos_get_palette_content(txt);
    if isempty(lisf) then 
      printf('Palette '+txt+' does not exists\n')
    else 
      // here we could decide to create a .cos or a .cosf 
      scicos_create_icons(lisf)
    end
  end
endfunction

function scicos_create_icon(blockname)
// create an icon for block named name 
// used in Makefile 
  if %f then 
    path=file('join',[get_scicospath();'macros';'blocks';'*';blockname+'.sci']);
    files=glob(path);
    if isempty(files) then 
      message(['Error: block '+blockname+' not found!']);
      return;
    end
  end
  // here we could decide to create a .cos or a .cosf 
  scicos_create_icons(list(blockname));
endfunction

function scicos_create_icons(lisf)
// build icons for a set of blocks 
// listed in the lisf list by their names or path.
// when a path is given the name is obtained 
// as the rootname of the tail of the path.
// jpc
  for k=1:size(lisf,'*')
    fil = lisf(k);
    scs_m=scicos_diagram();
    name=file('tail',fil);
    name=file('rootname',name);
    //printf('  Block ' + name );
    ok=execstr('blk='+name+'(''define'')',errcatch=%t)
    if ~ok then
      message(['Error in '+name+'(''define'')';lasterror()] );
    else 
      blk.graphics.sz=35*blk.graphics.sz;
      blk.graphics.orig=[0,0];
      scs_m.objs(1)=blk
    end
    fname= file('join',[name+'.svg']);
    str = 'scs_m_to_graphic_file(scs_m,fname,figure_background=%f);';
    ok=execstr(str,errcatch=%t);
    if ~ok then 
      message(['Error when drawing '+name;catenate(lasterror())] );
    end
  end
endfunction

function scicos_show_icon(name,zoom=1.4)
// Utility function: 
// shows in a graphic window the icon associated 
// to a scicos block named name. 
// Note that the argument name can be a pathname, 
// in that case the name of the block is the rootname 
// of the tail of the pathname 
//
// jpc (2011)

  scs_m=scicos_diagram();
  scs_m.props.zoom=zoom;
  name=file('tail',name);
  name=file('rootname',name);
  //printf('  Block ' + name );
  ok=execstr('blk='+name+'(''define'')',errcatch=%t)
  if ~ok then
    message(['Error in '+name+'(''define'')';lasterror()] );
  else 
    blk.graphics.sz=35*blk.graphics.sz;
    blk.graphics.orig=[0,0];
    scs_m.objs(1)=blk
  end
  if ~isempty(winsid()) then 
    old_curwin=xget('window')
    curwin=max(winsid())+1
  else
    old_curwin=[];
    curwin=0;
  end
  xset('window',curwin);
  scs_m=scs_m_remove_gr(scs_m); 
  window_set_size(curwin,%f,read=%f);
  drawobjs(scs_m,curwin);
endfunction

function scs_m_to_graphic_file(scs_m,name,figure_background=%f)
// export scs_m to graphic file (type given by name extension)
// by first drawing scs_m to a graphic window and then exporting.
// similar to what is done in export but here we have to display 
// scs_m first.
// jpc 2011 
  if ~isempty(winsid()) then 
    old_curwin=xget('window')
    curwin=max(winsid())+1
  else
    old_curwin=[];
    curwin=0;
  end
  xset('window',curwin);
  scs_m=scs_m_remove_gr(scs_m);
  scs_m.props.zoom=1.0;
  // XXX do not put extensions around the graphics 
  window_set_size(curwin,%f,read=%f);
  drawobjs(scs_m,curwin);
  xexport(curwin,name,figure_background=figure_background);
  xdel(curwin);
  if ~isempty(old_curwin) then xset('window',old_curwin);end
endfunction
