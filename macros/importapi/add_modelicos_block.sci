function [scs_m,obj_num] = add_modelicos_block(scs_m,blk,identification)

  // names = ['SUMMATION','INTEGRAL_m','CONST_m','SPLIT_f', 'GAINBLK'];
  // modelicos_names =['MBM_Add','MBC_Integrator','MBS_Constant', 'IMPSPLIT_f', 'MBM_Gain'];

  select blk.gui
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
      old=blk;
      blk = instantiate_block ('MBS_Clock');
      blk = set_block_params_from(blk, old);
    case 'EXPRESSION' then
      // XXXX: Attention dans le bloc expression il peut-y-avoir des
      // paramètres il faut les récupérer et les metre en paramètres
      // cette partie est ensuite regénérée a chaque chgt du code.
      
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
	if %t then 
	  old=blk;
	  blk= MBM_Addn_define(gains);
	  blk = set_block_origin (blk, old.graphics.orig);
	  blk = set_block_size (blk, old.graphics.sz);
	  blk = set_block_theta (blk, old.graphics.theta );
	  blk = set_block_flip (blk, ~old.graphics.flip);
	else
	  blk= add_modelicos_mbm_add(blk, gains);
	end
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
      // 
    case 'GAINBLK' then
      // we do not have context here thus maybe we have to step back
      // This should be evaluated with the context 
      ok=execstr('gains ='+blk.graphics.exprs(1),errcatch=%t);
      if ok then
	if size(gains,'*') == 1 then
	  old = blk;
	  str_gains = blk.graphics.exprs(1);
	  blk = MBM_Gain('define');
	  blk = set_block_params_from(blk, old);
	  params = cell (0, 2);
	  params.concatd [ { "gain", str_gains } ];
	  blk = set_block_parameters (blk, params);
	else
	  blk = add_modelicos_matrix_gain(blk, gains);
	end
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

function blk= add_modelicos_matrix_gain(blk, gains)
  // used when gains is given by a matrix or vector
  // we use a VMBLOCK;

  old = blk;
  
  txt = sprintf("parameter Real G[%d,%d]={",size(gains,'r'),size(gains,'c'));
  S=m2s([]);
  for i=1:size(gains,'r')
    s=sprint(gains(i,:),as_read=%t);
    s=strsubst(s(2),['[',']'],['{','}']);
    S.concatr[s];
  end
  txt = txt + catenate(S,sep=",") +"};";
  txt.concatd[sprintf("  RealOutput y[%d];",size(gains,'r'))];
  txt.concatd[sprintf("  RealInput u[%d];",size(gains,'c'))];
  txt.concatd["  equation"];
  for i=1:size(gains,'r')
    start = sprintf("    y[%d].signal=",i);
    S=m2s([]);
    for j=1: size(gains,'c')
      S.concatr[sprintf("G[%d,%d]*u[%d].signal",i,j,j)];
    end
    txt.concatd[start + catenate(S,sep='+') + ";"];
  end

  // use a VMBLOCK to perform a matricial gain
  global(modelica_count=0);
  nameF='generic'+string(modelica_count);
  modelica_count =       modelica_count +1;

  H=hash(in=['u'], intype=['I'], in_r=size(gains,'c'), in_c=[1],
	 out=['y'], outtype=['I'], out_r= size(gains,'r'), out_c=1,
	 param=['G'], paramv=list(gains),
	 pprop=[0], nameF=nameF);
  blk = VMBLOCK_define(H);
  blk.graphics.orig = old.graphics.orig;
  blk.graphics.sz =  old.graphics.sz;
  blk.graphics.theta = old.graphics.theta;
  
  blk.graphics.exprs.funtxt =[sprintf("model %s", nameF);
			      txt;
			      sprintf("end %s;", nameF)];
  
  blk.graphics.gr_i=list(["txt=[""MGain""];";
			  "xstringb(orig(1),orig(2),txt,sz(1),sz(2),""fill"")"],8);
  
  // evaluer 
  diag = scicos_diagram();
  diag.objs= list(blk);
  [diag1,ok]=do_silent_eval(diag);
  blk = diag1.objs(1);
endfunction

