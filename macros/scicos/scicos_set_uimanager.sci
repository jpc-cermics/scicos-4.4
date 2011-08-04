// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Library General Public
// License as published by the Free Software Foundation; either
// version 2 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Library General Public License for more details.
//
// You should have received a copy of the GNU Library General Public
// License along with this library; if not, write to the
// Free Software Foundation, Inc., 59 Temple Place - Suite 330,
// Boston, MA 02111-1307, USA.
//
// (Copyright (C) 20011-2011 Jean-Philippe Chancelier)

function scicos_set_uimanager(is_top)
// Get the vbox which contains the default menubar 
// and replace the menubar by a scicos menubar/toolbar 
// using the gtkuimanager mechanism.
//
  
  function txt=scicos_toolbar(is_top,action_group,merge)
  // text for the toolbar 
    txt =[ "  <toolbar name=""toolbar"">"
	   "    <toolitem name=""Zoom in"" action=""scmenu_zoom_in"" />"
	   "    <toolitem name=""Zoom out"" action=""scmenu_zoom_out"" />"
	   "    <toolitem name=""Zoom fit"" action=""scmenu_fit_diagram_to_figure"" />"
	   "    <toolitem name=""Zoom 100"" action=""scmenu_zoom_100"" />"
	   "    <separator name=""tsep1"" />"
	   "    <toolitem name=""Cut"" action=""scmenu_cut"" />"
	   "    <toolitem name=""Copy"" action=""scmenu_copy"" />"
	   "    <toolitem name=""Paste"" action=""scmenu_paste"" />"
	   "    <separator name=""tsep3"" />"];
    if ~is_top then 
      txt.concatd[[ "    <toolitem name=""up"" action=""scmenu_up"" />"
		    "    <toolitem name=""uptop"" action=""scmenu_up_to_main_diagram"" />"
		    "    <separator name=""tsep4""/>"]];
    end
    txt.concatd[[ "    <toolitem name=""prefs"" action=""scmenu_setup"" />"
		  "    <toolitem name=""compile"" action=""scmenu_compile"" />"
		  "    <toolitem name=""run"" action=""scmenu_run"" />"
		  "    <toolitem name=""stop"" action=""$scicos_stop"" />"
		  "    <separator name=""tsep4""/>"
		  "    <toolitem name=""Quit"" action=""scmenu_quit"" />"
		  "  </toolbar>"]];
    // just return a string 
    txt  = catenate(txt,sep='\n');
  endfunction

  function txt=scicos_menubar(action_group,merge)
  // Scicos Menu definitions
  // 
  // 
    txt= [ "  <menubar>";
	   "    <menu name=""File"" action=""scmenu_file_menu"">";
	   "      <menuitem name=""New"" action=""scmenu_new"" />";
	   "      <menuitem name=""Open"" action=""scmenu_open"" />";
	   "      <menuitem name=""Scicoslab Import"" action=""scmenu_scicoslab_import"" />";
	   "      <menuitem name=""Save"" action=""scmenu_save"" />";
	   "      <menuitem name=""Save As"" action=""scmenu_save_as"" />";
	   "      <menuitem name=""Save as Interf Func"" action=""scmenu_save_as_interf_func"" />";
	   "      <menuitem name=""Export"" action=""scmenu_export"" />";
	   "      <menuitem name=""Export All"" action=""scmenu_export_all"" />";
	   "      <menuitem name=""Exit Scicos"" action=""scmenu_exit_scicos"" />";
	   "      <menuitem name=""Quit"" action=""scmenu_quit"" />";
	   "    </menu>";
	   "    <menu name=""Diagram"" action=""scmenu_diagram_menu"">";
	   "      <menuitem name=""Context"" action=""scmenu_context"" />";
	   "      <menuitem name=""Replot"" action=""scmenu_replot"" />";
	   "      <menuitem name=""Rename"" action=""scmenu_rename"" />";
	   "      <menuitem name=""Purge"" action=""scmenu_purge"" />";
	   "      <menuitem name=""Set Diagram Info"" action=""scmenu_set_diagram_info"" />";
	   "      <menuitem name=""Set Code Gen Properties"" action=""scmenu_set_code_gen_properties"" />";
	   "      <menuitem name=""Region to Super Block"" action=""scmenu_region_to_super_block"" />";
	   "      <menuitem name=""Up To Main Diagram"" action=""scmenu_up_to_main_diagram"" />";
	   "    </menu>";
	   "    <menu name=""Palette"" action=""scmenu_palette_menu"">";
	   "      <menuitem name=""Pal Tree"" action=""scmenu_pal_tree"" />";
	   "      <menuitem name=""Palettes"" action=""scmenu_palettes"" />";
	   "      <menuitem name=""Pal editor"" action=""scmenu_pal_editor"" />";
	   "      <menuitem name=""Region to Palette"" action=""scmenu_region_to_palette"" />";
	   "      <menuitem name=""Load as Palette"" action=""scmenu_load_as_palette"" />";
	   "      <menuitem name=""Save as Palette"" action=""scmenu_save_as_palette"" />";
	   "    </menu>";
	   "    <menu name=""Edit"" action=""scmenu_edit_menu"">";
	   "      <menuitem name=""Undo"" action=""scmenu_undo"" />";
	   "      <menuitem name=""Cut"" action=""scmenu_cut"" />";
	   "      <menuitem name=""Copy"" action=""scmenu_copy"" />";
	   "      <menuitem name=""Paste"" action=""scmenu_paste"" />";
	   "      <menuitem name=""Duplicate"" action=""scmenu_duplicate"" />";
	   "      <menuitem name=""Delete"" action=""scmenu_delete"" />";
	   "      <menuitem name=""Move"" action=""scmenu_move"" />";
	   "      <menuitem name=""Smart Move"" action=""scmenu_smart_move"" />";
	   "      <menuitem name=""Align"" action=""scmenu_align"" />";
	   "      <menuitem name=""Flip"" action=""scmenu_flip"" />";
	   "      <menuitem name=""Add new block"" action=""scmenu_add_new_block"" />";
	   "      <menu name=""Block Menu"" action=""scmenu_block_menu"">";
	   "        <menuitem name=""Resize"" action=""scmenu_resize"" />";
	   "        <menuitem name=""Rotate Left"" action=""scmenu_rotate_left"" />";
	   "        <menuitem name=""Rotate Right"" action=""scmenu_rotate_right"" />";
	   "        <menuitem name=""Icon"" action=""scmenu_icon"" />";
	   "        <menuitem name=""Icon Editor"" action=""scmenu_icon_editor"" />";
	   "        <menuitem name=""Color"" action=""scmenu_color"" />";				    
	   "        <menuitem name=""Label"" action=""scmenu_label"" />";
	   "        <menuitem name=""Get Info"" action=""scmenu_get_info"" />";
	   "        <menuitem name=""Details"" action=""scmenu_details"" />";
	   "        <menuitem name=""Identification"" action=""scmenu_identification"" />";
	   "        <menuitem name=""Block Documentation"" action=""scmenu_block_documentation"" />";
	   "      </menu>"
	   "    </menu>";
	   "    <menu name=""View"" action=""scmenu_view_menu"">";
	   "      <menuitem name=""Zoom in"" action=""scmenu_zoom_in"" />";
	   "      <menuitem name=""Zoom out"" action=""scmenu_zoom_out"" />";
	   "      <menuitem name=""Zoom 100"" action=""scmenu_zoom_100"" />";
	   "      <menuitem name=""Fit diagram to figure"" action=""scmenu_fit_diagram_to_figure"" />";
	   "      <menuitem name=""Default window parameters"" action=""scmenu_default_window_parameters"" />";
	   "      <menuitem name=""Available Parameters"" action=""scmenu_available_parameters"" />";
	   "      <menuitem name=""Icon Font Option"" action=""scmenu_icon_font_option"" />";
	   "      <menuitem name=""Grid"" action=""scmenu_grid"" />";
	   "    </menu>";
	   "    <menu name=""Simulate"" action=""scmenu_simulate_menu"">";
	   "      <menuitem name=""Setup"" action=""scmenu_setup"" />";
	   "      <menuitem name=""Compile"" action=""scmenu_compile"" />";
	   "      <menuitem name=""Modelica initialize"" action=""scmenu_modelica_initialize"" />";
	   "      <menuitem name=""Eval"" action=""scmenu_eval"" />";
	   "      <menuitem name=""Analyze Diagram"" action=""scmenu_analyze_diagram"" />";
	   "      <menuitem name=""Debug Level"" action=""scmenu_debug_level"" />";
	   "      <menuitem name=""Run"" action=""scmenu_run"" />";
	   "    </menu>";
	   "    <menu name=""Format"" action=""scmenu_format_menu"">";
	   "      <menuitem name=""Set default action"" action=""scmenu_set_default_action"" />";
	   "      <menuitem name=""Set grid"" action=""scmenu_set_grid"" />";
	   "      <menuitem name=""Add Color"" action=""scmenu_add_color"" />";
	   "      <menuitem name=""Default link colors"" action=""scmenu_default_link_colors"" />";
	   "      <menuitem name=""Color"" action=""scmenu_color"" />";
	   "      <menuitem name=""Background color"" action=""scmenu_background_color"" />";
	   "      <menuitem name=""Show Block Shadow"" action=""scmenu_show_block_shadow"" />";
	   "      <menuitem name=""ID fonts"" action=""scmenu_id_fonts"" />";
	   "    </menu>";
	   "    <menu name=""Tools"" action=""scmenu_tools_menu"">";
	   "      <menuitem name=""Activate ScicosLab Window"" action=""scmenu_activate_scicoslab_window"" />";
	   "    <separator name=""sep0"" />";
	   "      <menuitem name=""Create Mask"" action=""scmenu_create_mask"" />";
	   "      <menuitem name=""Remove Mask"" action=""scmenu_remove_mask"" />";
	   "      <menuitem name=""Customize Mask"" action=""scmenu_customize_mask"" />";
	   "      <menuitem name=""Save Block GUI"" action=""scmenu_save_block_gui"" />";
	   "      <separator name=""sep1"" />";
	   "      <menuitem name=""Create Atomic"" action=""scmenu_create_atomic"" />";
	   "      <menuitem name=""Remove Atomic"" action=""scmenu_remove_atomic"" />";
	   "      <menuitem name=""Browser"" action=""scmenu_browser"" />";
	   "      <menuitem name=""Code Generation"" action=""scmenu_code_generation"" />";
	   "      <menuitem name=""Shortcuts"" action=""scmenu_shortcuts"" />";
	   "      <menuitem name=""Calc"" action=""scmenu_calc"" />";
	   "    </menu>";
	   "    <menu name=""Help"" action=""scmenu_help_menu"">";
	   "      <menuitem name=""Help"" action=""scmenu_help"" />";
	   "      <menuitem name=""Scicos Documentation"" action=""scmenu_scicos_documentation"" />";
	   "      <menuitem name=""Demos"" action=""scmenu_demos"" />";
	   "      <menuitem name=""About Scicos"" action=""scmenu_about_scicos"" />";
	   "    </menu>";
	   "  </menubar>" ];
    // 
    txt  = catenate(txt,sep='\n');    
        
    // a set of Actions given as a list 
    
    L=list();
    L(1) = ['scmenu_file_menu','File',"","";
	    'scmenu_new','New',"","";
	    'scmenu_open','Open',"","";
	    'scmenu_scicoslab_import','Scicoslab Import',"","";
	    'scmenu_save','Save',"","";
	    'scmenu_save_as','Save As',"","";
	    'scmenu_save_as_interf_func','Save as Interf Func',"","";
	    'scmenu_export','Export',"","";
	    'scmenu_export_all','Export All',"","";
	    'scmenu_exit_scicos','Exit Scicos',"","";
	    'scmenu_quit','Quit',"","gtk-quit"];

    L(2) = ['scmenu_diagram_menu','Diagram',"","";
	    'scmenu_context','Context',"","";
	    'scmenu_replot','Replot',"","";
	    'scmenu_rename','Rename',"","";
	    'scmenu_purge','Purge',"","";
	    'scmenu_set_diagram_info','Set Diagram Info',"","";
	    'scmenu_set_code_gen_properties','Set Code Gen Properties',"","";
	    'scmenu_region_to_super_block','Region to Super Block',"","";
	    'scmenu_up_to_main_diagram','Up To Main Diagram',"","gtk-goto-top";
    	    'scmenu_up','Up to Parent',"","gtk-go-up"];
    
    L(3) = ['scmenu_palette_menu','Palette',"","";
	    'scmenu_pal_tree','Pal Tree',"","";
	    'scmenu_palettes','Palettes',"","";
	    'scmenu_pal_editor','Pal editor',"","";
	    'scmenu_region_to_palette','Region to Palette',"","";
	    'scmenu_load_as_palette','Load as Palette',"","";
	    'scmenu_save_as_palette','Save as Palette',"",""];

    L(4) = ['scmenu_edit_menu','Edit',"","";
	    'scmenu_undo','Undo',"","gtk-undo";
	    'scmenu_cut','Cut',"<control>X","gtk-cut";
	    'scmenu_copy','Copy',"<Ctrl>c","gtk-copy";
	    'scmenu_paste','Paste',"<Ctrl>v","gtk-paste";
	    'scmenu_duplicate','Duplicate',"","";
	    'scmenu_delete','Delete',"Delete","";
	    'scmenu_move','Move',"","";
	    'scmenu_smart_move','Smart Move',"","";
	    'scmenu_align','Align',"","";
	    'scmenu_flip','Flip',"","";
	    'scmenu_rotate_left','Rotate Left',"","";
	    'scmenu_rotate_right','Rotate Right',"","";
	    'scmenu_add_new_block','Add new block',"","";
	    'scmenu_block_documentation','Block Documentation',"","";..
	    'scmenu_label','Label',"",""];

    L(5) = ['scmenu_view_menu','View',"","";
	    'scmenu_zoom_in','Zoom in',"","gtk-zoom-in";
	    'scmenu_zoom_out','Zoom out',"","gtk-zoom-out";
	    'scmenu_zoom_100','Zoom 100',"","gtk-zoom-100";
	    'scmenu_fit_diagram_to_figure','Fit diagram to figure',"","gtk-zoom-fit";
	    'scmenu_default_window_parameters','Default window parameters',"","";
	    'scmenu_available_parameters','Available Parameters',"","";
	    'scmenu_icon_font_option','Icon Font Option',"","";
	    'scmenu_grid','Grid',"",""];

    L(6) = ['scmenu_simulate_menu','Simulate',"","";
	    'scmenu_setup','Setup',"","gtk-preferences";
	    'scmenu_compile','Compile',"","gtk-execute";
	    'scmenu_modelica_initialize','Modelica initialize',"","";
	    'scmenu_eval','Eval',"","";
	    'scmenu_analyze_diagram','Analyze Diagram',"","";
	    'scmenu_debug_level','Debug Level',"","";
	    'scmenu_run','Run',"","gtk-media-play"];

    L(7) = ['scmenu_format_menu','Format',"","";
	    'scmenu_set_default_action','Set Default Action',"","";
	    'scmenu_set_grid','Set grid',"","";
	    'scmenu_add_color','Add Color',"","";
	    'scmenu_default_link_colors','Default Link Colors',"","";
	    'scmenu_color','Color',"","";
	    'scmenu_background_color','Background Color',"","";
	    'scmenu_show_block_shadow','Show Block Shadow',"","";
	    'scmenu_resize','Resize',"","";
	    'scmenu_identification','Identification',"","";
	    'scmenu_id_fonts','ID fonts',"","";
	    'scmenu_icon','Icon',"","";
	    'scmenu_icon_editor','Icon Editor',"",""];

    L(8) = ['scmenu_tools_menu','Tools',"","";
	    'scmenu_activate_scicoslab_window','Activate ScicosLab Window',"","";
	    'scmenu_create_mask','Create Mask',"","";
	    'scmenu_remove_mask','Remove Mask',"","";
	    'scmenu_customize_mask','Customize Mask',"","";
	    'scmenu_save_block_gui','Save Block GUI',"","";
	    'scmenu_create_atomic','Create Atomic',"","";
	    'scmenu_remove_atomic','Remove Atomic',"","";
	    'scmenu_get_info','Get Info',"","";
	    'scmenu_details','Details',"","";
	    'scmenu_browser','Browser',"","";
	    'scmenu_code_generation','Code Generation',"","";
	    'scmenu_shortcuts','Shortcuts',"","";
	    'scmenu_calc','Calc',"",""];

    L(9) = ['scmenu_help_menu','Help',"","";
	    'scmenu_help','Help',"","";
	    'scmenu_scicos_documentation','Scicos Documentation',"","";
	    'scmenu_demos','Demos',"","";
	    'scmenu_about_scicos','About Scicos',"",""];

    // menu Edit->Block 
    
    L(10)=["scmenu_block_menu","Block","",""];
        
    // get the menu helps to obtain the tooltips 
    H=scicos_help_menu();
    count=0;
    for i=1:length(L)
      M=L(i);
      action = gtkaction_new( M(1,1), M(1,2) , M(1,3), M(1,4) );
      action_group.add_action[action];
      for j=2:size(M,'r')
	if H.iskey[M(j,1)] then 
	  ttip=catenate(H(M(j,1)),sep='\n');
	else
	  ttip=M(j,3);
	end
	action = gtkaction_new( M(j,1), M(j,2) , ttip , M(j,4) );
	action.connect["activate",scicos_activate_action,list(merge)];
	if M(j,3)=="" then 
	  action_group.add_action[action];
	else
	  action_group.add_action_with_accel[action,accelerator=M(j,3)];
	end
      end
    end
  endfunction
  
  // main code 
  // ---------
  
  win=xget('window');
  window=nsp_graphic_widget(win);
  // only one children which is a GtkVBox
  L=window.get_children[];
  L=L(1).get_children[];
  // get the vertical box vb 
  vb=L(1);
  mb=vb.get_children[];
  // if we already have more than 1 widget it means we 
  // already have a toolbar.
  if length(mb) > 1 then;return;end 
  mb=mb(1);
  // mb.destroy[];
  mb.hide[];
  // 
  merge = gtkuimanager_new ();
  merge.connect['connect-proxy',scicos_uimanager_connect_proxy];
  action_group = gtkactiongroup_new("TestActions")
  // creates a set of actions 
  action = gtkaction_new( "$scicos_stop","Stop","Stops scicos simulation ", "gtk-media-stop");
  action.connect["activate",scicos_activate_action,list(merge)];
  action_group.add_action[action];
  //toogle action 
  //action = gtktoggleaction_new("bold","_Bold","Smart moves as default", "gtk-bold");
  //action.connect["activate",scicos_toggle_action,list(merge)];
  //action_group.add_action_with_accel[action,accelerator="<control>B"];
  // 
  merge.insert_action_group[action_group, 0];
  merge.set_data[ui_id=-1];
  // the ui manager will add widgets in vb 
  merge.connect["add_widget", scicos_add_widget, list(vb)];
  // 
  merge.set_data[win=win];
  window.add_accel_group[merge.get_accel_group[]];
  // to access to actions through window id
  window.set_data[uimanager=merge];
  mb_text=scicos_menubar(action_group,merge);
  tb_text=scicos_toolbar(is_top,action_group,merge);
  ui_text=catenate([mb_text,tb_text],sep='\n');
  // XXXX changer l'interface pour enlever length !!
  rep = merge.add_ui_from_string[ui_text,length(ui_text)];
  // XXX revoir le rep 
  if rep==0 then 
    printf("building menus failed: \n");
  end
