function [ok]=buildnewblock(blknam,files,filestan,filesint,libs,rpat,ldflags,cflags,silent)
//Copyright (c) 1989-2011 Metalau project INRIA
//** buildnewblock : generates Makefiles for
//                   the generated C code of a scicos block,
//                   compile and link it in ScicosLab
//
// Input : blknam : a prefix
//         files : files to be compiled
//         filestan : files to be compiled and included in
//                    the standalone code
//         filesint : files to be compiled and included in
//                    the interfacing of standalone code
//         libs : a vector of string of object files
//                    to include in the building process
//         rpat     : a target directory
//         ldflags  : linker flags
//         cflags   : a vector of strings for Compiler flags
//         silent   : flag to only do the generation without compilation
//                    and linking
//
// Output :  ok : a flag to say if build is ok
//

//** check rhs paramaters
    
  if nargin <= 1 then files    = blknam, end
  if nargin <= 2 then filestan = '', end
  if nargin <= 3 then filesint = '', end //##
  if nargin <= 4 then libs     = m2s([]), end
  if nargin <= 5 then rpat     = TMPDIR, end
  if nargin <= 6 then ldflags  = '', end
  if nargin <= 7 then cflags   = '', end
  if nargin <= 8 then silent   = %f, end

  if libs.equal[''] then libs=m2s([]);end 
  
  //@@ check if a fortran files exist
  ok =execstr("fd=fopen(''"+rpat+'/'+blknam+'f.f'+"'',mode=""r"")", errcatch=%t);
  if ok then
    fd.close[];
    files=[files,blknam+'f']
    if ~filesint.equal[''] then
      filesint=[filesint,blknam+'f']
    end
    if ~filestan.equal[''] then
      filestan=[filestan,blknam+'f']
    end
  else
    lasterror()
  end
  
  //## define a variable to know if we use
  //## a ScicosLab interfacing function for the standalone
  if ~filesint.equal[''] then
    with_int = %t;
  else
    with_int = %f;
  end

  //** adjust path and name of object files
  //   to include in the building process
  
  //** adjust cflags
  if ~isempty(cflags) then
    if (cflags ~= emptystr()) then
      cflags=strcat(cflags,' ')
    end
  end

  //** otherlibs treatment
  [ok,libs,for_link]=link_olibs(libs,rpat)
  if ~ok then
    ok=%f;
    x_message(['Error: unable to link libraries from libs';libs(:);
	       catenate(lasterror())]);
    return;
  end

  //** generate text of the loader file
  [txt]=gen_loader(blknam,for_link,with_int)

  //** write text of the loader in file
  ierr=execstr('scicos_mputl(txt,rpat+''/''+blknam+''_loader.sce'')',errcatch=%t)
  if ~ierr then
    x_message(['Can''t write '+blknam+'_loader.sce';catenate(lasterror())])
    ok=%f
    return
  end

  //** def make file name
  Makename=file('join',[rpat;'Makefile_'+blknam]);
  
  //@@ generation of Makefiles
  //  Take care of the fact that here we generate 
  //  a unix make when we are on windows and 
  //  a windows make when we are on unix 
  if ~%win32 then //@@ unix
    SCI = 'E:\nsp';
    txt=gen_make_win32(blknam,files,filestan,libs,ldflags,cflags);
    Makename2 = Makename+'.mak'
    ierr=execstr('scicos_mputl(txt,Makename2)',errcatch=%t)
    if ~ierr then
      x_message(['Can''t write '+Makename2;catenate(lasterror())]);
      ok=%f;
      return;
    end
    SCI = getenv('NSP');
  else 
    //@@ windows
    SCI = '/usr/lib/nsp';
    txt=gen_make_unix(blknam,files,filestan,libs,ldflags,cflags);
    ierr=execstr('scicos_mputl(txt,Makename)',errcatch=%t)
    if ~ierr then
      x_message(['Can''t write '+Makename;catenate(lasterror())]);
      ok=%f;
      return;
    end
    SCI = getenv('NSP');
  end

  //** generate makefile contents 
  [Makename2,txt]=gen_make(blknam,files,filestan,libs,Makename,ldflags,cflags);
    
  //** write text of the Makefile in the file called Makename
  ierr=execstr('scicos_mputl(txt,Makename2)',errcatch=%t)
  if ~ierr then
    x_message(['Can''t write '+Makename2;catenate(lasterror())])
    ok=%f
    return
  end

  //@@ compile and link if needed
  if ~silent then

    //** unlink if necessary
    [a,b]=c_link(blknam);
    while a
      ulink(b);
      [a,b]=c_link(blknam);
    end

    //** save path in case of error in ilib_compile
    oldpath=getcwd();
    
    //** compile Makefile (the dirname of Makename is used as 
    //   compilation destination directory.
    [libn,ok]=ilib_compile('lib'+blknam,Makename);
    if ~ok then
      chdir(oldpath);
      x_message([sprintf('Error: compilation failed for block %s',blknam);
		 catenate(lasterror())]);
      return;
    end
    
    //** link scicos generated code.
    ierr=execstr('link(libn,blknam,''c'')',errcatch=%t)
    
    if ~ierr then
      ok=%f;
      x_message(['sorry link problem';catenate(lasterror())]);
      return;
    end

  end
  
  //## generate makefile for interfacing function of the standalone
  if with_int then
     //## def name of interf func and
     //## name of interf librabry derived from name of superblock
     l_blknam=length(blknam)
     //l_blknam=(l_blknam>17)*17 + (l_blknam<=17)*l_blknam
     blknamint='int'+part(blknam,1:l_blknam)
     Makename=file('join',[rpat;'Makefile_'+blknamint]);
     
     //@@ generation of Makefiles
     if ~%win32 then 
       //@@ unix (we generate also win32 makefile)
       SCI='E:\scicoslab_43_cross'
       
       txt=gen_make_win32(blknamint,filesint,'',libs,ldflags,cflags);
       Makename2 = Makename+'.mak';
       ierr=execstr('scicos_mputl(txt,Makename2)',errcatch=%t)
       if ~ierr then
         x_message(['Can''t write '+Makename2;catenate(lasterror())]);
         ok=%f;
         return;
       end
       SCI = getenv('NSP');
     else 
       //@@ windows (we generate also unix makefile)
       SCI = '/usr/lib/scicoslab_gtk-4.3'
       txt=gen_make_unix(blknamint,filesint,'',libs,ldflags,cflags);
       ierr=execstr('scicos_mputl(txt,Makename)',errcatch=%t)
       if ~ierr then
         x_message(['Can''t write '+Makename;catenate(lasterror())]);
         ok=%f;
         return;
       end
       SCI = getenv('NSP');
     end

     //## generate txt of makefile of the Makefile
     [Makename2,txt]=gen_make(blknamint,filesint,'',libs,Makename,ldflags,cflags);
     //## write text of the Makefile in the file called Makename
     ierr=execstr('scicos_mputl(txt,Makename2)',errcatch=%t)
     if ~ierr then
       x_message(['Can''t write '+Makename2;catenate(lasterror())])
       ok=%f
       return
     end
     
     //@@ compile and link if needed
     if ~silent then

       //## unlink if necessary
       //## with addinter, this is the interfacing function of table
       //## that is used as reference
       [a,b]=c_link(blknamint+'_sci');
       while a
         ulink(b);
         [a,b]=c_link(blknamint+'_sci');
       end

       //## compile Makefile
       ierr=execstr('libn=ilib_compile(''lib''+blknamint,Makename)',errcatch=%t)
       if ~ierr then
         ok=%f;
         chdir(oldpath);
         x_message(['sorry compiling problem';catenate(lasterror())]);
         return;
       end

       //##add ScicosLab interfacing function
       txt='addinter(libn,blknamint+''_sci'');'
       ierr=execstr(txt,errcatch=%t)
       if ~ierr then
         ok=%f;
         x_message(['sorry link problem';catenate(lasterror())]);
         return;
       end
     end
  end
