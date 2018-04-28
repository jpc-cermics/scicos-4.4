function path=save_super(scs_m,fpath='./',gr_i='',sz=[],sim='super')
// Copyright INRIA
// given a super block definition scs_m save_super creates 
// this super block's interfacing function
// gr_i and sz for initial values
//   gr_i a vector of string (matrix size nx1)
//   sz a vector of real (matrix size 1x2)

  function txt=save_super_set(ppath)
    txt=['    y=needcompile'
	 '    while %t do'
	 '      [x,newparameters,needcompile]=scicos(arg1.model.rpar)'
	 '      arg1.model.rpar=x'
	 '      [ok,arg1]=adjust_s_ports(arg1)'
	 '      if ok then'
	 '        x=arg1'
	 '        y=needcompile'
	 '        typ=newparameters'
	 '        %exit=resume(%f)'
	 '      else'
	 '        %r=2'
	 '        %r=message([''SUPER BLOCK needs to be edited;'';''Edit or exit by removing all edition''],[''Edit'';''Exit''])'
	 '        if %r==2 then typ=list(),%exit=resume(%t),end'
	 '      end'
	 '    end'];
  endfunction

  function txt=save_csuper_set(ppath)
    if isempty(ppath) then txt=m2s([]);end 
    bl='  '
    com='/'+'/'
    t1=sci2exp(ppath,'ppath')
    txt=['  '+com+'paths to updatable parameters or states'
	 bl(ones(size(t1,1),1))+t1;
	 '  newpar=list();';
	 '  y=0;';
	 '  for path=ppath do'
	 '    np=size(path,''*'')'
	 '    spath=list()'
	 '    for k=1:np'
	 '      spath($+1)=''model'''
	 '      spath($+1)=''rpar'''
	 '      spath($+1)=''objs'''
	 '      spath($+1)=path(k)'
	 '    end'
	 '    xx=arg1(spath)'+com+' get the block';
	 '    execstr(''xxn=''+xx.gui+''(''''set'''',xx)'')'
	 '    if ~isequalbitwise(xxn,xx) then '
	 '      model=xx.model'
	 '      model_n=xxn.model'
	 '      if ~is_modelica_block(xx) then'
	 '        modified=or(model.sim<>model_n.sim)|..'
	 '                 ~isequal(model.state,model_n.state)|..'
	 '                 ~isequal(model.dstate,model_n.dstate)|..'
	 '                 ~isequal(model.odstate,model_n.odstate)|..'
	 '                 ~isequal(model.rpar,model_n.rpar)|..'
	 '                 ~isequal(model.ipar,model_n.ipar)|..'
	 '                 ~isequal(model.opar,model_n.opar)|..'
	 '                 ~isequal(model.label,model_n.label)'
	 '        if or(model.in<>model_n.in)|or(model.out<>model_n.out)|..'
	 '           or(model.in2<>model_n.in2)|or(model.out2<>model_n.out2)|..'
	 '           or(model.outtyp<>model_n.outtyp)|or(model.intyp<>model_n.intyp) then'
	 '          needcompile=1'
	 '        end'
	 '        if or(model.firing<>model_n.firing) then'
	 '          needcompile=2'
	 '        end'
	 '        if (size(model.in,''*'')<>size(model_n.in,''*''))|..'
	 '          (size(model.out,''*'')<>size(model_n.out,''*''))|..'
	 '          (size(model.evtin,''*'')<>size(model_n.evtin,''*'')) then'
	 '          needcompile=4'
	 '        end'
	 '        if model.sim.equal[''input''] || model.sim.equal[''output''] then'
	 '          if model.ipar<>model_n.ipar then'
	 '            needcompile=4'
	 '          end'
	 '        end'
	 '        if or(model.blocktype<>model_n.blocktype)|..'
	 '           or(model.dep_ut<>model_n.dep_ut) then'
	 '          needcompile=4'
	 '        end'
	 '        if (model.nzcross<>model_n.nzcross)|(model.nmode<>model_n.nmode) then'
	 '          needcompile=4'
	 '        end'
	 '        if prod(size(model_n.sim))>1 then'
	 '          if model_n.sim(2)>1000 then'
	 '            if model.sim(1)<>model_n.sim(1) then'
	 '              needcompile=4'
	 '            end'
	 '          end'
	 '        end'
	 '      else'
	 '        modified=or(model_n<>model)'
	 '        eq=model.equations;eqn=model_n.equations;'
	 '        if or(eq.model<>eqn.model)|or(eq.inputs<>eqn.inputs)|..'
	 '           or(eq.outputs<>eqn.outputs) then'
	 '          needcompile=4'
	 '        end'
	 '      end'
	 '     '+com+'parameter or states changed'
	 '      arg1(spath)=xxn'+com+' Update'
	 '      newpar(size(newpar)+1)=path'+com+' Notify modification'
	 '      y=max(y,needcompile)';
	 '    end'
	 '  end';
	 '  x=arg1'
	 '  typ=newpar'];
  endfunction

  
  path=[]
  scs_m=do_purge(scs_m);
  scs_m=scs_m_remove_gr(scs_m);
    
  nam=scs_m.props.title(1);
  nam=strsubst(nam,' ','_')
  in=[];out=[];clkin=[];clkout=[];

  for k=1:length(scs_m.objs)
    o=scs_m.objs(k)
    if o.type  == 'Block' then
      model=o.model
      select o.gui
      case 'IN_f' then
        in=[in;model.out]
      case 'OUT_f' then
        out=[out;model.in]
      case 'CLKIN_f' then
        clkin=[clkin;model.evtout]
      case 'CLKOUT_f' then
        clkout=[clkout;model.evtin];
      case 'CLKINV_f' then
        clkin=[clkin;model.evtout]
      case 'CLKOUTV_f' then
        clkout=[clkout;model.evtin]; 
      end
    end
  end

  model=scicos_model()
  model.sim=sim;
  model.in=in
  model.out=out
  model.evtin=clkin
  model.evtout=clkout
  model.rpar=scs_m
  model.blocktype='h'
  model.dep_ut=[%f %f]

  ppath=getparpath(scs_m,[])

  // form text of the macro
  txt=['function [x,y,typ]='+nam+'(job,arg1,arg2)';
       '  x=[];y=[],typ=[]';
       '  select job';
       '   case ''plot'' then';
       '    standard_draw(arg1)';
       '   case ''getinputs'' then';
       '    [x,y,typ]=standard_inputs(arg1)';
       '   case ''getoutputs'' then';
       '    [x,y,typ]=standard_outputs(arg1)';
       '   case ''getorigin'' then';
       '    [x,y]=standard_origin(arg1)';
       '   case ''set'' then'];
  
  if sim == 'super' then 
    txt =[txt; save_super_set(ppath)];
  else
    txt =[txt; save_csuper_set(ppath)];
  end
  
  txt=[txt;
       '   case ''define'' then']
  
  path=file('join',[stripblanks(fpath);nam+'.sci']);
  ok=execstr('F=fopen(path,mode=''w'');',errcatch=%t);
  if ~ok then 
    message([catenate(lasterror())]);
    return
  end
  F.put_smatrix[txt];
  
  // we separately save the model and the superblock 
  // first the model.rpar 
  if %t then 
    txt=scicos_schema2smat(model.rpar,name='sblock',indent=4);
  else
    txt=scicos_schema2serial(model.rpar,name='sblock',indent=4);
  end
  F.put_smatrix[txt];
  // now the model 
  model.rpar=[];
  txt=scicos_schema2smat(model,name='model',indent=4);
  F.put_smatrix[txt];
  F.put_smatrix[['    model.rpar=sblock;']];
  
  // now the gr_i
  if gr_i == '' then
    txt=['   gr_i=''xstringb(orig(1),orig(2),'''''+nam+''''',sz(1),sz(2),''''fill'''')'';']
  else
    txt= sprint(gr_i,as_read=%t,indent=2);
  end
  F.put_smatrix[txt];
  if isempty(sz) then sz=[2,2];end
  txt=sprintf('   x=standard_define([%d,%d],model,[],gr_i,''%s'')',sz(1),sz(2),nam);
  txt=[txt;
      '  end';
      'endfunction']
  F.put_smatrix[txt];
  F.close[];
