function [ok, scs_m, %cpr, edited] = do_load(fname,typ,import,keep_xstringb=%f)
// Copyright INRIA
// Load a Scicos/Nsp diagram or import a Scicos diagram from scicoslab
// keep_xstring can be set to true if during import the icons of xstringb types
// should be kept and not re-created with define.

// Update a schema from scilab to nsp
// -- graphics.gr_i is regenerated since basic graphic calls
//    are different in nsp (options are passed as option=val.
// -- ipar is to be regenerated for block who hard code
//    string into scilab code.
// -- angle is to be changed since conventions are not the same.

  
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
  
  function scs_m=do_update_scilab_schema(scs_m,keep_xstringb=%t)
  // do not use wpar when importing from scicoslab 
  // this should be done recursively.
    if size(scs_m.props.wpar,'*') >= 13 then 
      scs_m.props.wpar=scs_m.props.wpar(1:2);
    end
    
    n=size(scs_m.objs);
    if scs_m.props.options.iskey['D3'];
      scs_m.props.options('3D')=   scs_m.props.options('D3')
      scs_m.props.options.delete['D3'];
    end
    for i=1:n
      if scs_m.objs(i).iskey['gui'] then
	keep = %f;
	// check is graphics is a xstringb: we will keep it if keep_xstringb is true.
	gr_i= scs_m.objs(i).graphics.gr_i;
	if type(gr_i,'short')=='l' then gr_i = gr_i(1);end
	if type(gr_i,'short')== 's' && part(gr_i($),1:8)=="xstringb" && keep_xstringb then keep=%t;end
	//
	gui=scs_m.objs(i).gui;
	if ~keep then
	  // we can change the gui
	  if ~exists(gui,'callable') then 
	    guin = 'MISSING_BLOCK';
	    cmd = sprintf('obj=%s(''define'',''%s'');',guin,gui);
	    ok=execstr(cmd,errcatch=%t);
	    if ~ok then lasterror();
	    else
	      scs_m.objs(i).gui = obj.gui;
	      scs_m.objs(i).graphics.gr_i = obj.graphics.gr_i;
	      scs_m.objs(i).graphics.exprs = obj.graphics.exprs;
	      scs_m.objs(i).model.rpar = obj.model.rpar;
	    end
	  else
	    ok=execstr( 'obj='+gui+'(''define'')',errcatch=%t);
	    if ok then
	      if type(scs_m.objs(i).graphics.gr_i,'short')=='l' then
		scs_m.objs(i).graphics.gr_i(1) = obj.graphics.gr_i(1);
	      else
		scs_m.objs(i).graphics.gr_i = obj.graphics.gr_i;
	      end
	    else
	      message([sprintf('Update of %s cannot be done, we ignore the update',gui);
		       catenate(lasterror())]);
	      gr_i='xstringb(orig(1),orig(2),''undefined'',sz(1),sz(2),''fill'');';
	      scs_m.objs(i).graphics.gr_i=gr_i;
	    end
	  end
	end
	//scs_m.objs(i).graphics.out_implicit = obj.graphics.out_implicit;
	//scs_m.objs(i).graphics.in_implicit = obj.graphics.in_implicit;
	// This is not necessary since it can be done by Eval
	//
	select gui
	 case 'RFILE_f' then
	  // Uses C to read data
	  omodel = scs_m.objs(i).model
	  oipar = omodel.ipar;
	  imask=5+oipar(1)+oipar(2)
	  // new values;
	  exprs= scs_m.objs(i).graphics.exprs
	  fname=exprs(3)
	  frmt="%f"; // exprs(4)
	  // the new ipar.
	  ipar=[length(fname);length(frmt);oipar(3:4); str2code(fname);
		str2code(frmt);oipar(imask:$)];
	  scs_m.objs(i).model.ipar = ipar;
	 case 'READC_f' then
	  omodel = scs_m.objs(i).model;
	  oipar = omodel.ipar;
	  imask=10+oipar(1);
	  // new values;
	  exprs= scs_m.objs(i).graphics.exprs;
	  fname=exprs(3);
	  frmt=exprs(4);
	  frmt=part(frmt,1:3);// be sure that we are three character long
	  ipar=[length(fname);
		str2code(frmt);
		oipar(5:9);
		str2code(fname);
		oipar(imask:$)];
	  scs_m.objs(i).model.ipar = ipar;
	 case 'READAU_f' then
	  omodel = scs_m.objs(i).model
	  oipar = omodel.ipar;
	  exprs= scs_m.objs(i).graphics.exprs
	  fname=exprs(1)
	  frmt='uc ';
	  imask=10+oipar(1)
	  ipar=[length(fname);
		str2code(frmt);
		oipar(5:9);
		str2code(fname);
		oipar(imask:$)];
	  scs_m.objs(i).model.ipar = ipar;
	 case 'WRITEAU_f' then
	  exprs= scs_m.objs(i).graphics.exprs
	  fname=exprs(2)
	  frmt='uc ';
	  ipar=[length(fname);str2code(frmt);2;0;str2code(fname)];
	  scs_m.objs(i).model.ipar = ipar;
	 case 'WRITEC_f' then
	  exprs= scs_m.objs(i).graphics.exprs
	  fname=exprs(2)
	  frmt=exprs(3);
	  frmt=part(frmt,1:3);
	  N=  evstr(exprs(4));
	  swap=evstr(exprs(5));
	  ipar=[length(fname);str2code(frmt);N;swap;str2code(fname)];
	  scs_m.objs(i).model.ipar = ipar;
	 case 'WFILE_f' then
	  exprs= scs_m.objs(i).graphics.exprs
	  fname=exprs(2)
	  frmt="%5.2f"// exprs(3)
	  N=  evstr(exprs(4));
	  ipar=[length(fname);length(frmt);0;N;str2code(fname); ...
		str2code(frmt)];
	  scs_m.objs(i).model.ipar = ipar;
	end
      end
      o=scs_m.objs(i);
      if o.type =='Block' then
	omod=o.model;
	if or(o.model.sim(1)==['super','asuper','csuper']) then
	  o.model.rpar=do_update_scilab_schema(o.model.rpar,keep_xstringb=keep_xstringb);
	end
	o.graphics.theta = - o.graphics.theta;
	scs_m.objs(i)=o;
      elseif o.type =='Text' then
	sizes=[8,10,12,14,18,24];
	o.model.ipar(2)=sizes(min(max(1,o.model.ipar(2)),6))/10;
	o.graphics.exprs(3)= sci2exp(o.model.ipar(2));
	scs_m.objs(i)=o;
      end
    end
  endfunction
  
  function scs_m=do_subst_missing_blocks(scs_m)
  // replace undefinde blocks by MISSING_BLOCK
    n=size(scs_m.objs);
    for i=1:n
      if scs_m.objs(i).iskey['gui'] then
	gui=scs_m.objs(i).gui;
	if ~exists(gui,'callable') then 
	  guin = 'MISSING_BLOCK';
	  cmd = sprintf('obj=%s(''define'',''%s'');',guin,gui);
	  ok=execstr(cmd,errcatch=%t);
	  if ~ok then lasterror();
	  else
	    scs_m.objs(i).gui = obj.gui;
	    scs_m.objs(i).graphics.gr_i = obj.graphics.gr_i;
	    scs_m.objs(i).graphics.exprs = obj.graphics.exprs;
	    scs_m.objs(i).model.rpar = obj.model.rpar;
	    printf("Warning: missing function %s, Block %s is replaced by  MISSING_BLOCK",...
		   gui,gui); 
	  end
	end
      end
      o=scs_m.objs(i);
      if o.type =='Block' then
	omod=o.model;
	if or(o.model.sim(1)==['super','asuper','csuper']) then
	  o.model.rpar=do_subst_missing_blocks(o.model.rpar);
	end
	o.graphics.theta = - o.graphics.theta;
	scs_m.objs(i)=o;
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
      if o.type=='Block'|o.type=='Text' then
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

  // main code of do_load 
  
  global(%scicos_demo_mode=%f); // is it a demo mode 
  global(%scicos_open_saveas_path=''); // default dir 
  global(%scicos_ext='.cos'); //default file extension
  
  if nargin <=0 then fname=[]; end
  if nargin <=1 then typ = "diagram";  end
  if nargin <=2 then import = %f;  end
  
  alreadyran=acquire('alreadyran',def=%f);
  
  //end current simulation
  if alreadyran & typ=="diagram" then do_terminate(); end
  
  //set debug level to 0 for new diagram loaded
  scicos_debug(0); 
  
  current_version = get_scicos_version();
  if ~isempty(winsid) then
    xpause(100)  // quick and dirty fix for windows bug on fast
    // computers
  end
  // masks 
  if exists('%scicos_gui_mode') && %scicos_gui_mode==1 then
    if %scicos_ext.equal['xml'] then
      masks=['Scicos xml','Scicos file';'*.xml','*.cos*']
    else
      masks=['Scicos file','Scicos xml';'*.cos*','*.xml']
    end
  else
    masks=['Scicos file';'*.cos*']
  end

  ok=%t
  with_gui=isempty(fname) //if fname is empty one needs gui
  if type(fname,'short')=='m' then fname = m2s(fname);end;
  fnam = stripblanks(fname);// keep initila fname
  while %t
    fname=fnam
    if isempty(fname) then 
      if ~isempty(%scicos_demo_mode) then
	//** open a demo file
	path=file('join',[get_scicospath();"demos"]);
	fname=xgetfile(masks=['Scicos file','Scicos xml';'*.cos*','*.xml'],open=%t,dir=path)
      else
	fname=xgetfile(masks=masks,open=%t,dir=%scicos_open_saveas_path);
      end
    end
    %scicos_demo_mode = []; //** clear the variable

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
    if with_gui then %scicos_open_saveas_path=path, end
    if import then
      if ~or(ext==['cos','COS','XML','xml']) then
        message(['Only *.cos (binary) and *.xml (xml) files allowed for import']);
        ok=%f
        if ~with_gui then return, end
      else
        ok=%t
      end
    else
      //first pass
      if or(ext==['cos','COS','cosf','COSF','','XML','xml']) then
        if ext=='' then
          // to allow user not to enter necessarily the extension
          fname=fname+'.cos'
          ext='cos'
        end
        ok=%t
      else
        message(['Only *.cos (binary), *.cosf (formatted) files and *.xml (xml)';
                 'allowed'])
        ok=%f
        if ~with_gui then
          scs_m = get_new_scs_m();
          return
        end
      end
    end
    if ok then break, end
  end
  
  //second pass
  if ext=='cos' || ext=='COS' then
    if import then
      ok=execstr('sci_load(fname);',errcatch=%t)
    else
      ok=execstr('load(fname)',errcatch=%t)
    end
  elseif ext=='cosf' || ext=='COSF' then
    ok=execstr('exec(fname)',errcatch=%t);
  elseif ext=='xml' || ext=='XML' then
    printf('Opening an XML file. Please wait ...............\n')
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
    //      [ok,scs_m]=do_define_and_set(scs_m)
    [scs_m,cpr,vv,ok]=do_eval(scs_m,list(),hash(1),'XML');
    if ~ok then
      x_message(['An error occured while opening the diagram\n';
		 catenate(lasterror());
		 'The diagram will not be opened'])
      scs_m= get_new_scs_m();;
      return;
    end
  end
  if isempty(scs_m) then scs_m= get_new_scs_m();end
  // update version
  [ok,scicos_ver,scs_m]=update_version(scs_m);
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
  
  if import then
    // convert from scilab
    scs_m=do_update_scilab_schema(scs_m,keep_xstringb=keep_xstringb);
    // just in case we make a save
    scs_m.props.title=[scs_m.props.title(1)+'_nsp',path];
  else
    // remove undefined blocks 
    // Note that this is also done in do_update_scilab_schema
    scs_m=do_subst_missing_blocks(scs_m);
    scs_m.props.title=[scs_m.props.title(1),path];
  end
  

    
  if ext=='xml'|ext=='XML' then
    scs_m_sav=scs_m;
    [scs_m,ok]=generating_atomic_code(scs_m)
    if ~ok then scs_m=scs_m_sav;ok=%t;end
  end
  if ~ok then scs_m = get_new_scs_m();return;end
  %scicos_ext=ext
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
  elseif typ=='palette' then
    // Extract palette only if the pallette is composed by only one PAL_f block
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

