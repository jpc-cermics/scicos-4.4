function [scs_m,obj_num] = add_modelicos_block(scs_m,blk,identification)

  // names = ['INTEGRAL_m','CONST_m','SPLIT_f']
  // modelicos_names =['MBC_Integrator','MBS_Constant', 'IMPSPLIT_f']

  select blk.gui
    case 'SUMMATION' then
      // XXX: the case with one entry and matrix entries should be revisited 
      old = blk;
      blk = MB_Addn('define');
      blk = set_block_params_from(blk, old);
      execstr('signs='+old.graphics.exprs(2));
      blk.graphics.exprs.signs = signs;
      
    case 'EXTRACTOR' then
      // EXTRACTOR -> CBR_Extractor (OK)
      // we could do a CBR_Extractor_n 
      old = blk;
      blk = CBR_Extractor('define');
      blk = set_block_params_from(blk, old);
      execstr('index='+old.graphics.exprs);
      blk.graphics.exprs = [sci2exp(m2i(index));sci2exp(m2i(-1))];
      
    case 'CONST_m' then
      // CONST_m -> MBM_Constantn (OK)
      H = acquire('%api_context',def=hash(1));
      [ok,H1]=execstr('C ='+blk.graphics.exprs,env=H,errcatch=%t);
      if ~ok then
	printf("Warning: unable to evaluate ''%s'' in block CONST_m\n",blk.graphics.exprs);
	break;
      end
      // If we are able to evaluate the constant, we switch to MBM_Constantn
      // even if the constant is a scalar value.
      old = blk;
      blk = MBM_Constantn('define');
      blk = set_block_params_from(blk, old);
      // on pourrait ici faire un set_blocks_exprs 
      exprs = old.graphics.exprs;
      blk.graphics.exprs.paramv= sprintf("list(%s)",exprs);// sci2exp(H1.C));// exprs);
      scs_m1 = scicos_diagram();
      scs_m1.objs(1)= blk;
      [scs_m1,ok]=do_silent_eval(scs_m1, H);
      blk = scs_m1.objs(1);

    case 'ZZRAMP' then
      // RAMP and MBS_Ramp are different
      // ['Slope';'Start time';'Initial output']
      old=blk;
      blk = instantiate_block ('MBS_Ramp');
      blk = set_block_params_from(blk, old);
      exprs = old.graphics.exprs;
      // new_exprs = ZZ
      blk.graphics.exprs = new_exprs;
      
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

    case 'TIME_f' then
      // time as signal 
      // TIME_f -> MBS_Clock
      old=blk;
      blk = instantiate_block ('MBS_Clock');
      blk = set_block_params_from(blk, old);

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

    case 'TrigFun' then
      // TrigFun uses specialized MBM blocks
      // we could directly use the MB_TrigFun block which is to
      // be renamed MB_MathFun and works with vectors (should be extended to matrices ?).
      name = blk.graphics.exprs;
      names=['sin','cos','tan','asin','acos','atan','sinh','cosh','tanh']
      // to be added ,'asinh','acosh','atanh'];
      if or(name== names) then
	modelica_name = 'MBM_'+capitalize(name);
	old=blk;
	blk = instantiate_block (modelica_name);
	blk = set_block_params_from(blk, old);
      end
      
    case 'MBC_Integrator' then
      // params.concatd [ { "x0", '0' } ];
      // params.concatd [ { "reinit", '0' } ];
      // params.concatd [ { "satur", '0' } ];
      // params.concatd [ { "maxp", '%inf' } ];
      // params.concatd [ { "lowp", '-%inf' } ];
      blk.graphics.exprs= ['1'; blk.graphics.exprs(1)];

    case 'MBS_Constant' then
      // nothing to do same parameters 
      // params.concatd [ { "C", '1' } ];
      // blk.graphics.exprs= blk.graphics.exprs;

    case 'IMPSPLIT_f' then
      // nothing to do
      
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
  end
  blk.graphics.id = identification;
  scs_m.objs($+1) = blk ; // add the object to the data structure
  obj_num = string(length(scs_m.objs))