endfunction

function [txt]=convpathforwin(path)
//Copyright (c) 1989-2011 Metalau project INRIA

//** convpathforwin : convert path that only include
//                    a single '\' in a '\\'
//
// Input : path : the path name to be converted
//                a single string.
//
// Output : txt : the path converted
//                a single string.
//

  //@@ define initial output
  txt=''

  //@@ parse path
  for j=1:length(path)

    if part(path,j)=='\' then
      //@@ begin of string path
      if j==1 then
        if part(path,j+1)<>'\' then
          txt=txt+'\';
        end

      //@@ end of string path
      elseif j==length(path) then
        if part(path,j-1)<>'\' then
          txt=txt+'\';
        end

      //@@ somewhere in string path
      else
        if part(path,j-1)<>'\' & part(path,j+1)<>'\' then
          txt=txt+'\';
        end
      end
    end

    txt=txt+part(path,j);
  end

endfunction

function [ok]=exportlibforlcc(libs,rpat)
//Copyright (c) 1989-2011 Metalau project INRIA

//** exportlibforlcc : export a lcc.lib file from
//                     an existing dll
//
// Input : libs  : a single string containing path+name
//                 of the (dll) library
//                 for export a lcc.lib file
//
//         rpat  : a target directory for temporary generated files
//
// Output : ok : a boolean variable to say if job has succed
//
// Rmk : the lcc.lib file is generated close to the dll file,
//       in the same directory (<> rpat if it is not informed)
//

//** get lhs,rhs nb paramaters
// [lhs,rhs]=argn(0);

