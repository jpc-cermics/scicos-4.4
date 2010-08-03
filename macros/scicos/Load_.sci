function Load_()
  Cmenu='Open/Set'
  if edited&~super_block then
    num=x_message(['Diagram has not been saved'],['gtk-ok','gtk-go-back'])
    if num==2 then return;end
    if alreadyran then do_terminate(),end  //terminate current simulation
    alreadyran=%f
  end
  disablemenus();
  [ok,scs_m,%cpr,edited]=do_load()
  if super_block then edited=%t;end
  if ok then
    if ~set_cmap(scs_m.props.options('Cmap')) then 
      scs_m.props.options('3D')(1)=%f //disable 3D block shape 
    end
    options=scs_m.props.options
    xset('alufunction',3);
    xclear();//xbasc();
    xselect();
    set_background()

    pwindow_set_size()
    window_set_size()

    xselect();

    if is(scs_m.props.context,%types.SMat) then
      %now_win=xget('window')
      // execute the context 
      if ~exists('%scicos_context') then 
	%scicos_context=hash_create(0);
      end
      [ok,H1]=execstr(scs_m.props.context,env=%scicos_context,errcatch=%t);
      xset('window',%now_win)
      if ~ok then 
	message(['Error occur when evaluating context:']); //   lasterror() ])
      else
	context_same = H1.equal[%scicos_context];
	%scicos_context = H1;
	//perform eval only if context contains functions which may give
	//different results from one execution to next
	//XXXX : we have to check here if context contains rand exec or load 
	if ~context_same then 
	  disablemenus()
	  [scs_m,%cpr,needcompile,ok]=do_eval(scs_m,%cpr)
	  enablemenus()
	end
      end
    else
      scs_m.props.context=' '
    end
    //xset('alufunction',6)
    scs_m=drawobjs(scs_m),
    if pixmap then xset('wshow'),end
    if size(%cpr)==0 then
      needcompile=4
      alreadyran=%f
    else
      %state0=%cpr.state
      needcompile=0
      alreadyran=%f
    end
  end
  enablemenus()
endfunction

function [ok,scs_m,%cpr,edited]=do_load(fname,typ)
// Copyright INRIA
  if nargin < 2 then typ='diagram',end

  if alreadyran & typ=='diagram' then 
    do_terminate(),//end current simulation
  end  

  edited=%f
  %cpr=list()
  scs_m=scicos_diagram();

  current_version=scicos_ver
  //default version set to scicos2.2, 
  //for previous version scicos_ver is stored in files
  scicos_ver='scicos2.2' 

  if nargin <= 0 then fname=xgetfile(masks=['Scicos file';'*.cos*'],open=%t),end
  if fname<>emptystr() then
    [path,name,ext]=splitfilepath(fname)
    select ext
     case 'cosf'
      ierr=execstr('exec(fname);',errcatch=%t)
      ok=%t
     case 'cos' then
      ierr=execstr('load(fname);',errcatch=%t)
      ok=%t
    else
      message(['Only *.cos (binary) and *.cosf (formatted) files';
	       'allowed'])
      ok=%f
      scs_m=scicos_diagram();
      return
    end
    if ~ierr then
      message([name+' cannot be loaded.';lasterror()]) 
      ok=%f;
      return
    end
    if scicos_ver=='scicos2.2' then
      if isempty(scs_m) then scs_m=x,end //for compatibility
    end
    if scicos_ver<>current_version then 
      scs_m=do_version(scs_m,scicos_ver),
      %cpr=list()
      edited=%t
    end
  else
    ok=%f
    scs_m=scicos_diagram();
    return
  end
  scs_m.props.title=[scs_m.props.title(1),path]

  if typ=='diagram' then
    if ~%cpr.equal[list()] then
      for jj=1:size(%cpr.sim.funtyp,'*')
	if %cpr.sim.funtyp(jj)<10000 then
	  if %cpr.sim.funtyp(jj)>999 then
	    funam=%cpr.sim.funs(jj)
	    if ~c_link(funam) then
	      qqq=%cpr.corinv(jj)
	      path=list('objs',qqq(1))
	      for kkk=qqq(2:$)
		path($+1)='model'
		path($+1)='rpar'
		path($+1)='objs'
		path($+1)=kkk
	      end
	      path($+1)='graphics';path($+1)='exprs';path($+1)=2;
	      tt=scs_m(path)
	      if %cpr.sim.funtyp(jj)>1999 then
		[ok]=scicos_block_link(funam,tt,'c')
	      else
		[ok]=scicos_block_link(funam,tt,'f')
	      end 
	    end
	  end
	end
      end
    end
  end
endfunction

