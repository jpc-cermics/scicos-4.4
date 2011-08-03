function [scicos_pal, %scicos_menu, %scicos_short, %scicos_help, ...
          %scicos_display_mode, modelica_libs,scicos_pal_libs, ...
          %scicos_lhb_list, %CmenuTypeOneVector,%scicos_gif, ...
          %scicos_contrib,%scicos_libs,%scicos_cflags, ...
          %scicos_pal_list,scs_m_palettes] = initial_scicos_tables()

  // build a set of scicos global data 
  // 
  
  scicospath=get_scicospath()
  
  %scicos_display_mode=0  // =1 if pixmap to be used for display
  %scicos_gif=scicospath+"/macros/scicos/scicos-images/";
  %scicos_contrib=[];
  %scicos_libs=m2s([]);// string matrix 
  %scicos_cflags=[];
  
  // Define scicos palettes of blocks
  // --------------------------------
  pal_names=scicos_get_palette_content('all');

  scicos_pal=[pal_names, scicos_path + '/macros/blocks/palettes/'+pal_names+'.cos']
  //Scicos palettes loading 
  scicos_pal_libs = ['Branching','Events','Misc','Sinks','Threshold','Linear', ...
	             'MatrixOp','NonLinear','Sources','ModElectrical','ModHydraulics',...
                     'ModLinear','PDE','IntegerOp','Iterators'];
  
  //Scicos Menu definitions
  //------------------------
  File     = ['File',..
              'New',..
              'Open',..
	      'Scicoslab Import',..
              'Save',..
              'Save As',..
              'Save as Interf Func',..
              'Export',..
              'Export All',..
              'Exit Scicos',..
              'Quit' ];

  Diagram  = ['Diagram',..
              'Context',..
              'Replot',..
              'Rename',..
              'Purge',..
              'Set Diagram Info',..
              'Set Code Gen Properties',..
              'Region to Super Block',..
              'Up To Main Diagram',..
	      'Up'];
  
  Palette  = ['Palette',..
              'Pal Tree',..
              'Palettes',..
              'Pal editor',..
              'Region to Palette',..
              'Load as Palette',..
              'Save as Palette'];

  Edit     = ['Edit',..
              'Undo',..
              'Cut|||gtk-cut',..
              'Copy|<Ctrl>c||gtk-copy',..
              'Paste|<Ctrl>v||gtk-paste',..
              'Duplicate',..
              'Delete|Delete',..
              'Move',..
              'Smart Move',..
              'Align',..
              'Flip',..
              'Rotate Left',..
              'Rotate Right',..
              'Add new block',..
              'Block Documentation'..
              'Label'];

  View     = ['View',..
              'Zoom in',..
              'Zoom out',..
              'Fit diagram to figure',..
              'Default window parameters',..
              'Available Parameters',..
              'Icon Font Option',..
              'Grid'];

  Simulate = ['Simulate',..
              'Setup',..
              'Compile',..
              'Modelica initialize',..
              'Eval',..
              'Analyze Diagram',..
              'Debug Level',..
              'Run'];

  Format   = ['Format',..
              'Set default action',..
              'Set grid',..
              'Add color',..
              'Default link colors',..
              'Color',..
              'Background color',..
              'Show Block Shadow',..
              'Resize',..
              'Identification',..
              'ID fonts',..
              'Icon',..
              'Icon Editor'];

  Tools    = ['Tools',..
              'Activate ScicosLab Window',..
              'Create Mask',..
              'Remove Mask',..
              'Customize Mask',..
              'Save Block GUI',..
              'Create Atomic',..
              'Remove Atomic',..
              'Get Info',..
              'Details',..
              'Browser',..
              'Code Generation',..
              'Shortcuts',..
              'Calc'];

  Help     = ['Help',..
              'Help',..
              'Scicos Documentation',..
              'Demos',..
              'About Scicos'];

  %scicos_menu = list(File,Diagram,Palette,Edit,View,Simulate,Format,Tools,Help);

  //Scicos Right Mouse Button Menu 
  
  %scicos_lhb_list = list();

  //** state_var = 1 : right click inside the CURRENT Scicos Window
  %scicos_lhb_list(1) = list('Cut',..
                             'Copy|||gtk-copy',..
                             'Delete|||gtk-delete',..
                             'Move',..
                             'Smart Move',..
                             'Duplicate',..
                             'Region to Super Block',..
                             'Region to Palette');

  //** state_var = 2 : right click in the void of the CURRENT Scicos Window
  [L, scs_m_palettes] = do_pal_tree(scicos_pal);
  L.add_first['Pal Tree'];
  %scicos_pal_list=L;
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
                             'Cut',..
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
                             'Cut',..
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

  //** state_var = 7 : right click over a valid sblock inside the CURRENT Scicos Window
  %scicos_lhb_list(7) = list('Open/Set',..
                             list('Super Block Properties',..
                                  'Rename',..
                                  'Set Code Gen Properties'),..
                             'Cut',..
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
                                  'Customize Mask',..
                                  'Save Block GUI'),..
                             'Create Atomic',..
                             'Code Generation');

  //Scicos Shortcuts definitions===========================================
  %scicos_short=['a','Align'
                 'd','Delete';
                 'c','Duplicate';
                 'm','Move';
                 'z','Smart Move';
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

  //add TMPDIR/Modelica for generic modelica blocks
  rpat=getenv('NSP_TMPDIR')+'/Modelica";
  status=execstr("file(""mkdir"",rpat)",errcatch=%t)

  //** Scicos "xinfo" messages ===========================================
  //**
  //** "%CmenuTypeOneVector" store the list of the commands/function to be called that require both 'Cmenu' AND '%pt'
  //** menus of type 1 (require %pt)
  %CmenuTypeOneVector =..
     ['Region to Super Block', "Press lef mouse button, drag region and release (right button to cancel)";
      'Region to Palette',     "Press lef mouse button, drag region and release (right button to cancel)";
      'Smart Move',            "Click object to move, drag and click (left to fix, right to cancel)";
      'Move',                  "Click object to move, drag and click (left to fix, right to cancel)";
      'Duplicate'              "Click on the object to duplicate, drag, click (left to copy, right to cancel)";
      'Align',                 "Click on an a port, click on a port of object to be moved";
      'Link',                  "Drag, click left for final or intermediate points or right to cancel";
      'Smart Link',            "Drag, click left for final or intermediate points or right to cancel";
      'Delete',                "Delete: Click on the object to delete";
      'Flip',                  "Click on block to be flipped"      ;
      'Rotate Left',           "Click on block to be turned left"  ;
      'Rotate Right',          "Click on block to be turned right" ;
      'Open/Set',              "Click to open block or make a link";
      'MoveLink',              ''                                  ; //** hidden commands
      'SMove',                 ''                                  ;
      'SelectLink',            ''                                  ;
      'CtrlSelect',            ''                                  ;
      'SelectRegion',          ''                                  ;
      'Popup',                 ''                                  ;
      'PlaceDropped',          ''                                  ;
      'PlaceinDiagram',        ''                                  ;
      'Label',                 "Click block to label";
      'Get Info',              "Click on object  to get information on it";
      'Code Generation',       "Click on a Super Block (without activation output) to obtain a coded block!" ;
      //'Icon',                  "Click on block to edit its icon";
      //'Color',                 "Click on object to choose its color";
      //'Identification',        "Click on an object to set or get identification";
      //'Resize',                "Click block to resize";
      'Block Documentation',   "Click on a block to set or get it''s documentation"]

  // Hash table for help strings ==============================
  %scicos_help=scicos_help();
endfunction
