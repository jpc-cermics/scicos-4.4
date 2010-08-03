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
    chdir(getenv('NSP')+'/macros/blocks/palettes')
    //exec(loadpallibs,-1) 
    //path='SCI/macros/scicos_blocks'
    path=getenv('NSP')+'/macros/blocks'
    
    if bidon=='all' then
      bidon=['Sources','Sinks','Branching','Non_linear','Events','Threshold',...
	     'Others','Linear','OldBlocks','DemoBlocks','Electrical','Hydraulics'];
    else
      bidon=bidon(:)'
    end
    
    routines=[];
    for txt=bidon
      printf('Constructing %s\n',txt)
      if txt=='Sources' then
	lisf=['CONST.sci';'GENSQR_f.sci';'RAMP.sci';  
	      'RAND_f.sci';'RFILE_f.sci';
	      'CLKINV_f.sci'; 'CURV_f.sci';  'INIMPL_f.sci'; 'READAU_f.sci';
	      'SAWTOOTH_f.sci'; 'STEP_FUNCTION.sci';
	      'CLOCK_f.sci'; 'GENSIN_f.sci'; 'IN_f.sci';   'READC_f.sci';
	      'TIME_f.sci'; 'Modulo_Count.sci'];
	
      elseif txt=='Sinks' then
	lisf=['AFFICH_f.sci';   'CMSCOPE.sci';       
	      'SCOPXY_f.sci';   'WRITEC_f.sci';
	      'ANIMXY_f.sci';   'CSCOPE.sci';        
	      'OUTIMPL_f.sci'; 
	      'CLKOUTV_f.sci';  'EVENTSCOPE_f.sci';  
	      'OUT_f.sci';      'WFILE_f.sci';
	      'FSCOPE_f.sci';   'WRITEAU_f.sci'; 'SLIDER_f.sci' ];
	
      elseif txt=='Branching' then
	lisf=['DEMUX.sci';
	      'MUX.sci'; 'NRMSOM_f.sci';  'EXTRACTOR.sci';      
	      'SELECT_f.sci'; 'ISELECT_f.sci';     
	      'RELAY_f.sci';'SWITCH2.sci';'IFTHEL_f.sci';
	      'ESELECT_f.sci';   'M_SWITCH.sci';  
	      'SCALAR2VECTOR.sci';  'SWITCH_f.sci';
	      'TRANSMIT.sci'; 'M_VSWITCH.sci' ];
	
      elseif txt=='Non_linear' then
	lisf=['ABS_VALUE.sci'; 'TrigFun.sci'; 
	      'EXPBLK_f.sci';  'INTRP2BLK_f.sci'; 
	      'INTRPLBLK_f.sci'; 'INVBLK_f.sci'; 
	      'LOGBLK_f.sci'; 'LOOKUP_f.sci'; 'MAXMIN.sci'; 
	      'POWBLK_f.sci'; 'PROD_f.sci';
	      'PRODUCT.sci';  'QUANT_f.sci';
	      'SATURATION.sci'; 'SIGNUM.sci';'EXPRESSION.sci' ];
	
      elseif txt=='Events' then
	lisf=['ANDBLK.sci';'HALT_f.sci';'freq_div.sci';
	      'ANDLOG_f.sci';'EVTDLY_f.sci';'IFTHEL_f.sci';'ESELECT_f.sci';
	      'CLKSOMV_f.sci';'CLOCK_f.sci';'EVTGEN_f.sci';'EVTVARDLY.sci'];
	      
      elseif txt=='Threshold' then
	lisf=[  'NEGTOPOS_f.sci';  'POSTONEG_f.sci';  'ZCROSS_f.sci'];    
	
      elseif txt=='Others' then
	lisf=['c_block.sci';'fortran_block.sci';
	      'SUPER_f.sci';'scifunc_block.sci';
	      'TEXT_f.sci';'CBLOCK.sci';'RATELIMITER.sci'; 
	      'BACKLASH.sci';'DEADBAND.sci';
	      'CONSTRAINT_f.sci';'HYSTHERESIS.sci';'DEBUG_SCICOS.sci';
	      'LOGICAL_OP.sci';'RELATIONALOP.sci';
	      'generic_block2.sci'];
	
	// XXXXX 'EXPRESSION.sci';	      
	
	
      elseif txt=='Linear' then
	lisf=['DLR_f.sci';'TCLSS_f.sci';'DOLLAR_f.sci';
	      'CLINDUMMY_f.sci';'DLSS_f.sci';'REGISTER_f.sci';'TIME_DELAY.sci';
	      'CLR_f.sci';'GAINBLK.sci';'SAMPLEHOLD_f.sci';'VARIABLE_DELAY.sci';
	      'CLSS_f.sci';'SUMMATION.sci';'INTEGRAL.sci';'SUM_f.sci';'DERIV.sci'];
	
      elseif txt=='OldBlocks' then
	lisf=['ABSBLK_f.sci'; 'MSCOPE_f.sci';'SCOPE_f.sci';    
	      'MAX_f.sci'; 'MIN_f.sci';'SAT_f.sci'; 'MEMORY_f.sci';
	      'CLKSOM_f.sci';'TRASH_f.sci';'GENERAL_f.sci';'DIFF_f.sci'
	      'BIGSOM_f.sci';'INTEGRAL_f.sci';'GAINBLK_f.sci';
	      'DELAYV_f.sci';'DELAY_f.sci'; 'DEMUX_f.sci';'MUX_f.sci';
	     'MFCLCK_f.sci';'MCLOCK_f.sci';'COSBLK_f.sci';   'DLRADAPT_f.sci';
	      'SINBLK_f.sci'; 'TANBLK_f.sci'];
	
	// XXXXXXXXX 'generic_block.sci'];

      elseif txt=='DemoBlocks' then
	lisf=['BOUNCE.sci';'BOUNCEXY.sci'];
	
      elseif txt=='Electrical' then
	lisf=['Capacitor.sci';'Ground.sci';'VVsourceAC.sci';'ConstantVoltage.sci';
	      'Inductor.sci';'PotentialSensor.sci';'VariableResistor.sci';'CurrentSensor.sci';
	      'Resistor.sci';'VoltageSensor.sci';'Diode.sci';'VsourceAC.sci'];
	
      elseif txt=='Hydraulics' then
	lisf=['Bache.sci';'VanneReglante.sci';'PerteDP.sci'; 'PuitsP.sci';'SourceP.sci'];
      else
	error('Palette '+txt+' does not exists')
      end
      // here we could decide to create a .cos or a .cosf 
	routines=[routines;build_palette(lisf,path,txt+'.cos')];
    end
    chdir(savepwd)
  end
  // XXXX 
  //routines=unique(routines)
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

