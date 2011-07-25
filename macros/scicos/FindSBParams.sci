function [ok,params,param_types]=FindSBParams(scs_m,params)
// Copyright INRIA

  if nargin <= 1 then params=[];end 
    
  function varargout=getvalue(a,b,c,d)
    global par_types
    par_types=c
  endfunction
  
  param_types=list()
  global par_types
  ok = %t;
  
  // enrich %scicos_context with diagram context 
  Fun=scs_m.props.context;
  if exists('%scicos_context','callers') then 
    [%scicos_context,ierr] = script2var(Fun,%scicos_context);
  else
    [%scicos_context,ierr] = script2var(Fun);
  end
  if ierr<>0 then
    message(['Error: context evaluation failed:\n";
	     catenate(lasterror())])
    ok=%f;
  end
  for i=1:size(scs_m.objs)
    o=scs_m.objs(i);
    if o.type =='Block' then
      if o.gui <> 'PAL_f' then
        model=o.model;
        if model.sim.equal['super'] | ...
	      ( model.sim.equal['csuper'] & (model.ipar<>1)) | ...
	      model.sim(1)=='asuper' then
	  [ok,pparams]=FindSBParams(model.rpar,params);
	  if ~ok then return;end
          Funi='['+pparams+']'
        else
          if type(o.graphics.exprs,'short')=='h' && o.graphics.exprs.type =="MBLOCK" then 
	    //modelica block
            Funi=[];
            for j=1:length(o.graphics.exprs.paramv)
               Funi=[Funi;
                     '['+o.graphics.exprs.paramv(j)+']'];
            end
          else
            if type(o.graphics.exprs,'short')=='l' then
              Funi='['+o.graphics.exprs(1)(:)+']';
            elseif type(o.graphics.exprs,'short')=='s' then 
              Funi='['+o.graphics.exprs(:)+']';
	    else
	      Funi=m2s([]);
            end
            par_types=[];
            execstr('blk='+o.gui+'(''define'')')
	    // this call will fail because getvalue 
	    // do not set varargout. but par_types 
	    // will contain what we need.
	    ok=execstr(o.gui+'(''set'',blk)',errcatch=%t)
	    lasterror(); // do not care about message 
	    Del=[];kk=1;
            for jj=1:2:length(par_types)
              if par_types(jj)=='str' then Del=[Del,kk],end
              kk=kk+1
            end
            Funi(Del)=[]
          end
        end
        Fun=[Fun;Funi]
      end
    end
  end
  //   
  [params,ok]=GetLitParam(Fun,%t)
  if ~ok then return;end
  for X=params'
    select evstr('type(%scicos_context.'+X+')')
    case 1
      param_types($+1)='pol'
      param_types($+1)=-1
    case 2
      param_types($+1)='pol'
      param_types($+1)=-1
    case 8
      param_types($+1)='mat'
      param_types($+1)=[-1,-1]
    case 15
      param_types($+1)='lis'
      param_types($+1)=-1
    case 16
      param_types($+1)='lis'
      param_types($+1)=-1
    case 17
      param_types($+1)='lis'
      param_types($+1)=-1
    else
      param_types($+1)='gen'
      param_types($+1)=-1
    end
  end
//  clearglobal('par_types')  //recursive call, so it cannot be cleared here
endfunction

