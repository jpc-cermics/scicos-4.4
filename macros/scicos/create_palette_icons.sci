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

function scs_m=scicos_show_icon(name,zoom=1.4)
// Utility function: 
//  shows in a graphic window the icon associated to scicos block named name. 
//  name can be a pathname, in that case the name of the block is the rootname 
//  of the tail of the pathname.
//
//  Note that the graphic window will have a minium size due to the
//  presence of menus. Thus when exporting we have a too big icons 
// 
// jpc (2011-2015)

// firts create a diagram with the named block
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
  win = window_newid();
  scs_m=scicos_diagram_show(scs_m,win=win,margins=%f);
endfunction

function scs_m_to_graphic_file(scs_m,name,figure_background=%f)
// export scs_m to graphic file (type given by name extension)
// by first drawing scs_m to a graphic window and then exporting.
// jpc (2011-2015)
  win = window_newid();// fresh graphic window 
  scs_m.props.zoom=1.4;// default 
  scicos_diagram_show(scs_m,win=win,margins=%f);
  xexport(win,name,figure_background=figure_background);
  xdel(win);
  // back to win -1 
  if win >= 1 then xset('window',win-1);end
endfunction
