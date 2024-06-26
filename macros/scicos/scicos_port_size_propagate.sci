function [scs_m]=scicos_port_size_propagate(scs_m,cpr=[],verbose=%f)
  // Copyright jpc
  // create a new diagram where sizes are replaced by result of compilation sizes 
  if cpr.equal[[]];
    [scs_m,cpr1,needcompile,ok]=do_eval(scs_m);
    [cpr]=do_compile(scs_m);
    if cpr.equal[list()]; then return;end
  end
  //
  bp_out=zeros(0,4);
  bp_in=zeros(0,4);
  // loop on the size informations stored in cpr
  // and push this information in bp
  // a raw of bp =[ block-id, port-number, size1, size2]
  for j=1:size(cpr.state('outtb')) do
    // loop on links 
    sz = size(cpr.state.outtb(j));
    // 
    N = find(cpr.sim.outlnk == j);
    for n = N  do 
      // compute (b,p) such that n = outptr(b)+ p-1
      // pause bp
      b = max(find( cpr.sim.outptr <= n))
      p = n - cpr.sim.outptr(b) + 1;
      // if abs(n - ( cpr.sim.outptr(b)+ p-1)) > 0.1 then pause incoherence;end 
      bp_out.concatd[[b,p,sz]];
    end
    N = find(cpr.sim.inplnk == j);
    for n = N  do 
      // compute (b,p) such that n = inpptr(b)+ p-1 
      b = max(find( cpr.sim.inpptr <= n))
      p = n - cpr.sim.inpptr(b) + 1;
      // if abs(n - ( cpr.sim.inpptr(b)+ p-1)) > 0.1 then pause incoherence;end 
      bp_in.concatd[[b,p,sz]];
    end
  end
  // propagate the bp information in scs_m
  // we obtain a block from its block-id by
  // obj = scs_m(scs_full_path(cpr.corinv(block-id)));
  for j = 1: size(bp_out,1)
    bpj = bp_out(j,:);
    [b,p,sz1,sz2]=bpj{:}
    path = cpr.corinv(b);
    // get obj from path 
    // obj = scs_m(scs_full_path(path));
    obj = scs_m(scs_full_path(path));
    osz1 = obj.model.out(p);
    p2 = min(1,size(obj.model.out2,'*'));
    if verbose then 
      if obj.gui == 'DUMMY' then oname = obj.graphics.exprs; else oname = obj.gui;end
      if p2 == 0 then
	printf("Updates out port %d for block %s: from %dx[] to %dx%d\n",p,oname,osz1,sz1,sz2);
      else
	osz2 = obj.model.out2(p2);
	printf("Updates out port %d for block %s: from %dx%d to %dx%d\n",p,oname,osz1,osz2,sz1,sz2);
      end
    end
    obj.model.out(p)=sz1;
    obj.model.out2(p)=sz2;
    scs_m(scs_full_path(path))= obj;
  end

  for j = 1: size(bp_in,1)
    bpj = bp_in(j,:);
    [b,p,sz1,sz2]=bpj{:}
    path = cpr.corinv(b);
    // get obj from path 
    // obj = scs_m(scs_full_path(path));
    obj = scs_m(scs_full_path(path));
    isz1 = obj.model.in(p);
    p2 = min(1,size(obj.model.in2,'*'));

    if verbose then 
      if obj.gui == 'DUMMY' then oname = obj.graphics.exprs; else oname = obj.gui;end
      if p2 == 0 then
	printf("Updates in  port %d for block %s: from %dx[] to %dx%d\n",p,oname,isz1,sz1,sz2);
      else
	isz2 = obj.model.in2(p2);
	printf("Updates in  port %d for block %s: from %dx%d to %dx%d\n",p,oname,isz1,isz2,sz1,sz2);
      end
    end
    obj.model.in(p)=sz1;
    obj.model.in2(p)=sz2;
    scs_m(scs_full_path(path))= obj;
  end
  
  function modele2=adjust_in2(modele1)
    //adjust dimension of in2
    modele2=modele1;
    sz_in=size(modele1.in,'*');
    sz_in2=size(modele1.in2,'*');
    sz_intyp=size(modele1.intyp,'*');
    if sz_in2 < sz_in then
      modele2.in2=[modele2.in2(:);ones(sz_in-sz_in2,1)]
    end
    if sz_intyp<sz_in then
      modele2.intyp=[modele2.intyp(:);ones(sz_in-sz_intyp,1)]
    end
  endfunction
  
  function modele2=adjust_out2(modele1)
    //adjust dimension of out2
    modele2=modele1;
    sz_out=size(modele1.out,'*');
    sz_out2=size(modele1.out2,'*');
    sz_outtyp=size(modele1.outtyp,'*');
    //adjust dimension of out2
    if sz_out2 < sz_out then
      modele2.out2=[modele2.out2(:);ones(sz_out-sz_out2,1)]
    end
    //adjust dimension of outtyp
    if sz_outtyp<sz_out then
      modele2.outtyp=[modele2.outtyp(:);ones(sz_out-sz_outtyp,1)]
    end
  endfunction

  function [scs_m,from_changed,to_changed]= adjust_from_to(scs_m,from,to)

    // printf("Look at link %s -> %s",scs_m.objs(from(1)).gui,scs_m.objs(to(1)).gui);
        
    from_changed = %f;
    to_changed = %f;
    // check
    scs_m.objs(from(1)).model = adjust_out2(scs_m.objs(from(1)).model);
    scs_m.objs(to(1)).model = adjust_in2(scs_m.objs(to(1)).model);
    
    if scs_m.objs(from(1)).model.out(from(2)) > 0 &&
      scs_m.objs(to(1)).model.in(to(2)) > 0 &&
      scs_m.objs(from(1)).model.out(from(2)) <> scs_m.objs(to(1)).model.in(to(2)) then
      if ~(scs_m.objs(from(1)).gui.equal['SPLIT_f'] || scs_m.objs(to(1)).gui.equal['SPLIT_f']) then 
	printf("(Inconsistency in/out !)");
      else
	printf("(Inconsistency in/out with a split implied!)");
      end
    end
	
    if scs_m.objs(from(1)).model.out(from(2)) < 0 &&
      scs_m.objs(to(1)).model.in(to(2)) < 0 then
      printf(" out and in are both negatives !\n");
    elseif scs_m.objs(from(1)).model.out(from(2)) > 0 then
      if scs_m.objs(to(1)).model.in(to(2)) <> scs_m.objs(from(1)).model.out(from(2)) then 
	//printf("updates of objs(%d)->to(%d)\n",to(1),to(2));
	scs_m.objs(to(1)).model.in(to(2)) = scs_m.objs(from(1)).model.out(from(2));
	to_changed=%t;
      end
    else 
      if scs_m.objs(from(1)).model.out(from(2)) <> scs_m.objs(to(1)).model.in(to(2)) then
	//printf("updates of objs(%d)->out(%d)\n",from(1),from(2));
	scs_m.objs(from(1)).model.out(from(2)) = scs_m.objs(to(1)).model.in(to(2));
	from_changed=%t
      end
    end

    if  scs_m.objs(from(1)).model.out2(from(2)) > 0 &&
      scs_m.objs(to(1)).model.in2(to(2)) > 0 &&
      scs_m.objs(from(1)).model.out2(from(2)) <> scs_m.objs(to(1)).model.in2(to(2)) then
      if ~(scs_m.objs(from(1)).gui.equal['SPLIT_f'] || scs_m.objs(to(1)).gui.equal['SPLIT_f']) then 
	printf("(Inconsistency in out2/in2 !)");
      end
    end
	
    if scs_m.objs(from(1)).model.out2(from(2)) < 0 &&
      scs_m.objs(to(1)).model.in2(to(2)) < 0 then
      printf(" out2 and in2 are both negatives !\n");
    elseif scs_m.objs(from(1)).model.out2(from(2)) > 0 then
      if  scs_m.objs(to(1)).model.in2(to(2)) <> scs_m.objs(from(1)).model.out2(from(2)) then
	//printf("updates of objs(%d)->to(%d)\n",to(1),to(2));
	scs_m.objs(to(1)).model.in2(to(2)) = 	scs_m.objs(from(1)).model.out2(from(2));
	to_changed=%t;
      end 
    else
      if scs_m.objs(from(1)).model.out2(from(2)) <> scs_m.objs(to(1)).model.in2(to(2)) then 
	//printf("updates of objs(%d)->out2(%d)\n",from(1),from(2));
	scs_m.objs(from(1)).model.out2(from(2)) = scs_m.objs(to(1)).model.in2(to(2));
	from_changed=%t
      end
    end

    // if splits were updated reflect in and out in the split
    if scs_m.objs(from(1)).model.sim(1)=='lsplit' && from_changed then 
      if scs_m.objs(from(1)).model.out(from(2)) > 0 then
	// Il faut aussi metre a jour les autres out
	scs_m.objs(from(1)).model.out(:)=scs_m.objs(from(1)).model.out(from(2));
	scs_m.objs(from(1)).model.out2 =  ones(size(scs_m.objs(from(1)).model.out,'*'),1);
	scs_m.objs(from(1)).model.out2(:)=scs_m.objs(from(1)).model.out2(from(2));
	scs_m.objs(from(1)).model.in(from(2)) = scs_m.objs(from(1)).model.out(from(2));
	scs_m.objs(from(1)).model.in2(from(2)) = scs_m.objs(from(1)).model.out2(from(2));
      end
    end
    if scs_m.objs(to(1)).model.sim(1)=='lsplit' && to_changed then
      if scs_m.objs(to(1)).model.in(to(2)) > 0 then
	scs_m.objs(to(1)).model.out(:) = scs_m.objs(to(1)).model.in(to(2));
	scs_m.objs(to(1)).model.out2 = ones(size(scs_m.objs(to(1)).model.out,'*'),1);
	scs_m.objs(to(1)).model.out2(:) = scs_m.objs(to(1)).model.in2(to(2));
      end
    end
    
    if from_changed then
      // printf(": from was changed,")
    elseif to_changed then
      // printf(": to was changed,");
    end
    if from_changed || to_changed then
      //printf("\n");
    end
  endfunction
  
  function [scs_m,to_changed]=scsm_adjust_to_split(to)
    // propagate dimensions from to which is a split.
    // we propagate on the to side of the link
    // taking care that a split may have multiple to
    from = to;
    zlink=scs_m.objs(to(1)).graphics.pout;
    printf("A split with %d out\n",size(zlink,'*'));
    tos=[];
    for kk=1:size(zlink,'*') do
      to =scs_m.objs(zlink(kk)).to;
      tos.concatd[to];
      [scs_m,from_changed1,to_changed1]= adjust_from_to(scs_m,from,to);
      to_changed = to_changed || from_changed1;
    end
    for kk=1:size(tos,1)
      if scs_m.objs(tos(kk,1)).model.sim(1)=='lsplit' then
	[scs_m,to_changed1]=scsm_adjust_to_split(tos(kk,:));
	to_changed = to_changed || from_changed1;
      end
    end
  endfunction

  function [scs_m,from_changed]=scsm_adjust_from_split(from)
    // propagate dimensions from from which is a split.
    // we propagate on the from side of the split
    from_changed = %t;
    while %t do
      if from_changed && scs_m.objs(from(1)).model.sim(1)=='lsplit' then 
	to = from;
	zlink=scs_m.objs(from(1)).graphics.pin
	from=scs_m.objs(zlink).from
	[scs_m,from_changed,to_changed]= adjust_from_to(scs_m,from,to);
      else
	break;
      end
    end
  endfunction

  function fail=scsm_check_splits(scs_m)
    // check that the splits are initiated to -1
    fail = %f;
    for i=1:length(scs_m.objs)
      o = scs_m.objs(i);
      if o.type == 'Block' && o.model.sim(1)=='lsplit' then
	// a split
	if or(o.model.out(:)<>-1) then fail=%t;end
	if or(o.model.in(:)<>-1) then fail=%t;end
	if or(o.model.out2(:)<>-1) then fail=%t;end
	if or(o.model.in2(:)<>-1) then fail=%t;end
	if fail then break;end;
      elseif o.type == 'Block' && or(o.model.sim(1) ==  ['super','csuper','asuper']) then
	fail = scsm_check_splits(scs_m.objs(i).model.rpar);
	if fail then break;end;
      end
    end
    if fail then printf("Some splits are wrongly initiated ?\n");end
  endfunction

  function scs_m=scsm_initialize_splits(scs_m)
    // check that the splits are initiated to -1
    for i=1:length(scs_m.objs)
      o = scs_m.objs(i);
      if o.type == 'Block' && or(o.model.sim(1)==['lsplit';'limpsplit']) then
	// a split
	scs_m.objs(i).model.out(:)=-1;
	scs_m.objs(i).model.in(:)=-1;
	scs_m.objs(i).model.in2(:)=-1;
	scs_m.objs(i).model.out2(:)=-1;
      elseif o.type == 'Block' && or(o.model.sim(1) ==  ['super','csuper','asuper']) then
	model_rpar = scsm_initialize_splits(scs_m.objs(i).model.rpar);
	scs_m.objs(i).model.rpar = model_rpar;
      end
    end
  endfunction
  
  function [scs_m,count]=scsm_propagate_sizes(scs_m,count=0)
    // second phase: propagate block information
    // using the links
    for i=1:length(scs_m.objs)
      o = scs_m.objs(i);
      if o.type == 'Block' && or(o.model.sim(1) ==  ['super','csuper','asuper']) then
	//printf("Enter super for block %s\n",o.gui);
	[sub_scsm,count_super]=scsm_propagate_sizes(o.model.rpar);
	//printf("Quit super for block %s\n",o.gui);
	if count_super <> 0 then 
	  scs_m.objs(i).model.rpar = sub_scsm;
	  count = count + count_super;
	  // adjust_s_ports: propagate information from inside
	  // to outside. we should make both direction XXX
	  [ok,sbloc]=adjust_s_ports(scs_m.objs(i));
	  scs_m.objs(i) = sbloc;
	  // scicos_modelica_super_adjust_ports(scs_m.objs(i));
	end
      elseif o.type == 'Link' && o.ct(2) == 1 then
	// a regular Link
	// get the from block following the splits 
	from = o.from;
	to = o.to;
	[scs_m,from_changed,to_changed]= adjust_from_to(scs_m,from,to);
	if from_changed || to_changed then count = count+1;end
	// we can propagate changes along the splits or wait for
	// iterations to do the job 
	if %t && from_changed && scs_m.objs(from(1)).model.sim(1)=='lsplit' then
	  [scs_m,from_changed]=scsm_adjust_from_split(from);
	end
	if %t && to_changed && scs_m.objs(to(1)).model.sim(1)=='lsplit' then
	  [scs_m,to_changed]=scsm_adjust_to_split(to);
	end
      end
    end
  endfunction

  scs_m=scsm_initialize_splits(scs_m)
  // scsm_check_splits(scs_m);

  pass = 0;
  while %t then 
    [scs_m,count]=scsm_propagate_sizes(scs_m);
    pass = pass +1;
    if count == 0 then break;
    else
      printf("new pass with %d updates\n",count);
    end
    if pass == 10 then
      printf("stop at pass %d with uncompleted propagation\n",pass);
    end
  end
