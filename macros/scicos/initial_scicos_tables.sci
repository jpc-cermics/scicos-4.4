function [%scicos_pal,%scicos_menu, %scicos_toolbar, %scicos_short, %scicos_help, ...
          %scicos_topics, %scicos_display_mode, modelica_libs, ...
          %scicos_lhb_list, %CmenuTypeOneVector, %DmenuTypeOneVector, %scicos_gif, ...
          %scicos_contrib,%scicos_libs,%scicos_cflags] = initial_scicos_tables()

  // build a set of scicos global data
  //

  scicospath=get_scicospath()

  %scicos_display_mode=0  // =1 if pixmap to be used for display
  %scicos_gif=file('join',[scicospath,'macros/scicos/scicos-images']);
  %scicos_contrib=[];
  %scicos_libs=m2s([]);// string matrix
  %scicos_cflags=[];
  %scicos_topics=hash(10);// hasch table used for help topics

  //Scicos Menu definitions===================================================
  //**
  //** each item is defined as [name|||stockid type action accel stockiditem]
  //**
  //** if name|||stockid is used then the default stockid label
  //** and stockid item will be considered
  //**
  //** scmenu_up/scmenu_up_to_main_diagram are removed from top level diagram

  File =     list(["_File"                 "menu"      "scmenu_file_menu"           "" ""],
                  ["New|||gtk-new"         "menuitem"  "scmenu_new"                 "<Ctrl>N" ""],
                  ["sep0"                  "separator" ""                           "" ""],
                  ["Open|||gtk-open"       "menuitem"  "scmenu_open"                "<Ctrl>O" ""],
                  ["Scicoslab Import"      "menuitem"  "scmenu_scicoslab_import"    "" "gtk-convert"],
                  ["Mdl or Slx Import"        "menuitem"  "scmenu_simulink_import"     "" "gtk-convert"],
                  ["sep1"                  "separator" ""                           "" ""],
                  ["Save|||gtk-save"       "menuitem"  "scmenu_save"                "<Ctrl>S" ""],
                  ["Save As|||gtk-save-as" "menuitem"  "scmenu_save_as"             "" ""],
                  ["Save as Interf Func"   "menuitem"  "scmenu_save_as_interf_func" "" ""],
                  ["sep2"                  "separator" ""                           "" ""],
                  ["Export"                "menuitem"  "scmenu_export"              "" "gtk-print-preview"],
                  ["Export All"            "menuitem"  "scmenu_export_all"          "" "gtk-print-report"],
                  ["sep3"                  "separator" ""                           "" ""],
                  ["Exit Scicos"           "menuitem"  "scmenu_exit_scicos"         "" "gtk-close"],
                  ["sep4"                  "separator" ""                           "" ""],
                  ["Quit|||gtk-quit"       "menuitem"  "scmenu_quit"                "<Ctrl>Q" ""]);

  Diagram =  list(["_Diagram"                "menu"      "scmenu_diagram_menu"            "" ""],
                  ["Context"                 "menuitem"  "scmenu_context"                 "" "gtk-edit"],
                  ["sep0"                    "separator" ""                               "" ""],
                  ["Purge"                   "menuitem"  "scmenu_purge"                   "" "gtk-clear"],
                  ["Replot"                  "menuitem"  "scmenu_replot"                  "" "gtk-refresh"],
                  ["sep1"                    "separator" ""                               "" ""],
                  ["Rename"                  "menuitem"  "scmenu_rename"                  "" ""],
                  ["Set Diagram Info"        "menuitem"  "scmenu_set_diagram_info"        "" ""],
                  ["Set Code Gen Properties" "menuitem"  "scmenu_set_code_gen_properties" "" ""],
                  ["sep2"                    "separator" ""                               "" ""],
                  ["Region to Super Block"   "menuitem"  "scmenu_region_to_super_block"   "" ""],
                  ["sep3"                    "separator" ""                               "" ""],
                  ["Up To Parent"            "menuitem"  "scmenu_up"                      "" "gtk-go-up"],
                  ["Up To Main Diagram"      "menuitem"  "scmenu_up_to_main_diagram"      "" "gtk-goto-top"]);

  Palette =  list(["_Palette"          "menu"      "scmenu_palette_menu"      "" ""],
                  ["Pal Tree"          "menuitem"  "scmenu_pal_tree"          "" ""],
                  ["Palettes"          "menuitem"  "scmenu_palettes"          "" ""]);

  Palette.concat[list(...
		  ["sep0"              "separator" ""                         "" ""],
                  ["Pal editor"        "menuitem"  "scmenu_pal_editor"        "" ""],
                  ["sep1"              "separator" ""                         "" ""],
                  ["Region to Palette" "menuitem"  "scmenu_region_to_palette" "" ""],
                  ["sep2"              "separator" ""                         "" ""],
                  ["Load as Palette"   "menuitem"  "scmenu_load_as_palette"   "" ""],
                  ["Save as Palette"   "menuitem"  "scmenu_save_as_palette"   "" ""])];

  Edit =     list(["_Edit"                       "menu"      "scmenu_edit_menu"  ""        ""],
                  ["Undo|||gtk-undo"             "menuitem"  "scmenu_undo"       "<Ctrl>Z" ""],
                  ["sep0"                        "separator" ""                  ""        ""],
                  ["Cut|||gtk-cut"               "menuitem"  "scmenu_cut"        "<control>X" ""],
                  ["Copy|||gtk-copy"             "menuitem"  "scmenu_copy"       "<Ctrl>c" ""],
                  ["Paste|||gtk-paste"           "menuitem"  "scmenu_paste"      "<Ctrl>v" ""],
                  ["sep1"                        "separator" ""                  ""        ""],
                  ["Delete|||gtk-delete"         "menuitem"  "scmenu_delete"     "Delete"        ""],
                  ["sep2"                        "separator" ""                  ""        ""],
                  ["Select All|||gtk-select-all" "menuitem"  "scmenu_select_all" "<Ctrl>a" ""],
                  ["sep3"            "separator" ""                  "" ""],
                  list(["Block"               "menu"      "scmenu_block_menu"          ""           ""],
                       ["Duplicate"           "menuitem"  "scmenu_duplicate"           ""           ""],
                       ["bsep1"               "separator" ""                           ""           ""],
                       ["Flip"                "menuitem"  "scmenu_flip"                ""           ""],
                       ["Set Size"            "menuitem"  "scmenu_set_size"            ""           ""],
                       ["Resize"              "menuitem"  "scmenu_resize"              ""           ""],
                       ["Rotate Left"         "menuitem"  "scmenu_rotate_left"         ""           ""],
                       ["Rotate Right"        "menuitem"  "scmenu_rotate_right"        ""           ""],
                       ["bsep2"               "separator" ""                           ""           ""],
                       ["Block Documentation" "menuitem"  "scmenu_block_documentation" ""           ""],
                       ["Details"             "menuitem"  "scmenu_details"             ""           ""],
                       ["Get Info"            "menuitem"  "scmenu_get_info"            ""           ""],
                       ["Icon Editor"         "menuitem"  "scmenu_icon_edit"           ""           ""],
                       ["Icon"                "menuitem"  "scmenu_icon"                ""           ""],
                       ["Identification"      "menuitem"  "scmenu_identification"      ""           ""],
                       ["Label"               "menuitem"  "scmenu_label"               ""           ""]),
                  ["sep4"                        "separator" ""                     ""     ""],
                  ["Align"                       "menuitem"  "scmenu_align"         ""     ""],
                  ["sep5"                        "separator" ""                     ""     ""],
                  ["Add new block"               "menuitem"  "scmenu_add_new_block" ""     "gtk-add"]);

  View =     list(["_View"                     "menu"      "scmenu_view_menu"                 "" ""],
                  ["Zoom in|||gtk-zoom-in"     "menuitem"  "scmenu_zoom_in"                   "<Ctrl>plus" ""],
                  ["Zoom out|||gtk-zoom-out"   "menuitem"  "scmenu_zoom_out"                  "<Ctrl>minus" ""],
                  ["sep0"                      "separator" ""                                 "" ""],
                  ["Fit diagram to figure"     "menuitem"  "scmenu_fit_diagram_to_figure"     "" "gtk-zoom-fit"],
                  ["Default window parameters" "menuitem"  "scmenu_default_window_parameters" "" "gtk-zoom-100"],
                  ["sep1"                      "separator" ""                                 "" ""],
                  ["Available Parameters"      "menuitem"  "scmenu_available_parameters"      "" ""],
                  ["sep2"                      "separator" ""                                 "" ""],
                  ["Icon Font Option"          "menuitem"  "scmenu_icon_font_option"          "" "gtk-select-font"],
                  ["sep3"                      "separator" ""                                 "" ""],
                  ["Grid"                      "menuitem"  "scmenu_grid"                      "" ""]);

  Simulate = list(["_Simulate"           "menu"      "scmenu_simulate_menu"       "" ""],
                  ["Setup"               "menuitem"  "scmenu_setup"               "" "gtk-preferences"],
                  ["sep0"                "separator" ""                           "" ""],
                  ["Compile"             "menuitem"  "scmenu_compile"             "" "gtk-execute"],
                  ["Eval"                "menuitem"  "scmenu_eval"                "" ""],
                  ["sep1"                "separator" ""                           "" ""],
                  ["Modelica initialize" "menuitem"  "scmenu_modelica_initialize" "" ""],
                  ["sep2"                "separator" ""                           "" ""],
                  ["Analyze Diagram"     "menuitem"  "scmenu_analyze_diagram"     "" ""],
                  ["sep3"                "separator" ""                           "" ""],
                  ["Debug Level"         "menuitem"  "scmenu_debug_level"         "" ""],
                  ["sep4"                "separator" ""                           "" ""],
                  ["Run"                 "menuitem"  "scmenu_run"                 "" "gtk-media-play"]);

  Format =   list(["Fo_rmat"                    "menu"      "scmenu_format_menu"         "" ""],
                  ["Set default action"         "menuitem"  "scmenu_set_default_action"  "" ""],
                  ["sep0"                       "separator" ""                           "" ""],
                  ["Set grid"                   "menuitem"  "scmenu_set_grid"            "" ""],
                  ["sep1"                       "separator" ""                           "" ""],
                  ["Add Color"                  "menuitem"  "scmenu_add_color"           "" "gtk-color-picker"],
                  ["Default link colors"        "menuitem"  "scmenu_default_link_colors" "" "gtk-select-color"],
                  ["Color|||gtk-select-color"   "menuitem"  "scmenu_color"               "" ""],
                  ["Background color"           "menuitem"  "scmenu_background_color"    "" "gtk-select-color"],
                  ["sep2"                       "separator" ""                           "" ""],
                  ["Show Block Shadow"          "menuitem"  "scmenu_show_block_shadow"   "" ""],
                  ["sep3"                       "separator" ""                           "" ""],
                  ["ID fonts|||gtk-select-font" "menuitem"  "scmenu_id_fonts"            "" ""]);

  Tools =    list(["_Tools"                    "menu"      "scmenu_tools_menu"                "" ""],
                  ["Activate Nsp Window"       "menuitem"  "scmenu_activate_scicoslab_window" "" ""],
                  ["sep0"                      "separator" ""                                 "" ""],
                  ["Create Mask"               "menuitem"  "scmenu_create_mask"               "" ""],
                  ["Remove Mask"               "menuitem"  "scmenu_remove_mask"               "" ""],
                  ["Restore Mask"              "menuitem"  "scmenu_restore_mask"              "" ""],
                  ["Customize Mask"            "menuitem"  "scmenu_customize_mask"            "" ""],
                  ["Save Block GUI"            "menuitem"  "scmenu_save_block_gui"            "" ""],
                  ["sep1"                      "separator" ""                                 "" ""],
                  ["Create Atomic"             "menuitem"  "scmenu_create_atomic"             "" ""],
                  ["Remove Atomic"             "menuitem"  "scmenu_remove_atomic"             "" ""],
                  ["sep2"                      "separator" ""                                 "" ""],
                  ["Code Generation"           "menuitem"  "scmenu_code_generation"           "" ""],
                  ["sep3"                      "separator" ""                                 "" ""],
                  ["Browser"                   "menuitem"  "scmenu_browser"                   "" ""],
                  ["sep4"                      "separator" ""                                 "" ""],
                  ["Shortcuts"                 "menuitem"  "scmenu_shortcuts"                 "" ""],
                  ["sep5"                      "separator" ""                                 "" ""],
                  ["Calc"                      "menuitem"  "scmenu_calc"                      "" ""]);

                  //["Force Open" "menuitem"     "menuitem"  "scmenu_force_open"               ],

  Help =     list(["_Help"                    "menu"      "scmenu_help_menu"            "" ""],
                  ["Help|||gtk-help"          "menuitem"  "scmenu_help"                 "F1" ""],
                  ["sep0"                     "separator" ""                            "" ""],
                  ["Scicos Documentation"     "menuitem"  "scmenu_scicos_documentation" "" "gtk-dialog-info"],
                  ["sep1"                     "separator" ""                            "" ""],
                  ["Demos"                    "menuitem"  "scmenu_demos"                "" "gtk-open"],
                  ["sep2"                     "separator" ""                            "" ""],
                  ["About Scicos|||gtk-about" "menuitem"  "scmenu_about_scicos"         "" ""]);

  %scicos_menu = list(File,Diagram,Palette,Edit,View,Simulate,Format,Tools,Help);

  //Scicos Toolbar definitions===================================================
  //**
  //tspe4/scmenu_up/scmenu_up_to_main_diagram are removed from top level diagram
  //$scicos_stop internally handled by scicos uimanager

  %scicos_toolbar = list(["New|||gtk-new"             "toolitem"  "scmenu_new"                       "<Ctrl>N" ""],
                         ["Open|||gtk-open"           "toolitem"  "scmenu_open"                      "<Ctrl>O" ""],
                         ["Save|||gtk-save"           "toolitem"  "scmenu_save"                      "<Ctrl>S" ""],
                         ["tsep1"                     "separator" ""                                 "" ""],
                         ["Zoom in|||gtk-zoom-in"     "toolitem"  "scmenu_zoom_in"                   "<Ctrl>plus" ""],
                         ["Zoom out|||gtk-zoom-out"   "toolitem"  "scmenu_zoom_out"                  "<Ctrl>minus" ""],
                         ["tsep2"                     "separator" ""                                 "" ""],
                         ["Fit diagram to figure"     "toolitem"  "scmenu_fit_diagram_to_figure"     "" "gtk-zoom-fit"],
                         ["Default window parameters" "toolitem"  "scmenu_default_window_parameters" "" "gtk-zoom-100"],
                         ["tsep3"                     "separator" ""                                 "" ""],
                         ["Cut|||gtk-cut"             "toolitem"  "scmenu_cut"                       "<control>X" ""],
                         ["Copy|||gtk-copy"           "toolitem"  "scmenu_copy"                      "<Ctrl>c" ""],
                         ["Paste|||gtk-paste"         "toolitem"  "scmenu_paste"                     "<Ctrl>v" ""],
                         ["tsep4"                     "separator" ""                                 "" ""],
                         ["Up To Parent"              "toolitem"  "scmenu_up"                        "" "gtk-go-up"],
                         ["Up To Main Diagram"        "toolitem"  "scmenu_up_to_main_diagram"        "" "gtk-goto-top"],
                         ["tsep5"                     "separator" ""                                 "" ""],
                         ["Setup"                     "toolitem"  "scmenu_setup"                     "" "gtk-preferences"],
                         ["Compile"                   "toolitem"  "scmenu_compile"                   "" "gtk-execute"],
                         ["Run"                       "toolitem"  "scmenu_run"                       "" "gtk-media-play"],
                         ["Stop"                      "toolitem"  "$scicos_stop"                     "" "gtk-cancel"],
                         ["tsep6"                     "separator" ""                                 "" ""],
                         ["Quit|||gtk-quit"           "toolitem"  "scmenu_quit"                      "<Ctrl>Q" ""]);


  //Scicos palette ===========================================
  %scicos_pal=scicos_default_palettes();

  //Scicos Right Mouse Button Menu ===========================================
  //**
  %scicos_lhb_list = list();

  //** state_var = 1 : right click inside the CURRENT Scicos Window
  %scicos_lhb_list(1) = list('Cut|||gtk-cut',..
                             'Copy|||gtk-copy',..
                             'Delete|||gtk-delete',..
                             'Move',..
                             'Smart Move',..
                             'Duplicate',..
                             'Region to Super Block',..
                             'Region to Palette');

  //** state_var = 2 : right click in the void of the CURRENT Scicos
  //Window

  function L1=scicos_rmenu_pal_tree()
    // make a mpopup data list
    // for block insertion from right click menu
    // the action activated is placeindiagram.

    H=scicos_default_palettes();
    L=H.structure;
    L1=list('Pal Tree');

    function [L1]=foo_rec(L1,H)
      L=H.structure;
      for i=1:length(L)
        //single blk
        if type(H.contents(L(i)),'short')=='s' then
          blk=H.contents(L(i));
          name = strsubst(blk,'_','__');
          l=hash(name=name,rname=blk,cmenu='PlaceinDiagram');
        //palette of single blk
        elseif type(H.contents(L(i)),'short')=='l' then
          l=list(L(i));
          blocks=H.contents(L(i));
          for j=1:size(blocks,'*');
            name = strsubst(blocks(j),'_','__');
            l.add_last[hash(name=name,rname=blocks(j),cmenu='PlaceinDiagram')];
          end
        //palette
        elseif type(H.contents(L(i)),'short')=='h' then
          l=list(L(i));
          pal=H.contents(L(i))
          l=foo_rec(l,pal)
        end
        L1.add_last[l];
      end
    endfunction

    [L1]=foo_rec(L1,H)

  endfunction

  L=scicos_rmenu_pal_tree();

  %scicos_lhb_list(2) = list('Undo|||gtk-undo',..
                             'Paste',..
                             'Palettes',..
			     L,..
                             'Context',..
                             'Add new block',..
                             'Replot',..
                             'Save|||gtk-save',..
                             'Save As|||gtk-save-as',..
                             'Export',..
                             'Quit|||gtk-quit',..
                             'Background color',..
                             'Show Block Shadow',..
                             list('Zoom',..
                                  'Zoom in|||gtk-zoom-in',..
                                  'Zoom out|||gtk-zoom-out'),..
                             'Region to Super Block',..
                             'Region to Palette',..
                             'Code Generation',..
                             'Browser',..
                             'Details',..
                             'Help|||gtk-help');

  //** state_var = 3 : right click over a valid object inside a PALETTE or
  //**                 not a current Scicos window
  %scicos_lhb_list(3) = list('Copy|||gtk-copy',..
                             'Help');

  //** state_var = 4 : right click over a block that is not a super block
  %scicos_lhb_list(4) = list('Open/Set',..
                             'Cut|||gtk-cut',..
                             'Copy|||gtk-copy',..
                             'Delete|||gtk-delete',..
                             'Move',..
                             'Smart Move',..
                             'Duplicate',..
                             'Link',..
                             'Align',..
                             'Flip',..
                             list('Rotate',..
                                  'Rotate Left',..
                                  'Rotate Right'),..
                             list('Block Properties',..
                                  'Set Size',..
                                  'Resize',..
                                  'Icon',..
                                  'Icon Editor',..
                                  'Color|||gtk-select-color',..
                                  'Label',..
                                  'Get Info',..
                                  'Details',..
                                  'Identification',..
                                  'Block Documentation'),..
                             'Remove Atomic',..
                             'Region to Super Block',..
                             'Region to Palette',..
                             'Help|||gtk-help');

  //** state_var = 5 : right click over a link inside the CURRENT Scicos Window
  %scicos_lhb_list(5) = list('Link',..
                             'Delete|||gtk-delete',..
                             'Move',..
                             'Smart Move',..
                             list('Link Properties',..
                                  'Resize',..
                                  'Color|||gtk-select-color',..
                                  'Get Info',..
                                  'Details',..
                                  'Identification'));

  //** state_var = 6 : right click over a text inside the CURRENT Scicos Window
  %scicos_lhb_list(6) = list('Open/Set',..
                             'Cut|||gtk-cut',..
                             'Copy|||gtk-copy',..
                             'Delete|||gtk-delete',..
                             'Move',..
                             'Duplicate',..
                             list('Rotate',..
                                  'Rotate Left',..
                                  'Rotate Right'),..
                             list('Text Properties',..
                                  'Color|||gtk-select-color',..
                                  'Get Info',..
                                  'Details'));

  //** state_var = 7 : right click over a valid sblock inside the
  //  CURRENT Scicos Window
  %scicos_lhb_list(7) = list('Open/Set',..
                             list('Super Block Properties',..
                                  'Rename',..
                                  'Set Code Gen Properties'),..
                             'Cut|||gtk-cut',..
                             'Copy|||gtk-copy',..
                             'Delete|||gtk-delete',..
                             'Move',..
                             'Smart Move',..
                             'Duplicate',..
                             'Link',..
                             'Align',..
                             'Flip',..
                             list('Rotate',..
                                  'Rotate Left',..
                                  'Rotate Right'),..
                             list('Block Properties',..
                                  'Set Size',..
                                  'Resize',..
                                  'Icon',..
                                  'Icon Editor',..
                                  'Color|||gtk-select-color',..
                                  'Label',..
                                  'Get Info',..
                                  'Details',..
                                  'Identification',..
                                  'Block Documentation'),..
                             'Region to Super Block',..
                             'Region to Palette',..
                             list('Mask',..
                                  'Create Mask',..
                                  'Remove Mask',..
                                  'Restore Mask',..
                                  'Customize Mask',..
                                  'Save Block GUI'),..
                             'Create Atomic',..
                             'Code Generation');

  //Scicos Shortcuts definitions===========================================
  %scicos_short=['a','Align'
                 'd','Delete';
                 'c','Duplicate';
                 'm','CheckKeyMove';
                 'z','CheckKeySmartMove';
                 'u','Undo';
                 'f','Flip';
                 't','Rotate Left';
                 'T','Rotate Right';
                 'o','Open/Set';
                 's','Save';
                 'i','Get Info';
                 'r','Replot';
                 'l','Smart Link';
                 'q','Quit';
                 '-','Zoom out';
                 '+','Zoom in';
                 '=','Fit diagram to figure';
                 'g','Grid';
                 'h','Help']

  //Scicos Modelica librabry path definitions==============================

  modelica_libs=scicospath+'/macros/blocks/'+['ModElectrical','ModHydraulics','ModLinear','ModEni'];

  //add TMPDIR/Modelica for generic modelica blocks
  rpat=getenv('NSP_TMPDIR')+'/Modelica";
  status=execstr("file(""mkdir"",rpat)",errcatch=%t)

  //** Scicos "xinfo" messages ===========================================
  //**
  //** "%CmenuTypeOneVector" store the list of the commands/function to be called that require both 'Cmenu' AND '%pt'
  //** menus of type 1 (require %pt)
  %CmenuTypeOneVector =..
     ['Region to Super Block', "Press left mouse button, drag region and release (right button to cancel)";
      'scmenu_region_to_super_block', "Press left mouse button, drag region and release (right button to cancel)";
      'Region to Palette',     "Press left mouse button, drag region and release (right button to cancel)";
      'scmenu_region_to_palette',     "Press left mouse button, drag region and release (right button to cancel)";
      'Load as Palette',       '';
      'scmenu_load_as_palette',       '';
      'Smart Move',            "Click object to move, drag and click (left to fix, right to cancel)";
      'Move',                  "Click object to move, drag and click (left to fix, right to cancel)";
      'Duplicate'              "Click on the object to duplicate, drag, click (left to copy, right to cancel)";
      'Align',                 "Click on an a port, click on a port of object to be moved";
      'Link',                  "Drag, click left for final or intermediate points or right to cancel";
      'Smart Link',            "Drag, click left for final or intermediate points or right to cancel";
      'Delete',                "Delete: Click on the object to delete";
      'Flip',                  "Click on block to be flipped"      ;
      'scmenu_flip',           "Click on block to be flipped"      ;
      'Rotate Left',           "Click on block to be turned left"  ;
      'Rotate Right',          "Click on block to be turned right" ;
      'Open/Set',              "Click to open block or make a link";
      'CheckMove',             ''                                  ;
      'CheckKeyMove',          ''                                  ;
      'CheckSmartMove'         ''                                  ;
      'CheckKeySmartMove',     ''                                  ;
      'SelectLink',            ''                                  ;
      'CtrlSelect',            ''                                  ;
      'SelectRegion',          ''                                  ;
      'Popup',                 ''                                  ;
      'PlaceDropped',          ''                                  ;
      'PlaceinDiagram',        ''                                  ;
      'Label',                 "Click block to label";
      'Get Info',              "Click on object  to get information on it";
      'Resize',                "" ;
      'Resize Top',            "" ;
      'Block Documentation',   "Click on a block to set or get it''s documentation"]

  //** "%DmenuTypeOneVector" store the list of the commands/function to be called that don't require to
  //** disable menus in the editor. Should be carrefully updated
  %DmenuTypeOneVector =..
     ['CheckMove';
      'Move';
      'Delete';
      'Undo';
      'CheckSmartMove';
      'Smart Move';
      'SelectRegion';
      'scmenu_paste';
      'Fit diagram to figure';
      'scmenu_fit_diagram_to_figure';
      'Zoom in';
      'scmenu_zoom_in';
      'Zoom out';
      'scmenu_zoom_out']

  // Hash table for help strings ==============================
  %scicos_help=scicos_help();

  // Hash table for help topics ==============================
  // that's just an example to be used with cos_help('scicos')
  %scicos_topics('scicos')='http://www.scicos.org/HELP/eng/scicos/whatis_scicos.htm'
