function  [ok]=Link_modelica_C(Cfile)
  mlibs=modelica_libs;
  Cfile=Cfile;
  name=file('root',file('tail',Cfile))
  // path=strsubst(stripblanks(Cfile),name+'.c','')
  path=file('dirname',Cfile)
  if (%win32) then ext = '.obj'; else ext='.o'; end
  Ofile=file('join',[path,name+ext]);
  //below newest(Cfile,Ofile) is used instead of  updateC in case where
  //Cfile has been manually modified (debug,...)
  if file('exists',Ofile) && file('mtime',Cfile) <= file('mtime',Ofile) then
    ok=%t 
    return;
  end
  //##add libraries provided by %scicos_libs
  if exists('%scicos_libs') &&  ~isempty(%scicos_libs) then
    mlibs=[mlibs(:)',%scicos_libs(:)'];
  end
  //  build the list of external functions libraries
  // remove repreated directories from mlibs
  mlibs = unique(mlibs);
  //--------------------------------
  libs=[];
  if (%win32) then ext='*.ilib',else ext='*.a',end 
  // removing .a or .ilib sufixs
  for k=1:size(mlibs,'*')
    aa=glob(file('join',[mlibs(k),ext]));
    for j=1:size(aa,'*')
      libs=[libs;file('root',aa(j))];
    end
  end
  // add modelica_libs to the list of directories to be searched for *.h
  EIncludes=catenate("-I"""+ mlibs+"""",sep=" ")
  E2= strsubst(EIncludes,"\","\\\\")
  // build shared library with the C code
  files = name;
  //buildnewblock(blknam,files,filestan,filesint,libs,rpat,ldflags,cflags)
  ok = buildnewblock(name,files,'','',libs,TMPDIR,'',E2);
  if ~ok then return, end
endfunction