endfunction

function txt=scicos_schema2serial(obj,name='z',tag=0,indent=0)
// print a serialized version of obj in txt 
// we could also compress the serialized object 
  S=serialize(obj)
  txt=sprint(S,as_read=%t,indent=indent,name=name+'_serial');
  w=catenate(smat_create(indent,1,' '));
  txt.concatd[sprintf('%s%s=%s_serial.unserialize[];',w,name,name)];
  txt.concatd[sprintf('%sclear(''%s_serial'');',w,name,name)];
  txt.concatd[sprintf('%s%s=update_scs_m(%s);',w,name,name)];
endfunction

  
function txt=scicos_schema2smat(obj,name='z',tag=0,indent=0)
// XX en cours   
  function txt=scicos_obj2smat(obj,name='z',tag=0,indent=0)
  // returns in txt a representation of obj which 
  // should recreate obj if executed by nsp. 
  // Note that the generated code:
  // -- contains calls to scicos_xxx functions when possible 
  // -- the model are not saved 
  // -- the code generated for blocks contains calls to the 
  //    block define function.
  // 
    H=hash(3, codegeneration='codegen',Block='block',Link='link',Text='text');
    txt = m2s([]);
    typ = type(obj,'short');
    w=catenate(smat_create(indent,1,' '));
    temp='x_'+string(tag);
    select typ 
     case 'h' then 
      isref=%f;
      if obj.iskey['type'] then 
	typ=obj.type;
	if  typ=='Block' then 
	  // a block 
	  ok=execstr('ref='+obj.gui+ '(""define"");',errcatch=%t);
	  if ~ok then lasterror();end;
	  txt.concatd[sprintf('%s%s=%s(''define'');',w,temp,obj.gui)];
	  graphics = obj.graphics; ref_graphics = ref.graphics;
	  keys= graphics.__keys;
	  for i=1:size(keys,'*')
	    if ~or(keys(i)==['mlist','tlist']) && ~graphics(keys(i)).equal[ref_graphics(keys(i))] then 
	      nname= sprintf('%s.graphics.%s',temp,keys(i));
	      txt.concatd[scicos_obj2smat(graphics(keys(i)),name=nname,tag=tag+1, ...
					  indent=indent+1)];
	    end
	  end
	  model = obj.model;
	  for key=['in','out','in2','out2','outtyp','intyp'] do
	    nname= sprintf('%s.model.%s',temp,key);
	    txt.concatd[scicos_obj2smat(model(key),name=nname,tag=tag+1, ...
					indent=indent+1)];
	  end
	  txt.concatd[sprintf('%s%s=%s;clear(''%s'');',w,name,temp,temp)];
	  return;
	else 
	  // if typ is in H then use H value instead.
	  if H.iskey[obj.type] then typ=H(obj.type);end
	  fun=sprintf('scicos_%s',typ);
	  if exists(fun,'nsp-function') then
	    ok = execstr(sprintf('ref=scicos_%s()',typ),errcatch=%t);
	    if ~ok then lasterror();else isref=%t; end
	    txt.concatd[sprintf('%s%s=scicos_%s();',w,temp,typ)];
	  else
	    txt.concatd[sprintf('%s%s=hash(%d);',w,temp,length(obj))];
	  end
	end
      else
	txt.concatd[sprintf('%s%s=hash(%d);',w,temp,length(obj))];
      end
      // we have to save each field except if isref is true and 
      // the field is already in ref with the same value 
      // moreover we can decide or not to save models (here we 
      // save models by changing 'models' to 'xxmodels'
      if typ<>'xxmodel' then 
	keys= obj.__keys;
	for i=1:size(keys,'*')
	  
	  if ~(isref && ref.iskey[keys(i)] && obj(keys(i)).equal[ref(keys(i))]) then 
	    if validvar(keys(i)) then 
	      nname= sprintf('%s.%s',temp,keys(i));
	    else
	      nname= sprintf('%s(''%s'')',temp,keys(i));
	    end
	    txt.concatd[scicos_obj2smat(obj(keys(i)),name=nname,tag=tag+1, ...
					indent=indent+1)];
	  end
	end
      end
      txt.concatd[sprintf('%s%s=%s;clear(''%s'');',w,name,temp,temp)];
     case 'l' then
      txt.concatd[sprintf('%s%s=list();',w,temp)];
      for i=1:size(obj)
	txt.concatd[scicos_obj2smat(obj(i),name=temp+'('+string(i)+')',tag=tag+1,indent=indent+1)];
      end
      txt.concatd[sprintf('%s%s=%s;clear(''%s'');',w,name,temp,temp)];
    else
      txt.concatd[sprint(obj,as_read=%t,name=name,indent=indent)];
    end
    // back to def value;
  endfunction;

  // main code 
  // need to purge diagram first since
  obj=do_purge(obj);
  //format("long");
  txt1=scicos_obj2smat(obj,name=name,tag=tag,indent=indent);
  //format();
  // second path to remove extra \n
  txt2=m2s([]);
  i = 1;
  while i <= size(txt1,'*') then 
    str=txt1(i); 
    if part(str,length(str))=='=' then 
      i=i+1;str=str+txt1(i);
    end
    txt2.concatd[str];
    i=i+1;
  end
  txt=txt2;
