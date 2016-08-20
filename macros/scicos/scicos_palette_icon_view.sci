//
// obtained by translation to Nsp of testiconview.c
// Jean-Philippe Chancelier (2008-2011) jpc@cermics.enpc.fr
//
//
// Copyright (C) 2002  Anders Carlsson <andersca@gnu.org>
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
///

function window=scicos_palette_icon_view(H)
// Open a window with selectable palettes
// in icon views.
//
  if nargin <= 0 then
    H=%scicos_pal;
  end

  window = gtkwindow_new ()// GTK.WINDOW_TOPLEVEL);
  window.set_title['Scicos Palette IconView'];
  window.set_default_size[400, 400];

  if exists('gtk_get_major_version','function') then
    vbox = gtk_box_new(GTK.ORIENTATION_VERTICAL,spacing=0);
  else
    vbox = gtkvbox_new(homogeneous=%f,spacing=0);
  end

  window.add[ vbox];

  // a combo with recursive structure.
  function scicos_palette_tree_model_append(model,H,iter)
    L=H.structure;
    for i=1:length(L)
      //don't display single block in combobox
      if type(H.contents(L(i)),'string')<>'SMat' then
        if is(iter,%types.GtkTreeIter) then
          iter1=model.append[iter,list(L(i))];
        else
          iter1=model.append[list(L(i))];
        end
      end
      if type(H.contents(L(i)),'string')=='Hash' then
        scicos_palette_tree_model_append(model,H.contents(L(i)),iter1);
      end
    end
  endfunction

  // a hierarchical model
  model = gtktreestore_new(list("name"),%f);
  //scicos_palette_tree_model_append(model,H.structure,0);
  scicos_palette_tree_model_append(model,H,0);

  // a combo defined by model
  combobox2 = gtkcombobox_new(model=model);
  if ~exists('gtk_get_major_version','function') then
    combobox2.set_add_tearoffs[%t];
  end
  //g_object_unref (model);
  vbox.pack_start[combobox2, expand=%f,fill= %t,padding=0];

  cell_renderer = gtkcellrenderertext_new ();
  combobox2.pack_start[ cell_renderer,expand= %t];
  combobox2.add_attribute[cell_renderer,"text",0];
  // set active element in the combobox
  combobox2.set_active[0];

  function combo2_changed(combo,args)
  // this can be used as handler for
  // combobox.connect["changed", current_option ]
    M= combo.get_model[]
    iter=combo.get_active_iter[]
    //name = M.get_value[iter,0];
    //printf('Value selected %s\n",name);
    H=args(2);
    sw=args(1);

    path=evstr(split(M.get_string_from_iter[iter],sep=':'))+1

    function [j]=get_ind_from_path(H,path)
      k=0;
      for j=1:length(H.structure)
        //we skip single blk in combobox entry
        if type(H.contents(H.structure(j)),'string')<>'SMat' then k=k+1, end
        if path==k then return, end
      end
    endfunction

    function [contents]=get_contents_from_path(H,path)
      contents=[]
      for i=1:length(path)
        k=get_ind_from_path(H,path(i))
        contents=H.contents(H.structure(k))
        H=contents
      end
    endfunction

    S=get_contents_from_path(H,path)
    if isempty(S) then return, end

    icon_list=scicos_build_iconlist(S,combo);
    icon_list.show[];
    L=sw.get_children[];
    if length(L)>=1  then
      sw.remove[L(1)];
    end
    sw.add[icon_list];
  endfunction

  function remove_scicos_widget(wingtkid)
    scicos_manage_widgets('close', wingtkid=wingtkid);
  endfunction

  // Icon list

  icon_list=scicos_build_iconlist(H.contents(H.structure(1)),combobox2);
  // icon list in scrolled window
  scrolled_window = gtkscrolledwindow_new();
  scrolled_window.add[ icon_list];
  scrolled_window.set_policy[ GTK.POLICY_AUTOMATIC, GTK.POLICY_AUTOMATIC];
  //
  combobox2.connect["changed", combo2_changed,list(scrolled_window,H) ];
  vbox.pack_start[scrolled_window, expand=%t,fill= %t,padding=0];
  window.connect["destroy", remove_scicos_widget, list(window)];
  window.show_all[];
  // register the new widget 
  scicos_manage_widgets('register', wingtkid=window, wintype='IconView');
endfunction

