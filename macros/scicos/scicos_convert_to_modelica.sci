function scs_m= scicos_convert_to_modelica(scs_m)

  // XXX: il faut propager les contextes
    
  // replace all modelica blocks by dummy and
  // changes the link so as to be standard links
  scs_m= scicos_normalize_links(scs_m);
  // 
  scs_m= scicos_normalize_sum_f(scs_m);
  // 
  scs_m= scicos_convert_blocks_to_modelica(scs_m);
  // second step to eventually change the IN OUT blocks 
  scs_m= scicos_convert_inout_to_modelica(scs_m);
  //
  scs_m= scicos_convert_split_to_modelica(scs_m);
  // simplify links: in order that they always are
  // from -> to i.e from is an output and to an input

  scs_m= scicos_convert_links_to_modelica(scs_m);
endfunction

function scs_m= scicos_normalize_sum_f(scs_m)
  // sum_f can have unconnected entries
  // before conversion we re-organize the links
  // Take care that the sum block after this tranformation may 
  // have less input ports. It will be ok when converted to modelica 
  blks = [];
  for i=1:length(scs_m.objs)
    obj = scs_m.objs(i);
    if obj.type == 'Link' then
      to = scs_m.objs(obj.to(1));
      if to.gui == 'SUM_f' then
	port = obj.to(2);
	I = find( to.graphics.pin == 0);
	if size(I,'*') == 2 then I=min(I);end
	if I < port then
	  obj.to(2) = I;
	  to.graphics.pin(I) = to.graphics.pin(port);
	  to.graphics.pin(port) = 0;
	  scs_m.objs(obj.to(1))=to;
	  scs_m.objs(i)=obj;
	  blks.concatd[obj.to(1)];
	end
      end
    end
  end
  // second pass to clean
  for i=1:size(blks,'*')
    obj = scs_m.objs(blks(i));
    I= find(obj.graphics.pin ==0);
    if ~isempty(I) then
      obj.graphics.pin = obj.graphics.pin(1:I(1)-1);
      obj.graphics.in_implicit = obj.graphics.in_implicit(1:I(1)-1);
      scs_m.objs(blks(i))=obj;
    end
  end
endfunction

function scs_m= scicos_normalize_links(scs_m)
  // be sure that links goes to from (getoutputs) to to (getinputs)
  scs_m = scs_m;
  for i=1:length(scs_m.objs)
    obj = scs_m.objs(i);
    if obj.type == 'Link' then
      if obj.from(3)<>0 then
	// from is an input
	obj.from(3)=1;
	obj.to(3)=0;
	obj.xx=obj.xx($:-1:1);
	obj.yy=obj.yy($:-1:1);
	scs_m.objs(i) = obj;
      end
    end
  end
endfunction

