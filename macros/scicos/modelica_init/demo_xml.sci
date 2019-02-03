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
  
  function remove_scicos_widget(wingtkid)
    scicos_manage_widgets('close', wingtkid=wingtkid);
  endfunction

  // build the toplevel widget

  G=gmarkup(fname);
  model= demo_xml_model_from_markup(G);
  // utiliser le callback 
  modelica_update_model(model, "1.0", "0.0");

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
  treeview=gtktreeview_new();
  treeview.set_model[model=model];

  menubar=demo_xml_menubar(fname,window,treeview);
  vbox.pack_start[menubar,expand=%f,fill=%t,padding=0]

  if exists('gtk_get_major_version','function') then
    hbox1 = gtk_box_new(GTK.ORIENTATION_HORIZONTAL,spacing=8);
  else
    hbox1 = gtkhbox_new(homogeneous=%f,spacing=8);
  end
  selection = treeview.get_selection[];
  model = treeview.get_model[];
  selection_id= selection.connect["changed", selection_cb,list(model,hbox1)]
  
  hbox=demo_xml_combo(fname,selection,selection_id, treeview, hbox1);
  vbox.pack_start[hbox,expand=%f,fill=%t,padding=4];

  hbox=demo_xml_combo_data()
  vbox.pack_start[hbox,expand=%f,fill=%t,padding=0];
  
  vbox.pack_start[hbox1,expand=%t,fill=%t,padding=0];
  
  sw = gtkscrolledwindow_new ();
  sw.set_policy[GTK.POLICY_NEVER, GTK.POLICY_AUTOMATIC]
  sw.set_placement[GTK.CORNER_TOP_RIGHT]
  hbox1.pack_start[sw,expand=%f,fill=%f,padding=0]

  cell = gtkcellrenderertext_new ();
  col  = gtktreeviewcolumn_new (renderer=cell,attrs=hash(text= 0));
  col.set_title["Model tree"];
  treeview.append_column[col];

  // activated when we double-click on rows 
  // function row_activated_cb(args)
  //   pause  row_activated_cb
  // endfunction
  // treeview.connect[ "row-activated", row_activated_cb, list(treeview)];
  
  sw.add[treeview]
  // ----------------

  window.connect["destroy", remove_scicos_widget, list(window)];
  window.show_all[];

  // XXXX : attention a changer si on tue la fenetre
  // metre un destroy handler 
  global(initialize_modelica_running=%t);
  initialize_modelica_running=%t;
  
endfunction

function selection_cb(selection,args)
  // handler activated when a row is selected
  // in the tree view.
  // this will change the right panel
  // which is populated with a new treeview.

  function demo_empty_liststore (hbox)
    sw = gtkscrolledwindow_new();
    sw.set_shadow_type[GTK.SHADOW_ETCHED_IN]
    sw.set_policy[GTK.POLICY_NEVER,GTK.POLICY_AUTOMATIC]
    treeview = gtktreeview_new();
    // treeview.set_rules_hint[%t];
    treeview.set_search_column[3];
    sw.add[treeview];
    L=hbox.get_children[];
    if length(L)==2 then
      hbox.remove[L(2)];
    end
    hbox.pack_start[sw,expand=%t,fill=%t,padding=0]
    sw.show_all[]
  endfunction
  
  function demo_liststore (hbox,model)
    sw = gtkscrolledwindow_new();
    sw.set_shadow_type[GTK.SHADOW_ETCHED_IN]
    sw.set_policy[GTK.POLICY_NEVER,GTK.POLICY_AUTOMATIC]
    treeview = gtktreeview_new(model);
    // treeview.set_rules_hint[%t];
    treeview.set_search_column[3];
    // give name to columns
    model = treeview.get_model[];

    names=['Name','Id','Kind','Fixed','Value',...
	   'Weight','Max','Min','Nominal',...
	   'Comment','Selection', 'Fixed_orig', 'Output'];

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
	x_message("You should enter a number");
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

    // The two-last columns are ignored
    for i=1:(model.get_n_columns[]-2)

      if names(i)=='Selection' then
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
  hbox =args(2);
  iter=selection.get_selected[]
  if ~is(iter,%types.GtkTreeIter) then return;end
  if model.get_value[iter,1] then
    Tv =  model.get_value[iter,2];
  end
  // check editable and that we have a liststore 
  if model.get_value[iter,1] && type(Tv,'short')<> 'none' then
    demo_liststore(hbox,Tv);
  else
    demo_empty_liststore(hbox);
  end