//** extract path, name and extension of libs
  [path,fname,extension]=fileparts(libs);
  
  //** convert path of libs if needed
  Elibs=convpathforwin(libs)

  //** check rhs paramaters
  if nargin <= 1 then
    rpat = path
    [Erpat,fname,extension]=fileparts(Elibs);
  else
    //** convert path of rpat if needed
    Erpat=convpathforwin(rpat)
  end

  //** run pedumd to extract info from dll file
  //** .lcc file is generated in rpat directory
  ierr=execstr('unix(''pedump /exp """"''+..
               Elibs+''.dll"""" >""""''+..
               Erpat+''\''+fname+''.lcc""""'')','errcatch');

  if ierr<>0 then
    ok=%f
    //add a message here please
    return
  end

  //** generate an .exp file for buildlib of lcc
  //** .exp file is generated in rpat directory
  fw=mopen(rpat+'\'+fname+'.exp',"w");
  fr=mopen(rpat+'\'+fname+'.lcc',"r");
  if (meof(fr) == 0) then
    line=mfscanf(1,fr,"%s");
    mfprintf(fw,"%s\n",line);
   //printf('.');
  end
  while ( meof(fr) == 0)
    line=mfscanf(1,fr,"%s");
    if ~isempty(line) then
      mfprintf(fw,"_%s\n",line);
    end
  end
  mclose(fw);
  mclose(fr);

  //** run buildlib and then generate lcc.lib file
  //** .exp is read from rpat
  //** lcc.lib is generated in path (of the dll file)
  command='buildLib ""'+Erpat+'\'+fname+'.exp""'+...
          ' ""'+Elibs+'lcc.lib""'+' ""'+Elibs+'.dll""';
  ierr=execstr('unix(command)','errcatch')
  if ierr<>0 then
    ok=%f
    //add a message here please
    return
  end

endfunction

function [SCode]=gen_loader(blknam,for_link,with_int)
//Copyright (c) 1989-2011 Metalau project INRIA

//** gen_loader : generates the ScicosLab script to load the
//                newly created block into ScicosLab.
//
// Input : blknam   : the name of the block to compile
//         for_link : other external libraries to link with blknam
//         with_int : a flag to load an ScicosLab interfacing function
//                    of a standalone scicos simulator
//
// Output : SCode : the text of the loader file
//

  //** check rhs paramaters
  //[lhs,rhs]=argn(0);

  if nargin <= 1 then for_link=[], end
  if nargin <= 2 then with_int=%f, end
  
  SCode=['// Script file used to load the ""compiled""'
         '// scicos block into ScicosLab'
         ''
         '//Copyright (c) 1989-2011 Metalau project INRIA'
         ''
         '//@@ Define the name of the block'
         'blknam='+sci2exp(blknam)+';';
         ''
         '//** Get the absolute path of this loader file'
         'DIR=get_current_exec_dir();'
         'if DIR=='''' then'
         '  DIR=getcwd();'
         'else'
         '  end_char=part(DIR,length(DIR));'
         '  if end_char==''/''|end_char==''\'' then'
         '    DIR=part(DIR,1:length(DIR)-1);'
         '  end'
         'end'
         'DIR=DIR+''/'''
         ''
         '//** Define Makefile name'
         'Makename=DIR+''Makefile_''+blknam;'
         ''
         '//** Unlink if necessary'
         '[a,b]=c_link(blknam);'
         'while a'
         '  ulink(b);'
         '  [a,b]=c_link(blknam);'
         'end';
         ''
         '//** Run Makefile'
         'libn=ilib_compile('+sci2exp('lib'+blknam)+',Makename);'
         ''
         '//** Adjust path name of object files'
         'if %win32 then'
         '  fileso=strsubst(libn,''/'',''\'');'
         'else'
         '  fileso=strsubst(libn,''\'',''/'');'
         'end';
         ''
         '//@@ Inform %scicos_libs with library'
         'if exists(''%scicos_libs'') then'
         '  if isempty(find(fileso==%scicos_libs)) then'
         '    %scicos_libs=[%scicos_libs,fileso];'
         '  end'
         'else'
         '  %scicos_libs=[fileso];'
         'end'
         '']

  if ~isempty(for_link) then
    SCode=[SCode
           '//** Link otherlibs'
           for_link
           '']
  end

  SCode=[SCode
         '//** Link block routine in ScicosLab'
         'link(fileso,blknam,''c'');'
         ''
         '//** Load the gui function';
         'if file(''exists'',DIR+blknam+''_c.sci'') then'
         '  exec(DIR+blknam+''_c.sci'');'
         'end'
         '']

  //@@ ScicosLab interfacing function
  if with_int then

    //## define name of interf lib
    l_blknam=length(blknam);
    //l_blknam=(l_blknam>17)*17 + (l_blknam<=17)*l_blknam;
    blknamint='int'+part(blknam,1:l_blknam);

    SCode=[SCode
           '//## Define name of interf lib"
           'l_blknam=length(blknam);'
           '//l_blknam=(l_blknam>17)*17 + (l_blknam<=17)*l_blknam;'
           'blknamint=''int''+part(blknam,1:l_blknam);'
           'Makename=DIR+''Makefile_''+blknamint;'
           ''
           '//** Unlink if necessary'
           '[a,b]=c_link(blknamint+''_sci'');'
           'while a'
           '  ulink(b);'
           '  [a,b]=c_link(blknam+''_sci'');'
           'end';
           ''
           '//** Run Makefile'
           'libn=ilib_compile('+sci2exp('lib'+blknamint)+',Makename);'
           ''
           '//** Adjust path name of object files'
           'if %win32 then'
           '  fileso=strsubst(libn,''/'',''\'');'
           'else'
           '  fileso=strsubst(libn,''\'',''/'');'
           'end';
           ''
           '//## Link and add ScicosLab function of the standalone.'
           'addinter(fileso,blknamint+''_sci'');'
           '']

  end

  SCode=[SCode;
         '//@@ Clear the used variabe'
         'clear blknam'
         'clear l_blknam'
         'clear blknamint'
         'clear Makename'
         'clear DIR'
         'clear fileso'
         'clear libn'
         'clear a'
         'clear b'
         '']

endfunction

function [T]=gen_make_lccwin32(blknam,files,filestan,libs,ldflags,cflags)
//Copyright (c) 1989-2011 Metalau project INRIA

//** gen_make_lccwin32 : generate text of the Makefile
//              for scicos code generator for
//              lccwin32 compiler
//
// Input : blknam   : name of the library
//         files    : files to be compiled
//         filestan : files to be compiled and included in
//                    the standalone code
//         libs     :  a vector of object files
//                    to include in the building process
//         ldflags  : linker flags
//         cflags   : C compiler flags
//
// Output : T : the text of the makefile
//

  WSCI=strsubst(SCI,'/','\')

  T=["#generated by buildnewblock: Please do not edit this file"
     "#"
     "#Copyright (c) 1989-2011 Metalau project INRIA"
     "#"
     "# ------------------------------------------------------"
     "SCIDIR       = "+SCI
     "SCIDIR1      = "+WSCI
     "DUMPEXTS     = ""$(SCIDIR1)\bin\dumpexts-nsp"""
     "SCIIMPLIB    = ""$(SCIDIR1)\bin\LibScilablcc.lib"""
     "SCILIBS      = ""$(SCIDIR1)\bin\LibScilablcc.lib"""
     "LIBRARY      = lib"+blknam
     "CC           = lcc"
     "LINKER       = lcclnk"]

  if ~isempty(libs) then
    T=[T;
       "OTHERLIBS    = "+libs]
  else
    T=[T;
       "OTHERLIBS    = "]
  end

  T=[T;
     "LINKER_FLAGS = -dll -nounderscores"
     "INCLUDES     = -I""$(SCIDIR1)\routines\f2c""" 
     "CC_COMMON    = -DWIN32 -DSTRICT -DFORDLL -D__STDC__ $(INCLUDES)"
     "CC_OPTIONS   = $(CC_COMMON)"
     "CFLAGS       = $(CC_OPTIONS) -I""$(SCIDIR1)\routines"" "+cflags
     "FFLAGS       = $(FC_OPTIONS) -I""$(SCIDIR1)\routines"""
     ""
     "OBJS         = "+strcat(files+'.obj',' ')]

  if ~filestan.equal[''] then
    T=[T;
       "OBJSSTAN     = "+strcat(filestan+'.obj',' ')]
  end

  T=[T;
     ""
     "all :: $(LIBRARY).dll"
     ""
     "$(LIBRARY).dll: $(OBJS)"
     ascii(9)+"@echo Creation of dll $(LIBRARY).dll and import lib from ..."
     ascii(9)+"@echo $(OBJS)"
     ascii(9)+"@$(DUMPEXTS) -o ""$(LIBRARY).def"" ""$*"" $(OBJS)"
     ascii(9)+"@$(LINKER) $(LINKER_FLAGS) $(OBJS) $(SCIIMPLIB) $(OTHERLIBS) "+...
              " $(XLIBSBIN) $(TERMCAPLIB) $*.def -o "+...
              " $(LIBRARY).dll"
     ".c.obj:"
     ascii(9)+"@echo ------------- Compile file $< --------------"
     ascii(9)+"$(CC) $(CFLAGS) $<"
     ".f.obj:"
     ascii(9)+"@echo ----------- Compile file $*.f (using f2c) -------------"
     ascii(9)+"@""$(SCIDIR1)\bin\f2c.exe"" $(FFLAGS) $*.f "
     ascii(9)+"@$(CC) $(CFLAGS) $*.c"
     ascii(9)+"@del $*.c"
     "clean::"
     ascii(9)+"@del *.CKP"
     ascii(9)+"@del *.ln"
     ascii(9)+"@del *.BAK"
     ascii(9)+"@del *.bak"
     ascii(9)+"@del *.def"
     ascii(9)+"@del *.dll"
     ascii(9)+"@del *.exp"
     ascii(9)+"@del *.lib"
     ascii(9)+"@del errs"
     ascii(9)+"@del *~"
     ascii(9)+"@del *.obj"
     ascii(9)+"@del .emacs_*"
     ascii(9)+"@del tags"
     ascii(9)+"@del TAGS"
     ascii(9)+"@del make.log"
     ""
     "distclean:: clean"
     ""]

  if ~filestan.equal[''] then
    T=[T;
       "standalone: $(OBJSSTAN) "
        ascii(9)+"$(LINKER) $(LINKER_FLAGS) $(OBJSSTAN)"+...
                 "$(OTHERLIBS) $(SCILIBS)  /out:standalone.exe"]
  end
