function [btn,%pt,win,Cmenu]=cosclick()

  //build a windows tooltip for blk when mouse pointer
  //is above a block
  function win_tooltip=build_block_tooltip(o)
    if %win32 then
      win_tooltip = gtkwindow_new(type=1)
      win_tooltip.set_type_hint[GDK.WINDOW_TYPE_HINT_TOOLTIP]
    else
      win_tooltip = gtkwindow_new()
      F=get_current_figure();
      gh=nsp_graphic_widget(F.id)
      win_tooltip.set_transient_for[gh]
      win_tooltip.set_resizable[%f]
      win_tooltip.set_decorated[%f]
      win_tooltip.set_skip_taskbar_hint[%t]
      win_tooltip.set_skip_pager_hint[%t]
      win_tooltip.set_accept_focus[%f]
    end
    win_tooltip.set_data[id=0];
    win_tooltip.set_data[id2=0];
    // win_tooltip.get_root_window is deprecated 
    // screen=win_tooltip.get_root_window[]
    // pos=screen.get_pointer[]
    screen = gdk_screen_get_default();
    root = screen.get_root_window[];
    pos= root.get_pointer[];
    win_tooltip.move[pos(1)+10,pos(2)+10]
    if exists('gtk_get_major_version','function') then
      hbox=gtk_box_new(GTK.ORIENTATION_HORIZONTAL);
    else
      hbox=gtkhbox_new();
    end
    color= gdk_color_parse("black")
    event_box_fg = gtkeventbox_new();
    if ~exists('gtk_get_major_version','function') then
      event_box_fg.modify_bg[GTK.STATE_NORMAL,color]
    end
    event_box_bg = gtkeventbox_new()
    event_box_bg.set_border_width[1]
    //     color=gdk_color_parse("#F6F6B9")
    //     event_box_bg.modify_bg[GTK.STATE_NORMAL,color]
    event_box_fg.add[event_box_bg]
    label = gtklabel_new(str=o.gui)
    if ~exists('gtk_get_major_version','function') then
      label.set_padding[3,1]
    end
    event_box_bg.add[label]
    hbox.pack_start[event_box_fg,expand=%f,fill=%f,padding=0]
    win_tooltip.add[hbox]
    if %win32 then
      if ~exists('gtk_get_major_version','function') then
	color=gdk_color_parse("#FFFFCA")
	event_box_bg.modify_bg[GTK.STATE_NORMAL,color]
      end
      //       win_tooltip.grab_focus[%f]
      //       win_tooltip.set_focus_on_map[%f]
      //       win_tooltip.show_all[]
      //       win_tooltip.hide[]
    end
  endfunction
  
  //callback to show the tooltip
  function y=show_block_tooltip(args)
    win_tooltip=args(1)
    screen = gdk_screen_get_default();
    root = screen.get_root_window[];
    pos= root.get_pointer[];
    // pos=screen.get_pointer[]
    win_tooltip.move[pos(1)+10,pos(2)+10]
    win_tooltip.show_all[];
    win_tooltip.set_data[id=0];
    y=%f
  endfunction

  //callback to add extra info in the tooltip
  function y=add_extra_info_tooltip(args)
    win_tooltip=args(1)
    o=args(2)
    hbox=win_tooltip.get_children[](1)
    event_box_fg=hbox.get_children[](1)
    event_box_bg=event_box_fg.get_children[](1)
    label=event_box_bg.get_children[](1)
    str=mini_standard_document(o);
    if %win32 then
      str=strsubst(str,'<small><small>','<small>');
      str=strsubst(str,'</small></small>','</small>');
    end
    label.set_markup[catenate(str,sep="\n")];
    win_tooltip.set_data[id2=0];
    y=%f
  endfunction

  //destroy block tooltip
  function win_tooltip=destroy_block_tooltip(win_tooltip)
    if ~win_tooltip.equal[[]] then
      id = win_tooltip.get_data["id"];
      remove_timeout(id);
      id = win_tooltip.get_data["id2"];
      remove_timeout(id);
      win_tooltip.destroy[]
      win_tooltip=[]
    end
  endfunction

  //remove timeout event source tooltip
  function remove_timeout(id)
    if id.equal[[]] || id.equal[0] then return;end
    if exists('gtk_get_major_version','function') then
      g_source_remove(id);
    else
      gtk_timeout_remove(id);
    end
  endfunction
    
  //unhilite hilited port
  function port_hilited=unhilite_port(gr_port,port_hilited)
    if port_hilited then
      F=get_current_figure()
      F.remove[gr_port]
      F.invalidate[];
      port_hilited=%f
      xcursor(GDK.CROSSHAIR)
    end
  endfunction

  //detect mouse position in corners
  //of the bbox of the selected block
  function [corner]=nearest_tl_br_corner(%pt,o,kk,Select)

    function [data]=get_data_corner(xy,pt,sz)
      data=[(xy(1)-pt(1))*(xy(1)+sz-pt(1)),..
            (xy(2)-sz-pt(2))*(xy(2)-pt(2))]
    endfunction

    corner=[]
    if ~isempty(Select) then
      if size(Select,1)==1 && ~isempty(find(Select(:,1)==kk)) then
        bbox=o.gr.get_bounds[]
        sz=10 //??

        //top left
        data=get_data_corner([bbox(1);bbox(4)],%pt,sz)
        if data(1)<0 && data(2)<0 then
          corner='tl'
          return
        end

        //bottom right
        [data]=get_data_corner([bbox(3);bbox(2)],%pt,-sz)
        if data(1)<0 && data(2)<0 then
          corner='br'
          return
        end

      end
    end
  endfunction

  //unhilite resizable block
  function [c_hilited]=unhilite_cblock(gr_block,c_hilited,htype,hsize)
    if c_hilited then
      gr_block.hilite_type=htype
      gr_block.hilite_size=hsize
      gr_block.invalidate[]
      xcursor(GDK.CROSSHAIR)
      c_hilited=%f
    end
  endfunction

  //hilite resizable block
  function [c_hilited]=hilite_cblock(gr_block,corner)
    gr_block.hilite_type=1
    gr_block.hilite_size=-1
    gr_block.invalidate[]
    c_hilited=%t
    if corner=='tl' then
     xcursor(GDK.TOP_LEFT_CORNER)
    elseif corner=='br' then
     xcursor(GDK.BOTTOM_RIGHT_CORNER)
    end
  endfunction

