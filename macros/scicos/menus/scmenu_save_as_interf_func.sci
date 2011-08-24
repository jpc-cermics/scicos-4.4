function scmenu_save_as_interf_func()
  Cmenu=""
  ok=%f
  while ~ok then
    fname=xgetfile(masks=['Scilab';'*.sci'],save=%t)
    if fname<>emptystr() then 
      [dir,name,ext]=splitfilepath(fname)
      select ext
       case 'sci' then
	ok=%t
      else
	message('Only *.sci files allowed');
	ok=%f
      end
    else
      ok=%t
    end
  end
  if fname<>emptystr() then
    scs_m.props.title(1)=name

    [ok, %wh]=getvalue(['Enter the type of Interf. Func. to create'],
    ['Block(0) or SuperBlock(1)'],list('vec','1'),
    ['1'])
    if ok then
      scs_m.props.title(1)=name
      if  %wh==0 then
	%path=save_super(scs_m,fpath=dir,sim='csuper')
      else
	%path=save_super(scs_m,fpath=dir,sim='super')
      end
      if ~isempty(%path) then 
	ok= exec(%path,errcatch=%t)
	if ~ok then 
	  message(['Error: generated interf file cannot be executed:';
		   catenate(lasterror())]);
	end
      end
    end
  end
endfunction
