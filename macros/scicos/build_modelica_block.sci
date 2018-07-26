function [model,ok]=build_modelica_block(blklstm,corinvm,cmmat,NiM,NoM,scs_m,path)
// Serge Steer 2003, Copyright INRIA
//   
// given the blocks definitions in blklstm and connections in cmmat this
// function first creates the associated modelicablock  and writes its code
// in the file named 'imppart_'+name+'.mo' in the directory given by path
// Then modelica compiler is called to produce the C code of scicos block
// associated to this modelica block. filbally the C code is compiled and
// dynamically linked. 
// The correspondind model data structure is returned.
  
  function id_out=cleanID1(id)
  // replace characters of id which are no alphabetic or digit to _
  // moreover if starting character is a digit it is replaced by '_'.
    T=isalnum(id);
    ida=ascii(id);
    ida(~T)=ascii('_');
    if length(ida)>= 1 && isdigit(ascii(ida(1))) then ida(1)=ascii('_');end;
    id_out=ascii(ida);
  endfunction
    
  // get the name of the generated main modelica file
  name=stripblanks(scs_m.props.title(1))+'_im'; 
  if (name<> cleanID1(name) )
    x_message('Error: '''+name+''' is not a valid name for a Modelica model.');
    ok=%f
    return
  end
  // generation of the txt for the main modelica file
  // plus return ipar/rpar for the model of THE modelica block
  [ok,txt,ipar, opar]=create_modelica(blklstm,corinvm,cmmat,name,scs_m);
  if ~ok then return,end
  
  scicos_mputl(txt,file('join',[file('split',path);name+'.mo']));
  printf('--------------------------------------------\n\r');
  printf('%s',' Main Modelica : '+path+name+'.mo'); printf('\n\r');
  // search for Modelica blocks 
  Mblocks = [];
  for i=1:size(blklstm)
    if type(blklstm(i).sim,'string')=='List' then
      if blklstm(i).sim(2)==30004 then
	o = scs_m(scs_full_path(corinvm(i)))
	Mblocks=[Mblocks;
		 o.graphics.exprs.nameF]
      end
    end
  end

  //generating XML and Flat_Model
  // compile modelica files
  [ok,name,nipar,nrpar,nopar,nz,nx,nx_der,nx_ns,nin,nout,nm,ng,dep_u]=compile_modelica(path+name+'.mo',Mblocks);
  
  if ~ok then 
    model=list();
    return
  end

  //nx is the state dimension
  //ng is the number of surfaces
  //name1 of the model+flat
  //build model data structure of the block equivalent to the implicit part
  model=scicos_model(sim=list(name,10004),.. 
		     in=ones(nin,1),out=ones(nout,1),..
		     state=zeros(nx*2,1),..
		     dstate=zeros(nz,1),..
		     ipar=ipar,..
		     opar=opar,..
		     dep_ut=[dep_u %t],nzcross=ng,nmode=nm);
  
endfunction

function [ok,txt,ipar,opar]=create_modelica(blklst,corinvm,cmat,name,scs_m)
  // creates modelica code gathering all the modelica blocks contained in
  // the scicos schema.
    
  if exists('%Modelica_Init')==%f then 
    // Modelica_Init becomes true only in "Modelicainitialize_.sci"
    %Modelica_Init=%f;
  end
  if exists('%Modelica_ParEmb')==%f then 
    %Modelica_ParEmb=%t;
  end  
  
  Parembed=%Modelica_ParEmb & ~%Modelica_Init;
  
  txt=[];tab=ascii(9)
  //  rpar=[];//will contain all parameters associated with the all modelica blocs
  opar=list();
  ipar=[];//will contain the "adress" of each block in rpar
  models=[]//will contain the model declaration part
  eqns=[]//will contain the modelica equations part
  Pin=[]
  Bnumbers=[]
  Bnam=[]
  Bnames=[]
  nb=size(blklst)
  Params=[];
  for k=1:nb
    ipar(k)=0
    o=blklst(k)
    //#########
    //## Params
    //#########

    if o.equations.model<>'OutPutPort' & o.equations.model<>'InPutPort' then
      // retrieve the object corresponding to k in the scs_m structure 
      o_scsm = scs_m(scs_full_path(corinvm(k)));
      // second call to the interfacing function with a 'compile' job
      exec_ok=execstr( '[o_out]=' +o_scsm.gui+ '(""compile"",o,k);',errcatch=%t);
      if exec_ok && ~isempty(o_out) then o=o_out; end
      // get the graphic structure
      o_gr  = o_scsm.graphics;
      // get the identification field or label field
      id = stripblanks(o_gr.id)
      if id == '' then
        id = stripblanks(o_scsm.model.label);
      end
    else
      id=''
    end
    mo=o.equations;
    BlockName=get_model_name(mo.model,id,Bnam)
    if ~isempty(mo.parameters) then
      np=size(mo.parameters(1),'*');
    else
      np=0
    end
    P=[];
    // add default third argument if missing 
    if np<>0 then
      if size(mo.parameters)==2 then
        mo.parameters(3)=zeros(1,np)
      end
    end
    // loop on parameters 
    for j=1:np
      Parj=mo.parameters(1)(j)
      Parjv=mo.parameters(2)(j)
      Parj_in=Parj+'_' + BlockName
      if type(Parjv,'string')=='Mat' then 
	// if Real/Complex Integers are used with "fixed=true"
	//	rpar=[rpar;matrix(Parjv,-1,1)] ;// should to be removed once modelciac is updated
        Parjv_plat=Parjv(:);
        for jj=1:size(Parjv_plat,'*')
         opar($+1)=Parjv_plat(jj)
        end
	ipar(k)=ipar(k)+size(Parjv,'*')
      end
      //======================================================
      [ok,Parj_out]=construct_Pars(Parj_in,Parjv,Parembed);
      if ~ok then return,end
      Params=[Params;Parj_out]
      if mo.parameters(3)(j)==0 then
	P=[P;Parj+'='+Parj_in]
      elseif mo.parameters(3)(j)==1 then   
	//eParjv=construct_redeclar(Parjv)
	P=[P;Parj+'(start='+Parj_in+')'];	 
      elseif mo.parameters(3)(j)==2 then
	//eParjv=construct_redeclar(Parjv)
	P=[P;Parj+'(start='+Parj_in+',fixed=true)'];
      end
      //======================================================
    end
    
    //#########
    //## models
    //#########
    Bnumbers=[Bnumbers k];

    //## update list of names of modelica blocks
    Bnam = [Bnam,BlockName];
    Bnames = [Bnames, Bnam($)]

    if ~isempty(P) then str_params ="("+strcat(P,", ")+")";else str_params = "";end
    if id<>"" then str_id = sprintf(" ""%s""",id);else str_id = "";end
    models = [models;"  "+mo.model+" "+tab+Bnames($) + str_params + str_id + ";"];
  end

  ipar=cumsum([1;ipar(:)])
  
  //links
  for k=1:size(cmat,1)
    from=cmat(k,1:3)
    to=cmat(k,4:6)
    if from(1)==0 then //input port
      nb=nb+1
      Bnumbers=[Bnumbers nb];
      Bnames=[Bnames,'B'+string(nb)];
      models=[models;'  InPutPort'+' '+tab+'B'+string(nb)+';'];
      n1='B'+string(nb)
    elseif from(3)==1 then
      p1=blklst(from(1)).equations.inputs(from(2))
      n1=Bnames(find(Bnumbers==from(1)))
    else
      p1=blklst(from(1)).equations.outputs(from(2))
      n1=Bnames(find(Bnumbers==from(1)))
    end
    if to(1)==0 then //output port
      nb=nb+1
      Bnumbers=[Bnumbers nb];
      Bnames=[Bnames,'B'+string(nb)];
      models=[models;'  OutPutPort'+' '+tab+'B'+string(nb)+';'];
      n1='B'+string(nb)
    elseif to(3)==1 then
      p2=blklst(to(1)).equations.inputs(to(2))
      n2=Bnames(find(Bnumbers==to(1)))
    else
      if size(blklst(to(1)).equations.outputs,'*')<to(2) then pause,end
      p2=blklst(to(1)).equations.outputs(to(2))
      n2=Bnames(find(Bnumbers==to(1)))
    end

    if or(blklst(from(1)).equations.model==['InPutPort','OutPutPort']) ...
         | or(blklst(to(1)).equations.model==['InPutPort','OutPutPort']) ...
    then 
      eqns=[eqns
            "  "+n1+"."+p1+" = "+n2+"."+p2+";"]
    else
      eqns=[eqns
            "  connect ("+n1+"."+p1+","+n2+"."+p2+");"]
    end
  end
   
  txt=[txt;
       "model "+name
       Params
       models
       "equation"
       eqns
       "end "+name+";"]
  ok=%t;
endfunction

function r=validvar_modelica(s)
// unused function 
  r=validvar(s);
  if r then
    bad_char=['%' '#' '$']
    for j=1:size(bad_char,2)
      if strindex(s,bad_char(j)) then
	r=%f
	return
      end
    end
  end
endfunction

function [ok,Paro]=construct_Pars(Pari,opari,Parembed)
  // construct in Paro a string for the modelica declaration
  // of parameter Pari having value opari. 
  // opari is a matrix (double or integer).
  
  ok = %f; Paro='';
  
  if isempty(Pari) then return;end
  
  C=opari;
  npi= size(C,'*');
  
  select type(C,'string')
    case 'Mat' then
      if ~isreal(C) then
	x_message("type ""Complex"" is not supported in Modelica"); return;
      end
      par_type='Real'; FIXED='false'     
    case 'IMat' then
      par_type='Integer'; FIXED='true';
    else 
      x_message(sprintf("type ""%s"" is not supported in Modelica",type(C,"string")));
      return;
  end
  
  if ~Parembed then FIXED='true'; end
  
  if npi==1 then
    // value is a scalar
    if par_type=='Real' then
      eopari=sprintf("%e",C);
    end  
    if par_type=='Integer' then
      eopari=sprintf("%.0f",i2m(C))
    end  
    fixings= "(fixed=" + FIXED +") ";
  else
    if par_type=='Integer' then
      x_message("type ""Integer array"" is not suported in Modelica"); return;
    end
    [ok,eopari]=write_nD_format(C);
    if ~ok then return;end
    fixings="(each fixed="+FIXED+") ";
    [d1,d2]=size(C);
    if (d1==1) then 
      Pari=Pari+'['+string(d2)+']'; //[d2] 
    else
      Pari=Pari+'['+string(d1)+','+string(d2)+']'; //[d1,d2] 
    end            
  end
  Paro="  parameter "+par_type+" "+Pari+ fixings+"="+eopari+ "  """+Pari+""""+";"   
  ok=%t
endfunction

function [ok,r]=write_nD_format(x)
// 
  x= real(x); // ignore complex part 
  sx=size(x);
  if size(sx,'*')==2 then // Matrix/Vector
    [nD1,nD2]=size(x)
    if nD1==1 then //row vector or scalar
      if nD2==1 then 
	r=sprintf("{%e}",x)//scalar
      else
	//r=msprintf("%e,",x(1:$-1)')+msprintf("%e",x($))// row vector
	r= '{'+catenate(sprintf("%e",x(:)),sep=',')+'}';
      end
      ok=%t;return;
    else
      r=m2s([]);
      for i=1:nD1
	[ok,ri]=write_nD_format(x(i,:));//matrix or column vector
	if ok then r(i)=ri;else return;end
      end
      r='{'+catenate(r,sep=',')+'}';
      ok=%t;return;
    end 
  else // hypermatrix
    // typeof(x)==hypermat
    //  xd=x.entries
    //  sdims=x.dims(2:$)
    //  N=x.dims(1)
    //  cmd=':)' 
    //  n=size(sx,'c') 
    //  for i=1:n-2;cmd=':,'+cmd;end;
    //  cmd=','+cmd;
    r='';
    ok=%f;return;
  end
endfunction

function [ok,name,nipar,nrpar,nopar,nz,nx,nx_der,nx_ns,nin,nout,nm,ng,dep_u]=compile_modelica(filemo,Mblocks)
  // compile a modelica file filemo with blocks definition in Mblocks

  // Modelica_Init becomes true only in "Modelicainitialize_.sci"
  if exists('%Modelica_Init')==%f then %Modelica_Init=%f;end
  
  if exists('%Jacobian')==%f then  %Jacobian=%t;  end

  if exists('%Modelica_ParEmb')==%f then  %Modelica_ParEmb=%t;end
    
  running="off";
  // tmpdir is a column matrix 

  tmpdir=file('split',TMPDIR);
  [ok,modelicac,translator,xml2modelica]=Modelica_execs();

  if ~ok then,
    name='';
    dep_u=%t; nipar=0;nrpar=0;nopar=0;nz=0;nx=0;nx_der=0;nx_ns=0;nin=0;nout=0;nm=0;ng=0;
    return;
  end
  
  //basename in nsp is not the same as in scilab 
  //we must add file('root' 
  name=file('root',basename(filemo));
  namef=name+'f';
  Flat=file('join',[tmpdir;name+'f.mo']);
  Flatxml=file('join',[tmpdir;name+'f.xml']);
  Flat_functions=file('join',[tmpdir;name+'f_functions.mo']);
  xmlfile=file('join',[tmpdir;name+'f_init.xml']);       
  Relfile=file('join',[tmpdir;name+'f_relations.xml']);
  incidence=file('join',[tmpdir;name+"_incidence_matrix.xml"])
  xmlfileTMP=file('join',[tmpdir;name+'Sim.xml']) 
  Cfile=file('join',[tmpdir;name+'.c']);
  
  if %Jacobian then, JAC='-jac'; else, JAC=m2s([]); end
  
  //do not update C code if needcompile==0 this allows C code
  //modifications for debugging purposes  
  if exists('needcompile','all');needcompile=needcompile;else needcompile=4;end

  updateC=needcompile<>0|~file("exists",Cfile);
  updateC=updateC | %Modelica_Init;
  
  if updateC  then
    // Alan ???
    //    if ~exists('modelica_libs','all') then 
    // to use do_compile outside of scicos
    //       modelica_libs=get_scicospath()+'/macros/blocks/'+...
    //     ['ModElectrical','ModHydraulics','ModLinear'];
    //    end
    mlibs=modelica_libs;
    for k=1:size(modelica_libs,'*')
      mlibs(k)=file('native',mlibs(k))
    end
    mlibsM=file('native',file('join',[tmpdir;'Modelica']));
    mlib1=[mlibs(:);mlibsM];
    if %win32 then
      translator_libs=[smat_create(size(mlib1,'*'),1,'-lib'),""""+mlib1+""""]';
    else
      translator_libs=[smat_create(size(mlib1,'*'),1,'-lib'),mlib1]';
    end
    translator_libs.redim[-1,1]
    translator_libs=translator_libs(:);
    //-----------------------just for OS limitation-------
    // used when command line is too long 
    if %win32 then, Limit=1000;else, Limit=3500;end
    if sum(length(translator_libs)) > Limit  then 
      // FIXME this part should be tested by setting Limit to a smaller 
      // size 
      printf("%s\n",['WARNING:';..
		     '\tThere are too many Modelica files.';..
		     '\tit would be better to define several ';..
		     '\tModelica programs in a single file.'])
      molibs=[]
      for k=1:size(Mblocks,'r')
	funam=stripblanks(Mblocks(k))
	extF=file('extension',funam);
	if (extF=='.mo') then
	  molibs=[molibs;""""+funam+""""];
	else
	  molibs=[molibs;""""+file('join',[mlibsM;funam+'.mo'])+""""];
	end
      end
      
      for k=1:size(mlibs,'*')
	modelica_file=glob(file('join',[mlibs(k);'*.mo']));
	if ~isempty(modelica_file) then 
	  molibs=[molibs;""""+modelica_file+""""];
	end
      end
      mymopac=file('join',[tmpdir;'MYMOPACKAGE.mo']);
      txt=[];
      for k=1:size(molibs,'*')
	fnamex=file('root',file('tail',molibs(k)));
	if fnamex<>'MYMOPACKAGE' then 
	  txt=[txt;scicos_mgetl(evstr(molibs(k)))];
	end
      end
      scicos_mputl(txt,mymopac);     
      translator_libs= strcat(' -lib ""'+mymopac+'""');
    end    
    //---------------------just for OS limitation-------
    //---------------------------------------------------------------------
    if %Modelica_Init then with_ixml="-with-init";else with_ixml=m2s([]);end    
    // instruction to be executed 
    //win32 case
    if %win32 then
      instr=[""""+file("native",translator)+"""";
	     translator_libs;
	     "-lib";""""+file("native",filemo)+"""";
	     "-o";""""+file("native",Flat)+"""";
	     with_ixml;
             "-command";""""+name+" "+namef+""";"];
    else
      instr=[file("native",translator);
	     translator_libs;
	     "-lib";file("native",filemo);
	     "-o";file("native",Flat);
	     with_ixml;
             "-command";name+" "+namef+";"];
    end
    
    if %f && %win32 then
      instrc = file("join",[tmpdir;"gent.bat"]);
      scicos_mputl(instr,instrc);
      instr=instrc;
    end
    if ( %Modelica_Init ) then 
      if ~file("exists",xmlfile) then 
	overwrite=1;//Yes
      else
	overwrite=x_message(["The initialization file already exists!";...
			     "Do you want to overwrite it?"],["Yes","No"])       
      end
    else     
      // do not generate the flat file when it is already generated by
      // the initialization GUI
      if running == "1" then 
	overwrite=2;//no
      else
	overwrite=1;//yes
      end        
    end

    commandok=%t;
    if ~(overwrite==2) then 
      // run translator
      [ok,sp_o,sp_e,sp_m]=spawn_sync(instr);
      // FIXME: translator should report errors in sp_e !
      // take care that ok just means that 
      // the function runs and returned. 
      // Then it is necessary to check sp_e 
      // and in the case of translator ERROR is 
      // reported in sp_o
      if ~ok | (~isequal(sp_e,"") & ~isempty(sp_e)) | sum(strstr(sp_o,'ERROR'))<>0 then
	commandok=%f;
      end
      xpause(0,%t);
    end
    if ~commandok then
      // spawn command failed, report and return.
      x_message(['Error:';'Modelica translation failed';sp_o;sp_e;sp_m]);
      ok=%f,
      dep_u=%t; nipar=0;nrpar=0;nopar=0;nz=0;nx=0;nx_der=0;
      nx_ns=0;nin=0;nout=0;nm=0;ng=0;
      return
    end
    if (%Modelica_Init) then 
      //---------------------------
      printf('%s',' Init XML file : '+xmlfile); printf('\n\r');
      printf('%s',' Init Rel file : '+Relfile); printf('\n\r');
      name=Flat;dep_u=%t;//<<ALERT
      // dep_u of the initialization block is obtained onley when the  C
      // code is generated.
      ok=%t,nipar=0;nrpar=0;nopar=0;nz=0;nx=0;nx_der=0;nx_ns=0;nin=0;nout=0;nm=0;ng=0;      
      return;
    else
      if ~((running=="1" )& (file("exists",xmlfile))) then 
	// ok=fix_parameters(Flatxml,'bottom');
	ok=%t
      end  
      //	instr='""'+xml2modelica+'"" ""'+Flatxml+'"" -o ""'+Flat+'""  > ""'+tmpdir+'xml2modelica.err""';
      //	if (%win32) then, mputl(instr,tmpdir+'genx.bat');instr=tmpdir+'genx.bat';end	
      //	if ok & execstr('unix_s(instr)','errcatch')==0 then
      //	  mprintf('%s',' Flat Modelica : '+Flat); mprintf('\n\r');
      //	else 
      //	  MSG3= mgetl(tmpdir+'xml2modelica.err');
      //	  x_message(['------- XML to Modelica error message:-------';MSG3]);
      //	  ok=%f,dep_u=%t; nipar=0;nrpar=0;nopar=0;nz=0;nx=0;nx_der=0;nx_ns=0;nin=0;nout=0;nm=0;ng=0;
      //	  return	         
      //	end
    end
    //
    //---------------------------------------------------------------------
    if ~file("exists",Flat_functions) then,
      Flat_functions=m2s([]); 
    else
      if %win32 then
        Flat_functions='""'+Flat_functions+'""';
      end
    end
    XMLfiles=m2s([]);
    if ((running=="1" )& (file("exists",xmlfile))) then // if GUI is running
      XMLfiles=' -with-init-in ""'+xmlfileTMP+'"" -with-init-out ""'+xmlfileTMP+'""';
    end      
    // run modelicac 
    if %win32 then
      instr=[""""+file('native',modelicac)+""""; """"+file('native',Flat)+""""; Flat_functions;
	     XMLfiles; '-o'; """"+Cfile+""""; JAC];
    else
      instr=[file('native',modelicac);file('native',Flat); Flat_functions;
	     XMLfiles; '-o'; Cfile; JAC];
    end
    if %f && %win32 then
      instrc = file('join',[tmpdir;'genm2.bat']);
      scicos_mputl(instr,instrc);
      instr=instrc;
    end
    [ok,sp_o,sp_e,sp_m]=spawn_sync(instr);
    if ~ok then
      x_message(['Error:';'Modelica compilation failed ';sp_e;sp_m]);	    
      ok=%f,dep_u=%t; nipar=0;nrpar=0;nopar=0;nz=0;nx=0;nx_der=0;nx_ns=0;nin=0;nout=0;nm=0;ng=0;      
      return
    end
    xpause(0,%t);
    // printf("%s\n",sp_o);
    I=strstr(sp_e,"Trying to reduce state... Failed");
    if sum(I)<>0 then
      MSG3=["Warning: This model is a high index DAE          ";..
	    "The solver may be unable to simulate this system.";..
	    "Please try to reduce the system index.           "];
      printf("---------------------------------------------------\n")
      printf("! %s !\n",MSG3);
      printf("---------------------------------------------------\n")
    end
    //---------------------------------------------------------------------
  end // if update

  [nipar,nrpar,nopar,nz,nx,nx_der,nx_ns,nin,nout,nm,ng,dep_u]=reading_incidence(incidence)
  printf(' Modelica blocks are reduced to a block with:\n');
  printf(' Number of differential states: %d\n',nx_der);
  printf(' Number of algebraic states: %d\n',nx-nx_der);
  printf(' Number of discrete time states  : %d\n',nz);
  printf(' Number of zero-crossing surfaces: %d\n',ng);
  printf(' Number of modes  : %d\n',nm);
  printf(' Number of inputs : %d\n',nin);
  printf(' Number of outputs: %d\n',nout);
  printf(' Input/output dependency:[ ');
  for i=1:nin,if dep_u(i) then printf('T ');else,printf('F ');end;end; printf(']\n');
  if %Jacobian then 
    printf(' Analytical Jacobian: enabled  (%%Jacobian=%%t)\n');
  else
    printf(' Analytical Jacobian: disabled (%%Jacobian=%%f)\n');
  end
  if %Modelica_ParEmb then 
    printf(' Parameter embedding mode: enabled  (%%Modelica_ParEmb=%%t)\n');
  else
    printf(' Parameter embedding mode: disabled (%%Modelica_ParEmb=%%f)\n');
  end
  ok=Link_modelica_C(Cfile)
endfunction


function [ok]=fix_parameters(Flatxml,flag)
// flag='all' => set fixed of all parameters to true
// flag='top' => set fixed of only top level parameters to true
// flag='bottom' => set fixed of only second level parameters to true
  function [txt]=set_fix(txt)
    t=txt(txtline)
    t=strsubst(t,'false','true')
    txt(txtline)=t;
  endfunction

  function typ=fp_get_typ(txt)
    global txtline
    txtline=txtline+1;
    t=txt(txtline)
    typ=split(t);
    typ(length(typ)==0)=[];
    typ=split(typ(1),sep='>',msep=%f);
    typ(length(typ)==0)=[];
  endfunction
  
  res=execstr('xmlformat=scicos_mgetl(Flatxml)',errcatch=%t);
  if (res~=0) then, ok=%f; return; end
  
  typ=m2s([]);input_name=[];order=[];depend=[];
  global txtline;txtline=0;
  touch=%f
  while and(typ<>'</model') do
    [typ,val]=fp_get_typ(xmlformat);
    if typ(1)=='<elements' then
      [typ,val]=fp_get_typ(xmlformat);      
      while typ(1)<>'</elements' do
	if typ(1)=='<terminal' then
	  [typ,val]=fp_get_typ(xmlformat);      
	  txtline_save=txtline;
	  while typ(1)<>'</terminal' do
	    if typ(1)=='<name' then 
	     ttyp=split(typ(2),sep='<');
	     Item_name=ttyp(1);
	    end
	    if typ(1)=='<id' then 
	     ttyp=split(typ(2),sep='<');
	     Item_id=ttyp(1);
	    end
 	    if typ(1)=='<kind' then 
	     ttyp=split(typ(2),sep='<');
	     Item_kind=ttyp(1);
	    end
 	    if typ(1)=='<fixed' then 
	     Item_fixed=val;
	    end
 	    [typ,val]=fp_get_typ(xmlformat);
	  end
	  
	  if Item_kind=='fixed_parameter' then
	     fixit=%f
	     if flag=='all' then 
	       fixit=%t
	     else 
	       if flag=='top' & (Item_id==Item_name) then 
		    fixit=%t
	       end
	       if flag=='bottom' & (Item_id~=Item_name) then 
		    fixit=%t
	       end
	     end	    
	    //----------
	    if fixit then 
	      txtline=txtline_save;
	      [typ,val]=fp_get_typ(xmlformat);      
	      while typ(1)<>'</terminal' do
		if typ(1)=='<fixed' then 
		  [xmlformat]=set_fix(xmlformat);
		  touch=%t
		end
		[typ,val]=fp_get_typ(xmlformat);      
	      end
	    end
	    //-----------
	  end
	end
	[typ,val]=fp_get_typ(xmlformat);
      end
    end
  end
  
  clearglobal txtline;
  if touch then 
    res=execstr('scicos_mputl(xmlformat,Flatxml)',errcatch=%t);
    if (res~=0) then, ok=%f; return; end    
  end 
  ok=%t
endfunction

function model_name=get_model_name(mo_model,id,AllNames)
  //Copyright INRIA
  // return a unique name for a modelica model
  // for the compiled modelica structure
  //
  // inputs :
  //   mo_model: a string that gives the name of the model
  //              in the modelica list (equations) of a modelica block.
  //   id: an other string concatenated to mo_model 
  //   
  //   Allnames: vector of strings of already attribuated model names
  //
  // output :
  //   model_name : cleanID(mo_model)_cleanID(id)_xxx
  //   where xxx is a string generated for model_name not to be in AllNames
  
  function id_out=cleanID(id)
    // utility function: replaces characters of id which are no alphabetic or digit by '_'
    T=isalnum(id);
    ida=ascii(id);
    ida(~T)=ascii('_');
    id_out=ascii(ida);
  endfunction

  base_name = cleanID(mo_model) + '_' +  cleanID(id);
  model_name= base_name;
  ind = 1
  if ~isempty(AllNames) then
    while ~isempty(find(model_name==AllNames)) then
      model_name= base_name + '_' + string(ind);
      ind = ind + 1
    end
  end
endfunction

function [ok,modelicac,translator,xml2modelica]=Modelica_execs()
// find executables 
  ok=%t
  modelicac=getenv('NSP')+'/bin/modelicac.exe'
  translator=getenv('NSP')+'/bin/translator.exe'
  xml2modelica=getenv('NSP')+'/bin/XML2Modelica.exe'
  if ~file('exists',modelicac) then 
    x_message(['Error: cannot find the Modelica compiler:';modelicac]);
    ok=%f;
    return;
  end
  if ~file('exists',translator) then 
    x_message(['Error: cannot find the Modelica translator:';translator]);
    ok=%f;
    return;
  end
  if ~file('exists',xml2modelica) then 
    x_message(['Error: cannot find the XML to modelica converter:';xml2modelica]);
    ok=%f;
    return;
  end
endfunction

