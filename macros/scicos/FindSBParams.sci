function [ok,params,param_types]=FindSBParams(scs_m,params)
  // Copyright INRIA
  
  function [params,ok]=GetLitParam(str,flg)
    // get variable names contained in str 
    // flg is set to %t when the function is called 
    // by FindSBParams
    // 
    if nargin <= 1 then flg=%f;end
    ok=%t;
    // we search here the parameters called in function 
    execstr(['function get_lit_param();';str(:);'endfunction']);
    xx=macrovar(get_lit_param);
    params=xx.lhs;
    if flg then
      // check that we are not using exec or load 
      excl= ['exec','load'];
      tag = xx.funs.iskey[excl];
      if or(tag) then 
	I=find(tag);
	mes = excl(I(1));
	message(['The context of a masked or atomic subsystem';
		 'cannot contains the function ""'+mes+'""']);
	ok = %f;
	return;
      end
    end
    // delete from params symbols starting with %
    p = params.__keys;
    pos=strstr(p,'%')
    ex = p(find(pos == 1))
    params.delete[ex];
    params = params.__keys;
  endfunction

  // main program 
  
  if nargin <= 1 then params=[];end 

  function [ok,%1,%2,%3,%4,%5,%6,%7,%8,%9,%10,%11,%12,%13,%14,%15,%16,%17,%18,%19,%20]=...
	   getvalue_loc(%desc,%labels,%typ,%ini)
    // getvalue is limited with respect to the number of outputs
    // use getvalue_list instead
    function L=xfun(desc,list,flag) L=x_choices(desc,list,flag);endfunction
    [ok,%L,%L2]= getvalue_internal_list(%desc,%labels,%typ,%ini,use_dialog=%f);
    str = '['+ catenate('%'+m2s(1:length(%L))',sep=',')+']';
    for i=1:length(%L) do execstr( '%'+m2s(i,"%.0f")+ '=%L(i)'); end
    i =length(%L)+1; execstr( '%'+m2s(i,"%.0f")+ '=%L2;');
    if nargout > length(%L)+2 then
      for i=length(%L)+2:nargout-1 do execstr( '%'+m2s(i,"%.0f")+ '=[];'); end
    end
    global par_types
    par_types=%typ;
  endfunction

  function [ok,L,exprs]=getvalue_loc_list(%desc,%labels,%typ,%ini)
    function L=xfun(desc,list,flag) L=x_choices(desc,list,flag);endfunction
    [ok,L,exprs] = getvalue_internal_list(%desc,%labels,%typ,%ini,use_dialog=%f);
    global par_types
    par_types=%typ;
  endfunction
  
  getvalue=getvalue_loc
  getvalue_list=getvalue_loc_list
  
  param_types=list()
  global par_types
  ok = %t;
  
  // enrich %scicos_context with diagram context 
  Fun=scs_m.props.context;
  [%scicos_context,ierr] = script2var(Fun);
  if ierr<>0 then
    message(["Error: context evaluation failed:\n";
	     catenate(lasterror())])
    ok=%f;
    return;
  end
  for i=1:size(scs_m.objs)
    o=scs_m.objs(i);
    if o.type =='Block' then
      if o.gui== 'PAL_f' then 
	// Ignore the PAL_f blocks 
	continue;
      end
      model=o.model;
      if model.sim.equal['super'] || ( model.sim.equal['csuper'] & (model.ipar<>1)) ||
	model.sim(1)=='asuper' then
	[ok1,pparams]=FindSBParams(model.rpar,params);
	if ok1 then Funi='['+pparams+']';end
      else
	if type(o.graphics.exprs,'short')=='h' && o.graphics.exprs.type =="MBLOCK" then 
	  //modelica block
	  Funi=[];
	  for j=1:length(o.graphics.exprs.paramv)
	    Funi=[Funi;
		  "["+o.graphics.exprs.paramv(j)+"]"];
	  end
	else
	  if type(o.graphics.exprs,"short")=="l" then
	    Funi="["+o.graphics.exprs(1)(:)+"]";
	  elseif type(o.graphics.exprs,"short")=="s" then 
	    Funi="["+o.graphics.exprs(:)+"]";
	  else
	    Funi=m2s([]);
	  end
	  par_types=[];
	  // ok = execstr("blk="+o.gui+"(""define"")",errcatch=%t);
	  // this call will fail because getvalue 
	  // do not set varargout. but par_types 
	  // will contain what we need.
	  ok=execstr(o.gui+"(""set"",o)",errcatch=%t);
	  lasterror(); // do not care about message 
	  Del=[];kk=1;
	  for jj=1:2:length(par_types)
	    if par_types(jj)=="str" then Del=[Del,kk]; end;
	    kk=kk+1
	  end
	  if ~isempty(Del) then Funi(Del)=[]; end;
	end
      end
      Fun=[Fun;Funi]
    end
  end
  // Now we have in Fun a string matrix which 
  // contains expressions.
  [params,ok]=GetLitParam(Fun,%t)
  if ~ok then return;end
  for pp=params'
    ok=execstr("typ=type(%scicos_context."+pp+",""short"")")
    select typ 
      case {"m","i"} 
	param_types($+1)="mat"
	param_types($+1)=-1
      case {"p"}
	param_types($+1)="pol"
	param_types($+1)=-1
      case {"h","l"}
	param_types($+1)="lis"
	param_types($+1)=-1
      else
	param_types($+1)="gen"
	param_types($+1)=-1
    end
  end
endfunction

