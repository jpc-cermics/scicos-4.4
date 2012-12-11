function [menus]=scicos_menu_prepare()
// returns a string matrix 
// [ menus-names, menus-action-name] 

  [names,actions]=get_scicos_menu_names(%scicos_menu);

  menus=[names,actions];
   
  //adding here some hidden internal
  //scicos items which are not in the menus/toolbar
  //and then do not need gtk action
  menus = [menus;
	   'Link'            , 'scmenu_getlink'
	   'Open/Set'        , 'OpenSet_'
           'Force Open'      , 'scmenu_force_open',
           'Move'            , 'scmenu_move',
           'Smart Move'      , 'scmenu_smart_move',
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

  menus=[menus(:,2),menus(:,2);menus];

endfunction

function [names,actions]=get_scicos_menu_names(%scicos_menu,names=[],actions=[])

  for i=1:length(%scicos_menu)
    if type(%scicos_menu(i),'string')=='SMat' then
      if %scicos_menu(i)(2)=='menuitem' then
        names=[names;%scicos_menu(i)(1)];
        actions=[actions;%scicos_menu(i)(3)];
      end
     else
       [names,actions]=get_scicos_menu_names(%scicos_menu(i),names=names,actions=actions)
     end
  end

endfunction
