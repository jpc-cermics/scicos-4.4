function menu_stuff(win,menus)
// updates menus of a graphic window 
// 
  delmenu(win,'3D Rot.')
  delmenu(win,'UnZoom')
  delmenu(win,'Zoom')
  // delmenu(win,'File')
  if ~(type(menus,'short')== 'h') then return;end 
  for i=1:size(menus.items,'*')
    sname = menus.items(i);
    submenu=menus(sname);
    delmenu(win,sname);
    // printf("addmenu with %s %s\n",sname,submenu(1) );
    addmenu(win,sname,submenu(1),list(0,sname));    
  end
  if ~super_block then
    delmenu(win,'stop')
    addmenu(win,'stop||$scicos_stop');
    unsetmenu(win,'stop')
  else
    unsetmenu(win,'Simulate')
  end
endfunction

function [menus]=scicos_menu_prepare()
// returns a string matrix 
// [ menus-names, menus-action-name] 
// 
  names =['New';
	  'Open';
	  'Scicoslab Import';
	  'Save';
	  'Save As';
	  'Save as Interf Func';
	  'Export';
	  'Export All';
	  'Exit Scicos';
	  'Quit' ;
	  'Context';
	  'Replot';
	  'Rename';
	  'Purge';
	  'Set Diagram Info';
	  'Set Code Gen Properties';
	  'Region to Super Block';
	  'Up To Main Diagram';
	  'Up';
	  'Pal Tree';
	  'Palettes';
	  'Pal editor';
	  'Region to Palette';
	  'Load as Palette';
	  'Save as Palette';
	  'Undo';
	  'Cut';
	  'Copy';
	  'Paste';
	  'Duplicate';
	  'Delete';
	  'Move';
	  'Smart Move';
	  'Align';
	  'Flip';
	  'Rotate Left';
	  'Rotate Right';
	  'Add new block';
	  'Block Documentation';
	  'Label';
	  'Zoom in';
	  'Zoom out';
	  'Fit diagram to figure';
	  'Default window parameters';
	  'Available Parameters';
	  'Icon Font Option';
	  'Grid';
	  'Setup';
	  'Compile';
	  'Modelica initialize';
	  'Eval';
	  'Analyze Diagram';
	  'Debug Level';
	  'Run';
	  'Set default action';
	  'Set grid';
	  'Add color';
	  'Default link colors';
	  'Color';
	  'Background color';
	  'Show Block Shadow';
	  'Resize';
	  'Identification';
	  'ID fonts';
	  'Icon';
	  'Icon Editor';
	  'Activate ScicosLab Window';
	  'Create Mask';
	  'Remove Mask';
	  'Restore Mask';
	  'Customize Mask';
	  'Save Block GUI';
	  'Create Atomic';
	  'Remove Atomic';
	  'Get Info';
	  'Details';
	  'Browser';
	  'Code Generation';
	  'Shortcuts';
	  'Calc';
	  'Help';
          'Select All';
	  'Scicos Documentation';
	  'Demos';
	  'Force Open';
	  'About Scicos'];
  
  actions=scicos_action_name_to_fname(names);
  menus=[actions,actions;names,actions];

  menus = [menus;
	   'Link'            , 'scmenu_getlink'
	   'Open/Set'        , 'OpenSet_'
	   'CheckMove'       , 'scmenu_check_move'
	   'CheckKeyMove'    , 'scmenu_check_keymove'
	   'CheckSmartMove'  , 'scmenu_check_smart_move'
	   'CheckKeySmartMove', 'scmenu_check_keysmartmove'
	   'SelectLink'      , 'scmenu_check_select_link'
	   'CtrlSelect'      , 'CtrlSelect_'
	   'SelectRegion'    , 'SelectRegion_'
	   'Popup'           , 'Popup_'
	   'PlaceinDiagram'  , 'PlaceinDiagram_'
	   'PlaceDropped'    , 'PlaceDropped_'
	   'BrowseTo'        , 'BrowseTo_'
	   'Place in Browser', 'PlaceinBrowser_'
	   'Smart Link'      , 'scmenu_smart_getlink'];

endfunction
