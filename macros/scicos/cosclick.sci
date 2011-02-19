function [btn,%pt,win,Cmenu]=cosclick(flag)
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

  printf("cosclick : btn =%d\n",btn);

  if btn==-100 then  
    if win==curwin then
      Cmenu='Quit',
    else
      Cmenu=''
      %pt=[]
    end
    return
  end

  //TODO Alan
  if (btn==-2) & part(str,1:7)=='execstr' then
    from=max(strindex(str,'_'))+1;
    to=max(strindex(str,'('))-1
    win=evstr(part(str,from:to))
  end

  if ~isempty(win) & ~isempty(find(win==inactive_windows(2))) then
    global Scicos_commands
    pathh=inactive_windows(1)(find(win==inactive_windows(2)))

    if (btn==-2) then
      cmd='Cmenu='+part(str,9:length(str)-1)+';execstr(''Cmenu=''+Cmenu)'
    elseif (btn==0) then
      if %scicos_action then
        cmd='Cmenu='"MoveLink'"'
      else
        cmd='Cmenu='"Smart Move'"'
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
      cmd='Cmenu='"Smart Move'"'
    else
      cmd='Cmenu=''SelectLink'''
    end

    Scicos_commands=['%diagram_path_objective='+sci2exp(pathh)+';%scicos_navig=1';
                     cmd+';%win=curwin;%pt='+sci2exp(%pt)+';xselect();%scicos_navig=[]']
    return

  elseif btn==0 then
    if %scicos_action then
      Cmenu='MoveLink'
    else
      Cmenu='Smart Move'
    end
  elseif btn==1000 then
     Cmenu='Smart Move'
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
      execstr('Cmenu='+Cmenu,errcatch=%t)
      return
    elseif ~isempty(strindex(str,'PlaceDropped_info')) then
      // we have dropped a block in the window 
      ok = execstr('[ptd,path,win]='+str,errcatch=%t);
      if ok && win == curwin  then 
        Cmenu='PlaceDropped';
        btn=hash_create(path=path); // well... this is [paletteid,blockid].
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
    str_pt= " pt(1)="+string(%pt(1))+" pt(2)="+string(%pt(2));
  else
    str_pt= " pt=[]";
  end

  if type(btn,'short')=='h' then 
    printf("btn="+string('hash_table')+str_pt+"\n");
  else
    printf("btn="+string(btn)+str_pt+"\n");
  end
  printf("Cmenu="+Cmenu+"\n");
endfunction
