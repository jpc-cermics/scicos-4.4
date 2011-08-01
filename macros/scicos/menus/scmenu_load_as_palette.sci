function scmenu_load_as_palette()
  Cmenu=''
  [palettes,windows]=do_load_as_palette(palettes,windows)
endfunction

function [palettes,windows]=do_load_as_palette(palettes,windows)
// Copyright INRIA

  [ok,scs_m,cpr,edited]=do_load();
  if ~ok then return,end
  // get a palette id 
  maxpal=-min([-200;windows(:,1)]) 
  kpal=maxpal+1
  lastwin=curwin
  curwin=get_new_window(windows)
  if or(curwin==winsid()) then
    xdel(curwin);
  end
  windows=[windows;[-kpal curwin]]
  scs_m=scs_m_remove_gr(scs_m);
  if ~set_cmap(scs_m.props.options('Cmap')) then // add colors if required
    scs_m.props.options('3D')(1)=%f //disable 3D block shape
  end
  // open the palette window 
  restore(curwin,[],%zoom);
  delmenu(curwin,'3D Rot.')
  delmenu(curwin,'UnZoom')
  delmenu(curwin,'Zoom')
  scs_m=drawobjs(scs_m,curwin);
  palettes(kpal)=scs_m;
  xinfo('Palette: may be used to copy  blocks or regions')
  xset('window',lastwin)
endfunction