function icon_list=scicos_build_iconlist(S,combo)
// build a new iconlist for palette described by S
// this function is called each time a new palette is selected.
    
  function item_activated (icon_view,path,args)
  // double click on an item
    combo=args(1)
    S=args(2)
    model = icon_view.get_model[];
    L=icon_view.get_selected_items[];
    if ~isempty(L);
      iter = model.get_iter[L(1)];
      text= model.get_value[iter,1];
      //printf ("Item activated, text is %s\n", text);
      pixbuf=model.get_value[iter,0]
      PAL=%f
      if pixbuf.check_data['user_data'] then
        if pixbuf.user_data(1)=='PAL_f' then
          PAL=%t
          M=combo.get_model[];
          iter_combo=combo.get_active_iter[];
          it_combo_children=M.iter_children[iter_combo];
          for i=1:evstr(model.get_string_from_iter[iter])
            //we skip single blk in combobox entry
            if type(S.contents(S.structure(i)),'string')<>'SMat' then
              M.iter_next[it_combo_children];
            end
          end
          combo.set_active_iter[it_combo_children]
        end
      end
      if ~PAL then
        cos_help(text)
      end
    end
  endfunction

  function item_activated_cursor (icon_view,path)
  // when return is typed in the palettes
    model = icon_view.get_model[];
    L=icon_view.get_selected_items[];
    if ~isempty(L);
      iter = model.get_iter[L(1)];
      text= model.get_value[iter,1];
      //printf ("Item cursor activated, text is %s\n", text);
    end
  endfunction

  function selection_changed (icon_view)
  // each time selection changes
  // printf ("Selection changed!\n");
  endfunction

  function press_event_handler(icon_view,event)
    if event.button== 3 && event.type == GDK.BUTTON_PRESS then
      // a right press
      path=icon_view.get_path_at_pos[event.x, event.y];
      if type(path,'short')=='none' then
	// here we could decide to do something if
	// selection is non void
	//printf ("right-press activated in the background\n");
	L=icon_view.get_selected_items[];
	if isempty(L);return;end
	path=L(1);
      end
      icon_view.select_path[path];
      model = icon_view.get_model[];
      iter=model.get_iter[path];
      text= model.get_value[iter,1];
      //printf ("right-press activated over item text is %s\n", text);
      ll = list('Help', 'Details');
      [Cmenu,args]=mpopup(ll);
      if Cmenu == 'Help' then
	cos_help(text);
      elseif Cmenu == 'Details' then
	ok=execstr('obj='+text+'(""define"");',errcatch=%t);
	if ok then editvar('obj');
	else
	  lasterror();
	end
      end
    end
  endfunction

  icon_list = gtkiconview_new ();
  icon_list.set_selection_mode[GTK.SELECTION_SINGLE];
  // icon_list.set_selection_mode[GTK.SELECTION_MULTIPLE];
  icon_list.set_size_request[200,-1]
  icon_list.connect_after["button_press_event",press_event_handler];
  icon_list.connect["selection_changed",   selection_changed];
  //icon_list.connect["popup_menu",  popup_menu_handler];
  icon_list.connect["item_activated", item_activated,list(combo,S)];// double click
  icon_list.connect["activate-cursor-item",item_activated_cursor];

  // create a model for icon view [pixbuf,name,paletteid,blockid];
  model = gtkliststore_new(list(list(%types.GdkPixbuf),"",1,2), %f);

  // get data for palette j
  if type(S,'string')=='Hash' then
    for j=1:size(S.structure,'*')
      //single blk
      if type(S.contents(S.structure(j)),'short')=='s' then
        [pixbuf]=get_gdk_pixbuf(%scicos_gif,S.contents(S.structure(j)))
        path=[1,1];// sub(j).path;
        // we assume that path is of length 2 (paletteid,blockid).
        model.append[list(list(pixbuf),S.contents(S.structure(j)),path(1),path(2))];
      //palette
      elseif type(S.contents(S.structure(j)),'short')=='l' || ...
             type(S.contents(S.structure(j)),'short')=='h' then
        [pixbuf]=get_gdk_pixbuf(%scicos_gif,'PAL_f')
        pixbuf.user_data=list("PAL_f");
        path=[1,1];// sub(j).path;
        // we assume that path is of length 2 (paletteid,blockid).
        model.append[list(list(pixbuf),S.structure(j),path(1),path(2))];
        icon_list.set_text_column[1];
      end
    end
  else
    //list case
    for j=1:size(S,'*')
      [pixbuf]=get_gdk_pixbuf(%scicos_gif,S(j))
      path=[1,1];// sub(j).path;
      // we assume that path is of length 2 (paletteid,blockid).
      model.append[list(list(pixbuf),S(j),path(1),path(2))];
    end
  end

  icon_list.set_model[model=model];
  icon_list.set_pixbuf_column[0];
  // Allow DND between the icon view and nsp
  targets = list( list("GTK_TREE_MODEL_ROW",GTK.TARGET_SAME_APP, 0)  );
  masks= ior(GDK.BUTTON1_MASK,GDK.BUTTON3_MASK);
  icon_list.enable_model_drag_source[masks,targets, GDK.ACTION_COPY];
  // only want to drag/drop in graphic window.
  icon_list.set_reorderable[%f];
  //
  if ~isempty(icon_list.get_method_names[]=="set_tooltip_column") then
    // added Aug 2011
    // use block name as tooltip
    icon_list.set_tooltip_column[1];
  end
endfunction

//also used in pal_tree
function [pixbuf]=get_gdk_pixbuf(%scicos_gif,blk_name)
  pixbuf_def = gdk_pixbuf_new_from_file( file('join',[%scicos_gif(1),'VOID.png']));
  for jj=1:size(%scicos_gif,1)
    icon = file('join',[%scicos_gif(jj),blk_name+'.png']) ;
    ok = execstr('pixbuf = gdk_pixbuf_new_from_file(icon);',errcatch=  %t);
    if ok then
      // pixbuf = pixbuf.scale_simple[40,40,GDK.INTERP_NEAREST];
      break
    else
      pixbuf = pixbuf_def
      lasterror();
    end
  end
endfunction
