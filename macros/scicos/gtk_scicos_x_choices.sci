function L=gtk_scicos_x_choices(desc,Li)
// used in gtk_getvalue
// see getvalue for parameters description
  function []=set_focus(wid)
    wid.grab_focus[]
    if type(wid,'string')=='GtkEntry' then
      wid.set_position[wid.get_text_length[]]
    end
  endfunction

  function i=get_current_entry(entries,entry)
    for i=1:length(entries)
      if entries(i).equal[entry] then break, end
    end
  endfunction

  function [table,entries]= create_main_table(dialog,Li)
  // build a table or a grid 
    entries=list()
    labels=list()
    n=length(Li)
    
    for i=1:n
      label = gtklabel_new(str=Li(i)(2));
      //label.modify_font[font_desc]
      if exists('gtk_get_major_version','function') then
	label.set_halign [ GTK.ALIGN_START];
      else
	label.set_justify[GTK.JUSTIFY_LEFT]
	label.set_alignment[0,0.5];
      end
      // label.set_line_wrap[%t]
      labels(i)=label;
      if Li(i)(1)=='entry' then
        entry = gtkentry_new();
        entry.set_text[Li(i)(4)]
	if exists('gtk_get_major_version','function') then
	  entry.set_hexpand[%t];
	end
        //store width and scrollbar widget in entry user_data
	entries(i)=entry
      elseif Li(i)(1)=='combo' then
        combo=gtkcombobox_new(text=Li(i)(4))
        combo.set_active[Li(i)(3)-1]
	entries(i)=combo
      end
      entries(i).connect["changed",changed_callback,list(Li(i),dialog)];
    end
    
    if exists('gtk_get_major_version','function') then
      table=gtk_grid_new();
      table.set_hexpand[%t];
      // table.set_column_homogeneous[%t];
      table.set_border_width[5];
      table.set_row_spacing [ 2];
      table.set_column_spacing [5];
      for i=1:n
	table.attach[labels(i), 0, i-1, 1, 1]
	table.attach[entries(i), 1, i-1, 1, 1]
      end
    else
      table=gtktable_new(rows=n,columns=2,homogeneous=%f)
      table.set_col_spacings[5]
      for i=1:n
	table.attach[labels(i), 0, 1, i-1, i,xoptions=0];
	table.attach[entries(i), 1, 2, i-1 , i];
      end
    end 
  endfunction
  
  function L=get_results(entries)
    L=list()
    for i=1:length(entries)
      typ = type(entries(i),'string');
      if typ =='GtkEntry' then
        L(i)=entries(i).get_text[]
      elseif typ =='GtkComboBox' || typ == 'GtkComboBoxText' then
        L(i)=entries(i).get_active[]+1
      end
    end
  endfunction
  
  function modified=is_modified(entries,Li)
    L=get_results(entries);
    modified = ~Li.equal[L];
  endfunction
  
  function [title,typv]=get_title()
    typv=acquire('%scs_help',def='unknown');
    T=["Setup_Scicos","Scicos Simulator Parameters";
       "Rename" ,"Rename";
       "Setup_CodeGen" ,"Set Code Generation Properties";
       "Resize_block" ,"Set Block Size";
       "Resize_link" ,"Set Link Properties";
       "Ident_block" ,"Set Block Identification";
       "Ident_link" , "Set Link Identification";
       "Label_block" ,"Set Block Label";
       "Grid" ,"Set Grid Parameters";
       "scicos_debug" ,"Set Debug Level";
       "unknown", "Set Block properties"];
    I=find(T(:,1)==typv);
    if isempty(I) then title="Set Block properties";
    else title=T(I,2);
    end
  endfunction
  
  function []=button_callback(wid,args)
    dialog=args(1);
    dialog.user_data=args(2);
    gtk_main_quit()
  endfunction
  
  function []=delete_callback(wid1,wid2,args)
    dialog=args(1);
    dialog.user_data=args(2);
    gtk_main_quit()
  endfunction
  
  function changed_callback(entry,data)
    typ = type(entry,'string');
    if typ == 'GtkEntry' then
      Li=entry.get_text[]
    elseif typ =='GtkComboBox' || typ == 'GtkComboBoxText' then
      Li=entry.get_active[]+1
    end
    if ~Li.equal[data(1)]  then 
      modifier = '[edited]';
      title= dialog.get_title[];
      if strstr(title,modifier) == 0 then 
	dialog.set_title[dialog.get_title[]+ ' ' + modifier];
      end
    end
  endfunction

  // main code 
  // ---------------
  
  F=get_current_figure();
  gh=nsp_graphic_widget(F.id);
  
  // main window 
  dialog = gtkwindow_new();// type=GTK.WINDOW_POPUP);
  dialog.set_border_width[0];
  H=hash(Ok=1,Cancel=2,Help=3,Void=-1);
  dialog.user_data= H.Void;
  
  [title,tag]=get_title();
  dialog.set_title[title];
  
  if exists('gtk_get_major_version','function') then
    dialog.set_vexpand[%f];    
    vbox = gtk_box_new (GTK.ORIENTATION_VERTICAL);
    vbox.set_hexpand[%t];
    vbox.set_vexpand[%f];
  else
    vbox = gtkvbox_new ();
  end
  vbox.set_border_width[5];
  dialog.add[vbox,expand= %f,fill=%t];

  //1- title
  label = gtklabel_new(str=strcat(desc,"\n"));
  vbox.pack_start[label, expand=%f,fill=%t];
  //2- contents 
  [table,entries]= create_main_table(dialog,Li);
  if tag.equal["unknown"] then
    page_label="Getvalue"
  else
    page_label=tag;
  end
  //2- notebook widget or frame 
  if %t then 
    frame= gtkframe_new(label=page_label);
    frame.add[table];
    vbox.pack_start[frame, expand=%f,fill=%t,padding=3]
  else
    notebook = gtknotebook_new()
    notebook.set_tab_pos[GTK.POS_TOP];
    label = gtklabel_new(str=page_label);
    notebook.append_page[table,label];
    vbox.pack_start[notebook, expand=%f,fill=%t,padding=3]
  end 
  
  if exists('gtk_get_major_version','function') then
    hbox=gtk_button_box_new(GTK.ORIENTATION_HORIZONTAL);
    hbox.set_hexpand[%t];
    hbox.set_vexpand[%f];
    hbox.user_data=0
    vbox.pack_start[hbox,expand= %f,fill=%t,padding=2]
    button_help=gtkbutton_new(label="Help")
    hbox.pack_start[button_help]
    button_cancel = gtkbutton_new(label="Cancel")
    hbox.pack_start[button_cancel]
    hbox.set_child_secondary[button_cancel,%t]
    button_ok=gtkbutton_new(label="Ok")
    button_ok.grab_default[]
    hbox.pack_start[button_ok]
    hbox.set_child_secondary[button_ok,%t]
  else
    hbox=gtkhbuttonbox_new();
    hbox.user_data=0
    vbox.pack_start[hbox,expand= %f,fill=%t,padding=2]
    button_help=gtkbutton_new(stock="gtk-help")
    // button_help.connect["clicked", help_calback,list(dialog)]
    hbox.pack_start[button_help]
    button_cancel = gtkbutton_new(stock="gtk-cancel")
    hbox.pack_start[button_cancel]
    hbox.set_child_secondary[button_cancel,%t]
    button_ok=gtkbutton_new(stock="gtk-ok")
    button_ok.set_flags[GTK.CAN_DEFAULT]
    button_ok.grab_default[]
    hbox.pack_start[button_ok]
    hbox.set_child_secondary[button_ok,%t]
  end
  
  button_help.connect["clicked", button_callback,list(dialog,H.Help)];
  button_cancel.connect["clicked",button_callback,list(dialog,H.Cancel)];
  button_ok.connect["clicked",button_callback,list(dialog,H.Ok)];
  dialog.connect["delete-event",delete_callback,list(dialog,H.Cancel)];
  
  F=get_current_figure();
  gh=nsp_graphic_widget(F.id);
  dialog.set_transient_for[gh];
  set_focus(entries(1));
  dialog.show_all[];
  help_item= acquire('%scs_help',def='whatis_scicos');    
		 
  while %t then 
    gtk_main();
    select dialog.user_data
     case H.Help then cos_help(help_item);
     case H.Cancel then L=list();ok=%t;  dialog.destroy[];break;
     case H.Ok then L=get_results(entries); ok=%t; dialog.destroy[];break;
    end
  end
  nsp_clear_queue();
endfunction