endfunction

function model= demo_xml_model_from_markup(G)
  // creates a model from the markup obtained
  // with the <model>_init.xml file
  
  function name=get_node_str_attr(G,node_name,default)
    // search in node G of type Gmarkup the first subnode
    // named node_name and returns the associated attribute 'value'
    L= G.children;
    name=default;
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
      if type(elt,'short') == 'gmn' && elt.name == 'struct' then
	// elts here are supposed to be struct or terminal
	Gls = [];
	name=get_node_str(elt,'name')
	node= get_node(elt,'subnodes');
	if type(node,'short')=='gmn' then
	  Ls=collect_terminal_list(node);
	  if size(Ls(1),'*') <> 0 then
	    // convert Ls(11) to booleans
	    Ls(11) = (Ls(11) =='y');
	    Gls = gtkliststore_new(Ls);
	  end
	end
	// do not show OutPutPort or InPutPort entries
	editable = ~( strstr(name,"OutPutPort")<>0 || strstr(name,"InPutPort")<>0);
	if type(Gls,'short') == "GtkListStore" then
	  iter1 = model.append[iter,list(name,editable,list(Gls))];
	else
	  iter1 = model.append[iter,list(name,editable)];
	end
	if type(node,'short')=='gmn' then
	  demo_xml_store(model,iter1,node.children);
	end
      end
    end
  endfunction
  
  function L=collect_terminal_list(node)
    // collects the children of node of type <terminal>
    // the values are collected in L
    // L is a list of size 13 (for each terminal property)
    // and each element is a column matrix of string
    // the number of rows being the number of terminal nodes found 
    L=list()
    for i=1:13 ; L(i)=m2s([]);end
    L1=node.children;
    for i = 1:length(L1)
      elt = L1(i);
      if type(elt,'short')== 'gmn' && elt.name == 'terminal' then
	h=hash(10);
	h.name =get_node_str(elt,'name');
	h.id =get_node_str(elt,'id');
	h.kind=get_node_str(elt,'kind');
	h.fixed=get_node_str_attr(elt,'fixed',"-");
	h.initial_value=get_node_str_attr(elt,'initial_value',"");
	h.weight=get_node_str_attr(elt,'weight',"");
	h.max=get_node_str_attr(elt,'max',"");
	h.min=get_node_str_attr(elt,'min',"");
	h.nominal=get_node_str_attr(elt,'nominal',"");
	h.comment=get_node_str_attr(elt,'comment',"");
	h.selected=get_node_str_attr(elt,'selected',"");
	h.fixed_orig=get_node_str_attr(elt,'fixed_orig',"");
	h.output="";
	if type(get_node(elt,'output'),'short')== 'gmn' then h.output="out";end;
	// change values 
	if h.fixed == "" then h.fixed = "-";end
	if h.fixed_orig== "" then h.fixed_orig = h.fixed;end
	if h.weight == "" then
	  select h.fixed
	    case "true" then h.weight = "1.0" 
	    case "false" then h.weight = "0.0"
	    case {"-",""}  then h.weight= "0.0"
	  end
	  if h.kind == "fixed_parameter" then h.weight = "1.0";end
	end
	if h.selected == "" then
	  h.selected = "n";
	  if h.initial_value <> "" then h.selected = "y";end
	  if or(h.kind == ["discrete_variable","input","fixed_parameter"]) then h.selected = "y";end
	end
	if h.initial_value == "" then h.initial_value = h.nominal;end
	if h.initial_value == "" then h.initial_value = "0.0";end
	select h.fixed
	  case "true" then h.fixed = "%t";
	  case "false" then h.fixed = "%f";
	  case "" then h.fixed = "-";
	end
	l = list(h.name, h.id, h.kind, h.fixed, h.initial_value, h.weight, h.max,
		 h.min, h.nominal, h.comment, h.selected, h.fixed_orig, h.output);
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
	   'Comment','Selection','Fixed_orig', 'Output'];
    while %t then
      L=list();
      for i=1:nc
	L(i)=  tmodel.get_value[iter,i-1];
	if names(i)== 'Selection'
	  if L(i) then L(i)="y" else L(i)="n";end
	elseif names(i)== 'XXXFixed'
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
	tmodel=  model.get_value[iter1,2];
	L1=get_children(model,iter1);
	if type(tmodel,'short') == "GtkListStore" then
	  hmodel = get_terminal_obj(tmodel);
	else
	  hmodel = list();
	end
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
  
  function save_elements(fd,t_indent,L)
    for i=1:length(L)
      elt=L(i);
      indent=t_indent+"  ";
      fd.printf[indent+"<struct>\n"];
      indent=indent+"  ";
      fd.printf[indent+"<name>%s</name>\n",gmarkup_escape_text(elt(1))];
      fd.printf[indent+"<subnodes>\n"];
      // second level 
      save_elements(fd,indent,elt(3))
      terms=elt(2);
      indent=indent+"  ";
      for j=1:length(terms)
	terminal=terms(j);
	l= length(terminal);
	if l<>0 then
	  tags=["name";"kind";"id";"fixed";"initial_value";"weight";
		"max";"min";"nominal_value";"comment";"selected"];
	  fd.printf[indent+"<terminal>\n"];
	  // name
	  str=tags(1);
	  fd.printf[indent+"  <%s>%s</%s>\n",str,gmarkup_escape_text(terminal(1)),str];
	  // kind
	  str=tags(2);
	  fd.printf[indent+"  <%s>%s</%s>\n",str,gmarkup_escape_text(terminal(3)),str];
	  // id
	  str=tags(3);
	  fd.printf[indent+"  <%s>%s</%s>\n",str,gmarkup_escape_text(terminal(2)),str];
	  // fixed
	  str=tags(4);
	  value = terminal(4);
	  select value
	    case "%t" then value = "true";
	    case "%f" then value = "false";
	    case "-" then  value = "false";
	  end
	  fd.printf[indent+"  <%s value=""%s""/>\n",str,value];
	  // initial_value
	  str=tags(5);
	  value = terminal(5);
	  select value
	    case "0." then value = "0.0";
	  end
	  fd.printf[indent+"  <%s value=""%s""/>\n",str,value];
	  for k=6:l-2
	    str=tags(k);
	    fd.printf[indent+"  <%s value=""%s""/>\n",str,terminal(k)];
	  end
	  fd.printf[indent+"  <fixed_orig>%s</fixed_orig>\n",
		    gmarkup_escape_text(terminal(l-1))];
	  if terminal(l)=="out" then fd.printf[indent+"  <output/>\n"];end
	  
	  fd.printf[indent+"</terminal>\n"];
	end
      end
      indent=t_indent+"  ";
      fd.printf[indent+"  "+"</subnodes>\n"];
      fd.printf[indent+"</struct>\n"];
    end
  endfunction
  
  L=explore_model(model);
  fd=fopen(name,mode="w");
  fd.printf["<model>\n"];
  indent="  ";
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
  // count when_clauses
  count=0;
  for i=1:length(when_clauses.children)
    elt=when_clauses.children(i);
    if type(elt,'short')== 'gmn' then count=count+1;end
  end
  if count > 0 then 
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
  else
    fd.printf[indent+"<when_clauses/>\n"];
  end
  fd.printf["</model>\n"];
  fd.close[];