endfunction


function [Makename,txt]=gen_make(blknam,files,filestan,libs,Makename,ldflags,cflags)
//Copyright (c) 1989-2011 Metalau project INRIA
  
//** gen_make : generate text of the Makefile
//              for scicos code generator
//              That's a wrapper for
//                 gen_make_lccwin32
//                 gen_make_win32
//                 gen_make_unix
//
// Input : blknam   : name of the Scicos block to compile
//         files    : files to be compiled
//         filestan : files to be compiled and included in
//                    the standalone code
//         libs     :  a vector of object files
//                    to include in the building process
//         Makename : the name of Makefile file
//         ldflags  : linker flags
//         cflags   : C compiler flags
//
// Output : Makename : the name of Makefile file (modified
//                     for the case of win32)
//
//          txt      : the text of the Makefile
//

  //** check rhs paramaters
  //[lhs,rhs]=argn(0);

  if nargin <= 1 then files    = blknam, end
  if nargin <= 2 then filestan = '', end
  if nargin <= 3 then libs     = '', end
  if nargin <= 4 then Makename = 'Makefile_'+blknam, end
  if nargin <= 5 then ldflags  = '', end
  if nargin <= 6 then cflags   = '', end

  if with_lcc()==%t then
    //** generate Makefile for LCC compilator
    txt=gen_make_lccwin32(blknam,files,filestan,libs,ldflags,cflags)
    //Makename = strsubst(Makename,'/','\')+'.lcc'
    Makename = Makename+'.lcc'
  elseif %win32 then
    //** generate Makefile for Crosoft compilator
    txt=gen_make_win32(blknam,files,filestan,libs,ldflags,cflags)
    //select COMPILER;
    //  case 'VC++' then
        //Makename = strsubst(Makename,'/','\')+'.mak'
        Makename = Makename+'.mak'
    //end
  else
    //** unix case
    txt=gen_make_unix(blknam,files,filestan,libs,ldflags,cflags)
  end
