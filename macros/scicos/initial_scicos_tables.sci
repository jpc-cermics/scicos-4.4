function [%scicos_menu, %scicos_short, %scicos_help, ...
          %scicos_display_mode, modelica_libs, ...
          %scicos_lhb_list, %CmenuTypeOneVector, %DmenuTypeOneVector, %scicos_gif, ...
          %scicos_contrib,%scicos_libs,%scicos_cflags] = initial_scicos_tables()

  // build a set of scicos global data 
  // 
  
  scicospath=get_scicospath()
  
  %scicos_display_mode=0  // =1 if pixmap to be used for display
  %scicos_gif=scicospath+"/macros/scicos/scicos-images/";
  %scicos_contrib=[];
  %scicos_libs=m2s([]);// string matrix 
  %scicos_cflags=[];

  //Scicos Menu definitions===================================================
  //**
  File =     list(["File"                "menu"      "scmenu_file_menu"          ],
                  ["New"                 "menuitem"  "scmenu_new"                ],
                  ["sep0"                "separator" ""                          ],
                  ["Open"                "menuitem"  "scmenu_open"               ],
                  ["Scicoslab Import"    "menuitem"  "scmenu_scicoslab_import"   ],
                  ["sep1"                "separator" ""                          ],
                  ["Save"                "menuitem"  "scmenu_save"               ],
                  ["Save As"             "menuitem"  "scmenu_save_as"            ],
                  ["Save as Interf Func" "menuitem"  "scmenu_save_as_interf_func"],
                  ["sep2"                "separator" ""                          ],
                  ["Export"              "menuitem"  "scmenu_export"             ],
                  ["Export All"          "menuitem"  "scmenu_export_all"         ],
                  ["sep3"                "separator" ""                          ],
                  ["Exit Scicos"         "menuitem"  "scmenu_exit_scicos"        ],
                  ["sep4"                "separator" ""                          ],
                  ["Quit"                "menuitem"  "scmenu_quit"               ]);

  Diagram =  list(["Diagram"                 "menu"      "scmenu_diagram_menu"           ],
                  ["Context"                 "menuitem"  "scmenu_context"                ],
                  ["sep0"                    "separator" ""                              ],
                  ["Purge"                   "menuitem"  "scmenu_purge"                  ],
                  ["Replot"                  "menuitem"  "scmenu_replot"                 ],
                  ["sep1"                    "separator" ""                              ],
                  ["Rename"                  "menuitem"  "scmenu_rename"                 ],
                  ["Set Diagram Info"        "menuitem"  "scmenu_set_diagram_info"       ],
                  ["Set Code Gen Properties" "menuitem"  "scmenu_set_code_gen_properties"],
                  ["sep2"                    "separator" ""                              ],
                  ["Region to Super Block"   "menuitem"  "scmenu_region_to_super_block"  ],
                  ["sep3"                    "separator" ""                              ],
                  ["Up To Main Diagram"      "menuitem"  "scmenu_up_to_main_diagram"     ]);

  Palette =  list(["Palette"           "menu"      "scmenu_palette_menu"     ],
                  ["Pal Tree"          "menuitem"  "scmenu_pal_tree"         ],
                  ["Palettes"          "menuitem"  "scmenu_palettes"         ],
                  ["sep0"              "separator" ""                        ],
                  ["Pal editor"        "menuitem"  "scmenu_pal_editor"       ],
                  ["sep1"              "separator" ""                        ],
                  ["Region to Palette" "menuitem"  "scmenu_region_to_palette"],
                  ["sep2"              "separator" ""                        ],
                  ["Load as Palette"   "menuitem"  "scmenu_load_as_palette"  ],
                  ["Save as Palette"   "menuitem"  "scmenu_save_as_palette"  ]);

  Edit =     list(["Edit"          "menu"      "scmenu_edit_menu" ],
                  ["Undo"          "menuitem"  "scmenu_undo"      ],
                  ["sep0"          "separator" ""                 ],
                  ["Cut"           "menuitem"  "scmenu_cut"       ],
                  ["Copy"          "menuitem"  "scmenu_copy"      ],
                  ["Paste"         "menuitem"  "scmenu_paste"     ],
                  ["sep1"          "separator" ""                 ],
                  ["Delete"        "menuitem"  "scmenu_delete"    ],
                  ["sep2"          "separator" ""                 ],
                  ["Select All"    "menuitem"  "scmenu_select_all"],
                  ["sep3"          "separator" ""                 ],
                  list(["Block Menu"          "menu"      "scmenu_block_menu"         ],
                       ["Copy"                "menuitem"  "scmenu_copy"               ],
                       ["Cut"                 "menuitem"  "scmenu_cut"                ],
                       ["Delete"              "menuitem"  "scmenu_delete"             ],
                       ["Duplicate"           "menuitem"  "scmenu_duplicate"          ],
                       ["bsep1"               "separator" ""                          ],
                       ["Color"               "menuitem"  "scmenu_color"              ],
                       ["Flip"                "menuitem"  "scmenu_flip"               ],
                       ["Resize"              "menuitem"  "scmenu_resize"             ],
                       ["Rotate Left"         "menuitem"  "scmenu_rotate_left"        ],
                       ["Rotate Right"        "menuitem"  "scmenu_rotate_right"       ],
                       ["bsep2"               "separator" ""                          ],
                       ["Block Documentation" "menuitem"  "scmenu_block_documentation"],
                       ["Details"             "menuitem"  "scmenu_details"            ],
                       ["Get Info"            "menuitem"  "scmenu_get_info"           ],
                       ["Icon Editor"         "menuitem"  "scmenu_icon_edit"          ],
                       ["Icon"                "menuitem"  "scmenu_icon"               ],
                       ["Identification"      "menuitem"  "scmenu_identification"     ],
                       ["Label"               "menuitem"  "scmenu_label"              ]),
                  ["sep4"          "separator" ""                    ],
                  ["Align"         "menuitem"  "scmenu_align"        ],
                  ["sep5"          "separator" ""                    ],
                  ["Add new block" "menuitem"  "scmenu_add_new_block"]);

  View =     list(["View"                      "menu"      "scmenu_view_menu"                ],
                  ["Zoom in"                   "menuitem"  "scmenu_zoom_in"                  ],
                  ["Zoom out"                  "menuitem"  "scmenu_zoom_out"                 ],
                  ["Fit diagram to figure"     "menuitem"  "scmenu_fit_diagram_to_figure"    ],
                  ["sep0"                      "separator" ""                                ],
                  ["Default window parameters" "menuitem"  "scmenu_default_window_parameters"],
                  ["sep1"                      "separator" ""                                ],
                  ["Available Parameters"      "menuitem"  "scmenu_available_parameters"     ],
                  ["sep2"                      "separator" ""                                ],
                  ["Icon Font Option"          "menuitem"  "scmenu_icon_font_option"         ],
                  ["sep3"                      "separator" ""                                ],
                  ["Grid"                      "menuitem"  "scmenu_grid"                     ]);

  Simulate = list(["Simulate"            "menu"      "scmenu_simulate_menu"      ],
                  ["Setup"               "menuitem"  "scmenu_setup"              ],
                  ["sep0"                "separator" ""                          ],
                  ["Compile"             "menuitem"  "scmenu_compile"            ],
                  ["Eval"                "menuitem"  "scmenu_eval"               ],
                  ["sep1"                "separator" ""                          ],
                  ["Modelica initialize" "menuitem"  "scmenu_modelica_initialize"],
                  ["sep2"                "separator" ""                          ],
                  ["Analyze Diagram"     "menuitem"  "scmenu_analyze_diagram"    ],
                  ["sep3"                "separator" ""                          ],
                  ["Debug Level"         "menuitem"  "scmenu_debug_level"        ],
                  ["sep4"                "separator" ""                          ],
                  ["Run"                 "menuitem"  "scmenu_run"                ]);

  Format =   list(["Format"              "menu"      "scmenu_format_menu"        ],
                  ["Set default action"  "menuitem"  "scmenu_set_default_action" ],
                  ["sep0"                "separator" ""                          ],
                  ["Set grid"            "menuitem"  "scmenu_set_grid"           ],
                  ["sep1"                "separator" ""                          ],
                  ["Add Color"           "menuitem"  "scmenu_add_color"          ],
                  ["Default link colors" "menuitem"  "scmenu_default_link_colors"],
                  ["Color"               "menuitem"  "scmenu_color"              ],
                  ["Background color"    "menuitem"  "scmenu_background_color"   ],
                  ["sep2"                "separator" ""                          ],
                  ["Show Block Shadow"   "menuitem"  "scmenu_show_block_shadow"  ],
                  ["sep3"                "separator" ""                          ],
                  ["ID fonts"            "menuitem"  "scmenu_id_fonts"           ]);

  Tools =    list(["Tools"                     "menu"      "scmenu_tools_menu"               ],
                  ["Activate ScicosLab Window" "menuitem"  "scmenu_activate_scicoslab_window"],
                  ["sep0"                      "separator" ""                                ],
                  ["Create Mask"               "menuitem"  "scmenu_create_mask"              ],
                  ["Remove Mask"               "menuitem"  "scmenu_remove_mask"              ],
                  ["Restore Mask"              "menuitem"  "scmenu_restore_mask"             ],
                  ["Customize Mask"            "menuitem"  "scmenu_customize_mask"           ],
                  ["Save Block GUI"            "menuitem"  "scmenu_save_block_gui"           ],
                  ["sep1"                      "separator" ""                                ],
                  ["Create Atomic"             "menuitem"  "scmenu_create_atomic"            ],
                  ["Remove Atomic"             "menuitem"  "scmenu_remove_atomic"            ],
                  ["sep2"                      "separator" ""                                ],
                  ["Code Generation"           "menuitem"  "scmenu_code_generation"          ],
                  ["sep3"                      "separator" ""                                ],
                  ["Browser"                   "menuitem"  "scmenu_browser"                  ],
                  ["sep4"                      "separator" ""                                ],
                  ["Shortcuts"                 "menuitem"  "scmenu_shortcuts"                ],
                  ["sep5"                      "separator" ""                                ],
                  ["Calc"                      "menuitem"  "scmenu_calc"                     ]);

                  //["Force Open" "menuitem"     "menuitem"  "scmenu_force_open"               ],

  Help =     list(["Help"                 "menu"      "scmenu_help_menu"           ],
                  ["Help"                 "menuitem"  "scmenu_help"                ],
                  ["sep0"                 "separator" ""                           ],
                  ["Scicos Documentation" "menuitem"  "scmenu_scicos_documentation"],
                  ["sep1"                 "separator" ""                           ],
                  ["Demos"                "menuitem"  "scmenu_demos"               ],
                  ["sep2"                 "separator" ""                           ],
                  ["About Scicos"         "menuitem"  "scmenu_about_scicos"        ]);

  %scicos_menu = list(File,Diagram,Palette,Edit,View,Simulate,Format,Tools,Help);

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
  //
    H=scicos_default_palettes();
    L=H.structure;
    L1=list('Pal Tree');
    for i=1:length(L)
      if type(L(i),'short')=='s' then 
	l=list(L(i));
	blocks=H.contents(L(i));
	for j=1:size(blocks,'*');
	  name = strsubst(blocks(j),'_','__');
	  l.add_last[hash(name=name,rname=blocks(j),cmenu='PlaceinDiagram')];
	end
	L1.add_last[l];
      end
    end
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
                             'Pal Tree',..
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
  
  modelica_libs=scicospath+'/macros/blocks/'+['ModElectrical','ModHydraulics','ModLinear'];
  if exists('coselica_path') then
    modelica_libs=[modelica_libs,file('join',[coselica_path,'macros'])];
  end

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
      'scmenu_code_generation',"Click on a Super Block (without activation output) to obtain a coded block!" ;
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
endfunction