endfunction

function menuitem_response(w,args)
  // printf("Menu item [%s] activated \n",args(1));
  select args(1)
    case "save" then
      save_model(args(2), args(3).get_model[]);
    case "save-as" then
      // save_model(args(2), args(3).get_model[]);
      masks=['Scicos xml';'*.xml']
      fname= args(2);
      fname=xgetfile(masks=masks,save=%t,file=fname);
      save_model(fname, args(3).get_model[]);
    case "quit"
      then window=args(2); window.destroy[];
      global initialize_modelica_running;
      initialize_modelica_running=%f;
  end
endfunction

function menuitem_display_response(w,args)
  // printf("Menu item [%s] activated \n",args(1));
endfunction

function menuitem_derivatives_response(w,args)
  // printf("Menu item [%s] activated \n",args(1));
  new_mode = strsubst(tolower(args(1))," ","_");
  treeview = args(2);
  model = treeview.get_model[];

  global(need_compile=%f);
  global(der_mode="fixed_states");
  global(DispMode="Normal");
  
  if or(new_mode == ["free_fixed_states","free_steady_states"]) then return;end
  if "free_"+new_mode <> der_mode then need_compile = %t;end
  der_mode = new_mode;
  DispMode_back=DispMode;
  DispMode = "Normal";
  //     DispMode_change $WindowsID
  select der_mode
    case "fixed_states" then new_der_weight="0"; new_state_weight="1";
    case "steady_states" then new_der_weight="1"; new_state_weight="0";
  end
  //     replace_ders_in_tree $WindowsID $ztree  $RootNode $NewDerWeight $NewStateWeight
  DispMode = DispMode_back;
  der_mode = "free_"+ new_mode;
  //     DispMode_change $WindowsID
  modelica_update_model(model , new_state_weight,  new_der_weight);