endfunction

function [T]=gen_make_unix(blknam,files,filestan,libs,ldflags,cflags)
//Copyright (c) 1989-2011 Metalau project INRIA

//** gen_make_unix : generate text of the Makefile
//              for scicos code generator for cc/gcc
//              unix compiler
//
// Input : blknam   : name of the library
//         files    : files to be compiled
//         filestan : files to be compiled and included in
//                    the standalone code
//         libs     : a vector of object files
//                    to include in the building process
//         ldflags  : linker flags
//         cflags   : C compiler flags
//
// Output : T : the text of the makefile
//

  // get nsp path 
  NSP = getenv('NSP');
  use_msys = %win32;
  if %win32 then 
      // since we are on gen_Make_unix and %win32 is true means that
      // we are compiling with a linux env on windows
      // with msys2 we should keep the volume name
      // if we use msys2 we keep the volume name 
      // if part(NSP,2)==":" then NSP=part(NSP,3:length(NSP));end
  end  
  //test to know which directory we must include
  dirname=file('join',[NSP;'include'])
  if file('exist',dirname) then
    incl="-I$(NSPDIR)/include/ -I$(NSPDIR)/include/scicos"
  else
    incl="-I$(NSPDIR)/src/include/ -I$(NSPDIR)/src/include/scicos"
  end
  
  // get scicos path
  scicospath=get_scicospath()
  scicosdir=scicospath+'/src';
  scicoslib=scicospath+'/src/libscicos.a';
  
  T=["#generated by buildnewblock: Please do not edit this file"
     "#"
     "#Copyright (c) 1989-2011 Metalau project INRIA"
     "#"
     "# ------------------------------------------------------"
     "NSPDIR       = "+NSP
     "SCIDIR       = $(NSPDIR)"
     "SCICOSDIR    = "+scicosdir
     "SCICOSLIB    = "+scicoslib
     "LIBRARY      = lib"+blknam]

  if isempty(libs) then libs = m2s([]);end
  if use_msys then
    libs = [libs; '-L$(SCICOSDIR) -lscicos'];
  end
  
  if ~isempty(libs) then
    T=[T;
       "OTHERLIBS    = " + catenate(libs,sep=" ")]
  else
    T=[T;
       "OTHERLIBS    = "]
  end

  T=[T;
     ""
     "OBJS         = "+strcat(files+'.o',' ')]

  if ~filestan.equal[''] then
    T=[T;
       "OBJSSTAN     = "+strcat(filestan+'.o',' ')]
  end

  if ~isempty(cflags) then
    T=[T;
       "include $(NSPDIR)/Makefile.incl";
       "CFLAGS    = $(CC_OPTIONS) -DFORDLL "+incl+" "+cflags]
  else
    T=[T;
       "include $(NSPDIR)/Makefile.incl";
       "CFLAGS    = $(CC_OPTIONS) -DFORDLL "+incl]
  end

  T=[T;
     "FFLAGS    = $(FC_OPTIONS) -DFORDLL "+incl
     "include $(NSPDIR)/config/Makeso.incl"]

  if ~filestan.equal[''] then
    T=[T;
       "standalone: $(OBJSSTAN) "
       "#"+ascii(9)+"f77 $(FFLAGS) -o $@  $(OBJSSTAN) $(OTHERLIBS) $(SCILIBS)"
       ascii(9)+"gcc $(CFLAGS) -lm -lgfortran -o $@ $(OBJSSTAN) $(OTHERLIBS) $(SCICOSLIB) $(NSPLIBS) -Wl,--no-whole-archive $(EXTERNLIBS) $(FC_LDFLAGS)"]
  end

endfunction

function [T]=gen_make_win32(blknam,files,filestan,libs,ldflags,cflags)
//Copyright (c) 1989-2011 Metalau project INRIA

