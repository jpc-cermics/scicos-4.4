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
      blk.graphics.sz=20*blk.graphics.sz;
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

function scicos_show_icon(name,zoom)
// Utility function: 
// shows in a graphic window the icon associated 
// to a scicos block named name. 
// Note that the argument name can be a pathname, 
// in that case the name of the block is the rootname 
// of the tail of the pathname 
//
// jpc (2011)
  if nargin <=1 then zoom=1;end 
  scs_m=scicos_diagram();
  name=file('tail',name);
  name=file('rootname',name);
  //printf('  Block ' + name );
  ok=execstr('blk='+name+'(''define'')',errcatch=%t)
  if ~ok then
    message(['Error in '+name+'(''define'')';lasterror()] );
  else 
    blk.graphics.sz=20*blk.graphics.sz;
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
  options=scs_m.props.options
  set_background();
  scs_m=scs_m_remove_gr(scs_m);
  %zoom=zoom*restore(curwin,[],1.0);
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
  options=scs_m.props.options
  set_background();
  scs_m=scs_m_remove_gr(scs_m);
  %zoom=restore(curwin,[],1.0);
  drawobjs(scs_m,curwin);
  // reset the extension just in case 
  xexport(curwin,name,figure_background=figure_background);
  xdel(curwin);
  if ~isempty(old_curwin) then xset('window',old_curwin);end
endfunction
