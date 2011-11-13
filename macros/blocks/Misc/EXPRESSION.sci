function [x,y,typ]=EXPRESSION(job,arg1,arg2)
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
    model=arg1.model;graphics=arg1.graphics;
    exprs=graphics.exprs
    // expressions are stored in exprs with % and 
    // edited without the %
    for ii=1:8,
      cmd='exprs(2)=varnumsubst(exprs(2),'"%u'"+string(ii),'"u'"+string(ii))';
      execstr(cmd);
    end
    while %t do
      [ok,%nin,%exx,%usenz,exprs]=getvalue(...
	  ['Give a scalar expression using inputs u1, u2,...';
	   'If only one input, input is vector [u1,u2,...] (max 8)';
	   'ex: (dd*u1+sin(u2)>0)*u3';
	   'Note that here dd must be defined in context'],...
	  ['number of inputs';'scilab expression';'use zero-crossing (0: no, 1 yes)'],..
	  list('vec',1,'str',1,'vec',1),exprs)
      if ~ok then break,end
      if stripblanks(%exx)==emptystr() then %exx='0',end  //avoid empty expression
      if %nin==1 then 
	%nini=8,
      else
	%nini=%nin
      end
      // build the expression 
      ok=execstr('%bexp=scalexp_create(%exx)',errcatch=%t);
      if ~ok then
	message(['Erroneous expression';lasterror()]) 
	continue;
      end
      if %nin>1 then
	[model,graphics,ok]=check_io(model,graphics,ones_new(1,%nin),1,[],[]);
      else
	[model,graphics,ok]=check_io(model,graphics,-1,1,[], []);
      end
      if ~ok then 
	message(['Erroneous expression';lasterror()]) 
	continue;
      end
      // we need here to replace constants 
      // by their values i.e %pi,%e etc...
      // and to apply context.
      if exists('%scicos_context') then
	//printf('change expression with context\n");
	lc=%scicos_context;
      else
	lc=hash(5);
      end
      lc.enter[%pi=%pi,%e=%e]; // to be improved 
      lc.remove[ 'u'+string(1:8)];
      %bexp.apply_context[lc];
      // check that the expression is correct 
      vars = %bexp.get_vars[];
      if %nin > 1 then 
	exp_vars = 'u'+string(1:%nin)';
      else 
	exp_vars = 'u'+string(1:8)';
      end
      v_ok=%t;
      for i=1:size(vars,'*')
	if isempty(find(exp_vars==vars(i))) then 
	  message('uncorrect variables '+vars(i)+' in expression');
	  v_ok=%f;break;
	end
      end
      if ~v_ok then continue;end 
      // force all u to be present variables 
      %bexp.set_extra_names['u'+string(1:8)];
      %nz=%bexp.logicals[];
      %bexp.bcomp[];
      [ipar,rpar]=%bexp.get_bcode[];
      model.rpar=rpar
      model.ipar=ipar
      if %usenz then
	model.nzcross=%nz
	model.nmode=%nz
      else
	model.nzcross=0
	model.nmode=0
      end
      // back with %
      for ii=1:8
	execstr('exprs(2)=varnumsubst(exprs(2),'"u'"+string(ii),'"%u'"+string(ii))'),
      end
      graphics.exprs=exprs
      x.graphics=graphics
      x.model=model
      break
    end
   case 'define' then
    in=[1;1]
    out=1
    txt = '(u1>0)*sin(u2).^2'
    %bexp=scalexp_create(txt);
    nz=%bexp.logicals[];
    %bexp.bcomp[];
    [ipar,rpar]=%bexp.get_bcode[];
    model=scicos_model()
    model.sim=list('evaluate_expr',4)
    model.in=in
    model.out=out
    model.rpar=rpar
    model.ipar=ipar
    model.nzcross=nz
    model.nmode=nz
    model.dep_ut=[%t %f]
    // keep variables with % in exprs 
    for ii=1:8
      execstr('txt=varnumsubst(txt,'"u'"+string(ii),'"%u'"+string(ii))'),
    end
    exprs=[string(size(in,'*'));txt;'1']
    gr_i=['xstringb(orig(1),orig(2),[''Mathematical'';''Expression''],sz(1),sz(2),''fill'');']
    x=standard_define([3 2],model,exprs,gr_i,'EXPRESSION');
  end
endfunction




