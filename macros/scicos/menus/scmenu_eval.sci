function Eval_()
  Cmenu='Open/Set'
  disablemenus()
  %now_win=xget('window')
  // evaluate the context 
  if ~exists('%scicos_context') then 
    %scicos_context=hash_create(0);
  end
  [ok,H1]=execstr(scs_m.props.context,env=%scicos_context,errcatch=%t);
  xset('window',%now_win);
  
  if ok then 
    %scicos_context = H1;
    do_terminate();
    [scs_m,%cpr,needcompile,ok]=do_eval(scs_m,%cpr)
    if needcompile<>4&size(%cpr)>0 then %state0=%cpr.state,end
    alreadyran=%f
  else
    message(['Error occured when evaluating context:'; lasterror()]);
    continue;
  end
  enablemenus()
endfunction

function [scs_m,cpr,needcompile,ok]=do_eval(scs_m,cpr)
// This function (re)-evaluates blocks in the scicos data structure scs_m 
// Copyright INRIA
  ok=%t
  needcompile1=max(2,needcompile)
  // %mprt=funcprot()
  // funcprot(0) 
  
  getvalue=setvalue; // XXXXX Bof ? 
  
  function message(txt)
    x_message('In block '+o.gui+': '+txt);
    resume(%scicos_prob=%t); 
  endfunction

  %scicos_prob=%f

  function [ok,tt]=FORTR(funam,tt,i,o) ; ok=%t; endfunction
  function [ok,tt]=CFORTR2(funam,tt,i,o); ok=%t; endfunction
  function [ok,tt]=CFORTR(funam,tt,i,o); ok=%t; endfunction
  function [x,y,ok,gc]=edit_curv(x,y,job,tit,gc); ok=%t; endfunction
  function [ok,tt,dep_ut]=genfunc1(tt,ni,no,nci,nco,nx,nz,nrp,type_) ;dep_ut=model.dep_ut;ok=%t; endfunction

  // funcprot(%mprt)
  %nx=length(scs_m.objs)
  
  for %kk=1:%nx
    o=scs_m.objs(%kk)
    if o.type =='Block' then		// 
      model=o.model
      if model.sim(1)=='super'|model.sim(1)=='csuper' then
	sblock=model.rpar
	context=sblock.props.context
	if ~isempty(context) then 
	  %now_win=xget('window')
	  [ok,H1]=execstr(context,env=%scicos_context,errcatch=%t);
	  xset('window',%now_win)
	  if ~ok then
	    message(['Cannot evaluate a context';lasterror()])
	  else
	    %scicos_context=H1;
	    [sblock,%w,needcompile2,ok]=do_eval(sblock,list())
	    needcompile1=max(needcompile1,needcompile2)
	    if ok then
	      scs_m.objs(%kk).model.rpar=sblock
	    end
	  end    
	end
      else
	model=o.model
	execstr('o='+o.gui+'(''set'',o)')
	needcompile1=max(needcompile1,needcompile) // for scifunc_block
	model_n=o.model
	if or(model.blocktype<>model_n.blocktype) | 
	  or(model.dep_ut<>model_n.dep_ut) |
	   (model.nzcross<>model_n.nzcross)|(model.nmode<>model_n.nmode)
	then 
	  needcompile1=4
	end
	scs_m.objs(%kk)=o
      end
    end
  end
  needcompile=needcompile1
  if needcompile==4 then cpr=list(),end
endfunction


