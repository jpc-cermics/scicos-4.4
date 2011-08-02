function scmenu_save_block_gui()
// Copyright INRIA
  Cmenu=''
  fname=do_save_block_gui(scs_m);
  if ~fname.equal[""] then
    Scicos_commands=['%diagram_path_objective=[];%scicos_navig=1';
		     'exec('+sci2exp(fname)+');%diagram_path_objective='+sci2exp(super_path)+';%scicos_navig=1'];
  end
endfunction

function fname=do_save_block_gui(scs_m,fdef)
// Copyright INRIA
  
  if nargin < 2 then fdef="";end 
  
  fname = "";
  
  if isempty(Select) || isempty(find(Select(:,2)==curwin)) then
    message('Make a selection first');
    return;
  end
  // K contains selected indices restricted to curwin 
  K=Select(find(Select(:,2)==curwin),1);
  if length(K)<> 1 then 
    message('Select only one block for save block gui !');
    return;
  end
  
  o = scs_m.objs(K);
  
  if %f && o.gui<>'DSUPER' then
    message('Only Masked blocks can be saved.')
    return;
  end
  
  if fdef<>"" then 
    fname = fdef;
  else
    tit = ["Use .sci extension because GUI is a Scilab function"];
    fname=xgetfile(masks=['Scilab';'*.sci'],title=tit,save=%t)
    if fname==emptystr() then
      return
    end
  end
    
  if file('extension',fname)<>'.sci' then
    fname = file('root',fname)+'.sci';
  end
  // block name
  bname = file('root',file('tail',fname));

  eok=execstr('F=fopen('''+ fname+''',mode = ''w'');',errcatch=%t);
  if ~eok then
    message([sprintf('Error: cannot open %s for writing\n',fname); ...
	     catenate(lasterror())]);
    fname="";
    return 
  end
  
  graphics=o.graphics;
  exprs0=graphics.exprs(2)(1);
  btitre=graphics.exprs(2)(2)(1);
  bitems=graphics.exprs(2)(2)(2:$);
  if isempty(exprs0) then 
    txtset='     x=arg1,return'
  else
    tt='scicos_context.'+exprs0(1);
    for i=2:size(exprs0,1)
      tt=tt+',scicos_context.'+exprs0(i),
    end
    ss=graphics.exprs(2)(3)

    txtset=[
	'  y=needcompile'
	'  typ=list()'
	'  graphics=arg1.graphics;'
	'  exprs=graphics.exprs'
	'  Btitre=...'
	'    '+sci2exp(btitre)
	'  Exprs0=...'
	'    '+sci2exp(exprs0)
	'  Bitems=...'
	'    '+sci2exp(bitems)
	'  ss='+sci2exp(ss)
	'  scicos_context=hash(10)'
	'  x=arg1'
	'  ok=%f'
	'  while ~ok do'
	'    [ok,'+tt+',exprs]=getvalue(Btitre,Bitems,ss,exprs)'
	'    if ~ok then return;end'
	'     %scicos_context=scicos_context'
	'     sblock=x.model.rpar'
	'     [%scicos_context,ierr]=script2var(sblock.props.context,%scicos_context)'
	'     if ierr<>0 then'
	'       message(catenate(lasterror()));'
	'       ok=%f';
	'     else';
	'       [sblock,%w,needcompile2,ok]=do_eval(sblock,list(),%scicos_contex);';
	'       if ok then'
	'          y=max(2,needcompile,needcompile2)'
	'          x.graphics.exprs=exprs'
	'          x.model.rpar=sblock'
	'          break'
	'       else'
	'         message(catenate(lasterror()));';
	'       end'
	'     end'
	'  end']
  end
    
  Date=gdate_new();
  str= Date.strftime["%d %B %Y"];
  
  txt=[sprintf('function [x,y,typ]=%s(job,arg1,arg2)',bname);
       sprintf('//Generated from %s on %s',o.model.rpar.props.title(1),str);
       '  x=[];y=[];typ=[];'
       '  select job'
       '   case ''plot'' then'
       '    standard_draw(arg1)'
       '   case ''getinputs'' then'
       '    [x,y,typ]=standard_inputs(arg1)'
       '   case ''getoutputs'' then'
       '    [x,y,typ]=standard_outputs(arg1)'
       '   case ''getorigin'' then'
       '    [x,y]=standard_origin(arg1)'
       '   case ''set'' then'
       txtset;
       '   case ''define'' then'];
  

  fprintf(F,"%s\n",txt);
  dimen=o.graphics.sz/20
  dimen=dimen(:)'

  textdef=['  //model=scicos_model()']
  model=o.model
  model.ipar=1;
  rpar=model.rpar
  rpar=scs_m_remove_gr(rpar)
  model.rpar=rpar
  fprint(F,model,as_read=%t,indent=3);
  exprs_txt='  exprs=['
  for i=1:size(exprs0,1)
    ierr=execstr('strtmp=sci2exp(evstr(exprs0(i)),0)',errcatch=%t)
    if ierr==%f then strtmp='[]',disp('Cannot evaluate '+exprs0(i)),return,end
    textdef=[textdef;
             '  '+exprs0(i)+'='+strtmp];
    if i==size(exprs0,1) then
      exprs_txt=exprs_txt+'sci2exp('+exprs0(i)+',0)'
    else
      exprs_txt=exprs_txt+'sci2exp('+exprs0(i)+',0);'
    end
  end
  exprs_txt=exprs_txt+']';
  textdef=[textdef;exprs_txt];
  gr_i_tmp = sci2exp(o.graphics.gr_i);
  textdef=[textdef;
           '  gr_i='+gr_i_tmp];
  textdef=[textdef;
	   sprintf('  x=standard_define(%s,model,exprs,gr_i,''%s'')',sci2exp(dimen),bname)];


  txt=[ textdef
	'  end'
	'endfunction']
  fprintf(F,"%s\n",txt);
  F.close[];
endfunction
