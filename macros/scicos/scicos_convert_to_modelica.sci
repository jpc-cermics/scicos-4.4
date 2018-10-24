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
	old = blk;
	if ok then G=gains ; else G=2;end; // XXXXXXX
	blk = MB_Gain('define',G);
	blk = set_block_params_from(blk, old);
	scs_m.objs(i)=blk;
      else
	// convert super, csuper, asuper
	// Note that this should come in second since
	// some asuper are directly converted to modelica 
	if or(blk.model.sim(1) ==  ['super','csuper','asuper']) then
	  // propagate in internal schema 
	  scsm1 = scicos_convert_to_modelica(blk.model.rpar);
	  blk.model.rpar = scsm1;
	  scs_m.objs(i)=blk;
	end
    end
  end
  // scs_m = do_silent_eval(scs_m);
  L=list();
  L2=list();
  for i=1:length(scs_m.objs)
    obj = scs_m.objs(i);
    if obj.type == 'Link' then

      from = obj.from;
      to = obj.to;

      if from(3)==0 then
	[xout,yout,typout]=getoutputs(scs_m.objs(from(1)));
      else
	[xout,yout,typout]=getinputs(scs_m.objs(from(1)));
      end

      if to(3)==1 then
	[xin,yin,typin] = getinputs(scs_m.objs(to(1)));
      else
	[xin,yin,typin] = getoutputs(scs_m.objs(to(1)));
      end
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
      if typin(to(2)) == typout(from(2)) then
	// two blocks of the same type, just update the link type 
	obj.ct(2) = typin(to(2));
	scs_m.objs(i) = obj;
      elseif typout(from(2)) == 2 then
	// from(1) is of type 2, thus to(1) is of type 1.
	// we insert a MO2Sn : from(1) -[type 2]-> MO2Sn -[type 1]-> to(1)
	new = MB_MO2Sn('define');
	new.graphics.orig = [xin(1)-30,yin(1)];
	new.graphics.sz = [20,20];
	// unlock scs_m.objs(to(1)) and lock the new 
	if to(3)==1 then
	  [xnew,ynew,typnew] = getinputs(new);
	  new.graphics.pin(to(2))= scs_m.objs(to(1)).graphics.pin(to(2));
	  scs_m.objs(to(1)).graphics.pin(to(2))=0;
	else
	  [xnew,ynew,typnew] = getoutputs(new);
	  new.graphics.pout(to(2))= scs_m.objs(to(1)).graphics.pout(to(2));
	  scs_m.objs(to(1)).graphics.pout(to(2))=0;
	end
	// insert new 
	L($+1)=new;
	// update link points
	n=length(obj.xx);
	if obj.yy(n-1) == obj.yy(n) then
	  obj.xx(n)= xnew($);
	  obj.yy(n-1:n)= ynew($);
	else
	  obj.xx(n)= xnew($);
	  obj.yy(n)= ynew($);
	end
	obj.ct(2) = 2; 
	obj.to=[length(scs_m.objs)+length(L),1,to(3)];
	scs_m.objs(i) = obj;
	// add a link
	L2($+1)= list('explicit',[length(scs_m.objs)+length(L),1],[to(1),to(2)]);
      else
	// typout(from(2)) == 1 
	// from(1) is of type 1, thus to(1) is of type 2.
	// we insert a S2MOn : from(1) -[type 2]-> S2MOn -[type 1]-> to(1)
	new = MB_MO2Sn('define');
	new.graphics.orig = [xin(1)-30,yin(1)];
	new.graphics.sz = [20,20];
	// unlock scs_m.objs(to(1)) and lock the new 
	if to(3)==1 then
	  [xnew,ynew,typnew] = getinputs(new);
	  new.graphics.pin(to(2))= scs_m.objs(to(1)).graphics.pin(to(2));
	  scs_m.objs(to(1)).graphics.pin(to(2))=0;
	else
	  [xnew,ynew,typnew] = getoutputs(new);
	  new.graphics.pout(to(2))= scs_m.objs(to(1)).graphics.pout(to(2));
	  scs_m.objs(to(1)).graphics.pout(to(2))=0;
	end
	// insert new 
	L($+1)=new;
	// update link points
	n=length(obj.xx);
	if obj.yy(n-1) == obj.yy(n) then
	  obj.xx(n)= xnew($);
	  obj.yy(n-1:n)= ynew($);
	else
	  obj.xx(n)= xnew($);
	  obj.yy(n)= ynew($);
	end
	obj.ct(2) = 1; 
	obj.to=[length(scs_m.objs)+length(L),1,to(3)];
	scs_m.objs(i) = obj;
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

