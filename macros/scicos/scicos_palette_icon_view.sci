// 
// obtained by translation to Nsp of testiconview.c 
// Jean-Philippe Chancelier (2008-2011) jpc@cermics.enpc.fr
//
//
// Copyright (C) 2002  Anders Carlsson <andersca@gnu.org>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Library General Public
// License as published by the Free Software Foundation; either
// version 2 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Library General Public License for more details.
//
// You should have received a copy of the GNU Library General Public
// License along with this library; if not, write to the
// Free Software Foundation, Inc., 59 Temple Place - Suite 330,
// Boston, MA 02111-1307, USA.
///

function window=scicos_palette_icon_view(H)
// Open a window with selectable palettes 
// in icon views.
//
  if nargin <= 0 then 
    H=scicos_default_palettes();
  end
  
  window = gtkwindow_new ()// GTK.WINDOW_TOPLEVEL);
  window.set_title['Scicos Palette IconView']; 
  window.set_default_size[400, 400];
  vbox = gtkvbox_new(homogeneous=%f,spacing=0);
  window.add[ vbox];
  
  // a combo with recursive structure.
  function scicos_palette_tree_model_append(model,h,iter) 
    for i=1:length(h)
      t = type(h(i),'string');
      // On first call to this recursive function iter is not 
      // a GtkTreeIter
      if t == 'SMat' then 
	if is(iter,%types.GtkTreeIter) then 
	  iter1=model.append[iter,list(h(i))];
	else 
	  iter1=model.append[list(h(i))];
	end
      else
	scicos_palette_tree_model_append(model,h(i),iter1);
      end
    end
  endfunction
  
  // a hierarchical model
  model = gtktreestore_new(list("name"),%f);
  scicos_palette_tree_model_append(model,H.structure,0);
  // a combo defined by model
  combobox2 = gtkcombobox_new(model=model);
  combobox2.set_add_tearoffs[%t];
  //g_object_unref (model);
  vbox.pack_start[combobox2, expand=%f,fill= %t,padding=0];
  
  cell_renderer = gtkcellrenderertext_new ();
  combobox2.pack_start[ cell_renderer,expand= %t];
  combobox2.add_attribute[cell_renderer,"text",0];
  // set active element in the combobox 
  combobox2.set_active[0];

  function combo2_changed(combo,args)
  // this can be used as handler for 
  // combobox.connect["changed", current_option ]
    M= combo.get_model[]
    iter=combo.get_active_iter[]
    name = M.get_value[iter,0];
    //printf('Value selected %s\n",name);
    H=args(2);
    sw=args(1);
    S= H.contents(name);
    icon_list=scicos_build_iconlist(S);
    icon_list.show[];
    L=sw.get_children[];
    if length(L)>=1  then 
      sw.remove[L(1)];
    end
    sw.add[icon_list];
  endfunction
  
  // Icon list 
  
  icon_list=scicos_build_iconlist(H.contents('Sources'))
  // icon list in scrolled window 
  scrolled_window = gtkscrolledwindow_new();
  scrolled_window.add[ icon_list];
  scrolled_window.set_policy[ GTK.POLICY_AUTOMATIC, GTK.POLICY_AUTOMATIC];
  // 
  combobox2.connect["changed", combo2_changed,list(scrolled_window,H) ];
  vbox.pack_start[scrolled_window, expand=%t,fill= %t,padding=0];
  window.show_all[];
endfunction

