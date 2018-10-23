function scs_m= scicos_convert_to_modelica(scs_m)
  // replace all modelica blocks by dummy and
  // changes the link so as to be standard links
  scs_m = scs_m;
  for i=1:length(scs_m.objs)
    blk = scs_m.objs(i);
    if blk.type <> 'Block' then continue;end
    select blk.gui
      case 'SPLIT_f' then
	// XXXX a revoir 
	old = blk;
	blk = IMPSPLIT_f('define');
	blk = set_block_params_from(blk, old);
      	scs_m.objs(i)=blk;
      case 'INTEGRAL_m' then
	old = blk;
	blk = MBC_Integrator('define');
	blk = set_block_params_from(blk, old);
	blk.graphics.exprs(2)= old.graphics.exprs(1);
	scs_m.objs(i)=blk;
      case 'SUMMATION' then
	// XXX: the case with one entry and matrix entries should be revisited 
	old = blk;
	blk = MB_Addn('define');
	blk = set_block_params_from(blk, old);
	execstr('signs='+old.graphics.exprs(2));
	blk.graphics.exprs.signs = signs;
	scs_m.objs(i)=blk;
      case 'EXTRACTOR' then
	// EXTRACTOR -> CBR_Extractor (OK)
	// we could do a CBR_Extractor_n 
	old = blk;
	blk = CBR_Extractor('define');
	blk = set_block_params_from(blk, old);
	execstr('index='+old.graphics.exprs);
	blk.graphics.exprs = [sci2exp(m2i(index));sci2exp(m2i(-1))];
	scs_m.objs(i)=blk;
      case 'CONST_m' then
	// CONST_m -> MB_Constantn (OK)
	H = acquire('%api_context',def=hash(1));
	[ok,H1]=execstr('C ='+blk.graphics.exprs,env=H,errcatch=%t);
	if ~ok then
	  printf("Warning: unable to evaluate ''%s'' in block CONST_m\n",blk.graphics.exprs);
	  break;
	end
	// If we are able to evaluate the constant, we switch to MBM_Constantn
	// even if the constant is a scalar value.
	old = blk;
	blk = MB_Constantn('define');
	blk = set_block_params_from(blk, old);
	// on pourrait ici faire un set_blocks_exprs 
	exprs = old.graphics.exprs;
	blk.graphics.exprs.paramv= sprintf("list(%s)",exprs);// sci2exp(H1.C));// exprs);
	scs_m1 = scicos_diagram();
	scs_m1.objs(1)= blk;
	[scs_m1,ok]=do_silent_eval(scs_m1, H);
	blk = scs_m1.objs(1);
      	scs_m.objs(i)=blk;
	
      case 'ZZRAMP' then
	// RAMP and MBS_Ramp are different
	// ['Slope';'Start time';'Initial output']
	old=blk;
	blk = instantiate_block ('MBS_Ramp');
	blk = set_block_params_from(blk, old);
	exprs = old.graphics.exprs;
	// new_exprs = ZZ
	blk.graphics.exprs = new_exprs;
	scs_m.objs(i)=blk;
      case 'GENSIN_f' then
	// a sin source 
	// GENSIN_f -> MBS_Sine
	old=blk;
	blk = instantiate_block ('MBS_Sine');
	blk = set_block_params_from(blk, old);
	// 
	exprs = old.graphics.exprs;
	// ['Magnitude';'Frequency (rad/s)';'Phase (rad)']
	// ['Magnitude','freqHz [Hz]      ','phase [rad] ',' offset [-]','startTime [s]]
	new_exprs = [exprs(1);exprs(2)+"/(2*%pi)";exprs(3);"0";"0"];
	blk.graphics.exprs = new_exprs;
      	scs_m.objs(i)=blk;
      case 'TIME_f' then
	// time as signal 
	// TIME_f -> MBS_Clock
	old=blk;
	blk = instantiate_block ('MBS_Clock');
	blk = set_block_params_from(blk, old);
      	scs_m.objs(i)=blk;
      case 'EXPRESSION' then
	// XXXX: Attention dans le bloc expression il peut-y-avoir des
	// paramètres il faut les récupérer et les metre en paramètres
	// cette partie est ensuite regénérée a chaque chgt du code.
	// here we should define a MB_EXPRESSION in the same spirit
	// of MB_Constantn using VMBlock internally
	old=blk;
	blk = instantiate_block ('MBLOCK');
	blk = set_block_params_from(blk, old);
	n_in = evstr(old.graphics.exprs(1));
	in= 'u' + string(1:n_in);
	intype= smat_create(n_in,1,'I');
	out=['y1'];
	outtype=['I'];
	param=[];
	paramv=list();
	pprop=[];
	global(modelica_count=0);
	nameF='generic'+string(modelica_count);
	modelica_count =       modelica_count +1;
        
	exprs = tlist(["MBLOCK","in","intype","out","outtype",...
		       "param","paramv","pprop","nameF","funtxt"],...
		      sci2exp(in(:)),...
		      sci2exp(intype(:)),...
		      sci2exp(out(:)),...
		      sci2exp(outtype(:)),...
		      sci2exp(param(:)),...
		      list(string(0.1),string(.0001)),...
		      sci2exp(pprop(:)),...
		      nameF,m2s([]))
	blk.graphics.exprs = exprs;
	
	modelica_expr= strsubst(old.graphics.exprs(2),"%","");
	txt = modelica_expr;
	modelica_expr= strsubst(modelica_expr, in, in+'.signal');
        
	blk.graphics.exprs.funtxt =[sprintf("model %s", nameF);
				    sprintf("RealInput %s;",catenate(in,sep=","));                         
				    sprintf("RealOutput %s;",out);
				    "  equation";
          			    sprintf("    y1.signal = %s;",modelica_expr);
				    sprintf("end %s;", nameF)];
	// evaluer 
	diag = scs_m;
	diag.objs= list(blk);
	[diag1,ok]=do_silent_eval(diag);
	blk = diag1.objs(1);
	// unfortunately this will be crushed by last eval 
	blk.graphics.gr_i(1)(1) = sprintf("txt = %s;",txt);
	scs_m.objs(i)=blk;
      case 'ABS_VALUEi' then
	old= blk;
	blk = MB_MathFun('define',"abs");
	in_implicit =blk.graphics.in_implicit;
	out_implicit =blk.graphics.out_implicit;
	blk = set_block_params_from(blk, old);
	blk.graphics.in_implicit=in_implicit;
	blk.graphics.out_implicit=out_implicit;
      	scs_m.objs(i)=blk;
      case 'SIGNUM' then
	old= blk;
	blk = MB_MathFun('define',"sign");
	in_implicit =blk.graphics.in_implicit;
	out_implicit =blk.graphics.out_implicit;
	blk = set_block_params_from(blk, old);
	blk.graphics.in_implicit=in_implicit;
	blk.graphics.out_implicit=out_implicit;
	scs_m.objs(i)=blk;
      case 'LOGBLK_f' then
	old= blk;
	blk = MB_MathFun('define',"log");
	in_implicit =blk.graphics.in_implicit;
	out_implicit =blk.graphics.out_implicit;
	blk = set_block_params_from(blk, old);
	blk.graphics.in_implicit=in_implicit;
	blk.graphics.out_implicit=out_implicit;
	scs_m.objs(i)=blk;
      case 'TrigFun' then
	// TrigFun uses specialized MBM blocks
	// we could directly use the MB_TrigFun block which is to
	// be renamed MB_MathFun and works with vectors (should be extended to matrices ?).
	old= blk;
	blk = MB_MathFun('define');
	in_implicit =blk.graphics.in_implicit;
	out_implicit =blk.graphics.out_implicit;
	blk = set_block_params_from(blk, old);
	blk.graphics.exprs.paramv = old.graphics.exprs;
	blk.graphics.in_implicit=in_implicit;
	blk.graphics.out_implicit=out_implicit;
	if %f then       
	  name = blk.graphics.exprs;
	  names=['sin','cos','tan','asin','acos','atan','sinh','cosh','tanh']
	  // to be added ,'asinh','acosh','atanh'];
	  if or(name== names) then
	    modelica_name = 'MBM_'+capitalize(name);
	    old=blk;
	    blk = instantiate_block (modelica_name);
	    blk = set_block_params_from(blk, old);
	  end
	end
	scs_m.objs(i)=blk;
      case 'GAINBLK' then
	// we do not have context here thus maybe we have to step back
	// This should be evaluated with the context 
	ok=execstr('gains ='+blk.graphics.exprs(1),errcatch=%t);
	if ok then
	  old = blk;
	  blk = MB_Gain('define',gains);
	  in_implicit =blk.graphics.in_implicit;
	  out_implicit =blk.graphics.out_implicit;
	  // ça risque d'écraser des trucs 
	  blk = set_block_params_from(blk, old);
	  blk.graphics.in_implicit=in_implicit;
	  blk.graphics.out_implicit=out_implicit;
	else
	  blk = MB_Gain('define',2);
	end
	scs_m.objs(i)=blk;
      else
	if or(blk.model.sim(1) ==  ['super','csuper','asuper']) then
	  // propagate in internal schema 
	  scsm1 = scicos_convert_to_modelica(blk.model.rpar);
	  blk.model.rpar = scsm1;
	  scs_m.objs(i)=blk;
	end
    end
  end
endfunction

function blk= add_modelicos_to_scicos(n,old)
  // from modelica to scicos for a vector
  // since the transition between scicos to modelica is only for
  // 1x1 signal we have to multiplex
  blk = MB_MO2Sn('define',max(n,1));
endfunction

function blk= add_scicos_to_modelicos(n,old)
  // from modelica to scicos for a vector
  // since the transition between scicos to modelica is only for
  // 1x1 signal we have to multiplex
  blk = MB_S2MOn('define',max(n,1));
endfunction

