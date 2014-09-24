function [ok,tt,cancel,libss,cflags]=CC4(funam,tt,libss,cflags)
// Copyright INRIA
//
  
  function [libss,cflags,ok,cancel]=get_linker_args(txt,funam,flag,libss="",cflags="")
  // get extra libs and cflags 
    if nargin < 4 then libss="";end
    if nargin < 5 then cflags="";end
    if size(libss,'*')<>1 then 
      libss=catenate(libss,sep=' ');
    end
    label=[libss;cflags];
    ok=%f;cancel=%f;
    
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
      if ~isempty(strindex(cflags,'''')) | ~isempty(strindex(cflags,'""')) then
	ierr=execstr('cflags=evstr(cflags)',errcatch=%t)
	if ~ierr then
	  message(['Error(s) in Additionnal compiler flag(s)'])
	  chdir(cur_wd);
	  ok=%f;
	end
      else
	cflags=split(cflags,msep=%t,sep=' ;');
	cflags=strcat(cflags,' ')
      end

      //@@ check libraries existence
      // This is not good because a user can give -L/foo -lfoo 
      for i=1:size(libss,'*')
	lib_dll=libss(i)+%shext;
	ifexst=file('exists',lib_dll);
	if ~ifexst then message ('the library '+lib_dll+' doesn''t exists');ok=%f;end
      end
    end
  endfunction

  function txt= CC4_default(funam)
    // skeleton 
    txt=['#include <scicos/scicos_block4.h>';
	 ''
	 'void '+funam+'(scicos_block *block,int flag)'
	 '{'
	 '  if (flag == 4)';'    {/* initialization */';'    }'];
    if out<>0 then
      txt.concatd[['  else if (flag == 1)';'    {/* output computation */ ';'    }']];
    end
    if nx<>0 then
      txt.concatd[['  else if (flag == 0)';'    {/* derivative or residual computation */';'    }']];
    end
    if nzcr<>0 then
      txt.concatd[['  else if (flag == 9)';'    {/* zero crossing surface and mode computation */';'    }']];
    end
    if nz<>0 then
      txt.concatd[['  else if (flag == 2)';'    {/* computation of next discrete state*/ ';'    }']];
    elseif min(nx,nzcr+nevin)>0 then
      txt.concatd[['  else if (flag == 2)';'    {/* computation of jumped state*/';'    }']];
    end
    if nevout<>0 then
      txt.concatd[['  else if (flag == 3)';'    {/* computation of output event times*/';'    }']];
    end
    txt.concatd[['  else  if (flag == 5)';'     {/* ending */';'    }']];
    txt.concatd[['}';'']];
  endfunction
    
  if nargin < 3 then libss="";end
  if nargin < 4 then cflags="";end
  
  cancel=%f
  if isempty(tt) then
    head = ['Here is a skeleton of the C functions\n'+...
	    'you should fill:'];
    textmp=CC4_default(funam);
  else
    head = ['C code to be edited'];
    textmp=tt;
  end
  
  tt = textmp
  ok   = %t
  cur_wd=getcwd();
  
  // set param of scstxtedit
  while %t 
    txt = editsmat('Cfunc edition',textmp,comment=head);
    if isempty(txt) then 
      // empty answer from editsmat means Cancel edition.
      cancel=%t; ok=%f;break;
    end
    // extra arguments libss and cflags 
    [libss,cflags,ok,cancel]=get_linker_args(txt,funam,'c',libss=libss, cflags=cflags);
    if cancel || ~ok then  break; end
    // try linking 
    [ok]=scicos_block_link(funam,txt,'c',libss,cflags)
    if ok then
      ok = %t;cancel = %f; tt=txt;
      break;
    end
    textmp=txt;
  end
  // back to cur_wd
  chdir(cur_wd);
endfunction
