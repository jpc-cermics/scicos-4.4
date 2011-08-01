// 
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
// (Copyright (C) 20011-2011 Jaen-Philippe Chancelier)

function scicos_set_uimanager(is_top)
// Get the vbox which contains the default menubar 
// and replace the menubar by a scicos menubar/toolbar 
// using the gtkuimanager mechanism.
//
  
  function txt=scicos_toolbar(is_top,action_group,merge)
  // text for the toolbar 
    txt =[ "  <toolbar name=""toolbar"">"
	   "    <toolitem name=""Zoom in"" action=""Zoom in"" />"
	   "    <toolitem name=""Zoom out"" action=""Zoom out"" />"
	   "    <toolitem name=""Zoom fit"" action=""Fit diagram to figure"" />"
	   "    <toolitem name=""Zoom 100"" action=""Zoom 100"" />"
	   "    <separator name=""tsep1"" />"
	   "    <toolitem name=""Cut"" action=""Cut"" />"
	   "    <toolitem name=""Copy"" action=""Copy"" />"
	   "    <toolitem name=""Paste"" action=""Paste"" />"
	   "    <separator name=""tsep3"" />"];
    
    if is_top then 
      txt=[txt;
	   "    <toolitem name=""prefs"" action=""Setup"" />"
	   "    <toolitem name=""compile"" action=""Compile"" />"
	   "    <toolitem name=""run"" action=""Run"" />"
	   "    <toolitem name=""stop"" action=""$scicos_stop"" />"
	   "    <separator name=""tsep4""/>"
	   "    <toolitem name=""Quit"" action=""Quit"" />"
	   "  </toolbar>"];
    else
      txt=[txt;
	   "    <toolitem name=""up"" action=""Up To Main Diagram"" />"
	   "    <separator name=""tsep4""/>"
	   "    <toolitem name=""Quit"" action=""Quit"" />"
	   "  </toolbar>"];
    end
    // just return a string 
    txt  = catenate(txt,sep='\n');
  endfunction

  function txt=scicos_menubar(action_group,merge)
  // Scicos Menu definitions
  // 
  // 
    txt= [ "  <menubar>";
	   "    <menu name=""File"" action=""FileMenu"">";
	   "      <menuitem name=""New"" action=""New"" />";
	   "      <menuitem name=""Open"" action=""Open"" />";
	   "      <menuitem name=""Scicoslab Import"" action=""Scicoslab Import"" />";
	   "      <menuitem name=""Save"" action=""Save"" />";
	   "      <menuitem name=""Save As"" action=""Save As"" />";
	   "      <menuitem name=""Save as Interf Func"" action=""Save as Interf Func"" />";
	   "      <menuitem name=""Export"" action=""Export"" />";
	   "      <menuitem name=""Export All"" action=""Export All"" />";
	   "      <menuitem name=""Exit Scicos"" action=""Exit Scicos"" />";
	   "      <menuitem name=""Quit"" action=""Quit"" />";
	   "    </menu>";
	   "    <menu name=""Diagram"" action=""DiagramMenu"">";
	   "      <menuitem name=""Context"" action=""Context"" />";
	   "      <menuitem name=""Replot"" action=""Replot"" />";
	   "      <menuitem name=""Rename"" action=""Rename"" />";
	   "      <menuitem name=""Purge"" action=""Purge"" />";
	   "      <menuitem name=""Set Diagram Info"" action=""Set Diagram Info"" />";
	   "      <menuitem name=""Set Code Gen Properties"" action=""Set Code Gen Properties"" />";
	   "      <menuitem name=""Region to Super Block"" action=""Region to Super Block"" />";
	   "      <menuitem name=""Up To Main Diagram"" action=""Up To Main Diagram"" />";
	   "    </menu>";
	   "    <menu name=""Palette"" action=""PaletteMenu"">";
	   "      <menuitem name=""Pal Tree"" action=""Pal Tree"" />";
	   "      <menuitem name=""Palettes"" action=""Palettes"" />";
	   "      <menuitem name=""Pal editor"" action=""Pal editor"" />";
	   "      <menuitem name=""Region to Palette"" action=""Region to Palette"" />";
	   "      <menuitem name=""Load as Palette"" action=""Load as Palette"" />";
	   "      <menuitem name=""Save as Palette"" action=""Save as Palette"" />";
	   "    </menu>";
	   "    <menu name=""Edit"" action=""EditMenu"">";
	   "      <menuitem name=""Undo"" action=""Undo"" />";
	   "      <menuitem name=""Cut"" action=""Cut"" />";
	   "      <menuitem name=""Copy"" action=""Copy"" />";
	   "      <menuitem name=""Paste"" action=""Paste"" />";
	   "      <menuitem name=""Duplicate"" action=""Duplicate"" />";
	   "      <menuitem name=""Delete"" action=""Delete"" />";
	   "      <menuitem name=""Move"" action=""Move"" />";
	   "      <menuitem name=""Smart Move"" action=""Smart Move"" />";
	   "      <menuitem name=""Align"" action=""Align"" />";
	   "      <menuitem name=""Flip"" action=""Flip"" />";
	   "      <menuitem name=""Add new block"" action=""Add new block"" />";
	   "      <menu name=""Block Menu"" action=""Block Menu"">";
	   "        <menuitem name=""Resize"" action=""Resize"" />";
	   "        <menuitem name=""Rotate Left"" action=""Rotate Left"" />";
	   "        <menuitem name=""Rotate Right"" action=""Rotate Right"" />";
	   "        <menuitem name=""Icon"" action=""Icon"" />";
	   "        <menuitem name=""Icon Editor"" action=""Icon Editor"" />";
	   "        <menuitem name=""Color"" action=""Color"" />";				    
	   "        <menuitem name=""Label"" action=""Label"" />";
	   "        <menuitem name=""Get Info"" action=""Get Info"" />";
	   "        <menuitem name=""Details"" action=""Details"" />";
	   "        <menuitem name=""Identification"" action=""Identification"" />";
	   "        <menuitem name=""Block Documentation"" action=""Block Documentation"" />";
	   "      </menu>"
	   "    </menu>";
	   "    <menu name=""View"" action=""ViewMenu"">";
	   "      <menuitem name=""Zoom in"" action=""Zoom in"" />";
	   "      <menuitem name=""Zoom out"" action=""Zoom out"" />";
	   "      <menuitem name=""Zoom 100"" action=""Zoom 100"" />";
	   "      <menuitem name=""Fit diagram to figure"" action=""Fit diagram to figure"" />";
	   "      <menuitem name=""Default window parameters"" action=""Default window parameters"" />";
	   "      <menuitem name=""Available Parameters"" action=""Available Parameters"" />";
	   "      <menuitem name=""Icon Font Option"" action=""Icon Font Option"" />";
	   "      <menuitem name=""Grid"" action=""Grid"" />";
	   "    </menu>";
	   "    <menu name=""Simulate"" action=""SimulateMenu"">";
	   "      <menuitem name=""Setup"" action=""Setup"" />";
	   "      <menuitem name=""Compile"" action=""Compile"" />";
	   "      <menuitem name=""Modelica initialize"" action=""Modelica initialize"" />";
	   "      <menuitem name=""Eval"" action=""Eval"" />";
	   "      <menuitem name=""Analyze Diagram"" action=""Analyze Diagram"" />";
	   "      <menuitem name=""Debug Level"" action=""Debug Level"" />";
	   "      <menuitem name=""Run"" action=""Run"" />";
	   "    </menu>";
	   "    <menu name=""Format"" action=""FormatMenu"">";
	   "      <menuitem name=""Set default action"" action=""Set default action"" />";
	   "      <menuitem name=""Set grid"" action=""Set grid"" />";
	   "      <menuitem name=""Add color"" action=""Add color"" />";
	   "      <menuitem name=""Default link colors"" action=""Default link colors"" />";
	   "      <menuitem name=""Color"" action=""Color"" />";
	   "      <menuitem name=""Background color"" action=""Background color"" />";
	   "      <menuitem name=""Show Block Shadow"" action=""Show Block Shadow"" />";
	   "      <menuitem name=""ID fonts"" action=""ID fonts"" />";
	   "    </menu>";
	   "    <menu name=""Tools"" action=""ToolsMenu"">";
	   "      <menuitem name=""Activate ScicosLab Window"" action=""Activate ScicosLab Window"" />";
	   "    <separator name=""sep0"" />";
	   "      <menuitem name=""Create Mask"" action=""Create Mask"" />";
	   "      <menuitem name=""Remove Mask"" action=""Remove Mask"" />";
	   "      <menuitem name=""Customize Mask"" action=""Customize Mask"" />";
	   "      <menuitem name=""Save Block GUI"" action=""Save Block GUI"" />";
	   "      <separator name=""sep1"" />";
	   "      <menuitem name=""Create Atomic"" action=""Create Atomic"" />";
	   "      <menuitem name=""Remove Atomic"" action=""Remove Atomic"" />";
	   "      <menuitem name=""Browser"" action=""Browser"" />";
	   "      <menuitem name=""Code Generation"" action=""Code Generation"" />";
	   "      <menuitem name=""Shortcuts"" action=""Shortcuts"" />";
	   "      <menuitem name=""Calc"" action=""Calc"" />";
	   "    </menu>";
	   "    <menu name=""Help"" action=""HelpMenu"">";
	   "      <menuitem name=""Help"" action=""Help"" />";
	   "      <menuitem name=""Scicos Documentation"" action=""Scicos Documentation"" />";
	   "      <menuitem name=""Demos"" action=""Demos"" />";
	   "      <menuitem name=""About Scicos"" action=""About Scicos"" />";
	   "    </menu>";
	   "  </menubar>" ];
    // 
    txt  = catenate(txt,sep='\n');    
        
    // list of actions 
       
    L=list();
    L(1) = ['FileMenu','File',"","";
	    'New','New',"","";
	    'Open','Open',"","";
	    'Scicoslab Import','Scicoslab Import',"","";
	    'Save','Save',"","";
	    'Save As','Save As',"","";
	    'Save as Interf Func','Save as Interf Func',"","";
	    'Export','Export',"","";
	    'Export All','Export All',"","";
	    'Exit Scicos','Exit Scicos',"","";
	    'Quit','Quit',"","gtk-quit"];

    L(2) = ['DiagramMenu','Diagram',"","";
	    'Context','Context',"","";
	    'Replot','Replot',"","";
	    'Rename','Rename',"","";
	    'Purge','Purge',"","";
	    'Set Diagram Info','Set Diagram Info',"","";
	    'Set Code Gen Properties','Set Code Gen Properties',"","";
	    'Region to Super Block','Region to Super Block',"","";
	    'Up To Main Diagram','Up To Main Diagram',"","gtk-goto-top"];
    
    L(3) = ['PaletteMenu','Palette',"","";
	    'Pal Tree','Pal Tree',"","";
	    'Palettes','Palettes',"","";
	    'Pal editor','Pal editor',"","";
	    'Region to Palette','Region to Palette',"","";
	    'Load as Palette','Load as Palette',"","";
	    'Save as Palette','Save as Palette',"",""];

    L(4) = ['EditMenu','Edit',"","";
	    'Undo','Undo',"","gtk-undo";
	    'Cut','Cut',"<control>X","gtk-cut";
	    'Copy','Copy',"<Ctrl>c","gtk-copy";
	    'Paste','Paste',"<Ctrl>v","gtk-paste";
	    'Duplicate','Duplicate',"","";
	    'Delete','Delete',"Delete","";
	    'Move','Move',"","";
	    'Smart Move','Smart Move',"","";
	    'Align','Align',"","";
	    'Flip','Flip',"","";
	    'Rotate Left','Rotate Left',"","";
	    'Rotate Right','Rotate Right',"","";
	    'Add new block','Add new block',"","";
	    'Block Documentation','Block Documentation',"","";..
	    'Label','Label',"",""];

    L(5) = ['ViewMenu','View',"","";
	    'Zoom in','Zoom in',"","gtk-zoom-in";
	    'Zoom out','Zoom out',"","gtk-zoom-out";
	    'Zoom 100','Zoom 100',"","gtk-zoom-100";
	    'Fit diagram to figure','Fit diagram to figure',"","gtk-zoom-fit";
	    'Default window parameters','Default window parameters',"","";
	    'Available Parameters','Available Parameters',"","";
	    'Icon Font Option','Icon Font Option',"","";
	    'Grid','Grid',"",""];

    L(6) = ['SimulateMenu','Simulate',"","";
	    'Setup','Setup',"","gtk-preferences";
	    'Compile','Compile',"","gtk-execute";
	    'Modelica initialize','Modelica initialize',"","";
	    'Eval','Eval',"","";
	    'Analyze Diagram','Analyze Diagram',"","";
	    'Debug Level','Debug Level',"","";
	    'Run','Run',"","gtk-media-play"];

    L(7) = ['FormatMenu','Format',"","";
	    'Set default action','Set default action',"","";
	    'Set grid','Set grid',"","";
	    'Add color','Add color',"","";
	    'Default link colors','Default link colors',"","";
	    'Color','Color',"","";
	    'Background color','Background color',"","";
	    'Show Block Shadow','Show Block Shadow',"","";
	    'Resize','Resize',"","";
	    'Identification','Identification',"","";
	    'ID fonts','ID fonts',"","";
	    'Icon','Icon',"","";
	    'Icon Editor','Icon Editor',"",""];

    L(8) = ['ToolsMenu','Tools',"","";
	    'Activate ScicosLab Window','Activate ScicosLab Window',"","";
	    'Create Mask','Create Mask',"","";
	    'Remove Mask','Remove Mask',"","";
	    'Customize Mask','Customize Mask',"","";
	    'Save Block GUI','Save Block GUI',"","";
	    'Create Atomic','Create Atomic',"","";
	    'Remove Atomic','Remove Atomic',"","";
	    'Get Info','Get Info',"","";
	    'Details','Details',"","";
	    'Browser','Browser',"","";
	    'Code Generation','Code Generation',"","";
	    'Shortcuts','Shortcuts',"","";
	    'Calc','Calc',"",""];

    L(9) = ['HelpMenu','Help',"","";
	    'Help','Help',"","";
	    'Scicos Documentation','Scicos Documentation',"","";
	    'Demos','Demos',"","";
	    'About Scicos','About Scicos',"",""];

    // menu Edit->Block 
    
    L(10)=["Block Menu","Block","",""];
        
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
  // XXXX changer l'interface pour enlever length !!
  mb_text=scicos_menubar(action_group,merge);
  tb_text=scicos_toolbar(is_top,action_group,merge);
  ui_text=catenate([mb_text,tb_text],sep='\n');
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
  if part(name,1)<>'$' then 
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
  name = strsubst(tolower(name),' ','_');
  fname='scmenu_'+name
endfunction

  