function icon_list=scicos_build_iconlist(S)
// build a new iconlist for palette described 
// by S
  
  function item_activated (icon_view,path)
  // double click on an item 
    model = icon_view.get_model[];
    L=icon_view.get_selected_items[];
    if ~isempty(L);
      iter = model.get_iter[L(1)];
      text= model.get_value[iter,1];
      //printf ("Item activated, text is %s\n", text);
      help("http://www.scicos.org/HELP/eng/scicos/'+text+'.htm');
    end
  endfunction
  
  function item_activated_cursor (icon_view,path)
  // when return is typed in the palettes 
    model = icon_view.get_model[];
    L=icon_view.get_selected_items[];
    if ~isempty(L);
      iter = model.get_iter[L(1)];
      text= model.get_value[iter,1];
      //printf ("Item cursor activated, text is %s\n", text);
    end
  endfunction

  function selection_changed (icon_view)
  // each time selection changes 
  // printf ("Selection changed!\n");
  endfunction
  
  function press_event_handler(icon_view,event)
    if event.button== 3 && event.type == GDK.BUTTON_PRESS then 
      // a right press 
      path=icon_view.get_path_at_pos[event.x, event.y];
      if type(path,'short')=='none' then 
	// here we could decide to do something if 
	// selection is non void 
	//printf ("right-press activated in the background\n");
	L=icon_view.get_selected_items[];
	if isempty(L);return;end 
	path=L(1);
      end
      icon_view.select_path[path];
      model = icon_view.get_model[];
      iter=model.get_iter[path];
      text= model.get_value[iter,1];
      //printf ("right-press activated over item text is %s\n", text);
      ll = list('Help', 'Details');
      [Cmenu,args]=mpopup(ll);
      if Cmenu == 'Help' then 
	help("http://www.scicos.org/HELP/eng/scicos/'+text+'.htm');
      elseif Cmenu == 'Details' then 
	ok=execstr('obj='+text+'(""define"");',errcatch=%t);
	if ok then editvar('obj');
	else
	  lasterror();
	end
      end
    end
  endfunction
  
  icon_list = gtkiconview_new ();
  icon_list.set_selection_mode[GTK.SELECTION_SINGLE];
  // icon_list.set_selection_mode[GTK.SELECTION_MULTIPLE];
  icon_list.set_size_request[200,-1]
  icon_list.connect_after["button_press_event",press_event_handler];
  icon_list.connect["selection_changed",   selection_changed];
  //icon_list.connect["popup_menu",  popup_menu_handler];
  icon_list.connect["item_activated", item_activated];// double click
  icon_list.connect["activate-cursor-item",item_activated_cursor];

  // create a model for icon view [pixbuf,name,paletteid,blockid];
  // 
  model = gtkliststore_new(list(list(%types.GdkPixbuf),"",1,2), %f);
  
  scicos_icon_path = scicos_path + '/macros/scicos/scicos-images/';
  icons = glob(scicos_icon_path);
  
  dir_logo = scicos_icon_path + 'gtk-directory.png';
  pixbuf_dir = gdk_pixbuf_new_from_file(dir_logo);
  pixbuf_def = gdk_pixbuf_new_from_file(scicos_icon_path + 'VOID.png');

  // get data for palette j 
  
  for j=1:size(S,'*');
    icon = scicos_icon_path + S(j) + '.png' ;
    ok = execstr('pixbuf = gdk_pixbuf_new_from_file(icon);',errcatch=  %t);
    if ~ok then 
      pixbuf = pixbuf_def
      lasterror();
    end
    path=[1,1];// sub(j).path;
    // we assume that path is of length 2 (paletteid,blockid).
    model.append[list(list(pixbuf),S(j),path(1),path(2))];
  end
  
  icon_list.set_model[model=model];
  icon_list.set_pixbuf_column[0];
    
  // Allow DND between the icon view and nsp 
  targets = list( list("GTK_TREE_MODEL_ROW",GTK.TARGET_SAME_APP, 0)  );
  masks= ior(GDK.BUTTON1_MASK,GDK.BUTTON3_MASK);
  icon_list.enable_model_drag_source[masks,targets, GDK.ACTION_COPY];
  // only want to drag/drop in graphic window.
  icon_list.set_reorderable[%f];
  //
  if ~isempty(icon_list.get_method_names[]=="set_tooltip_column") then 
    // added Aug 2011 
    // use block name as tooltip 
    icon_list.set_tooltip_column[1];
  end
endfunction


function H1=scicos_default_palettes()
// 
// returns a H table of scicos default palette 
  
  H1 = hash(10);
  
  // describe the structure of the palette hierarchy.
  
  H1.structure= list('Sources','Sinks','Branching','Non_linear',...
		     'Lookup_Tables','Events','Threshold','Others',...
		     'Linear', 'OldBlocks' , 'DemoBlocks', 'Modelica',...
		     list('Modelica','Modelica Electrical',...
			  'Modelica Hydraulics' ,  'Modelica Linear'),...
		     'Matrix' , 'Integer',  'Iterators');
  
  // for each palette describe its contents
  
  H= hash(20);
  
  H.Sources =...
      ['CONST_m';'GENSQR_f';'RAMP';  
       'RAND_m';'RFILE_f';
       'CLKINV_f'; 'CURV_f';  'INIMPL_f'; 'READAU_f';
       'SAWTOOTH_f'; 'STEP_FUNCTION';
       'CLOCK_c'; 'GENSIN_f'; 'IN_f';   'READC_f';
       'TIME_f'; 'Modulo_Count';'Sigbuilder';'Counter';
       'SampleCLK';'TKSCALE';'GTKRANGE';'FROMWSB';'Ground_g';
       'PULSE_SC';'GEN_SQR';'BUSIN_f';'SENSOR_f'];
  
  H.Sinks = ...
      ['AFFICH_m';   'CMSCOPE';
       'CSCOPXY';   'WRITEC_f';
       'CANIMXY';   'CSCOPE';
       'OUTIMPL_f'; 
       'CLKOUTV_f';  'CEVENTSCOPE';
       'OUT_f';      'WFILE_f';
       'CFSCOPE';   'WRITEAU_f';
       'CSCOPXY3D';   'CANIMXY3D';
       'CMATVIEW';	'CMAT3D'; 
       'TOWS_c';'BUSOUT_f';'ACTUATOR_f';
       'SLIDER_f'; 'SLIDER_m'];
  
  H.Branching = ...
      ['DEMUX';
       'MUX'; 'NRMSOM_f';  'EXTRACTOR';
       'SELECT_m';'ISELECT_m';
       'RELAY_f';'IFTHEL_f';
       'ESELECT_f';'M_SWITCH';'SWITCH2_s';
       'SCALAR2VECTOR';'SWITCH_f';'EDGE_TRIGGER';
       'Extract_Activation';'GOTO';'FROM';
       'GotoTagVisibility';'CLKGOTO';'CLKFROM';
       'CLKGotoTagVisibility';'GOTOMO';'FROMMO';
       'GotoTagVisibilityMO';'BUSCREATOR';'BUSSELECTOR';
       'TRANSMIT';'M_VSWITCH']
  
  H.Non_linear = ...
      ['ABS_VALUEi'; 'TrigFun';
       'EXPBLK_m';  'INVBLK';
       'LOGBLK_f'; 'LOOKUP_f'; 'MAXMIN';
       'POWBLK_f'; 'PROD_f';
       'PRODUCT';  'QUANT_f';'EXPRESSION';
       'SATURATION'; 'SIGNUM';'CONSTRAINT_c']

  H.Lookup_Tables = ...
      ['LOOKUP_c';'LOOKUP2D' ; 'INTRPLBLK_f'; 'INTRP2BLK_f']
  
  H.Events = ...
      ['ANDBLK';'HALT_f';'freq_div';
       'ANDLOG_f';'EVTDLY';'IFTHEL_f';'ESELECT_f';
       'CLKSOMV_f';'CLOCK_c';'EVTGEN_f';'EVTVARDLY';
       'M_freq';'SampleCLK';'VirtualCLK0';'SyncTag']

  H.Threshold=...
      [  'NEGTOPOS_f';  'POSTONEG_f';  'ZCROSS_f'];
  
  H.Others = ...
      ['fortran_block';
       'SUPER_f';'scifunc_block_m';'scifunc_block5';
       'TEXT_f';'CBLOCK4';'RATELIMITER';
       'BACKLASH';'DEADBAND';'EXPRESSION';
       'HYSTHERESIS';'DEBUG_SCICOS';
       'LOGICAL_OP';'RELATIONALOP';'generic_block3';
       'PDE';'ENDBLK';'AUTOMAT';'Loop_Breaker';
       'PAL_f'];
  H.Linear = ...
      ['DLR';'TCLSS';'DOLLAR_m';
       'CLINDUMMY_f';'DLSS';'REGISTER';'TIME_DELAY';
       'CLR';'GAINBLK';'SAMPHOLD_m';'VARIABLE_DELAY';
       'CLSS';'SUMMATION';'INTEGRAL_m';'SUM_f';
       'DERIV';'PID2';'DIFF_c']
  
  H.OldBlocks= ...
      ['CLOCK_f';'ABSBLK_f';    
       'MAX_f'; 'MIN_f';'SAT_f'; 'MEMORY_f';
       'CLKSOM_f';'TRASH_f';'GENERAL_f';'DIFF_f';
       'BIGSOM_f';'INTEGRAL_f';'GAINBLK_f';
       'DELAYV_f';'DELAY_f'; 'DEMUX_f';'MUX_f';
       'MFCLCK_f';'MCLOCK_f';'COSBLK_f';   'DLRADAPT_f';
       'SINBLK_f'; 'TANBLK_f';'generic_block';'RAND_f';
       'DOLLAR_f';'CBLOCK';'c_block';'PID']
  
  H.DemoBlocks=...
      ['BOUNCE';'BOUNCEXY';'BPLATFORM'; ...
       'PENDULUM_ANIM'];
  
  H.Modelica=...
      ['MBLOCK', 'MPBLOCK'];
  
  H('Modelica Electrical')= ...
      ['Capacitor';'Ground';'VVsourceAC';
       'ConstantVoltage';'Inductor';'PotentialSensor';
       'VariableResistor';'CurrentSensor';'Resistor';
       'VoltageSensor';'Diode';'VsourceAC';
       'NPN';'PNP';'SineVoltage';'Switch';
       'OpAmp';'PMOS';'NMOS';'CCS';'CVS';
       'IdealTransformer';'Gyrator'];
  
  H('Modelica Hydraulics') = ...
      ['Bache';'VanneReglante';'PerteDP';
       'PuitsP';'SourceP';'Flowmeter'];
  
  H('Modelica Linear')=...
      ['Actuator';'Constant';'Feedback'; 
       'Gain';'Limiter';'PI';'Sensor';'PT1';
       'SecondOrder'; 'TanTF'; 'AtanTF'; 'FirstOrder';
       'SineTF'; 'Sine'];
  
  H.Matrix = ...
      ['MATMUL';'MATTRAN';'MATSING';'MATRESH';'MATDIAG';
       'MATEIG';'MATMAGPHI';'EXTRACT';'MATEXPM';'MATDET';
       'MATPINV';'EXTTRI';'RICC';'ROOTCOEF';'MATCATH';
       'MATLU';'MATDIV';'MATZCONJ';'MATZREIM';'SUBMAT';
       'MATBKSL';'MATINV';'MATCATV';'MATSUM'; ...
       'CUMSUM';
       'SQRT';'Assignment']

  H.Integer = ...
      ['BITCLEAR';'BITSET';'CONVERT';'EXTRACTBITS';'INTMUL';
       'SHIFT';'LOGIC';'DLATCH';'DFLIPFLOP';'JKFLIPFLOP';
       'SRFLIPFLOP']
  
  H.Iterators= ...
      ['ForIterator';'WhileIterator'];

  H1.contents = H;
endfunction
