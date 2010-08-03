function ok=scicos_block_link(funam,txt,flag)
// compile and link funnam given by text txt 
  if flag=='c' then mflag='C', else mflag='fortran',end
  if stripblanks(funam)==emptystr() then 
    ok=%f;
    x_message('sorry file name not defined in '+flag+' block');return
  end
  cur_wd = getcwd();
  chdir(getenv('NSP_TMPDIR'));
  //  mputl(txt,funam+'.'+flag);
  F=fopen(funam+'.'+flag,mode="w");
  F.put_smatrix[txt];
  F.close[]
  //we should improve ilib_for_link.
  //libn=ilib_for_link(funam,funam+'.o',[],flag,makename='Makelib',loadername='loader.sce');
  ilib_link_gen_loader(funam,flag);
  ilib_link_gen_Make(funam,funam+'.o',"",'Makelib',"", "","","","");
  [make_command,lib_name_make,lib_name,path,makename,files]= ilib_compile_get_names('lib'+funam,'Makelib',funam+'.o');
  ierr= execstr('system(make_command+makename + '' ''+ files)', errcatch=%t);
  if ierr==%f then 
    chdir(cur_wd)
    x_message('Sorry compilation problem:\n\n'+catenate(lasterror()));
    ok=%f;return;
  end
  [a,b]=c_link(funam); while a;  ulink(b);[a,b]=c_link(funam);end
  ierr= execstr('system(make_command+makename + '' ''+ lib_name)', errcatch=%t);
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