endfunction

//
function H1=scicos_default_palettes()
// returns a H table of scicos default palette

  H1 = hash(10);

  // describe the structure of the palette hierarchy.

  // a palette is described by an hash table and gives the order
  // of the displayed components in the 'structure' field.
  // The 'contents' field enclose the contents.

  // a component is describeb by :
  // * a string, that means that the component is a block,
  // * a list of single string, that means that the component is a palette only composed by blocks,
  // * or an hash table, that means that the component is a palette that can contains single blocks and palettes.

  H1.structure= list('Sources','Sinks','Branching','Non_linear',...
                     'Lookup_Tables','Events','Threshold','Others',...
                     'Linear', 'OldBlocks' , 'DemoBlocks','Modelica',...
                     'Matrix' , 'Integer',  'Iterators');

  // for each palette describe its contents

  H= hash(20);

  H.Sources = list('CONST_m','GENSQR_f','RAMP',
       'RAND_m','RFILE_f',
       'CLKINV_f', 'CURV_f',  'INIMPL_f', 'READAU_f',
       'SAWTOOTH_f', 'STEP_FUNCTION',
       'CLOCK_c', 'GENSIN_f', 'IN_f',   'READC_f',
       'TIME_f', 'Modulo_Count','Sigbuilder','Counter',
       'SampleCLK','TKSCALE','GTKRANGE','FROMWSB','Ground_g',
       'PULSE_SC','GEN_SQR','BUSIN_f','SENSOR_f');

  H.Sinks = list('AFFICH_m',   'CMSCOPE',
       'CSCOPXY',   'WRITEC_f',
       'CANIMXY',   'CSCOPE',
       'OUTIMPL_f',
       'CLKOUTV_f',  'CEVENTSCOPE',
       'OUT_f',      'WFILE_f',
       'CFSCOPE',   'WRITEAU_f',
       'CSCOPXY3D',   'CANIMXY3D',
       'CMATVIEW',      'CMAT3D',
       'TOWS_c','BUSOUT_f','ACTUATOR_f',
       'SLIDER_f', 'SLIDER_m','DMSCOPE');

  H.Branching = list('DEMUX',
       'MUX', 'NRMSOM_f',  'EXTRACTOR',
       'SELECT_m','ISELECT_m',
       'RELAY_f','IFTHEL_f',
       'ESELECT_f','M_SWITCH','SWITCH2_s',
       'SCALAR2VECTOR','SWITCH_f','EDGE_TRIGGER',
       'Extract_Activation','GOTO','FROM',
       'GotoTagVisibility','CLKGOTO','CLKFROM',
       'CLKGotoTagVisibility','GOTOMO','FROMMO',
       'GotoTagVisibilityMO','BUSCREATOR','BUSSELECTOR',
       'TRANSMIT','M_VSWITCH');

  H.Non_linear = list('ABS_VALUEi', 'TrigFun',
       'EXPBLK_m',  'INVBLK',
       'LOGBLK_f', 'LOOKUP_f', 'MAXMIN',
       'POWBLK_f', 'PROD_f',
       'PRODUCT',  'QUANT_f','EXPRESSION',
       'SATURATION', 'SATURATIONDYNAMIC', 'SIGNUM','CONSTRAINT_c');

  H.Lookup_Tables = list('LOOKUP_c','LOOKUP2D' , 'INTRPLBLK_f', 'INTRP2BLK_f');

  H.Events = list('ANDBLK','HALT_f','freq_div',
       'ANDLOG_f','EVTDLY','IFTHEL_f','ESELECT_f',
       'CLKSOMV_f','CLOCK_c','EVTGEN_f','EVTVARDLY',
       'M_freq','SampleCLK','VirtualCLK0','SyncTag');

  H.Threshold= list('NEGTOPOS_f',  'POSTONEG_f',  'ZCROSS_f');

  H.Others = list('fortran_block',
       'SUPER_f','scifunc_block_m','scifunc_block5',
       'TEXT_f','CBLOCK4','RATELIMITER',
       'BACKLASH','DEADBAND','EXPRESSION',
       'HYSTHERESIS','DEBUG_SCICOS',
       'LOGICAL_OP','RELATIONALOP','generic_block3',
       'PDE','ENDBLK','AUTOMAT','Loop_Breaker',
       'PAL_f','ASSERT');

  H.Linear = list('DLR','TCLSS','DOLLAR_m',
       'CLINDUMMY_f','DLSS','REGISTER','TIME_DELAY',
       'CLR','GAINBLK','SAMPHOLD_m','VARIABLE_DELAY',
       'CLSS','SUMMATION','INTEGRAL_m','SUM_f',
       'DERIV','PID2','DIFF_c','DISCRETE_DERIVATIVE');

  H.OldBlocks= list('CLOCK_f','ABSBLK_f',
       'MAX_f', 'MIN_f','SAT_f', 'MEMORY_f',
       'CLKSOM_f','TRASH_f','GENERAL_f','DIFF_f',
       'BIGSOM_f','INTEGRAL_f','GAINBLK_f',
       'DELAYV_f','DELAY_f', 'DEMUX_f','MUX_f',
       'MFCLCK_f','MCLOCK_f','COSBLK_f',   'DLRADAPT_f',
       'SINBLK_f', 'TANBLK_f','generic_block','RAND_f',
       'DOLLAR_f','CBLOCK','c_block','PID');

  H.DemoBlocks = list('BOUNCE','BOUNCEXY','BPLATFORM', ...
       'PENDULUM_ANIM');

  //Modelica palette
  H_Mod=hash(10)

  H_Mod.structure=list('MBLOCK', 'Modelica Electrical', 'MPBLOCK', 'Modelica Hydraulics', 'Modelica Linear', 'Modelica Test');

  H2=hash(10);

  H2.MBLOCK='MBLOCK';

  H2.MPBLOCK='MPBLOCK';

  H2('Modelica Electrical')= list('Capacitor','Ground','VVsourceAC',
       'ConstantVoltage','Inductor','PotentialSensor',
       'VariableResistor','CurrentSensor','Resistor',
       'VoltageSensor','Diode','VsourceAC',
       'NPN','PNP','SineVoltage','Switch',
       'OpAmp','PMOS','NMOS','CCS','CVS',
       'IdealTransformer','Gyrator');

  H2('Modelica Hydraulics') = list('Bache','VanneReglante','PerteDP',
       'PuitsP','SourceP','Flowmeter');

  H2('Modelica Linear') = list('Actuator','Constant','Feedback',
       'Gain','Limiter','PI','Sensor','PT1',
       'SecondOrder', 'TanTF', 'AtanTF', 'FirstOrder',
       'SineTF', 'Sine');

  H2('Modelica Test') = list('Atmosphere', 'Pipe',           'Tank',
  'FluxSensor', 'PressureSensor', 'ValveContinuous',
  'HGround',    'Tank2',          'ValveDiscrete',
  'Medias',     'Tank3',          'VolumeFlow', 'PressionSource' );


  H_Mod.contents=H2;
  H.Modelica = H_Mod;

  H.Matrix = list('MATMUL','MATTRAN','MATSING','MATRESH','MATDIAG',
       'MATEIG','MATMAGPHI','EXTRACT','MATEXPM','MATDET',
       'MATPINV','EXTTRI','RICC','ROOTCOEF','MATCATH',
       'MATLU','MATDIV','MATZCONJ','MATZREIM','SUBMAT',
       'MATBKSL','MATINV','MATCATV','MATSUM', ...
       'CUMSUM',
       'SQRT','Assignment');

  H.Integer = list('BITCLEAR','BITSET','COMBINATORIALLOGIC','CONVERT','EXTRACTBITS','INTMUL',
       'SHIFT','LOGIC','DLATCH','DFLIPFLOP','JKFLIPFLOP',
       'SRFLIPFLOP');

  H.Iterators = list('ForIterator','WhileIterator');

  H1.contents = H;

endfunction