endfunction

function blk= add_modelicos_mbm_add(blk, gains)
  // generate a block for performing multiple additions
  // using mbm_add as basic block
  super_blk = instantiate_super_block ();
  super_blk = set_block_icon_text (super_blk, blk.graphics.exprs(2));
  super_blk = set_block_bg_color (super_blk, [1, 1, 1]);
  super_blk = set_block_fg_color (super_blk, [0, 0, 0]);
  super_blk = set_block_nin (super_blk,size(gains,'*') );
  super_blk = set_block_nout (super_blk, 1);
  super_blk = set_block_evtnin (super_blk, 0);
  super_blk = set_block_evtnout (super_blk, 0);
  super_blk = set_block_ident (super_blk, blk.graphics.id );
  super_blk = set_block_origin (super_blk, blk.graphics.orig);
  super_blk = set_block_size (super_blk, blk.graphics.sz);
  super_blk = set_block_theta (super_blk, blk.graphics.theta );
  super_blk = set_block_flip (super_blk, ~blk.graphics.flip);
  scsm = instantiate_diagram();
  I= size(gains,'*');
  blk_out = instantiate_block ('OUTIMPL_f');
  blk_out = set_block_parameters (blk_out, { "prt", '1' });
  blk_out = set_block_size (blk_out, blk.graphics.sz);
  xinter = blk.graphics.sz(1);
  yinter = blk.graphics.sz(2);
  top = 2*yinter*I;
  blk_out = set_block_origin (blk_out, [2*xinter + 2*xinter*(I-1); top - 2*yinter*(I-2)]); 
  scsm.objs($+1)= blk_out;
  for i=1:I
    blk_in = instantiate_block ('INIMPL_f');
    blk_in = set_block_size (blk_in, blk.graphics.sz);
    blk_in = set_block_origin (blk_in,[0; top - 2*yinter*(i-2) ]);
    blk_in= set_block_parameters (blk_in, { "prt", string(i) });
    scsm.objs($+1)= blk_in;
  end
  
  first = MBM_Add('define');
  params = cell (0, 2);
  params.concatd [ { "k1", string(gains(1)) } ];
  params.concatd [ { "k2", string(gains(2)) }];
  first = set_block_parameters (first, params);
  first = set_block_nin (first, 2);
  first = set_block_nout (first, 1);
  first = set_block_evtnin (first, 0);
  first = set_block_evtnout (first, 0);
  first = set_block_flip (first, %f);
  first = set_block_theta (first, 0);
  first = set_block_size (first, blk.graphics.sz);
  first = set_block_origin (first, [2*xinter; top]);

  scsm.objs($+1)= first;
  to = length(scsm.objs);
  scsm = add_implicit_link(scsm,['2','1'],[string(to),'1'],[]);
  scsm = add_implicit_link(scsm,['3','1'],[string(to),'2'],[]);
  from= to;
  for j=3:size(gains,'*') do
    new = MBM_Add('define');
    params = cell (0, 2);
    params.concatd [ { "k1", '1' } ];
    params.concatd [ { "k2", string(gains(j)) }];
    new = set_block_parameters (new, params);
    new = set_block_nin (new, 2);
    new = set_block_nout (new, 1);
    new = set_block_evtnin (new, 0);
    new = set_block_evtnout (new, 0);
    new = set_block_flip (new, %f);
    new = set_block_theta (new, 0);
    new = set_block_size (new, blk.graphics.sz);
    new = set_block_origin (new, [2*xinter+ 2*xinter*(j-2); top - 2*yinter*(j-2)]);
    scsm.objs($+1)= new;
    to =  length(scsm.objs);
    scsm = add_implicit_link(scsm,[string(from),'1'],[string(to),'1'],[]);
    scsm = add_implicit_link(scsm,[string(j+1),'1'],[string(to),'2'],[]);
    from=to;
  end
  // last link to the output port which is at position 1
  scsm = add_implicit_link(scsm,[string(from),'1'],['1','1'],[]);
  super_blk = fill_super_block (super_blk, scsm);
  blk = super_blk;
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
