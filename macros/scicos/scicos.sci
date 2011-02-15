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
  global Scicos_commands

  //check if superblock editing mode
  //% FIXME [%ljunk,%mac]=where()
  
  if ~exists('slevel') then slevel=0;end 
  slevel = slevel +1;
  super_block = slevel > 1;

  if ~super_block then
    global next_scicos_call
    if isempty(next_scicos_call) then
      next_scicos_call=1
      [verscicos,minver]=get_scicos_version()
      verscicos=part(verscicos,7:length(verscicos))
      if minver<>'' then
        verscicos=verscicos+'.'+minver
      end
      ttxxtt=['Scicos version '+verscicos
              'Copyright (c) 1992-2010 Metalau project INRIA'
              '']
      printf("%s\n",ttxxtt)
    end

    //prepare from and to workspace stuff
    //needed ?

    //set up navigation
    super_path=[] // path to the currently opened superblock
    %scicos_navig=[]
    inactive_windows=list(list(),[])
    Scicos_commands=[]
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

  //TOBEREMOVED
  scicos_ver='scicos2.7.3' // set current version of scicos
  scicos_ver='scicos4.2' // set current version of scicos
  
  if ~super_block then
    // define scicos libraries
    if exists('scicos_pal')==%f | exists('%scicos_menu')==%f | exists('%scicos_short')==%f |..
	  exists('%scicos_display_mode')==%f| exists('scicos_pal_libs') ==%f |..
          exists('%scicos_lhb_list')==%f | exists('%CmenuTypeOneVector')==%f |..
          exists('%scicos_gif')==%f | exists('%scicos_contrib')==%f |..
          exists('%scicos_libs')==%f | exists('%scicos_cflags')==%f then

      [scicos_pal_0,%scicos_menu_0,%scicos_short_0,%scicos_help_0,..
       %scicos_display_mode_0,modelica_libs_0,scicos_pal_libs_0, ..
       %scicos_lhb_list_0, %CmenuTypeOneVector_0, %scicos_gif_0,..
       %scicos_contrib_0,%scicos_libs_0,%scicos_cflags_0,..
       %scicos_pal_list_0,scs_m_palettes_0]=initial_scicos_tables();

      if exists('scicos_pal')==%f then
        scicos_pal=scicos_pal_0;
      end
      if exists('%scicos_menu')==%f then
        %scicos_menu=%scicos_menu_0;
      end
      if exists('%scicos_short')==%f then
        %scicos_short=%scicos_short_0;
      end
      if exists('%scicos_help')==%f then
        %scicos_help=%scicos_help_0;
      end
      if exists('%scicos_display_mode')==%f then
        %scicos_display_mode=%scicos_display_mode_0;
      end
      if exists('modelica_libs')==%f then
        modelica_libs=modelica_libs_0
      end
      if exists('scicos_pal_libs')==%f then
        scicos_pal_libs=scicos_pal_libs_0
      end
      if exists('%scicos_lhb_list')==%f then
        %scicos_lhb_list = %scicos_lhb_list_0;
      end
      if exists('%CmenuTypeOneVector')==%f then
        %CmenuTypeOneVector = %CmenuTypeOneVector_0;
      end
      if exists('%scicos_gif')==%f then
        %scicos_gif = %scicos_gif_0;
      end
      if exists('%scicos_contrib')==%f then
        %scicos_contrib = %scicos_contrib_0;
      end
      if exists('%scicos_libs')==%f then
        %scicos_libs = %scicos_libs_0;
      end
      if exists('%scicos_cflags')==%f then
        %scicos_cflags = %scicos_cflags_0;
      end
      if exists('%scicos_pal_list')==%f then
        %scicos_pal_list = %scicos_pal_list_0;
      end
      if exists('scs_m_palettes')==%f then
        scs_m_palettes = scs_m_palettes_0;
      end
    end
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
  end
  
  Main_Scicos_window=1000

  //Initialisation
  newparameters=list();
  enable_undo=%f;
  edited=%f;
  needreplay=%f;
  %path='./';
  %exp_dir=getcwd();
  
  if ~super_block then // global variables
    %zoom=1.4;
    pal_mode=%f; // Palette edition mode
    newblocks=[]; // table of added functions in pal_mode

    scicos_paltmp=scicos_pal;
    if execstr('load(''.scicos_pal'')',errcatch=%t)==%t then
      scicos_pal=[scicos_paltmp;scicos_pal];
      [%junk,%palce]=gunique(scicos_pal(:,2));
      %palce=-sort(-%palce);
      scicos_pal=scicos_pal(%palce,:);
    else
      lasterror(); // clear the error message stack 
    end
    ok = execstr('load(''.scicos_short'')',errcatch=%t)  //keyboard shortcuts
    if ~ok then 
      lasterror(); // clear the error message stack 
    end
  end

  //
  if ~exists('needcompile') then needcompile=0; 
  else needcompile=needcompile;end

  if nargin >=1 then
    if type(scs_m,'string')== 'SMat' then //diagram is given by its filename
      %fil=scs_m
      alreadyran=%f
      [ok,scs_m,%cpr,edited]=do_load(%fil,'diagram')
      if ~ok then return, end

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
    end
    needsavetest=%f
  end

  if scs_m.type<>'diagram' then
    error('first argument must be a scicos diagram')
  end
  
  if ~super_block then
    %cor_item_exec=[];
    [menus]=scicos_menu_prepare(%scicos_menu);
    for i=1:size(menus.items,'*')
      sname = menus.items(i);
      submenu=menus(sname);
      %ww='menus('''+sname+''')(2)('+ m2s(1:(size(submenu(1),'*')),'%.0f') + ')';
      execstr(sname+ '=%ww;');
      %cor_item_exec=[%cor_item_exec;submenu(2),submenu(3)];
    end

    // add fixed menu items not visible
    %cor_item_exec = [%cor_item_exec;
                      'Link'            , 'Link_'
                      'Open/Set'        , 'OpenSet_'
                      'MoveLink'        , 'MoveLink_'
                      'SMove'           , 'SMove_'
                      'SelectLink'      , 'SelectLink_'
                      'CtrlSelect'      , 'CtrlSelect_'
                      'SelectRegion'    , 'SelectRegion_'
                      'Popup'           , 'Popup_'
                      'PlaceinDiagram'  , 'PlaceinDiagram_'
                      'PlaceDropped'    ,'PlaceDropped_'
                      'BrowseTo'        , 'BrowseTo_'
                      'Place in Browser', 'PlaceinBrowser_'
                      'Select All'      , 'SelectAll_'   
                      'Smart Link'      , 'SmartLink_'];

    //keyboard definiton
    %tableau=smat_create(1,100,"");
    for %Y=1:size(%scicos_short,1)
      %tableau(-31+ascii(%scicos_short(%Y,1)))=%scicos_short(%Y,2);
    end
  end

  options=scs_m.props.options
  %scicos_solver=scs_m.props.tol(6)
  %browsehelp_sav=[]

  if ~super_block then
    xset('window',Main_Scicos_window);
    curwin=xget('window');
    palettes=list();
    noldwin=0
    windows=[1 curwin]
    pixmap=%scicos_display_mode
    //
    %scicos_gui_mode=1;
    //if ~exists('%scicos_gui_mode') then 
    //  if with_tk() then %scicos_gui_mode=1,else %scicos_gui_mode=0,end
    //end
    //%scicos_gui_mode=0
    //if %scicos_gui_mode==1 then
    //  getfile=tk_getfile;
    //  savefile=tk_savefile;
    //  if MSDOS then getvalue=tk_getvalue,end
    //  if MSDOS then mpopup=tk_mpopup, else mpopup=tk_mpopupX,end
    //  if MSDOS then choose=tk_choose; else
    //    deff('x=choose(varargin)','x=x_choose(varargin(1:$))');
    //  end
    //  funcprot(0);getcolor=tk_getcolor;funcprot(1);
    //else
    //  deff('x=getfile(varargin)','x=xgetfile(varargin(1:$))');
    //  savefile=getfile;
    //  deff('Cmenu=mpopup(x)','Cmenu=[]')
    //  deff('x=choose(varargin)','x=x_choose(varargin(1:$))');
    //end
  else
    noldwin=size(windows,1)
    windows=[windows;slevel,curwin]
    palettes=palettes;
  end
  
  // set context (variable definition...)
  if is(scs_m.props.context,%types.SMat) then
    %now_win=xget('window')
    if ~execstr(scs_m.props.context,errcatch=%t) then
      message(['Error occur when evaluating context:']);
      lasterror();
    end
    xset('window',%now_win)
    xset('recording',0);
  else
    scs_m.props.context=' ' 
  end

  MSDOS=%f; // XXXXX 

  Cmenu='';%pt=[];%win=curwin;
  Select=[];Select_back=[];%ppt=[];

  //initialize graphics
  if %diagram_open then
    F=get_current_figure();
    gh_current_window=nsp_graphic_widget(F.id)
    if ~execstr('user_data=gh_current_window.user_data',errcatch=%t) then
      gh_current_window.user_data=list([])
      user_data=gh_current_window.user_data
      lasterror();
    end
    if ~isequal(user_data(1),scs_m) then
      ierr=execstr('load(getenv(''NSP_TMPDIR'')+''/AllWindowss'')',errcatch=%t)
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
        printf("icicicicici\n");
        pause
      end
      needsavetest=%f
      xset('window',curwin);
      xset('recording',0);
      xtape_status=xget('recording');
      %zoom=restore(curwin,menus,%zoom)
      scs_m = drawobjs(scs_m);
      if super_block then
        Cmenu = 'Replot'
      end
    else
      Select=user_data(2)
      enable_undo=user_data(3)
      scs_m_save=user_data(4)
      nc_save=user_data(5)
      xselect()
    end
  else
    if or(curwin==winsid()) then
      xset('window',curwin);
      F=get_current_figure();
      gh_current_window=nsp_graphic_widget(F.id)
      if ~execstr('user_data=gh_current_window.user_data',errcatch=%t) then
        gh_current_window.user_data=list([])
        user_data=gh_current_window.user_data
      end
      if ~isequal(user_data(1),scs_m) then
        Select=user_data(2)
      end
    end
  end

// center the viewport 
// window_set_size() can do the same but it clears the window
//   xflush();
//   wd_=xget('wdim');
//   wpd_=xget('wpdim');
//   wshift=max((wd_-wpd_)/2,0);
//   xset('viewport',wshift(1),wshift(2));

  exec(restore_menu)
  global Clipboard 

  while (Cmenu<>"Quit" & Cmenu<>"Leave")
    if or(winsid()==curwin) then
      if edited then
        // store win dims, it should only be in do_exit but not possible now
        [wrect,frect,logflag,arect]=xgetech()
        data_bounds=frect
        winpos=xget("wpos")
        winsize=xget("wpdim")
        axsize=xget("wdim")
        %curwpar=[data_bounds(:)',axsize,..
                  xget('viewport'),winsize,winpos,%zoom]
        if ~isequal(scs_m.props.wpar,%curwpar) then
          scs_m.props.wpar=%curwpar
        end
      end
      drawtitle(scs_m.props)
    end

    if isempty(%scicos_navig) then 
      if ~isempty(Scicos_commands) then
        //printf("    Scicos_commands(1) : %s \n",Scicos_commands(1))
        execstr(Scicos_commands(1))
        Scicos_commands(1)=[]
      end
    end
    if Cmenu=='Quit' then break,end

    if ~isempty(%scicos_navig) then //** navigation mode active
      while ~isempty(%scicos_navig) do
        if ~isequal(%diagram_path_objective,super_path) then
          %diagram_open=%f
          Select_back=Select
          [Cmenu,Select]=Find_Next_Step(%diagram_path_objective,super_path,Select) 
          if or(curwin==winsid()) & ~isequal(Select,Select_back) then
            selecthilite(Select_back,%f); // unHilite previous objects
            selecthilite(Select,%t);      // Hilite the actual selected object
          end
          if Cmenu=="OpenSet" then
            ierr=execstr('exec(OpenSet_);',errcatch=%t)
            if ierr==%f then message(catenate(lasterror())),end
            if isequal(%diagram_path_objective,super_path) then // must add after testing &%scicos_navig<>[] 
              if ~or(curwin==winsid()) then 
                %zoom=restore(curwin,menus,%zoom)
                execstr('drawobjs(scs_m)',errcatch=%t) 
                %scicos_navig=[];
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
        xset('window',curwin);
        xset('recording',0);
        %zoom=restore(curwin,menus,%zoom)
        Cmenu='Replot'
        Select_back=[];Select=[]
      end
      if ~isempty(Select) then
        if ~or(Select(1,2)==winsid()) then
          Select=[]; //** imply a full Reset 
        end
      end

      [CmenuType, mess]=CmType(Cmenu);
      xinfo(mess);
      if (Cmenu=="" & ~isempty(%pt)) then %pt=[]; end
      if (Cmenu<>"" & CmenuType==0) then %pt=[]; end
      if (Cmenu<>"" & CmenuType==1 & isempty(%pt) & ~isempty(Select)) then
        [%pt,%win] = get_selection(Select,%pt,%win)
      end
      if (Cmenu==""|(CmenuType==1 & isempty(%pt) & isempty(Select))) then
        [btn, %pt_n, win_n, Cmenu_n]=cosclick();
        if (Cmenu_n=='SelectLink' | Cmenu_n=='MoveLink') & Cmenu<>"" & CmenuType==1 & isempty(%pt) then
          if ~isempty(%pt_n) then %pt = %pt_n; end
        else
          if Cmenu_n<>"" then Cmenu = Cmenu_n; end
          if ~isempty(%pt_n) then %pt = %pt_n; end
        end
        %win = win_n
      else
        disablemenus();
        %koko=find(Cmenu==%cor_item_exec(:,1));
        if size(%koko,'*')==1 then
          Select_back=Select;
          %cor_item_fun=%cor_item_exec(%koko,2);
          printf('Entering function ' + %cor_item_fun+'\n');
          ierr=execstr('exec('+%cor_item_fun+');',errcatch=%t);
          if ierr==%f then 
            message(['Error in '+%cor_item_fun;catenate(lasterror())]);
            Cmenu='Replot';%pt=[];
            Select_back=[];Select=[];
          elseif or(curwin==winsid()) then
            if ~isequal(Select,Select_back) then
              selecthilite(Select_back,%f); // unHilite previous objects
              selecthilite(Select,%t);      // Hilite the actual selected object
            end
          else
            if isempty(%scicos_navig) then // in case window is not open
              %scicos_navig=1
              %diagram_path_objective=[]
            end
          end
          printf('Quit function ' + %cor_item_fun+'\n'); 
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
      // clear all globals defore leaving
      clearglobal Clipboard  
      clearglobal Scicos_commands 
      clearglobal %tableau
      clearglobal %scicos_navig
      clearglobal %diagram_path_objective
      //close_inactive_windows(inactive_windows,[])
      clearglobal inactive_windows
    end
  elseif Cmenu=='Leave' then
    //TODO
    disablemenus();
    printf('%s\n','To reactivate Scicos, click on a diagram or type '"scicos();'"')
  end
  // remove the gr graphics from scs_m 
  for k=1:length(scs_m.objs);
    if scs_m.objs(k).iskey['gr'] then 
      scs_m.objs(k).delete['gr'];
    end
  end
endfunction

function [itype, mess] = CmType(Cmenu)
//** look inside "%CmenuTypeOneVector" if the command is type 1 (need both Cmenu and %pt)
  k = find (Cmenu == %CmenuTypeOneVector(:,1)); 
  if isempty(k) then //** if is not type 1 (empty k)
    itype = 0 ; //** set type to zero
    mess=''   ; //** set message to empty
    return    ; //** --> EXIT point : return back 
  end
  if size(k,'*')>1 then //** if found more than one command 
    message('Warning '+string( size(k,'*'))+' menus have identical name '+Cmenu);
    k=k(1); //** ? 
  end
  itype = 1 ; 
  mess = %CmenuTypeOneVector(k,2) ; 
endfunction

function [x,k]=gunique(x)
  [x,k]=gsort(x);
  keq=find(x(2:$)==x(1:$-1))
  x(keq)=[]
  k(keq)=[]
endfunction

function restore_menu()
  for %Y=1:size(%scicos_menu,1)
    execstr(%scicos_menu(%Y)(1)+'_'+m2s(curwin,'%.0f')+'='+%scicos_menu(%Y)(1)+';')
  end
endfunction
