function [ok, scs_m, %cpr, edited] = do_load(fname,typ)
// Copyright INRIA
// Load a Scicos diagram

  function [scicos_ver]=find_scicos_version(scs_m)
  // Copyright INRIA
  // find_scicos_version tries to retrieve a scicos
  // version number in a scs_m structure.
  // 21/08/07: Alan, inital revision
  // 
    if ~exists('scicos_ver') then
      scicos_ver = "scicos2.2";
    else
      scicos_ver = scicos_ver;
    end
    if scs_m.iskey['version'] then
      if scs_m.version<>'' then
	// version is stored in the structure.
	scicos_ver=scs_m.version
	return;
      end
      n=size(scs_m.objs);
      for j=1:n //loop on objects
	o=scs_m.objs(j);
	if o.type =='Block' then
	  if o.model.iskey['equations'] then
	    scicos_ver = "scicos2.7.3"
	    break;
	  else
	    // the last version supported here is scicos2.7
	    // other tests can be done
	    scicos_ver = "scicos2.7"
	    break;
	  end
	end
      end //** end for
    end
  endfunction

  function [ok,scicos_ver,scs_m]=update_version(scs_m)
  // updates a diagram to the current scicos version 
    ok=%t;
    current_version = get_scicos_version()
    // guess the proper version of the diagram 
    scicos_ver = find_scicos_version(scs_m)
    if scicos_ver==current_version then return;end 
    cmd= 'scs_m_out=do_version(scs_m,scicos_ver)'
    ok=execstr(cmd,errcatch=%t)
    if ~ok then
      lasterror();
      return;
    end
    scs_m=scs_m_out;
  endfunction
  
  global %scicos_demo_mode ; 
  if nargin <=0 then fname=[]; end
  if nargin <=1 then typ = "diagram";  end
  if ~exists('alreadyran') then alreadyran = %f;end 
  
  if alreadyran & typ=="diagram" then
    do_terminate(); //end current simulation
  end

  scicos_debug(0); //set debug level to 0 for new diagram loaded

  current_version = get_scicos_version()
  if ~isempty(winsid) then
    xpause(100)  // quick and dirty fix for windows bug on fast
    // computers
  end
  
  if %scicos_demo_mode==1 then
    //** open a demo file
    if isempty(fname) then
      if exists('%scicos_gui_mode') && %scicos_gui_mode==1 then
	file_mask = ["*.cos*","*.xml"]
      else
	file_mask = "*.cos*"
      end
      path=file('join',[get_scicospath();"demos"]);
      // fname     = getfile(file_mask, path)
      fname=xgetfile(masks=['Scicos file','Scicos xml';'*.cos*','*.xml'],open=%t,dir=path)
    end
  else
    //** conventional Open
    if isempty(fname) then
      if exists('%scicos_gui_mode') && %scicos_gui_mode==1 then
	// fname = getfile(['*.cos*','*.xml'])
	fname=xgetfile(masks=['Scicos file','Scicos xml';'*.cos*','*.xml'],open=%t);
      else
	// fname = getfile('*.cos*')
	fname=xgetfile(masks=['Scicos file';'*.cos*'],open=%t);
      end
    end
  end 
  %scicos_demo_mode = []; //** clear the variable

  fname = stripblanks(fname)
  
  if fname.equal[""] then 
    // We have canceled the open 
    ok=%f
    %cpr=%cpr
    scs_m=scs_m
    edited=edited
    return
  end
  
  %cpr=list()
  scs_m=[]
  edited = %f
  [path,name,ext]=splitfilepath(fname);
  //first pass
  if or(ext==['cos','COS','cosf','COSF','','XML','xml']) then
    if ext=='' then  
      // to allow user not to enter necessarily the extension
      fname=fname+'.cos'
      ext='cos'
    end
  else
    message(['Only *.cos (binary), *.cosf (formatted) files and *.xml (xml)';
	     'allowed'])
    ok=%f
    //scs_m=scicos_diagram(version=current_version)
    scs_m = get_new_scs_m();
    return
  end
  //second pass
  if ext=='cos'|ext=='COS' then
    ok=execstr('load(fname)',errcatch=%t)
  elseif ext=='cosf'|ext=='COSF' then
    ok=execstr('exec(fname)',errcatch=%t);
  elseif ext=='xml'|ext=='XML' then
    printf('Opening an XML file. Please wait ...............')
    ok=execstr('scs_m=xml2cos(fname)',errcatch=%t)
  elseif ext=='new'
    ok=%t
    ierr=%t
    scs_m=scicos_diagram(version=current_version)
    scs_m.props.title=name
  end
  if ~ok then
    str=lasterror();
    if length(str)>= 4 then str=str(1:$-4);end 
    message(['An error has occur during execution of ""'+name+'""';
	     catenate(str)]);
    ok=%f
    scs_m=get_new_scs_m();    
    return
  end
  if tolower(ext) == 'xml' then
    needcompile=4;
    [scs_m,cpr,vv,ok]=do_eval(scs_m,list(),hash(1),%f,'XML');
    if ~ok then
      x_message(['An error occured while opening the diagram\n';
		 catenate(lasterror());
		 'The diagram will not be opened'])
      scs_m= get_new_scs_m();;
      return;
    end
  end
  //for compatibility
  scicos_ver=find_scicos_version(scs_m)
  if scicos_ver=='scicos2.2' then
    if isempty(scs_m) then scs_m=x,end //for compatibility
  end
  //##update version
  [ok,scicos_ver,scs_m]=update_version(scs_m)
  if ~ok then
    message('An error occured during the update of '+name+'.')
    scs_m = get_new_scs_m();
    return
  end
  //## reset %cpr and edited=%t if we have
  //## do a convertion
  if scicos_ver<>current_version then
    %cpr=list()
    edited=%t
  end
  scs_m.props.title=[scs_m.props.title(1),path]
  if ext=='xml'|ext=='XML' then
    scs_m_sav=scs_m;
    [scs_m,ok]=generating_atomic_code(scs_m)
    if ~ok then scs_m=scs_m_sav;ok=%t;end
  end
  if ~ok then scs_m = get_new_scs_m();return;end
  if typ=='diagram' then
    if ~%cpr.equal[list()] then
      for jj=1:size(%cpr.sim.funtyp,'*')
	if type(%cpr.corinv(jj),'short')=='l' then
	  //force recompilation if diagram contains Modelica Blocks
	  //Can be improved later, re-generating C code only...
	  %cpr=list()
	  edited=%t
	  return
	end
	
	ft=modulo(%cpr.sim.funtyp(jj),10000)
	if ft>999 then
	  funam=%cpr.sim.funs(jj)
	  //regenerate systematically dynamically linked blocks forsafety
	  //[a,b]=c_link(funam); while a;  ulink(b);[a,b]=c_link(funam);end
	  //should be better than
	  //"if  ~c_link(funam) then"
	  //but ulink remove .so files and Makefile doesnt depends on .so file...
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
	    if ft>1999 then
	      pp=%cpr.corinv(jj)
	      if size(pp,'*')>1 then
	        scs_string='scs_m.objs('+sci2exp(pp(1))+').model.rpar'
		pp(1)=[]
		while size(pp,'*')>1
		  scs_string=scs_string+'.objs('+sci2exp(pp(1))+').model.rpar'
		  pp(1)=[];
                end
                scs_string=scs_string+'.objs('+sci2exp(pp(1))+')'
              else
	        scs_string='scs_m.objs('+sci2exp(pp(1))+')'
 	      end
	      execstr('fnam='+scs_string+'.model.sim(1)');
	      if fnam=='asuper' then 
	        execstr('[modeli,ok]=recur_scicos_block_link('+scs_string+',''c'')')
		clear modeli fnam pp scs_string        
	      else 
	        [ok]=scicos_block_link(funam,tt,'c')
	      end
	    else
	      [ok]=scicos_block_link(funam,tt,'f')
	    end
	  end
	end
      end
    end
    //    if ext=='xml'|ext=='XML' then
    //if the diagram contains an affiche block a window is openend on eval action
    //      open_win=winsid();
    //      k=find(open_win==0);
    //      xdel(open_win(k));
    //    end
  elseif typ=='palette' then
    //## Extract palette only if the pallette is composed
    //## by only one PAL_f block
    ok=execstr('nbobj=length(scs_m.objs)',errcatch=%t)
    if ok then
      if nbobj==1 then
        ok =execstr('isPAL_f=(scs_m.objs(1).gui)==''PAL_f''',errcatch=%t)
        if ok then
          if isPAL_f then
            scs_m = scs_m.objs(1).model.rpar
          end
        end
      end
    end
  end