function scs_m= scicos_convert_links_to_modelica(scs_m)
  // pass on links to adapt their types to the from and to blocks
  // inserting type converters if necessary
  L=list();
  L2=list();
  Ln=list();
  for i=1:length(scs_m.objs)
    obj = scs_m.objs(i);
    if obj.type == 'Block' && or(obj.model.sim(1) ==  ['super','asuper']) then
      // propagate in internal schema except for csuper 
      scsm1 = scicos_convert_links_to_modelica(obj.model.rpar);
      obj.model.rpar = scsm1;
      scs_m.objs(i)=obj;
      
    elseif obj.type == 'Link' && obj.ct(2) > 0 then
      from = obj.from;
      to = obj.to;
      // from is now always an output 
      [xout,yout,typout]=getoutputs(scs_m.objs(from(1)));
      // to is now always an input
      [xin,yin,typin] = getinputs(scs_m.objs(to(1)));
      
      if %t then 
	// typin et typout 1: 'E', 2 'I', 3 'B';
	if isempty(scs_m.objs(from(1)).graphics.out_implicit) then outtyp='E';
	elseif length(scs_m.objs(from(1)).graphics.out_implicit) < from(2) then outtyp='E';
	else outtyp = scs_m.objs(from(1)).graphics.out_implicit(from(2));end

	if isempty(scs_m.objs(to(1)).graphics.in_implicit) then intyp='E';
	elseif size(scs_m.objs(to(1)).graphics.in_implicit,'*') < to(2) then intyp='E';
	else intyp = scs_m.objs(to(1)).graphics.in_implicit(to(2));end

	printf("Link-%d from %s(%d,%d,%s)-> %s(%d,%d,%s) ok=%d\n",
	       obj.ct(2),
	       scs_m.objs(from(1)).gui,from(2),typout(from(2)),outtyp,
	       scs_m.objs(to(1)).gui,to(2),typin(to(2)),intyp,
	       obj.ct(2) == typin(to(2)) && obj.ct(2) == typout(from(2)))
      end
      
      if typin(to(2)) == typout(from(2)) then
	// two blocks of the same type, just update the link type
	// and refresh the connection positions
	obj.xx(1) = xout(from(2));obj.yy(1) = yout(from(2));
	obj.xx($) = xin(to(2));obj.yy($) = yin(to(2));
	obj.ct(2) = typin(to(2));
	scs_m.objs(i) = obj;
      elseif typout(from(2)) == 2 then
	// from(1) is of type 2, thus to(1) is of type 1.
	// we insert a MO2Sn : from(1) -[type 2]-> MO2Sn -[type 1]-> to(1)
	new = MB_MO2Sn('define');
	new.graphics.orig = [xin(1)-30,yin(1)];
	new.graphics.sz = [20,20];
	// unlock scs_m.objs(to(1)) and lock the new 
	[xnew,ynew,typnew] = getinputs(new);
	// lock
	new.graphics.pin(1) = i;// scs_m.objs(to(1)).graphics.pin(to(2));
	// unlock 
	scs_m.objs(to(1)).graphics.pin(to(2))=0;
	// insert new 
	L($+1)=new;
	// update link points
	n=length(obj.xx);
	if n > 2 && obj.yy(n-1) == obj.yy(n) then
	  obj.xx(n)= xnew;
	  obj.yy(n-1:n)= ynew;
	else
	  obj.xx(n)= xnew;
	  obj.yy(n)= ynew;
	end
	obj.ct(2) = 2; 
	obj.to=[length(scs_m.objs)+length(L),1,to(3)];
	scs_m.objs(i) = obj;
	Ln($+1)=i;//if n == 2 then Ln($+1)=i;end
	// add a link
	L2($+1)= list('explicit',[length(scs_m.objs)+length(L),1],[to(1),to(2)]);
      else
	// typout(from(2)) == 1 
	// from(1) is of type 1, thus to(1) is of type 2.
	// we insert a S2MOn : from(1) -[type 2]-> S2MOn -[type 1]-> to(1)
	new = MB_S2MOn('define');
	new.graphics.orig = [xin(1)-30,yin(1)];
	new.graphics.sz = [20,20];
	// lock the i link to port 1 of new block 
	[xnew,ynew,typnew] = getinputs(new);
	new.graphics.pin(1) = i;
	// ulock 
	scs_m.objs(to(1)).graphics.pin(to(2))=0;
	// insert new 
	L($+1)=new;
	// update link points
	n=length(obj.xx);
	if n > 2 && obj.yy(n-1) == obj.yy(n) then
	  obj.xx(n)= xnew(1);
	  obj.yy(n-1:n)= ynew(1);
	else
	  obj.xx(n)= xnew(1);
	  obj.yy(n)= ynew(1);
	end
	obj.ct(2) = 1; 
	obj.to=[length(scs_m.objs)+length(L),1,to(3)];
	scs_m.objs(i) = obj;
	Ln($+1)=i;//if n == 2 then Ln($+1)=i;end
	// add a link
	L2($+1)= list('implicit',[length(scs_m.objs)+length(L),1],[to(1),to(2)]);
      end
    end
  end
  scs_m.objs.concat[L];
  for i=1:length(L2)
    l= L2(i);
    if l(1) == "explicit" then
      scs_m=add_explicit_link(scs_m,string(l(2)),string(l(3)),[]);
    else
      scs_m=add_implicit_link(scs_m,string(l(2)),string(l(3)),[]);
    end
  end
  for i=1:length(Ln)
    obj = scs_m.objs(Ln(i));
    // improve routage 
    delF=scs_m.objs(obj.from(1)).graphics.sz/2
    delT=scs_m.objs(obj.to(1)).graphics.sz/2
    forig=scs_m.objs(obj.from(1)).graphics.orig(1)+delF(1)
    torig=scs_m.objs(obj.to(1)).graphics.orig(1)+delT(1)
    [xx,yy]=scicos_routage(obj.xx,obj.yy,forig,torig,delF(2),delT(2))
    obj.xx = xx; obj.yy =yy;
    scs_m.objs(Ln(i))=obj;
  end
