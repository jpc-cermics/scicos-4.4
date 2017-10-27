function [scs_m]=scicos_port_size_propagate(scs_m,%cpr)
  //
  bp_out=zeros(0,4);
  bp_in=zeros(0,4);
  // loop on the size informations stored in %cpr
  // and push this information in bp
  // a raw of bp =[ block-id, port-number, size1, size2]
  for j=1:size(%cpr.state('outtb')) do
    // loop on links 
    sz = size(%cpr.state.outtb(j));
    // 
    N = find(%cpr.sim.outlnk == j);
    for n = N  do 
      // compute (b,p) such that n = outptr(b)+ p-1
      // pause bp
      b = max(find( %cpr.sim.outptr <= n))
      p = n - %cpr.sim.outptr(b) + 1;
      // if abs(n - ( %cpr.sim.outptr(b)+ p-1)) > 0.1 then pause incoherence;end 
      bp_out.concatd[[b,p,sz]];
    end
    N = find(%cpr.sim.inplnk == j);
    for n = N  do 
      // compute (b,p) such that n = inpptr(b)+ p-1 
      b = max(find( %cpr.sim.inpptr <= n))
      p = n - %cpr.sim.inpptr(b) + 1;
      // if abs(n - ( %cpr.sim.inpptr(b)+ p-1)) > 0.1 then pause incoherence;end 
      bp_in.concatd[[b,p,sz]];
    end
  end
  // propagate the bp information in scs_m
  // we obtain a block from its block-id by
  // obj = scs_m(scs_full_path(%cpr.corinv(block-id)));
  for j = 1: size(bp_out,1)
    bpj = bp_out(j,:);
    [b,p,sz1,sz2]=bpj{:}
    path = %cpr.corinv(b);
    // get obj from path 
    // obj = scs_m(scs_full_path(path));
    obj = scs_m(scs_full_path(path));
    osz1 = obj.model.out(p);
    p2 = min(1,size(obj.model.out2,'*'));
    if p2 == 0 then
      printf("Updates out port %d for block %s: from %dx[] to %dx%d\n",p,obj.gui,osz1,sz1,sz2);
    else
      osz2 = obj.model.out2(p2);
      printf("Updates out port %d for block %s: from %dx%d to %dx%d\n",p,obj.gui,osz1,osz2,sz1,sz2);
    end
    
    obj.model.out(p)=sz1;
    obj.model.out2(p)=sz2;
    scs_m(scs_full_path(path))= obj;
  end

  for j = 1: size(bp_in,1)
    bpj = bp_in(j,:);
    [b,p,sz1,sz2]=bpj{:}
    path = %cpr.corinv(b);
    // get obj from path 
    // obj = scs_m(scs_full_path(path));
    obj = scs_m(scs_full_path(path));
    printf("Updates in port %d for block %s\n",p,obj.gui);
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
    
  function [scs_m]=scsm_propagate_sizes(scs_m)
    // second phase: propagate block information
    // using the links
    for i=1:length(scs_m.objs)
      o = scs_m.objs(i);
      if o.type == 'Block' && or(o.model.sim(1) ==  ['super','csuper','asuper']) then
	printf("Enter super for block %s\n",o.gui);
	sub_scsm=scsm_propagate_sizes(o.model.rpar);
	printf("Quit super for block %s\n",o.gui);
	scs_m.objs(i).model.rpar = sub_scsm;
      elseif o.type == 'Link' && o.ct(2) == 1 then
	// a regular Link
	// get the from block following the splits 
	from = o.from;
	while %t
	  if scs_m.objs(from(1)).model.sim(1)=='lsplit' then
	    __link=scs_m.objs(from(1)).graphics.pin
	    from=scs_m.objs(__link).from
	  else
	    break
	  end
	end
	// get the to block 
	to = o.to
	printf("Look at link %s -> %s\n",scs_m.objs(from(1)).gui,scs_m.objs(to(1)).gui);
	// check
	scs_m.objs(from(1)).model = adjust_out2(scs_m.objs(from(1)).model);
	scs_m.objs(to(1)).model = adjust_in2(scs_m.objs(to(1)).model);
	
	if scs_m.objs(from(1)).model.out(from(2)) > 0 &&
	  scs_m.objs(to(1)).model.in(to(2)) > 0 &&
	  scs_m.objs(from(1)).model.out(from(2)) <> scs_m.objs(to(1)).model.in(to(2)) then
	  if ~(scs_m.objs(from(1)).gui.equal['SPLIT_f'] || scs_m.objs(to(1)).gui.equal['SPLIT_f']) then 
	    printf("Inconsistency in in/out !\n");
	  end
	end
	
	if scs_m.objs(from(1)).model.out(from(2)) < 0 &&
	  scs_m.objs(to(1)).model.in(to(2)) < 0 then
	  printf(" out and in are both negatives !\n");
	elseif %f && scs_m.objs(from(1)).model.out(from(2)) > 0 then
	  //printf("updates of objs(%d)->to(%d)\n",to(1),to(2));
	  scs_m.objs(to(1)).model.in(to(2)) = 	scs_m.objs(from(1)).model.out(from(2));
	elseif %f then 
	  //printf("updates of objs(%d)->out(%d)\n",from(1),from(2));
	  scs_m.objs(from(1)).model.out(from(2)) = scs_m.objs(to(1)).model.in(to(2));
	end

	if  scs_m.objs(from(1)).model.out2(from(2)) > 0 &&
	  scs_m.objs(to(1)).model.in2(to(2)) > 0 &&
	  scs_m.objs(from(1)).model.out2(from(2)) <> scs_m.objs(to(1)).model.in2(to(2)) then
	  if ~(scs_m.objs(from(1)).gui.equal['SPLIT_f'] || scs_m.objs(to(1)).gui.equal['SPLIT_f']) then 
	    printf("Inconsistency in out2/in2 !\n");
	  end
	end
	
	if scs_m.objs(from(1)).model.out2(from(2)) < 0 &&
	  scs_m.objs(to(1)).model.in2(to(2)) < 0 then
	  printf(" out2 and in2 are both negatives !\n");
	elseif %f && scs_m.objs(from(1)).model.out2(from(2)) > 0 then
	  //printf("updates of objs(%d)->to(%d)\n",to(1),to(2));
	  scs_m.objs(to(1)).model.in2(to(2)) = 	scs_m.objs(from(1)).model.out2(from(2));
	elseif %f
	  //printf("updates of objs(%d)->out2(%d)\n",from(1),from(2));
	  scs_m.objs(from(1)).model.out2(from(2)) = scs_m.objs(to(1)).model.in2(to(2));
	end
      end
    end
  endfunction

  [scs_m]=scsm_propagate_sizes(scs_m);
  
endfunction


