function [model,ok]=build_modelica_block(blklstm,corinvm,cmmat,NiM,NoM,scs_m,path)
// Serge Steer 2003, Copyright INRIA
// given the blocks definitions in blklstm and connections in cmmat this
// function first create  the associated modelicablock  and writes its code
// in the file named 'imppart_'+name+'.mo' in the directory given by path
// Then modelica compiler is called to produce the C code of scicos block
// associated to this modelica block. filbally the C code is compiled and
// dynamically linked with Scilab.
// The correspondind model data structure is returned.

//## get the name of the generated main modelica file
name=stripblanks(scs_m.props.title(1))+'_im'; 

if (name<> cleanID1(name) )
  x_message(' Error: '''+name+''' is not a valid name for a Modelica model.');
  ok=%f
  return
end

//## generation of the txt for the main modelica file
//## plus return ipar/rpar for the model of THE modelica block
[ok,txt,ipar, opar]=create_modelica(blklstm,corinvm,cmmat,name,scs_m);
if ~ok then return,end

//## write txt in the file path+name+'.mo'
//FIXME
//path=pathconvert(stripblanks(path),%t,%t)
scicos_mputl(txt,path+name+'.mo');
printf('--------------------------------------------\n\r');
printf('%s',' Main Modelica : '+path+name+'.mo'); printf('\n\r');

//## search for 

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
//## compile modelica files
[ok,name,nipar,nrpar,nopar,nz,nx,nx_der,nx_ns,nin,nout,nm,ng,dep_u]=compile_modelica(path+name+'.mo',Mblocks);


if ~ok then return,end

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
                   dep_ut=[dep_u %t],nzcross=ng,nmode=nm)
endfunction

function id_out=cleanID1(id)
  if id=='' then
    id_out='';
    return;
  end
  lid=length(id)
  ida=ascii(id);
  ido=ida;
  for i=1:length(id)
    C1= ascii('0')<=ida(i) & ida(i)<=ascii('9');
    C2= ascii('a')<=ida(i) & ida(i)<=ascii('z');
    C3= ascii('A')<=ida(i) & ida(i)<=ascii('Z');    
    if C1 | C2 | C3 then 
      ido(i)=ida(i)
    else
      ido(i)=ascii('_')
    end    
  end  
  
  if ( ascii('0')<=ida(1) & ida(1)<=ascii('9')) then 
    ido(1)=ascii('_')
  end

  id_out=ascii(ido);
endfunction

function [ok,txt,ipar,opar]=create_modelica(blklst,corinvm,cmat,name,scs_m)
// Copyright INRIA
  if exists('%Modelica_Init','global')==%f then 
    // Modelica_Init becomes true only in "Modelicainitialize_.sci"
    %Modelica_Init=%f;
  end
  if exists('%Modelica_ParEmb','global')==%f then 
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
      //## retrieve the object in the scs_m structure
      o_scsm = scs_m(scs_full_path(corinvm(k)));
      //## 17/11/09 : Add a second call to the interfacing function (job 'compile')
      ierr=execstr('[o_out]='+o_scsm.gui+'(""compile"",o,k);',errcatch=%t);
      if ierr then
        if ~isequal(o_out,[]) then
          o=o_out
        end
      end
      //## get the structure graphics
      o_gr  = o_scsm.graphics;
      //## get the identification field or label field
      
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
    //** mo.parameters have size=2
    //** it only contains parameters
    if np<>0 then
      if size(mo.parameters)==2 then
        mo.parameters(3)=zeros(1,np)
      end
    end

    for j=1:np
      //## loop on number of param value
      //## can be both scalar or array
      Parj=mo.parameters(1)(j)
      Parjv=mo.parameters(2)(j)
      Parj_in=Parj+'_'+BlockName
      if type(Parjv,'string')=='Mat' then // if Real/Complex	Integers are used with "fixed=true"

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

    if isempty(P) then
      models=[models;
              '  '+mo.model+' '+tab+Bnames($)];
    else
      models=[models;
              '  '+mo.model+' '+tab+Bnames($)+'('+strcat(P,', ')+')'];
    end

    //## Add gr_i identification in comments of models

    if id<>'' then
      models($)=models($)+' ""'+id+'"";'
    else
      models($)=models($)+';'
    end

    //rajouter les ports
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
            '  '+n1+'.'+p1+' = '+n2+'.'+p2+';']
    else
      eqns=[eqns
            '  connect ('+n1+'.'+p1+','+n2+'.'+p2+');']
    end
  end
   
  txt=[txt;
       'model '+name
       Params
       models
       'equation'
       eqns
       'end '+name+';']
  ok=%t;
endfunction

function r=validvar_modelica(s)
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

  Paro='';
  if isempty(Pari) then
    ok=%f;return
  end  
  C=opari;
  [a1,b1]=size(C);
  npi=a1*b1;

  //FIXME !!
  //if typeof(C)== 'hypermat' then   
  //  x_message('type ""Hyper Matrix"" is not supported')
  //  ok=%f;return;
  //end
  
  if (type(C,'string')=='Mat') then
    if isreal(C) then
      par_type='Real'
      FIXED='false'     
    else
      x_message("type ""Complex"" is not suported in Modelica");
      ok=%f;return;
    end
  elseif (type(C,'string')=='IMat') then
    par_type='Integer'
    FIXED='true'
  else 
    //x_message("type """+string(typeof(C))+""" is not suported in Modelica");
    x_message("type is not suported in Modelica");
    ok=%f;return;
  end
  
  if ~Parembed then 
    FIXED='true'
  end
  
  if (npi==1) then // scalar
    if par_type=='Real' then
      // eopari=m2s(C,"%e")
      eopari=sprintf("%e",C);
    end  
    if par_type=='Integer' then
      //eopari=m2s(C,"%d")
      eopari=sprintf("%.0f",i2m(C))
    end  
    fixings='(fixed='+FIXED+') '
  else
    if par_type=='Integer' then
      x_message("type ""Integer array"" is not suported in Modelica");
      ok=%f;return;
    end
    [ok,eopari]=write_nD_format(C);
    if ~ok then return;end
    fixings='(each fixed='+FIXED+') ';
    [d1,d2]=size(C);
    if (d1==1) then 
      Pari=Pari+'['+string(d2)+']'; //[d2] 
    else
      Pari=Pari+'['+string(d1)+','+string(d2)+']'; //[d1,d2] 
    end            
  end
  Paro='  parameter '+par_type+' '+Pari+ fixings+'='+eopari+ "  """+Pari+""""+';'   
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
// Copyright INRIA
  //lines(0)
  if exists('%Modelica_Init','global')==%f then 
    // Modelica_Init becomes true only in "Modelicainitialize_.sci"
    %Modelica_Init=%f;
  end

  if exists('%Jacobian','global')==%f then 
    %Jacobian=%t;
  end

  if exists('%Modelica_ParEmb','global')==%f then 
    %Modelica_ParEmb=%t;
  end
    
  running="off";
  //FIXME
  //try   
  //  %_winId=TCL_GetVar("IHMLoc")  
  //catch
    %_winId="nothing";
  //end
  if (%_winId <> "nothing") then  
    running=TCL_EvalStr("winfo exists [sciGUIName "+%_winId+"]")
  end
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
    
  // macros/scicos/compile_modelica.sci
  // macros/auto/scicos_simulate.sci
  // macros/scicos/clickin.sci
  // macros/scicos/do_eval.sci
  // macros/scicos/do_run.sci
  // compile_init_modelica
  // MIHM
  
  if %Jacobian then, JAC=' -jac '; else, JAC=' '; end
  
  //do not update C code if needcompile==0 this allows C code
  //modifications for debuggingS_translator.er purposes  
  if exists('needcompile','all');needcompile=needcompile;else needcompile=4;end

  updateC=needcompile<>0|~file("exists",Cfile)
  updateC=updateC | %Modelica_Init 
  if updateC  then
    if ~exists('modelica_libs','all') then 
      // to use do_compile outside of scicos
      modelica_libs=get_scicospath()+'/macros/blocks/'+...
	  ['ModElectrical','ModHydraulics','ModLinear'];
    end
    mlibs=modelica_libs
    mlibsM=file('join',[tmpdir;'Modelica'])
    mlib1=[mlibs,mlibsM];
    translator_libs=strcat(' -lib ""'+mlib1+'""');
    //-----------------------just for OS limitation-------
    if getenv('WIN32','NO')=='OK' then, Limit=1000;else, Limit=3500;end
    if (length(translator_libs)>Limit) then 
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
    if %Modelica_Init then with_ixml=" -with-init ";else with_ixml=" ";end    
    
    instr='""'+translator+'"" '+translator_libs+' -lib ""'+filemo+'"" -o ""'+...
	  Flat+'""'+with_ixml+'  -command ""'+name+' '+namef+';"" > ""'+ ...
	  file('join',[tmpdir;'S_translator.err'])+'""';
    if getenv('WIN32','NO')=='OK' then
      instr = file('join',[tmpdir;'gent.bat']);
      scicos_mputl(instr,instr);
    end
    //  pause    
    if ( %Modelica_Init ) then 
      if ~file("exists",xmlfile) then 
	overwrite=1;//Yes
      else
	overwrite=x_message(['The initialization file already exists!';...
		    'Do you want to overwrite it?'],['Yes','No'])       
      end
    else     
      // do not generate the flat file when it is already generated by
      // the initialization GUI
      if (running =="1") then 
	overwrite=2;//no
      else
	overwrite=1;//yes
      end        
    end
    if (overwrite==2) then 
      commandresult=0;
    else
      //FIXME
      //commandresult=execstr('unix_s(instr)',errcatch=%t);
      //system(instr)
      commandresult=0
      printf('ZZZ: %s\n',instr);
    end
    
    if commandresult==0 then
      if (%Modelica_Init) then //---------------------------
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
//	if MSDOS then, mputl(instr,tmpdir+'genx.bat');instr=tmpdir+'genx.bat';end	
//	if ok & execstr('unix_s(instr)','errcatch')==0 then
//	  mprintf('%s',' Flat Modelica : '+Flat); mprintf('\n\r');
//	else 
//	  MSG3= mgetl(tmpdir+'xml2modelica.err');
//	  x_message(['------- XML to Modelica error message:-------';MSG3]);
//	  ok=%f,dep_u=%t; nipar=0;nrpar=0;nopar=0;nz=0;nx=0;nx_der=0;nx_ns=0;nin=0;nout=0;nm=0;ng=0;
//	  return	         
//	end
      end
    else
      MSG2=scicos_mgetl(file('join',[tmpdir;'S_translator.err']));
      x_message(['-------Modelica translator error message:-----';MSG2]);
      ok=%f,
      dep_u=%t; nipar=0;nrpar=0;nopar=0;nz=0;nx=0;nx_der=0;nx_ns=0;nin=0;nout=0;nm=0;ng=0;
      return
    end
 
    //---------------------------------------------------------------------
    if ~file("exists",Flat_functions) then,
      Flat_functions=" "; 
    else
      Flat_functions='""'+Flat_functions+'""';
    end

    if ((running=="1" )& (file("exists",xmlfile))) then // if GUI is running
      XMLfiles=' -with-init-in ""'+xmlfileTMP+'"" -with-init-out ""'+xmlfileTMP+'""';
    else
      XMLfiles='';
    end      
    instr='""'+modelicac+'"" ""'+Flat+'""  '+Flat_functions+' '+XMLfiles+' -"+...
	  " o ""'+Cfile+'"" '+JAC+' 1> ""'+file('join',[tmpdir;'S_modelicac.out'])+'""'+' 2> ""'+ ...
	  file('join',[tmpdir;'S_modelicac.err'])+'""';    
    if getenv('WIN32','NO')=='OK' then
      instr=file('join',[tmpdir;'genm2.bat']);
      scicos_tl(instr,instr), 
    end
    //if execstr('unix_s(instr)','errcatch')==0 then  
    if system(instr)<>0 then
      MSG3= scicos_mgetl(file('join',[tmpdir;'S_modelicac.out']));
      printf("\n %s",MSG3)      
      MSG3= scicos_mgetl(file('join',[tmpdir;'S_modelicac.err']));      
      [nl,nc]=size(MSG3); Index=1;
      for i=1:nl
	if strindex(MSG3(i),"Trying to reduce state... Failed")==1 then Index=2;break;end
      end
      if Index==2 then 
	MSG3=["Warning: This model is a high index DAE          ";..
	      "The solver may be unable to simulate this system.";..
	      "Please try to reduce the system index.           "];
	printf("\n  ---------------------------------------------------")
	printf("\n ! %s !",MSG3);
	printf("\n  ---------------------------------------------------")
      end
    else
      MSG3= scicos_mgetl(file('join',[tmpdir;'S_modelicac.err']));
      x_message(['-------Modelica compiler error:-------';MSG3]);	    
      ok=%f,dep_u=%t; nipar=0;nrpar=0;nopar=0;nz=0;nx=0;nx_der=0;nx_ns=0;nin=0;nout=0;nm=0;ng=0;      
      return
    end     
    //---------------------------------------------------------------------
  end // if update
  
  [nipar,nrpar,nopar,nz,nx,nx_der,nx_ns,nin,nout,nm,ng,dep_u]=reading_incidence(incidence)
  
  printf('\n\r Modelica blocks are reduced to a block with:');
  printf('\n\r Number of differential states: %d',nx_der);
  printf('\n\r Number of algebraic states: %d',nx-nx_der);
  printf('\n\r Number of discrete time states  : %d',nz);
  printf('\n\r Number of zero-crossing surfaces: %d',ng);
  printf('\n\r Number of modes  : %d',nm);
  printf('\n\r Number of inputs : %d',nin);
  printf('\n\r Number of outputs: %d',nout);
  printf('\n\r Input/output dependency:[ ');
  for i=1:nin,if dep_u(i) then mprintf('T ');else,mprintf('F ');end;end; mprintf(']');
  if %Jacobian then 
    printf('\n\r Analytical Jacobian: enabled  (\%Jacobian=\%t)');
  else
    printf('\n\r Analytical Jacobian: disabled (\%Jacobian=\%f)');
  end
  
  if %Modelica_ParEmb then 
    printf('\n\r Parameter embedding mode: enabled  (\%Modelica_ParEmb=\%t)');
  else
    printf('\n\r Parameter embedding mode: disabled (\%Modelica_ParEmb=\%f)');
  end

  printf('\n\r ');
  
  ok=Link_modelica_C(Cfile)

endfunction


function [ok]=fix_parameters(Flatxml,flag)
  // flag='all' => set fixed of all parameters to true
  // flag='top' => set fixed of only top level parameters to true
  // flag='bottom' => set fixed of only second level parameters to true

  res=execstr('xmlformat=mgetl(Flatxml)',errcatch=%t);
  if (res~=0) then, ok=%f; return; end
    
  typ=[];input_name=[];order=[];depend=[];
  global txtline;txtline=0;
  touch=%f
  while and(typ<>'</model') do
    [typ,val]=get_typ(xmlformat);
    if typ(1)=='<elements' then
      [typ,val]=get_typ(xmlformat);      
      while typ(1)<>'</elements' do
	if typ(1)=='<terminal' then
	  [typ,val]=get_typ(xmlformat);      
	  txtline_save=txtline;
	  while typ(1)<>'</terminal' do
	    if typ(1)=='<name' then 
	     ttyp=tokens(typ(2),'<');
	     Item_name=ttyp(1);
	    end
	    if typ(1)=='<id' then 
	     ttyp=tokens(typ(2),'<');
	     Item_id=ttyp(1);
	    end
 	    if typ(1)=='<kind' then 
	     ttyp=tokens(typ(2),'<');
	     Item_kind=ttyp(1);
	    end
 	    if typ(1)=='<fixed' then 
	     Item_fixed=val;
	    end
 	    [typ,val]=get_typ(xmlformat);
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
	      [typ,val]=get_typ(xmlformat);      
	      while typ(1)<>'</terminal' do
		if typ(1)=='<fixed' then 
		  [xmlformat]=set_fix(xmlformat);
		  touch=%t
		end
		[typ,val]=get_typ(xmlformat);      
	      end
	    end
	    //-----------
	  end
	end
	[typ,val]=get_typ(xmlformat);
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


function t=read_new_line(txt)
  global txtline
  txtline=txtline+1;
  t=txt(txtline)
endfunction

function [typx,value]=get_typ(txt)
  t=read_new_line(txt);
  typ=tokens(t);  
  typx=tokens(typ(1),'>');
  if size(typ,'*')==2 & typ=='value' then 
    valx=tokens(typ(2),['>','/'])
    execstr(valx,'errcatch')
  else
    value=[];
  end
endfunction

function [txt]=set_fix(txt)
  t=txt(txtline)
  t=strsubst(t,'false','true')
  txt(txtline)=t;
endfunction

function model_name=get_model_name(mo_model,id,AllNames)
//Copyright INRIA
//## return a unique name for a modelica model
//## for the compiled modelica structure
//##
//## inputs :
//##   mo_model : a string that gives the name of the model
//##              in the modelica list (equations) of a modelica block.
//##
//##   Bnames   : vector of strings of already attribuated model names
//##
//## output :
//##   model_name : the output string of the model name
//##
  // pause get_model_name 
  ido=cleanID(id);
  mo_model=cleanID(mo_model)
  ind = 1
  model_name=mo_model+'_'+ido
  if ~isempty(AllNames) then
    while ~isempty(find(model_name==AllNames)) then
      model_name=mo_model+'_'+ido+string(ind)
      ind = ind + 1
    end
  end
endfunction

function id_out=cleanID(id)
  if id=='' then
    id_out='';
    return;
  end
  lid=length(id)
  ida=ascii(id);
  ido=ida;
  for i=1:length(id)
    C1= ascii('0')<=ida(i) & ida(i)<=ascii('9');
    C2= ascii('a')<=ida(i) & ida(i)<=ascii('z');
    C3= ascii('A')<=ida(i) & ida(i)<=ascii('Z');    
    if C1 | C2 | C3 then 
      ido(i)=ida(i)
    else
      ido(i)=ascii('_')
    end    
  end  
  id_out=ascii(ido);
endfunction

function [ok,modelicac,translator,xml2modelica]=Modelica_execs()
  //FIXME
  //ok=%f
  
  //modelicac=pathconvert(SCI+'/bin/modelicac.exe',%f,%t)         
  //translator=pathconvert(SCI+'/bin/translator.exe',%f,%t) 
  //xml2modelica=pathconvert(SCI+'/bin/XML2Modelica.exe',%f,%t)
  //ok =%t
  
  //if strindex(modelicac,' ')<>[] then modelicac='""'+modelicac+'""',end
  //if strindex(translator,' ')<>[] then translator='""'+translator+'""',end
  //if strindex(xml2modelica,' ')<>[] then xml2modelica='""'+xml2modelica+'""',end

  //if (fileinfo(modelicac)==[])    then x_message(['Scilab cannot find the Modelica compiler:';modelicac]);ok=%f;return;end
  //if (fileinfo(translator)==[])   then x_message(['Scilab cannot find the Modelica translator:';translator]);ok=%f;return;end
  //if (fileinfo(xml2modelica)==[]) then x_message(['Scilab cannot find the XML to modelica convertor:';xml2modelica]);ok=%f;return;end
  
  ok=%t
  modelicac=getenv('NSP')+'/bin/modelicac.exe'
  translator=getenv('NSP')+'/bin/translator.exe'
  xml2modelica=getenv('NSP')+'/bin/XML2Modelica.exe'

endfunction