endfunction

function menubar=demo_xml_menubar(fname,window,treeview)
  tearoff = %f;
  menubar = gtkmenubar_new ();
  // File Menu
  menu = gtkmenu_new ();
  if tearoff then
    menuitem = gtktearoffmenuitem_new ();
    menu.append[  menuitem]
  end
  menuitem = gtkimagemenuitem_new(stock_id="gtk-open");
  menuitem.connect["activate",menuitem_response,list("open",treeview)];
  menu.append[menuitem]
  menuitem = gtkimagemenuitem_new(stock_id="gtk-close");
  menuitem.connect["activate",menuitem_response,list("close",treeview)];
  menu.append[menuitem]
  menuitem = gtkimagemenuitem_new(stock_id="gtk-save");
  menuitem.connect["activate",menuitem_response,list("save",fname,treeview)];
  menu.append[menuitem]
  menuitem = gtkimagemenuitem_new(stock_id="gtk-save-as");
  menuitem.connect["activate",menuitem_response,list("save-as",fname,treeview)];
  menu.append[menuitem]
  menuitem = gtkimagemenuitem_new(stock_id="gtk-quit");
  menuitem.connect["activate",menuitem_response,list("quit",window)];
  menu.append[menuitem]
  
  menuitem = gtkmenuitem_new(label="File");
  menuitem.set_submenu[menu];
  menubar.append[  menuitem]
  menuitem.show[];

  //  A radio-button menu for Derivatives 
  menu = gtkmenu_new ();
  if tearoff then
    menuitem = gtktearoffmenuitem_new ();
    menu.append[  menuitem]
  end
  names=["Fixed states";"Steady states"];
  for i = 1:size(names,'*')
    if i==1 then
      menuitem = gtkradiomenuitem_new(label=names(i));
      group = menuitem;
    else
      menuitem = gtkradiomenuitem_new(group=group,label=names(i));
    end
    // callback
    menuitem.connect["activate",menuitem_derivatives_response,list(names(i), treeview)];
    menu.append[menuitem]
  end
  menuitem = gtkmenuitem_new(label="Derivatives");
  menuitem.set_submenu[menu];
  menubar.append[  menuitem]
  
  //  A radio-button menu for Display 
  menu = gtkmenu_new ();
  if tearoff then
    menuitem = gtktearoffmenuitem_new ();
    menu.append[  menuitem]
  end
  names=["Normal";
	 "Simplified model";
	 "Only Fixed items";
	 "Selected";
	 "Selected (show all)";
	 "Changed (show all)"];
  for i = 1:size(names,'*')
    if i==1 then
      menuitem = gtkradiomenuitem_new(label=names(i));
      group = menuitem;
    else
      menuitem = gtkradiomenuitem_new(group=group,label=names(i));
    end
    // callback
    menuitem.connect["activate",menuitem_display_response,list(names(i),treeview)];
    menu.append[menuitem]
    if i >=2 then menuitem.set_sensitive[%f]; end
    // if i == 4 then menuitem.set_inconsistent[ %f]; end
  end
  menuitem = gtkmenuitem_new(label="Display");
  menuitem.set_submenu[menu];
  menubar.append[  menuitem]
  // Help
  menuitem = gtkimagemenuitem_new(stock_id="gtk-help");
  menubar.append[  menuitem]
