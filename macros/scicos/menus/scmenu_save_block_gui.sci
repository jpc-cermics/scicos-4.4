function scmenu_save_block_gui()
// Copyright INRIA
  if size(find(Select(:,2)==curwin),2)<>1 then
    message('Select one and only one block in the current window.')
    Cmenu=''
    return
  else
    if length(scs_m.objs)<Select(1) | scs_m.objs(Select(1)).type<>"Block" then
      Select=[]
      return
    else
      Cmenu=''
      if scs_m.objs(Select(1)).gui<>'DSUPER' then
        message('Only Masked blocks can be saved.')
      else
        fname=do_saveblockgui(scs_m.objs(Select(1)))
        if fname<>emptystr() then
          Scicos_commands=['%diagram_path_objective=[];%scicos_navig=1';
                           'exec('+sci2exp(fname)+');%diagram_path_objective='+sci2exp(super_path)+';%scicos_navig=1']
        end
      end
    end
  end
endfunction

function fname=do_saveblockgui(o)
// Copyright INRIA
  tit = ["Use .sci extension because GUI is a Scilab function"];
  // FIXME: 
  fname=xgetfile(masks=['Scilab';'*.sci'],title=tit,save=%t)
  if fname==emptystr() then
    return
  end

  [path,bname,ext] = splitfilepath_cos(fname)

  rep=execstr('F=fopen('''+ fname+''',mode = ''w'');',errcatch=%t);
  if rep==%f then
    message(path+': Directory or file write access denied')
    return
  end

  graphics=o.graphics
  exprs0=graphics.exprs(2)(1)
  btitre=graphics.exprs(2)(2)(1)
  bitems=graphics.exprs(2)(2)(2:$)
  if isempty(exprs0) then 
     txtset='x=arg1,return'
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
          '  Btitre=..'
          '    '+sci2exp(btitre)
          '  Exprs0=..'
          '    '+sci2exp(exprs0)
          '  Bitems=..'
          '    '+sci2exp(bitems)
          '    '+sci2exp(ss)
          '  scicos_context=struct()'
          '     x=arg1'
          '  ok=%f'
          '  while ~ok do'
          '    [ok,'+tt+',exprs]=getvalue(Btitre,Bitems,ss,exprs)'
          '    if ~ok then return;end'
          '     %scicos_context=scicos_context'
          '     sblock=x.model.rpar'
          '     [%scicos_context,ierr]=script2var(sblock.props.context,%scicos_context)'
          '     if ierr==0 then'
          '       [sblock,%w,needcompile2,ok]=do_eval(sblock,list(),%scicos_context)'
          '       if ok then'
          '          y=max(2,needcompile,needcompile2)'
          '          x.graphics.exprs=exprs'
          '          x.model.rpar=sblock'
          '          break'
          '       end'
          '     else'
          '       err=lasterror();'
          '       if err<>[] then message(err);end'
          '       ok=%f'
          '     end'
          '  end']
  end


  T=localtime()
  txt=['function [x,y,typ]='+bname+'(job,arg1,arg2)'
       '//Generated from '+o.model.rpar.props.title(1)+' on '+m2s(T.mday)+'/'+m2s(T.mon+1)+'/'+m2s(T.year+1900)
       'x=[];y=[];typ=[];'
       'select job'
       'case ''plot'' then'
       '  standard_draw(arg1)'
       'case ''getinputs'' then'
       '  [x,y,typ]=standard_inputs(arg1)'
       'case ''getoutputs'' then'
       '  [x,y,typ]=standard_outputs(arg1)'
       'case ''getorigin'' then'
       '  [x,y]=standard_origin(arg1)'
       'case ''set'' then'
       txtset
       'case ''define'' then']

  fprintf(F,"%s\n",txt);
  dimen=o.graphics.sz/20
  dimen=dimen(:)'

  textdef=['  //model=scicos_model()']
  model=o.model
  model.ipar=1;
  rpar=model.rpar
  rpar=scs_m_remove_gr(rpar)
  model.rpar=rpar
  fprint(F,model,as_read=%t);
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
           '  '+gr_i_tmp];
  textdef=[textdef;
              '  x=standard_define('+sci2exp(dimen)+',model,exprs,gr_i)']
  

  txt=[ textdef
       'end'
       'endfunction']

  fprintf(F,"%s\n",txt);
  F.close[];
endfunction
