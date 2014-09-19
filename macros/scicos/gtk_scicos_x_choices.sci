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

  //entrykeymouse : bind the entries for keyboard/mouse event
  function [y]=entrykeymouse(wid,event,args)
    scrollbar  = wid.user_data(2)
    adjustment = scrollbar.get_adjustment[]
    curpos     = wid.get_position[]
    wchar      = wid.get_width_chars[]
    len        = wid.get_text_length[]
    b          = wid.user_data(1)
    if len>wchar then
      scrollbar.show[]
      adjustment.upper     = len
      adjustment.page_size = wchar
      if b>len then b=len end
      a=b-wchar
      if curpos<a then
        a=curpos
        b=curpos+wchar
      elseif curpos>b then
        b=curpos
        a=curpos-wchar
      end
      adjustment.value = a
      wid.user_data(1) = b
    else
      scrollbar.hide[]
    end
    if type(event,'string')=='GdkEvent' then
      if event.type==GDK.KEY_RELEASE then
        if gdk_keyval_name[event.keyval]=='Return' | ...
           gdk_keyval_name[event.keyval]=='KP_Enter' then
          entries=args(1)
          button_ok=args(2)
          n=length(entries)
          i=get_current_entry(entries,wid)
          if (i+1)<=n then
            set_focus(entries(i+1))
          else
            set_focus(button_ok)
          end
        end
      end
    end
    y=%f
  endfunction

  //GetFrameEntry : 
  // Li : initial list
  // entries : list of widgets
  function [entries]=GetFrameEntry(Li,vbox)

    entries=list()
    labels=list()
    n=length(Li)
    width_entry=35 //nb chars
    width_labels=[] //pixels
    //font_desc = pangofontdescription_new("Arial 10");

    for i=1:n
      label = gtklabel_new(str=Li(i)(2));
      //label.modify_font[font_desc]
      label.set_justify[GTK.JUSTIFY_LEFT]
      label.set_alignment[0,0.5]
      labels(i)=label
      width_labels(i)=label.size_request[](1)
      //label.set_size_request[260,-1]

      if Li(i)(1)=='entry' then
        entry = gtkentry_new();
        entry.set_width_chars[width_entry]
        entry.set_text[Li(i)(4)]
        //entry.modify_font[font_desc]
        adjustment=gtkadjustment_new(value=0,lower=0,upper=0,step_incr=1,page_incr=1,page_size=30)
        scrollbar=gtkhscrollbar_new(adjustment=adjustment)
        scrollbar.set_update_policy[GTK.UPDATE_CONTINUOUS]
        scrollbar.set_no_show_all[%t]
        //store width and scrollbar widget in entry user_data
        entry.user_data=list(width_entry,scrollbar)
        table_entry=gtktable_new(rows=2,columns=2,homogeneous=%f)
        table_entry.attach[label, 0, 1, 0, 1,xoptions=0]
        table_entry.attach[entry, 1, 2, 0, 1]
        table_entry.attach[scrollbar, 1, 2, 1, 2]
        table_entry.set_col_spacings[2]
        table_entry.queue_resize[]
        vbox.pack_start[table_entry,expand=%t,fill=%f,padding=0]
        entries(i)=entry
      elseif Li(i)(1)=='combo' then
        combo=gtkcombobox_new(text=Li(i)(4))
        combo.set_active[Li(i)(3)-1]
        //combo.modify_font[font_desc]
        table_entry=gtktable_new(rows=1,columns=2,homogeneous=%f)
        table_entry.attach[label, 0, 1, 0, 1,xoptions=0]
        table_entry.attach[combo, 1, 2, 0, 1]
        vbox.pack_start[table_entry,expand=%t,fill=%f,padding=0]
        entries(i)=combo
      end
    end

    //adjust label width
    width_label=min(max(width_labels),270)
    for i=1:n
      labels(i).set_line_wrap[%t]
      labels(i).set_size_request[width_label,-1]
    end
  endfunction

  function L=get_results(entries)
    L=list()
    for i=1:length(entries)
      if type(entries(i),'string')=='GtkEntry' then
        L(i)=entries(i).get_text[]
      elseif type(entries(i),'string')=='GtkComboBox' then
        L(i)=entries(i).get_active[]+1
      end
    end
  endfunction

  function modified=is_modified(entries,Li)
    modified=%f
    for i=1:length(entries)
      if type(entries(i),'string')=='GtkEntry' then
        if entries(i).get_text[]<>Li(i)(4) then
          modified=%t
          break
        end
      elseif type(entries(i),'string')=='GtkComboBox' then
        if (entries(i).get_active[]+1)<>Li(i)(3) then
          modified=%t
          break
        end
      end
    end
  endfunction

  F=get_current_figure();
  gh=nsp_graphic_widget(F.id);

  window = gtkwindow_new();//GTK.WINDOW_TOPLEVEL);
  //window.modify_bg[GTK.STATE_NORMAL,gdk_color_parse("light grey")]
  window.set_border_width[0]

  vbox = gtkvbox_new(homogeneous=%f,spacing=0);
  vbox.set_border_width[3]
  window.add[vbox]

  //title widget
  event_box=gtkeventbox_new ();
  label = gtklabel_new(str=strcat(desc,"\n"));
  //font_desc=pangofontdescription_new("Arial 10");
  //label.modify_font[font_desc]
  event_box.modify_bg[GTK.STATE_NORMAL,gdk_color_parse("white")]
  event_box.add[label]
  vbox.pack_start[event_box]

  //notebook widget
  notebook = gtknotebook_new()
  notebook.set_tab_pos[GTK.POS_TOP];
  //notebook.modify_bg[GTK.STATE_NORMAL,gdk_color_parse("light grey")]
  vbox.pack_start[notebook,padding=3]
  vbox2 = gtkvbox_new(homogeneous=%f,spacing=2);
  vbox2.set_border_width[2]

  [entries]=GetFrameEntry(Li,vbox2)

  typv=""
  if exists('%scs_help') then
    if ~isempty(%scs_help) then
      typv=%scs_help
    end
  end

  if typv=="Setup_Scicos" then
    titlewin="Scicos Simulator Parameters"
  elseif typv=="Rename" then
    titlewin="Rename"
  elseif typv=="Setup_CodeGen" then
    titlewin="Set Code Generation Properties"
  elseif typv=="Resize_block" then
    titlewin="Set Block Size"
  elseif typv=="Resize_link" then
    titlewin="Set Link Properties"
  elseif typv=="Ident_block" then
    titlewin="Set Block Identification"
  elseif typv=="Ident_link" then
    titlewin="Set Link Identification"
  elseif typv=="Label_block" then
    titlewin="Set Block Label"
  elseif typv=="Grid" then
    titlewin="Set Grid Parameters"
  elseif typv=="scicos_debug" then
    titlewin="Set Debug Level"
  else 
    titlewin="Set Block properties"
  end
  
  window.set_title[titlewin]
  //user_data store if entries have been modified
  window.user_data=%f

  if ~typv.equal[""] then
    label = gtklabel_new(str=typv);
  else
    label = gtklabel_new(str="Getvalue");
  end
  //label.modify_font[font_desc]
  notebook.append_page[vbox2,label];

  //Buttons bar
  function []=HelpButton(wid,args)
    hbox=args(1)
    hbox.user_data=1
    gtk_main_quit()
  endfunction

  function []=OkButton(wid,args)
    hbox=args(1)
    hbox.user_data=2
    gtk_main_quit()
  endfunction

  function []=CancelButton(wid,args)
    hbox=args(1)
    hbox.user_data=3
    gtk_main_quit()
  endfunction

  hbox=gtkhbuttonbox_new()
  hbox.user_data=0
  vbox.pack_start[hbox,expand= %f,fill=%t,padding=2]
  button_help=gtkbutton_new(stock="gtk-help")
  button_help.connect["clicked",HelpButton,list(hbox)]
  hbox.pack_start[button_help]
  button_ok=gtkbutton_new(stock="gtk-ok")
  hbox.pack_start[button_ok]
  hbox.set_child_secondary[button_ok,%t]
  button_ok.set_flags[GTK.CAN_DEFAULT]
  button_ok.grab_default[]
  button_ok.connect["clicked",OkButton,list(hbox)]
  button_cancel = gtkbutton_new(stock="gtk-cancel")
  hbox.pack_start[button_cancel]
  hbox.set_child_secondary[button_cancel,%t]
  button_cancel.connect["clicked",CancelButton,list(hbox)]
  hbox.set_layout[3]

  function [y]=DestroyFunc(wid,event,args)
    hbox=args(1)
    hbox.user_data=-4
    gtk_main_quit()
    y=%t
  endfunction

  function ChangedFunc(wid,data)
    entries=data(1)
    Li=data(2)
    window=data(3)
    titlewin=window.get_title[]
    modified=is_modified(entries,Li)

    if modified then
      if ~window.user_data then
        window.set_title[titlewin + ' [edited]']
      end
    else
      if window.user_data then
        window.set_title[strsubst(titlewin,' [edited]','')]
      end
    end
    window.user_data=modified

  endfunction

  //bind gtkentry
  for i=1:length(entries)
    if Li(i)(1)=='entry' then
      entries(i).connect["key-release-event",entrykeymouse,list(entries,button_ok)]
      entries(i).connect["key-press-event",entrykeymouse,list(entries,button_ok)]
    end
    if type(entries(i),'string')=='GtkEntry' then
      entrykeymouse(entries(i),'toto')
    end
    entries(i).connect["changed",ChangedFunc,list(entries,Li,window)]
  end
  hbox.set_border_width[0]
  window.connect["delete-event",DestroyFunc,list(hbox)];
  window.set_transient_for[gh]
  if %win32 then
    window.set_type_hint[GDK.WINDOW_TYPE_HINT_DIALOG]
  else
    window.set_type_hint[GDK.WINDOW_TYPE_HINT_MENU]
  end
  window.show_all[];
  window.present[]
  set_focus(entries(1))

  //main loop
  ok=%f

  while ~ok
    gtk_main()
    response=hbox.user_data;

    //get results
    L=get_results(entries)

    //check modified
    modified=window.user_data

    if response==1 then
      if exists('%scs_help') then
        cos_help(%scs_help)
      else
        cos_help('whatis_scicos')
      end
    elseif response==2 then
      if modified then
        //printf("Warning modified. TODOCHECK\n");
        ok=%t
      else
        ok=%t
      end
    elseif response==3 then
      L=list()
      ok=%t
    elseif response==-4 then
      if modified then
        num=0
        while num==0
          num=message([" Modifications have not been committed.";...
                       "Do you really want to close the window ?"],...
                       ['Yes','No']);
        end
        if num==1 then
          L=list()
          ok=%t
        end
      else
        L=list()
        ok=%t
      end
    end
  end
  window.destroy[];
  nsp_clear_queue();
endfunction
