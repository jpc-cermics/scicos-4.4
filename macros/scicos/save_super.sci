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
  scs_m=do_purge(scs_m)
  nam=scs_m.props.title(1);
  nam=strsubst(nam,' ','_')
  in=[];out=[];clkin=[];clkout=[];

  for k=1:length(scs_m.objs)
    o=scs_m.objs(k)
    if typeof(o)=='Block' then
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
  txt=scicos_scs2str(model,name='model',indent=4);
  F.put_smatrix[txt];
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


function txt=scicos_scs2str(obj,name='z',tag=0,indent=0)
  
  H=hash(3, codegeneration='codegen',Block='block',Link='link',Text='text');
  txt = m2s([]);
  typ = type(obj,'short');
  w=catenate(smat_create(indent,1,' '));
  temp='x_'+string(tag);
  select typ 
   case 'h' then 
    if obj.iskey['type'] then 
      typ=obj.type;
      if H.iskey[obj.type] then typ=H(obj.type);end
      txt.concatd[sprintf('%s%s=scicos_%s();',w,temp,typ)];
    else
      txt.concatd[sprintf('%s%s=hash(%d);',w,temp,length(obj))];
    end
    keys= obj.__keys;
    keys=setdiff(keys,['type','tlist','mlist']);
    for i=1:size(keys,'*')
      nname= sprintf('%s(''%s'')',temp,keys(i));
      txt.concatd[scicos_scs2str(obj(keys(i)),name=nname,tag=tag+1,indent=indent+1)];
    end
    txt.concatd[sprintf('%s%s=%s;clear(''%s'');',w,name,temp,temp)];
   case 'l' then
    txt.concatd[sprintf('%s%s=list();',w,temp)];
    for i=1:size(obj)
      txt.concatd[scicos_scs2str(obj(i),name=temp+'('+string(i)+')',tag=tag+1,indent=indent+1)];
    end
    txt.concatd[sprintf('%s%s=%s;clear(''%s'');',w,name,temp,temp)];
  else
    txt.concatd[sprint(obj,as_read=%t,name=name,indent=indent)];
  end
endfunction;

