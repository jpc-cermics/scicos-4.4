function [scs_m,newparameters,needcompile,edited]=scicos(scs_m,menus)
// scicos - block diagram graphic editor
//%SYNTAX
// scs_m=scicos(scs_m,job)
//%PARAMETERS
// scs_m    : scilab list, scicos main data structure
//      scs_m.props contains system name and other infos
//      scs_m.objs(i) contains description of ith block diagram element
// menus : vector of character strings,optional parameter giving usable menus 
//!
// Copyright INRIA
  
  global %scicos_navig
  global %diagram_path_objective
  global inactive_windows
  global scicos_widgets
  global Scicos_commands
  
  if ~exists('slevel') then slevel=0;end 
  slevel = slevel +1;
  super_block = slevel > 1;

  if ~super_block then
    // print the banner on first call 
    global next_scicos_call
    if isempty(next_scicos_call) then
      next_scicos_call=1
      scicos_banner() 
    end
    Main_Scicos_window=1000
    // initialize variables used for navigation
    super_path=[]; // path to the currently opened superblock
    %scicos_navig=[]; // do we have to navigate 
    inactive_windows=list(list(),[]);
    scicos_widgets=list();
    Scicos_commands=[];
    //set current version of scicos
    scicos_ver=get_scicos_version(); 
    // define scicos libraries
    scicos_library_initialize()
    //     
    modelica_libs=unique(modelica_libs);
    if exists('%scicos_with_grid')==%f then
      %scicos_with_grid=%f;
    end
    if exists('%scs_wgrid')==%f then
      %scs_wgrid=[10;10;12];
    end
    if exists('%scicos_action')==%f then
      %scicos_action=%t;
    end
    if exists('%scicos_snap')==%f then
      %scicos_snap=%f;
    end
    %zoom=1.4; // default zoom value 
    pal_mode=%f; //Palette edition mode
    newblocks=[]; //table of added functions in pal_mode
    ok = execstr('load(''.scicos_short'')',errcatch=%t)  //keyboard shortcuts
    if ~ok then 
      lasterror(); //clear the error message stack 
    end
    // menus actions 
    %cor_item_exec=scicos_menu_prepare();
    // keyboard definiton
    %tableau=smat_create(1,100,"");
    for %Y=1:size(%scicos_short,1)
      %tableau(-31+ascii(%scicos_short(%Y,1)))=%scicos_short(%Y,2);
    end
  end

  %diagram_open=%t   //default choice
  if ~isempty(super_path) then
    if isequal(%diagram_path_objective,super_path) then
      if ~isempty(%scicos_navig) then
        %diagram_open=%t
        %scicos_navig=[]
        xset('window',curwin)
      end
    elseif ~isempty(%scicos_navig) then
      %diagram_open=%f
    end
  end
   
  // initialisation of shared variables 
  newparameters=list();
  enable_undo=%f;
  edited=%f;
  needreplay=%f;
  %path='./';
  %exp_dir=getcwd();
  
  // inherits needcompile. 
  if ~exists('needcompile') then needcompile=0; 
  else needcompile=needcompile;
  end
  
  
  if nargin >=1 then
    if type(scs_m,'string')== 'SMat' then //diagram is given by its filename
      %fil=scs_m
      alreadyran=%f
      [ok,scs_m,%cpr,edited]=do_load(%fil,'diagram')
      if ~ok then return, end
      // make a first eval 
      [scs_m,%cpr,needcompile,ok]=do_eval(scs_m,%cpr)
      if ~ok then %cpr=list();end 
      // -------------------
      if size(%cpr)==0 then
	needcompile=4
	%state0=list()
      else
	%state0=%cpr.state;
	needcompile=0
      end
    else //diagram is given by its data structure
      if ~super_block then 
	%cpr=list();needcompile=4;alreadyran=%f,%state0=list()
      end
    end
    needsavetest=%t
  else
    xset('window',Main_Scicos_window);
    xset('recording',0);

    ok = execstr('load(getenv(''NSP_TMPDIR'')+''/BackupSave.cos'')',errcatch=%t)
    if ~ok then
      lasterror();
      scs_m=get_new_scs_m();
      %cpr=list();needcompile=4;alreadyran=%f;%state0=list();
    else
      load(getenv('NSP_TMPDIR')+'/BackupInfo')
      scs_m=rec_restore_gr(scs_m,inactive_windows)
    end
    nsp_clear_queue()
    needsavetest=%f
  end
  
  if scs_m.type<>'diagram' then
    error('First argument must be a scicos diagram')
  end
  
  options=scs_m.props.options
  %scicos_solver=scs_m.props.tol(6);
  %browsehelp_sav=[]

  if ~super_block then
    xset('window',Main_Scicos_window)
    curwin=xget('window')
    palettes=list()
    noldwin=0
    windows=[1 curwin]
    pixmap=%scicos_display_mode
    %scicos_gui_mode=1
    getvalue=gtk_getvalue
  else
    noldwin=size(windows,1)
    windows=[windows;slevel,curwin]
    palettes=palettes;
  end

  
  Cmenu='';%pt=[];%win=curwin;%curwpar=[];
  Select=[];Select_back=[];%ppt=[];

  if %diagram_open then
    //initialize graphics
    F=get_current_figure()
    gh_current_window=nsp_graphic_widget(F.id);
    if ~gh_current_window.check_data['user_data'] then 
      gh_current_window.user_data=list([]);
    end
    user_data=gh_current_window.user_data;
    //pause
    if ~isequal(user_data(1),scs_m) then
      ierr=execstr('load(getenv(''NSP_TMPDIR'')+''/AllWindows'')',errcatch=%t)
      if ierr then
        x=winsid()
        for win_i=AllWindows
          if ~isempty(find(x==win_i)) then
            //scf(win_i)
            xset('window',win_i);
            seteventhandler('')
          end
        end
      else
        lasterror();
      end
      if needsavetest & ~super_block then
	// pause ici ici ici 
      end
      needsavetest=%f
      scs_m=scs_m_remove_gr(scs_m,recursive=%f);
      %zoom=restore(curwin,%zoom)
      scicos_set_uimanager(slevel <=1 );
      scs_m=scs_m_remove_gr(scs_m,recursive=%f);
      //%zoom=restore(curwin,%zoom,slevel)
      window_set_size();
      scs_m=drawobjs(scs_m,curwin);
    else
      //needed here ?
      //maybe because we don't store gr in rpar of sblock
      //isequal to be checked for gr object
      scs_m=user_data(1)
      if size(user_data(1).props.wpar,'*')>12 then
        %zoom=scs_m.props.wpar(13)
      end
      Select=user_data(2)
      enable_undo=user_data(3)
      scs_m_save=user_data(4)
      nc_save=user_data(5)
      xselect()
    end
    F=get_current_figure()
    gh_current_window=nsp_graphic_widget(F.id);
    gh_current_window.present[]
  else
    // ~%diagram_open
    if or(curwin==winsid()) then
      xset('window',curwin)
      F=get_current_figure()
      gh_current_window=nsp_graphic_widget(F.id)
      if ~gh_current_window.check_data['user_data'] then 
	gh_current_window.user_data=list([]);
      end
      user_data=gh_current_window.user_data;
      if isequal(user_data(1),scs_m) then
        Select=user_data(2)
      end
    end
  end

  // be sure that context is ok at this level.
  if type(scs_m.props.context,'short')<>'s' then 
    scs_m.props.context='';
  end
  [%scicos_context,ierr] = script2var(scs_m.props.context);
  if ierr<>0 then 
    message(['Error occured when evaluating context:';
	     catenate(lasterror())]);
  end
  
  // 
  global Clipboard 
  
  while (Cmenu<>"Quit" & Cmenu<>"Leave")
    if or(winsid()==curwin) then
      if edited then
        [frect,axsize,viewport,winsize,winpos,pagesize]=get_curwpar(curwin)
        %curwpar=[frect,axsize,viewport,winsize,winpos,%zoom,pagesize]
        if ~isequal(scs_m.props.wpar,%curwpar) then
          scs_m.props.wpar=%curwpar
        end
      end
      drawtitle(scs_m.props)
    end
    
    if isempty(%scicos_navig) && ~isempty(Scicos_commands) then
      // we have a command to execute 
      ok=execstr(Scicos_commands(1),errcatch=%t);
      if ~ok then 
	message(['Error: failed to execute command:';Scicos_commands(1)]);
      end
      Scicos_commands(1)=[];
    end
    
    if Cmenu=='Quit' then break,end

    if ~isempty(%scicos_navig) then 
      // navigation mode is active 
      while ~isempty(%scicos_navig) do
        if ~isequal(%diagram_path_objective,super_path) then
          %diagram_open=%f
          Select_back=Select
          [Cmenu,Select]=Find_Next_Step(%diagram_path_objective,super_path,Select) 
          if or(curwin==winsid()) & ~isequal(Select,Select_back) then
            selecthilite(Select_back,%f)
            selecthilite(Select,%t)
          end
          if ~or(curwin==winsid()) then
            scicos_menu_update_sensitivity(Clipboard,Select)
          end

          if Cmenu=="OpenSet" then
            ierr=execstr('_ie=exec(OpenSet_);',errcatch=%t)
            if ierr==%f then message(catenate(lasterror())),end
            if isequal(%diagram_path_objective,super_path) then 
	      // must add after testing &%scicos_navig<>[] 
              if ~or(curwin==winsid()) then
                %zoom=restore(curwin,%zoom)
                scicos_set_uimanager(slevel <=1 );
		scs_m=scs_m_remove_gr(scs_m,recursive=%f);
		window_set_size();
		ok=execstr('scs_m=drawobjs(scs_m,curwin)',errcatch=%t);
		if ~ok then 
		  message(['Failed to draw diagram'])
		  lasterror();
		end
                %scicos_navig=[]
                Select_back=[];Select=[]
              end  
            else
              if ~or(curwin==winsid()) & isempty(%scicos_navig) then
                %scicos_navig=1
                %diagram_path_objective=[]
              end
            end
          elseif Cmenu=="Quit" then
            do_exit()
	    return
          end
        else
          %scicos_navig=[]
        end
      end 
    else
      %diagram_open=%t
      if ~or(curwin==winsid()) then
        %zoom=restore(curwin,%zoom)
        scicos_set_uimanager(slevel <=1 );
        scs_m=scs_m_remove_gr(scs_m,recursive=%f);
        xset('recording',0)
        Cmenu='Replot'
        Select_back=[];Select=[]
      end
      if ~isempty(Select) then
        if ~or(Select(1,2)==winsid()) then
          Select=[]; //** imply a full Reset 
        end
      end
      scicos_menu_update_sensitivity(Clipboard,Select)

      [CmenuType, DmenuType, mess]=CmType(Cmenu);
      xinfo(mess);
      if (Cmenu=="" & ~isempty(%pt)) then %pt=[]; end
      if (Cmenu<>"" & CmenuType==0) then %pt=[]; end
      if (Cmenu<>"" & CmenuType==1 & isempty(%pt) & ~isempty(Select)) then
        [%pt,%win] = get_selection(Select,%pt,%win)
      end
      if (Cmenu==""|(CmenuType==1 & isempty(%pt) & isempty(Select))) then
        [btn, %pt_n, win_n, Cmenu_n]=cosclick();
        if (Cmenu_n=='SelectLink' || Cmenu_n=='CheckMove' ...
	    || Cmenu_n=='CheckKeyMove'|| Cmenu_n=='CheckKeySmartMove' ) ...
		    & Cmenu<>"" & CmenuType==1 & isempty(%pt) then
          if ~isempty(%pt_n) then %pt = %pt_n; end
        else
          if Cmenu_n<>"" then Cmenu = Cmenu_n; end
          if ~isempty(%pt_n) then %pt = %pt_n; end
        end
        %win = win_n
      else
        if DmenuType then disablemenus(), end
        //printf("Cmenu=%s\n",Cmenu);
        %koko=find(Cmenu==%cor_item_exec(:,1))
        if ~isempty(%koko) then
          %koko=%koko(1)
          Select_back=Select
          %cor_item_fun=%cor_item_exec(%koko,2)
	  //printf('Entering function ' + %cor_item_fun+'\n');
          // execstr('exec('+%cor_item_fun+');');ierr=%t
	  ierr=execstr('_ie=exec('+%cor_item_fun+');',errcatch=%t);
          if ierr==%f then 
            message(['Error in '+%cor_item_fun;catenate(lasterror())]);
            Cmenu='Replot';%pt=[]
            // unhilite objects
            selecthilite(Select,%f)
            Select_back=[];Select=[]
          elseif or(curwin==winsid()) then
            if ~isequal(Select,Select_back) then
	      // update the hilite status of objects. 
              selecthilite(Select_back,%f)
              selecthilite(Select,%t)
            end
          else
            if isempty(%scicos_navig) then // in case window is not open
              %scicos_navig=1
              %diagram_path_objective=[]
            end
          end
          // printf('Quit function ' + %cor_item_fun+'\n');
        else
          Cmenu="";%pt=[]
        end
      end
    end
  end
  if Cmenu=='Quit' then
    do_exit()

    if ~super_block then // even after quiting, workspace variables
      //TODO
      execstr("file(""delete"",getenv(''NSP_TMPDIR'')+''/BackupSave.cos'')",errcatch=%t)
      execstr("file(""delete"",getenv(''NSP_TMPDIR'')+''/BackupInfo'')",errcatch=%t)
      // clear all globals defore leaving
      clearglobal Clipboard  
      clearglobal Scicos_commands 
      clearglobal %tableau
      clearglobal %scicos_navig
      clearglobal %diagram_path_objective
      close_inactive_windows(inactive_windows,[],widgets=scicos_widgets)
      clearglobal inactive_windows
      clearglobal scicos_widgets
    end
    // remove the gr graphics from scs_m 
    for k=1:length(scs_m.objs)
      if scs_m.objs(k).iskey['gr'] then 
        scs_m.objs(k).delete['gr']
      end
    end
  elseif Cmenu=='Leave' then
    // quit scicos but in a state where it can be re-activated 
    // -------------------------------------------------------
    scs_m=scicos_leave(scs_m)
  end