function super_blk= add_modelicos_to_scicos(n)
  // from modelica to scicos for a vector
  // since the transition between scicos to modelica is only for
  // 1x1 signal we have to multiplex
  if nargin <= 1 then
    global(modelica_count=0);
    nameF='generic'+string(modelica_count);
    modelica_count =       modelica_count +1;
  else
    nameF=old.graphics.exprs.nameF;
  end
  
  H=hash(in=["u"], intype="I", in_r=n, in_c=1,
	 out=["y"+string(1:n)'], outtype=smat_create(n,1,"E"), out_r=ones(n,1), out_c=ones(n,1),
	 param=[], paramv=list(),
	 pprop=[], nameF=nameF);
 
  txt=[sprintf("model %s", nameF)];
  txt.concatd[sprintf("  RealInput u[%d];",n)];
  txt.concatd[sprintf("  Real %s;",catenate("y"+ string(1:n),sep=","))];
  txt.concatd["  equation"];
  for i=1:n
    txt.concatd[sprintf("    y%d= u[%d].signal;",i,i)];
  end
  txt.concatd[sprintf("end %s;", nameF)];
  
  H.funtxt = txt;
  if nargin == 2 then 
    blk = VMBLOCK_define(H,old);
  else
    blk = VMBLOCK_define(H);
  end
  
  blk.graphics.exprs.funtxt = txt;
  
  gr_i=["txt=[""Modelica"";"" "+H.nameF+" ""];";
	"xstringb(orig(1),orig(2),txt,sz(1),sz(2),""fill"")"];
  blk.graphics.gr_i=list(gr_i,8);
  blk.gui = "VMBLOCK";
  blk = set_block_size (blk, [40,40]);
  blk = set_block_origin (blk, [60,10]);
  
  super_blk = instantiate_super_block ();
  super_blk = set_block_size (super_blk, [20,20]);
  
  scsm= instantiate_diagram();
  
  blk_in = instantiate_block ('INIMPL_f');
  blk_in = set_block_size (blk_in, [20,10]);
  blk_in = set_block_origin (blk_in, [0;30]);
  scsm.objs(1)= blk_in;

  scsm.objs(2)=blk;
  
  // now a mux
  blk_mux = MUX('define');
  blk_mux.graphics.exprs = string(n);
  blk_mux.model.in= ones(n,1);
  blk_mux.model.intyp=- ones(n,1)
  blk_mux.model.out=n;
  blk_mux.model.outtyp=- 1;
  gr_i="blk_draw(sz,orig,orient,model.label)";
  blk_mux =standard_define([40 40],blk_mux.model,string(n),gr_i,'MUX')
  blk_mux = set_block_origin (blk_mux, [120,10]);
  scsm.objs(3) =blk_mux;
  
  blk_out = instantiate_block ('OUT_f');
  blk_out = set_block_parameters (blk_out, { "prt", '1' });
  blk_out = set_block_size (blk_out, [20,10])
  blk_out = set_block_origin (blk_out, [200,30]);
  scsm.objs(4)= blk_out;
  
  if %t then 
  scsm = add_implicit_link(scsm,['1','1'],['2','1'],[]); 
  for i=1:n
    scsm = add_explicit_link(scsm,['2',string(i)],['3',string(i)],[]);
  end
  scsm = add_explicit_link(scsm,['3','1'],['4','1'],[]);
  end
  
  super_blk = fill_super_block (super_blk, scsm);
  
endfunction

function super_blk= add_scicos_to_modelicos(n,old)
  // from modelica to scicos for a vector
  // since the transition between scicos to modelica is only for
  // 1x1 signal we have to multiplex
  if nargin <= 1 then
    global(modelica_count=0);
    nameF='generic'+string(modelica_count);
    modelica_count =       modelica_count +1;
  else
    nameF=old.graphics.exprs.nameF;
  end
  
  H=hash(in=["u"+string(1:n)'], intype=smat_create(n,1,"E"), in_r=ones(n,1), in_c=ones(n,1),
	 out=["y"], outtype=["I"], out_r= 1, out_c=1,
	 param=[], paramv=list(),
	 pprop=[], nameF=nameF);
  
  txt=[sprintf("model %s", nameF)];
  txt.concatd[sprintf("  Real %s;",catenate("u"+ string(1:n),sep=","))];
  txt.concatd[sprintf("  RealOutput y[%d];",n)];
  txt.concatd["  equation"];
  for i=1:n
    txt.concatd[sprintf("    y[%d].signal = u%d;",i,i)];
  end
  txt.concatd[sprintf("end %s;", nameF)];

  H.funtxt = txt;
  if nargin == 2 then 
    blk = VMBLOCK_define(H,old);
  else
    blk = VMBLOCK_define(H);
  end

  blk.graphics.exprs.funtxt = txt;
  gr_i=["txt=[""Modelica"";"" "+H.nameF+" ""];";
	"xstringb(orig(1),orig(2),txt,sz(1),sz(2),""fill"")"]
  blk.graphics.gr_i=list(gr_i,8);
  blk.gui = "VMBLOCK";
  blk = set_block_size (blk, [40,40]);
  blk = set_block_origin (blk, [120;0]);
  
  super_blk = instantiate_super_block ();
  super_blk = set_block_size (super_blk, [20,20]);
  scsm= instantiate_diagram();
  
  blk_in = instantiate_block ('IN_f');
  blk_in = set_block_size (blk_in, [20,10]);
  blk_in = set_block_origin (blk_in, [0;30]);
  scsm.objs(1)= blk_in;

  // now a demux
  blk2 = DEMUX('define');
  blk2.graphics.exprs = string(n);
  blk2.model.in=n;
  blk2.model.intyp=-1
  blk2.model.out=ones(n,1);
  blk2.model.outtyp=- ones(n,1)
  gr_i="blk_draw(sz,orig,orient,model.label)";
  blk2 =standard_define([40 40],blk2.model,string(n),gr_i,'DEMUX')
  blk2 = set_block_origin (blk2, [40,10]);
  scsm.objs(2) =blk2;

  scsm.objs(3)=blk;
  
  blk_out = instantiate_block ('OUTIMPL_f');
  blk_out = set_block_parameters (blk_out, { "prt", '1' });
  blk_out = set_block_size (blk_out, [20,10])
  blk_out = set_block_origin (blk_out, [200,30]);
  scsm.objs(4)= blk_out;

  if %t then
  for i=1:n
    scsm = add_explicit_link(scsm,['2',string(i)],['3',string(i)],[]);
  end
  scsm = add_explicit_link(scsm,['1','1'],['2','1'],[]);
  scsm = add_implicit_link(scsm,['3','1'],['4','1'],[]); 
  end
  
  super_blk = fill_super_block (super_blk, scsm);
endfunction



