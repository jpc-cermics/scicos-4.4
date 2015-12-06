function scmenu_export()
// Export scs_m by redrawing the diagram in a graphic window
// or by exporting scs_m in a graphic file 
// 
  do_export(scs_m)
  Cmenu=''
endfunction

function scmenu_export_all()
// Export recursively scs_m in graphic files stored in 
// a directory.
  do_export_all(scs_m,fb=%f);
  Cmenu=''
endfunction

function do_export(scs_m,fname) 

  function do_export_gwin(scs_m)
  // export to a graphic window
    win = window_newid();
    if win > 0 then oldwin= xget('window');end
    scs_m.props.title(1)='Scilab Graphics of '+scs_m.props.title(1);
    scs_m=scicos_diagram_show(scs_m,win=win,margins=%f,scicos_uim=%f,read=%f);
    if win > 0 then xset('window',oldwin);end
  endfunction
  
  function do_export_gfile(scs_m,fname) 
  // export to a graphic file according to
  // file extensions. 
  // XXX check drivers for eps et ps ? who is the old one 
  // and who is the ps via cairo ? 
    win = window_newid();
    if win > 0 then oldwin= xget('window');end
    scs_m.props.title(1)='Scilab Graphics of '+scs_m.props.title(1);
    scs_m=scicos_diagram_show(scs_m,win=win,margins=%f,scicos_uim=%f,read=%f);
    xexport(win,fname,mode='k');
    xdel(win);
    if win > 0 then xset('window',oldwin);end
  endfunction
  
  num=1;
  if nargin==1 then
    num=x_choose(['Graphic file';'Graphics window'],'How do you want to export?');
    if num==0 then return;end
    if num<>2 then 
      while %t then 
	fname= xgetfile(save=%t);
	if fname == "" then return;end;
	ext= file('extension',fname);
	if ~or(ext==['.svg','.pdf','.eps','.ps','.fig','.png']) then
	  message(['File extension should be .eps, .ps, .png, .pdf or .svg"]);
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

function do_export_all(scsm,fname=[],path=[],ext=[],depth=1,fb=%f)
// export the diagram and all the contained super blocks 
// ut to depth given by depth to graphic files.
// path: is the repository name in which files are exported
// fname: if given it is the prefix name used for exports
//        if not given then the diagram name ans superblock names will be used.
// ext: file suffix which code the graphic files to use 
// depth: depth for exports 
// fb: boolean to specify if the figure_background is to be kept or not 
//     it can be usefull to set this value to %f when exporting to get
//     rid of the enclosed white rectangle around the diagram.
  
  function do_export_scsm(scs_m,path,ext,fname,d,fb)
  // export to a graphic file by first creating a graphic window.
  // This will be changed when it will be possible to draw on 
  // a figure not associated to a graphic window. 
  // jpc 2011. 
    win = window_newid();
    if win > 0 then oldwin= xget('window');end
    scs_m=scicos_diagram_show(scs_m,win=win,margins=%f,scicos_uim=%f,read=%f);
    if isempty(fname) 
      fname_export = file('join',[path,scs_m.props.title(1)+ext]);
    else
      fname_export = file('join',[path,fname+ext]);
    end
    xexport(win,fname_export,mode='k',figure_background=fb);
    xdel(win);
    if win > 0 then xset('window',oldwin);end
  endfunction
  
  function count=do_export_recursive(scsm,path,ext,fname,count,d,depth,fb);
    if d > depth then return;end 
    oname=fname;
    if ~isempty(oname) then oname = oname + sprintf("%02d",count);end 
    do_export_scsm(scsm,path,ext,oname,d,fb);
    count=count+1;
    for k=1:length(scsm.objs)
      o=scsm.objs(k)
      if o.type =='Block' && o.model.sim(1)=='super' then 
	count=do_export_recursive(o.model.rpar,path,ext,fname,count,d+1,depth,fb);
      end
    end
  endfunction
  
  // choose a folder 
  if isempty(path) 
    title=['Choose a folder where exported figures are to be placed']
    path=xgetfile(dir="/tmp",title=title,folder=%t);
    if path.equal[''] then return;end;
  end
  // choose a graphic file type 
  if isempty(ext) then 
    exts=['.eps','.png','.pdf','.gif','.svg'];
    names=['postcript','png','pdf','gif','svg'];
    l1=list('combo','Graphic File',1,names);
    [Lres,L]=x_choices('Graphic export',list(l1),%t); 
    if isempty(Lres) then return;end 
    ext = exts(Lres(1));
  end
  
  // recursively export the files 
  do_export_recursive(scsm,path,ext,fname,1,0,depth,fb);
endfunction