endfunction

function scicos_write_port_sizes(scs_m,fname,open=%t)
  if open then 
    F=fopen(fname,mode="w");
  end
  for i=1:length(scs_m.objs)
    o = scs_m.objs(i);
    if o.type == 'Block' && o.model.sim(1) <> 'lsplit' then
      F.printf["// Block %s\n",o.gui];
      if length(o.graphics.id)<>0 then
	sb=sprintf("%s",o.graphics.id);
      else
	sb=sprintf("%s",o.gui);
      end
      for j=1:size(o.model.out,'*')
	F.printf["parameter %s.out%s.m=%d\n",sb,string(j),o.model.out(j)];
	F.printf["parameter %s.out%s.n=%d\n",sb,string(j),o.model.out2(j)];
      end
      for j=1:size(o.model.in,'*')
	F.printf["parameter %s.in%s.m=%d\n",sb,string(j),o.model.in(j)];
	F.printf["parameter %s.in%s.n=%d\n",sb,string(j),o.model.in2(j)];
      end
      if o.type == 'Block' && or(o.model.sim(1) ==  ['super','csuper','asuper']) then
	scicos_write_port_sizes(o.model.rpar,fname,open=%f);
      end
    end
  end
  if open then F.close[];end
endfunction


function blk=scicos_modelica_super_adjust_ports(blk)
  // we want to be able to propagate sizes bidirectionnaly
  // from inside to ouside and from ouside to inside
  // collect inside informations
  infos_out=zeros(0,5);
  infos_in=zeros(0,5);
  for k=1:length(blk.model.rpar)
    o=blk.model.rpar.objs(k)
    if o.type=='Block' then
      if o.gui == 'DUMMY' then oname = o.graphics.exprs; else oname = o.gui;end
      select oname
	case {'OUTIMPL_f','OUT_f'} then
	  info_out = [k, o.model.ipar, o.model.in, o.model.in2,o.model.intyp];
	  infos_out = [infos_out;info_out];
	case {'INIMPL_f', 'IN_f'} then
	  info_in = [k, o.model.ipar, o.model.out, o.model.out2,o.model.outtyp];
	  infos_in = [infos_in;info_in];
      end
    end
  end
  if size(blk.model.in,'*') <> size(infos_in,'r') then pause bug;end
  if size(blk.model.out,'*') <> size(infos_out,'r') then pause bug;end
  for k=1:size(blk.model.in,'*')
    I=find(k== infos_in(:,2));
    if isempty(I) then pause;bug;end
    if blk.model.in(k) <> infos_in(I,3) then pause to_be_updated;end
  end
  for k=1:size(blk.model.out,'*')
    I=find(k== infos_out(:,2));
    if isempty(I) then pause;bug;end
    if blk.model.out(k) <> infos_out(I,3) then pause to_be_updated;end
  end
  pause zz;
endfunction
