// testiconview.sce 
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

function scicos_palette_icon_view(L) 
  if nargin <= 0 then 
    L=acquire('%scicos_pal_list');
  end
  function combo_changed(combo,args)
  // this can be used as handler for 
  // combobox.connect["changed", current_option ]
    M= combo.get_model[]
    iter=combo.get_active_iter[]
    name = M.get_value[iter,0];
    printf('Value selected %s\n",name);
    L=args(2);
    sw=args(1);
    for j=2:length(L)
      if L(j)(1)== name then 
	printf('Value selected is %d\n",j);
	pal_id=j-1;
      end
    end
    icon_list=scicos_build_iconlist(L,pal_id)
    icon_list.show[];
    L=sw.get_children[];
    if length(L)>=1  then 
      sw.remove[L(1)];
    end
    sw.add[icon_list];
  endfunction
  
  window = gtkwindow_new ()// GTK.WINDOW_TOPLEVEL);
  window.set_title['Scicos Palette IconView']; 
  window.set_default_size[400, 400];
  vbox = gtkvbox_new(homogeneous=%f,spacing=0);
  window.add[ vbox];

  // A combo to enable palette selection 
  
  text= m2s([]);
  for i=2:length(L);
    text.concatd[L(i)(1)];
  end
  
  combobox = gtkcombobox_new(text=text);
  combobox.set_add_tearoffs[%f];
  combobox.set_active[0];
  vbox.pack_start[combobox, expand=%f,fill= %t,padding=0];
  
  // an other combo with recursion 
  // for test 
  // -------------------------------
    
  function model= phylogenic_tree_model()
  // gives an example of a tree build from a 
  // list tree 
    data = list( "Eubacteria",...
		 list(  "Aquifecales",...
			"Chlorobium-Flavobacteria group",...
			"Chlamydia-Verrucomicrobia group",...
			list( ...
			    "Verrucomicrobia",...
			    "Chlamydia"),...
			"Flexistipes",...
			"Proteobacteria",...
			list( "alpha",...
			      "gamma ")),...
		 "Eukaryotes",...
		 list(  "Metazoa",...
			"crytomonads et al"),...
		 "Archaea ",...
		 list(     "Korarchaeota",...
			   "Buryarchaeota"));
    
    function phylogenic_tree_model_append(model,h,iter) 
      for i=1:length(h)
	t = type(h(i),'string');
	// On first call to this recursive function iter is not 
	// a GtkTreeIter
	if t == 'SMat' then 
	  if is(iter,%types.GtkTreeIter) then 
	    iter1=model.append[iter,list(h(i))];
	  else 
	    iter1=model.append[list(h(i))];
	  end
	else
	  phylogenic_tree_model_append(model,h(i),iter1);
	end
      end
    endfunction
    
    model = gtktreestore_new(list("name"),%f);
    phylogenic_tree_model_append(model,data,0);
    
  endfunction
  
  model =  phylogenic_tree_model()
  combobox2 = gtkcombobox_new(model=model);
  combobox2.set_add_tearoffs[%t];
  //g_object_unref (model);
  // XXX vbox.pack_start[combobox2, expand=%f,fill= %t,padding=0];
  
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
    name = M.get_value[iter,args(1)];
    printf('Value selected %s\n",name);
  endfunction
  
  combobox2.connect["changed", combo2_changed,list(0) ];
  
  // Icon list 
  
  icon_list=scicos_build_iconlist(L,1)
  // icon list 
  scrolled_window = gtkscrolledwindow_new();
  scrolled_window.add[ icon_list];
  scrolled_window.set_policy[ GTK.POLICY_AUTOMATIC, GTK.POLICY_AUTOMATIC];
  
  combobox.connect["changed", combo_changed,list(scrolled_window,L) ];
  
  vbox.pack_start[scrolled_window, expand=%t,fill= %t,padding=0];
  window.show_all[];
endfunction

function icon_list=scicos_build_iconlist(L, j)
// build a new iconlist for palette j 
  
  function item_activated (icon_view,path)
  // double click on an item 
    model = icon_view.get_model[];
    L=icon_view.get_selected_items[];
    if ~isempty(L);
      iter = model.get_iter[L(1)];
      text= model.get_value[iter,1];
      printf ("Item activated, text is %s\n", text);
      help("http://www.scicos.org/HELP/eng/scicos/'+text+'.htm');
    end
  endfunction
  
  function item_activated_cursor (icon_view,path)
  // when return is typed in the palettes 
    model = icon_view.get_model[];
    L=icon_view.get_selected_items[];
    if ~isempty(L);
      iter = model.get_iter[L(1)];
      text= model.get_value[iter,1];
      printf ("Item cursor activated, text is %s\n", text);
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
	printf ("right-press activated in the background\n");
	L=icon_view.get_selected_items[];
	if isempty(L);return;end 
	path=L(1);
      end
      icon_view.select_path[path];
      model = icon_view.get_model[];
      iter=model.get_iter[path];
      text= model.get_value[iter,1];
      printf ("right-press activated over item text is %s\n", text);
      ll = list('Help', 'Details');
      [Cmenu,args]=mpopup(ll);
      if Cmenu == 'Help' then 
	help("http://www.scicos.org/HELP/eng/scicos/'+text+'.htm');
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
  icon_list.set_size_request[200,-1]
  icon_list.connect_after["button_press_event",press_event_handler];
  icon_list.connect["selection_changed",   selection_changed];
  //icon_list.connect["popup_menu",  popup_menu_handler];
  icon_list.connect["item_activated", item_activated];// double click
  icon_list.connect["activate-cursor-item",item_activated_cursor];
  // model columns -> [pixbuf,name,paletteid,blockid];
  
  model = gtkliststore_new(list(list(%types.GdkPixbuf),"",1,2), %f);
  
  scicos_icon_path = scicos_path + '/macros/scicos/scicos-images/';
  icons = glob(scicos_icon_path);
  
  dir_logo = scicos_icon_path + 'gtk-directory.png';
  pixbuf_dir = gdk_pixbuf_new_from_file(dir_logo);
  pixbuf_def = gdk_pixbuf_new_from_file(scicos_icon_path + 'VOID.png');

  // get data for palette j 
  sub=L(j+1);
  
  for j=2:length(sub)
    icon = scicos_icon_path + sub(j).name + '.png' ;
    ok = execstr('pixbuf = gdk_pixbuf_new_from_file(icon);',errcatch=  %t);
    if ~ok then 
      pixbuf = pixbuf_def
    end
    path=sub(j).path;
    // we assume that path is of length 2 (paletteid,blockid).
    model.append[list(list(pixbuf),sub(j).name,path(1),path(2))];
  end
  
  icon_list.set_model[model=model];
  icon_list.set_pixbuf_column[0];
    
  // Allow DND between the icon view and nsp 
  targets = list( list("GTK_TREE_MODEL_ROW",GTK.TARGET_SAME_APP, 0)  );
  masks= ior(GDK.BUTTON1_MASK,GDK.BUTTON3_MASK);
  icon_list.enable_model_drag_source[masks,targets, GDK.ACTION_COPY];
  // only want to drag/drop in graphic window.
  icon_list.set_reorderable[%f];
endfunction

