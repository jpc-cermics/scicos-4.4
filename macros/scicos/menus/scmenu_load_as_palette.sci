function scmenu_load_as_palette()
  Cmenu=''
  [ok,sc]=do_load_as_palette(scs_m);
  if ok then scs_m = sc;end 
endfunction

function [ok,scs_m]=do_load_as_palette(scs_m)
//
// load a new diagram and place it in the current 
// diagram inside a PAL_f block.
//
  [ok,sc,cpr,edited]=do_load();
  if ~ok then return,end
  // create a palette block
  ok=execstr('blk=PAL_f(''define'')',errcatch=%t);
  if ~ok then 
    message('Failed to drop a ""PAL_f"" block !");
    lasterror();
    Cmenu='';
    return;
  else
    blk.graphics.sz=20*blk.graphics.sz;
  end
  blk.model.rpar = sc;
  // 
  blk.model.rpar.props.title='Palette: '+sc.props.title(1);
  blk.graphics.id = 'Palette: '+sc.props.title(1);
  %pt=[0,0];
  [%pt,scs_m,needcompile]=do_placeindiagram_new(scs_m,blk);
  // herited from do_place_in_diagram 
  resume(scs_m_save,nc_save,enable_undo=%t,edited=%t);
endfunction
