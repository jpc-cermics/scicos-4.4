function  [ok]=Link_modelica_C(Cfile)

  mlibs=pathconvert(modelica_libs,%f,%t)  
  Cfile=pathconvert(Cfile,%f,%t)
  name=basename(Cfile)
  path=strsubst(stripblanks(Cfile),name+'.c','')
  if MSDOS then Ofile=path+name+'.obj', else Ofile=path+name+'.o', end

  //below newest(Cfile,Ofile) is used instead of  updateC in case where
  //Cfile has been manually modified (debug,...)
  if newest(Cfile,Ofile)==1 then
    //  build the list of external functions libraries
    // remove repreated directories from mlibs
    rep=[];
    for k=1:size(mlibs,'*')
      for j=k+1:size(mlibs,'*')
        if stripblanks(mlibs(k))==stripblanks(mlibs(j)) then rep=[rep,j]; end
      end
    end
    mlibs(rep)=[];
    //--------------------------------
    libs=[];
    if MSDOS then ext='\*.ilib',else ext='/*.a',end 
    // removing .a or .ilib sufixs
    for k=1:size(mlibs,'*')
      aa=listfiles(mlibs(k)+ext);
      for j=1:size(aa,'*')
        [pathx,fnamex,extensionx]=fileparts(aa(j));
        libsname= fullfile(pathx,fnamex);
        libs=[libs;libsname];
      end
    end

    //##add libraries provided by %scicos_libs
    if %scicos_libs<>[] then
      libs=[libs %scicos_libs(:)'];
    end

    // add modelica_libs to the list of directories to be searched for *.h
    //if MSDOS then ext='\*.h',else ext='/*.h',end
    EIncludes=''
    for k=1:size(mlibs,'*')
      EIncludes=EIncludes+'  -I""'+ mlibs(k)+'""';
    end

    E2='';
    for i=1:length(EIncludes)
      if (part(EIncludes,i)=='\') then
        E2=E2+'\';
      end
      E2=E2+part(EIncludes,i);
    end

    //** build shared library with the C code
    files = name;
    //## buildnewblock(blknam,files,filestan,filesint,libs,rpat,ldflags,cflags)
    ok = buildnewblock(name,files,'','',libs,TMPDIR,'',E2);
    if ~ok then return, end

  end
endfunction