// select action from an activated event
//
  global Scicos_commands
  global scicos_dblclk

  Cmenu_orig=Cmenu
  Cmenu="";%pt=[];btn=0;
  if ~or(winsid()==curwin) then  win=xget('window');Cmenu='Quit',return,end
  enablemenus();

  if isempty(scicos_dblclk) then
    xcursor(GDK.CROSSHAIR)
    btn=-1

    win_tooltip=[];
    port_hilited=%f;
    c_hilited=%f;
    gr_block=[];
    htype=[];hsize=[];hcolor=[];
    gr_port=[];
    kk_last=[];

    //new : motion event loop (Alan,30/05/13)
    while %t
      //switch getmotion to %f to not show the tooltip
      [btn,xc,yc,win,str]=xclick(getkey=%t,cursor=%f,getmotion=%t)
      // [id,id2]=remove_timeout(id,id2)
      win_tooltip=destroy_block_tooltip(win_tooltip)

      if (btn~=-1) then
        port_hilited=unhilite_port(gr_port,port_hilited)
        win_tooltip=destroy_block_tooltip(win_tooltip)
        unhilite_cblock(gr_block,c_hilited,htype,hsize)
        break
      else
        if win==curwin then
          str_pt= sprintf("[%.2f,%.2f]",xc,yc);
          xinfo(str_pt); //display mouse position
          kk=getblock(scs_m,[xc;yc]);
          if ~isempty(kk) then
            if isempty(kk_last) then kk_last=kk, end
            [connected,xyo,typo,szout,szouttyp,from]=getportblk(scs_m.objs(kk),kk,'from',[xc,yc])
            cedge=check_edge(scs_m.objs(kk),'inside',[xc,yc])
            if ~connected && cedge=='Link' && size(Select,1)<=1 then
              win_tooltip=destroy_block_tooltip(win_tooltip)
              c_hilited=unhilite_cblock(gr_block,c_hilited,htype,hsize)
              if ~port_hilited then
                xcursor(GDK.PENCIL)
                gr_port=hilite_port(xyo(1),xyo(2),scs_m.objs(kk))
                port_hilited=%t
              end
            elseif cedge=='inside'
              port_hilited=unhilite_port(gr_port,port_hilited)
              corner=nearest_tl_br_corner([xc,yc],scs_m.objs(kk),kk,Select)
              if ~isempty(corner) then
                if ~(scs_m.objs(kk).gui=="IMPSPLIT_f" || scs_m.objs(kk).gui=="SPLIT_f" ||...
                     scs_m.objs(kk).gui=="BUSSPLIT"   || scs_m.objs(kk).gui=="CLKSPLIT_f") then
                  if ~c_hilited then
                    gr_block=scs_m.objs(kk).gr
                    htype=gr_block.hilite_type
                    hsize=gr_block.hilite_size
                    c_hilited=hilite_cblock(gr_block,corner)
                  end
                end
              else
                c_hilited=unhilite_cblock(gr_block,c_hilited,htype,hsize)
                if ~(kk.equal[kk_last]) then
                  win_tooltip=destroy_block_tooltip(win_tooltip)
                end
                if win_tooltip.equal[[]] then
                  win_tooltip=build_block_tooltip(scs_m.objs(kk))
                end
                id=gtk_timeout_add(500,show_block_tooltip,list(win_tooltip))
                id2=gtk_timeout_add(2000,add_extra_info_tooltip,list(win_tooltip,scs_m.objs(kk)))
		win_tooltip.set_data[id=id,id2=id2];
                kk_last=kk
              end
            else
              port_hilited=unhilite_port(gr_port,port_hilited)
              win_tooltip=destroy_block_tooltip(win_tooltip)
              corner=nearest_tl_br_corner([xc,yc],scs_m.objs(kk),kk,Select)
              if ~isempty(corner) then
                if ~(scs_m.objs(kk).gui=="IMPSPLIT_f" || scs_m.objs(kk).gui=="SPLIT_f" ||...
                     scs_m.objs(kk).gui=="BUSSPLIT"   || scs_m.objs(kk).gui=="CLKSPLIT_f") then
                  if ~c_hilited then
                    gr_block=scs_m.objs(kk).gr
                    htype=gr_block.hilite_type
                    hsize=gr_block.hilite_size
                    c_hilited=hilite_cblock(gr_block,corner)
                  end
                end
              else
                c_hilited=unhilite_cblock(gr_block,c_hilited,htype,hsize)
              end
            end
          else
            port_hilited=unhilite_port(gr_port,port_hilited)
            win_tooltip=destroy_block_tooltip(win_tooltip)
            c_hilited=unhilite_cblock(gr_block,c_hilited,htype,hsize)
          end
        end
      end
    end
  else
    btn=10;xc=scicos_dblclk(1);yc=scicos_dblclk(2);win=scicos_dblclk(3);str=''
    scicos_dblclk=[]
  end
  %pt=[xc,yc]

