function [x,y,typ]=DUMMY(job,arg1,arg2)
  // A dummy block used at compile time to check dimensions
  // XXXX attenion il lui faut les events en graphique 
  x=[];y=[];typ=[];
  select job
    case 'plot' then
      standard_draw(arg1)
    case 'getinputs' then
      [x,y,typ]=standard_inputs(arg1)
    case 'getoutputs' then
      [x,y,typ]=standard_outputs(arg1)
    case 'getorigin' then
      [x,y]=standard_origin(arg1)
    case 'set' then
      x=arg1
    case 'define' then
      //----------- Define

      function blk = DUMMY_define(old)
	blk = scicos_block(gui='DUMMY');
	if nargin == 1 then
	  blk.graphics = old.graphics;
	  gr_i=["txt=[arg1.graphics.exprs];";
		"xstringb(orig(1),orig(2),txt,sz(1),sz(2),""fill"")"];
	  blk.graphics.gr_i = gr_i;
	  blk.graphics.exprs = old.gui;
	  
	  blk.model.dep_ut = old.model.dep_ut
	  blk.model.sim = list('dummy',4);
	  blk.model.in = old.model.in;
	  blk.model.in2 = old.model.in2;
	  blk.model.intyp = old.model.intyp;
	  blk.model.out = old.model.out;
	  blk.model.out2 = old.model.out2;
	  blk.model.outtyp = old.model.outtyp;
	else
	  blk.graphics.sz = [2, 2];
	end
      endfunction

      if nargin == 2 then 
	x= DUMMY_define(arg1);
      else
	x= DUMMY_define();
      end
  end
endfunction


  function ok = scicos_modelica_check_sizes(scs_m)
    // checks if scicos schema contains modelica blocks with
    // unspecified sizes
    ok = %t;
    for i=1:length(scs_m.objs)
      o = scs_m.objs(i);
      if o.type == 'Block' then
	if or(o.model.sim(1) ==  ['super','csuper','asuper']) then
	  // propagate in internal schema 
	  o_new = o;
	  ok= scicos_modelica_check_sizes(o.model.rpar);
	  if ~ok then return;end
	elseif is_modelica_block(o)
	  ok = isempty(o.model.in) || and(o.model.in >= 0);
	  ok = ok && (isempty(o.model.out) || and(o.model.out >= 0));
	  ok = ok && (isempty(o.model.in2) || and(o.model.in2 >= 0));
	  ok = ok && (isempty(o.model.out2) || and(o.model.out2 >= 0));
	  if ~ok then return;end
	end
      end
    end
  endfunction
  
  function scs_m= scicos_dummy(scs_m)
    // replace all modelica blocks by dummy and
    // changes the link so as to be standard links
    for i=1:length(scs_m.objs)
      o = scs_m.objs(i);
      if o.type == 'Block' then
	if or(o.model.sim(1) ==  ['super','csuper','asuper']) then
	  // propagate in internal schema 
	  o_new = o;
	  [scsm]= scicos_dummy(o.model.rpar);
	  o_new.model.rpar = scsm;
	  // update the block 
	  scs_m.objs(i)=o_new;
	elseif o.gui=='IMPSPLIT_f' then
	  // 
	  o_new= DUMMY('define',o);
	  o_new.model.in = - 1;
	  o_new.model.out = [- 1;-1];
	  scs_m.objs(i)=o_new;
	elseif is_modelica_block(o)
	  // 
	  o_new= DUMMY('define',o);
	  scs_m.objs(i)=o_new;
	end
      elseif o.type == 'Link' then
	// replace implicit by explicit but explicit can be 1 or 3 what's the difference ?
	if o.ct(2) == 2 then  o.ct(2) = 1;scs_m.objs(i)=o;end
      end
    end
  endfunction

  function [scs_m,doeval]= scicos_update_modelica_port_sizes(scs_m,scs_m1)
    // scs_m and scs_m1 have the same tree structure
    // scs_m1 is used to updates sizes in scs_m 
    doeval = %f;
    for i=1:length(scs_m.objs)
      o = scs_m.objs(i);
      if o.type == 'Block' then
	if or(o.model.sim(1) ==  ['super','csuper','asuper']) then
	  // propagate in internal schema 
	  o_new = o;
	  [scsm,doeval1]= scicos_update_modelica_port_sizes(o.model.rpar,scs_m1.objs(i).model.rpar);
	  doeval = doeval || doeval1;
	  o_new.model.rpar = scsm;
	  // update the block 
	  scs_m.objs(i)=o_new;
	  doeval = doeval || scs_m.objs(i).model.in < 0 || scs_m.objs(i).model.out < 0;
	  scs_m.objs(i).model.in = scs_m1.objs(i).model.in;
	  scs_m.objs(i).model.in2 = scs_m1.objs(i).model.in2;
	  scs_m.objs(i).model.intyp = scs_m1.objs(i).model.intyp;
	  scs_m.objs(i).model.out = scs_m1.objs(i).model.out;
	  scs_m.objs(i).model.out2 = scs_m1.objs(i).model.out2;
	  scs_m.objs(i).model.outtyp = scs_m1.objs(i).model.outtyp;
	elseif is_modelica_block(o)
	  //
	  doeval = doeval || scs_m.objs(i).model.in < 0 || scs_m.objs(i).model.out < 0;
	  scs_m.objs(i).model.in = scs_m1.objs(i).model.in;
	  scs_m.objs(i).model.in2 = scs_m1.objs(i).model.in2;
	  scs_m.objs(i).model.intyp = scs_m1.objs(i).model.intyp;
	  scs_m.objs(i).model.out = scs_m1.objs(i).model.out;
	  scs_m.objs(i).model.out2 = scs_m1.objs(i).model.out2;
	  scs_m.objs(i).model.outtyp = scs_m1.objs(i).model.outtyp;
	end
      end
    end
  endfunction
  
  function scs_m = scicos_compiler_modelica_pass0(scs_m,verbose = %f)
  // This pass is used to try to fix the sizes of modelica blocks
  // this is usefull since it would most of the time to modelica errors
  // at modelica translator/compile pass
  
  ok = scicos_modelica_check_sizes(scs_m);
  if ok then
    if verbose then print("no negative sizes in modelica\n");end
    return;
  end
  // replace all scicos blocks par standard block
  scs_m1 = scicos_dummy(scs_m);
  if verbose then printf("subsitute modelica blocks pass ended\n");end
  // use this fake schema to compile to obtain sizes 
  scs_m1 = scicos_port_size_propagate(scs_m1);
  if verbose then printf("propagate port sizes pass ended\n");end
  // propagate sizes in the original schem 
  scs_m = scicos_update_modelica_port_sizes(scs_m,scs_m1);
  if verbose then printf("update port sizes pass ended\n");end
  // make a scilent_eval to be sure that consequences of size changes are taken into account;
  scs_m = do_silent_eval(scs_m);
  if verbose then printf("silent eval pass ended\n");end
endfunction





  
