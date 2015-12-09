function scs_m=do_version(scs_m,version)
// Copyright INRIA
// translate scicos data structure to new version
  
  function scs_m_new=do_version441(scs_m)
  // updates to 441
    scs_m_new=scs_m
    scs_m_new.version='scicos4.4.1';
    //for compatibility
    scs_m_new.props.options=scicos_options();
    keys=scs_m.props.options.__keys;
    for i=1:size(keys,'*')
      if keys(i)~='type' then
        scs_m_new.props.options(keys(i))=scs_m.props.options(keys(i));
      end
    end
    
    for j=1:length(scs_m.objs)
      o=scs_m.objs(j);
      if o.type=='Block' then
        omod=o.model
        if o.gui.equal['INVBLK'] then
          scs_m_new.objs(j).model.in2  = -2;
          scs_m_new.objs(j).model.out2 = -2;
        elseif omod.sim.equal['super'] || omod.sim.equal['csuper'] || omod.sim(1).equal['asuper'] then
          rpar=do_version441(omod.rpar);
          scs_m_new.objs(j).model.rpar=rpar
        end
      end
    end
  endfunction
  
  function scs_m_new=do_version44(scs_m)
  // updates to 44
    scs_m_new=scs_m
    scs_m_new.version='scicos4.4';
    //for compatibility
    if size(scs_m_new.props.options.ID(1),'*')==2 then
      scs_m_new.props.options.ID(1)=[scs_m.props.options.ID(1)(1),scs_m.props.options.ID(1)(2),2,1]
    end

    if size(scs_m_new.props.options.ID(2),'*')==2 then
      scs_m_new.props.options.ID(2)=[scs_m.props.options.ID(2)(1),scs_m.props.options.ID(2)(2),10,1]
    end

    Changeb=['bouncexy','cscope','cmscope','canimxy','canimxy3d',...
	     'cevscpe','cfscope','cscopexy','cscopxy','cscopexy3d',...
	     'cscopxy3d','cmatview','cmat3d','affich','affich2',...
	     'writec','writef','writeau','tows_c','bplatform2'];
    
    for j=1:length(scs_m.objs)
      o=scs_m.objs(j);
      if o.type=='Block' then
	gra=o.graphics
	omod=o.model
	if o.gui=='CBLOCK4' then
	  exprs_1=gra.exprs(1)
	  if size(exprs_1,'*')==19 then
	    exprs_1($+1)='';exprs_1($+1)=''
	    gra.exprs(1)=exprs_1;o.graphics=gra
	    scs_m_new.objs(j)=o
	  end
	else
	  if type(omod.sim(1),'short')=='s' && or(omod.sim(1)==Changeb) then
	    dep_t=omod.dep_ut($);
	    dep_u=m2b([]);dep_u(1:size(omod.in,'*'))=%t;
	    scs_m_new.objs(j).model.dep_ut=[%t dep_t]
	    if or(omod.sim(1)==['cmscope';'cscope']) then 
	      scs_m_new.objs(j).model.blocktype='x'
	    end
	  elseif omod.sim.equal['super'] || omod.sim.equal['csuper'] || omod.sim(1).equal['asuper'] then
	    rpar=do_version44(omod.rpar);
	    scs_m_new.objs(j).model.rpar=rpar
	  end
	end
      end
    end
  endfunction

  function scs_m_new=do_version43(scs_m)
  // update to  4.3
    scs_m_new=scs_m;
    scs_m_new.version='scicos4.3';
    //@@ adjust ID.fonts
    scs_m_new.props.options.ID(1)=[scs_m.props.options.ID(1)(1),scs_m.props.options.ID(1)(2),2,1]
    scs_m_new.props.options.ID(2)=[scs_m.props.options.ID(2)(1),scs_m.props.options.ID(2)(2),10,1]

    function  gr_i=convert_gri(name,gri)
    // updates the gr_i part 
      gr_i=gri;
      cmd=sprintf('o=%s(''define'');',name);
      ok=execstr(cmd,errcatch=%t);
      if ~ok then
	gr_i='xstringb(orig(1),orig(2),''undefined'',sz(1),sz(2),''fill'');'
	lasterror();
      end;
      gr_i=o.graphics.gr_i(1);
    endfunction

    names=['MUX','DEMUX','FROMWSB','TOWS_c','INTEGRAL_m','INTEGRAL',...
	   'PRODUCT','DERIV','JKFLIPFLOP','SRFLIPFLOP','DLATCH',...
	   'DFLIPFLOP','CLKGotoTagVisibility','GotoTagVisibilityMO',...
	   'GotoTagVisibility','Inductor','Capacitor','Resistor'];
    
    for j=1:length(scs_m.objs);
      o=scs_m.objs(j);
      if o.type=='Block' then
	// block updates 
	omod=o.model;
	// sbloc
	if omod.sim.equal['super'] || omod.sim.equal['csuper'] then
	  rpar=do_version43(omod.rpar);
	  scs_m_new.objs(j).model.rpar=rpar
	end
	// changes some gui's
	if ~isempty(find(name==names)) then 
	  gri=scs_m_new.objs(j).graphics.gr_i;
	  gr_i=convert_gri(name,gri);
	  scs_m_new.objs(j).graphics.gr_i=gr_i;
	end 
      elseif o.type=="Link" then 
	// update links 
	scs_m_new.objs(j).xx=o.xx(:)
	scs_m_new.objs(j).yy=o.yy(:)
      end
    end
  endfunction

  function scs_m_new=do_version42(scs_m)
  // updates to 4.2 
    scs_m_new=scs_m
    scs_m_new.version='scicos4.2';
    for j=1:length(scs_m.objs);
      o=scs_m.objs(j);
      if o.type  =='Block' then
	omod=o.model;
	//SUPER BLOCK
	if omod.sim.equal['super'] || omod.sim.equal['csuper'] then
	  rpar=do_version42(omod.rpar);
	  scs_m_new.objs(j).model.rpar=rpar
	  //name of gui and sim list change
	elseif o.gui=='SCOPE_f' then
	  scs_m_new.objs(j).gui='CSCOPE'
	  scs_m_new.objs(j).model.dstate=[]
	  //Remove the last parameter (inheritance not used in cscope)
	  ipar = scs_m_new.objs(j).model.ipar(:);
	  scs_m_new.objs(j).model.ipar = ipar(1:$-1);
	  scs_m_new.objs(j).model.sim=list('cscope', 4)
	  in = scs_m_new.objs(j).model.in(:);
	  a = size(in,1);
	  in2 = ones(a,1);
	  scs_m_new.objs(j).model.in2 = in2;
	  scs_m_new.objs(j).model.intyp = in2;
	  exprs = scs_m.objs(j).graphics.exprs;
	  if size(exprs)<9 then exprs(9)='0',end // compatibility
	  if size(exprs)<10 then exprs(10)=emptystr(),end // compatibility
	  scs_m_new.objs(j).graphics.exprs=exprs;
	elseif o.gui=='CSCOPE' then
	  exprs = scs_m.objs(j).graphics.exprs;
	  if size(exprs)<10 then exprs(10)=emptystr(),end // compatibility
	  scs_m_new.objs(j).graphics.exprs=exprs;
	elseif o.gui=='BOUNCEXY' then
	  in = scs_m_new.objs(j).model.in(:);
	  a = size(in,1);
	  in2 = ones(a,1);
	  scs_m_new.objs(j).model.in2 = in2;
	  scs_m_new.objs(j).model.intyp = in2;
	elseif o.gui=='MSCOPE_f' then
	  exprs = scs_m.objs(j).graphics.exprs;
	  if size(exprs)<10 then exprs(10)='0',end // compatibility
	  if size(exprs)<11 then exprs(11)=emptystr(),end // compatibility
	  scs_m_new.objs(j).graphics.exprs=exprs;
	  scs_m_new.objs(j).gui='CMSCOPE'
	  scs_m_new.objs(j).model.dstate=[]
	  scs_m_new.objs(j).model.sim=list('cmscope', 4)
	  in = scs_m_new.objs(j).model.in(:);
	  // be sure that the number of refresh period values 
	  // equals the number of entries.
	  a = size(in,1);
	  B=stripblanks(scs_m.objs(j).graphics.exprs(8));
	  B=split(B);
	  if size(B,'*')<> a then 
	    B(1:a)=B(1);
	  end
	  B = catenate(B,sep=' ');
	  scs_m_new.objs(j).graphics.exprs(8) = B;
	  rpar=scs_m_new.objs(j).model.rpar(:);
	  N=scs_m_new.objs(j).model.ipar(2);
	  period = [];
	  for i=1:N
	    period(i)=rpar(2);
	  end
	  scs_m_new.objs(j).model.rpar = [rpar(1);period(:);rpar(3:size(rpar,1))]
	  in2 = ones(a,1);
	  scs_m_new.objs(j).model.in2 = in2;
	  scs_m_new.objs(j).model.intyp = in2;
	elseif o.gui=='ANIMXY_f' then
	  scs_m_new.objs(j).gui='CANIMXY'
	  scs_m_new.objs(j).model.dstate=[]
	  scs_m_new.objs(j).model.sim=list('canimxy', 4)
	  in = scs_m_new.objs(j).model.in(:);
	  a = size(in,1);
	  in2 = ones(a,1);
	  scs_m_new.objs(j).model.in2 = in2;
	  scs_m_new.objs(j).model.intyp = in2;
	  scs_m_new.objs(j).graphics.exprs = [string(1);scs_m_new.objs(j).graphics.exprs(:)]
	  scs_m_new.objs(j).model.ipar = [scs_m_new.objs(j).model.ipar(:);1]
	  exprs = scs_m_new.objs(j).graphics.exprs(:)
	  if size(exprs,'*')==8 then exprs=[1;exprs(1:3);'[]';'[]';exprs(4:8)],end
	  scs_m_new.objs(j).graphics.exprs=exprs;
	elseif o.gui=='EVENTSCOPE_f' then
	  scs_m_new.objs(j).gui='CEVENTSCOPE'
	  scs_m_new.objs(j).model.dstate=[]
	  scs_m_new.objs(j).model.sim=list('cevscpe', 4)
	  in = scs_m_new.objs(j).model.in(:);
	  a = size(in,1);
	  in2 = ones(a,1);
	  scs_m_new.objs(j).model.in2 = in2;
	  scs_m_new.objs(j).model.intyp = in2;
	elseif o.gui=='FSCOPE_f' then
	  scs_m_new.objs(j).gui='CFSCOPE'
	  scs_m_new.objs(j).model.dstate=[]
	  scs_m_new.objs(j).model.sim=list('cfscope', 4)
	  in = scs_m_new.objs(j).model.in(:);
	  a = size(in,1);
	  in2 = ones(a,1);
	  scs_m_new.objs(j).model.in2 = in2;
	  scs_m_new.objs(j).model.intyp = in2;
	  exprs = scs_m.objs(j).graphics.exprs;
	  if size(exprs)<9 then exprs(9)='0',end // compatibility
	  scs_m_new.objs(j).graphics.exprs=exprs;
	elseif o.gui=='SCOPXY_f' then
	  scs_m_new.objs(j).gui='CSCOPXY'
	  scs_m_new.objs(j).model.dstate=[]
	  scs_m_new.objs(j).model.sim=list('cscopxy', 4)
	  in = scs_m_new.objs(j).model.in(:);
	  a = size(in,1);
	  in2 = ones(a,1);
	  scs_m_new.objs(j).model.in2 = in2;
	  scs_m_new.objs(j).model.intyp = in2;
	  scs_m_new.objs(j).graphics.exprs = [string(1);scs_m_new.objs(j).graphics.exprs(:)]
	  scs_m_new.objs(j).model.ipar = [scs_m_new.objs(j).model.ipar(:);1]
	elseif o.gui=='CMSCOPE' then
	  exprs = scs_m.objs(j).graphics.exprs;
	  if size(exprs)<11 then exprs(11)=emptystr(),end // compatibility
	  scs_m_new.objs(j).graphics.exprs=exprs;
	  scs_m_new.objs(j).model.dstate=[];
	  in = scs_m_new.objs(j).model.in(:);
	  // be sure that the number of refresh period values 
	  // equals the number of entries.
	  a = size(in,1);
	  B=stripblanks(scs_m.objs(j).graphics.exprs(8));
	  B=split(B);
	  if size(B,'*')<> a then 
	    B(1:a)=B(1);
	  end
	  B = catenate(B,sep=' ');
	  scs_m_new.objs(j).graphics.exprs(8)=B;
	  // 
	  rpar=scs_m_new.objs(j).model.rpar(:);
	  N=scs_m_new.objs(j).model.ipar(2);
	  period = [];
	  for i=1:N
	    period(i)=rpar(2);
	  end
	  scs_m_new.objs(j).model.rpar = [rpar(1);period(:);rpar(3:size(rpar,1))]
	  in2 = ones(a,1);
	  scs_m_new.objs(j).model.in2 = in2;
	  scs_m_new.objs(j).model.intyp = in2;
	elseif o.gui=='IN_f' then
	  scs_m_new.objs(j).model.out    = -1;
	  scs_m_new.objs(j).model.out2   = -2;
	  scs_m_new.objs(j).model.outtyp = -1;
	elseif o.gui=='OUT_f' then
	  scs_m_new.objs(j).model.in    = -1;
	  scs_m_new.objs(j).model.in2   = -2;
	  scs_m_new.objs(j).model.intyp = -1;
	elseif o.gui=='INIMPL_f' then
	  scs_m_new.objs(j).model.out    = -1;
	  scs_m_new.objs(j).model.out2   = 1;
	  scs_m_new.objs(j).model.outtyp = -1;
	elseif o.gui=='OUTIMPL_f' then
	  scs_m_new.objs(j).model.in    = -1;
	  scs_m_new.objs(j).model.in2   = 1;
	  scs_m_new.objs(j).model.intyp = -1;
	end
      end
    end
  endfunction

  function scs_m_new=do_version273(scs_m)
  // upadte to 2.7.3
    scs_m_new=scs_m;
    scs_m_new.version='scicos2.7.3';
    for i=1:length(scs_m.objs);
      o=scs_m.objs(i); 
      if o.type=='Block' then
	omod=o.model;
	if omod.iskey['equations'] == %f then 
	  omod.equations = list();
	end
	if omod.sim.equal['super'] || omod.sim.equal['csuper'] then
	  rpar=do_version273(omod.rpar)
	  omod.nmode = 0;
	  omod.rpar=rpar
	elseif omod.sim(1)=='ifthel' then // |omod.sim(1)=='eselect' then
	  //setfield($+1,getfield($,omod),omod)
	  //setfield($-1,1,omod)
	  //setfield($-2,1,omod)
	  omod.nmode = 1;
	else
	  omod.nmode=0;
	end
	if omod.iskey['nmode'] == %f then omod.nmode=0;end 
	o.model= omod
	scs_m_new.objs(i)=o
      elseif o.type=='Link' then
	// updates links 
	if size(o.from,'*')==2 then o.from(3)=0;end
	if size(o.to,'*')==2 then o.to(3)=1;end
	scs_m_new.objs(i)=o
      end
    end
  endfunction

  function scs_m_new=do_version272(scs_m)
  // update to 2.7.2
    scs_m_new=scs_m
    scs_m_new.version='scicos2.7.2';
    for i=1:length(scs_m.objs)
      if scs_m.objs(i).type <> 'Block' then continue;end 
      graphic=scs_m.objs(i).graphics
      if graphic.iskey['in_implicit'] & 
	size(graphic.in_implicit,'*')==size(graphic.pin,'*') then 
	in_implicit=graphic.in_implicit;
      else    
	I='E';
	in_implicit=I(ones(size(graphic.pin(:))));
      end
      if graphic.iskey['out_implicit'] & 
	size(graphic.out_implicit,'*')==size(graphic.pout,'*') then
	out_implicit=graphic.out_implicit
      else
	I='E';
	out_implicit=I(ones(size(graphic.pout(:))));
      end
      ng = scicos_graphics(graphic(:));
      ng.in_implicit=   in_implicit;
      ng.out_implicit=  out_implicit;
      scs_m_new.objs(i).graphics= ng;
      sim= scs_m_new.objs(i).model.sim;
      if sim.equal['super'] || sim.equal['csuper'] then
	rpar=do_version272(scs_m_new.objs(i).model.rpar)
	scs_m_new.objs(i).model.rpar=rpar 
      end
    end
  endfunction

  function scs_m_new=do_version271(scs_m)
  // upadte to 2.7.1
    scs_m_new=scs_m;
    scs_m_new.version='scicos2.7.1';
    for i=1:length(scs_m.objs)
      o=scs_m.objs(i);
      if o.type <> 'Block' then continue;end 
      omod=o.model;
      omod.nzcross = 0;
      if omod.sim.equal['super'] || omod.sim.equal['csuper'] then
	rpar=do_version271(omod.rpar)
	omod.nzcross=0;
	omod.rpar=rpar
      elseif omod.sim.equal['zcross'] then
	omod.nzcross = omod.in;
	omod.sim=list(omod.sim,1)
      elseif omod.sim.equal['lusat'] then
	omod.nzcross = 2*omod.in;
	omod.sim=list(omod.sim,1)
      end
      o.model= omod
      scs_m_new.objs(i)=o
    end
  endfunction

  function scs_m_new=do_version27(scs_m)
  // update to 2.7 version 
  // Note that in nsp it is possible to access to hash 
  // table elements with indices (the associated key to indice i is H.__keys(i))
  // but note that the __keys order in a hash table can change ..
  // Thus the following function can have bad behaviour since it 
  // uses indices. 
    
    function  gr_i=convert_gri(name,gri)
    // updates the gr_i part 
      gr_i=gri;
      names=['BIGSOM_f','CONST_f','CURV_f','EVTDLY_f', 'EVTGEN_f',...
	     'GAIN_f','LOOKUP_f','REGISTER_f','SWITCH_f','EXPBLK_f', ...
	     'POWBLK_f'];
      if isempty(find(name==names)) then return;end
      cmd=sprintf('o=%s(''define'');',name);
      ok=execstr(cmd,errcatch=%t);
      if ~ok then
	gr_i='xstringb(orig(1),orig(2),''undefined'',sz(1),sz(2),''fill'');'
	lasterror();
      end;
      gr_i=o.graphics.gr_i(1);
    endfunction
    
    if scs_m.type =='diagram' then 
      scs_m_new=scs_m;
      scs_m_new.version="scicos2.7";
      for k=1:length(scs_m_new.objs)
	if scs_m_new.objs(k).type =='Link' then
	  o=scs_m_new.objs(k)
	  if size(o.from,'*')==2 then o.from(3)=0,end
	  if size(o.to,'*')==2 then o.to(3)=1,end
	  scs_m_new.objs(k)=o
	end
      end
      return;
    end
    scs_m_new=scicos_diagram()
    scs_m_new.version="scicos2.7";
    tf=scs_m(1)(4)
    if isempty(tf) then tf=100;end
    tol=scs_m(1)(3)
    if size(tol,'*')<4 then tol(4)=tf+1,end
    if size(tol,'*')<5 then tol(5)=0,end
    if size(tol,'*')<6 then tol(6)=0,end
    
    scs_m_new.props=scicos_params(wpar=scs_m(1)(1),title=scs_m(1)(2),
    tol=tol,tf=tf,
    context=scs_m(1)(5),options=scs_m(1)(7),
    doc=scs_m(1)(10))

    if isempty(scs_m(1)(7).Background) then 
      scs_m_new.props.options.Background=[8 1]
    end
    scs_m_new.objs(1)=mlist('Deleted') // not to change the internal numbering
    n=length(scs_m)
    back_col=8   //white background
    
    for i=2:n ; //loop on objects
      o=scs_m(i);
      if o(1)=='Block' then
	if size(o(2)) > 8 then
	  if type(o(2)(9))==15 then 
	    gr_io=o(2)(9)(1);
	    if ~isempty(o(2)(9)(2)) then
	      back_col=o(2)(9)(2);,
	    end
	  else
	    gr_io=o(2)(9);
	    back_col=8
	  end
	  gr_i=convert_gri(o(5),gr_io);
	  if isempty(gr_i) then gr_i=gr_io;, end
	elseif size(o(2)) < 9 then
	  gr_i=[];
	  back_col=8
	end
	gr_i=list(gr_i,back_col)
	
	mdl=o(3);
	if size(o(3))<=12 then 
	  mdl(13)=''; mdl(14)=[] ; mdl(15)='';
	elseif size(o(3))<=13 then 
	  mdl(14)=[] ; mdl(15)='';
	elseif size(o(3))<=14 then 
	  mdl(15)='';
	end
	
	if mdl(1)(1).equal['super'] || mdl(1)(1).equal['csuper'] then
	  if type(mdl(8))==15 then
	    mdl(8)=do_version27(mdl(8))
	  end
	end

	graphics=scicos_graphics(orig=o(2)(1),sz=o(2)(2),flip=o(2)(3),
	exprs=o(2)(4),pin=o(2)(5),pout=o(2)(6),
	pein=o(2)(7),peout=o(2)(8),gr_i=gr_i,
	id=mdl(15)) 	       
	
	
	model=scicos_model(sim=mdl(1),in=mdl(2),out=mdl(3),evtin=mdl(4),
	evtout=mdl(5),state=mdl(6),dstate=mdl(7),
	rpar=mdl(8),ipar=mdl(9),blocktype=mdl(10),
	firing=mdl(11),dep_ut=mdl(12),label=mdl(13))

	
	objsi=scicos_block(graphics=graphics,model=model,gui=o(5),
	doc=mdl(14))
	if objsi.gui=='ESELECT_f' then objsi.model.sim(2)=-2,end
	scs_m_new.objs(i)=objsi
	
      elseif o(1)=='Link' then
	// update Link 
	from=o(8);from(3)=0;
	to=o(9);to(3)=1;
	
	objsi=scicos_link(xx=o(2),yy=o(3),id=o(5),thick=o(6),
	ct=o(7),from=from,to=to)
	scs_m_new.objs(i)=objsi
      elseif o(1)=='Text' then
	// update Text object 
	objsi=TEXT_f('define')
	objsi.model.rpar=o(3)(8)
	objsi.model.ipar=o(3)(9)
	objsi.graphics.orig=o(2)(1)
	objsi.graphics.sz=o(2)(2)
	objsi.graphics.exprs=o(2)(4)
	scs_m_new.objs(i)=objsi
      elseif o(1)=='Deleted' then
	scs_m_new.objs(i)=tlist('Deleted')
      end
    end
    resume(%cpr=list(),edited=%t); // doit etre enleve
  endfunction


  function scs_m=do_version251(scs_m)
  // update to 2.5.1 
    obsolete=%f
    for k=1:length(scs_m.objs)
      o=scs_m.objs(k)
      if o.type=='Block' then
	model=o(3)
	if model(1).equal['super'] || model(1).equal['csuper'] then
	  model(8)=do_version251(model(8))
	  o(3)=model;
	  scs_m.objs(k)=o
	elseif o(5).equal['SOM_f'] then
	  if and(model(8)==1) then
	    model(8)=[]
	    model(1)=list('plusblk',2) 
	    scs_m(k)(3)=model
	    scs_m(k)(5)='SUM_f'
	  else
	    scs_m(k)(3)(1)=list('sum',2) 
	    obsolete=%t
	  end
	elseif o(5).equal['AFFICH_f'] then  
	  scs_m(k)(3)(7)=[0;-1;0;0;1;1];
	  no=AFFICH_f('define');
	  scs_m(k)(2)(9)=no.graphics.gr_i(1);
	elseif o(5).equal['c_block'] then
	  model(1)(2)=model(1)(2)-int(model(1)(2)/1000)*1000+2000
	  scs_m(k)(3)=model
	  tt=scs_m(k)(2)(4)(2)
	  ii=grep(tt,'machine.h')
	  if size(ii,'*')==1 then 
	    tt(ii)='#include <machine.h>',
	    scs_m(k)(2)(4)(2)=tt
	  end
	end
      elseif o(1).equal["Link"] then
	if size(o(2),'*')==1 then
	  o(2)=o(2)*[1;1];o(3)=o(3)*[1;1];
	  scs_m(k)=o
	end
      end
    end
    if obsolete then
      message(['Diagram contains obsolete signed blocks sum'
	       'They are drawn in brown, they work as before but,'
	       'please replace them with the new block sum'])
    end  
  endfunction

  function scs_m=do_version231(scs_m)
  //2.3.1 to 2.4 version
    if size(scs_m(1))<5 then scs_m(1)(5)=' ',end  //compatibility
    if type(scs_m(1)(5))<>10 then scs_m(1)(5)=' ',end //compatibility
    if size(scs_m(1))<6 then //compatibility
      wpar=scs_m(1)
      wpar(6)=list()
      wpar(7)=list(%t,[0.8 0.8 0.8])
      wpar(8)=[]
      wpar(9)=[]
      wpar(10)=[]
      scs_m(1)=wpar
    end
    if size(scs_m(1)(1),'*') <4 then scs_m(1)(1)=[scs_m(1)(1),0,0],end //compatibility

    scs_m(1)(1)(2)=max(scs_m(1)(1)(2),450)
    if size(scs_m(1))<6 then 
      options=scicos_options()
      doc=list() //documentation structure
      wpar=scs_m(1)
      wpar(6)=list()
      wpar(7)=options
      wpar(8)=[]
      wpar(9)=[]
      wpar(10)=doc
      scs_m(1)=wpar
    end
    wsiz=scs_m(1)(1)
    if size(wsiz,'*')<6 then //compatibility
      if size(wsiz,'*')<4 then wsiz(3)=0;wsiz(4)=0;end
      wsiz(5)=wsiz(1);wsiz(6)=wsiz(2);
      scs_m(1)(1)=wsiz;
    end
    if type(scs_m(1)(7))==15 then //options 
      old_opt=scs_m(1)(7)
      options=scicos_options()
      options('3D')(1)=old_opt(1)
      options('Cmap')=old_opt(2)
      scs_m(1)(7)=options
    end

    nx=size(scs_m)
    for k=2:nx
      o=scs_m(k)
      if o(1)=='Block' then
	model=o(3)
	if model(1)=='super'|model(1)=='csuper' then
	  model(8)=do_version231(model(8))
	  o(3)=model
	  scs_m(k)=o
	elseif model(1)(1)=='ifthel' then
	  model(1)=list('ifthel',-1)
	  scs_m(k)(3)=model
	elseif model(1)(1)=='eselect' then
	  model(1)=list('eselect',-1)
	  scs_m(k)(3)=model  
	end
      end
    end
  endfunction

  function x_new=do_version23(scs_m)
  //2.3 to 2.3.1

    function o=block2_version(o)
      if ~isempty(o(3)(6)) then o(3)(12)(2)=%t;end
    endfunction

    x_new=list()
    x_new(1)=scs_m(1)
    nx=size(scs_m)
    for k=2:nx
      o=scs_m(k)
      if o(1)=='Link' then
      elseif o(1)=='Block' then
	model=o(3)
	if model(1)=='super'|model(1)=='csuper' then
	  model(8)=do_version23(model(8))
	  o(3)=model
	  o=block2_version(o)
	  scs_m(k)=o
	else
	  o=block2_version(o)
	end
      end
      x_new(k)=o;
    end
  endfunction

  function x_new=do_version22(scs_m)
  // 
    function o=replace_firing(o)
      firing=o(3)(11)
      cout=o(3)(5)
      if firing==%f|firing==0 then 
	o(3)(11)=-ones(size(cout))
	//printf('firing changed from %f to '+sci2exp(o(3)(11))+' in '+o(3)(1)(1))
      elseif firing==%t|firing==1  then 
	o(3)(11)=0*cout
	//printf('firing changed from %t to '+sci2exp(o(3)(11))+' in '+o(3)(1)(1))  
      elseif isempty(firing) then
	o(3)(11)=[]
      else
	write(%io(2),'Problem with block '+o(3)(1)(1)); pause 
      end
    endfunction
    
    function o=block_version(o)
      [graphics,model]=o(2:3)
      for k=2:5, model(k)=ones_new(model(k),1),end
      blocktype=o(5)
      ok=%t
      label=' '
      gr_i=' '
      select blocktype
       case 'ABSBLK_f' then
	model(2)=-1
	model(3)=-1
	label=' '
	gr_i='xstringb(orig(1),orig(2),''abs'',sz(1),sz(2),''fill'')'
       case 'ANIMXY_f' then
	[rpar,ipar]=model([8:9])
	model(9)=[model(9);0;[-1;-1];[-1;-1]]
	win=ipar(1);N=ipar(3);clrs=ipar(4);siz=ipar(5)
	xmin=rpar(1);xmax=rpar(2);ymin=rpar(3);ymax=rpar(4)
	label=[string(clrs);
	       string(siz);
	       string(win);
	       '[]';
	       '[]';
	       string(xmin);
	       string(xmax);
	       string(ymin);
	       string(ymax);
	       string(N)]
	gr_i=['t=(0:0.3:2*%pi)'';';
	      'xx=orig(1)+(1/5+(cos(2.2*t)+1)*3/10)*sz(1);';
	      'yy=orig(2)+(1/4.3+(sin(t)+1)*3/10)*sz(2);';
	      'xpoly(xx,yy,thickness=2);'];
       case 'BOUND_f' then
	rpar=model(8);in=model(2);nin=sum(in)
	if nin<>1 then 
	  write(%io(2),['Pb with BOUND_f block';
			'previously block has more than one input port';
			'It is better to change it with the new block version';
			'preceded by a multiplexer'])
	end
	thresh=rpar(1:nin),v=rpar(nin+1:2*nin)
	label=[strcat(sci2exp(thresh));
	       strcat(sci2exp(v))]
	gr_i=['thick=xget(''thickness'');xset(''thickness'',2);';
	      'xx=orig(1)+[1/5;1/2;1/2;1-1/5]*sz(1);';
	      'yy=orig(2)+[1/2;1/2;1-1/5;1-1/5]*sz(2);';
	      'xpoly(xx,yy);';
	      'xset(''thickness'',1);';
	      'xpoly(orig(1)+[1/9;1/5]*sz(1),orig(2)+[1/2;1/2]*sz(2));';
	      'xpoly(orig(1)+[1/2;1-1/9]*sz(1),orig(2)+[1/2;1/2]*sz(2));';
	      'xpoly(orig(1)+[1/2;1/2]*sz(1),orig(2)+[1/9;1/2]*sz(2));';
	      'xpoly(orig(1)+[1/2;1/2]*sz(1),orig(2)+[1-1/5;1-1/9]*sz(2));';
	      'xset(''thickness'',thick);']
       case 'CLINDUMMY_f' then
	label=[]
	gr_i=['xstringb(orig(1),orig(2),[''DUMMY'';''CLSS''],sz(1),sz(2),''fill'');']
       case 'CLKIN_f' then
	prt=model(9);
	label=string(prt)
	gr_i=[]
       case 'CLKOUT_f' then
	prt=model(9);
	label=string(prt)
	gr_i=[]
       case 'CLKSPLIT_f' then
	label=[]
	gr_i=[]
       case 'CLKSOM_f' then
	label=[]
	gr_i=[]
       case 'CLOCK_f' then
	orig=o(2)(1)
	sz=o(2)(2)
	oo=o(3)(8)
	dt=0.1
	for ko=2:size(oo)
	  if oo(ko)(3)(1)=='evtdly' then
	    dt=oo(ko)(3)(8)
	    break
	  end
	end
	o = list('Block',
	list([0,0],[2,2],%t,[],[],[],[],0,
	list(
	['wd=xget(''wdim'').*[1.016,1.12];';
	 'thick=xget(''thickness'');xset(''thickness'',2);';
	 'p=wd(2)/wd(1);p=1;';
	 'rx=sz(1)*p/2;ry=sz(2)/2;';
	 'xarcs([orig(1)+0.05*sz(1);';
	 'orig(2)+0.95*sz(2);';
	 '   0.9*sz(1)*p;';
	 '   0.9*sz(2);';
	 '   0;';
	 '   360*64],scs_color(5));';
	 'xset(''thickness'',1);';
	 'xx=[orig(1)+rx    orig(1)+rx;';
	 '    orig(1)+rx    orig(1)+rx+0.6*rx*cos(%pi/6)];';
	 'yy=[orig(2)+ry    orig(2)+ry ;';
	 '  orig(2)+1.8*ry  orig(2)+ry+0.6*ry*sin(%pi/6)];';
	 'xsegs(xx,yy,scs_color(10));';
	 'xset(''thickness'',thick);'],[])),
	list('csuper',[],[],[],1,[],' ',
	list(list([600,400,0,0],'foo',[],[]),
	list('Block',list([399,162],[20,20],%t,'1',[],[],6,[],[]),
	list('output',[],[],1,[],[],[],[],1,'d',[],[%f,%f],' ',list()),' ','CLKOUT_f'),
	list('Block',list([320,232],[40,40],%t,['0.1';'0.1'],[],[],7,4,
	['dt=model(8);';
	 'txt=[''Delay'';string(dt)];';
	 'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'');']),
	list('evtdly',[],[],1,1,[],[],0.1,[],'d',0.1,[%f,%f],' ',list()),' ','EVTDLY_f'),
	list('Link',[340;340;380.71066],[226.28571;172;172],'drawlink',' ',[0,0],[5,-1],[3,1],
	[5,1]),
	list('Block',list([380.71066;172],[1,1],%t,' ',[],[],4,[6;7]),
	list('lsplit',[],[],1,[1;1],[],[],[],[],'d',[-1,-1],[%t,%f],' ',list()),' ','CLKSPLIT_f'),
	list('Link',[380.71066;399],[172;172],'drawlink',' ',[0,0],[5,-1],[5,1],[2,1]),
	list('Link',[380.71066;380.71066;340;340],[172;301.9943;301.9943;277.71429],'drawlink',' ',
	[0,0],[5,-1],[5,2],[3,1])),[],'h',[],[%f,%f]),' ','CLOCK_f')

	o(2)(1)=orig
	o(2)(2)=sz
	xx=o(3)(8)(3)
	xx(2)(4)=string([dt;dt])
	xx(3)(11)=dt
	xx(3)(8)=dt
	o(3)(8)(3)=xx
	model=o(3)
      else
	ok=%f
      end

      if ok then
	graphics(4)=label
	graphics(9)=gr_i
	o(2)=graphics
	model(13)=' ';model(14)=list()
	o(3)=model
	o=replace_firing(o)
	return
      end

      ok=%t
      select blocktype
       case 'CLR_f' then
	ipar=model(9);model(9)=[]
	ns=size(model(6),'*');nin=1;nout=1;
	rpar=model(8);
	A=matrix(rpar(1:ns*ns),ns,ns);
	B=matrix(rpar(ns*ns+1:ns*(ns+nin)),ns,nin);
	C=matrix(rpar(ns*(ns+nin)+1:ns*(ns+nin+nout)),nout,ns);
	D=rpar(ns*(ns+nin+nout)+1);
	H=ss2tf(syslin('c',A,B,C,D));
	H=clean(H);
	if type(H)==16 then
	  num=H(2);den=H(3)
	else
	  num=H,den=1
	end
	label=[sci2exp(num);sci2exp(den)]
	gr_i=['xstringb(orig(1),orig(2),[''Num(s)'';''-----'';''Den(s)''],sz(1),sz(2),''fill'');']
       case 'CLSS_f' then
	in=model(2);out=model(3)
	nin=sum(in)
	nout=sum(out)
	x0=model(6),
	rpar=model(8)
	ns=prod(size(x0))
	A=matrix(rpar(1:ns*ns),ns,ns)
	B=matrix(rpar(ns*ns+1:ns*(ns+nin)),ns,nin)
	C=matrix(rpar(ns*(ns+nin)+1:ns*(ns+nin+nout)),nout,ns)
	D=matrix(rpar(ns*(ns+nin+nout)+1:ns*(ns+nin+nout)+(nin*nout)),nout,nin)
	label=[  strcat(sci2exp(A));
		 strcat(sci2exp(B));
		 strcat(sci2exp(C));
		 strcat(sci2exp(D));
		 strcat(sci2exp(x0))]
	gr_i=['txt=[''xd=Ax+Bu'';''y=Cx+Du''];';
	      'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'');']
	model(2)=nin;model(3)=nout
       case 'CONST_f' then
	C=model(8);model(3)=sum(model(3))
	label=[strcat(sci2exp(C))]
	gr_i=['model=arg1(3);C=model(8);';
	      'dx=sz(1)/5;dy=sz(2)/10;';
	      'w=sz(1)-2*dx;h=sz(2)-2*dy;';
	      'xstringb(orig(1)+dx,orig(2)+dy,string(C),w,h,''fill'');']
       case 'COSBLK_f' then
	in=model(2);nin=sum(in)
	if nin<>1 then 
	  write(%io(2),['Pb with COSBLK_f block';
			'previously block has more than one input port';
			'It is better to change it with the new block version';
			'preceded by a multiplexer and followed by a demultiplxer'])
	end
	label=' '
	gr_i=['xstringb(orig(1),orig(2),[''cos''],sz(1),sz(2),''fill'');']
       case 'CURV_f' then
	label=[]
	gr_i=['model=arg1(3);rpar=model(8);ipar=model(9);n=ipar(1);';
	      'thick=xget(''thickness'');xset(''thickness'',2);';
	      'xx=rpar(1:n);yy=rpar(n+1:2*n);';
	      'rect=rpar(2*n+1:2*n+4);';
	      'mxx=rect(3)-rect(1);';
	      'mxy=rect(4)-rect(2);';
	      'xx=orig(1)+sz(1)*(1/10+(4/5)*((xx-rect(1))/mxx));';
	      'yy=orig(2)+sz(2)*(1/10+(4/5)*((yy-rect(2))/mxy));';
	      'xpoly(xx,yy);';
	      'xset(''thickness'',thick);']
       case 'DELAY_f' then
	orig=o(2)(1)
	sz=o(2)(2)
	oo=o(3)(8)
	dt=[];z0=[]
	for ko=2:size(oo)
	  if oo(ko)(3)(1)=='evtdly' then
	    dt=oo(ko)(3)(8)
	  elseif oo(ko)(3)(1)=='register' then
	    z0=oo(ko)(3)(7)
	  end
	end
	if isempty(dt)| isempty(z0) then
	  write(%io(2), 'Pb with DELAY_f block dt or z0 not found'); pause
	end
	o=DELAY_f('define')
	o(2)(1)=orig
	o(2)(2)=sz
	o(3)(8)(4)(2)(4)=sci2exp(z0)
	o(3)(8)(5)(2)(4)=sci2exp(dt)
	o(3)(8)(5)(3)(8)=dt
	o(3)(8)(5)(3)(11)=0
	o(3)(8)(4)(3)(7)=z0(:)
	model=o(3)
	label=[]
	gr_i=['b1=xstringl(0,0,''e'');';
	      'b2=xstringl(0,0,''-Ts'');';
	      'h=-b1(2)+max(0,sz(2)-0.5*b1(4)+b2(4))/2;';
	      'w=max(0,sz(1)-b1(3)-b1(4))/2;';
	      'xstring(orig(1)+w,orig(2)+h,''e'');';
	      'xstring(orig(1)+w+b1(3)/2,orig(2)+h+b1(4)*0.5,''-Ts'');']
       case 'DLRADAPT_f' then
	[dstate,rpar,ipar]=model(7:9)
	m=ipar(1);
	n=ipar(2)
	npt=ipar(3)
	p=rpar(1:npt)

	rn=matrix(rpar(npt+1:npt+m*npt)+%i*rpar(npt+m*npt+1:npt+2*m*npt),npt,m)
	rd=matrix(rpar(npt+2*m*npt+1:npt+(2*m+n)*npt)+
	%i*rpar(npt+(2*m+n)*npt+1:npt+2*(m+n)*npt),npt,n)
	g=rpar(npt+2*(m+n)*npt+1:npt+2*(m+n)*npt+npt)
	last_u=dstate(1:m);last_y=dstate(m+1:m+n)
	label=[sci2exp(p);
	       sci2exp(rn);
	       sci2exp(rd);
	       sci2exp(g);
	       sci2exp(last_u);
	       sci2exp(last_y)]
	gr_i=['txt=[''N(z,p)'';''-----'';''D(z,p)''];';
	      'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'');']
       case 'DLR_f' then
	model(9)=[];model(10)='d'
	ns=size(model(7),'*');nin=1;nout=1;
	rpar=model(8);
	A=matrix(rpar(1:ns*ns),ns,ns);
	B=matrix(rpar(ns*ns+1:ns*(ns+nin)),ns,nin);
	C=matrix(rpar(ns*(ns+nin)+1:ns*(ns+nin+nout)),nout,ns);
	D=rpar(ns*(ns+nin+nout)+1);
	H=ss2tf(syslin('d',A,B,C,D));
	H=clean(H);
	if type(H)==16 then
	  num=H(2);den=H(3)
	else
	  num=H,den=1
	end
	label=[sci2exp(num);sci2exp(den)]
	gr_i=['txt=[''Num(z)'';''-----'';''Den(z)''];';
	      'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'');']
       case 'DLSS_f' then
	in=model(2);out=model(3)
	nin=sum(in)
	nout=sum(out)
	x0=model(6),rpar=model(8)
	ns=prod(size(x0))
	A=matrix(rpar(1:ns*ns),ns,ns)
	B=matrix(rpar(ns*ns+1:ns*(ns+nin)),ns,nin)
	C=matrix(rpar(ns*(ns+nin)+1:ns*(ns+nin+nout)),nout,ns)
	D=matrix(rpar(ns*(ns+nin+nout)+1:ns*(ns+nin+nout)+(nin*nout)),nout,nin)

	label=[  strcat(sci2exp(A));
		 strcat(sci2exp(B));
		 strcat(sci2exp(C));
		 strcat(sci2exp(D));
		 strcat(sci2exp(x0))]
	gr_i=['txt=[''x+=Ax+Bu'';''y=Cx+Du''];';
	      'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'');']
       case 'EVENTSCOPE_f' then
	[nclock,rpar,ipar]=model([4 8 9])
	win=ipar(1);
	per=rpar(1);
	wdim=[-1;-1]
	wpos=[-1;-1]
	clrs=[1;3;5;7;9;11;13;15];
	model(9)=[win;1;clrs;wpos(:);wdim(:)]
	label=[sci2exp(nclock);
	       strcat(sci2exp(clrs),' ');
	       string(win);
	       sci2exp([]);
	       sci2exp([]);
	       string(per)]
	gr_i=['thick=xget(''thickness'');xset(''thickness'',2);';
	      'xrect(orig(1)+sz(1)/10,orig(2)+(1-1/10)*sz(2),sz(1)*8/10,sz(2)*8/10);';
	      'xx=[orig(1)+sz(1)/5,orig(1)+sz(1)/5;';
	      'orig(1)+(1-1/5)*sz(1),orig(1)+sz(1)/5];';
	      'yy=[orig(2)+sz(2)/5,orig(2)+sz(2)/5;';
	      'orig(2)+sz(2)/5,orig(2)+(1-1/5)*sz(2)];';
	      'xarrows(xx,yy);';
	      't=(0:0.3:2*%pi)'';';
	      'xx=orig(1)+(1/5+3*t/(10*%pi))*sz(1);';
	      'yy=orig(2)+(1/4.3+(sin(t)+1)*3/10)*sz(2);';
	      'xpoly(xx,yy);';
	      'xset(''thickness'',thick);']
       case 'EVTDLY_f' then
	dt=model(8);
	if model(11) then ff=0; else ff=-1; end
	model(11)=ff
	label=[string(dt);string(ff)]
	gr_i=['dt=model(8);';
	      'txt=[''Delay'';string(dt)];';
	      'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'');']
       case 'EVTGEN_f' then
	tt=model(11);
	label=string(tt)
	gr_i=['xstringb(orig(1),orig(2),''Event'',sz(1),sz(2),''fill'');']
       case 'FOR_f' then
	write(%io(2),'FOR block nor more exist')
      else
	ok=%f
      end
      if ok then
	graphics(4)=label
	graphics(9)=gr_i
	o(2)=graphics
	model(13)=' ';model(14)=list()
	o(3)=model
	o=replace_firing(o)
	return
      end
      ok=%t
      select blocktype
       case 'GAIN_f' then
	[in,out]=model(2:3)
	gain=matrix(model(8),out,in)
	label=[strcat(sci2exp(gain))]
	gr_i=['[nin,nout]=model(2:3);';
	      'if nin*nout==1 then gain=string(model(8)),else gain=''Gain'',end';
	      'dx=sz(1)/5;';
	      'dy=sz(2)/10;';
	      'xx=orig(1)+      [1 4 1 1]*dx;';
	      'yy=orig(2)+sz(2)-[1 5 9 1]*dy;';
	      'xpoly(xx,yy);';
	      'w=sz(1)-2*dx;h=sz(2)-2*dy;';
	      'xstringb(orig(1)+dx,orig(2)+dy,gain,w,h,''fill'');']
       case 'GENERAL_f' then
	in=model(2);out=model(5)
	label=[strcat(sci2exp(in));strcat(sci2exp(out))]
	gr_i=['xstringb(orig(1),orig(2),''GENERAL'',sz(1),sz(2),''fill'');']
       case 'GENSIN_f' then
	rpar=model(8)
	label=[string(rpar(1));string(rpar(2));string(rpar(3))]
	gr_i=['txt=[''sinusoid'';''generator''];';
	      'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'');']
       case 'GENSQR_f' then
	//rpar=model(8); ?
	Amplitude=model(7)
	label=string(Amplitude)
	gr_i=['txt=[''square wave'';''generator''];';
	      'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'');']
       case 'HALT_f' then
	n=model(9);
	label=string(n)
	gr_i=['xstringb(orig(1),orig(2),''STOP'',sz(1),sz(2),''fill'');']
       case 'IFTHEL_f' then
	label=[]
	model(11)=[-1,-1]
	gr_i=['txt=[''If in>=0'';'' '';'' then    else''];';
	      'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'');']
       case 'INTEGRAL_f' then
	x0=model(6);
	label=strcat(sci2exp(x0))
	gr_i=['xstringb(orig(1),orig(2),''  1/s  '',sz(1),sz(2),''fill'');']
       case 'INVBLK_f' then
	model(2)=-1;model(3)=-1
	label=' '
	gr_i=['xstringb(orig(1),orig(2),''1/u'',sz(1),sz(2),''fill'');']
       case 'IN_f' then
	prt=model(9);
	label=[string(prt)]
	model(3)=-1
	gr_i=[]
       case 'LOGBLK_f' then
	a=model(8)
	in=model(2)
	label=[string(a)]
	model(2)=-1;model(3)=-1
	gr_i=['xstringb(orig(1),orig(2),''log'',sz(1),sz(2),''fill'');']
       case 'LOOKUP_f' then
	model(10)='c'
	gr_i=['rpar=model(8);n=size(rpar,''*'')/2;';
	      'thick=xget(''thickness'');xset(''thickness'',2);';
	      'xx=rpar(1:n);yy=rpar(n+1:2*n);';
	      'mnx=min(xx);xx=xx-mnx*ones(size(xx));mxx=max(xx);';
	      'xx=orig(1)+sz(1)*(1/10+(4/5)*xx/mxx);';
	      'mnx=min(yy);yy=yy-mnx*ones(size(yy));mxx=max(yy);';
	      'yy=orig(2)+sz(2)*(1/10+(4/5)*yy/mxx);';
	      'xpoly(xx,yy);';
	      'xset(''thickness'',thick);']
	label=[]
       case 'MAX_f' then
	in=model(2);nin=sum(in)
	if nin<>1 then 
	  write(%io(2),['Pb with MAX_f block';
			'previously block has more than one input port';
			'It is better to change it with the new block version';
			'preceded by a multiplexer'])
	end
	label=' '
	gr_i=['xstringb(orig(1),orig(2),''Max'',sz(1),sz(2),''fill'');']
       case 'MCLOCK_f' then
	label=[]
	gr_i=['txt=[''2freq clock'';''  f/n     f''];';
	      'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'')']
       case 'MFCLCK_f' then
	dt=model(8)
	nn=model(9)  
	label=[string(dt);string(nn)]
	gr_i=['txt=[''M. freq'';''clock''];';
	      'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'')']
       case 'MIN_f' then
	in=model(2);nin=sum(in)
	if nin<>1 then 
	  write(%io(2),['Pb with MIN_f block';
			'previously block has more than one input port';
			'It is better to change it with the new block version';
			'preceded by a multiplexer'])
	end
	label=' '
	gr_i=['xstringb(orig(1),orig(2),''MIN'',sz(1),sz(2),''fill'')']
       case 'NEGTOPOS_f' then
	label=[]
	gr_i=['xstringb(orig(1),orig(2),'' - to + '',sz(1),sz(2),''fill'');']
       case 'OUT_f' then
	prt=model(9);
	model(2)=-1
	label=[string(prt)]
	gr_i=[]
       case 'POSTONEG_f' then
	label=[]
	gr_i=['xstringb(orig(1),orig(2),'' + to - '',sz(1),sz(2),''fill'')']
       case 'POWBLK_f' then
	in=model(2);nin=sum(in)
	if nin<>1 then 
	  write(%io(2),['Pb with MIN_f block';
			'previously block has more than one input port';
			'It is better to change it with the new block version';
			'preceded by a multiplexer and followed by a demux'])
	end
	if ~isempty(model(8)) then
	  a=model(8)
	else
	  a=model(9)
	end
	in=model(2)
	label=[string(a)]
	gr_i=['xstringb(orig(1),orig(2),''u^a'',sz(1),sz(2),''fill'');']
       case 'PROD_f' then
	label=[]
	gr_i=[]
	model(1)=list('prod',2)
       case 'QUANT_f' then
	rpar=model(8);ipar=model(9);
	pas=rpar(1)
	meth=ipar
	label=[string(pas);string(meth)]
	gr_i=['thick=xget(''thickness'');xset(''thickness'',2);';
	      'xx=orig(1)+[1;2;2;3;3;4;4]/5*sz(1);';
	      'yy= orig(2)+[1;1;2;2;3;3;4]/5*sz(2);';
	      'xpoly(xx,yy);';
	      'xset(''thickness'',thick);']
       case 'RAND_f' then
	rpar=model(8);flag=model(9);
	out=model(3);nout=sum(out)
	if nout<>1 then 
	  write(%io(2),['Pb with RAND_f block';
			'previously block has more than one output port';
			'It is better to change it with the new block version';
			' followed by a demux'])
	end

	a=rpar(1:nout)
	b=rpar(nout+1:2*nout)
	label=[string(flag);sci2exp(a(:));sci2exp(b(:))]
	gr_i=['txt=[''random'';''generator''];';
	      'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'')']
       case 'REGISTER_f' then
	z0=model(7)
	label=strcat(string(z0),';')

	gr_i=['dly=model(8);';
	      'txt=[''Shift'';''Register'';string(dly)];';
	      'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'')']
      else
	ok=%f
      end
      if ok then
	graphics(4)=label
	graphics(9)=gr_i
	o(2)=graphics
	model(13)=' ';model(14)=list()
	o(3)=model
	o=replace_firing(o)
	return
      end
      ok=%t
      select blocktype
       case 'RFILE_f' then
	[out,state,ipar]=model([3 7 9])
	nout=sum(out)
	ievt=ipar(3);N=ipar(4);
	imask=5+ipar(1)+ipar(2)
	if ievt<>0 then tmask=ipar(imask),else tmask=[],end
	outmask=ipar(imask+ievt:imask+nout+ievt-1)
	lunit=state(2)
	ievt=ipar(3);N=ipar(4);
	imask=5+ipar(1)+ipar(2)
	if ievt<>0 then tmask=ipar(imask),else tmask=[],end
	outmask=ipar(imask+ievt:imask+nout+ievt-1)
	lfil=ipar(1)
	lfmt=ipar(2)
	if lfil>0 then fname=scilab_code2str(ipar(5:4+lfil)),else fname=' ',end
	if lfmt>0 then Fmt=scilab_code2str(ipar(5+lfil:4+lfil+lfmt)),else Fmt=' ',end
	label=[ sci2exp(tmask);
		sci2exp(outmask);
		fname;
		Fmt;
		string(N);
		sci2exp(out)]
	gr_i=['txt=[''read from'';''input file''];';
	      'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'')']
       case 'SAT_f' then
	rpar=model(8)
	minp=rpar(1),maxp=rpar(2),pente=rpar(3)
	label=[string(minp);string(maxp);string(pente)]

	gr_i=['thick=xget(''thickness'');xset(''thickness'',2);';
	      'xx=orig(1)+[4/5;1/2+1/5;1/2-1/5;1/5]*sz(1);';
	      'yy=orig(2)+[1-1/5;1-1/5;1/5;1/5]*sz(2);';
	      'xpoly(xx,yy);';
	      'xset(''thickness'',thick)']
       case 'SAWTOOTH_f' then
	model(10)='c'
	gr_i=['txt=[''sawtooth'';''generator''];';
	      'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'');']
       case 'SCOPE_f' then
	[in,rpar,ipar]=model([2 8 9])
	in=model(2);nin=sum(in)
	if nin<>1 then 
	  write(%io(2),['Pb with SCOPE_f block';
			'previously block has more than one input port';
			'It is better to change it with the new block version';
			'preceded by a multiplexer'])
	end
	win=ipar(1);N=ipar(3);
	clrs=-ipar(4:nin+3)
	if size(clrs,'*')<8 then clrs(8)=1;end

	wdim=[-1;-1]
	wpos=[-1;-1]
	model(9)=[win;1;N;clrs;wpos(:);wdim(:)]
	dt=rpar(1);ymin=rpar(2);ymax=rpar(3);per=rpar(4)
	label=[strcat(string(clrs),' ');
	       string(win);
	       sci2exp([]);
	       sci2exp([]);
	       string(ymin);
	       string(ymax);
	       string(per);
	       string(N)];
	
	gr_i=['thick=xget(''thickness'');xset(''thickness'',2);';
	      'xrect(orig(1)+sz(1)/10,orig(2)+(1-1/10)*sz(2),sz(1)*8/10,sz(2)*8/10);';
	      'xx=[orig(1)+sz(1)/5,orig(1)+sz(1)/5;';
	      'orig(1)+(1-1/5)*sz(1),orig(1)+sz(1)/5];';
	      'yy=[orig(2)+sz(2)/5,orig(2)+sz(2)/5;';
	      'orig(2)+sz(2)/5,orig(2)+(1-1/5)*sz(2)];';
	      'xarrows(xx,yy);';
	      't=(0:0.3:2*%pi)'';';
	      'xx=orig(1)+(1/5+3*t/(10*%pi))*sz(1);';
	      'yy=orig(2)+(1/4.3+(sin(t)+1)*3/10)*sz(2);';
	      'xpoly(xx,yy);';
	      'xset(''thickness'',thick)']
       case 'SCOPXY_f' then
	[rpar,ipar]=model(8:9)
	win=ipar(1);N=ipar(3);clrs=-ipar(4);siz=ipar(5)
	xmin=rpar(1);xmax=rpar(2);ymin=rpar(3);ymax=rpar(4)
	wdim=[-1;-1]
	wpos=[-1;-1]
	label=[sci2exp(clrs);
	       sci2exp(siz);
	       string(win);
	       sci2exp([]);
	       sci2exp([]);
	       string(xmin);
	       string(xmax);
	       string(ymin);
	       string(ymax);
	       string(N)];
	model(9)=[win;1;N;clrs;siz;1;wpos(:);wdim(:)]
	gr_i=['thick=xget(''thickness'');xset(''thickness'',2);';
	      't=(0:0.2:2*%pi)'';';
	      'xx=orig(1)+(1/5+(cos(3*t)+1)*3/10)*sz(1);';
	      'yy=orig(2)+(1/4.3+(sin(t+1)+1)*3/10)*sz(2);';
	      'xpoly(xx,yy);';
	      'xset(''thickness'',thick)']
       case 'SELECT_f' then
	z0=model(7);nin=size(model(2),1);
	label=[string(nin);string(z0-1)]
	model(1)=list('selector',2)
	gr_i=['xstringb(orig(1),orig(2),''Selector'',sz(1),sz(2),''fill'');']
       case 'SINBLK_f' then
	in=model(2);nin=sum(in)
	if nin<>1 then 
	  write(%io(2),['Pb with MIN_f block';
			'previously block has more than one input port';
			'It is better to change it with the new block version';
			'preceded by a multiplexer and followed by a demux'])
	end
	label=' '
	gr_i=['xstringb(orig(1),orig(2),''sin'',sz(1),sz(2),''fill'')']
       case 'SOM_f' then
	sgn=model(8);
	label=sci2exp(sgn)
	model(1)=list('sum',2)
	gr_i=[]
       case 'SPLIT_f' then
	label=[]
	gr_i=[]
       case 'SUPER_f' then
	label=[]
	gr_i=['thick=xget(''thickness'');xset(''thickness'',2);';
	      'xx=orig(1)+      [2 4 4]*(sz(1)/7);';
	      'yy=orig(2)+sz(2)-[2 2 6]*(sz(2)/10);';
	      'xrects([xx;yy;[sz(1)/7;sz(2)/5]*ones_new(1,3)]);';
	      'xx=orig(1)+      [1 2 3 4 5 6 3.5 3.5 3.5 4 5 5.5 5.5 5.5]*sz(1)/7;';
	      'yy=orig(2)+sz(2)-[3 3 3 3 3 3 3   7   7   7 7 7   7   3  ]*sz(2)/10;';
	      'xsegs(xx,yy,0);';
	      'xset(''thickness'',thick)']
       case 'TANBLK_f' then
	in=model(2);nin=sum(in)
	if nin<>1 then 
	  write(%io(2),['Pb with TANBLK_f block';
			'previously block has more than one input port';
			'It is better to change it with the new block version';
			'preceded by a multiplexer and followed by a demux'])
	end
	label=' '
	gr_i=['xstringb(orig(1),orig(2),''tan'',sz(1),sz(2),''fill'');']
       case 'TCLSS_f' then
	in=model(2);nin=sum(in)
	out=model(3);nout=sum(out)
	x0=model(6),rpar=model(8)
	
	ns=prod(size(x0));nin=nin-ns
	A=matrix(rpar(1:ns*ns),ns,ns)
	B=matrix(rpar(ns*ns+1:ns*(ns+nin)),ns,nin)
	C=matrix(rpar(ns*(ns+nin)+1:ns*(ns+nin+nout)),nout,ns)
	D=matrix(rpar(ns*(ns+nin+nout)+1:ns*(ns+nin+nout)+(nin*nout)),nout,nin)
	nin1=nin;nout1=nout

	label=[strcat(sci2exp(A));
	       strcat(sci2exp(B));
	       strcat(sci2exp(C));
	       strcat(sci2exp(D));
	       strcat(sci2exp(x0))]
	gr_i=['txt=[''Jump'';''(A,B,C,D)''];';
	      'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'')']
      else
	ok=%f
      end
      if ok then
	graphics(4)=label
	graphics(9)=gr_i
	o(2)=graphics
	model(13)=' '
	model(14)=list()
	o(3)=model
	o=replace_firing(o)
	return
      end  
      ok=%t
      select blocktype
       case 'TEXT_f' then
	ipar=model(9)
	font=ipar(1);siz=ipar(2)
	label=[graphics(4);string(font);string(siz)]
	gr_i=[]
       case 'TIME_f' then
	label=[]
	gr_i=['wd=xget(''wdim'').*[1.016,1.12];';
	      'thick=xget(''thickness'');xset(''thickness'',2);';
	      'p=wd(2)/wd(1);p=1;';
	      'rx=sz(1)*p/2;ry=sz(2)/2;';
	      'xarc(orig(1)+0.05*sz(1),orig(2)+0.95*sz(2),0.9*sz(1)*p,0.9*sz(2),0,360*64);';
	      'xset(''thickness'',1);';
	      'xx=[orig(1)+rx    orig(1)+rx;';
	      'orig(1)+rx    orig(1)+rx+0.6*rx*cos(%pi/6)];';
	      'yy=[orig(2)+ry    orig(2)+ry ;';
	      '	  orig(2)+1.8*ry  orig(2)+ry+0.6*ry*sin(%pi/6)];';
	      'xsegs(xx,yy,0);';
	      'xset(''thickness'',thick);']
       case 'TRASH_f' then
	in=model(2);nin=sum(in)
	if nin<>1 then 
	  write(%io(2),['Pb with MIN_f block';
			'previously block has more than one input port';
			'It is better to change it with the new block version';
			'preceded by a multiplexer'])
	end
	label=' '
	gr_i=['xstringb(orig(1),orig(2),''Trash'',sz(1),sz(2),''fill'')']
       case 'WFILE_f' then
	state=model(7)
	[in,ipar]=model([2  9])
	N=ipar(3);
	lunit=state(2)
	N=ipar(4)
	lfil=ipar(1)
	lfmt=ipar(2)
	if lfil>0 then fname=scilab_code2str(ipar(5:4+lfil)),else fname=' ',end
	if lfmt>0 then Fmt=scilab_code2str(ipar(5+lfil:4+lfil+lfmt)),else Fmt=' ',end
	label=[sci2exp(in);
	       fname;
	       Fmt;
	       string(N)]
	
	gr_i=['txt=[''write to'';''output file''];';
	      'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'')']
       case 'ZCROSS_f' then
	in=model(2)
	label=strcat(sci2exp(in))
	gr_i=['xstringb(orig(1),orig(2),''Zcross'',sz(1),sz(2),''fill'');']
       case 'func_block' then
	write(%io(2),['PB with func_block';
		      'version change is not implemented'])
	label=[]
	gr_i=['xstringb(orig(1),orig(2),''Func'',sz(1),sz(2),''fill'');']
       case 'm_sin' then
	rpar=model(8);gain=rpar(1);phase=rpar(2)
	label=[string(gain);string(phase)]
	gr_i=[]
       case 'sci_block' then
	write(%io(2),['PB with sci_block';
		      'version change is not implemented'])
	label=[]
	gr_i=['xstringb(orig(1),orig(2),''Sci_Block'',sz(1),sz(2),''fill'');']
       case 'scifunc_block' then
	write(%io(2),['PB with scifunc_block';
		      'version change is not implemented'])
	i1=model(2);o1=model(3);ci1=model(4);co1=model(5);x1=model(6);
	z1=model(7);auto1=model(11);type_1=model(10);
	tt=model(9),rpar=model(8)
	label=list([sci2exp(i1);sci2exp(o1);sci2exp(ci1);sci2exp(co1);
		    strcat(sci2exp(x1));strcat(sci2exp(z1));type_1;
		    strcat(sci2exp(rpar));sci2exp(auto1)],tt)
	
	gr_i=['xstringb(orig(1),orig(2),''Scifunc'',sz(1),sz(2),''fill'');']
       case 'standard_block' then
	write(%io(2),['PB with standard_block';
		      'version change is not implemented'])
	label=[]
	gr_i=[]
      else
	printf(blocktype+' unknown, parameters values may be lost, please check\n')
	label=[]
	gr_i=[]
      end
      graphics(4)=label
      graphics(9)=gr_i
      o(2)=graphics
      model(13)=' '
      model(14)=list()
      o(3)=model
      o=replace_firing(o)
    endfunction

    
    x_new=list()
    wpar=scs_m(1)
    wsiz=wpar(1)
    if size(wsiz,'*')>=4 then x_new=scs_m,return,end

    wpar(3)(4)=wpar(4)+1
    x_new(1)=wpar
    nx=size(scs_m)
    for k=2:nx
      o=scs_m(k)
      if o(1)=='Link' then
      elseif o(1)=='Block' then
	model=o(3)
	if model(1)=='super'|model(1)=='csuper' then
	  model(8)=do_version22(model(8))
	  o(3)=model
	  o=block_version(o)
	  scs_m(k)=o
	else
	  o=block_version(o)
	end
      elseif o(1)=='Text' then
	o=block_version(o)
      end
      x_new(k)=o;
    end
  endfunction

  // main code 
  //printf("do_version: version=%s\n",version);
  Versions_old='scicos'+['2.2','2.3','2.3.1','2.4','2.5.1'];
  if ~isempty(find(version==Versions_old)) then 
    error('Please use Scilab to first update your schema to versions >= 2.7');
    return;
  end
  // now we are at least scicos2.7
  if version=='scicos2.7' then 
    version='scicos2.7.1';
    printf('updates version to %s\n',version);
    scs_m=do_version271(scs_m),
  end
  if version=='scicos2.7.1' then 
    version='scicos2.7.2';
    printf('updates version to %s\n',version);
    scs_m=do_version272(scs_m),
  end
  if version=='scicos2.7.2' then 
    version='scicos2.7.3';
    printf('updates version to %s\n',version);
    scs_m=do_version273(scs_m),
  end
  // now we are at least scicos2.7.3
  if or(version==['scicos2.7.3','scicos4','scicos4.0.1','scicos4.0.2']) then
    version='scicos4.2';
    printf('updates version to %s\n',version);
    scs_m=update_scs_m(scs_m);
    scs_m=do_version42(scs_m);
  end
  // now we are at least scicos4.2 
  if version=='scicos4.2' then
    version='scicos4.3';
    printf('updates version to %s\n',version);
    scs_m=update_scs_m(scs_m);
    scs_m=do_version43(scs_m);
  end
  // now we are at least scicos4.3
  if version=='scicos4.3' then
    version='scicos4.4';
    printf('updates version to %s\n',version);
    scs_m=update_scs_m(scs_m);
    scs_m=do_version44(scs_m);
  end
  // now we are at least scicos4.4
  if version=='scicos4.4' then
    version='scicos4.4.1';
    printf('updates version to %s\n',version);
    scs_m=update_scs_m(scs_m);
    scs_m=do_version441(scs_m);
  end
