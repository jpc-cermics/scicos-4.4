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
// (Copyright (C) 2011-2011 Jean-Philippe Chancelier)

function scicos_set_uimanager(is_top)
// Get the vbox which contains the default menubar 
// and replace the menubar by a scicos menubar/toolbar 
// using the gtkuimanager mechanism.
//
  
  function txt=scicos_toolbar(is_top)
  // text for the toolbar 
    txt =[ "  <toolbar name=""toolbar"">"
	   "    <toolitem name=""Zoom in"" action=""scmenu_zoom_in"" />"
	   "    <toolitem name=""Zoom out"" action=""scmenu_zoom_out"" />"
	   "    <toolitem name=""Zoom fit"" action=""scmenu_fit_diagram_to_figure"" />"
	   "    <toolitem name=""Zoom 100"" action=""scmenu_default_window_parameters"" />"
	   "    <separator name=""tsep1"" />"
	   "    <toolitem name=""Cut"" action=""scmenu_cut"" />"
	   "    <toolitem name=""Copy"" action=""scmenu_copy"" />"
	   "    <toolitem name=""Paste"" action=""scmenu_paste"" />"
	   "    <separator name=""tsep3"" />"];
    if ~is_top then 
      txt.concatd[[ "    <toolitem name=""Up To Parent"" action=""scmenu_up"" />"
		    "    <toolitem name=""Up To Main Diagram"" action=""scmenu_up_to_main_diagram"" />"
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

  function txt=scicos_menubar()
  // Scicos Menu definitions

    function [txt]=get_txt_scicos_menubar(%scicos_menu,txt=[])
      for i=1:length(%scicos_menu)
        if type(%scicos_menu(i),'string')=='SMat' then
          if ~isempty(strindex(%scicos_menu(i)(1),'|||')) then
             %scicos_menu(i)(1)=part(%scicos_menu(i)(1),1:strindex(%scicos_menu(i)(1),'|||')-1)
          end
          tt="<"+%scicos_menu(i)(2)+" name="""+%scicos_menu(i)(1)+"""";
          if %scicos_menu(i)(2)=="menuitem" then
            tt=tt+" action="""+%scicos_menu(i)(3)+""" />";
          elseif %scicos_menu(i)(2)=="menu" then
            tt=tt+" action="""+%scicos_menu(i)(3)+""">";
          elseif %scicos_menu(i)(2)=="separator" then
            tt=tt+" />";
          end
          txt=[txt;tt]
        else
          txt=get_txt_scicos_menubar(%scicos_menu(i),txt=txt);
          txt=[txt;"</menu>"];
        end
      end
    endfunction

    txt=["<menubar>";
         get_txt_scicos_menubar(%scicos_menu);
         "</menubar>" ];

    txt  = catenate(txt,sep='\n');    
  endfunction
  
  function action_group=scicos_create_actions(gname,S,merge)
  // creates an action group named gname and 
  // populated by S.
  //
  // get the menu helps to obtain the tooltips 
    H=scicos_help_menu();
    action_group = gtkactiongroup_new(gname);
    for i=1:size(S,'r');
      if H.iskey[S(i,1)] then 
	ttip=catenate(H(S(i,1)),sep='\n');
      else
	ttip="";
      end
      if ~isempty(strindex(S(i,2),'|||')) then
        S(i,4) = part(S(i,2),strindex(S(i,2),'|||')+3:length(S(i,2)))
        S(i,2) = ""
      end
      action = gtkaction_new( S(i,1), S(i,2) , ttip , S(i,4) );
      if gname<>"menu" then 
	action.connect["activate",scicos_activate_action,list(merge)];
      end
      if S(i,3)=="" then 
	action_group.add_action[action];
      else
	action_group.add_action_with_accel[action,accelerator=S(i,3)];
      end
    end
    merge.insert_action_group[action_group, 0];
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

  // creates a set of actions 
  // ------------------------
  S=scicos_actions();
  gnames=S.__keys;
  for i=1:size(gnames,'*')
    gn=gnames(i);
    scicos_create_actions(gn,S(gn),merge);
  end
  
  merge.set_data[ui_id=-1];
  // the ui manager will add widgets in vb 
  merge.connect["add_widget", scicos_add_widget, list(vb)];
  // 
  merge.set_data[win=win];
  window.add_accel_group[merge.get_accel_group[]];
  // to access to actions through window id
  window.set_data[uimanager=merge];
  mb_text=scicos_menubar();
  tb_text=scicos_toolbar(is_top);
  ui_text=catenate([mb_text,tb_text],sep='\n');
  // XXXX changer l'interface pour enlever length !!
  rep = merge.add_ui_from_string[ui_text,length(ui_text)];
  // XXX revoir le rep 
  if rep==0 then 
    printf("building menus failed: \n");
  end
  // initial sensitivity 
  scicos_action_set_sensitivity(window,"scmenu_cut",%f)
  scicos_action_set_sensitivity(window,"scmenu_copy",%f)
  scicos_action_set_sensitivity(window,"scmenu_paste",%f)
  // 
  scicos_action_set_sensitivity(win,"scmenu_create_mask",%f);
  scicos_action_set_sensitivity(win,"scmenu_remove_mask",%f);
  scicos_action_set_sensitivity(win,"scmenu_restore_mask",%f);
  scicos_action_set_sensitivity(win,"scmenu_customize_mask",%f);
  scicos_action_set_sensitivity(win,"scmenu_save_block_gui",%f);
  //
  scicos_action_set_sensitivity(win,"scmenu_create_atomic",%f);
  scicos_action_set_sensitivity(win,"scmenu_remove_atomic",%f);
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
  //printf("Action %s (type=%s) win=%d activated\n", name, typename,win);
  if part(name,1)=='$' then 
    // predefined command 
    nsp_enqueue_command(win,name);
  else
    nsp_enqueue_command(win,sprintf('scicos_tb(%s,%d)',name,win));
  end
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
// set the sensitivity of action name for window win to 
// the value of sensitive 
// win can be a number of a window widget.
// 
  // return; // temporarily not activated XXXX
  //printf("Setting %s sensitivity to %d\n',name,sensitive);
  if type(win,'short')== 'm' then 
    window=nsp_graphic_widget(win);
  else
    window=win;
  end
  if window.check_data['uimanager']==%f then return;end 
  uimanager = window.get_data['uimanager'];
  L=uimanager.get_action_groups[]
  if isempty(L) then return;end 
  for i=1:length(L)
    action_group = L(i);
    // Attention bug si name n'existe pas 
    action = action_group.get_action[name];
    if type(action,'short')== 'GtkAction' then 
      action.set_property["sensitive", sensitive];
    end
  end
endfunction
  
function scicos_set_stop_sensitivity(sensitive) 
// set the stop sensitivity for a set of windows.
//
  wins=intersect(winsid(),[inactive_windows(2)(:);curwin]');
  for i=1:length(wins)
    window=nsp_graphic_widget(wins(i));
    if window.check_data['uimanager'] then 
      uimanager = window.get_data['uimanager'];
      L=uimanager.get_action_groups[]
      for j=1:length(L)
	action_group = L(j);
	if action_group.get_name[]=="scicos_stop" then
	  action_group.set_property["sensitive",sensitive];
	end
      end
    end
  end
endfunction

function disablemenus()
// disable all actions 
// printf("debug: disable all menus \n");
  scicos_menu_sensitivity(%f);
endfunction

function enablemenus()
// disable all actions 
//printf("debug: enable all menus \n");
  scicos_menu_sensitivity(%t);
  scicos_set_stop_sensitivity(%f);
endfunction

function scicos_menu_sensitivity(flag)
// disable all actions 
// printf("debug: disable all menus \n");
  wins=intersect(winsid(),[inactive_windows(2)(:);curwin]');
  for i=1:length(wins)
    window=nsp_graphic_widget(wins(i));
    if window.check_data['uimanager'] then 
      uimanager = window.get_data['uimanager'];
      L=uimanager.get_action_groups[]
      for j=1:length(L)
	action_group = L(j);
	action_group.set_property["sensitive",flag];
      end
    end
  end
endfunction

function S=scicos_actions()
// A set of actions 
// ['action','name-in-menu', accelerator|"" , icon-name|"" ]
  S=hash_create(10);

  function [tt,tt_menu]=get_scicos_actions(%scicos_menu,tt=[],tt_menu=[])

    for i=1:length(%scicos_menu)
      if type(%scicos_menu(i),'string')=='SMat' then

        if %scicos_menu(i)(2)=="menuitem" then
          tt=[tt;%scicos_menu(i)(3) %scicos_menu(i)(1) %scicos_menu(i)(4) %scicos_menu(i)(5)]
        elseif %scicos_menu(i)(2)=="menu" then
          tt_menu=[tt_menu;%scicos_menu(i)(3) %scicos_menu(i)(1) %scicos_menu(i)(4) %scicos_menu(i)(5)]
        end

      else
        [tt,tt_menu]=get_scicos_actions(%scicos_menu(i),tt=tt,tt_menu=tt_menu);
      end
    end

  endfunction

  [txt,txt_menu]=get_scicos_actions(%scicos_menu);

  S.global=txt;
  S.menu=txt_menu;

  S.scicos_stop= ["$scicos_stop","Stop","", "gtk-cancel"];
endfunction

function scicos_menus_select_set_sensitivity(selection,win) 
// change menu sensitivity according to selection 
// here we change cut and copy 
  // return ;// to be activated latter XXXX
  if isempty(selection) then 
    sel= 'None';
  elseif length(selection) > 1 then 
    sel='Multi'
  else  
    sel= scs_m.objs(selection).type 
  end
  //printf('selection is ==>%s \n",sel);
  if sel== 'None' then 
    scicos_action_set_sensitivity(win,"scmenu_cut",%f);
    scicos_action_set_sensitivity(win,"scmenu_copy",%f);
    scicos_action_set_sensitivity(win,"scmenu_delete",%f);
    scicos_action_set_sensitivity(win,"scmenu_block_menu",%f);
    // 
    scicos_action_set_sensitivity(win,"scmenu_create_mask",%f);
    scicos_action_set_sensitivity(win,"scmenu_remove_mask",%f);
    scicos_action_set_sensitivity(win,"scmenu_restore_mask",%f);
    scicos_action_set_sensitivity(win,"scmenu_customize_mask",%f);
    scicos_action_set_sensitivity(win,"scmenu_save_block_gui",%f);
    scicos_action_set_sensitivity(win,"scmenu_create_atomic",%f);
    scicos_action_set_sensitivity(win,"scmenu_remove_atomic",%f);
    //
  elseif  sel== 'Multi' then 
    scicos_action_set_sensitivity(win,"scmenu_cut",%t);
    scicos_action_set_sensitivity(win,"scmenu_copy",%t);
    scicos_action_set_sensitivity(win,"scmenu_delete",%t);
    scicos_action_set_sensitivity(win,"scmenu_block_menu",%f);
    // 
    scicos_action_set_sensitivity(win,"scmenu_create_mask",%f);
    scicos_action_set_sensitivity(win,"scmenu_remove_mask",%f);
    scicos_action_set_sensitivity(win,"scmenu_restore_mask",%f);
    scicos_action_set_sensitivity(win,"scmenu_customize_mask",%f);
    scicos_action_set_sensitivity(win,"scmenu_save_block_gui",%f);
    scicos_action_set_sensitivity(win,"scmenu_create_atomic",%f);
    scicos_action_set_sensitivity(win,"scmenu_remove_atomic",%f);
  else 
    scicos_action_set_sensitivity(win,"scmenu_cut",%t);
    scicos_action_set_sensitivity(win,"scmenu_copy",%t);
    scicos_action_set_sensitivity(win,"scmenu_delete",%t);
    o= scs_m.objs(selection);
    if o.type=='Block'
      scicos_action_set_sensitivity(win,"scmenu_block_menu",%t);
    else 
      scicos_action_set_sensitivity(win,"scmenu_block_menu",%f);
    end
    tag=scicos_is_maskable(o);
    scicos_action_set_sensitivity(win,"scmenu_create_mask",tag);
    scicos_action_set_sensitivity(win,"scmenu_restore_mask",tag);
    tag=scicos_is_masked(o);
    scicos_action_set_sensitivity(win,"scmenu_remove_mask",tag);
    scicos_action_set_sensitivity(win,"scmenu_customize_mask",tag);
    scicos_action_set_sensitivity(win,"scmenu_save_block_gui",tag);
    tag= scicos_is_atomicable(o);
    scicos_action_set_sensitivity(win,"scmenu_create_atomic",tag);
    tag= scicos_is_atomic(o);
    scicos_action_set_sensitivity(win,"scmenu_remove_atomic",tag);
  end
endfunction

function y=scicos_is_maskable(o)
  y=o.type == 'Block' && type(o.model.sim,'short')=='s' ...
    &&  o.model.sim == 'super';
endfunction

function y=scicos_is_masked(o)
  y=o.type == 'Block' && isequal(o.model.sim,'csuper') ...
    && isequal(o.model.ipar,1);
endfunction 

function y=scicos_is_atomicable(o)
  y= o.type =='Block' && o.model.sim.equal['super'] && size(o.model.evtin,'*')<=1;
endfunction

function y=scicos_is_atomic(o)
  y = o.type =='Block' && o.model.sim(1)=='asuper';
endfunction



function scicos_menus_paste_set_sensitivity(flag)
// change paste sensitivity according to emptiness 
// or not of the clipboard. 
  // return; // to be activated latter XXXX 
  wins=intersect(winsid(),[inactive_windows(2)(:);curwin]');
  for k=1:size(wins,'*') 
    scicos_action_set_sensitivity(wins(k),"scmenu_paste",flag);
  end
endfunction

function scicos_menu_update_sensitivity(Clipboard,Select)
  if ~isempty(Clipboard) then
    scicos_menus_paste_set_sensitivity(%t)
  else
    scicos_menus_paste_set_sensitivity(%f)
  end
  if ~isempty(Select) then
    scicos_menus_select_set_sensitivity(Select(:,1),curwin);
  else
    scicos_menus_select_set_sensitivity(Select,curwin);
  end
endfunction