//** gen_make_win32 : generate text of the Makefile
//              for scicos code generator for
//              Mswin32 compilers
//
// Input : blknam   : name of the library
//         files    : files to be compiled
//         filestan : files to be compiled and included in
//                    the standalone code
//         libs     :  a vector of object files
//                    to include in the building process
//         ldflags  : linker flags
//         cflags   : C compiler flags
//
// Output : T : the text of the makefile
//

  T=["#generated by buildnewblock: Please do not edit this file"
     "#"
     "#Copyright (c) 1989-2011 Metalau project INRIA"
     "#"
     "# ------------------------------------------------------"
     "NSPDIR       = "+getenv('NSP')
     "SCICOSDIR    = "+get_scicospath()
     "DUMPEXTS     = ""$(NSPDIR)/bin/dumpexts-nsp"""
     "NSPIMPLIB    = ""$(NSPDIR)/bin/libnsp.lib"""
     "COSIMPLIB    = ""$(SCICOSDIR)/src/libscicos.lib"""
     "NSPLIBS      = ""$(NSPDIR)/bin/libnsp.dll"""
     "COSLIBS      = ""$(SCICOSDIR)/src/libscicos.dll"""
     "LIBRARY      = lib"+blknam
     "CC           = cl"
     "LINKER       = link"]

  if isempty(libs) then libs = m2s([]);end
  
  if ~isempty(libs) then
    T=[T;
       "OTHERLIBS    = " + catenate(libs,sep=" ")]
  else
    T=[T;
       "OTHERLIBS    = "]
  end
  
  if %win64 then 
    T_LINK = "LINKER_FLAGS = /NOLOGO /machine:x64"
  else
    T_LINK = "LINKER_FLAGS = /NOLOGO /machine:ix86"
  end
  
  T=[T;
     T_LINK;
     "INCLUDES     = -I""$(NSPDIR)/routines/f2c"""
     "CC_COMMON    = -D__MSC__ -DWIN32 -c -DSTRICT -nologo $(INCLUDES)"
     "CC_OPTIONS   = $(CC_COMMON) -Od -Gd -W3"]
  if ~isempty(cflags) then
    T=[T;
       "CFLAGS       = $(CC_OPTIONS) -DFORDLL -I""$(NSPDIR)/include"" "+cflags]
  else
    T=[T;
       "CFLAGS       = $(CC_OPTIONS) -DFORDLL -I""$(NSPDIR)/include"""]
  end
  T=[T;
     "FFLAGS       = $(FC_OPTIONS) -DFORDLL -I""$(NSPDIR)/include"""
     ""
     "OBJS         = "+strcat(files+'.obj',' ')]

  if ~filestan.equal[''] then
    T=[T;
       "OBJSSTAN     = "+strcat(filestan+'.obj',' ')]
  end

  T=[T;
     ""
     "all :: $(LIBRARY).dll"
     ""
     "$(LIBRARY).dll: $(OBJS)"
     ascii(9)+"@echo Creation of dll $(LIBRARY).dll and import lib from ..."
     ascii(9)+"@echo $(OBJS)"
     ascii(9)+"@$(DUMPEXTS) -o ""$*.def"" ""$*.dll"" $**"
     ascii(9)+"@$(LINKER) $(LINKER_FLAGS) $(OBJS) $(NSPIMPLIB) $(COSIMPLIB) $(OTHERLIBS)"+...
              " /nologo /dll /out:""$*.dll"""+...
              " /implib:""$*.lib"" /def:""$*.def"""
     ".c.obj:"
     ascii(9)+"@echo ------------- Compile file $< --------------"
     ascii(9)+"$(CC) $(CFLAGS) $<"
     ".f.obj:"
     ascii(9)+"@echo ----------- Compile file $*.f (using f2c) -------------"
     ascii(9)+"@""$(NSPDIR)/bin/f2c.exe"" $(FFLAGS) $*.f"
     ascii(9)+"@$(CC) $(CFLAGS) $*.c"
     ascii(9)+"@del $*.c"
     "clean::"
     ascii(9)+"@del *.CKP"
     ascii(9)+"@del *.ln"
     ascii(9)+"@del *.BAK"
     ascii(9)+"@del *.bak"
     ascii(9)+"@del *.def"
     ascii(9)+"@del *.dll"
     ascii(9)+"@del *.exp"
     ascii(9)+"@del *.lib"
     ascii(9)+"@del errs"
     ascii(9)+"@del *~"
     ascii(9)+"@del *.obj"
     ascii(9)+"@del .emacs_*"
     ascii(9)+"@del tags"
     ascii(9)+"@del TAGS"
     ascii(9)+"@del make.log"
     ""
     "distclean:: clean"
     ""]

  if ~filestan.equal[''] then
    T=[T;
       "standalone: $(OBJSSTAN) "
        ascii(9)+"$(LINKER) $(LINKER_FLAGS) $(OBJSSTAN)"+...
                 " $(OTHERLIBS) $(NSPIMPLIB) $(COSIMPLIB) /out:standalone.exe"]
  end

endfunction


function [ok,libs,for_link]=link_olibs(libs,rpat)
//Copyright (c) 1989-2011 Metalau project INRIA

