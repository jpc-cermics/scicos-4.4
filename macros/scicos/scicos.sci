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
//check if superblock editing mode
//% FIXME [%ljunk,%mac]=where()
  
  if ~exists('slevel') then slevel=0;end 
  slevel = slevel +1;
  super_block = slevel > 1;

  scicos_ver='scicos2.7.3' // set current version of scicos
  scicos_ver='scicos4.2' // set current version of scicos
  
  if ~super_block then
    // define scicos libraries
    if exists('scicos_pal')==%f | exists('%scicos_menu')==%f | exists('%scicos_short')==%f |..
	  exists('%scicos_display_mode')==%f| exists('scicos_pal_libs') ==%f then 
      [scicos_pal_0,%scicos_menu_0,%scicos_short_0,%scicos_help_0,..
       %scicos_display_mode_0,modelica_libs_0,scicos_pal_libs_0]=initial_scicos_tables()
      if exists('scicos_pal')==%f then
	//x_message(['scicos_pal not defined';  'using default values'])
	scicos_pal=scicos_pal_0;
      end
      if exists('%scicos_menu')==%f then
	//x_message(['%scicos_menu not defined';   'using default values'])
	%scicos_menu=%scicos_menu_0;
      end
      if exists('%scicos_short')==%f then
	//x_message(['%scicos_short not defined';   'using default values'])
	%scicos_short=%scicos_short_0;
      end
      if exists('%scicos_help')==%f then
	//x_message(['%scicos_help not defined';   'using default values'])
	%scicos_help=%scicos_help_0;
      end
      if exists('%scicos_display_mode')==%f then
	//x_message(['%scicos_display_mode not defined';  'using default values'])
	%scicos_display_mode=%scicos_display_mode_0;
      end
    
      if exists('modelica_libs')==%f then
        //x_message(['modelica_libs not defined'; 'using default values'])
        modelica_libs=modelica_libs_0
      end
      if exists('scicos_pal_libs')==%f then
        //x_message(['scicos_pal_libs not defined'; 'using default values'])
        scicos_pal_libs=scicos_pal_libs_0
      end
    end
    
    //if exists('%scicos_context')==%f then
    //  %scicos_context=hash_create(0);
    //end
  
    //intialize lhb menu
    
    %scicos_lhb_list=list()
    %scicos_lhb_list(1)=list('Open/Set',..
			     'Smart Move'  ,..
			     'Move'  ,..
			     'Copy|||gtk-copy',..
			     'Delete|||gtk-delete',..
			     'Link',..
			     'Align',..
			     'Replace',..
			     'Flip',..
			     list('Properties',..
				  'Resize',..
				  'Icon',..
				  'Icon Editor',..
				  'Color|||gtk-select-color',..
				  'Label',..
				  'Get Info',..
				  'Identification',..
				  'Details',...
				  'Documentation'),...
			     'Code Generation',..
			     'Help|||gtk-help')
    [L, scs_m_palettes] = do_pal_tree(scicos_pal);
    L.add_first['Pal Tree'];
    %scicos_pal_list=L;
    %scicos_lhb_list(2)=list('Undo|||gtk-undo','Palettes',L,'Context','Add new block',..
			     'Copy Region','Delete Region','Region to Super Block',..
			     'Replot','Save|||gtk-save','Save As|||gtk-save-as',..
			     'Load|||gtk-open','Export','Quit|||gtk-quit','Background color','Aspect',..
			     'Zoom in|||gtk-zoom-in',  'Zoom out|||gtk-zoom-out',  'Help');
    
    %scicos_lhb_list(3)=list('Copy|||gtk-copy','Copy Region','Help');
    //
    //if exists('scicoslib')==0 then load('SCI/macros/scicos/lib'),end
    //exec(loadpallibs,-1) //to load the palettes libraries
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
    super_path=[]; // path to the currently opened superblock

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
      if ~ok then 
	return,
      end
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
  else
    xset('window',Main_Scicos_window);
    xset('recording',0);
    scs_m=scicos_diagram();
    %cpr=list();needcompile=4;alreadyran=%f;%state0=list();
  end
  //  if scs_m.type<>'diagram' then error('first argument must be a scicos diagram'),end
  
  [menus]=scicos_menu_prepare(%scicos_menu);
  // insert proper call backs in the current environment 
  // 
  %cor_item_exec=[];
  for i=1:size(menus.items,'*')
    sname = menus.items(i);
    submenu=menus(sname);
    %ww='menus('''+sname+''')(2)('+ m2s(1:(size(submenu(1),'*')),'%.0f') + ')';
    execstr(sname+ '=%ww;');
    %cor_item_exec=[%cor_item_exec;submenu(2),submenu(3)];
  end

  //keyboard definiton
  //FIXME global('%tableau');
  //XXX %tableau=emptystr([1:100]);
  %tableau=smat_create(1,100,"");
  for %Y=1:size(%scicos_short,1)
    %tableau(-31+ascii(%scicos_short(%Y,1)))=%scicos_short(%Y,2);
  end

  // viewport
  options=scs_m.props.options
  //solver
  %scicos_solver=scs_m.props.tol(6)

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

  //initialize graphics
  //xdel(curwin)
  xset('window',curwin);
  xset('recording',0);
  xset('default')
  xclear(); // clear and tape_clean in nsp 
  if pixmap then xset('pixmap',1); end
  xset('pattern',1)
  xset('color',1)
  if ~set_cmap(options('Cmap')) then // add colors if required
    options('3D')(1)=%f //disable 3D block shape
  end
  if pixmap then xset('wwpc');end
  if new_graphics() 
    xclear(curwin,gc_reset=%f);xselect()
  else
    xclear();xselect()
  end
  
  xtape_status=xget('recording');
  xset('recording',0);

  // reset graphics objects 
  pwindow_set_size()
  window_set_size()

  for %Y=1:size(%scicos_menu,1)
    execstr(%scicos_menu(%Y)(1)+'_'+m2s(curwin,'%.0f')+'='+%scicos_menu(%Y)(1)+';')
  end

  MSDOS=%f; // XXXXX 
  
  menu_stuff(curwin,menus)
  // Reset menu added:   to be sure to be able to reset menus 
  EnableMenus_='EnableMenus';
  execstr('function str=Reset_'+string(curwin)+'();str=''EnableMenus_'';endfunction');
  execstr('function enablemenus__(); Cmenu='''';enablemenus();endfunction');
  %cor_item_exec=[%cor_item_exec; 'EnableMenus','enablemenus__'];
  addmenu(curwin,'Reset');
  // add fixed menu items not visible
  %cor_item_exec=[%cor_item_exec;
                  'PlaceinDiagram','PlaceinDiagram_';
                  'PlaceDropped'  ,'PlaceDropped_';
                  'MoveLink'      ,'MoveLink_'
                  'CtrlSelect'    , 'CtrlSelect_'];
  
  if ~super_block then
    delmenu(curwin,'stop')
    addmenu(curwin,'stop||$scicos_stop');
    unsetmenu(curwin,'stop')
  else
    unsetmenu(curwin,'Simulate')
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
  
  if new_graphics() then 
    // reset all the graphic objects which could still be in 
    // scs_m 
    scs_m=do_replot(scs_m)
  else
    drawobjs(scs_m);
  end
  
  // center the viewport 
  // window_set_size() can do the same but it clears the window
  xflush();
  wd_=xget('wdim');
  wpd_=xget('wpdim');
  wshift=max((wd_-wpd_)/2,0);
  xset('viewport',wshift(1),wshift(2));
  if pixmap then xset('wshow'),end
  %pt=[];%win=curwin;
  Cmenu='Open/Set'
  Select=list();Select_back=list();%ppt=[];

  while %t
    while %t do
      if Cmenu=="" & isempty(%pt) then
        [btn,%pt,%win,Cmenu]=cosclick()
        if Cmenu<> "" then 
          break
        end
      else
        break
      end
    end

    if Cmenu=='Quit' then do_exit();break;end
    disablemenus();
    %koko=find(Cmenu==%cor_item_exec(:,1));
    if size(%koko,'*')==1 then
      Select_back=Select;
      %cor_item_fun=%cor_item_exec(%koko,2);
      printf('Entering function ' + %cor_item_fun+'\n');
      ierr=execstr('exec('+%cor_item_fun+');',errcatch=%t);
      if ierr== %f then 
        message(['Error in '+%cor_item_fun;catenate(lasterror())]);
        Cmenu="";%pt=[];
        Select_back=list();Select=list();
      elseif or(curwin==winsid()) then
        if ~isequal(Select,Select_back) then
          selecthilite(Select_back, %f); // unHilite previous objects
          selecthilite(Select, %t);      // Hilite the actual selected object
        end
      end
      printf('Quit function ' + %cor_item_fun+'\n'); 
    else
      Cmenu="";%pt=[]
    end
    if Cmenu=='Quit' then do_exit();break;end
    if pixmap then xset('wshow'),end
  end
  // remove the gr graphics from scs_m 
  if new_graphics() then 
    for k=1:length(scs_m.objs);
      if scs_m.objs(k).iskey['gr'] then 
        scs_m.objs(k).delete['gr'];
      end
    end
  end
endfunction

function [x,k]=gunique(x)
  [x,k]=gsort(x);
  keq=find(x(2:$)==x(1:$-1))
  x(keq)=[]
  k(keq)=[]
endfunction