endfunction 

  
function txt=scicos_schema2api(obj,name='z',tag=0,indent=0)
  
  function txt=scicos_obj2api(obj,name='z',tag=0,indent=0,export=%f)
  // returns in txt a representation of obj which 
  // should recreate obj if executed by nsp. 
  // Note that the generated code:
  // -- contains calls to scicos_xxx functions when possible 
  // -- the model are not saved 
  // -- the code generated for blocks contains calls to the 
  //    block define function.
  // 
    if export then 
      ignore_tags = ['mlist','tlist','gr_i']
    else
      ignore_tags = ['mlist','tlist'];
    end
    H=hash(3, codegeneration='codegen',Block='block',Link='link',Text='text');
    txt = m2s([]);
    typ = type(obj,'short');
    w=catenate(smat_create(indent,1,' '));
    temp='x_'+string(tag);
    select typ 
     case 'h' then 
      isref=%f;
      if obj.iskey['type'] then 
	typ=obj.type;
	if  typ=='Block' then 
	  // a block 
	  ok=execstr('ref='+obj.gui+ '(""define"");',errcatch=%t);
	  if ~ok then lasterror();end;
	  txt.concatd[sprintf('%s%s=%s(''define'');',w,temp,obj.gui)];
	  graphics = obj.graphics; ref_graphics = ref.graphics;
	  keys= graphics.__keys;
	  for i=1:size(keys,'*')
	    if ~or(keys(i)==ignore_tags) && ~graphics(keys(i)).equal[ref_graphics(keys(i))] then 
	      nname= sprintf('%s.graphics.%s',temp,keys(i));
	      txt.concatd[scicos_obj2api(graphics(keys(i)),name=nname,tag=tag+1, ...
					  indent=indent+1,export=export)];
	    end
	  end
	  model = obj.model;
	  for key=['in','out','in2','out2','outtyp','intyp'] do
	    nname= sprintf('%s.model.%s',temp,key);
	    txt.concatd[scicos_obj2api(model(key),name=nname,tag=tag+1, ...
				       indent=indent+1,export=export)];
	  end
	  // txt.concatd[sprintf('%s%s=%s;clear(''%s'');',w,name,temp,temp)];
	  if obj.gui == 'SUPER_f' then 
	    // we also need to copy the model 
	    model= obj.model; ref_model = ref.model;
	    keys= model.__keys;
	    for i=1:size(keys,'*')
	      if ~or(keys(i)==ignore_tags) && ~model(keys(i)).equal[ref_model(keys(i))] then 
		nname= sprintf('%s.model.%s',temp,keys(i));
		txt.concatd[scicos_obj2api(model(keys(i)),name=nname,tag=tag+1, ...
					   indent=indent+1,export=export)];
	      end
	    end
	  elseif obj.gui == 'CLOCK_f' || obj.gui == 'CLOCK_c'  then
	    // we need to keep the clock parameters which are
	    // stored in the model
	    path = b2m(obj.model.rpar.objs(1)==mlist('Deleted'))+2;
	    evtdly=obj.model.rpar.objs(path); // get the evtdly block
	    exprs= evtdly.graphics.exprs;
	    txt.concatd[sprintf('%sexprs=%s;',w,sci2exp(exprs))];
	    txt.concatd[sprintf('%s%s=set_block_exprs(%s,exprs);',w,temp,temp)];
	  elseif obj.model.iskey['rpar'] && type(obj.model.rpar,'short')== 'h' &&
	    obj.model.rpar.type == 'diagram' then
	    printf('Attention %s contient un super block if faut le gerer\n',obj.gui);
	  end
	  txt.concatd[sprintf('%s%s=%s;clear(''%s'');',w,name,temp,temp)];
	  return
	else 
	  // if typ is in H then use H value instead.
	  if H.iskey[obj.type] then typ=H(obj.type);end
	  if typ == 'scsopt' then typ = 'options'; obj.type='options'; end
	  fun=sprintf('scicos_%s',typ);
	  if exists(fun,'nsp-function') then
	    ok = execstr(sprintf('ref=scicos_%s()',typ),errcatch=%t);
	    if ~ok then lasterror();else isref=%t; end
	    txt.concatd[sprintf('%s%s=scicos_%s();',w,temp,typ)];
	  else
	    txt.concatd[sprintf('%s%s=hash(%d);',w,temp,length(obj))];
	  end
	  // if fun== 'scicos_options' then pause;end
	end
      else
	txt.concatd[sprintf('%s%s=hash(%d);',w,temp,length(obj))];
      end
      // we have to save each field except if isref is true and 
      // the field is already in ref with the same value 
      // moreover we can decide or not to save models (here we 
      // save models by changing 'models' to 'xxmodels'
      if typ<>'xxmodel' then 
	keys= obj.__keys;
	for i=1:size(keys,'*')
	  if ~or(keys(i)==ignore_tags) then 
	    if ~(isref && ref.iskey[keys(i)] && obj(keys(i)).equal[ref(keys(i))]) then 
	      if validvar(keys(i)) then 
		nname= sprintf('%s.%s',temp,keys(i));
	      else
		nname= sprintf('%s(''%s'')',temp,keys(i));
	      end
	      txt.concatd[scicos_obj2api(obj(keys(i)),name=nname,tag=tag+1, ...
					 indent=indent+1,export=export)];
	    end
	  end
	end
      end
      txt.concatd[sprintf('%s%s=%s;clear(''%s'');',w,name,temp,temp)];
     case 'l' then
      txt.concatd[sprintf('%s%s=list();',w,temp)];
      for i=1:size(obj)
	txt.concatd[scicos_obj2api(obj(i),name=temp+'('+string(i)+')',tag=tag+1,indent=indent+1,export=export)];
      end
      txt.concatd[sprintf('%s%s=%s;clear(''%s'');',w,name,temp,temp)];
    else
      txt1=sprint(obj,as_read=%t,name=name,indent=indent);txt1($)=txt1($)+ ';';
      txt.concatd[txt1];
    end
    // back to def value;
  endfunction;

  // main code 
  export = %t; // true for exporting to scicoslab 

  // need to purge diagram first since
  obj=do_purge(obj);
  //format("long");
  txt1=scicos_obj2api(obj,name=name,tag=tag,indent=indent,export=export);
  //format();
  // second path to remove extra \n
  txt2=m2s([]);
  i = 1;
  while i <= size(txt1,'*') then 
    str=txt1(i); 
    if part(str,length(str))=='=' then 
      i=i+1;str=str+txt1(i);
    end
    txt2.concatd[str];
    i=i+1;
  end
  
  // utilities needed for exporting to scicoslab 
  // 
  if export then 
    head=["if ~exists(''%nsp'') & ~exists(''scicos_diagram'') then load(''SCI/macros/scicos/lib'');end";
	  "needcompile=4";
	  "if ~exists(''%nsp'') then";
          " function opts=scicos_options()";
	  "  opts=tlist([''scsopt'',''Background'',''Link'',''ID'',''Cmap'',''D3'',''3D'',''Grid'',''Wgrid'',''Action'',''Snap'']);"
	  "  opts.Background=[8 1];"
	  "  opts.Link=[1,5];"
	  "  opts.ID= list([5 0],[4 0]);";
	  "  opts.Cmap=[0.8 0.8 0.8]";
	  "  opts.D3=list(%t,33);";
	  "  opts(''3D'')=list(%t,33);";
	  "  opts.Grid=%f;";
	  "  opts.Wgrid=[10;10;12];";
	  "  opts.Action=%f;";
	  "  opts.Snap=%t;";
	  " endfunction";
	  " function blk=scicos_text(varargopt)";
	  "  blk=mlist([''Text'', ''graphics'',''model'', ''gui''],scicos_graphics(),scicos_model(),'''');";
	  " endfunction";
	  "end"];
    txt=[head;txt2];
  else
    txt=txt2;
  end
endfunction 
  
