function scmenu_eval()
// Copyright INRIA
  if ~super_block then
    // not super block 
    Cmenu='';
    do_terminate();
    [scs_m,%cpr,needcompile,ok]=do_eval(scs_m,%cpr);
    if ok then 
      Cmenu='Replot';
      if needcompile<>4 && size(%cpr)>0 then %state0=%cpr.state,end
      alreadyran=%f;
    end
  else
    // go to toplevel to perform evaluation.
    Scicos_commands=['%diagram_path_objective=[];%scicos_navig=1';
		     'Cmenu='"Eval'";%scicos_navig=[]';
		     '%diagram_path_objective='+sci2exp(super_path)+';%scicos_navig=1']
  end
endfunction

function [scs_m,cpr,needcompile,ok]=do_eval(scs_m,cpr,context,flag)
// This function (re)-evaluates blocks in the scicos data structure scs_m 
// Copyright INRIA
// Last Updated 14 Jan 2009 Fady NASSIF

  function scicos_check_params(title,equations,equations_n)
    if isempty(equations.parameters) then return;end
    if isempty(equations_n.parameters) then return;end
    if model.equations.parameters.equal[model_n.equations.parameters] then
      return;
    end
    // equations.parameters should be: list(<string-mat>,list(val1,...valn)) 
    // but it can also be empty.
    if ~equations.parameters(1).equal[equations_n.parameters(1)] then 
      // name of parameters differ 
      resume(needcompile1=4);
    end
    if equations.parameters(2).equal[equations_n.parameters(2)] then 
      // list of values differ 
      resume(needcompile=0);
      XML=file('join',[TMPDIR;stripblanks(scs_m.props.title(1))+'_imf_init.xml']);
      XMLTMP=file('join',[TMPDIR;stripblanks(scs_m.props.title(1))+'_imSim.xml']);
      file('delete',XML);
      file('delete',XMLTMP);
    end
  endfunction

  function [scs_m,cpr,needcompile,ok,msg]=do_eval_rec(scs_m,cpr,context,flag)
  // This function (re)-evaluates blocks in the scicos data structure
  // scs_m. The evaluation is made in a non-interactive way.
  // Copyright INRIA

    needcompile = acquire('needcompile',def=0);
    msg=m2s([]);

    // to detect that message was activated
    global %scicos_prob;     // detect pbs in non interactive block evaluation
    global %scicos_setvalue; // detect loop in non interactive block evaluation

    // enrich context with scs_m.props.context 
    [context,ierr]=script2var(scs_m.props.context,context);
    if ierr<>0 then 
      msg=["Failed to evaluate a context:";catenate(lasterror())];
      ok=%f;
      return;
    end
    // getvalue will use %scicos_context
    %scicos_context=context;
    
    ok=%t
    needcompile1=max(2,needcompile)
    
    for %kk=1:length(scs_m.objs)
      o=scs_m.objs(%kk)
      if o.type =='Block' || o.type =='Text' then
	if o.gui<>'PAL_f' then
	  // 
	  rpar=o.model.rpar;
	  if flag.equal['XML'] then
	    graphics=o.graphics;
	    sim=o.model.sim;
	    %scicos_prob=%f
	    eok=execstr('o=' + o.gui + '(""define"",o);',errcatch=%t);
	    if ~eok || %scicos_prob then
	      [ok,msg]=do_eval_report('Error: while defining a block:',o.gui);
	      return
	    end
	    //update model compatibility with old csuper blocks
	    if length(o.model)<length(scicos_model()) then
	      o.model=update_model(o.model);
	    end
	    o.graphics=graphics;
	  end
	  model=o.model
	  if (model.sim(1)=='super' ..
	      | (model.sim(1)=='csuper'& ~model.ipar.equal[1]) ..
	      | (model.sim(1)=='asuper'& flag.equal['XML']) ..
	      | (o.gui == 'DSUPER' & flag.equal['XML'])) then  //exclude mask
	    sblock=rpar;
	    [scicos_context1,ierr]=script2var(sblock.props.context,context)
	    if ierr<>0 then
	      [ok,msg]=do_eval_report('Error: cannot evaluate a context:','');
	      return
	    else
	      [sblock,%w,needcompile2,ok,msg]=do_eval_rec(sblock,list(),scicos_context1,flag)
	      needcompile1=max(needcompile1,needcompile2)
	      if ok then
		o.model.rpar=sblock
		if flag.equal['XML'] then
		  if sim(1)=="asuper" then
		    o.model.sim=sim;
		  end
		  o.model.in=-1*ones(size(graphics.pin,'*'),1);
		  o.model.in2=-2*ones(size(graphics.pin,'*'),1);
		  o.model.intyp=-1*ones(1,size(graphics.pin,'*'));
		  o.model.out=-1*ones(size(graphics.pout,'*'),1);
		  o.model.out2=-2*ones(size(graphics.pout,'*'),1);
		  o.model.outtyp=-1*ones(1,size(graphics.pout,'*'));
		  o.model.evtin=ones(size(graphics.pein,'*'),1);
		  o.model.evtout=ones(size(graphics.peout,'*'),1);
		end
	      else
		[ok,msg]=do_eval_report(msg,'');
		return
	      end
	    end
	  elseif o.model.sim(1)=='asuper' then
	    if o.model.sim.equal['asuper'] then // code not yet generated
	      sblock=rpar
	      //deff('hilite_obj(a,b,c,d,e,f,g,h)','')
	      //deff('unhilite_obj(a,b,c,d,e,f,g,h)','')
	      [sblock,%w,needcompile2,ok]=do_eval(sblock,list(),hash(10),%t,flag)
	      if ok then
		o.model.rpar=sblock
		scs_m1=scs_m;
		scs_m1.objs(%kk)=o;
		[o,needcompile2,ok]=do_create_atomic(o,%kk,scs_m1)
	      else
		error('Compiling atomic super block fails.')
	      end
	      needcompile1=4
	    else
	      //nothing
	    end	
	    // 
	  else
	    //should we generate a message here?
	    %scicos_prob=%f;
	    %scicos_setvalue=[];
	    eok=execstr('o=' +o.gui+ '(''set'',o)',errcatch=%t);
	    if ~eok || %scicos_prob  then
	      [ok,msg]=do_eval_report('Operation set failed for: ',o.gui);
	      return
	    end
	    if ~flag.equal['XML'] then
	      needcompile1=max(needcompile1,needcompile) // for scifunc_block
	      model_n=o.model
	      if or(model.blocktype<>model_n.blocktype)|.. // type 'c','d','z','l'
		    or(model.dep_ut<>model_n.dep_ut)|..
		    (model.nzcross<>model_n.nzcross)|..
		    (model.nmode<>model_n.nmode) then
		needcompile1=4
	      end
	      if (size(model.in,'*')<>size(model_n.in,'*'))|..
		    (size(model.out,'*')<>size(model_n.out,'*'))|..
		    (size(model.evtin,'*')<>size(model_n.evtin,'*')) then
		//  number of input (evt or regular ) or output  changed
		needcompile1=4
	      end
	      if model.sim.equal['input'] |model.sim.equal['output'] then
		if model.ipar<>model_n.ipar then
		  needcompile1=4
		end
	      end
	      itisanMBLOCK=%f
	      if prod(size(model.sim))>1 then
		if (model.sim(2)==30004) then 
		  itisanMBLOCK=%t
		end
	      end
	      if (prod(size(model.sim))==1 && type(model.equations,'short')=='h') |...
		    itisanMBLOCK then
		scicos_check_params(scs_m.props.title(1),model.equations,model_n.equations);
	      end
	    end
	  end
	  if flag.equal['XML'] then
	    o.graphics=graphics;
	  end
	end
      end
      scs_m.objs(%kk)=o;
    end
    needcompile=needcompile1
    if needcompile==4 then cpr=list(),end
  endfunction
  
  function message(txt)
    if exists('o') then 
      txt = ["Error: in evaluation of block "+o.gui+": ";txt];
    end
    x_message_modeless(txt);
    resume(%scicos_prob=%t); 
  endfunction
  
  function [ok,tt]=FORTR(funam,tt,i,o) ; ok=%t; endfunction
  function [ok,tt,cancel]=CFORTR2(funam,tt,i,o); ok=%t;cancel=%f; endfunction
  function [ok,tt]=CFORTR(funam,tt,i,o); ok=%t; endfunction
  function [x,y,ok,gc]=edit_curv(x,y,job,tit,gc); ok=%t; endfunction
  function [ok,tt,dep_ut]=genfunc1(tt,ni,no,nci,nco,nx,nz,nrp,type_)
    dep_ut=model.dep_ut;ok=%t; 
  endfunction
  function [ok,tt,cancel,libss,cflags]=CC4(funam,tt,i,o,libss,cflags)
    ok=%t,cancel=%f;tt=tt;
    libss=libss;cflags=cflags;
  endfunction
  
  function result= dialog(labels,valueini); result=valueini;endfunction
  function [result,Quit]  = scstxtedit(valueini,v2);result=valueini,Quit=%f;endfunction
  function [ok,msg]=do_eval_report(message,name)
  // change the error message and propagate the message;
    msg=lasterror();
    if ~isempty(msg) && msg(1)=="Loop in setvalue\n" then 
      // message to indicate that we have aborted an infinite loop
      // in set operation of a block.
      msg=[sprintf("Error: parameters for block %s\n",name);
	 'are inconsistent and should be edited manually'];
    end
    if ~message.equal[''] then msg=[message+string(name);msg];end 
    ok=%f;
  endfunction
  
  // main code 
  // ----------
  needcompile = acquire('needcompile',def=0);
  
  if nargin < 2 then cpr=list(); end
  if nargin < 3 then context=hash(10);end
  if nargin < 4 then flag='NONXML';end
  
  // window 0 existed 
  %win0_exists=or(winsid()==0)
  // overload some functions used in GUI
  getvalue=setvalue;
  getvalue_list=setvalue_list;
  
  [scs_m,cpr,needcompile,ok,msg]=do_eval_rec(scs_m,cpr,context,flag);
  if ~ok && ~isempty(msg) then x_message(catenate(msg));end
  if needcompile==4 then cpr=list(),end
  if ~%win0_exists then xdel(0);end
