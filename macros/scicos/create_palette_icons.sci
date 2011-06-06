function create_palette_icons(palette='all')
// jpc April 2009 
// 
// This function will populate the current 
// directory with svg files, one for each 
// palette element.
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
      build_palette_icons(lisf)
    end
  end
endfunction

function build_palette_icons(lisf)
// lisf is a matrix of block names 
//
  for k=1:size(lisf,'*')
    fil = lisf(k);
    scs_m=scicos_diagram();
    name=file('rootname',fil);
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
