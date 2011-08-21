function [btn,%pt,win,Cmenu]=cosclick(flag)
// select action from an activated event 
// 
  Cmenu_orig=Cmenu
  Cmenu="";%pt=[];btn=0;
  if ~or(winsid()==curwin) then  win=xget('window');Cmenu='Quit',return,end
  if ~exists('%scicos_action') then %scicos_action=%t, end
  enablemenus();
  global scicos_dblclk
  if isempty(scicos_dblclk) then
    if nargin==1 then
      [btn,xc,yc,win,str]=xclick(getkey=%t,cursor=flag)
    else
      [btn,xc,yc,win,str]=xclick(getkey=%t,cursor=%t)
    end
  else
    btn=10;xc=scicos_dblclk(1);yc=scicos_dblclk(2);win=scicos_dblclk(3);str=''
    scicos_dblclk=[]
  end
  %pt=[xc,yc]
  
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
    // menu activated 
    if part(str,1:7)=='execstr' then
      // A menu was activated and str is like 
      // str='execstr(Name_<win>(<number>))' 
      str1=part(str,9:length(str)-1);
      win=sscanf(str1,"%*[^_]_%d");
      mcmd='Cmenu='+str1+';execstr(''Cmenu=''+Cmenu)';
      printf('cosclick: using menu cmd [%s]\n",mcmd);
    elseif part(str,1:9)=='scicos_tb' then 
      // A toolbar item was activated 
      // str='scicos_tb(name,win)';
      [str1,win]=sscanf(str,'scicos_tb(%[^,],%d)');
      mcmd='Cmenu=""'+str1+'""';
      printf('cosclick: using toolbar cmd [%s]\n",mcmd);
    else
      // XXX we should not ignore other menus ? 
      mcmd="";
    end
  end
  
  if ~isempty(win) & ~isempty(find(win==inactive_windows(2))) then
    global Scicos_commands
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
    else
      cmd='Cmenu=''SelectLink'''
    end

    Scicos_commands=['%diagram_path_objective='+sci2exp(pathh)+';%scicos_navig=1';
                     cmd+';%win=curwin;%pt='+sci2exp(%pt)+';xselect();%scicos_navig=[]']
    printf('cosclick: navigation and Cmenu=%s\n",cmd);
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
    str_pt=sprintf("[%05.0f,%05.0f]",%pt(1),%pt(2));
  else
    str_pt= "[]";
  end
  if type(btn,'short')=='h' then 
    strb=string('hash_table');
  else
    strb=string(btn);
  end
  printf("cosclick: btn=%s, pt=%s, Cmenu=''%s'', win=%d, curwin=%d\n",strb,str_pt,Cmenu,win,curwin);
endfunction
