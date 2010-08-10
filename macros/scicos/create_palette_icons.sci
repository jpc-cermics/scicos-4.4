function create_palette_icons(palette='all')
// jpc April 2009 
// 
// This function will populate the current 
// directory with svg files 
// 
  if nargin < 1 then bidon='all';end
  scicos_ver='scicos2.7.3'
  
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
    ok=execstr('blk='+name+'(''define'')',errcatch=%t)
    if ~ok then
      message(['Error in '+name+'(''define'')';lasterror()] );
    else 
      blk.graphics.sz=20*blk.graphics.sz;
      blk.graphics.orig=[0,0];
      scs_m.objs(1)=blk
    end
    ok=execstr('scicos_view(scs_m)',errcatch=%t);
    if ~ok then 
      message(['Error when drawing '+name;catenate(lasterror())] );
    else
      win=xget('window');
      xexport(win,file('join',[name+'.svg']),figure_background=%f);
    end
  end
endfunction


