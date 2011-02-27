function Export_()
// Export scs_m by redrawing the diagram in a graphic window
// or by exporting scs_m in a graphic file 
// 
  do_export(scs_m)
  Cmenu=''
endfunction

function ExportAll_()
// Export recursively scs_m in graphic files stored in 
// a directory. Since scs_m 
  do_export_all()
  Cmenu=''
endfunction

function do_export(scs_m,fname) 

  function do_export_gwin(scs_m)
  // export to a graphic window
  // jpc 2011 using the restore function 
    
    if ~isempty(winsid()) then 
      old_curwin=xget('window')
      curwin=max(winsid())+1
    else
      old_curwin=[];
      curwin=0;
    end
    xset('window',curwin);
    options=scs_m.props.options
    set_background();
    scs_m=scs_m_remove_gr(scs_m);
    scs_m.props.title(1)='Scilab Graphics of '+scs_m.props.title(1);
    %zoom=restore(curwin,[],1.0);
    drawobjs(scs_m);
    if ~isempty(old_curwin) then xset('window',old_curwin);end
  endfunction

  function do_export_gfile(scs_m,fname) 
  // export to a graphic file according to
  // file extensions. This only works if scs_m 
  // is displayed on the current window.
  // jpc 2011 
    cwin=xget('window');
    xexport(cwin,fname);
  endfunction

  if nargin==1 then
    num=x_choose(['Graphic file';'Graphics window'],'How do you want to export?');
    if num==0 then return;end
    if num<>2 then 
      while %t then 
	fname= xgetfile(save=%t);
	if fname == "" then return;end;
	ext= file('extension',fname);
	if ~or(ext==['.svg', '.pdf', '.eps', '.ps', '.fig', '.png']) then
	  message(['File extension should be .eps, .ps, .png, .pdf,or .svg"]);
	else
	  break;
	end
      end
    end
  end
  rep=%t;
  select num 
   case 1 then rep= execstr('do_export_gfile(scs_m,fname);',errcatch=%t);
   case 2 then rep= execstr('do_export_gwin(scs_m);',errcatch=%t);
  end
  if rep == %f then 
    message(['error while exporting";lasterror()]);
  end
endfunction

function do_export_all()
  // jpc 2011

  function do_export__(scs_m,path,extension)
  // export to a graphic file by first creating a graphic window.
  // This will be changed when it will be possible to draw on 
  // a figure not associated to a graphic window. 
  // jpc 2011. 
    
    if ~isempty(winsid()) then 
      old_curwin=xget('window')
      curwin=max(winsid())+1
    else
      old_curwin=[];
      curwin=0;
    end
    xset('window',curwin);
    options=scs_m.props.options
    set_background();
    scs_m=scs_m_remove_gr(scs_m);
    %zoom=restore(curwin,[],1.0);
    drawobjs(scs_m);
    xexport(curwin,file('join',[path,scs_m.props.title(1)+extension]));
    xdel(curwin);
    if ~isempty(old_curwin) then xset('window',old_curwin);end
  endfunction

  // choose a folder 
  title=['Choose a folder where exported figures are to be placed']
  path=xgetfile(dir="/tmp",title=title,folder=%t)
  if path.equal[''] then return;end 
  // choose a graphic file type 
  extensions=['.eps','.png','.pdf','.gif','.gif'];
  names=['postcript','png','pdf','gif','svg'];
  l1=list('combo','Graphic File',1,names);
  [Lres,L]=x_choices('Graphic export',list(l1),%t); 
  if isempty(Lres) then return;end 
  ext = extensions(Lres(1));
  // recursively export the files 
  do_export__(scs_m,path,ext);
  for k=1:length(scs_m.objs)
    o=scs_m.objs(k)
    if o.type =='Block' && o.model.sim(1)=='super' then 
      do_export__(o.model.rpar,path,ext);
    end
  end
endfunction





