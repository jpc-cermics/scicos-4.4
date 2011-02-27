function Export_()
  do_export(scs_m)
  Cmenu='Replot'
endfunction

function do_export(scs_m,fname) 
  driv='Pos';
  num=1
  wpar=scs_m.props.wpar
  winc=xget('window');
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
// file extensions.
// jpc 2011 
  cwin=xget('window');
  xexport(cwin,fname);
endfunction



