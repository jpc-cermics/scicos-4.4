function routines=create_palette(bidon)
//load SCI/macros/scicos/lib;
  if nargin < 1 then bidon='all';end
  scicos_ver='scicos2.7.3'
  lisf=glob('*.sci');
  if nargin == 0 then
    // search the current directory for all the *.sci 
    // and load the blocks functions 
    Path=getcwd();
    to_del=[]
    for i=1:size(lisf,'*')
      fil=lisf(i)
      ierror=execstr('getf(fil)','errcatch')
      if ierror <>0 then
	to_del=[to_del i];
      end
    end
    lisf(to_del)=[];
    [path,fname,ext]=splitfilepath(Path);
    path=path+fname
    build_palette(lisf,path,fname)
  else
    savepwd=getcwd()
    //chdir(SCI+'/macros/scicos/')
    chdir( scicos_path+'/macros/blocks/palettes')
    //exec(loadpallibs,-1) 
    //path='SCI/macros/scicos_blocks'
    path=scicos_path+'/macros/blocks'
    
    if bidon=='all' then
      bidon=scicos_get_palette_content('all');
    else
      bidon=bidon(:)'
    end
    routines=[];
    for i=1:size(bidon,'*') 
      txt = bidon(i);
      printf('Constructing %s\n',txt)
      lisf=scicos_get_palette_content(txt);
      if isempty(lisf) then 
	printf('Palette '+txt+' does not exists\n')
      else 
	// here we could decide to create a .cos or a .cosf 
	routines=[routines;build_palette(lisf,path,txt+'.cos')];
      end
    end
    chdir(savepwd)
  end
  routines=unique(routines);
endfunction

function [routines]=build_palette(lisf,path,fname)
  scs_m=scicos_diagram()
  X=0
  Y=0
  yy=0
  sep=30
  routines=m2s([]);
  for k=1:size(lisf,'*')
    fil = lisf(k);
    name= part(fil,1:length(fil)-4)
    ierror=execstr('blk='+name+'(''define'')',errcatch=%t)
    if ierror == %f  then
      message(['Error in '+name+'(''define'')';lasterror()] );
    else 
      routines=[routines;blk.model.sim(1)]
      blk.graphics.sz=20*blk.graphics.sz;
      blk.graphics.orig=[X Y]
      X=X+blk.graphics.sz(1)+sep
      yy=max(yy,blk.graphics.sz(2))
      if X>400 then X=0,Y=Y+yy+sep,yy=0,end
      scs_m.objs($+1)=blk
    end
  end
  // save in file 
  scs_m=scicos_save_in_file(scs_m,list(),fname,scicos_ver);
endfunction



