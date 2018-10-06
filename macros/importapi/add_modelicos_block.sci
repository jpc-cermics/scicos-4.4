function [scs_m,obj_num] = add_modelicos_block(scs_m,blk,identification)
  
  select blk.gui
    case 'EXPRESSION' then
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
      name = blk.graphics.exprs;
      names=['sin','cos','tan','asin','acos','atan','sinh','cosh','tanh']
      // to be added ,'asinh','acosh','atanh'];
      if or(name== names) then
	modelica_name = 'MBM_'+capitalize(name);
	old=blk;
	blk = instantiate_block (modelica_name);
	blk = set_block_params_from(blk, old);
      end
    case 'MBM_Add' then
      // blk.graphics.exprs contains
      //params.concatd [ { "Datatype", '-1' } ];
      //params.concatd [ { "sgn", '[+1,-1]' } ];
      //params.concatd [ { "satur", '0' } ];
      // we just collect the signs. We should check th datatype
      // and add saturation if requested
      gains = evstr(blk.graphics.exprs(2));
      if size(gains,'*') == 1 then
	// cannot use add in that case we revert to a gain
	// which will be a modelica gain since we call instantiate_block
	old = blk;
	str_gains = old.graphics.exprs(2);
	blk = instantiate_block ('GAINBLK');
	blk = set_block_params_from(blk, old);
	params = cell (0, 2);
	params.concatd [ { "gain", str_gains } ];
	params.concatd [ { "over", '0' } ];
	params.concatd [ { "mulmethod", '1' } ];
	blk = set_block_parameters (blk, params);
      elseif  size(gains,'*') == 2 then
	params = cell (0, 2);
	params.concatd [ { "k1", string(gains(1)) } ];
	params.concatd [ { "k2", string(gains(2)) }];
	blk = set_block_parameters (blk, params);
	blk = set_block_nin (blk, 2);
	blk = set_block_nout (blk, 1);
	blk = set_block_evtnin (blk, 0);
	blk = set_block_evtnout (blk, 0);
      else
	blk= add_modelicos_mbm_add(blk, gains);
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
    case 'MBM_Gain' then
      // we do not have context here thus maybe we have to step back
      ok=execstr('gains ='+blk.graphics.exprs(1),errcatch=%t);
      if ~ok || size(gains,'*') <> 1 then
	old = blk;
	str_gains = blk.graphics.exprs(1);
	blk = GAINBLK('define');
	blk = set_block_params_from(blk, old);
	params = cell (0, 2);
	params.concatd [ { "gain", str_gains } ];
	params.concatd [ { "over", '0' } ];
	params.concatd [ { "mulmethod", '1' } ];
	blk = set_block_parameters (blk, params);
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