function [scs_m] = convert_links(scs_m,num)

  xl = [cumsum([xo;points(:,1)]')';xi];  yl = [cumsum([yo;points(:,2)]')';yi]
  lk=scicos_link(xx=xl,yy=yl,ct=[clr,typ],from=from_node,to=to_node)
  link = scs_m.objs(num);
    
  [from,nok1]=evstr(lfrom)
  [to,nok2]=evstr(lto)
  
  if nok1+nok2>0 then
    obj_num=length(scs_m.objs)
    printf('Warning: Link %s->%s not supported.\n',sci2exp(lfrom,0),sci2exp(lto,0));
    return
  end
  
  o1 = scs_m.objs(from(1))
  [xout,yout,type_out]=getoutputs(o1)
  
  kfrom =from(2)
  if length(xout) < kfrom then 
    printf("output port %d does not exists in block %d\n",kfrom,from(1)),
    return;
  end
  
  type_out=type_out(kfrom);
  
  o2 = scs_m.objs(to(1));
  [xin,yin,type_in] = getinputs(o2)
  
  kto = to(2)
  if length(xin) < kto then 
    printf("inout port %d does not exists in block %d\n",kto,to(1)),
    return;
  end
  type_in = type_in(kto);

  if type_in == type_out then
    // the two ports share the same type we need to generate an implicit link
    [scs_m,obj_num]= add_implicit_link(scs_m,lfrom,lto,points);
  else
    if or(type_out==[1,3]) then
      //printf("The output port is regular. must add a CBI_RealInput converter\n");
      modelica_insize= o2.model.in(to(2));
      if %f &&  modelica_insize == 1  then 
	blk = instantiate_block ('CBI_RealInput');
      else
	blk=  add_scicos_to_modelicos(modelica_insize);
	blk.graphics.sz=[20,20];
      end
      blk = set_block_origin (blk,o1.graphics.orig+[o1.graphics.sz(1),0]+[40,0]);
      // blk = set_block_size(blk,[20,20]);
      obj_num = obj_num+1;
      scs_m.objs(obj_num) = blk;
      [scs_m,obj_num_t]=add_implicit_link(scs_m,string([obj_num,1]),lto);
      [scs_m,obj_num]=add_implicit_link(scs_m,lfrom,string([obj_num,1]));
    end
    if or(type_in==[1,3]) then
      // printf("The input port is regular. must add a CBI_RealOutput converter\n"),
      modelica_outsize= o1.model.out(from(2));
      if %f && modelica_outsize == 1 then 
	blk = instantiate_block ('CBI_RealOutput');
      else
	blk=  add_modelicos_to_scicos( modelica_outsize);
	blk.graphics.sz=[20,20];
      end
      blk = set_block_origin (blk,o2.graphics.orig-[40,0]);
      // blk = set_block_size(blk,[20,20]);
      obj_num = obj_num+1;
      scs_m.objs(obj_num) = blk;
      [scs_m,obj_num_t]=add_implicit_link(scs_m,string([obj_num,1]),lto);
      [scs_m,obj_num]=add_implicit_link(scs_m,lfrom,string([obj_num,1]));
    end
  end

  [from,nok1]=evstr(lfrom)
  [to,nok2]=evstr(lto)
  if nok1+nok2>0 then
    printf('Warning: Link %s->%s not supported.\n',sci2exp(lfrom,0),sci2exp(lto,0));
    return
  end
  
  o1 = scs_m.objs(from(1))
  graphics1=o1.graphics
  orig  = graphics1.orig
  sz    = graphics1.sz
  theta = graphics1.theta
  io    = graphics1.flip
  op    = graphics1.pout
  impi  = graphics1.pin
  cop   = graphics1.peout
  [xout,yout,typout]=getoutputs(o1)

  k=from(2)
  if length(xout) < k then
    printf("Warning: output port %d does not exists in block %d\n",k,from(1)),
    return;
  end

  // printf("In add_explicit \n");
  
  xo=xout(k);yo=yout(k);typo=typout(k);
  
  if ~or(typo==[1,3]) then
    error("The output port is not regular."),
  end
  
  xxx=rotate([xo;yo],...
	     theta*%pi/180,...
	     [orig(1)+sz(1)/2;orig(2)+sz(2)/2]);
  xo=xxx(1);
  yo=xxx(2);


  // Check if selected port is already connected and get port type ('in' or 'out')

  port_number=k
  if op(port_number)<>0 then
    printf('Warning: Selected port is already connected.\n'),pause
  end
  typpfrom='out'

  from_node=[from,0]
  xl=xo
  yl=yo

  kto = to(1)
  o2 = scs_m.objs(kto);
  graphics2 = o2.graphics;
  orig  = graphics2.orig
  sz    = graphics2.sz
  theta = graphics2.theta
  ip    = graphics2.pin
  impo  = graphics2.pout
  cip   = graphics2.pein

  k = to(2)

  if and(orig==-1) then
    xi=[],yi=[]
  else
    [xin,yin,typin] = getinputs(o2)
    if length(xin) < k then 
      printf("inout port %d does not exists in block %d\n",k,to(1)),
      return;
    end
    xi = xin(k); yi = yin(k); typi = typin(k);

    if ~isempty([xi;yi]) then
      xxx=rotate([xi;yi],...
                 theta*%pi/180,...
                 [orig(1)+sz(1)/2;orig(2)+sz(2)/2]);
      xi=xxx(1);
      yi=xxx(2);
    end

    if typo<>typi  then
      error(catenate(['Selected ports don''t have the same type'
		      'The port at the origin of the link has type '+string(typo);
		      'the port at the end has type '+string(typin(k))+'.'],sep='\n'));
    end
  end
  port_number = k ;
  if ip(port_number)<>0 then
    printf('Warning: Selected port is already connected.\n')
  end

  clr=default_color(typo)
  typ=typo
  to_node=[to,1]

  xl = [cumsum([xo;points(:,1)]')';xi];  yl = [cumsum([yo;points(:,2)]')';yi]
  lk=scicos_link(xx=xl,yy=yl,ct=[clr,typ],from=from_node,to=to_node)
  if typ==3 then
    lk.thick=[2 2]
  end
  
  lk=scicos_route(lk,scs_m)
  scs_m.objs($+1) = lk ;

  obj_num=length(scs_m.objs)

  //update connected blocks
  outin=['out','in']

  scs_m.objs(from_node(1))=mark_prt(scs_m.objs(from_node(1)),from_node(2),outin(from_node(3)+1),typ,obj_num)
  scs_m.objs(to_node(1))=mark_prt(scs_m.objs(to_node(1)),to_node(2),outin(to_node(3)+1),typ,obj_num)
  if isempty(xi) then
    scs_m.objs(to_node(1)).graphics.orig=[xl($),yl($)]
  end
endfunction