function lisf=scicos_get_palette_content(txt)
// return the objet present in palette named txt 
//
  if txt=='all' then
    // return the palette names 
    lisf= ['Sources'; 'Sinks' ;  'Branching'; 'Non_linear';  'Lookup_Tables'; 
	   'Events' ;  'Threshold';  'Others'; 'Linear'; 'OldBlocks' ; 'DemoBlocks' ;
	   'Modelica' ;  'Modelica Electrical';   'Modelica Hydraulics' ;  'Modelica Linear';
	   'Matrix' ; 'Integer';  'Iterators' ];
    
  elseif txt=='Sources' then
    lisf=['CONST_m.sci';'GENSQR_f.sci';'RAMP.sci';  
	  'RAND_m.sci';'RFILE_f.sci';
	  'CLKINV_f.sci'; 'CURV_f.sci';  'INIMPL_f.sci'; 'READAU_f.sci';
	  'SAWTOOTH_f.sci'; 'STEP_FUNCTION.sci';
	  'CLOCK_c.sci'; 'GENSIN_f.sci'; 'IN_f.sci';   'READC_f.sci';
	  'TIME_f.sci'; 'Modulo_Count.sci';'Sigbuilder.sci';'Counter.sci';
	  'SampleCLK.sci';'TKSCALE.sci';'FROMWSB.sci';'Ground_g.sci';
	  'PULSE_SC.sci';'GEN_SQR.sci';'BUSIN_f.sci';'SENSOR_f.sci']
  
  elseif txt=='Sinks' then
    lisf=['AFFICH_m.sci';   'CMSCOPE.sci';
	  'CSCOPXY.sci';   'WRITEC_f.sci';
	  'CANIMXY.sci';   'CSCOPE.sci';
	  'OUTIMPL_f.sci'; 
	  'CLKOUTV_f.sci';  'CEVENTSCOPE.sci';
	  'OUT_f.sci';      'WFILE_f.sci';
	  'CFSCOPE.sci';   'WRITEAU_f.sci';
	  'CSCOPXY3D.sci';   'CANIMXY3D.sci';
	  'CMATVIEW.sci';	'CMAT3D.sci'; 
	  'TOWS_c.sci';'BUSOUT_f.sci';'ACTUATOR_f.sci']
  
  elseif txt=='Branching' then
    lisf=['DEMUX.sci';
	  'MUX.sci'; 'NRMSOM_f.sci';  'EXTRACTOR.sci';
	  'SELECT_m.sci';'ISELECT_m.sci';
	  'RELAY_f.sci';'SWITCH2_m.sci';'IFTHEL_f.sci';
	  'ESELECT_f.sci';'M_SWITCH.sci';
	  'SCALAR2VECTOR.sci';'SWITCH_f.sci';'EDGE_TRIGGER.sci';
	  'Extract_Activation.sci';'GOTO.sci';'FROM.sci';
	  'GotoTagVisibility.sci';'CLKGOTO.sci';'CLKFROM.sci';
	  'CLKGotoTagVisibility.sci';'GOTOMO.sci';'FROMMO.sci';
	  'GotoTagVisibilityMO.sci';'BUSCREATOR.sci';'BUSSELECTOR.sci']
	
  elseif txt=='Non_linear' then
	lisf=['ABS_VALUE.sci'; 'TrigFun.sci';
	      'EXPBLK_m.sci';  'INVBLK.sci';
	      'LOGBLK_f.sci'; 'LOOKUP_f.sci'; 'MAXMIN.sci';
	      'POWBLK_f.sci'; 'PROD_f.sci';
	      'PRODUCT.sci';  'QUANT_f.sci';'EXPRESSION.sci';
	      'SATURATION.sci'; 'SIGNUM.sci';'CONSTRAINT_c.sci']

  elseif txt=='Lookup_Tables' then
    lisf=['LOOKUP_c.sci';'LOOKUP2D.sci' ; 'INTRPLBLK_f.sci'; 'INTRP2BLK_f.sci']
    	
  elseif txt=='Events' then
    lisf=['ANDBLK.sci';'HALT_f.sci';'freq_div.sci';
	  'ANDLOG_f.sci';'EVTDLY.sci';'IFTHEL_f.sci';'ESELECT_f.sci';
	  'CLKSOMV_f.sci';'CLOCK_c.sci';'EVTGEN_f.sci';'EVTVARDLY.sci';
	  'M_freq.sci';'SampleCLK.sci';'VirtualCLK0.sci';'SyncTag.sci']

  elseif txt=='Threshold' then
    lisf=[  'NEGTOPOS_f.sci';  'POSTONEG_f.sci';  'ZCROSS_f.sci']
    
  elseif txt=='Others' then
    lisf=['fortran_block.sci';
	  'SUPER_f.sci';'scifunc_block_m.sci';'scifunc_block5.sci';
	  'TEXT_f.sci';'CBLOCK4.sci';'RATELIMITER.sci';
	  'BACKLASH.sci';'DEADBAND.sci';'EXPRESSION.sci';
	  'HYSTHERESIS.sci';'DEBUG_SCICOS.sci';
	  'LOGICAL_OP.sci';'RELATIONALOP.sci';'generic_block3.sci';
	  'PDE.sci';'ENDBLK.sci';'AUTOMAT.sci';'Loop_Breaker.sci'];
    
    //XXXX  'PAL_f.sci']
	
  elseif txt=='Linear' then
    lisf=['DLR.sci';'TCLSS.sci';'DOLLAR_m.sci';
	  'CLINDUMMY_f.sci';'DLSS.sci';'REGISTER.sci';'TIME_DELAY.sci';
	  'CLR.sci';'GAINBLK.sci';'SAMPHOLD_m.sci';'VARIABLE_DELAY.sci';
	  'CLSS.sci';'SUMMATION.sci';'INTEGRAL_m.sci';'SUM_f.sci';
	  'DERIV.sci';'PID2.sci';'DIFF_c.sci']
	
  elseif txt=='OldBlocks' then
    lisf=['CLOCK_f.sci';'ABSBLK_f.sci';    
	  'MAX_f.sci'; 'MIN_f.sci';'SAT_f.sci'; 'MEMORY_f.sci';
	  'CLKSOM_f.sci';'TRASH_f.sci';'GENERAL_f.sci';'DIFF_f.sci';
	  'BIGSOM_f.sci';'INTEGRAL_f.sci';'GAINBLK_f.sci';
	  'DELAYV_f.sci';'DELAY_f.sci'; 'DEMUX_f.sci';'MUX_f.sci';
	  'MFCLCK_f.sci';'MCLOCK_f.sci';'COSBLK_f.sci';   'DLRADAPT_f.sci';
	  'SINBLK_f.sci'; 'TANBLK_f.sci';'generic_block.sci';'RAND_f.sci';
	  'DOLLAR_f.sci';'CBLOCK.sci';'c_block.sci';'PID.sci']

  elseif txt=='DemoBlocks' then
    lisf=['BOUNCE.sci';'BOUNCEXY.sci';'BPLATFORM.sci';'PENDULUM_ANIM.sci']
    
  elseif txt== 'Modelica' then
    lisf=['MBLOCK.sci', 'MPBLOCK.sci'];
    
  elseif txt== 'Modelica Electrical' then
    
    lisf=['Capacitor.sci';'Ground.sci';'VVsourceAC.sci';
	  'ConstantVoltage.sci';'Inductor.sci';'PotentialSensor.sci';
	  'VariableResistor.sci';'CurrentSensor.sci';'Resistor.sci';
	  'VoltageSensor.sci';'Diode.sci';'VsourceAC.sci';
	  'NPN.sci';'PNP.sci';'SineVoltage.sci';'Switch.sci';
	  'OpAmp.sci';'PMOS.sci';'NMOS.sci';'CCS.sci';'CVS.sci';
	  'IdealTransformer.sci';'Gyrator.sci'];
    
  elseif txt== 'Modelica Hydraulics' then
	      
    lisf = ['Bache.sci';'VanneReglante.sci';'PerteDP.sci';
	    'PuitsP.sci';'SourceP.sci';'Flowmeter.sci'];
	
  elseif txt== 'Modelica Linear' then
	      
    lisf =['Actuator.sci';'Constant.sci';'Feedback.sci'; 
	   'Gain.sci';'Limiter.sci';'PI.sci';'Sensor.sci';'PT1.sci';
	   'SecondOrder.sci'; 'TanTF.sci'; 'AtanTF.sci'; 'FirstOrder.sci';
	   'SineTF.sci'; 'Sine.sci'];
    
  elseif txt=='Matrix' then
    lisf=['MATMUL.sci';'MATTRAN.sci';'MATSING.sci';'MATRESH.sci';'MATDIAG.sci';
	  'MATEIG.sci';'MATMAGPHI.sci';'EXTRACT.sci';'MATEXPM.sci';'MATDET.sci';
	  'MATPINV.sci';'EXTTRI.sci';'RICC.sci';'ROOTCOEF.sci';'MATCATH.sci';
	  'MATLU.sci';'MATDIV.sci';'MATZCONJ.sci';'MATZREIM.sci';'SUBMAT.sci';
	  'MATBKSL.sci';'MATINV.sci';'MATCATV.sci';'MATSUM.sci'; ...
	  'CUMSUM.sci';
	  'SQRT.sci';'Assignment.sci']

  elseif txt=='Integer' then
    lisf=['BITCLEAR.sci';'BITSET.sci';'CONVERT.sci';'EXTRACTBITS.sci';'INTMUL.sci';
	  'SHIFT.sci';'LOGIC.sci';'DLATCH.sci';'DFLIPFLOP.sci';'JKFLIPFLOP.sci';
	  'SRFLIPFLOP.sci']
	
  elseif txt=='Iterators' then
    lisf=['ForIterator.sci';'WhileIterator.sci']
    
  else
    lisf=[];
  end
endfunction