//   printf("btn=%d,xc=%f,yc=%f,win=%d\n",btn,xc,yc,win)
  options=scs_m.props.options
  if btn==-100 then
    if win==curwin then
      Cmenu='Quit',
    else
      Cmenu=''
      %pt=[]
    end
    return
  end

  if (btn==-2) then
    %pt=[]
    // menu activated
    if part(str,1:7)=='execstr' then
      // A menu was activated and str is like
      // str='execstr(Name_<win>(<number>))'
      str1=part(str,9:length(str)-1);
      win=sscanf(str1,"%*[^_]_%d");
      mcmd='Cmenu='+str1+';execstr(''Cmenu=''+Cmenu)';
      // printf('cosclick: using menu cmd [%s]\n",mcmd);
    elseif part(str,1:9)=='scicos_tb' then
      // A toolbar item was activated
      // str='scicos_tb(name,win)';
      [str1,win]=sscanf(str,'scicos_tb(%[^,],%d)');
      mcmd='Cmenu=""'+str1+'""';
      // printf('cosclick: using toolbar cmd [%s]\n",mcmd);
    elseif part(str,1:9)=='scicos_br' then
      // A browser row was activated
      // printf('cosclick: A browser row was activated');
      [str1,pathh]=sscanf(str,'scicos_br(%[^,],%[^)])');
      Scicos_commands=['%diagram_path_objective='+pathh+';%scicos_navig=1';
		       'Cmenu='''';%win=curwin;xselect();%scicos_navig=[]'];
      mcmd='';
    else
      // XXX we should not ignore other menus ?
      mcmd="";
    end
  end

  if ~isempty(win) & ~isempty(find(win==inactive_windows(2))) then
    pathh=inactive_windows(1)(find(win==inactive_windows(2)))

    if (btn==-2) then
      cmd= mcmd;
    elseif (btn==0) then
      if options('Action') then
        cmd='Cmenu='"CheckMove'"'
      else
        cmd='Cmenu='"CheckSmartMove'"'
      end
    elseif (btn==10) then
      cmd='Cmenu='"Open/Set'"'
    elseif or(btn==[2 5]) then
      cmd='Cmenu='"Popup'"';
    elseif (btn>=32) & (btn<288)
      if exists('%scicos_short') then //Search in %scicos_short the assiocated menu
        ind=find(ascii(btn)==%scicos_short(:,1))
        if ~isempty(ind) then
          ind=ind($)
          cmd='Cmenu='''+%scicos_short(ind,2)+''''
        else
          cmd='Cmenu=''SelectLink'''
        end
      else
        cmd='Cmenu=''SelectLink'''
      end
    elseif (btn==1000) then
      cmd='Cmenu='"CheckSmartMove'"'
    elseif (btn==-1) then
      cmd='Cmenu='''''
    else
      cmd='Cmenu=''SelectLink'''
    end

    Scicos_commands=['%diagram_path_objective='+sci2exp(pathh)+';%scicos_navig=1';
                     cmd+';%win=curwin;%pt='+sci2exp(%pt)+';xselect();%scicos_navig=[]']
    // printf('cosclick: navigation and Cmenu=%s\n",cmd);
    return

  elseif btn==0 then
    //c_hilited means that we want resize a block
    //TODO : Cmenu should be switched in CheckMove/CheckSmartMove
    if c_hilited then
      if corner=='tl' then
        Cmenu='Resize Top'
      elseif corner=='br' then
        Cmenu='Resize'
      end
    else
      if options('Action') then
        Cmenu='CheckMove'
      else
        Cmenu='CheckSmartMove'		//
      end
    end
  elseif btn==1000 then
     Cmenu='CheckSmartMove'
  elseif (btn==10) & (win==curwin) then
    Cmenu='Open/Set'
  elseif (btn==10) & (win<>curwin) then
    jj = find(windows(:,2)==win)
    if ~isempty(jj) then
      if or(windows(jj,1)==100000) then
        Cmenu = "Open/Set"
       else
        Cmenu = "Duplicate"
      end
    else
      Cmenu=''; %pt=[];
    end
  elseif or(btn==[2 5]) then // button 2 pressed or clicked
    Cmenu='Popup'
    return
  elseif btn==-2 then // Dynamic Menu
    win=curwin
    if ~isempty(strindex(str,'_'+string(curwin)+'(')) then
      // click in a scicos dynamic menu
      %pt=[]
      execstr('Cmenu='+part(str,9:length(str)-1))
      execstr('Cmenu='+Cmenu,errcatch=%t);
      return
    elseif ~isempty(strindex(str,'scicos_tb')) then
      // click in a scicos toolbar menu
      [mcmd,vwin]=sscanf(str,'scicos_tb(%[^,],%d)');
      Cmenu = mcmd;
    elseif part(str,1:9)=='scicos_br' then
      // A browser row was activated
      [str1,pathh]=sscanf(str,'scicos_br(%[^,],%[^)])');
      Scicos_commands=['%diagram_path_objective='+pathh+';%scicos_navig=1';
		       'Cmenu='''';%win=curwin;xselect();%scicos_navig=[]'];
      Cmenu='';
    elseif ~isempty(strindex(str,'PlaceDropped_info')) then
      // we have dropped a block in the window
      ok = execstr('[ptd,path,win,bname]='+str,errcatch=%t);
      if ok && win == curwin  then
	// we need here to transmit info on dropped block
        Cmenu='PlaceDropped';
	// well... path is [paletteid,blockid] and name is block name
        btn=hash_create(path=path,name=bname);
        %pt = ptd;
        return;
      elseif win <> curwin then
        message("You can only drop in current window");
      end
    else // click in an other dynamic menu
      execstr(str)
      return
    end
  elseif btn>31 then
    if (btn==1003) | (btn==2003)| (btn==2000) then
      Cmenu='CtrlSelect'
    else
      Cmenu=%tableau(min(100,btn-31));
      if Cmenu=="" then %pt=[];end
    end
  end

  if ~isempty(%pt) then
    str_pt= sprintf("[%05.0f,%05.0f]",%pt(1),%pt(2));
  else
    str_pt= "[]";
  end
  if type(btn,'short')=='h' then
    strb=string('hash_table');
  else
    strb=string(btn);
  end
//   printf("cosclick: btn=%s, pt=%s, Cmenu=''%s'', win=%d, curwin=%d\n",strb,str_pt,Cmenu,win,curwin);
endfunction
