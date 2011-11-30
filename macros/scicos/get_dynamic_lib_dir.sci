function [libss,cflags,ok,cancel]=get_dynamic_lib_dir(txt,funam,flag,libss,cflags)
// Copyright INRIA
  if nargin < 4 then libs=[];end
  if nargin < 5 then cflags="";end
  label=[libss;cflags];
  cancel=%f
  cur_wd=getcwd();
  chdir(getenv('NSP_TMPDIR'));
  //  mputl(txt,funam+'.'+flag);
  F=fopen(funam+'.'+flag,mode="w");
  F.put_smatrix[txt];
  F.close[];
  
  ok=%f
  
  while ~ok then
    [ok,libss,cflags,label]=getvalue('Linking the '+funam+' function',...
                                    ['External libraries (if any)';
                                     'Additionnal compiler flag(s)'],...
                                     list('str',1,'str',1),label);
    if ~ok then chdir(cur_wd);cancel=%t,return;end
    //@@ check libss
    if ~isempty(strindex(libss,'''')) || ~isempty(strindex(libss,'""')) then
      ierr=execstr('libss=evstr(libss)',errcatch=%t)
      if ~ierr  then
        message(['cannot evaluate strings given for external libraries'])
        chdir(cur_wd);
        ok=%f;
      end
    else
      libss=split(libss,msep=%t,sep=' ;');
      // libss=tokens(libss,[' ',';'])
    end

    //@@ check cflags
    if strindex(cflags,'''')<>[] | strindex(cflags,'""')<>[] then
      ierr=execstr('cflags=evstr(cflags)','errcatch')
      if ~ierr then
        message(['Error(s) in Additionnal compiler flag(s)'])
        chdir(cur_wd);
        ok=%f;
      end
    else
      cflags=split(cflags,msep=%t,sep=' ;');
      cflags=strcat(cflags,' ')
    end

    //@@ check libraries existance
    // This is not good because a user can give -L/foo -lfoo 
    for i=1:size(libss,'*')
      lib_dll=libss(i)+%shext;
      ifexst=file('exists',lib_dll);
      if ~ifexst then message ('the library '+lib_dll+' doesn''t exists');ok=%f;end
    end
  end
  chdir(cur_wd);
endfunction
