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
    if ~H.contents.iskey[name] then return;end
    S= H.contents(name);
    icon_list=scicos_build_iconlist(S);
    icon_list.show[];
    L=sw.get_children[];
    if length(L)>=1  then 
      sw.remove[L(1)];
    end
    sw.add[icon_list];
  endfunction
  
  function remove_scicos_widget(wingtkid)
    global scicos_widgets
    for i=1:length(scicos_widgets)
      if wingtkid.equal[scicos_widgets(i).id] then
        scicos_widgets(i).open=%f;break
      end
    end
  endfunction

  // Icon list 
  
  icon_list=scicos_build_iconlist(H.contents(H.first));
  // icon list in scrolled window 
  scrolled_window = gtkscrolledwindow_new();
  scrolled_window.add[ icon_list];
  scrolled_window.set_policy[ GTK.POLICY_AUTOMATIC, GTK.POLICY_AUTOMATIC];
  // 
  combobox2.connect["changed", combo2_changed,list(scrolled_window,H) ];
  vbox.pack_start[scrolled_window, expand=%t,fill= %t,padding=0];
  window.connect["destroy", remove_scicos_widget, list(window)];
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
  
  if exists('coselica_path') then
    coselica_icon_path= coselica_path + '/macros/icons/';
  end
    
  icons = glob(scicos_icon_path);
  
  dir_logo = scicos_icon_path + 'gtk-directory.png';
  pixbuf_dir = gdk_pixbuf_new_from_file(dir_logo);
  pixbuf_def = gdk_pixbuf_new_from_file(scicos_icon_path + 'VOID.png');

  // get data for palette j 
  
  for j=1:size(S,'*');
    icon = scicos_icon_path + S(j) + '.png' ;
    ok = execstr('pixbuf = gdk_pixbuf_new_from_file(icon);',errcatch=  %t);
    if ~ok then 
      if exists('coselica_path') then
	icon = coselica_icon_path + S(j) + '.png' ;
	ok = execstr('pixbuf = gdk_pixbuf_new_from_file(icon);',errcatch=  %t);
	if ~ok 
	  pixbuf = pixbuf_def
	  lasterror();
	end
      else
	pixbuf = pixbuf_def
	lasterror();
      end
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
			  'Modelica Hydraulics' , 'Foo', list('Sources')),...
		     'Matrix' , 'Integer',  'Iterators');
  
  H1.first = 'Sources';
  
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