endfunction

function scs_m= scicos_convert_blocks_to_modelica(scs_m)
  // replace all modelica blocks by dummy and
  // changes the link so as to be standard links
  scicos_context=acquire('scicos_context',def=hash(10));
  [scicos_context,ierr]=script2var(scs_m.props.context,scicos_context);
  if ierr<>0 then 
    msg(["Warning: Failed to evaluate a context:";catenate(lasterror())]);
  end
  %scicos_context=scicos_context;
  
  scs_m = scs_m;
  for i=1:length(scs_m.objs)
    blk = scs_m.objs(i);
    if blk.type <> 'Block' then continue;end
    select blk.gui
      case 'PID2' then
	old = blk;
	blk = MBC_PID('define');
	blk = set_block_params_from(blk, old);
	blk.graphics.exprs= [old.graphics.exprs;'10'];
	scs_m.objs(i)=blk;
      case 'PID' then
	old = blk;
	old = PID('upgrade',old);
	blk = MBC_PID('define');
	blk = set_block_params_from(blk, old);
	blk.graphics.exprs= [old.graphics.exprs;'10'];
	scs_m.objs(i)=blk;
      case 'SPLIT_f' then
	// XXXX a revoir 
	//old = blk;
	//blk = IMPSPLIT_f('define');
	//blk = set_block_params_from(blk, old);
      	//scs_m.objs(i)=blk;
      case {'INTEGRAL_m','INTEGRAL'} then
	// XXXX a reprendre car c'est vectoriel dans scicos
	old = blk;
	blk = MBC_Integrator('define');
	blk = set_block_params_from(blk, old);
	blk.graphics.exprs(2)= old.graphics.exprs(1);
	scs_m.objs(i)=blk;
      case 'SUMMATION' then
	// XXX: the case with one entry and matrix entries should be revisited 
	old = blk;
	execstr('signs='+old.graphics.exprs(2));
	blk = MB_Addn('define',-1,signs);
	blk = set_block_params_from(blk, old);
	blk.graphics.exprs.signs = signs;
	scs_m.objs(i)=blk;
      case 'SUM_f' then
	// XXX: the case with one entry and matrix entries should be revisited
	// SUM_f is special : it can contain unconnected entries
	// we thus obtain a MB_Addn with unconnected entries
	// This should be fixed latter.
	old = blk;
	signs = ones(1,size(old.model.in,'*'));
	blk = MB_Addn('define',-1,signs);
	blk = set_block_params_from(blk, old);
	blk.graphics.exprs.signs = signs;
	scs_m.objs(i)=blk;
	pause xxx;
      case 'PRODUCT' then
	// XXX: the case with one entry and matrix entries should be revisited 
	old = blk;
	blk = MB_Prodn('define');
	blk = set_block_params_from(blk, old);
	execstr('signs='+old.graphics.exprs(1));
	blk.graphics.exprs.signs = signs;
	scs_m.objs(i)=blk;
      case 'PROD_f' then
	// XXX: the case with one entry and matrix entries should be revisited 
	old = blk;
	blk = MB_Prodn('define');
	blk = set_block_params_from(blk, old);
	blk.graphics.exprs.signs = ones(1,size(old.model.in,'*'));
	scs_m.objs(i)=blk;

      case 'EXTRACTOR' then
	// XXXX Attention doit etre vectoriel 
	// EXTRACTOR -> CBR_Extractor (OK)
	// we could do a CBR_Extractor_n
	old = blk;
	execstr('index='+old.graphics.exprs);
	blk = MB_Extractn('define',index);
	// blk = CBR_Extractor('define');
	blk = set_block_params_from(blk, old);
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
	blk = MBS_Clock('define');
	blk = set_block_params_from(blk, old);
      	scs_m.objs(i)=blk;
      case 'EXPRESSION' then
	old=blk;
	expression = strsubst(blk.graphics.exprs(2),"%u","u");
	blk = MB_Expression('define',evstr(blk.graphics.exprs(1)),expression);
	blk = set_block_params_from(blk, old);
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
      case 'SQRT' then
	old= blk;
	blk = MB_MathFun('define',"sqrt");
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
	old=blk;
	blk = MB_Gain('define',blk.graphics.exprs(1));
	blk = set_block_params_from(blk, old);
	scs_m.objs(i)=blk;
      case 'MUX' then
	old=blk;
	blk = MB_Mux('define',blk.model.in, blk.model.out);
	blk = set_block_params_from(blk, old);
	scs_m.objs(i)=blk;
      case 'DEMUX' then
	pause demux 
	old=blk;
	blk = MB_Demux('define',blk.model.out, blk.model.in);
	blk = set_block_params_from(blk, old);
	scs_m.objs(i)=blk;
      else
	// convert super, csuper, asuper
	// Note that this should come in second since
	// some asuper are directly converted to modelica 
	if or(blk.model.sim(1) ==  ['super','csuper','asuper']) then
	  // propagate in internal schema 
	  scsm1 = scicos_convert_blocks_to_modelica(blk.model.rpar);
	  blk.model.rpar = scsm1;
	  scs_m.objs(i)=blk;
	end
    end
  end