endfunction

// XXXXX attention doit etre utilisé dans load xml aussi

function [ok, explicit_vars, implicit_vars, parameters]=scicos_read_incidence(fname)
  // <model>
  // 	<identifiers>
  // 		<implicit_variable>Lorentz_.__der_Z.[4]</implicit_variable>
  // 		<implicit_variable>Lorentz_.__der_Y.[4]</implicit_variable>
  //             ..... 
  // 	</identifiers>
  // </model>
  ok=%f;
  explicit_vars=m2s([]);
  implicit_vars=m2s([]);
  parameters=m2s([]); 
  G=gmarkup(fname,clean_strings=%t);
  pause gmarkup ;
  if G.name <> "model" then ok=%f;return;end
  L= G.children;
  subnodes=list();
  for i=1:length(L)
    elt = L(i);
    if type(elt,'short') == 'gmn' && elt.name == "identifiers"  then
      subnodes= elt.children;
    end
  end
  for i=1:length(subnodes)
    elt = subnodes(i);
    if type(elt,'short') == 'gmn' then
      str = elt.children(1);
      select elt.name
	case "parameter" then parameters.concatd[str];
	case "explicit_variable" then explicit_vars.concatd[str];
	case "implicit_variable" then implicit_vars.concatd[str];
      end
    end
  end
  ok=%t;
endfunction

