function scicos_view(scs_m)
// show a diagram as it would be shown in scicos 
// very similar to scicos but we quit just after 
// the drawing of the diagram.
// 
  if ~exists('slevel') then slevel=0;end 
  slevel = slevel +1;
  super_block = slevel > 1;

  scicos_ver='scicos2.7.3' // set current version of scicos
  
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
    
  end
  
  Main_Scicos_window=1000;
  
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
    end
    execstr('load(''.scicos_short'')',errcatch=%t)  //keyboard shortcuts
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
    scs_m=scicos_diagram();
    %cpr=list();needcompile=4;alreadyran=%f;%state0=list();
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
  else
    noldwin=size(windows,1)
    windows=[windows;slevel,curwin]
    palettes=palettes;
  end

  //initialize graphics
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
  xclear(curwin,gc_reset=%f);xselect()
  xtape_status=xget('recording');
  xset('recording',0);
  //set_background()

  pwindow_set_size()
  window_set_size()

  MSDOS=%f; // XXXXX 
  
  // set context (variable definition...)
  if is(scs_m.props.context,%types.SMat) then
    %now_win=xget('window')
    if ~execstr(scs_m.props.context,errcatch=%t) then
      message(['Error occur when evaluating context:']);//     lasterror() ])
    end
    xset('window',%now_win)
    xset('recording',0);
  else
    scs_m.props.context=' ' 
  end
  scs_m = drawobjs(scs_m);
endfunction