function H1=coselica_default_palettes()
// returns a H table of scicos default palette 
  
  H1 = hash(10);
  
  // describe the structure of the palette hierarchy.
  
  H1.structure= list('Blocks',...
		     list('Interface','Routing','Math','Math Vectors','Coselica Sources','Continuous','Non Linear'),...
		     'Electrical',...
		     list('Basic','Ideal','Semiconductors','E. Sensors','E. Sources'),...
		     'Mechanics',...
		     list('Translational', list('T. Components', 'T. Sources', 'T. Sensors'),...
			  'Rotational', list('R. Components', 'R. Sources', 'R. Sensors'),...
			  'Planar',list('World','Forces','Joints','LoopJoints','Parts',...
					'Sensors',list('Sensors','Absolute Sensors','Relative Sensors'))),...
		     'Heat Transfer',...
		     list('H. Components','H. Sources','H. Sensors','H. Celcius'),...
		     'Obsolete');

  H1.first = 'Interface';
  
  // for each palette describe its contents

  H=hash(30);
  
  H('Interface')= ...
      ["CBI_RealInput" ;// "Coselica.Blocks.Interfaces.RealInput"
       "CBI_RealOutput"];// "Coselica.Blocks.Interfaces.RealOutput"

  H('Routing')=...
      ["CBR_DeMultiplex2"//"Coselica.Blocks.Routing.DeMultiplex2"
       "CBR_Multiplex2"//"Coselica.Blocks.Routing.Multiplex2"
       "CBR_Replicator"//"Coselica.Blocks.Routing.Replicator"
       "CBR_Extractor"//"Coselica.Blocks.Routing.Extractor"
       "CBR_DeMultiplexVector2"//"Coselica.Blocks.Routing.DeMultiplexVector2"
       "CBR_MultiplexVector2"];//"Coselica.Blocks.Routing.MultiplexVector2"

  H('Math')= ...
      ["MBM_Gain"//"Modelica.Blocks.Math.Gain"
       "MBM_Feedback"//"Modelica.Blocks.Math.Feedback"
       "MBM_Add"//"Modelica.Blocks.Math.Add"
       "CBM_Add3"//"Coselica.Blocks.Math.Add3"
       "MBM_Product"//"Modelica.Blocks.Math.Product"
       "MBM_Division"//"Modelica.Blocks.Math.Division"
       "MBM_Min"//"Modelica.Blocks.Math.Min"
       "MBM_Max"//"Modelica.Blocks.Math.Max"
       "MBM_Abs"//"Modelica.Blocks.Math.Abs"
       "MBM_Sign"//"Modelica.Blocks.Math.Sign"
       "MBM_Sqrt"//"Modelica.Blocks.Math.Sqrt"
       "MBM_Exp"//"Modelica.Blocks.Math.Exp"
       "MBM_Log"//"Modelica.Blocks.Math.Log"
       "MBM_Log10"//"Modelica.Blocks.Math.Log10"
       "MBM_Sin"//"Modelica.Blocks.Math.Sin"
       "MBM_Cos"//"Modelica.Blocks.Math.Cos"
       "MBM_Tan"//"Modelica.Blocks.Math.Tan"
       "MBM_Asin"//"Modelica.Blocks.Math.Asin"
       "MBM_Acos"//"Modelica.Blocks.Math.Acos"
       "MBM_Atan"//"Modelica.Blocks.Math.Atan"
       "CBM_Atan2"//"Coselica.Blocks.Math.Atan2"
       "MBM_Sinh"//"Modelica.Blocks.Math.Sinh"
       "MBM_Cosh"//"Modelica.Blocks.Math.Cosh"
       "MBM_Tanh"//"Modelica.Blocks.Math.Tanh"
       "CBM_TwoInputs"//"Coselica.Blocks.Math.TwoInputs"
       "CBM_TwoOutputs"];//"Coselica.Blocks.Math.TwoOutputs"

  H('Math Vectors')= ...
      ["CBM_Sum"//"Coselica.Blocks.Math.Sum"
       "CBMV_Add"//"Coselica.Blocks.Math.Vectors.Add"
       "CBMV_DotProduct"//"Coselica.Blocks.Math.Vectors.DotProduct"
       "CBMV_ElementwiseProduct"//"Coselica.Blocks.Math.Vectors.ElementwiseProduct"
       "CBMV_CrossProduct"];//"Coselica.Blocks.Math.Vectors.CrossProduct"

  H('Coselica Sources')= ...      
      ["MBS_Constant"//"Modelica.Blocks.Sources.Constant"
       "MBS_Step"//"Modelica.Blocks.Sources.Step"
       "MBS_Ramp"//"Modelica.Blocks.Sources.Ramp"
       "MBS_Sine"//"Modelica.Blocks.Sources.Sine"
       "MBS_ExpSine"//"Modelica.Blocks.Sources.ExpSine"
       "MBS_Exponentials"//"Modelica.Blocks.Sources.Exponentials"
       "MBS_Clock"//"Modelica.Blocks.Sources.Exponentials"
       "CBS_Pulse"//"Coselica.Blocks.Sources.Pulse"
       "CBS_SawTooth"//"Coselica.Blocks.Sources.SawTooth"
       "CBS_Trapezoid"];//"Coselica.Blocks.Sources.Trapezoid"

  H('Continuous')=...
      ["MBC_Integrator"//"Modelica.Blocks.Continuous.Integrator"
       "MBC_LimIntegrator"//"Modelica.Blocks.Continuous.LimIntegrator"
       "MBC_Der"//"Modelica.Blocks.Continuous.Der"
       "MBC_Derivative"//"Modelica.Blocks.Continuous.Derivative"
       "MBC_FirstOrder"//"Modelica.Blocks.Continuous.FirstOrder"
       "MBC_SecondOrder"//"Modelica.Blocks.Continuous.SecondOrder"
       "MBC_PI"//"Modelica.Blocks.Continuous.PI"
       "MBC_PID"//"Modelica.Blocks.Continuous.PID"
       "MBC_LimPID"];//"Modelica.Blocks.Continuous.LimPID"

  H('Non Linear')=...
      ["MBN_Limiter"//"Modelica.Blocks.Nonlinear.Limiter"
       "MBN_DeadZone"//"Modelica.Blocks.Nonlinear.DeadZone"
       "CBN_Hysteresis"//"Coselica.Blocks.Nonlinear.Hysteresis"
       "CBN_RateLimiter"];//"Coselica.Blocks.Nonlinear.RateLimiter"

  H('Basic')= ...
      ["MEAB_Ground"//"Modelica.Electrical.Analog.Basic.Ground"
       "MEAB_Resistor"//"Modelica.Electrical.Analog.Basic.Resistor"
       "MEAB_HeatingResistor"//"Modelica.Electrical.Analog.Basic.HeatingResistor"
       "MEAB_Capacitor"//"Modelica.Electrical.Analog.Basic.Capacitor"
       "MEAB_Inductor"//"Modelica.Electrical.Analog.Basic.Inductor"
       "MEAB_Transformer"//"Modelica.Electrical.Analog.Basic.Transformer"
       "MEAB_Gyrator"//"Modelica.Electrical.Analog.Basic.Gyrator"
       "CEAB_EMF0"//"Coselica.Electrical.Analog.Basic.EMF0"
       "CEAB_EMF"//"Coselica.Electrical.Analog.Basic.EMF"
       "CEAB_TranslationalEMF0"//"Coselica.Electrical.Analog.Basic.TranslationalEMF0"
       "CEAB_TranslationalEMF"//"Coselica.Electrical.Analog.Basic.TranslationalEMF"
       "MEAB_VCV"//"Modelica.Electrical.Analog.Basic.VCV"
       "MEAB_VCC"//"Modelica.Electrical.Analog.Basic.VCC"
       "MEAB_CCV"//"Modelica.Electrical.Analog.Basic.CCV"
       "MEAB_CCC"//"Modelica.Electrical.Analog.Basic.CCC"
       "MEAB_OpAmp"//"Modelica.Electrical.Analog.Basic.OpAmp"
       "MEAB_VariableResistor"//"Modelica.Electrical.Analog.Basic.VariableResistor"
       "MEAB_VariableCapacitor"//"Modelica.Electrical.Analog.Basic.VariableCapacitor"
       "MEAB_VariableInductor"];//"Modelica.Electrical.Analog.Basic.VariableInductor"

  H('Ideal')=...
      ["CEAI_IdealDiode"//"Coselica.Electrical.Analog.Ideal.IdealDiode"
       "MEAI_IdealTransformer"//"Modelica.Electrical.Analog.Ideal.IdealTransformer"
       "MEAI_IdealGyrator"//"Modelica.Electrical.Analog.Ideal.IdealGyrator"
       "MEAI_Idle"//"Modelica.Electrical.Analog.Ideal.Idle"
       "MEAI_Short"//"Modelica.Electrical.Analog.Ideal.Short"
       "MEAI_IdealOpeningSwitch"//"Modelica.Electrical.Analog.Ideal.IdealOpeningSwitch"
       "MEAI_IdealClosingSwitch"];//"Modelica.Electrical.Analog.Ideal.IdealClosingSwitch"

  H('Semiconductors')=...
      ["MEAS_Diode"//"Modelica.Electrical.Analog.Semiconductors.Diode"
       "CEAS_ZDiode"//"Coselica.Electrical.Analog.Semiconductors.ZDiode"
       "MEAS_PMOS"//"Modelica.Electrical.Analog.Semiconductors.PMOS"
       "MEAS_NMOS"//"Modelica.Electrical.Analog.Semiconductors.NMOS"
       "MEAS_NPN"//"Modelica.Electrical.Analog.Semiconductors.NPN"
       "MEAS_PNP"//"Modelica.Electrical.Analog.Semiconductors.PNP"
       "CEAS_Thyristor"];//"Coselica.Electrical.Analog.Semiconductors.Thyristor"

  H('E. Sensors')=...
      ["MEAS_PotentialSensor"//"Modelica.Electrical.Analog.Sensors.PotentialSensor"
       "MEAS_VoltageSensor"//"Modelica.Electrical.Analog.Sensors.VoltageSensor"
       "MEAS_CurrentSensor"//"Modelica.Electrical.Analog.Sensors.CurrentSensor"
       "CEAS_PowerSensor"];//"Coselica.Electrical.Analog.Sensors.PowerSensor"

  H('E. Sources')=...
      ["MEAS_SignalVoltage"//"Modelica.Electrical.Analog.Sources.SignalVoltage"
       "MEAS_ConstantVoltage"//"Modelica.Electrical.Analog.Sources.ConstantVoltage"
       "MEAS_StepVoltage"//"Modelica.Electrical.Analog.Sources.StepVoltage"
       "MEAS_RampVoltage"//"Modelica.Electrical.Analog.Sources.RampVoltage"
       "MEAS_SineVoltage"//"Modelica.Electrical.Analog.Sources.SineVoltage"
       "MEAS_PulseVoltage"//"Modelica.Electrical.Analog.Sources.PulseVoltage"
       "MEAS_SawToothVoltage"//"Modelica.Electrical.Analog.Sources.SawToothVoltage"
       "CEAS_TrapezoidVoltage"//"Coselica.Electrical.Analog.Sources.TrapezoidVoltage"
       "MEAS_SignalCurrent"//"Modelica.Electrical.Analog.Sources.SignalCurrent"
       "MEAS_ConstantCurrent"//"Modelica.Electrical.Analog.Sources.ConstantCurrent"
       "MEAS_StepCurrent"//"Modelica.Electrical.Analog.Sources.StepCurrent"
       "MEAS_RampCurrent"//"Modelica.Electrical.Analog.Sources.RampCurrent"
       "MEAS_SineCurrent"//"Modelica.Electrical.Analog.Sources.SineCurrent"
       "MEAS_PulseCurrent"//"Modelica.Electrical.Analog.Sources.PulseCurrent"
       "MEAS_SawToothCurrent"//"Modelica.Electrical.Analog.Sources.SawToothCurrent"
       "CEAS_TrapezoidCurrent"];//"Coselica.Electrical.Analog.Sources.TrapezoidCurrent"

  H('T. Components')=...
      ["MMT_Fixed"//"Modelica.Mechanics.Translational.Fixed"
       "CMTC_Free"//"Coselica.Mechanics.Translational.Components.Free"
       "CMTC_Mass"//"Coselica.Mechanics.Translational.Components.Mass"
       "CMTC_MassWithWeight"//"Coselica.Mechanics.Translational.Components.MassWithWeight"
       "MMT_Rod"//"Modelica.Mechanics.Translational.Rod"
       "MMT_Spring"//"Modelica.Mechanics.Translational.Spring"
       "MMT_Damper"//"Modelica.Mechanics.Translational.Damper"
       "MMT_SpringDamper"//"Modelica.Mechanics.Translational.SpringDamper"
       "CMTC_ElastoGap"//"Coselica.Mechanics.Translational.Components.ElastoGap"
       "CMT_MassWithFriction"//"Coselica.Mechanics.Translational.MassWithFriction"
       "CMT_Stop"//"Coselica.Mechanics.Translational.Stop"
       "CMTC_Pulley"//"Coselica.Mechanics.Translational.Components.Pulley"
       "CMTC_ActuatedPulley"//"Coselica.Mechanics.Translational.Components.ActuatedPulley"
       "CMTC_Lever"];//"Coselica.Mechanics.Translational.Components.Lever"

  H('T. Sources')=...
      ["CMTS_Position0"//"Coselica.Mechanics.Translational.Sources.Position0"
       "CMTS_Speed0"//"Coselica.Mechanics.Translational.Sources.Speed0"
       "CMTS_Accelerate0"//"Coselica.Mechanics.Translational.Sources.Accelerate0"
       "CMTS_Force0"//"Coselica.Mechanics.Translational.Sources.Force0"
       "CMTS_Position"//"Coselica.Mechanics.Translational.Sources.Position"
       "CMTS_Speed"//"Coselica.Mechanics.Translational.Sources.Speed"
       "CMTS_Accelerate"//"Coselica.Mechanics.Translational.Sources.Accelerate"
       "CMTS_Force"//"Coselica.Mechanics.Translational.Sources.Force"
       "CMTS_Force2"//"Coselica.Mechanics.Translational.Sources.Force2"
       "CMTS_ConstantForce"//"Coselica.Mechanics.Translational.Sources.ConstantForce"
       "CMTS_ConstantSpeed"//"Coselica.Mechanics.Translational.Sources.ConstantSpeed"
       "CMTS_ForceStep"//"Coselica.Mechanics.Translational.Sources.ForceStep"
       "CMTS_LinearSpeedDependen"//"Coselica.Mechanics.Translational.Sources.LinearSpeedDependentForce"
       "CMTS_QuadraticSpeedDepen"];//"Coselica.Mechanics.Translational.Sources.QuadraticSpeedDependentForce"
  H('T. Sensors')=...
      ["CMTS_PositionSensor"//"Coselica.Mechanics.Translational.Sensors.PositionSensor"
       "CMTS_SpeedSensor"//"Coselica.Mechanics.Translational.Sensors.SpeedSensor"
       "CMTS_AccSensor"//"Coselica.Mechanics.Translational.Sensors.AccSensor"
       "CMTS_RelPositionSensor"//"Coselica.Mechanics.Translational.Sensors.RelPositionSensor"
       "CMTS_RelSpeedSensor"//"Coselica.Mechanics.Translational.Sensors.RelSpeedSensor"
       "CMTS_RelAccSensor"//"Coselica.Mechanics.Translational.Sensors.RelAccSensor"
       "CMTS_ForceSensor"//"Coselica.Mechanics.Translational.Sensors.ForceSensor"
       "CMTS_PowerSensor"];//"Coselica.Mechanics.Translational.Sensors.PowerSensor"
  H('R. Components')=...
      ["MMR_Fixed"//"Modelica.Mechanics.Rotational.Fixed"
       "CMRC_Free"//"Coselica.Mechanics.Rotational.Components.Free"
       "MMR_Inertia"//"Modelica.Mechanics.Rotational.Inertia"
       "CMRC_Disc"//"Coselica.Mechanics.Rotational.Components.Disc"
       "MMR_Spring"//"Modelica.Mechanics.Rotational.Spring"
       "MMR_Damper"//"Modelica.Mechanics.Rotational.Damper"
       "MMR_SpringDamper"//"Modelica.Mechanics.Rotational.SpringDamper"
       "CMRC_ElastoBacklash"//"Coselica.Mechanics.Rotational.Components.ElastoBacklash"
       "CMR_BearingFriction"//"Coselica.Mechanics.Rotational.BearingFriction"
       "CMR_Brake"//"Coselica.Mechanics.Rotational.Brake"
       "CMR_Clutch"//"Coselica.Mechanics.Rotational.Clutch"
       "CMR_OneWayClutch"//"Coselica.Mechanics.Rotational.OneWayClutch"
       "CMR_Freewheel"//"Coselica.Mechanics.Rotational.Freewheel"
       "MMR_IdealGear"//"Modelica.Mechanics.Rotational.IdealGear"
       "MMR_IdealPlanetary"//"Modelica.Mechanics.Rotational.IdealPlanetary"
       "CMRC_IdealDifferential"//"Coselica.Mechanics.Rotational.Components.IdealDifferential"
       "MMR_IdealGearR2T"];//"Modelica.Mechanics.Rotational.IdealGearR2T"
  H('R. Sources')=...
      ["CMRS_Position0"//"Coselica.Mechanics.Rotational.Sources.Position0"
       "CMRS_Speed0"//"Coselica.Mechanics.Rotational.Sources.Speed0"
       "CMRS_Accelerate0"//"Coselica.Mechanics.Rotational.Sources.Accelerate0"
       "CMRS_Torque0"//"Coselica.Mechanics.Rotational.Sources.Torque0"
       "CMRS_Position"//"Coselica.Mechanics.Rotational.Sources.Position"
       "CMRS_Speed"//"Coselica.Mechanics.Rotational.Sources.Speed"
       "CMRS_Accelerate"//"Coselica.Mechanics.Rotational.Sources.Accelerate"
       "CMRS_Torque"//"Coselica.Mechanics.Rotational.Sources.Torque"
       "CMRS_Torque2"//"Coselica.Mechanics.Rotational.Sources.Torque2"
       "CMRS_ConstantTorque"//"Coselica.Mechanics.Rotational.Sources.ConstantTorque"
       "CMRS_ConstantSpeed"//"Coselica.Mechanics.Rotational.Sources.ConstantSpeed"
       "CMRS_TorqueStep"//"Coselica.Mechanics.Rotational.Sources.TorqueStep"
       "CMRS_LinearSpeedDependen"//"Coselica.Mechanics.Rotational.Sources.LinearSpeedDependentTorque"
       "CMRS_QuadraticSpeedDepen"];//"Coselica.Mechanics.Rotational.Sources.QuadraticSpeedDependentTorque"

  H('R. Sensors')=...
      ["MMRS_AngleSensor"//"Modelica.Mechanics.Rotational.Sensors.AngleSensor"
       "MMRS_SpeedSensor"//"Modelica.Mechanics.Rotational.Sensors.SpeedSensor"
       "MMRS_AccSensor"//"Modelica.Mechanics.Rotational.Sensors.AccSensor"
       "MMRS_RelAngleSensor"//"Modelica.Mechanics.Rotational.Sensors.RelAngleSensor"
       "MMRS_RelSpeedSensor"//"Modelica.Mechanics.Rotational.Sensors.RelSpeedSensor"
       "MMRS_RelAccSensor"//"Modelica.Mechanics.Rotational.Sensors.RelAccSensor"
       "MMRS_TorqueSensor"//"Modelica.Mechanics.Rotational.Sensors.TorqueSensor"
       "CMRS_PowerSensor"];//"Coselica.Mechanics.Rotational.Sensors.PowerSensor"

  H('World')= "CMP_World"//"Coselica.Mechanics.Planar.World"
  H('Forces')=...
      ["CMPF_WorldForce"//"Coselica.Mechanics.Planar.Forces.WorldForce"
       "CMPF_WorldTorque"//"Coselica.Mechanics.Planar.Forces.WorldTorque"
       "CMPF_FrameForce"//"Coselica.Mechanics.Planar.Forces.FrameForce"
       "CMPF_LineForce"//"Coselica.Mechanics.Planar.Forces.LineForce"
       "CMPF_LineForceWithMass"];//"Coselica.Mechanics.Planar.Forces.LineForceWithMass"
  H('Joints')=...
      [ "CMPJ_FreeMotion"//"Coselica.Mechanics.Planar.Joints.FreeMotion"
	"CMPJ_Prismatic"//"Coselica.Mechanics.Planar.Joints.Prismatic"
	"CMPJ_Revolute"//"Coselica.Mechanics.Planar.Joints.Revolute"
	"CMPJ_ActuatedPrismatic"//"Coselica.Mechanics.Planar.Joints.ActuatedPrismatic"
	"CMPJ_ActuatedRevolute"//"Coselica.Mechanics.Planar.Joints.ActuatedRevolute"
	"CMPJ_RollingWheel"//"Coselica.Mechanics.Planar.Joints.RollingWheel"
	"CMPJ_ActuatedRollingWhee"];//"Coselica.Mechanics.Planar.Joints.ActuatedRollingWheel"
  H('LoopJoints')=...
      ["CMPL_Prismatic"//"Coselica.Mechanics.Planar.LoopJoints.Prismatic"
       "CMPL_Revolute"//"Coselica.Mechanics.Planar.LoopJoints.Revolute"
       "CMPL_ActuatedPrismatic"//"Coselica.Mechanics.Planar.LoopJoints.ActuatedPrismatic"
       "CMPL_ActuatedRevolute"];//"Coselica.Mechanics.Planar.LoopJoints.ActuatedRevolute"
  
  H('Parts')=...
      ["CMPP_Fixed"//"Coselica.Mechanics.Planar.Parts.Fixed"
       "CMPP_FixedTranslation"//"Coselica.Mechanics.Planar.Parts.FixedTranslation"
       "CMPP_FixedRotation"//"Coselica.Mechanics.Planar.Parts.FixedRotation"
       "CMPP_Body"//"Coselica.Mechanics.Planar.Parts.Body"
       "CMPP_BodyShape"//"Coselica.Mechanics.Planar.Parts.BodyShape"
       "CMPP_PointMass"];//"Coselica.Mechanics.Planar.Parts.PointMass"

  H('Sensors')=...
      ["CMPS_Distance"//"Coselica.Mechanics.Planar.Sensors.Distance"
       "CMPS_CutForce"//"Coselica.Mechanics.Planar.Sensors.CutForce"
       "CMPS_CutForce2"//"Coselica.Mechanics.Planar.Sensors.CutForce2"
       "CMPS_CutTorque"//"Coselica.Mechanics.Planar.Sensors.CutTorque"
       "CMPS_Power"];//"Coselica.Mechanics.Planar.Sensors.Power"
  
  H('Absolute Sensors')=...
      ["CMPS_AbsPosition"//"Coselica.Mechanics.Planar.Sensors.AbsPosition"
       "CMPS_AbsVelocity"//"Coselica.Mechanics.Planar.Sensors.AbsVelocity"
       "CMPS_AbsAcceleration"//"Coselica.Mechanics.Planar.Sensors.AbsAcceleration"
       "CMPS_AbsAngle"//"Coselica.Mechanics.Planar.Sensors.AbsAngle"
       "CMPS_AbsAngularVelocity"//"Coselica.Mechanics.Planar.Sensors.AbsAngularVelocity"
       "CMPS_AbsAngularAccelerat"//"Coselica.Mechanics.Planar.Sensors.AbsAngularAcceleration"
       "CMPS_AbsPosition2"//"Coselica.Mechanics.Planar.Sensors.AbsPosition2"
       "CMPS_AbsVelocity2"//"Coselica.Mechanics.Planar.Sensors.AbsVelocity2"
       "CMPS_AbsAcceleration2"];//"Coselica.Mechanics.Planar.Sensors.AbsAcceleration2"
  
  H('Relative Sensors')=...
      ["CMPS_RelPosition"//"Coselica.Mechanics.Planar.Sensors.RelPosition"
       "CMPS_RelVelocity"//"Coselica.Mechanics.Planar.Sensors.RelVelocity"
       "CMPS_RelAcceleration"//"Coselica.Mechanics.Planar.Sensors.RelAcceleration"
       "CMPS_Angle"//"Coselica.Mechanics.Planar.Sensors.Angle"
       "CMPS_RelAngularVelocity"//"Coselica.Mechanics.Planar.Sensors.RelAngularVelocity"
       "CMPS_RelAngularAccelerat"//"Coselica.Mechanics.Planar.Sensors.RelAngularAcceleration"
       "CMPS_RelPosition2"//"Coselica.Mechanics.Planar.Sensors.RelPosition2"
       "CMPS_RelVelocity2"//"Coselica.Mechanics.Planar.Sensors.RelVelocity2"
       "CMPS_RelAcceleration2"];//"Coselica.Mechanics.Planar.Sensors.RelAcceleration2"

  H('H. Components')=...
      ["MTH_HeatCapacitor"
       "MTH_ThermalConductor"//"Modelica.Thermal.HeatTransfer.HeatCapacitor"
       "MTH_Convection"//"Modelica.Thermal.HeatTransfer.Convection"
       "MTH_BodyRadiation"];//"Modelica.Thermal.HeatTransfer.BodyRadiation"
       
  H('H. Sources')=...
      ["MTH_FixedTemperature"//"Modelica.Thermal.HeatTransfer.FixedTemperature"
       "MTH_PrescribedTemperatur"//"Modelica.Thermal.HeatTransfer.PrescribedTemperature"
       "MTH_FixedHeatFlow"//"Modelica.Thermal.HeatTransfer.FixedHeatFlow"
       "MTH_PrescribedHeatFlow"];//"Modelica.Thermal.HeatTransfer.PrescribedHeatFlow"
  
   H('H. Sensors')=...
       ["MTH_TemperatureSensor"//"Modelica.Thermal.HeatTransfer.TemperatureSensor"
	"MTH_RelTemperatureSensor"//"Modelica.Thermal.HeatTransfer.RelTemperatureSensor"
	"MTH_HeatFlowSensor"];//"Modelica.Thermal.HeatTransfer.HeatFlowSensor"
   
   H('H. Celcius')=...
       ["MTHC_ToKelvin"//"Modelica.Thermal.HeatTransfer.Celsius.ToKelvin"
       "MTHC_FromKelvin"//"Modelica.Thermal.HeatTransfer.Celsius.FromKelvin"
       "MTHC_FixedTemperature"//"Modelica.Thermal.HeatTransfer.Celsius.FixedTemperature"
       "MTHC_PrescribedTemperatu"//"Modelica.Thermal.HeatTransfer.Celsius.PrescribedTemperature"
       "MTHC_TemperatureSensor"];//"Modelica.Thermal.HeatTransfer.Celsius.TemperatureSensor"
	
   H('Obsolete')=...
       ["MMT_SlidingMass"//"Modelica.Mechanics.Translational.SlidingMass"
       "CMT_Position"//"Modelica.Blocks.Sources.Pulse"
       "CMT_Speed"//"Coselica.Mechanics.Translational.Speed"
       "MMT_Accelerate"//"Modelica.Mechanics.Translational.Accelerate"
       "MMT_Force"//"Modelica.Mechanics.Translational.Force"
       "MEAB_EMF"//"Modelica.Electrical.Analog.Basic.EMF"
       "CMR_Position"//"Coselica.Mechanics.Rotational.Position"
       "CMR_Speed"//"Coselica.Mechanics.Rotational.Speed"
       "MMR_Accelerate"//"Modelica.Mechanics.Rotational.Accelerate"
       "MMR_Torque"//"Modelica.Mechanics.Rotational.Torque"
       "MMR_Torque2"//"Modelica.Mechanics.Rotational.Torque2"
       "MMR_ConstantTorque"//"Modelica.Mechanics.Rotational.ConstantTorque"
       "MMR_ConstantSpeed"//"Modelica.Mechanics.Rotational.ConstantSpeed"
       "MMR_TorqueStep"//"Modelica.Mechanics.Rotational.TorqueStep"
       "MMR_LinearSpeedDependent"//"Modelica.Mechanics.Rotational.LinearSpeedDependentTorque"
       "MMR_QuadraticSpeedDepend"];//"Modelica.Mechanics.Rotational.QuadraticSpeedDependentTorque"
  H1.contents = H;
  
endfunction