function modelica_update_model(model, new_state_weight,  new_der_weight);
  // update state and state derivatives with new_state_weight,  new_der_weight
  // this is activated when
  // loading date + changing the menu derivatives
  
  function S=model_terminal_names(model)
    // collect the terminal names in model
    // which is the column 2 in terminal obj
    S=m2s([]);
    iter=model.get_iter_first[0];
    // name=model.get_value[iter,0];
    if model.iter_has_child[iter] then
      iter1=model.iter_children[iter];
      // printf("Exploring %s\n",model.get_value[iter1,0]);
      while %t 
	if model.iter_has_child[iter1] then
	  iter2=model.iter_children[iter1];
	  while %t  then
	    name=model.get_value[iter2,0];
	    S.concatd[name];
	    if ~model.iter_next[iter2] then break;end
	  end
	end
	if ~model.iter_next[iter1]  then break;end
      end
    end
    I=find(strstr(S,"__der_")<>0);
    if ~isempty(S) then S=S(I);  S=strsubst(S,"__der_","");end
  endfunction

  function model_update_states_or_der(model,names,newval,tag)

    function model_update_fixed(model,iter)
      // if weight (col 5) is 1.0 we update fixed(col 3) depending on kind
      if or(model.get_value[iter, 2]==[ "fixed_parameter", "variable"]) then
	if abs(evstr(model.get_value[iter,5])-1) < 1.e-8 then 
	  model.set[iter,3,"%t"];
	else
	  model.set[iter,3,"%f"];
	end
      end
    endfunction
    
    function model_update_terminal(model, newval,tag)
      nc=model.get_n_columns[]
      iter=model.get_iter_first[0];
      if tag == "der" then
	// updates weight for derivatives
	while %t do
	  if abs(evstr(newval) - 1.0) < 1.e-8 then model.set[iter,4,"0.0"];end
	  model.set[iter,5,newval];
	  model_update_fixed(model,iter)
	  if ~model.iter_next[iter] then break;end
	end
      else
	// updates weight for states 
	while %t do
	  if model.get_value[iter, 11] == "-" then  model.set[iter,5,newval];end
	  model_update_fixed(model,iter)
	  if ~model.iter_next[iter] then break;end
	end
      end
    endfunction

    if tag == "der" then names = "__der_" +names;end 
    
    iter=model.get_iter_first[0];
    // name=model.get_value[iter,0];
    if model.iter_has_child[iter] then
      iter1=model.iter_children[iter];
      // printf("Exploring %s\n",model.get_value[iter1,0]);
      while %t 
	if model.iter_has_child[iter1] then
	  iter2=model.iter_children[iter1];
	  while %t  then
	    name=model.get_value[iter2,0];
	    if or(name == names) then
	      model_update_terminal(model.get_value[iter2,2],newval,tag);
	    end
	    if ~model.iter_next[iter2] then break;end
	  end
	end
	if ~model.iter_next[iter1]  then break;end
      end
    end
  endfunction
  S=model_terminal_names(model);
  model_update_states_or_der(model,S,new_state_weight , "state");
  model_update_states_or_der(model,S,new_der_weight, "der");
endfunction

function Compute_finished(ok)
  // to be removed and dispatched
  if ok then
    // Compute finished with succes
    printf("Finished solve with success\n");
    
    // puts "XXX: In Compute_finished with ok"
    // set ierror $sciGUITable(win,$WindowsID,data,IERROR)
    // $w.buttons.error configure -text "$ierror"
    
    // Update_Selected_in_tree  $WindowsID "Write" 	  
    // set oldnode [$ztree selection get]
    // remove_from_tree $WindowsID  $Active_Model; 
    
    // set Model_name [string range $Active_Model  4 end]     
    // set init "_init"
    // set ext ".xml"; 
    // set tmpdir "$sciGUITable(win,$WindowsID,data,SCI_TMPDIR)"  
    // set sciGUITable(win,$WindowsID,data,Scixmlfile) "$tmpdir/$Model_name$init$ext" 
    // button_OpenXML  $WindowsID
    
    // clickTree $WindowsID $oldnode 
    // $ztree selection set $oldnode  
    // open_parent $oldnode
    
 else
   // puts "XXX: In Compute_finished with not ok"
   // set msg1 "The selected numerical solver failed to convere."
   // set msg2 "\nYou can try again either selecting another solver or generating a code with the analytical Jacobian."
   // set msg3 "\nThe analytical Jacobian can be activated in the <Code generation> menu."
   // tk_messageBox -icon info -type ok -title "Simulation failure"  -message "$msg1$msg2$msg3"	
   //  }
   //  #if { $res eq "nok"  } { # general computing problem    }
   //  #if { $res eq "noki" } { # when the model is not square    }
   //  #if { $res eq "nokc" } { # error in compile of the initialization model; compile_init_modelica.sci  }
   //  #if { $res eq "nok1" } { # bad model   }
   //  #if { $res eq "nok2" } { # mixed Scicos/Modelica models   }
   //  $w.buttons.compute configure -state active
   //  $w.buttons.compute configure -text "Solve"
   //
  end
endfunction

