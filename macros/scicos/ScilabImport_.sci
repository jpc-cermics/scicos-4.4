function ScicoslabImport_()
// Import a Scilab Diagram in Nsp scicos.
// XXX we should change the name in order not to 
// overwrite the Scilab Diagram when saving.
  Cmenu=''
  if edited & ~super_block then
    num=x_message(['Diagram has not been saved'],['gtk-ok','gtk-go-back'])
    if num==2 then return;end
    if alreadyran then do_terminate(),end  //terminate current simulation
    alreadyran=%f
  end
  [ok,scs_m,%cpr,edited]=do_scilab_import()
  if super_block then edited=%t;end
  if ok then
    if ~set_cmap(scs_m.props.options('Cmap')) then 
      scs_m.props.options('3D')(1)=%f //disable 3D block shape 
    end
    options=scs_m.props.options
    xclear();
    xselect();
    set_background()
    window_set_size()
    if is(scs_m.props.context,%types.SMat) then
      %now_win=xget('window')
      if ~execstr(scs_m.props.context,errcatch=%t) then
	message(['Error occur when evaluating context:']);
	lasterror();
      end
      xset('window',%now_win)
    else
      scs_m.props.context=' '
    end
    scs_m= drawobjs(scs_m),
    //if pixmap then xset('wshow'),end
    if size(%cpr)==0 then
      needcompile=4
      alreadyran=%f
    else
      %state0=%cpr.state
      needcompile=0
      alreadyran=%f
    end
  end
endfunction

function [ok,scs_m,%cpr,edited]=do_scilab_import(fname,typ)
// Copyright INRIA
  if nargin < 2 then typ='diagram',end
  if ~exists('alreadyran') then alreadyran = %f;end 
  //default version set to scicos2.2, 
  //for previous version scicos_ver is stored in files
  if ~exists('scicos_ver') then scicos_ver='scicos2.2';end 
  
  if alreadyran & typ=='diagram' then 
    do_terminate(),//end current simulation
  end  

  edited=%f
  %cpr=list()
  scs_m=[]

  current_version = get_scicos_version();
  if nargin <= 0 then 
    fname=xgetfile(masks=['Scicos cos file';'*.cos'],open=%t);
  end
  if fname.equal[emptystr()] then
    ok=%f;
    scs_m = get_new_scs_m();
    return
  end
  [path,name,ext]=splitfilepath(fname)
  select ext
   case 'cos' then
    ierr=execstr('sci_load(fname);',errcatch=%t)
    ok=%t
  else
    message(['Only scilab *.cos (binary) files allowed for import']);
    ok=%f
    scs_m=list()
    return
  end
  if ~ierr then
    message([name+' cannot be loaded.';lasterror()]) 
    ok=%f;
    return
  end
  // check if version is inside scs_m;
  if scs_m.iskey['version'] then 
    scicos_ver = scs_m.version
  end
  if scicos_ver=='scicos2.2' then
    if isempty(scs_m) then scs_m=x,end //for compatibility
  end
  // we could here make an eval 
  // if ~exists('%cpr') then %cpr=list();end ;
  // [scs_m,%cpr,needcompile,ok]=do_eval(scs_m,%cpr);
  if scicos_ver<>current_version then 
    scs_m=do_version(scs_m,scicos_ver),
    %cpr=list()
    edited=%t
  end
  // convert from scilab 
  scs_m=do_update_scilab_schema(scs_m);
  // just in case we make a save 
  scs_m.props.title(1)=  scs_m.props.title(1)+'_nsp' ;
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

// Update a schema from scilab to nsp 
// -- graphics.gr_i is regenerated since basic graphic calls 
//    are different in nsp (options are passed as option=val.
// -- ipar is to be regenerated for block who hard code 
//    string into scilab code.

function scs_m=do_update_scilab_schema(scs_m)
  n=size(scs_m.objs);
  if scs_m.props.options.iskey['D3'];
    scs_m.props.options('3D')=   scs_m.props.options('D3')
    scs_m.props.options.delete['D3'];
  end
  for i=1:n
    if scs_m.objs(i).iskey['gui'] then 
      gui=scs_m.objs(i).gui;
      execstr( 'obj='+gui+'(''define'')');
      if type(scs_m.objs(i).graphics.gr_i,'short')=='l' then 
	scs_m.objs(i).graphics.gr_i(1) = obj.graphics.gr_i(1);
      else 
	scs_m.objs(i).graphics.gr_i = obj.graphics.gr_i;
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
      if o.model.sim.equal['super'] | o.model.sim.equal['csuper'] then
	o.model.rpar=do_update_scilab_schema(o.model.rpar)
      end
      scs_m.objs(i)=o;
    end
  end
endfunction



 


  