endfunction

function scs_m= scicos_convert_inout_to_modelica(scs_m)
// replace IN_f and OUT_f if they need to be modelica converted 
  
  function [to_types] = scicos_get_linked_block_to_pout(blk,pout,to_types)
    // find the link going from outputs of the IN_f bloc blk.
    link = scs_m.objs(blk.graphics.pout(pout));
    to_blk = scs_m.objs(link.to(1));
    if to_blk.gui == "SPLIT_f" then
      // The split contains several outputs, one of them goes to a real block
      for k=1:size(to_blk.graphics.pout,'*')
	[to_types] = scicos_get_linked_block_to_pout(to_blk,k,to_types)
      end
    else
      [x_target,y_target,to_blk_type] = getinputs(to_blk);
      to_blk_type = to_blk_type(link.to(2));
      to_types=[to_types,to_blk_type];
    end
  endfunction

  function [scs_m] = scicos_propagate_type_from_impin(scs_m,blk,pout)
    // find the link going from outputs of the IN_f bloc blk.
    link = scs_m.objs(blk.graphics.pout(pout));
    to_blk = scs_m.objs(link.to(1));
    if to_blk.gui == "SPLIT_f" then
      blk_new = IMPSPLIT_f('define');
      blk_new = set_block_params_from(blk_new, to_blk);
      scs_m.objs(link.to(1))=blk_new;
      // The split contains several outputs, one of them goes to a real block
      for k=1:size(to_blk.graphics.pout,'*')
	scs_m = scicos_propagate_type_from_impin(scs_m,to_blk,k);
      end
    else
      scs_m = scs_m;
    end
  endfunction
  
  function [from_blk,from_blk_type,link] = scicos_get_linked_block_to_out(blk)
    // find the link going to inputs of the OUT_f bloc blk.
    link = scs_m.objs(blk.graphics.pin);
    // find the block -> OUT_F
    from_blk = scs_m.objs(link.from(1));
    if from_blk.gui == "SPLIT_f" then
      // follow up to a real block
      blk1 = from_blk;
      [from_blk,from_blk_type,link] = scicos_get_linked_block_to_out(blk1);
      [x_target,y_target,from_blk_type] = getoutputs(from_blk);
      from_blk_type = from_blk_type(link.from(2));
    else
      printf("scicos_get_linked_block_to_out %s\n",from_blk.gui);
      [x_target,y_target,from_blk_type] = getoutputs(from_blk);
      from_blk_type = from_blk_type(link.from(2));
    end
  endfunction
  
  scs_m = scs_m;
  for i=1:length(scs_m.objs)
    blk = scs_m.objs(i);
    if blk.type <> 'Block' then continue;end
    select blk.gui
     case 'IN_f' then
       // follows the tree of linsk from IN_f and get types
       [to_types] = scicos_get_linked_block_to_pout(blk,1,[]);
       if or(to_types == 2) then 
	 // we convert IN_f and should propagate conversion for
	 // all the SPLITS accordingly XXXXX
	 // printf("The IN_f must be converted \n");
	 blk_new = INIMPL_f('define',blk.model.ipar);
	 blk_new = set_block_params_from(blk_new, blk);
	 scs_m.objs(i)=blk_new;
	 [scs_m] = scicos_propagate_type_from_impin(scs_m,blk_new,1);
       end
     case 'OUT_f' then
      // pause OUT
      [from_blk,from_blk_type] = scicos_get_linked_block_to_out(blk)
      if from_blk_type == 2 then 
	// printf("The OUT_f must be converted \n");
	blk_new = OUTIMPL_f('define',blk.model.ipar);
	blk_new = set_block_params_from(blk_new, blk);
	scs_m.objs(i)=blk_new;
      end
    else
      // convert super, csuper but do not convert asuper
      // which are supposed to be globally converted.
      // XXXX a affiner
      if or(blk.model.sim(1) ==  ['super','asuper']) then
	// propagate in internal schema 
	scsm1 =  scicos_convert_inout_to_modelica(blk.model.rpar)
	blk.model.rpar = scsm1;
	[ok,blk]=adjust_s_ports(blk)
	// blk = do_silent_eval_block(blk);
	// XXXX need to update the super block inout to reflect the
        // internal changes 
	scs_m.objs(i)=blk;
      end
    end
  end