function callback_solve(button,args)
  // call back of the solve button
  // calls compile_init_modelica
  // Compute_cic
  // Then it reloads the xml files
  fname = args(1);
  treeview = args(2);
  hbox = args(3)
  model = treeview.get_model[];
  selection_id = button.get_data['selection_id'];
  selection = button.get_data['selection'];
  
  save_model(fname,model);
  ok = compile_init_modelica(name+'f',paremb=0,jaco='0');
  // build incidence matrix file name 
  tmpdir =file('split',getenv('NSP_TMPDIR'));
  im_fname =file('join',[tmpdir;name+'fi_incidence_matrix.xml']);
  // XXXX check that im_fname exists 
  [ok, explicit_vars, implicit_vars, parameters]=scicos_read_incidence(im_fname)
  number_unknowns = size(implicit_vars,'*');
  // XXX get the method selected in menus 
  method="Kinsol";Compute_cic(method,number_unknowns);
  // reload the xml file
  G=gmarkup(fname);
  model= demo_xml_model_from_markup(G);
  selection.disconnect[selection_id];
  treeview.set_model[model=model];
  selection_id=selection.connect["changed", selection_cb,list(model,hbox)];

  button.set_data[selection_id = selection_id ];
  button.set_data[selection = selection ];
  
endfunction

function hbox=demo_xml_combo(fname,selection,selection_id, treeview, hbox1)
  // combo box for toplevel solve button
  // 
  hbox = gtk_box_new("horizontal");
  cellview = gtk_cell_view_new(text="Solver: ");
  hbox.add[cellview];
  //-- combo 
  names=["Kinsol";"Ida (init)";"Fsolve";"Optim"];
  n = size(names,'*');
  bools=ones(n,1)>=0;
  model = gtk_list_store_new(list(names,bools));
  combobox = gtk_combo_box_new(model=model);
  //XXX combobox.set_add_tearoffs[%t];
  cell_renderer = gtk_cell_renderer_text_new ();
  combobox.pack_start[ cell_renderer,expand= %t];
  combobox.add_attribute[cell_renderer,"text",0];
  combobox.set_active[0];
  hbox.add[combobox];
  //-- button
  button = gtk_button_new(mnemonic="Solve");
  button.set_data[selection_id = selection_id ];
  button.set_data[selection = selection ];
  button.connect[ "clicked", callback_solve, list(fname, treeview, hbox1)];
  hbox.add[button];
endfunction

function hbox=demo_xml_combo_data()
  // combo texts to display informations
  // about variables
  hbox = gtk_box_new("horizontal");
  names=["Equations";
	 "Unknowns"    
	 "Reduced"     
	 "Diff Ste"    
	 "Fixed Par"   
	 "Relxd Par"   
	 "Fixed Var"   
	 "Relxd Var"   
	 "Discret"     
	 "Input"];
  for i=1:size(names,'*')
    // cellview = gtk_cell_view_new(text=names(i));
    // hbox.add[cellview];
    tmp1 = gtk_frame_new (label=names(i));
    hbox.pack_start[ tmp1,expand=%t,fill=%t,padding=6]
    boom =gtk_box_new("vertical",spacing=0);
    boom.set_border_width[1];
    tmp1.add[boom];
    markup = " ";//<span foreground=''blue''>bleue</span>";
    cellview = gtk_cell_view_new (markup=markup);
    boom.add[cellview];
  end
endfunction

function get_model_info()
  square = NEQ == NVAR
  Unknowns=$NVAR // NVAR = $NPL+$NVL+$NDIS;
  Fixed_Par=$NPF// kind == fixed_parameter & weight == 1 
  Relxd_Par=$NPL // kind == fixed_parameter & $weight != 1
  Fixed_Var=$NVF //  kind == variable & $weight == 1 
  Relxd_Var=$NVL//  kind == variable & $weight != 1 
  Discrete=$NDIS //  kind == discrete_variable
  Input=$NIN //  kind == input
  Diff_St=$NDIF //  [regexp {__der_(\w*)} Id ]
endfunction