//** link_olibs   : links otherlibs in ScicosLab
//                  for scicos C generated block
//
// Input : libs   : a matrix of string containing path+name
//                 of the libraries
//
//         rpat   : a target directory for temporary generated files
//
// Output : ok    : a boolean variable to say if job has succed
//          libs  : a matrix of string containing path+name
//                  of the libraries
//          for_link : a vector of strings with link cmd
//                     for exec or for loader.sce
//
  ok=%t
  // decl and set local variables
  x=''
  xlibs=m2s([]);
  for_link=m2s([]);

  //** get out from this function if
  //   there is nothing to do
  if isempty(libs) then return, end

  //** LCC
  if with_lcc()==%t then
    //** add lcc.lib
    //   for compatibility with dll of
    //   msvc
    libs=libs(:)';
    for x=libs
      //** extract path, name and extension of libs
      [path,fname,extension]=fileparts(x);
      if nargin <= 1 then
        rpat = path
      end
      if (extension == '') then
        //** search dll
        if file('exists',x+'.dll') then
          if ~file('exists',x+'lcc.lib') then
            //** export lcc.lib
            x_message(['I will try to export a '+x+'lcc.lib']);
            ok=exportlibforlcc(x,rpat)
            if ~ok then
              x_message(['Can''t export a '+path+fname+'lcc.lib';
                         'Please try to do your own lcc.lib file with';
                         'the xx scilab function or change the path';
                         'of your library '+x+'.dll']);
              ok=%f;
              return
            end
          end
          for_link=[for_link;x+'.dll']
          link(for_link($));
          xlibs=[xlibs;x+'lcc.lib']

        //** search DLL
        elseif file('exists',x+'.DLL') then
          if ~file('exists',x+'lcc.lib') then
            //** export lcc.lib
            x_message(['I will try to export a '+x+'lcc.lib']);
            ok=exportlibforlcc(x,rpat)
            if ~ok then
              x_message(['Can''t export a '+path+fname+'lcc.lib';
                         'Please try to do your own lcc.lib file with';
                         'the xx scilab function or change the path';
                         'of your library '+x+'.dll']);
              ok=%f;
              return
            end
          end
          for_link=[for_link;x+'.DLL']
          link(for_link($));
          xlibs=[xlibs;x+'lcc.lib']

        else
          //** no extension
          //   no .dll exists
          //   do something here please ?
          ok=%f
          //pause
          x_message(['I don''t know what to do !';
		     'Line 1038 of buildnewblock.sci';
                     'Please report to scicos@inria.fr'])
        end
      elseif ~file('exists',x) then
        x_message(['Can''t include '+x;
                   'That file doesn''t exist';
                   catenate(lasterror())])
        ok=%f
        return
      //** extension assume that user know what he does
      else
        //** compiled object (.obj)
        //** compiled object doesn't need to be linked
        if extension=='.obj' | extension=='.OBJ'  then
          xlibs=[xlibs;x]
        //** library (.dll)
        elseif extension=='.dll' | extension=='.DLL' then
          for_link=[for_link;x]
          link(for_link($));
          if ~file('exists',file('join',[path;fname+'lcc.lib'])) then
            //** export lcc.lib
            x_message(['I will try to export a '+path+fname+'lcc.lib']);
            ok=exportlibforlcc(path+fname,rpat)
            if ~ok then
              x_message(['Can''t export a '+path+fname+'lcc.lib';
                         'Please try to do your own lcc.lib file with';
                         'the xx scilab function or change the path';
                         'of your library '+x+'.dll']);
              ok=%f;
              return
            end
          end
          xlibs=[xlibs;path+fname+'lcc.lib']

        //** library (.lib)
        elseif extension=='.lib' | extension=='.ilib' then
          if file('exists',file('join',[path;fname+'.dll'])) then
            for_link=[for_link;path+fname+'.dll']
            link(for_link($));
          elseif file('exists',path+fname+'.DLL') then
            for_link=[for_link;path+fname+'.DLL']
            link(for_link($));
          else
            //link(x);
            x_message(['I don''t know what to do !';
		       'Line 1083 of buildnewblock.sci';
                      'Please report to scicos@inria.fr'])
            ok=%f
            //pause
          end
          xlibs=[xlibs;x]
        else
          //link(x);
          x_message(['I don''t know what to do !';
		     'Line 1092 of buildnewblock.sci';
                     'Please report to scicos@inria.fr'])
          ok=%f
          //pause
        end
      end
    end

  //** MSVC
  elseif %win32 then
    //** add .lib or .ilib
    libs=libs(:)';
    for x=libs
      [path,fname,extension]=fileparts(x);
      if (extension == '') then
        //** search ilib
        if file('exists',x+'.ilib') then
          //** search dll
          if file('exists',x+'.dll') then
            for_link=[for_link;x+'.dll']
            link(for_link($));
          //** search DLL
          elseif file('exists',x+'.DLL') then
            for_link=[for_link;x+'.DLL']
            link(for_link($));
          //** no .dll, .DLL
          else
            x_message(['I cant''t find a dll !';
                       'Please report to scicos@inria.fr'])
            ok=%f
            //pause
          end
          xlibs=[xlibs;x+'.ilib']
        //** search lib
        elseif file('exists',x+'.lib') then
          //** search dll
          if file('exists',x+'.dll') then
            for_link=[for_link;x+'.dll']
            link(for_link($));
          //** search DLL
          elseif file('exists',x+'.DLL') then
            for_link=[for_link;x+'.DLL']
            link(for_link($));
          //** no .dll, .DLL
          else
            x_message(['I cant''t find a dll !';
                       'Please report to scicos@inria.fr'])
            ok=%f
            //pause
          end
          xlibs=[xlibs;x+'.lib']
        else
          //** no extension
          //   no .lib, no .ilib exists
          //   do something here please ?
          x_message(['I don''t know what to do !';
		     'Line 1148 of buildnewblock.sci';
                     'Please report to scicos@inria.fr'])
          ok=%f
          //pause
        end
      elseif ~file('exists',x) then
        x_message(['Can''t include '+x;
                   'That file doesn''t exist';
                   catenate(lasterror())])
        ok=%f
        return
      //** extension assume that user know what he does
      else
        //** compiled object (.obj)
        //** compiled object doesn't need to be linked
        if extension=='.obj' | extension=='.OBJ'  then
          xlibs=[xlibs;x]
        //** library (.dll)
        elseif extension=='.dll' | extension=='.DLL' then
          for_link=[for_link;x]
          link(for_link($));
          if file('exists',file('join',[path;fname+'.ilib'])) then
            xlibs=[xlibs;file('join',[path;fname+'.ilib'])]
          elseif file('exists',file('join',[path;fname+'.lib'])) then
            xlibs=[xlibs;file('join',[path;fname+'.lib'])]
          else
            //link(x);
            x_message(['I don''t know what to do !';
		       'Line 1176 of buildnewblock.sci';
                       'Please report to scicos@inria.fr'])
            ok=%f
            //pause
          end
        //** library (.lib)
        elseif extension=='.lib' | extension=='.ilib' then
          if file('exists',file('join',[path;fname+'.dll'])) then
            for_link=[for_link;file('join',[path;fname+'.dll'])]
            link(for_link($));
          elseif file('exists',file('join',[path;fname+'.DLL'])) then
            for_link=[for_link;file('join',[path;fname+'.DLL'])]
            link(for_link($));
          else
            //link(x);
            x_message(['I don''t know what to do !';
		       'Line 1113 of buildnewblock.sci';
                       'Please report to scicos@inria.fr'])
            ok=%f
            //pause
          end
          xlibs=[xlibs;x]
        else
          //link(x);
          x_message(['I don''t know what to do !';
		     'Line 1201 of buildnewblock.sci';
                     'Please report to scicos@inria.fr'])
          ok=%f
          //pause
        end
      end
    end

  //** Unix
  else
    //** add .a
    //   for compatibility test if we have already a .a
    libs=libs(:)';
    for x=libs
      [path,fname,extension]=fileparts(x);
      //** no extension. Assume that's a so library
      if (extension == '') then
       if file('exists',file('join',[path;fname+'.so'])) then
        for_link=[for_link;x+'.so']
        link(for_link($));
       elseif file('exists',file('join',[path;fname+'.SO'])) then
        for_link=[for_link;x+'.SO']
        link(for_link($));
       else
         //link(x);
         x_message(['I don''t know what to do !';
		    'Line 1227 of buildnewblock.sci';
                    'Please report to scicos@inria.fr'])
         ok=%f
         //pause
       end
       if file('exists',x+'.a') then
         xlibs=[xlibs;x+'.a']
       elseif file('exists',x+'.A') then
         xlibs=[xlibs;x+'.A']
       else
         //link(x);
         x_message(['I don''t know what to do !';
		    'Line 1239 of buildnewblock.sci';
                    'Please report to scicos@inria.fr'])
         ok=%f
         //pause
       end
      elseif ~file('exists',x) then
        x_message(['Can''t include '+x;
                   'That file doesn''t exist';
                   catenate(lasterror())])
        ok=%f
        return
      //** extension assume that user know what he does
      else
        //** compiled object (.o)
        //** compiled object doesn't need to be linked
        if extension=='.o' | extension=='.O'  then
          xlibs=[xlibs;x]
        //** library (.so)
        elseif extension=='.so' | extension=='.SO' then
          for_link=[for_link;x]
          link(for_link($));
          if file('exists',file('join',[path;fname+'.a'])) then
            xlibs=[xlibs;file('join',[path;fname+'.a'])]
          elseif file('exists',file('join',[path;fname+'.A'])) then
            xlibs=[xlibs;file('join',[path;fname+'.A'])]
          else
            //link(x);
            x_message(['I don''t know what to do !';
		       'Line 1188 of buildnewblock.sci';
                       'Please report to scicos@inria.fr'])
            ok=%f
            //pause
          end
        //** library (.a)
        elseif extension=='.a' | extension=='.A' then
          if file('exists',file('join',[path;fname+'.so'])) then
            for_link=[for_link;file('join',[path;fname+'.so'])]
            link(for_link($));
          elseif file('exists',file('join',[path;fname+'.SO'])) then
            for_link=[for_link;file('join',[path;fname+'.SO'])]
            link(for_link($));
          else
            //link(x);
            x_message(['I don''t know what to do !';
		       'Line 1204 of buildnewblock.sci';
                       'Please report to scicos@inria.fr'])
            ok=%f
            //pause
          end
          xlibs=[xlibs;x]
        else
          //link(x);
          x_message(['I don''t know what to do !';
		     'Line 1292 of buildnewblock.sci';
                     'Please report to scicos@inria.fr'])
          ok=%f
          //pause
        end
      end
    end
  end

  //** add double quote for include in
  //   Makefile
  libs=xlibs
  if ~isempty(libs) then 
    if (%win32) then
      libs='""'+libs+'""'
    else
      libs=''''+libs+''''
    end
    //** concatenate libs for Makefile
    if size(libs,1)<>1 then
      libs = strcat(libs,' ')
    end
  end
    
  //** return link cmd for for_link
  if ~isempty(for_link) then
    for_link = 'link(""'+for_link+'"");';
  end

endfunction