endfunction

function [ok,scs_m]=do_define_and_set(scs_m,flg)
  %mprt=funcprot()
  funcprot(0) 
  getvalue=setvalue;
  
  function message(txt)
    x_message('In block '+o.gui+': '+txt);
    global %scicos_prob;
    resume(%scicos_prob=%t);
  endfunction
  
  global %scicos_prob
  %scicos_prob=%f
  
  //## overload some functions used in GUI
  function [ok,tt]        =  FORTR(funam,tt,i,o) 
    ok=%t;
  endfunction
  function [ok,tt,cancel] =  CFORTR2(funam,tt,i,o)
    ok=%t,cancel=%f
  endfunction
  function [ok,tt]        =  CFORTR(funam,tt,i,o)
    ok=%t
  endfunction
  function [x,y,ok,gc]    =  edit_curv(x,y,job,tit,gc)
    ok=%t
  endfunction
  function [ok,tt,dep_ut] = genfunc1(tt,ni,no,nci,nco,nx,nz,nrp,type_)
    dep_ut=model.dep_ut;ok=%t
  endfunction
  function result         = dialog(labels,valueini)
    result=valueini
  endfunction
  function [result,Quit]  = scstxtedit(valueini,v2)
    result=valueini,Quit=%f
  endfunction
  // use a non interactive version
  if nargin < 2 then
    // do not use herited context 
    [%scicos_context,ierr]=script2var(scs_m.props.context,hash(10));
  else
    // enrich %scicos_context 
    [%scicos_context,ierr]=script2var(scs_m.props.context)
  end
  n=size(scs_m.objs);
  for i=1:n
    o=scs_m.objs(i);
    if typeof(o)=='Block'|typeof(o)=='Text' then
      graphics=o.graphics;
      rpar=o.model.rpar;
      sim=o.model.sim;
      ierr=execstr('o='+o.gui+'(""define"",o);',errcatch=%t);
      if ierr<>0 then
	x_message(['An error occured while opening the diagram';
		   lasterror();
		   'The diagram will not be opened'])
	ok=%f;
	scs_m= get_new_scs_m();;
	return
      end
      //update model compatibility with old csuper blocks
      if length(o.model)<length(scicos_model()) then
	o.model=update_model(o.model);
      end
      o.graphics.exprs=graphics.exprs;
      if or(o.model.sim(1)==['super','asuper']) | ...
	    (o.model.sim(1)=='csuper'& ~isequal(o.model.ipar,1))
	[ok,scs_m_1]=do_define_and_set(rpar,%t)
	if ~ok then scs_m=get_new_scs_m();
	  return;
	end
	o.model.rpar=scs_m_1;
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
      else
	ierr=execstr('o='+o.gui+'(""set"",o);',errcatch=%t);
	if ~ierr then
	  x_message(['An error occured while opening the diagram\n';
		     catenate(lasterror());
		     'The diagram will not be opened'])
	  ok=%f;
	  scs_m= get_new_scs_m();;
	  return
	end
      end
      o.graphics=graphics;
    end
    scs_m.objs(i)=o;
  end