endfunction


function scs_m= scicos_convert_split_to_modelica(scs_m)
// replaces SPLIT_f by IMPSPLIT_f
  
  function [from_blk,from_blk_type,link] = scicos_get_linked_block_to_split(blk)
    // find the link going to inputs of the OUT_f bloc blk.
    link = scs_m.objs(blk.graphics.pin);
    // find the block -> OUT_F
    from_blk = scs_m.objs(link.from(1));
    if from_blk.gui == "SPLIT_f" then
      // follow up to a real block
      blk1 = from_blk;
      [from_blk,from_blk_type,link] = scicos_get_linked_block_to_split(blk1);
      [x_target,y_target,from_blk_type] = getoutputs(from_blk);
      from_blk_type = from_blk_type(link.from(2));
    else
      printf("scicos_get_linked_block_to_split %s\n",from_blk.gui);
      [x_target,y_target,from_blk_type] = getoutputs(from_blk);
      from_blk_type = from_blk_type(link.from(2));
    end
  endfunction
  
  scs_m = scs_m;
  for i=1:length(scs_m.objs)
    blk = scs_m.objs(i);
    if blk.type <> 'Block' then continue;end
    select blk.gui
      case 'SPLIT_f' then
	[from_blk,from_blk_type,link] = scicos_get_linked_block_to_split(blk);
	if from_blk_type == 2 then
	  blk_new=IMPSPLIT_f('define');
	  blk_new = set_block_params_from(blk_new, blk);
	  scs_m.objs(i)=blk_new;
	end
      else
	if or(blk.model.sim(1) ==  ['super','csuper','asuper']) then
	  // propagate in internal schema 
	  scsm1 =  scicos_convert_split_to_modelica(blk.model.rpar)
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

