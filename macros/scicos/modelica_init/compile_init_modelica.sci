function [ok]=compile_init_modelica(xmlmodel,paremb=0,jaco='0')
  // called by the solve button of Modelica initialize dialog
  //   
  global icpr;
  ok = %f;

  tmpdir =file('split',getenv('NSP_TMPDIR'));
  
  [ok,modelicac,translator,xml2modelica]=Modelica_execs();
  if ~ok then, 
    message("Modelica compilers are not found");
    return; 
  end
  xmlfile =file('join',[tmpdir;xmlmodel+'_init.xml']);
  namei=xmlmodel+'i';
  Flati=file('join',[tmpdir;xmlmodel+'i.mo']);
  FlatCi=file('join',[tmpdir;xmlmodel+'i.c']);
  incidencei=file('join',[tmpdir;xmlmodel+'i_incidence_matrix.xml']);
  Flat_functions=file('join',[tmpdir;xmlmodel+'_functions'+'.mo']);
  
  // instruction to be executed 
  //win32 case
  if %win32 then
    instr=[""""+file("native",xml2modelica)+"""";
	   """"+file("native",xmlfile)+"""";
	   "-init";"-o";
	   """"+file("native",Flati)+""""];
  else
    instr=[file("native",xml2modelica);
	   xmlfile;
	   "-init";"-o";
	   Flati];
  end
  
  // generate a makefile to help debug
  txt = instr; txt($)=""""+txt($)+"""";
  txt = ["#/* -*- Mode: Makefile -*- */";
	 "all :"
	 "\t"+ catenate(txt,sep=" ")];
  scicos_mputl(txt,file('join',[tmpdir;'makefile_mo3']));
  // run
  [ok,sp_o,sp_e,sp_m]=spawn_sync(instr);
  // FIXME: should report errors in sp_e !
  // take care that ok just means that 
  // the function runs and returned. 
  // Then it is necessary to check sp_e 
  // and in the case of translator ERROR is 
  // reported in sp_o
  if ~ok | (~isequal(sp_e,"") & ~isempty(sp_e)) | sum(strstr(sp_o,'ERROR'))<>0 then
    ok=%f;
  end
  xpause(0,%t);
  
  if ~ok then
    x_message(['Error:';'xml2modelica failed for modelica initialization';sp_e;sp_m]);	    
    return
  end

  fprintf(" Init XML (xml2modelica): %s \n",Flati);

  if ~file("exists",Flat_functions) then,
    Flat_functions=m2s([]); 
  else
    if %win32 then
      Flat_functions='""'+Flat_functions+'""';
    end
  end

  // launch modelicac again
  if %win32 then
    instr=[""""+file('native',modelicac)+"""";
	   """"+file('native',Flati)+"""";
	   Flat_functions;
	   "-with-init-in";
	   """"+file('native',xmlfile)+"""";
	   "-with-init-out";
	   """"+file('native',xmlfile)+"""";
	   "-o";
	   """"+file('native',FlatCi)+""""];
  else
    instr=[file('native',modelicac);
	   file('native',Flati);
	   Flat_functions;
	   "-with-init-in";
	   file('native',xmlfile);
	   "-with-init-out";
	   file('native',xmlfile);
	   "-o";
	   file('native',FlatCi)];
  end
  if jaco<>'0' then   
    instr=[instr;"-jac"];
  end
  
  txt = ["#/* -*- Mode: Makefile -*- */"
	 "all : ";
	 catenate(["\t";instr],sep= " ")];
  scicos_mputl(txt,file('join',[tmpdir;'makefile_mo4']));
  [ok,sp_o,sp_e,sp_m]=spawn_sync(instr);
  if ~ok then
    x_message(['Error:';'Modelica compilation failed ';sp_e;sp_m]);	    
    ok=%f;
    return
  end

  xpause(0,%t);
  ok=Link_modelica_C(FlatCi)
  [nipar,nrpar,nopar,nz,nx,nx_der,nx_ns,nin,nout,nm,ng,dep_u]=reading_incidence(incidencei)
  if ~ok then, 
    x_message(["Error: compilation failed at link_modelica"]);
    return; 
  end
  
  //build model data structure of the block equivalent to the implicit
  bllst=bllst;nblock=length(bllst);
  mdl=bllst(nblock)
  mdl.sim=list(namei,10004);
  mdl.state=zeros(nx*2,1);
  mdl.dstate=zeros(nz,1);
  mdl.nzcross=ng;
  mdl.nmode=nm;
  mdl.in=ones(nin,1);
  mdl.out=ones(nout,1);
  mdl.dep_ut=[dep_u, %t];
  bllst(nblock)=mdl; 
  if size(connectmat,2)==6 then connectmat=connectmat(:,[1 2 4 5]),end
  // scs_m=null() is very strange because scs_m can be used in c_pass2;
  // scs_m=null()
  
  icpr=list();
  %scicos_solver=100;
  
  // returns an empty list when c_pass2 is not OK 
  icpr=c_pass2(bllst,connectmat,clkconnect,cor,corinv);
  
  if icpr.equal[list()] then 
    x_message(["Error: compilation failed"]);
    return,
  end   

  // suppressing display blocks
  Ignore=['bouncexy','cscope','cmscope','canimxy','canimxy3d','cevscpe','cfscope','cscopexy',...
          'cscopexy3d','cscopxy','cscopxy3d','cmatview', 'cmat3d','affich', 'affich2','BPLATFORM']

  for i=1:length(icpr.sim.funs)
    if type(icpr.sim.funs(i),'short')== 's' then
      if ~isempty(find(icpr.sim.funs(i) == Ignore)) then
	icpr.sim.funs(i) = 'trash';
      end
    end
  end
  // XXXXX Attention c'est une fonction a appeller 
  // TCL_EvalStr("Compile_finished ok "+ %_winId); 
endfunction