endfunction

function [scs_m,ok]=do_silent_eval(scs_m, context)
  // Simplified version of do_eval which evaluates scs_m 
  // without messages and without stopping at errors.
  // This function is mainly used when importing. 
  // This function uses %scicos_context if it exists
  // and an extra context can  be given as a hash table in argument context.
  
  function [scs_m,ok]=do_silent_eval_rec(scs_m,context)
  // This function (re)-evaluates blocks in the scicos data structure
  // scs_m. The evaluation is made in a non-interactive way.
    msg=m2s([]);
    // to detect that message was activated
    global %scicos_prob;     // detect pbs in non interactive block evaluation
    global %scicos_setvalue; // detect loop in non interactive block evaluation
    
    // enrich context with scs_m.props.context 
    [context,ierr]=script2var(scs_m.props.context,context);
    // getvalue will use %scicos_context
    %scicos_context=context;
    ok=%t
        
    for %kk=1:length(scs_m.objs)
      o=scs_m.objs(%kk)
      if (o.type =='Block' || o.type =='Text') && o.gui<>'PAL_f' then
	if o.gui == 'SUPER_f' then
	  // internal diagram
	  sblock=o.model.rpar;
	  [scicos_context1,ierr]=script2var(sblock.props.context,context)
	  [sblock,lok]=do_silent_eval_rec(sblock,scicos_context1)
	  o.model.rpar=sblock;
	elseif or(o.model.sim(1)==['super','csuper','asuper']) || o.gui == 'DSUPER' then
	  // evaluate block
	  %scicos_prob=%f;
	  %scicos_setvalue=[];
	  eok=execstr('o='+o.gui+'(''set'',o)',errcatch=%t);
	  if ~eok || %scicos_prob  then ok=%f; continue; end
	  // internal diagram
	  if or(o.model.sim(1)==['super']) then 
	    // XXX check if this is requested for super ?
	    sblock=o.model.rpar;
	    [scicos_context1,ierr]=script2var(sblock.props.context,context)
	    [sblock,lok]=do_silent_eval_rec(sblock,scicos_context1)
	    o.model.rpar=sblock;
	  end
	else
	  // evaluate the block 
	  %scicos_prob=%f;
	  %scicos_setvalue=[];
	  eok=execstr('o='+o.gui+'(''set'',o)',errcatch=%t);
	  if ~eok || %scicos_prob  then ok=%f; continue; end
	end
	scs_m.objs(%kk)=o;
      end
    end
  endfunction
    
  function message(txt)
    resume(%scicos_prob=%t);
  endfunction
  
  function [ok,tt]=FORTR(funam,tt,i,o) ; ok=%t; endfunction
  function [ok,tt,cancel]=CFORTR2(funam,tt,i,o); ok=%t;cancel=%f; endfunction
  function [ok,tt]=CFORTR(funam,tt,i,o); ok=%t; endfunction
  function [x,y,ok,gc]=edit_curv(x,y,job,tit,gc); ok=%t; endfunction
  function [ok,tt,dep_ut]=genfunc1(tt,ni,no,nci,nco,nx,nz,nrp,type_)
    dep_ut=model.dep_ut;ok=%t; 
  endfunction
  function [ok,tt,cancel,libss,cflags]=CC4(funam,tt,i,o,libss,cflags)
    ok=%t,cancel=%f;tt=tt;
    libss=libss;cflags=cflags;
  endfunction
  
  function result= dialog(labels,valueini); result=valueini;endfunction
  function [result,Quit]  = scstxtedit(valueini,v2);result=valueini,Quit=%f;endfunction
  function [ok,msg]=do_eval_report(message,name)
  // change the error message and propagate the message;
    msg=lasterror();
    if ~isempty(msg) && msg(1)=="Loop in setvalue\n" then 
      // message to indicate that we have aborted an infinite loop
      // in set operation of a block.
      msg=[sprintf("Error: parameters for block %s\n",name);
	 'are inconsistent and should be edited manually'];
    end
    if ~message.equal[''] then msg=[message;msg];end 
    ok=%f;
  endfunction
  
  // main code 
  // ----------
  // window 0 existed 
  %win0_exists=or(winsid()==0)
  // overload some functions used in GUI
  getvalue=setvalue;
  getvalue_list=setvalue_list;
  
  if nargin < 2 then context=hash(10);end
  [scs_m,ok]=do_silent_eval_rec(scs_m,context)
  if ~%win0_exists then xdel(0);end
endfunction

function [blk,ok]=do_silent_eval_block(blk, context)
  // do_silent_eval for a unique block
  if nargin < 2 then context=hash(10);end
  scs_m = scicos_diagram();
  scs_m.objs(1)=blk;
  [scs_m,ok]=do_silent_eval(scs_m,context);
  blk =  scs_m.objs(1);
endfunction