endfunction

function model=update_model(model)
  model = scicos_model(model(:));
endfunction

function [scs_m,ok]=generating_atomic_code(scs_m)
  ok=%t;
  scs_m_sav=scs_m;
  for i=1:length(scs_m.objs)
    o=scs_m.objs(i);
    if o.type =='Block' then
      if or(o.model.sim(1)==['super','asuper','csuper']) then
	[scs_m1,ok]=generating_atomic_code(o.model.rpar)
	if ~ok then 
	  scs_m=scs_m_sav;
	  return;
	end
	o.model.rpar=scs_m1;
	scs_m.objs(i)=o;
	if o.model.sim(1)=='asuper' then
	  printf('Generating the code for the atomic subsystem ......')
	  eok=execstr('[o,needcompile,ok]=do_create_atomic(o,i,scs_m)',errcatch=%t);
	  if ~eok  then
	    printf('Error\n')
	    printf('An Error Occured While trying to generate\n");
	    printf(' automatically the code for the atomic subsystem:\n"+ ...
		   catenate(lasterror()));
	    printf(' Please try to do it manually.\n')
	    ok=%f;
	    return;
	  end
	  // test the ok returned by do_create_atomic
	  if ~ok then scs_m=scs_m_sav;printf('Error\n');return;end
	  printf('Done\n');
	  scs_m.objs(i)=o;
	  //scs_m = update_redraw_obj(scs_m,list('objs',i),o);
	end
      end
    end
  end
endfunction

