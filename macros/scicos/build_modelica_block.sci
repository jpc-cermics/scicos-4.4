function [model,ok]=build_modelica_block(blklstm,cmmat,NiM,NoM,name,path)
// Serge Steer 2003, Copyright INRIA
// given the blocks definitions in blklstm and connections in cmmat this
// function first create  the associated modelicablock  and writes its code
// in the file named 'imppart_'+name+'.mo' in the directory given by path
// Then modelica compiler is called to produce the C code of scicos block
// associated to this modelica block. filbally the C code is compiled and
// dynamically linked with Scilab.
// The correspondind model data structure is returned.
name='imppart_'+stripblanks(name);
//FIXME
//path=pathconvert(stripblanks(path),%t,%t)

[txt,rpar,ipar]=create_modelica1(blklstm,cmmat,name);
scicos_mputl(txt,path+name+'.mo');
printf('   Modelica code generated at '+path+name+'.mo\n')
[ok,name1,nx,nin,nout,ng,nm,nz]=compile_modelica(path+name+'.mo');

if ~ok then model=list(), return, end

//nx is the state dimension
//ng is the number of surfaces

//build model data structure of the block equivalent to the implicit part
model=scicos_model(sim=list(name,10004),.. 
	           in=ones(nin,1),out=ones(nout,1),..
		   state=zeros(nx*2,1),..
		   dstate=zeros(nz,1),..
		   rpar=rpar,..
		   ipar=ipar,..
		   dep_ut=[%f %t],nzcross=ng,nmode=nm)
endfunction

function [txt,rpar,ipar]=create_modelica1( blklst,cmat,name)
  txt=[];tab=ascii(9)
  rpar=[];//will contain all parameters associated with the all modelica blocs
  ipar=[];//will contain the "adress" of each block in rpar
  models=[]//will contain the model declaration part
  eqns=[]//will contain the modelica equations part
  Pin=[]
  Bnumbers=[]
  Bnames=[]
  nb=size(blklst)
  Pars=[]
  for k=1:nb
    ipar(k)=0
    o=blklst(k);
    mo=o.equations;
    if ~isempty(mo.parameters) then
      np=size(mo.parameters(1),'*');
    else
      np=0
    end
    P=[];
    
    if size(mo.parameters)==2 then
      for l=1:np
	Pars=[Pars;'P'+string(size(Pars,1)+1)]
	rpar=[rpar;matrix(mo.parameters(2)(l),-1,1)]
	ipar(k)=ipar(k)+size(mo.parameters(2)(l),'*')
	P=[P;mo.parameters(1)(l)+'='+Pars($)];
      end
    else
      for l=1:np
	Pars=[Pars;'P'+string(size(Pars,1)+1)]
	rpar=[rpar;matrix(mo.parameters(2)(l),-1,1)]
	ipar(k)=ipar(k)+size(mo.parameters(2)(l),'*')
	if mo.parameters(3)(l)==0 then
	  P=[P;mo.parameters(1)(l)+'='+Pars($)];
	elseif mo.parameters(3)(l)==1 then
	  P=[P;mo.parameters(1)(l)+'(start='+Pars($)+')'];
	elseif mo.parameters(3)(l)==2 then
	  P=[P;mo.parameters(1)(l)+'(start='+Pars($)+',fixed=true)'];  
	end
      end
    end
    Bnumbers=[Bnumbers k];
    Bnames=[Bnames,'B'+string(k)];
    if isempty(P) then
      models=[models;'  '+mo.model+' '+tab+'B'+string(k)+';'];
    else
      models=[models;'  '+mo.model+' '+tab+'B'+string(k)+'('+strcat(P,', ')+');'];
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
  
  if ~isempty(Pars) then
    Pars='  parameter Real '+Pars+';'
  end
  txt=[txt;
       'class '+name
       Pars
       models
       'equation'
       eqns
       'end '+name+';']
