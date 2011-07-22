function Eval_()
// Copyright INRIA
  if ~super_block then
    // not super block 
    Cmenu='Replot'
    %now_win=xget('window')
    if ~exists('%scicos_context') then 
      %scicos_context=hash_create(0);
    end
    [%scicos_context,ierr]=script2var(scs_m.props.context,%scicos_context)
    //for backward compatibility for scifunc
    if ierr==0 then
      // FIXME: this part should not be necessary in nsp because 
      // evaluation is done using %scicos_context as context 
      // when necessary 
      // If necessary: there is an easier way to make the same in nsp
      // with insert_env(%scicos_context)
      //%mm=getfield(1,%scicos_context)
      //for %mi=%mm(3:$)
      //eok=execstr(%mi+'=%scicos_context(%mi)',errcatch=%t)
      //if ~eok then ierr=1;break;end 
      //end
    end
    //end of for backward compatibility for scifunc
    xset('window',%now_win)
    if ierr==0 then 
      do_terminate()
      [scs_m,%cpr,needcompile,ok]=do_eval(scs_m,%cpr,%scicos_context)
      if needcompile<>4&size(%cpr)>0 then %state0=%cpr.state,end
      alreadyran=%f
    else
      message(['Incorrect context definition, ';lasterror()] )
    end
  else
    // super_block 
    Scicos_commands=['%diagram_path_objective=[];%scicos_navig=1';
		       'Cmenu='"Eval'";%scicos_navig=[]';
		       '%diagram_path_objective='+sci2exp(super_path)+';%scicos_navig=1']
  end
endfunction