endfunction

function [ok,scicos_ver,scs_m]=update_version(scs_m)
// Copyright INRIA
// updates a diagram to the current scicos version 
  function scs = do_version441_plus(scs_m)
    scs = scs_m;
    if ~scs.props.iskey['zoom'] then
      if size(scs.props.wpar,'*') >= 13 then 
	scs.props.zoom= scs.props.wpar(13);
      else
	scs.props.zoom=1.4;
      end
    end
  endfunction
  
  ok=%t;
  current_version = get_scicos_version()
  // guess the proper version of the diagram 
  scicos_ver = find_scicos_version(scs_m)
  if scicos_ver==current_version then 
    scs_m = do_version441_plus(scs_m);
    return;
  end 
  cmd= 'scs_m_out=do_version(scs_m,scicos_ver)'
  ok=execstr(cmd,errcatch=%t)
  if ~ok then
    lasterror();
    return;
  end
  scs_m=scs_m_out;
endfunction

function [scicos_ver]=find_scicos_version(scs_m)
// Copyright INRIA
// find_scicos_version tries to retrieve a scicos
// version number in a scs_m structure.
// 21/08/07: Alan, inital revision
// 
  scicos_ver=acquire('scicos_ver',def= "scicos2.2");
  if scs_m.iskey['version'] then
    if scs_m.version<>'' then
      // version is stored in the structure.
      scicos_ver= scs_m.version
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
    end
  end
endfunction

function scs_m=do_upgrade_gri(scs_m)
// regenerate the gr_i of the blocks using
// blocks definition;
  for i=1:size(scs_m.objs)
    o= scs_m.objs(i);
    if o.type =='Block' then
      if o.iskey['gui'] then 
	execstr( 'obj='+o.gui+'(''define'')');
	ngri=obj.graphics.gr_i(1);
	if type(ngri,'short')=='l' then ngri=ngri(1);end
	if type(o.graphics.gr_i,'short')=='l' then 
	  o.graphics.gr_i(1) = obj.graphics.gr_i(1);
	else 
	  o.graphics.gr_i = obj.graphics.gr_i;
	end
      end
      omod=o.model;
      if o.model.sim.equal['super'] | o.model.sim.equal['csuper'] then
	o.model.rpar=do_upgrade_gri(o.model.rpar)
      end
      scs_m.objs(i)=o;
    end
  end
endfunction