endfunction

function scs_m=scicos_leave(scs_m)
// quit scicos but in a state where it can be re-activated 
// -------------------------------------------------------
  scs_m=scs_m_remove_gr(scs_m);
  ok=do_save(scs_m,file('join',[getenv('NSP_TMPDIR');'BackupSave.cos']));
  if ok then 
    //need to save %cpr because the one in .cos cannot be
    //used to continue simulation
    if ~exists('%tcur') then %tcur=[];end
    if ~exists('%scicos_solver') then %scicos_solver=0;end
    save(file('join',[getenv('NSP_TMPDIR');'BackupInfo']),...
	 edited,needcompile,alreadyran, %cpr,%state0,%tcur,...
	 %scicos_solver,inactive_windows);
    //close widgets
    global scicos_widgets
    for kk=1:length(scicos_widgets)
      if scicos_widgets(kk).open then
        scicos_widgets(kk).id.destroy[]
      end
    end
  end
  if ~ok then
    message(['Problem saving a backup; I cannot activate ScicosLab.';
	     'Save your diagram scs_m manually.'])
    pause saving scs_m;
  end
  // set event handlers 
  AllWindows=unique([windows(:,2);inactive_windows(2)(:)])
  AllWindows=intersect(AllWindows',winsid())
  seteventhandler('scilab2scicos',win=AllWindows);
  // disable menus 
  disablemenus();
  save(file('join',[getenv('NSP_TMPDIR');'AllWindows']),AllWindows);
  printf('%s\n','To reactivate Scicos, click on a diagram or type '"scicos();'"')
  if edited then
    printf('%s\n','Your diagram is not saved. Do not quit ScicosLab or "+...
	   "open another Scicos diagram before returning to Scicos.')
  end
endfunction 

function [itype, dtype, mess] = CmType(Cmenu)
  dtype=isempty(find(Cmenu==%DmenuTypeOneVector(:,1)));
  k=find(Cmenu==%CmenuTypeOneVector(:,1)); 
  if isempty(k) then
    itype=0
    mess=''
    return
  end
  if size(k,'*')>1 then //** if found more than one command 
    message('Warning '+string( size(k,'*'))+' menus have identical name '+Cmenu);
    k=k(1); //** ? 
  end
  itype=1
  mess=%CmenuTypeOneVector(k,2)
endfunction

function [x,k]=gunique(x)
  [x,k]=gsort(x)
  keq=find(x(2:$)==x(1:$-1))
  x(keq)=[]
  k(keq)=[]
endfunction

function inactive_windows=close_inactive_windows(inactive_windows,path,widgets=list())
// -------------------------------------------------------------------
  DELL=[]  // inactive windows to kill
  if size(inactive_windows(2),'*')>0 then
    n=size(path,'*');
    mainopen=or(curwin==winsid()) // is current window open
    for kk=1:size(inactive_windows(2),'*')
      if isempty(path)|isempty(inactive_windows(1)(kk)) then
        if size(inactive_windows(1)(kk),'*')>n then
          DELL=[DELL kk];
          win=inactive_windows(2)(kk)
          if or(win==winsid()) then
            xbasc(win),xdel(win); 
          end
        end
      else
        if size(inactive_windows(1)(kk),'*')>n then 
          if isequal(inactive_windows(1)(kk)(1:n),path) then
            DELL=[DELL kk];
            win=inactive_windows(2)(kk)
            if or(win==winsid()) then
              xbasc(win),xdel(win); 
            end
          end
        end
      end
    end
    if mainopen then xset('window',curwin), end
  end
  for kk=DELL($:-1:1)  // backward to keep indices valid
    inactive_windows(1)(kk)=null()
    inactive_windows(2)(kk)=[]
  end
  for kk=1:length(widgets)
    if widgets(kk).open then
      widgets(kk).id.destroy[]
    end
  end
endfunction

function scilab2scicos(win,x,y,ibut)
//utility function for the return to scicos by event handler
// -------------------------------------
  if ibut==-1000|ibut==-1 then return,end
  ierr=execstr('load(getenv(''NSP_TMPDIR'')+''/AllWindows'')',errcatch=%t)
  if ierr then
    x=winsid()
    for win_i=AllWindows
      if ~isempty(find(x==win_i)) then
        xset('window',win_i)
        seteventhandler('')
      end
    end
  end
  //scicos();
  printf("\nReturn to scicos by eventhandler is disabled.\nUse -->scicos(); instead.\n");
endfunction

function scs_m_out=scs_m_remove_gr(scs_m_in,recursive=%t)
// remove the gr graphics from scs_m 
// recursively 
// ----------------------------------
  scs_m_out=scs_m_in
  for k=1:length(scs_m_out.objs)
    // no use to check first if gr exists before deleting it 
    scs_m_out.objs(k).delete['gr'];
    o = scs_m_out.objs(k);
    if recursive && o.type=='Block' then 
      if or(o.model.sim(1)==['super','csuper','asuper']) then 
	o.model.rpar=scs_m_remove_gr(o.model.rpar,recursive=%t);
	scs_m_out.objs(k)=o;
      end
    end
  end
endfunction


function scs_m=rec_restore_gr(scs_m,inactive_windows)
//draw the gr graphics from scs_m for inactive_windows
//-------------------------------------------
  options=scs_m.props.options
  %scicos_solver=scs_m.props.tol(6)
  n=size(inactive_windows(2),'*')
  for i=1:n
    wii=find(winsid()==inactive_windows(2)(i))
    if ~isempty(wii) then
      path=scs_full_path(inactive_windows(1)(i))
      o=scs_m(path)
      scs_m_save=scs_m
      scs_m=o.model.rpar
      super_block=%t
      curwin=inactive_windows(2)(i)
      xset('window',curwin)
      %zoom=restore(curwin,%zoom)
      %wdm=scs_m.props.wpar
      options=scs_m.props.options
      window_set_size()
      scs_m=do_replot(scs_m)
      //do not store gr in rpar
      scs_m=scs_m_remove_gr(scs_m,recursive=%t);
      o.model.rpar=scs_m
      scs_m=scs_m_save
      scs_m(path)=o
    end
  end
endfunction

function scicos_banner() 
// print the banner when first called 
// ---------------------------------
  [verscicos,minver]=get_scicos_version()
  verscicos=part(verscicos,7:length(verscicos))
  if minver<>'' then
    verscicos=verscicos+'.'+minver
  end
  printf('Scicos version %s\nCopyright (c) 1992-2011 Metalau project INRIA\n',...
	 verscicos);
endfunction


function scicos_library_initialize()
// names are the names which are to be set 
// with the values returned by function initial_scicos_tables. 
// Thus if one entry in names is not defined then initial_scicos_tables
// is called and the returned values are used to set variables with name 
// from names if they are not already set.
// ----------------------------------------

  names = ['%scicos_pal';'%scicos_menu';'%scicos_toolbar';'%scicos_short';
	   '%scicos_help';'%scicos_topics';'%scicos_display_mode';'modelica_libs';
	   '%scicos_lhb_list';'%CmenuTypeOneVector';'%DmenuTypeOneVector';
           '%scicos_gif';'%scicos_contrib';'%scicos_libs';'%scicos_cflags'];
  Enames = exists(names);
  if ~and(Enames) then 
    // at least one of names is not defined 
    L=list();
    L(1:size(names,'*'))= initial_scicos_tables();
    for i=1:size(Enames,'*')
      if Enames(i)== %f then 
	execstr('resume('+ names(i)+'=L('+string(i)+'));');
      end
    end
  end
endfunction

