function [btn,%pt,win,Cmenu]=cosclick(flag)
// Copyright INRIA
  Cmenu_orig=Cmenu
  Cmenu="";%pt=[];btn=0;
  if ~or(winsid()==curwin) then  win=xget('window');Cmenu='Quit',return,end   
  enablemenus();
  global scicos_dblclk
  if isempty(scicos_dblclk) then
    if nargin==1 then
      [btn,xc,yc,win,str]=xclick(getkey=%t,cursor=flag)
    else
      [btn,xc,yc,win,str]=xclick(getkey=%t,cursor=%t)
    end
  else
    btn=10;xc=scicos_dblclk(1);yc=scicos_dblclk(2);win=scicos_dblclk(3);
    scicos_dblclk=[]
  end
  %pt=[xc,yc]
  printf("cosclick : btn =%d\n",btn);
  if or(btn==[2 5]) then // button 2 pressed or clicked
      Cmenu='Popup'
      return
  elseif btn==0 then
      Cmenu='MoveLink'
  elseif btn==10 then  
      if win==curwin then
	Cmenu='Open/Set'
      end
  elseif btn==-100 then  
      if win==curwin then
	Cmenu='Quit',
      else
	Cmenu='Open/Set'
	%pt=[]
      end
  //** ----- Mouse + Keyb. combos
  elseif btn==2000 then
     Cmenu='CtrlSelect'
    
  elseif btn==-2 then

    // click in a dynamic menu
    win=curwin
    if ~isempty(strindex(str,'_'+string(curwin)+'(')) then
      // click in a scicos dynamic menu
      %pt=[]
      execstr('Cmenu='+part(str,9:length(str)-1))
      execstr('Cmenu='+Cmenu)
      return
    elseif  ~isempty(strindex(str,'PlaceDropped_info')) then
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
      execstr(str,errcatch=%t)
      return
    end
    
  elseif (btn==0|btn==3)&(win<>curwin) then
    jj=find(windows(:,2)==win)
    if ~isempty(jj) then
      if Cmenu_orig=='Copy Region' then
	Cmenu=""
      else
	Cmenu='Copy' //btn=99  //mode copy
      end
      if or(windows(jj,1)==100000) then
	Cmenu='Open/Set'//btn=111  //mode open-set (cliquer dans navigator)
      end
    else
      %pt=[]
    end
  elseif btn>31 then
    Cmenu=%tableau(min(100,btn-31));
    if Cmenu=="" then %pt=[];end
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
