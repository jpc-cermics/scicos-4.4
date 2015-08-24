// Copyright (C) 2009 Jean-Philippe Chancelier Cermics/Enpc
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//
// Read a modelica xml scicos file
// and set up a widget for edition.
//

function window=demo_xml(fname)

  function selection_cb(selection,args)
  // handler activated when a row is selected
  // in the tree view.
  // this will change the right panel
  // which is populated with a new treeview.
    function demo_liststore (hbox,model)
      sw = gtkscrolledwindow_new();
      sw.set_shadow_type[GTK.SHADOW_ETCHED_IN]
      sw.set_policy[GTK.POLICY_NEVER,GTK.POLICY_AUTOMATIC]
      treeview = gtktreeview_new(model);
      treeview.set_rules_hint[%t];
      treeview.set_search_column[3];
      // give name to columns
      model = treeview.get_model[];

      names=['Name','Id','Kind','Fixed','Value',...
	     'Weight','Max','Min','Nominal',...
	     "Comment','Selection'];

      function cell_edited (cell,path_string,new_text,data)
      // callback for changed texts
	model = data(1);
	col = data(2);
	path = gtktreepath_new(path_string);
	i = path.get_indices[];
	iter = model.get_iter[path_string];
	// test if new_text is a valid answer
	ok=%t;
	if length(new_text)<>0 then
	  ok=execstr('val='+new_text',errcatch=%t);
	  if ok then
	    ok= ( type(val,'short')=='m' )
	  end
	end
	if ~ok then
	  x_message('You should enter a number");
	  return
	end
	model.set[iter,col,new_text];
      endfunction

      function editable_toggled (cell, path_str, data)
      // callback for changing the boolean values
	model=data(1);
	column_number = data(2);
	// get toggled iter */
	iter=model.get_iter[path_str];
	val = model.get_value[iter,column_number];
	// do something with the value
	val = ~val;
	// set new value */
	model.set[iter,column_number, val];
      endfunction

      for i=1:model.get_n_columns[]

	if names(i)=='Selection' || names(i)== 'Fixed' then
	  // boolean editable
	  renderer = gtkcellrenderertoggle_new ();
	  if names(i)=='Selection' then
	    renderer.connect["toggled", editable_toggled,list(model,i- 1)];
	  end
	  col = gtktreeviewcolumn_new(title=names(i),renderer=renderer,attrs= hash(active=i-1));

	else
	  renderer = gtkcellrenderertext_new ();
	  if or(names(i)==['Value','Weight','Max','Min','Nominal']) then
	    renderer.connect[  "edited",  cell_edited,list(model,i-1)]
	    renderer.set_property['editable',%t]
	  end
	  col = gtktreeviewcolumn_new(title=names(i),renderer=renderer,...
				      attrs=hash(text=i-1));
	end
	col.set_resizable[%t];
	if i== 10 then
	  col.set_sizing[ GTK.TREE_VIEW_COLUMN_FIXED]
	  col.set_fixed_width[100]
	end
	treeview.append_column[col];
      end

      sw.add[treeview];
      L=hbox.get_children[];
      if length(L)==2 then
	hbox.remove[L(2)];
      end
      hbox.pack_start[sw,expand=%t,fill=%t,padding=0]
      sw.show_all[]
    endfunction


    model=args(1);
    iter=selection.get_selected[]
    if ~is(iter,%types.GtkTreeIter) then return;end
    if model.get_value[iter,1] then
      Tv =  model.get_value[iter,2];
      hbox=args(2);
      demo_liststore(hbox,Tv);
    end
  endfunction

  function remove_scicos_widget(wingtkid)
    global scicos_widgets
    for i=1:length(scicos_widgets)
      if wingtkid.equal[scicos_widgets(i).id] then
        scicos_widgets(i).open=%f;break
      end
    end
  endfunction

  // build the toplevel widget

  if nargin < 1 then
    fname=getenv('NSP')+'/macros/scicos_no_xor/demo_xml1.xml'
  end
  G=gmarkup(fname);
  model= demo_xml_model_from_markup(G);
  window = gtkwindow_new ()
  window.set_title["Modelica variables browser"]
  window.set_default_size[-1, 500]

  window.set_border_width[8]
  if exists('gtk_get_major_version','function') then
    vbox = gtk_box_new(GTK.ORIENTATION_VERTICAL,spacing=0);
  else
    vbox = gtkvbox_new(homogeneous=%f,spacing=0);
  end
  window.add[vbox]
  menubar=demo_xml_menubar();
  vbox.pack_start[menubar,expand=%f,fill=%t,padding=0]

  if exists('gtk_get_major_version','function') then
    hbox = gtk_box_new(GTK.ORIENTATION_HORIZONTAL,spacing=8);
  else
    hbox = gtkhbox_new(homogeneous=%f,spacing=8);
  end
  vbox.pack_start[hbox,expand=%t,fill=%t,padding=0];

  sw = gtkscrolledwindow_new ();
  sw.set_policy[GTK.POLICY_NEVER, GTK.POLICY_AUTOMATIC]
  sw.set_placement[GTK.CORNER_TOP_RIGHT]
  hbox.pack_start[sw,expand=%f,fill=%f,padding=0]

  treeview=gtktreeview_new();
  treeview.set_model[model=model];

  cell = gtkcellrenderertext_new ();
  col  = gtktreeviewcolumn_new (renderer=cell,attrs=hash(text= 0));
  col.set_title["Texte"];
  treeview.append_column[col];

  sw.add[treeview]
  // ----------------
  selection = treeview.get_selection[];
  model = treeview.get_model[];
  selection.connect["changed", selection_cb,list(model,hbox)]

  window.connect["destroy", remove_scicos_widget, list(window)];
  window.show_all[];
endfunction



function model= demo_xml_model_from_markup(G)
//------------------------------------------
// build a model from the markup object
// In this process we will create a
// Three column TreeStore
// The first column contains a hierarchy
// of <struct>  + the top level <model>
// which keep the tree structure
// The second column contains for each
// struct a new model which contains
// the <terminal> objects stored as model rows.
// The third column is just a boolean which indicates
// if the second column is populated.
//------------------------------------------

  function name=get_node_str_attr(G,node_name)
  // search in node G of type Gmarkup the first subnode
  // named node_name and returns the associated attribute 'value'
    L= G.children;
    name="";
    for i=1:length(L)
      elt = L(i);
      if type(elt,'short') == 'gmn' && elt.name == node_name then
	if elt.attributes.iskey['value'] then
	  name =  elt.attributes.value;
	end
      end
    end
  endfunction

  function name=get_node_str(G,node_name)
  // search in node G the first subnode
  // named node_name and returns the associated string
    L= G.children;
    name="";
    for i=1:length(L)
      elt = L(i);
      if type(elt,'short') == 'gmn' && elt.name == node_name then
	L1=elt.children;
	for j=1:length(L1)
	  if type(L1(j),'short')== 's' then
	    name = L1(j);
	    if ~and(isspace(name)) then return;end
	  end
	end
      end
    end
  endfunction

  function node=get_node(G,node_name)
  // search in node G of type Gmarkup the first subnode
  // named node_name name and returns the associated string
    L= G.children;
    node=[];
    for i=1:length(L)
      elt = L(i);
      if type(elt,'short') == 'gmn' && elt.name == node_name then
	node= elt;
	return;
      end
    end
  endfunction

  function demo_xml_store(model,iter,L)
  // store items in the model
  // recursively to keep tree stucture.
    if isempty(L) then return; end
    for i=1:length(L)
      elt = L(i);
      if type(elt,'short') == 'gmn' then
	if elt.name <> 'terminal' then
	  // elts here are supposed to be struct or terminal
	  name=get_node_str(elt,'name')
	  node= get_node(elt,'subnodes');
// 	  pause demo_xml_store
	  if type(node,'short')=='gmn' then
	    Ls=collect_terminal_list(node);
	    // convert Ls(11) to booleans
	    Ls(11) = Ls(11) =='y';
	    // convert Ls(4) to booleans
	    Ls(4) = Ls(4) <> 'false';
// 	  pause ALAN:AVERIFIERICI/CORRECTION POUR LinearModelica
            if ~isempty(Ls(2)) then
	      Gls = gtkliststore_new(Ls);
            end
	  end
	  iter1 = model.append[iter,list(name,%t,list(Gls))];
	  if type(node,'short')=='gmn' then
	    demo_xml_store(model,iter1,node.children);
	  end
	end
      end
    end
  endfunction

  function L=collect_terminal_list(node)
  // the node selected must have subnodes
  // we collect the values in L.
    L=list()
    for i=1:11 ; L(i)=m2s([]);end
    L1=node.children;
    for i = 1:length(L1)
      elt = L1(i);
      if type(elt,'short')== 'gmn' && elt.name == 'terminal' then
	l=list();
	l($+1)=get_node_str(elt,'name');
	l($+1)=get_node_str(elt,'id');
	l($+1)=get_node_str(elt,'kind');
	l($+1)=get_node_str_attr(elt,'fixed');
	l($+1)=get_node_str_attr(elt,'initial_value');
	l($+1)="0.0"; // weight;
	l($+1)=""; // max
	l($+1)=""; // min
	l($+1)="1.0"; // nominal
	l($+1)=get_node_str_attr(elt,'comment');
	l($+1)=get_node_str_attr(elt,'selected');
	for j=1:length(l) ; L(j)=[L(j);l(j)];end
      end
    end
  endfunction

  // main code
  // a fake gtkliststore to obtain its type
  Gls = gtkliststore_new(list(5))
  // create the top level model
  model = gtktreestore_new(list("name",%f,list(Gls)),%f)
  // Get the name of the model
  model_name = get_node_str(G,'name');
  iter = model.append[list(model_name,%f)];
  node=get_node(G,'elements')
  // recursively populate the model
  demo_xml_store(model,iter,node.children);
  // we attach the remaining nodes i.e
  // equations and when_clauses to the model
  // since it contains extra-data needed for
  // xml-saving the model
  equations=get_node(G,'equations')
  whenode=get_node(G,'when_clauses')
  model.user_data=list(equations,whenode)
endfunction

function L=explore_model(model)
//------------------------------------------
// explore the treemodel and
// get the treemodel information in
// a recursive list
//------------------------------------------

  function H=get_terminal_obj(tmodel)
    H=list();
    nc=tmodel.get_n_columns[]
    iter=tmodel.get_iter_first[0];
    names=['Name','Id','Kind','Fixed','Value',...
	   'Weight','Max','Min','Nominal',...
	   "Comment','Selection'];
    while %t then
      L=list();
      for i=1:nc
	L(i)=  tmodel.get_value[iter,i-1];
	if names(i)== 'Selection'
	  if L(i) then L(i)="y" else L(i)="n";end
	elseif names(i)== 'Fixed'
	  if L(i) then L(i)="true" else L(i)="false";end
	end
      end
      H($+1)=L;
      if ~tmodel.iter_next[iter] then break;end
    end
  endfunction

  function L=get_children(model,iter)
    L=list();
    if model.iter_has_child[iter] then
      iter1=model.iter_children[iter];
      while %t  then
	name=model.get_value[iter1,0];
	if model.get_value[iter1,1] then
	  tmodel=  model.get_value[iter1,2];
	  hmodel = get_terminal_obj(tmodel);
	else
	  hmodel= list();
	end
	L1=get_children(model,iter1);
	L($+1)=list(name,hmodel,L1);
	if ~model.iter_next[iter1] then break;end
      end
    end
  endfunction

  // name of modelica model
  iter=model.get_iter_first[0];
  name=model.get_value[iter,0];
  L1=get_children(model,iter);
  L=list(name,L1);
endfunction

function save_model(name,model)
//------------------------------------------
// save a model in a file in xml syntax
//------------------------------------------
  function save_elements(fd,indent,L)
    for i=1:length(L)
      elt=L(i);
      indent=indent+"  ";
      fd.printf[indent+"<struct>\n"];
      fd.printf[indent+"  "+"<name>%s</name>\n",gmarkup_escape_text(elt(1))];
      fd.printf[indent+"  "+"<subnodes>\n"];
      terms=elt(2);
      for j=1:length(terms)
	terminal=terms(j);
	l= length(terminal);
	if l<>0 then
	  tags=["name";"kind";"id";"fixed";"initial_value";"weight";
		"max";"min";"nominal_value";"comment";"selected"];
	  fd.printf[indent+"  "+"<terminal>\n"];
	  // name
	  str=tags(1);
	  fd.printf[indent+"  "+"  <%s>%s</%s>\n",str,gmarkup_escape_text(terminal(1)),str];
	  // kind
	  str=tags(2);
	  fd.printf[indent+"  "+"  <%s>%s</%s>\n",str,gmarkup_escape_text(terminal(3)),str];
	  // id
	  str=tags(3);
	  fd.printf[indent+"  "+"  <%s>%s</%s>\n",str,gmarkup_escape_text(terminal(2)),str];
	  for k=4:l
	    str=tags(k);
	    fd.printf[indent+"  "+"  <%s value=""%s""/>\n",str,terminal(k),str];
	  end
	  fd.printf[indent+"  "+"</terminal>\n"];
	end
      end
      save_elements(fd,indent+"  ",elt(3))
      fd.printf[indent+"  "+"</subnodes>\n"];
      fd.printf[indent+"</struct>\n"];
    end
  endfunction

  L=explore_model(model);
  fd=fopen(name,mode="w");
  fd.printf["<model>\n"];
  indent=" ";
  fd.printf[indent+"<name>%s</name>\n",gmarkup_escape_text(L(1))];
  fd.printf[indent+"<elements>\n"];
  save_elements(fd,indent,L(2));
  fd.printf[indent+"</elements>\n"];
  // now insert the unmodified equations
  //
  equations=model.user_data(1);
  fd.printf[indent+"<equations>\n"];
  for i=1:length(equations.children)
    elt=equations.children(i);
    if type(elt,'short')== 'gmn' then
      fd.printf[indent+"  <equation value=""%s\n", ...
		gmarkup_escape_text(elt.attributes.value)];
      fd.printf[indent+"  ""/>\n"];
    end
  end
  fd.printf[indent+"</equations>\n"];
  when_clauses=  model.user_data(2);
  fd.printf[indent+"<when_clauses>\n"];
  for i=1:length(when_clauses.children)
    elt=when_clauses.children(i);
    if type(elt,'short')== 'gmn' then
      fd.printf[indent+"  <when value=""%s\n", ...
		gmarkup_escape_text(elt.attributes.value)];
      fd.printf[indent+"  ""/>\n"];
    end
  end
  fd.printf[indent+"</when_clauses>\n"];
  fd.printf["</model>\n"];
  fd.close[];
endfunction


//
// Menu demo
//

function menuitem_response(w,args)
  printf("Menu item [%s] activated \n",args(1));
endfunction

function menubar=demo_xml_menubar()
  tearoff = %f;
  menubar = gtkmenubar_new ();
  // File Menu
  menu = gtkmenu_new ();
  if tearoff then
    menuitem = gtktearoffmenuitem_new ();
    menu.append[  menuitem]
  end
  menuitem = gtkimagemenuitem_new(stock_id="gtk-open");
  menuitem.connect["activate",menuitem_response,list("open activated")];
  menu.append[menuitem]
  menuitem = gtkimagemenuitem_new(stock_id="gtk-close");
  menuitem.connect["activate",menuitem_response,list("close activated")];
  menu.append[menuitem]
  menuitem = gtkimagemenuitem_new(stock_id="gtk-save");
  menuitem.connect["activate",menuitem_response,list("save activated")];
  menu.append[menuitem]
  menuitem = gtkimagemenuitem_new(stock_id="gtk-save-as");
  menuitem.connect["activate",menuitem_response,list("save-as activated")];
  menu.append[menuitem]
  menuitem = gtkimagemenuitem_new(stock_id="gtk-quit");
  menuitem.connect["activate",menuitem_response,list("quit activated")];
  menu.append[menuitem]

  menuitem = gtkmenuitem_new(label="File");
  menuitem.set_submenu[menu];
  menubar.append[  menuitem]
  menuitem.show[];

  //  A radio-button menu
  menu = gtkmenu_new ();
  if tearoff then
    menuitem = gtktearoffmenuitem_new ();
    menu.append[  menuitem]
  end
  names=["Normal";"Simplified model";"Fixed items";
	 "Selected";"Selected (show all)";"Changed (show all)"];
  for i = 1:size(names,'*')
    if i==1 then
      menuitem = gtkradiomenuitem_new(label=names(i));
      group = menuitem;
    else
      menuitem = gtkradiomenuitem_new(group=group,label=names(i));
    end
    // callback
    menuitem.connect["activate",menuitem_response,list(names(i))];
    menu.append[menuitem]
    if i == 3 then menuitem.set_sensitive[%f]; end
    if i == 4 then menuitem.set_inconsistent[ %f]; end
  end

  menuitem = gtkmenuitem_new(label="Display");
  menuitem.set_submenu[menu];
  menubar.append[  menuitem]

  // Help

  menuitem = gtkimagemenuitem_new(stock_id="gtk-help");
  menubar.append[  menuitem]

endfunction
