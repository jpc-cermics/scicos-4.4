function  [needcompile]=scicos_object_check_needcompile(xx,xxn)
// xx and xxn are to blocks. 
// xxn is a new version of xx and we check here the 
// needcompile level requested to replace xx by xxn
  needcompile = 0;
  if xxn.equal[xx] then return;end 
  // now xxn <> xx 
  // get the models 
  model=xx.model;
  model_n=xxn.model;
  if is_modelica_block(xx) then 
    // Modelia block case 
    if model_n.equal[model] then return;end 
    eq=model.equations;
    eqn=model_n.equations;
    if ~eq.model.equal[eqn.model] || ~eq.inputs.equal[eqn.inputs] ||  ...
	  ~eq.outputs.equal[eqn.outputs] then
      needcompile=4;
      return;
    end
    // test parameter changes
    if ~eq.parameters.equal[eqn.parameters] then
      param_name   = eq.parameters(1);
      param_name_n = eqn.parameters(1);
      if ~param_name.equal[param_name_n] then
	needcompile=4;
	return;
      else
	for i=1:length(eq.parameters(2))
	  if eq.parameters(2)(i).equal[(eqn.parameters(2)(i))] then
	    needcompile=0;
	    TMPDIR=getenv('NSP_TMPDIR')
	    XML=file('join',[TMPDIR,stripblanks(scs_m.props.title(1))+'_imf_init.xml']);
	    isok=execstr("file(""delete"",XML)",errcatch=%t)
	    if ~isok then
	      x_message(['Unable to delete the XML file'])
	      lasterror();
	    end
	    XMLTMP=file('join',[TMPDIR,stripblanks(scs_m.props.title(1))+'_imSim.xml']);
	    isok=execstr("file(""delete"",XMLTMP)",errcatch=%t)
	    if ~isok then
	      x_message(['Unable to delete the XML file'])
	      lasterror();
	    end
	    break;
	  end
	end
      end
    end
    if size(o.model.sim,'*') > 1 then
      if (o.model.sim(2)==30004) then 
	// only if it is the Modelica generic block
	if or(o.graphics.exprs<>xxn.graphics.exprs) then  
	  // if equation in generic Modelica Mblock change
	  needcompile=4;
	end
      end
    end
    return;
  end
  // other cases 
  modified= ~model.equal[model_n];
  if modified then 
    if ~model.in.equal[model_n.in] || ~model.out.equal[model_n.out] || ...
	  ~model.in2.equal[model_n.in2] || ~model.out2.equal[model_n.out2] || ...
	  ~model.outtyp.equal[model_n.outtyp] || ~model.intyp.equal[model_n.intyp] then
      needcompile=1
    end
    if ~model.firing.equal[model_n.firing] then
      needcompile=2
    end
    if ~(size(model.in,'*').equal[size(model_n.in,'*')]) ||...
	  ~(size(model.out,'*').equal[size(model_n.out,'*')]) ||...
	    ~(size(model.evtin,'*').equal[size(model_n.evtin,'*')]) then
      needcompile=4
    end
    if model.sim.equal['input'] || model.sim.equal['output'] then
      if ~model.ipar.equal[model_n.ipar] then
	needcompile=4
      end
    end
    if ~model.blocktype.equal[model_n.blocktype] || ...
	  ~model.dep_ut.equal[model_n.dep_ut]  then
      needcompile=4
    end
    if ~model.nzcross.equal[model_n.nzcross] || ~model.nmode.equal[model_n.nmode] then
      needcompile=4
    end
    if prod(size(model_n.sim))>1 then
      if model_n.sim(2)>1000 then
	if ~model.sim(1).equal[model_n.sim(1)] then
	  needcompile=4
	end
      end
    end
  end
endfunction