endfunction

function scicos_activate_action(action,args) 
// default handler activated by actions 
// redirect activation to standard menu 
// mechanism through nsp_enqueue_command
  merge=args(1);
  if merge.check_data['win']==%f then return;end 
  win = merge.get_data['win'];
  name = action.get_name[];
  if %f && part(name,1)<>'$' then 
    name=scicos_action_name_to_fname(name)
  end
  typename=type(action,'string');
  printf("Action %s (type=%s) win=%d activated\n", name, typename,win);
  nsp_enqueue_command(win,name);
endfunction

function scicos_add_widget(merge,widget,args)
// this function is called by the ui manager 
// to insert widgets in args(1)
  container=args(1);
  container.pack_start[widget,expand=%f,fill=%f,padding=0];
  widget.show[];
  if type(widget,'short')=='GtkToolbar' then 
    toolbar = widget;
    // toolbar.set_icon_size[GTK.ICON_SIZE_SMALL_TOOLBAR];
    // toolbar.set_icon_size[GTK.ICON_SIZE_LARGE_TOOLBAR];
    merge.set_data[toolbar=toolbar];
    // this should be compatible with value selected in radio_actions
    toolbar.set_style[0];
    // toolbar.show_arrow[%t];
  end 
endfunction

function scicos_uimanager_connect_proxy(uimgr, action, widget)
// used to add tooltips to menu items 
  //pause in uimanager_connect_proxy
  tooltip = action.get_property['tooltip']
  if tooltip=="" then return;end
  if is(widget,%types.GtkMenuItem) then 
    widget.set_tooltip_text[tooltip];
  end
endfunction 

function fname=scicos_action_name_to_fname(name)
// from action name to the name of the nsp associated 
// handler 
  name = strsubst(tolower(name),' ','_');
  fname='scmenu_'+name
endfunction

function scicos_action_set_sensitivity(win,name,sensitive)
//
  return; // temporarily not activated XXXX
  window=nsp_graphic_widget(win);
  if window.check_data['uimanager']==%f then return;end 
  uimanager = window.get_data['uimanager'];
  L=uimanager.get_action_groups[]
  if isempty(L) then return;end 
  action_group = L(1)
  // Attention bug si name n'existe pas 
  action = action_group.get_action[name];
  action.set_property["sensitive", sensitive];
endfunction


  