function [scs_m,cpr,needcompile,ok]=do_eval(scs_m,cpr,%scicos_context,%SubSystemEval,flag)
// This function (re)-evaluates blocks in the scicos data structure scs_m 
// Copyright INRIA
// Last Updated 14 Jan 2009 Fady NASSIF

  global %err_mess_eval
  if nargin < 2 then cpr=list(); end
  if ~exists('%scicos_context') then 
    %scicos_context=hash_create(0);
  end
  [%scicos_context,ierr]=script2var(scs_m.props.context,%scicos_context);
  if nargin < 4  && ~exists('%SubSystemEval') then
    %SubSystemEval=%f;
  end
  if ~%SubSystemEval then
    %win0_exists=or(winsid()==0)
  end
  if nargin < 5 then flag='NONXML';end
  ok=%t
  needcompile1=max(2,needcompile)
  //%mprt=funcprot()
  //funcprot(0) 
  getvalue=setvalue;
  
  function message(txt)
    x_message('In block '+o.gui+': '+txt);
    resume(%scicos_prob=%t); 
  endfunction

  global %scicos_prob
  %scicos_prob=%f

  // overload some functions used in GUI

  function [ok,tt]=FORTR(funam,tt,i,o) ; ok=%t; endfunction
  function [ok,tt,cancel]=CFORTR2(funam,tt,i,o); ok=%t;cancel=%f; endfunction
  function [ok,tt]=CFORTR(funam,tt,i,o); ok=%t; endfunction
  function [x,y,ok,gc]=edit_curv(x,y,job,tit,gc); ok=%t; endfunction
  function [ok,tt,dep_ut]=genfunc1(tt,ni,no,nci,nco,nx,nz,nrp,type_)
    dep_ut=model.dep_ut;ok=%t; 
  endfunction
  function [ok,tt,cancel,libss,cflags]=CC4(funam,tt,i,o,libss,cflags)
    ok=%t,cancel=%f;
  endfunction
  function result= dialog(labels,valueini); result=valueini;endfunction
  function [result,Quit]  = scstxtedit(valueini,v2);result=valueini,Quit=0;endfunction
  function [ok,tt]=MODCOM(funam,tt,vinp,vout,vparam,vparamv,vpprop)
    ok = %t;
    nameF=file('root',file('tail',funam));
    extF =file('extension',funam);
    if extF=='' then 
      funam1=file('join',[getenv('NSP_TMPDIR');'Modelica';nameF+'.mo']);
      scicos_mputl(tt,funam1);
    elseif ~file('exists',funam) then
      funam1=funam;
      scicos_mputl(tt,funam1);
    end
  endfunction
  
  %nx=length(scs_m.objs)
  // funcprot(%mprt)
  for %kk=1:%nx
    o=scs_m.objs(%kk)
    if o.type =='Block' || o.type =='Text' then
      if o.gui<>'PAL_f' then
	rpar=o.model.rpar;
	if flag=='XML' then
	  graphics=o.graphics;
	  sim=o.model.sim;
	  eok=execstr('o='+o.gui+'(""define"",o);',errcatch=%t);
	  if ~eok then
	    ok=%f;
	    if ~%SubSystemEval then
	      if ~isempty(%err_mess_eval) then x_message(%err_mess_eval);end
	      clearglobal %err_mess_eval;
	      open_win=winsid();// to close the opened windows number 0 
	      k=find(open_win==0); // it is openend when evaluating blocks as affiche.
	      xdel(open_win(k));
	    end
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
	    | (model.sim(1)=='asuper'& flag=='XML') ..
	    | (o.gui == 'DSUPER' & flag == 'XML')) then  //exclude mask
	  sblock=rpar
	  context=sblock.props.context
	  [scicos_context1,ierr]=script2var(context,%scicos_context)
	  if ierr <>0 then
	    %now_win=xget('window')
	    %err_mess_eval=[%err_mess_eval;'Cannot evaluate a context: '+lasterror()]
	    xset('window',%now_win)
	  else
	    [sblock,%w,needcompile2,ok]=do_eval(sblock,list(),scicos_context1,%t,flag)
	    needcompile1=max(needcompile1,needcompile2)
	    if ok then
	      o.model.rpar=sblock
	      if flag=='XML' then
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
	      if flag=='XML' then // when opening the xml return in case of error else do nothing
		if ~%SubSystemEval then 
		  if ~isempty(%err_mess_eval) then x_message(%err_mess_eval);end
		  clearglobal %err_mess_eval;
		  open_win=winsid();// to close the opened windows number 0 
		  k=find(open_win==0); // it is openend when evaluating blocks as affiche.
		  xdel(open_win(k));
		end
		ok=%f;return
	      end
	    end
	  end
	elseif o.model.sim(1)=='asuper' then
	else
	  //should we generate a message here?
	  %scicos_prob=%f
	  %SB=%SubSystemEval;
	  if o.model.sim(1)=='csuper' then %SubSystemEval=%t;end // compatibility
	  eok=execstr('o='+o.gui+'(''set'',o)',errcatch=%t);
	  %SubSystemEval=%SB;
	  if eok & %scicos_prob==%f then
	    if flag <>'XML' then
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
		if ~model.equations.parameters.equal[model_n.equations.parameters] then
		  param_name   = model.equations.parameters(1);
		  param_name_n = model_n.equations.parameters(1);
		  if ~param_name.equal[param_name_n] then
		    needcompile1=4
		  else
		    for i=1:length(model.equations.parameters(2))
		      if or((model.equations.parameters(2)(i))<>(model_n.equations.parameters(2)(i))) then
			needcompile=0
			XML=file('join',[TMPDIR;stripblanks(scs_m.props.title(1))+'_imf_init.xml']);
			//XML=pathconvert(XML,%f,%t);    
			XMLTMP=file('join',[TMPDIR;stripblanks(scs_m.props.title(1))+'_imSim.xml']);
			//XMLTMP=pathconvert(XMLTMP,%f,%t);
			if MSDOS then 
			  cmnd='del /F '+XML+' '+XMLTMP;
			else
			  cmnd='rm -f '+XML+' '+XMLTMP
			end
			if ~execstr('system(cmnd)',errcatch=%t) then
			  %err_mess_eval=[%err_mess_eval;'Unable to delete the XML file'];
			end
			break;
		      end
		    end
		  end
		end
	      end
	    end
	  else
	    if flag=='XML' then ok=%f;return;end
	  end
	end
	if flag=='XML' then
	  o.graphics=graphics;
	end
      end
    end
    scs_m.objs(%kk)=o;
  end
  needcompile=needcompile1
  if needcompile==4 then cpr=list(),end
  if ~%SubSystemEval then
    if ~isempty(%err_mess_eval) then x_message(%err_mess_eval);ok=%f;end
    clearglobal %err_mess_eval;
    if exists('%win0_exists') &(~%win0_exists) then
      open_win=winsid();// to close the opened windows number 0 
      k=find(open_win==0); // it is openend when evaluating blocks as affiche.
      xdel(open_win(k));
    end
  end
endfunction