endfunction

  
function [ok,name,nx,nin,nout,ng,nm,nz]=compile_modelica(fil)
// Serge Steer 2003, Copyright INRIA
  ok=%t //XXXX

  if ~with_modelica_compiler() then
    message('Modelica compiler unavailable')
    ok=%f,name='',nx=0,nin=0,nout=0,ng=0,nm=0,nz=0
    return
  end
  
  ng=0
  //XXXXX
	//fil=pathconvert(fil,%f,%t)
  //mlibs=pathconvert(modelica_libs,%f,%t)
  mlibs=modelica_libs
  
  name=file("rootname",basename(fil))
  path=strsubst(stripblanks(fil),name+'.mo','')

  //do not update C code if needcompile==0 this allows C code
  //modifications for debugging purposes  
  updateC=needcompile <>0|file("exists",path+name+'.c')

  if updateC then
    if MSDOS then
      //FIXME
      modelicac=pathconvert(SCI+'/bin/modelicac.exe',%f,%t)
      if ~isempty(strindex(modelicac,' ')) then modelicac='""'+modelicac+'""',end
      modelicac=modelicac+strcat(' -L ""'+mlibs+'""')
      instr=modelicac+' '+fil+' -o '+path+name+'.c -jac'
      
      scicos_mputl(instr,path+'genc.bat')
      instr=path+'genc.bat'
    else
       //modelicac=pathconvert(SCI+'/bin/modelicac',%f,%t)
       modelicac=getenv('NSP')+'/bin/modelicac'
       modelicac=modelicac+strcat(' -L '+mlibs)
       instr=modelicac+' '+fil+' -o '+path+name+'.c -jac'
       
    end

    if system(instr)<>0 then
      x_message(['Modelica compiler error:'
		  scicos_mgetl(TMPDIR+'/unix.err');
		 'sorry ']);
      ok=%f,nx=0,nin=0,nout=0,ng=0;nm=0;nz=0;return
    end
    printf('   C code generated at '+path+name+'.c\n')
  end

  Cfile=path+name+'.c';

  //scicos_patch
  txt=scicos_mgetl(Cfile);
  txt=strsubst(txt,'Get_Jacobian_parameter','scicos_Get_Jacobian_parameter');
  txt=strsubst(txt,'Set_Jacobian_flag','scicos_Set_Jacobian_flag');
  txt=strsubst(txt,'Get_Scicos_SQUR','scicos_Get_Scicos_SQUR');
  txt=strsubst(txt,'get_scicos_time','scicos_get_time');
  txt=strsubst(txt,'set_pointer_xproperty','scicos_set_pointer_xproperty');
  txt=strsubst(txt,'set_block_error','scicos_set_block_error');
  txt=strsubst(txt,'get_phase_simulation','scicos_get_phase_simulation');
  scicos_mputl(txt,Cfile);

  if MSDOS then Ofile=path+name+'.obj', else Ofile=path+name+'.o', end
  
  //get the Genetrated block properties
  [nx,nin,nout,ng,nm,nz]=analyze_c_code(scicos_mgetl(Cfile))

  //below newest(Cfile,Ofile) is used instead of  updateC in case where
  //Cfile has been manually modified (debug,...)
  if newest_here(Cfile,Ofile)==1 then 
    //unlink if necessary
    [a,b]=c_link(name); while a ; ulink(b);[a,b]=c_link(name);end
    // build shared library with the C code
    files=name+'.o';Make=path+'Make'+name;loader=path+name+'.sce'
    //  build the list of external functions libraries
    libs=[];
    if MSDOS then ext='\*.ilib',else ext='/*.a',end
    for k=1:size(mlibs,'*')
      libs=[libs;glob(mlibs(k)+ext)]
    end

    ierr=execstr('libn=ilib_for_link(name,files,libs,""c"",makename=Make,loadername=loader)',errcatch=%t)
    if ~ierr then
      ok=%f;x_message(['sorry compilation problem';lasterror()]);
      return;
    end

    // link the generated C code
    if ~(execstr('link(libn,name,''c'')',errcatch=%t)) then 
      ok=%f;
      x_message(['Problem while linking generated code';lasterror()]);
      return;
    end
  end
endfunction

function [nx,nin,nout,ng,nm,nz]=analyze_c_code(txt)
// Serge Steer 2003, Copyright INRIA
  match=  'number of variables = '
  T=txt((strstr(txt(1:10),match)==1))//look for match in the first 10 lines
  nx=evstr(strsubst(T,match,''))

  match=  'number of inputs = '
  T=txt((strstr(txt(1:10),match)==1))//look for match in the first 10 lines
  nin=evstr(strsubst(T,match,''))

  match=  'number of outputs = '
  T=txt((strstr(txt(1:10),match)==1))//look for match in the first 10 lines
  nout=evstr(strsubst(T,match,''))

  match=  'number of zero-crossings = '
  T=txt((strstr(txt(1:10),match)==1))//look for match in the first 10 lines
  ng=evstr(strsubst(T,match,''))

  match=  'number of modes = '
  T=txt((strstr(txt(1:10),match)==1))//look for match in the first 10 lines
  nm=evstr(strsubst(T,match,''))

  match=  'number of discrete variables = '
  T=txt((strstr(txt(1:10),match)==1))//look for match in the first 10 lines
  nz=evstr(strsubst(T,match,''))

endfunction

function txt=modify1(txt,nx)

endfunction

function r=with_modelica_compiler()
  // check if modelica_compiler exists
  if MSDOS then
    //path=pathconvert(SCI+'/bin/modelicac.exe',%f,%t)
    path=getenv('NSP')+'/bin/modelicac.exe';
  else
    //path=pathconvert(SCI+'/bin/modelicac',%f,%t)
    path=getenv('NSP')+'/bin/modelicac';
  end
  //r=fileinfo(path)<>[]
  r=file("exists",path)
endfunction

function n=newest_here(file1,file2)
 e1=file("exists",file1)
 e2=file("exists",file2)

 if e1&e2 then
   d1=file("atime",file1)
   d2=file("atime",file2)
   if d1>d2 then
     n=1
   elseif d2>d1 then
     n=2
   else
     n=1
   end
 elseif e1 then
   n=1
 elseif e2 then
   n=2
 else
   n=[]
 end
endfunction
