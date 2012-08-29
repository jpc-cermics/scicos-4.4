function scmenu_scicoslab_import()
// similar to open 
// but the flag %t in do_open will change do_load to do_scicoslab_import.
// 
  Cmenu='';Select=[]
  if edited & ~super_block then
    num=x_message(['Diagram has not been saved'],['gtk-ok','gtk-go-back'])
    if num==2 then return;end
    if alreadyran then do_terminate(),end  //terminate current simulation
    clear('%scicos_solver')
    alreadyran=%f
  end
  //xselect();
  [ok,sc,cpr,ed,context]=do_open(%t)
  if ok then 
    %scicos_context=context;
    scs_m=sc; %cpr=cpr; edited=ed;
    options=scs_m.props.options;
    if size(scs_m.props.wpar,'*')>12 then
      %zoom=scs_m.props.wpar(13)
    else
      %zoom=1.4
    end
    alreadyran=%f;
    if size(%cpr)==0 then
      needcompile=4;
    else
      %state0=%cpr.state;
      needcompile=0;
    end
  end
endfunction


function [ok,scs_m,%cpr,edited]=do_scicoslab_import(fname,typ)
// Copyright INRIA
  if nargin < 2 then typ='diagram',end
  if ~exists('alreadyran') then alreadyran = %f;end 
  //default version set to scicos2.2, 
  //for previous version scicos_ver is stored in files
  if ~exists('scicos_ver') then scicos_ver='scicos2.2';end 
  
  if alreadyran & typ=='diagram' then 
    do_terminate(),//end current simulation
  end  

  // default values 
  ok=%t;
  edited=%f
  %cpr=list()
  scs_m=get_new_scs_m();

  current_version = get_scicos_version();
  if nargin <= 0 then 
    fname=xgetfile(masks=['Scicos cos file';'*.cos'],open=%t);
  end
  if fname.equal[emptystr()] then
    ok=%f;
    return
  end
  [path,name,ext]=splitfilepath(fname);
  if ext<> 'cos' then 
    message(['Only scilab *.cos (binary) files allowed for import']);
    ok=%f
    return
  end
  if ~file('exists',fname)  then 
    message([name+' cannot be loaded:';
	     'file '+fname+' does not exists !']);
    ok=%f ;
    return;
  end;
  eok=execstr('sci_load(fname);',errcatch=%t)
  if ~eok then
    message([name+' cannot be loaded.';catenate(lasterror())]) 
    ok=%f;
    return
  end
  // check if version is inside scs_m;
  if type(scs_m,'short')== 'h' && scs_m.iskey['version'] then 
    scicos_ver = scs_m.version
  else
    if ~exists('scicos_ver') then 
      scicos_ver='scicos2.2';
    end
  end
  if scicos_ver=='scicos2.2' then
    if isempty(scs_m) then scs_m=x,end //for compatibility
  end
  
  if scicos_ver<>current_version then 
    ok=execstr('scs_m=do_version(scs_m,scicos_ver)',errcatch=%t);
    if ~ok then 
      message(['Error: cannot update the diagram:';
	       catenate(lasterror())]);
      %cpr=list();
      edited=%t;
      return; 
    end
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
// -- angle is to be changed since conventions are not the same.

function scs_m=do_update_scilab_schema(scs_m)
  n=size(scs_m.objs);
  if scs_m.props.options.iskey['D3'];
    scs_m.props.options('3D')=   scs_m.props.options('D3')
    scs_m.props.options.delete['D3'];
  end
  for i=1:n
    if scs_m.objs(i).iskey['gui'] then 
      gui=scs_m.objs(i).gui;
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



 


  
