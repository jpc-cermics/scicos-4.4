function [btn,%pt,win,Cmenu]=cosclick()

  //build a tooltip for blk when mouse pointer
  //is above à block
  function win_tooltip=build_block_tooltip(o)
    //win_tooltip = gtkwindow_new(type=1)
    //win_tooltip.set_type_hint[GDK.WINDOW_TYPE_HINT_TOOLTIP]
    
    win_tooltip = gtkwindow_new()
    F=get_current_figure();
    gh=nsp_graphic_widget(F.id)
    win_tooltip.set_transient_for[gh]
    win_tooltip.set_resizable[%f]
    win_tooltip.set_decorated[%f]
    win_tooltip.set_skip_taskbar_hint[%t]
    win_tooltip.set_skip_pager_hint[%t]
    win_tooltip.set_accept_focus[%f]

    screen=win_tooltip.get_root_window[]
    pos=screen.get_pointer[]
    win_tooltip.move[pos(1)+10,pos(2)+10]
    hbox = gtkhbox_new();
    frame = gtkframe_new();
    frame.set_shadow_type[1]
    label = gtklabel_new(str=o.gui);
    label.set_padding[3,1]
    frame.add[label]
    hbox.pack_start[frame,expand=%f,fill=%t,padding=0]
    win_tooltip.add[hbox]
    ev=ior([GDK.EXPOSURE_MASK;GDK.LEAVE_NOTIFY_MASK;GDK.BUTTON_PRESS_MASK;
	    GDK.POINTER_MOTION_MASK;GDK.POINTER_MOTION_HINT_MASK]);
    win_tooltip.set_events[ev]
    //win_tooltip.show_all[];
  endfunction

  //callback to show and update the tooltip
  function y=update_show_block_tooltip(args)
    y=%t
    win_tooltip=args(1)
    o=args(2)
    if ~win_tooltip.equal[[]] then
      win_tooltip=update_block_tooltip(o,win_tooltip)
      win_tooltip.show_all[];
    end
  endfunction
  
  //callback to only show the tooltip
  function y=show_block_tooltip(args)
    y=%t
    win_tooltip=args(1)
    o=args(2)
    if ~win_tooltip.equal[[]] then
      if ~win_tooltip.get_visible[] then
        win_tooltip=update_block_tooltip(o,win_tooltip)
      end
      win_tooltip.show_all[];
//       pause
    end
  endfunction
  
  //update a tooltip for blk when mouse pointer
  //move above à block
  function win_tooltip=update_block_tooltip(o,win_tooltip)
    screen=win_tooltip.get_root_window[]
    pos=screen.get_pointer[]
    win_tooltip.move[pos(1)+10,pos(2)+10]
    hbox=win_tooltip.get_children[](1)
    frame=hbox.get_children[](1)
    label=frame.get_children[](1)
    label.set_label[o.gui]
  endfunction

  //destroy block tooltip
  function win_tooltip=destroy_block_tooltip(win_tooltip)
    if ~win_tooltip.equal[[]] then
      win_tooltip.destroy[]
      win_tooltip=[]
    end
  endfunction

  //remove timeout event source tooltip
  function id=remove_timeout(id)
    if ~id.equal[[]] then
      gtk_timeout_remove(id);
      id=[];
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
  
  function rep=move_tooltip(win_tooltip,event)
    win_tooltip.hide[]
    screen=win_tooltip.get_root_window[]
    pos=screen.get_pointer[]
    win_tooltip.move[pos(1)+10,pos(2)+10]
    win_tooltip.show_all[];
    rep=%t
  endfunction
  
// select action from an activated event 
// 
  global Scicos_commands
  global scicos_dblclk
  
  Cmenu_orig=Cmenu
  Cmenu="";%pt=[];btn=0;
  if ~or(winsid()==curwin) then  win=xget('window');Cmenu='Quit',return,end
  if ~exists('%scicos_action') then %scicos_action=%t, end
  enablemenus();
  
  if isempty(scicos_dblclk) then
    xcursor(GDK.CROSSHAIR)
    btn=-1

    win_tooltip=[];
    port_hilited=%f;
    gr_port=[];
    id=[];
    kk_last=[];

    //new : motion event loop (Alan,30/05/13)
    while %t
      //switch getmotion to %f to not show the tooltip
      [btn,xc,yc,win,str]=xclick(getkey=%t,cursor=%f,getmotion=%t)
      id=remove_timeout(id)
      
      if (btn~=-1) then
        port_hilited=unhilite_port(gr_port,port_hilited)
        win_tooltip=destroy_block_tooltip(win_tooltip)
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
            if ~connected && cedge=='Link' then
              win_tooltip=destroy_block_tooltip(win_tooltip)
              if ~port_hilited then
                xcursor(GDK.PENCIL)
                gr_port=hilite_port(xyo(1),xyo(2),scs_m.objs(kk))
                port_hilited=%t
              end
            elseif cedge=='inside'
              //fprintf("ici\n");
              port_hilited=unhilite_port(gr_port,port_hilited)
              if ~(kk.equal[kk_last]) then
                win_tooltip=destroy_block_tooltip(win_tooltip)
              end
              if win_tooltip.equal[[]] then
                win_tooltip=build_block_tooltip(scs_m.objs(kk))
                win_tooltip.connect["motion_notify_event",move_tooltip]
              end
              id = gtk_timeout_add(500,show_block_tooltip,list(win_tooltip,scs_m.objs(kk)))
              kk_last=kk
            else
              port_hilited=unhilite_port(gr_port,port_hilited)
              win_tooltip=destroy_block_tooltip(win_tooltip)
            end
          else
            port_hilited=unhilite_port(gr_port,port_hilited)
            win_tooltip=destroy_block_tooltip(win_tooltip)
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
      if %scicos_action then
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
    if %scicos_action then
      Cmenu='CheckMove'
    else
      Cmenu='CheckSmartMove'		// 
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
