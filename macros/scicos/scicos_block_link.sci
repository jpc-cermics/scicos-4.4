function ok=scicos_block_link(funam,txt,flag,libs,cflags)
// compile and link funnam given by text txt 
  if nargin < 4 then libs=[];end
  if nargin < 5 then cflags="";end
  
  if flag=='c' then mflag='C', else mflag='fortran',end
  if stripblanks(funam)==emptystr() then 
    ok=%f;
    x_message('sorry file name not defined in '+flag+' block');
    return
  end
  cur_wd = getcwd();
  chdir(getenv('NSP_TMPDIR'));
  //  mputl(txt,funam+'.'+flag);
  F=fopen(funam+'.'+flag,mode="w");
  F.put_smatrix[txt];
  F.close[]
  ilib_link_gen_loader(funam,flag,libs=libs);
  ilib_link_gen_Make(funam,funam+'.o',libs,'Makelib',"", "",cflags,"","",flag);
  [make_command,lib_name_make,lib_name,path,makename,files]= ...
      ilib_compile_get_names('lib'+funam,'Makelib',funam+'.o');
  mcm = strcat(make_command,' ')+' '+makename + ' ';
  ierr= execstr('system(mcm+files);', errcatch=%t);
  if ierr==%f then 
    chdir(cur_wd)
    x_message('Sorry compilation problem:\n\n'+catenate(lasterror()));
    ok=%f;return;
  end
  [a,b]=c_link(funam); while a;  ulink(b);[a,b]=c_link(funam);end
  ierr= execstr('system(mcm+lib_name);', errcatch=%t);
  if ierr==%f then 
    chdir(cur_wd)
    x_message('Sorry shared lib cannot be created:\n\n'+catenate(lasterror()));
    ok=%f;return;
  end
  ierr= exec('loader.sce',errcatch=%t)
  if ierr==%f then     
    chdir(cur_wd);
    x_message('Sorry link problem:\n\n'+catenate(lasterror()));
    ok=%f;return;
  end
  chdir(cur_wd)
  ok=%t
endfunction
